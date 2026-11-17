"""Audit the actual saved Studio place, Blender geometry reports, and playtest logs."""
import hashlib
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
place = ROOT / 'build/SuckTheSea.rbxlx'
after = ET.parse(place).getroot()
before = ET.parse(ROOT / 'build/backups/SuckTheSea-before-underwater-expansion.rbxlx').getroot()

def name(e):
    return e.findtext('./Properties/string[@name="Name"]') or e.attrib.get('class', '')

def get(e, path):
    for segment in path:
        e = next(c for c in e.findall('Item') if name(c) == segment)
    return e

def refs(e):
    result = {}
    def visit(parent, path):
        for item in parent.findall('Item'):
            full = path + [name(item)]
            result[item.attrib.get('referent', '')] = '/'.join(full)
            visit(item, full)
    visit(e, [])
    return result

def signature(e, references):
    def value(p):
        text = (p.text or '').strip()
        if p.tag == 'Ref':
            text = references.get(text, text)
        return (p.tag, tuple(sorted(p.attrib.items())), text, tuple(value(c) for c in p))
    props = tuple(sorted((value(p) for p in e.find('Properties') if p.attrib.get('name') not in ['UniqueId', 'HistoryId']), key=str))
    return (e.attrib['class'], props, tuple(sorted((signature(c, references) for c in e.findall('Item')), key=str)))

a, b = refs(before), refs(after)
preserved = {folder: signature(get(before, ['Workspace', folder]), a) == signature(get(after, ['Workspace', folder]), b) for folder in ['Buildings', 'NPCs']}
scripts = {}
all_items = {}
def scan(parent, path):
    for item in parent.findall('Item'):
        full = path + [name(item)]
        all_items['/'.join(full)] = item
        if item.attrib.get('class') in ['ModuleScript', 'Script', 'LocalScript']:
            scripts['/'.join(full)] = item.findtext('./Properties/*[@name="Source"]') or ''
        scan(item, full)
scan(after, [])
sources = {}
for group in ['Shared', 'Server', 'Client', 'Tests']:
    for f in (ROOT / 'src' / group).glob('*.luau'):
        script_name = f.name.replace('.server.luau', '').replace('.client.luau', '').replace('.luau', '')
        if '.client.' in f.name:
            path = 'StarterPlayer/StarterPlayerScripts/SeaGameClient'
        elif group == 'Server':
            path = 'ServerScriptService/SeaGame/' + script_name
        elif group == 'Tests':
            path = 'ServerStorage/SeaGameTests/' + script_name
        else:
            path = 'ReplicatedStorage/SeaGame/' + group + '/' + script_name
        sources[str(f.relative_to(ROOT))] = scripts.get(path, '').replace('\r\n', '\n').strip() == f.read_text(encoding='utf-8').replace('\r\n', '\n').strip()

loot = get(after, ['ReplicatedStorage', 'SeaGame', 'Assets', 'Loot']).findall('Item')
loot_meshes = [p for item in loot for p in item.iter('Item') if p.attrib.get('class') == 'MeshPart']
mesh_ids = [p.findtext('./Properties/Content[@name="MeshContent"]/uri') or p.findtext('./Properties/Content[@name="MeshId"]/url') or '' for p in loot_meshes]
qa = json.loads((ROOT / 'assets/depth/qa.json').read_text())
manifest = json.loads((ROOT / 'assets/depth/manifest.json').read_text())
log = Path('C:/Users/Administrator/AppData/Local/Roblox/logs/0.747.0.7471481_20261116T092718Z_Studio_08039_last.log')
events, runtime_errors, samples = [], [], []
for line in log.read_text(encoding='utf-8', errors='replace').splitlines():
    m = re.match(r'^(2026[^,]+).*\[FLog::(?:CreatorOutput|Output|CreatorError)\] (.+)$', line)
    if not m:
        continue
    timestamp, message = m.groups()
    if message.startswith(('DEPTH_', 'EXPANSION_PERF')) or (message.startswith('STEP3_UNIT_COMPLETE') and timestamp >= '2026-11-16T12:00'):
        events.append({'time': timestamp, 'message': message})
    if timestamp >= '2026-11-16T12:18:' and re.match(r'Error: (ReplicatedStorage.SeaGame|ServerScriptService.SeaGame|Players\.[^.]+\.PlayerScripts\.SeaGameClient)', message):
        runtime_errors.append(message)
    if message.startswith('EXPANSION_PERF '):
        fields = message.split()
        sample = dict(time=timestamp, mode=fields[1], frames=int(fields[2]), averageMs=float(fields[3]), p95Ms=float(fields[4]), maximumMs=float(fields[5]), waterStart=float(fields[6]), waterEnd=float(fields[7]))
        sample['realDrain'] = sample['waterEnd'] < sample['waterStart'] - .2
        sample['backgroundThrottleSuspected'] = 64 < sample['averageMs'] < 69
        samples.append(sample)

