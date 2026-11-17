"""Verify the final native Studio file against source, asset QA and the pre-edit map."""
import ast
import hashlib
import json
import xml.etree.ElementTree as ET
from pathlib import Path

R = Path(__file__).resolve().parents[1]
tree = ast.parse((R / 'tools/collect_depth_verification.py').read_text(encoding='utf-8'))
exec(compile(ast.Module(body=[n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name in {'name', 'get', 'refs', 'signature'}], type_ignores=[]), 'audit_helpers', 'exec'))
old = ET.parse(R / 'build/backups/SuckTheSea-before-sparkle-update.rbxlx').getroot()
new = ET.parse(R / 'build/SuckTheSea.rbxlx').getroot()
oref, nref = refs(old), refs(new)

def index(root):
    out = {}
    def visit(parent, path=''):
        for item in parent.findall('Item'):
            full = path + '.' + name(item) if path else name(item)
            out[full] = item
            visit(item, full)
    visit(root)
    return out

oi, ni = index(old), index(new)
def prop(item, key):
    e = item.find('./Properties/*[@name="' + key + '"]')
    return ET.tostring(e, encoding='unicode').strip() if e is not None else None
def numbers(item, key):
    return [float(c.text) for c in item.find('./Properties/*[@name="' + key + '"]')]

unchanged = ['Workspace.Buildings', 'Workspace.NPCs', 'Lighting', 'Workspace.Terrain', 'Workspace.Ocean', 'Workspace.StarterIsland', 'Workspace.UnderwaterTerrain.Seafloor', 'Workspace.UnderwaterTerrain.PolishedReefs', 'Workspace.Decorations.CoastalPlanting', 'ReplicatedStorage.SeaGame.Assets.Loot', 'MaterialService', 'ServerScriptService.SeaGame.GroundSites', 'ServerScriptService.SeaGame.OceanLedger', 'ServerScriptService.SeaGame.OceanProgress', 'ReplicatedStorage.SeaGame.Shared.OceanVolume', 'ReplicatedStorage.SeaGame.Shared.Needs', 'ReplicatedStorage.SeaGame.Client.ShoreContours']
preserved = {p: signature(oi[p], oref) == signature(ni[p], nref) for p in unchanged}
sources = {}
for group in ('Shared', 'Client', 'Server', 'Tests'):
    for f in (R / 'src' / group).glob('*.luau'):
        ident = f.name.replace('.server.luau', '').replace('.client.luau', '').replace('.luau', '')
        path = 'StarterPlayer.StarterPlayerScripts.SeaGameClient' if '.client.' in f.name else ('ServerScriptService.SeaGame.' + ident if group == 'Server' else 'ServerStorage.SeaGameTests.' + ident if group == 'Tests' else 'ReplicatedStorage.SeaGame.' + group + '.' + ident)
        source = ni[path].findtext('./Properties/*[@name="Source"]') or ''
        sources[str(f.relative_to(R))] = source.replace('\r\n', '\n').strip() == f.read_text(encoding='utf-8').strip()

fits = json.loads((R / 'assets/sparkle/rock-fit.json').read_text())
fit_by_path = {f['path']: f for f in fits}
issues = []
for p, previous in oi.items():
    if previous.get('class') != 'MeshPart' or not p.startswith('Workspace.'):
        continue
    if p not in ni:
        issues.append('Removed world mesh: ' + p)
        continue
    current = ni[p]
    fit = fit_by_path.get(p)
    for key, expected in [('CFrame', fit['cf'] if fit else numbers(previous, 'CFrame')), ('size', fit['size'] if fit else numbers(previous, 'size'))]:
        if max(abs(a-b) for a,b in zip(numbers(current, key), expected)) > .0004:
            issues.append('Unexpected ' + key + ': ' + p)
    for key in ('Anchored', 'CanCollide', 'CanTouch', 'CanQuery', 'CollisionGroup', 'CollisionFidelity', 'CastShadow'):
        if prop(previous, key) != prop(current, key):
            issues.append('Changed physics flag ' + key + ': ' + p)

assets = []
for category in ('Tools', 'Icons'):
    folder = ni['ReplicatedStorage.SeaGame.Assets.' + category]
    for model in folder.findall('Item'):
        for part in model.iter('Item'):
            if part.get('class') == 'MeshPart':
                assets.append((category + '.' + name(model), part))
assets += [(f['path'], ni[f['path']]) for f in fits]
missing = []
for p, part in assets:
    sa = next((x for x in part.findall('Item') if x.get('class') == 'SurfaceAppearance'), None)
    if sa is None:
        missing.append(p + ': SurfaceAppearance')
        continue
    for key in ('ColorMapContent', 'NormalMapContent', 'RoughnessMapContent', 'MetalnessMapContent'):
        e = sa.find('./Properties/*[@name="' + key + '"]')
        if e is None or not ''.join(e.itertext()).strip():
            missing.append(p + ': ' + key)

temporary = [p for p in ni if any(x in p for x in ('TemporarySparkle', 'SuckTheSea_Sparkle', 'LiveLoot', 'SurfaceLiveCheck', 'SparklePreloadCheck'))]
qa = json.loads((R / 'assets/sparkle/qa.json').read_text())
manifest = json.loads((R / 'assets/sparkle/manifest.json').read_text())
tests = json.loads((R / 'build/sparkle-tests.json').read_text())
runtime = json.loads((R / 'build/sparkle-runtime-verification.json').read_text())
counts = dict(tools=len(ni['ReplicatedStorage.SeaGame.Assets.Tools'].findall('Item')), icons=len(ni['ReplicatedStorage.SeaGame.Assets.Icons'].findall('Item')), replacedRocks=len(fits), checkedTexturedParts=len(assets), meshesAuthored=len(manifest['objects']), triangles=manifest['triangles'], maximumTriangles=max(x['triangles'] for x in manifest['objects']))
unit_pass = all(x['ok'] for x in tests['tests']['units'].values())
report = dict(place='build/SuckTheSea.rbxlx', sha256=hashlib.sha256((R / 'build/SuckTheSea.rbxlx').read_bytes()).hexdigest(), preserved=preserved, sourceMatches=sources, placementAndPhysicsIssues=issues, missingPBRMaps=missing, temporaryObjects=temporary, counts=counts, blenderQA=dict(allPassed=all(x['pass'] for x in qa.values()), acceptedWarnings='Intentional stacked UVs sharing the authored enamel/stone atlas; no unique per-face lighting bake.'), grounding=dict(maximumFootGap=max(f['maxGap'] for f in fits), maximumVerticalAdjustment=max(abs(f['deltaY']) for f in fits)), tests=tests, runtime=runtime)
report['passed'] = all(preserved.values()) and all(sources.values()) and not issues and not missing and not temporary and counts['tools'] == 12 and counts['icons'] == 8 and counts['replacedRocks'] == 41 and report['blenderQA']['allPassed'] and unit_pass and all(v == 'Success' for v in tests['preload'].values()) and runtime['edit']['temporaryObjects'] == [] and runtime['edit']['device'] == 'default'
(R / 'build/sparkle-verification.json').write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding='utf-8')
print(json.dumps({k:v for k,v in report.items() if k not in ('tests', 'runtime', 'sourceMatches', 'sha256')}, indent=2))
print('SOURCE_MATCHES', sum(sources.values()), len(sources))
assert report['passed'], 'Sparkle saved place audit failed'
