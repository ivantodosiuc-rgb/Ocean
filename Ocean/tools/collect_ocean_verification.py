"""Verify the final saved place against local code and the pre-progress map."""
import hashlib,json,re,xml.etree.ElementTree as ET
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
place=ROOT/'build/SuckTheSea.rbxlx'
before=ET.parse(ROOT/'build/backups/SuckTheSea-before-ocean-progress.rbxlx').getroot()
after=ET.parse(place).getroot()
def name(e):return e.findtext('./Properties/string[@name="Name"]') or e.attrib.get('class','')
def get(e,path):
    for segment in path:e=next(c for c in e.findall('Item') if name(c)==segment)
    return e
def references(e):
    result={}
    def visit(parent,path):
        for item in parent.findall('Item'):
            full=path+[name(item)];result[item.attrib.get('referent','')]='/'.join(full);visit(item,full)
    visit(e,[]);return result
def signature(e,refs):
    def value(p):
        text=(p.text or '').strip()
        if p.tag=='Ref':text=refs.get(text,text)
        return (p.tag,tuple(sorted(p.attrib.items())),text,tuple(value(c) for c in p))
    props=tuple(sorted((value(p) for p in e.find('Properties') if p.attrib.get('name') not in ['UniqueId','HistoryId']),key=str))
    return (e.attrib['class'],props,tuple(sorted((signature(c,refs) for c in e.findall('Item')),key=str)))
a,b=references(before),references(after)
preserved={}
for folder in ['StarterIsland','Buildings','Decorations','NPCs','Ocean','UnderwaterTerrain','Terrain']:
    preserved[folder]=signature(get(before,['Workspace',folder]),a)==signature(get(after,['Workspace',folder]),b)
preserved['Lighting']=signature(get(before,['Lighting']),a)==signature(get(after,['Lighting']),b)
scripts={};items={}
def scan(parent,path):
    for item in parent.findall('Item'):
        full=path+[name(item)];items['/'.join(full)]=item
        if item.attrib.get('class') in ['Script','LocalScript','ModuleScript']:
            scripts['/'.join(full)]=item.findtext('./Properties/*[@name="Source"]') or ''
        scan(item,full)
scan(after,[])
sources={}
for group in ['Shared','Server','Client','Tests']:
    for f in (ROOT/'src'/group).glob('*.luau'):
        n=f.name.replace('.server.luau','').replace('.client.luau','').replace('.luau','')
        if '.client.' in f.name:p='StarterPlayer/StarterPlayerScripts/SeaGameClient'
        elif group=='Server':p='ServerScriptService/SeaGame/'+n
        elif group=='Tests':p='ServerStorage/SeaGameTests/'+n
        else:p='ReplicatedStorage/SeaGame/'+group+'/'+n
        sources[str(f.relative_to(ROOT))]=scripts.get(p,'').replace('\r\n','\n').strip()==f.read_text(encoding='utf-8').replace('\r\n','\n').strip()
loot=get(after,['ReplicatedStorage','SeaGame','Assets','Loot']).findall('Item')
meshes=[p for item in loot for p in item.iter('Item') if p.attrib.get('class')=='MeshPart']
mesh_ids=[p.findtext('./Properties/Content[@name="MeshContent"]/uri') or p.findtext('./Properties/Content[@name="MeshId"]/url') or '' for p in meshes]
events=[];errors=[]
log=Path('C:/Users/Administrator/AppData/Local/Roblox/logs/0.747.0.7471481_20261116T092718Z_Studio_08039_last.log')
for line in log.read_text(encoding='utf-8',errors='replace').splitlines():
    match=re.match(r'^(2026[^,]+).*\[FLog::(?:CreatorOutput|CreatorError|Output)\] (.+)$',line)
    if not match:continue
    timestamp,message=match.groups()
    if timestamp<'2026-11-16T12:49:':continue
    if message.startswith(('OCEAN_','STEP3_UNIT_COMPLETE')):events.append({'time':timestamp,'message':message})
    if re.match(r'Error: (ReplicatedStorage.SeaGame|ServerScriptService.SeaGame|Players\.[^.]+\.PlayerScripts\.SeaGameClient)',message):errors.append({'time':timestamp,'message':message})
def latest(prefix):return next((e for e in reversed(events) if e['message'].startswith(prefix)),None)
qa=json.loads((ROOT/'assets/depth/qa.json').read_text())
report={
    'place':str(place.relative_to(ROOT)),
    'sha256':hashlib.sha256(place.read_bytes()).hexdigest(),
    'preservedExpandedMap':preserved,
    'installedSourceMatches':sources,
    'temporaryObjectsSaved':[p for p in items if 'TemporaryStep3Test' in p or 'TemporarySceneEdit' in p],
    'blenderResources':{'count':len(loot),'uniqueUploadedMeshes':len(set(mesh_ids)),'allUploaded':all(x.startswith('rbxassetid://') for x in mesh_ids),'all81MeshQAPassed':len(qa)==81 and all(q['pass'] for q in qa.values())},
    'globalProgressUnitTests':latest('OCEAN_UNIT_COMPLETE'),
    'economyProfileRegression':latest('STEP3_UNIT_COMPLETE'),
    'actualWaterAndVolumeTest':latest('OCEAN_LIVE_PASS'),
    'clientDisplayAndPerformance':latest('OCEAN_CLIENT_PASS'),
    'savedVolumeToPhysicalOceanRestorationFixture':latest('OCEAN_RESTORE_PASS'),
    'phoneLayouts':[e for e in events if e['message'].startswith('OCEAN_UI_LAYOUT_PASS')],
    'nativeTouchStrawToggle':latest('OCEAN_TOUCH_SLOT_PASS'),
    'runtimeErrorsInGameModules':errors,
    'events':events,
    'limitations':['Experience is unpublished. Real Roblox cloud DataStore, rejoin and cross-server messaging are NOT verified.','Concurrency, retries and restoration tests use a dependency-injected store in actual Studio Luau.','iPhone XR Simulator tested in both orientations; no physical phone or two-client session.','Terrain liquid occupancy was observed in 1/255 increments. Saved volume is not rounded to that representation.'],
}
report['savedMapAuditPassed']=all(preserved.values()) and all(sources.values()) and not report['temporaryObjectsSaved'] and not errors and len(loot)==50 and len(set(mesh_ids))==50
report['playVerificationPassed']=all(report[k] for k in ['globalProgressUnitTests','economyProfileRegression','actualWaterAndVolumeTest','clientDisplayAndPerformance','savedVolumeToPhysicalOceanRestorationFixture','nativeTouchStrawToggle']) and len(report['phoneLayouts'])>=2
(ROOT/'build/ocean-progress-verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in report.items() if k not in ['events','sha256','limitations']},ensure_ascii=False,indent=2))
assert report['savedMapAuditPassed'] and report['playVerificationPassed'],'Final saved map audit or playtest evidence failed'