def latest(prefix):
    return next((e for e in reversed(events) if e['message'].startswith(prefix)), None)

report = {
    'place': str(place.relative_to(ROOT)),
    'sha256': hashlib.sha256(place.read_bytes()).hexdigest(),
    'preservedBuildingsAndNPCs': preserved,
    'installedSourceMatches': sources,
    'temporaryObjectsSaved': [p for p in all_items if 'TemporaryStep3Test' in p or 'TemporarySceneEdit' in p or 'SuckTheSea_Depth' in p],
    'resources': {'count': len(loot), 'meshCount': len(loot_meshes), 'uniqueMeshIds': len(set(mesh_ids)), 'allUploaded': all(m.startswith('rbxassetid://') for m in mesh_ids)},
    'blenderQA': {'meshes': len(qa), 'allPassed': all(x['pass'] for x in qa.values()), 'triangles': sum(x['triangles'] for x in manifest['objects']), 'acceptedWarnings': 'Intentional stacked palette UVs; separate closed prop components retain coincident end caps/vertices. No reported floating components or z-fighting.'},
    'runtimeErrorsInFinalGameModules': runtime_errors,
    'unitTests': latest('STEP3_UNIT_COMPLETE'),
    'wreckIntegration': latest('DEPTH_SERVER_COMPLETE'),
    'nativeKeyOne': latest('DEPTH_NATIVE_ONE_PASS'),
    'collisionRoutes': latest('DEPTH_SLOPES_PASS'),
    'ruinsLoot': latest('DEPTH_RUINS_PASS'),
    'physicalTideCycle': latest('DEPTH_TIDE_PASS'),
    'boatFollowsWater': latest('DEPTH_BOAT_PASS'),
    'finalEditAudit': latest('DEPTH_EDIT_AUDIT'),
    'waterPerformanceSamples': samples,
    'verifiedEvents': events,
    'limitations': ['Studio single-client timings, not a guarantee for all hardware or published servers.', 'Background Studio throttles to 15 FPS; zero-drain samples and overlapping test runs are excluded from improvement claims.', 'Unpublished experience: live DataStore rejoin not tested.', 'No physical phone or two-client session in this expansion pass.'],
}
report['savedMapAuditPassed'] = all(preserved.values()) and all(sources.values()) and not report['temporaryObjectsSaved'] and not runtime_errors and report['blenderQA']['allPassed'] and len(loot) == 50 and len(set(mesh_ids)) == 50
(ROOT / 'build/depth-verification.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
print(json.dumps({k: v for k, v in report.items() if k not in ['verifiedEvents', 'waterPerformanceSamples', 'sha256', 'limitations']}, ensure_ascii=False, indent=2))
assert report['savedMapAuditPassed'], 'Saved map or source audit failed'
assert all(report[k] for k in ['physicalTideCycle', 'boatFollowsWater', 'wreckIntegration', 'nativeKeyOne', 'collisionRoutes', 'ruinsLoot']), 'Required playtest evidence missing'
