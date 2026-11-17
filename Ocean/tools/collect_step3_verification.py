import json,re,hashlib,xml.etree.ElementTree as ET
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
place=ROOT/'build/SuckTheSea.rbxlx'
after=ET.parse(place).getroot();before=ET.parse(ROOT/'build/backups/SuckTheSea-before-step3.rbxlx').getroot()
def name(e):return e.findtext('./Properties/string[@name="Name"]') or e.attrib.get('class','')
def get(e,path):
    for segment in path:e=next(c for c in e.findall('Item') if name(c)==segment)
    return e
def refs(e):
    result={}
    def visit(parent,path):
        for item in parent.findall('Item'):
            full=path+[name(item)];result[item.attrib.get('referent','')]='/'.join(full);visit(item,full)
    visit(e,[]);return result
def signature(e,references):
    def value(p):
        text=(p.text or '').strip()
        if p.tag=='Ref':text=references.get(text,text)
        return (p.tag,tuple(sorted((k,v) for k,v in p.attrib.items() if k!='referent')),text,tuple(value(c) for c in p))
    props=tuple(sorted((value(p) for p in e.find('Properties') if p.attrib.get('name') not in ['UniqueId','HistoryId']),key=str))
    return (e.attrib['class'],props,tuple(sorted((signature(c,references) for c in e.findall('Item')),key=str)))
a,b=refs(before),refs(after);preserved={}
for folder in ['StarterIsland','Buildings','Decorations','NPCs','UnderwaterTerrain']:
    preserved[folder]=signature(get(before,['Workspace',folder]),a)==signature(get(after,['Workspace',folder]),b)
preserved['Lighting']=signature(get(before,['Lighting']),a)==signature(get(after,['Lighting']),b)
scripts={}
def scan(parent,path=[]):
    for item in parent.findall('Item'):
        full=path+[name(item)]
        if item.attrib.get('class') in ['ModuleScript','Script','LocalScript']:
            source=item.find('./Properties/*[@name="Source"]');scripts['/'.join(full)]=source.text or ''
        scan(item,full)
scan(after)
sources={}
for group in ['Shared','Server','Client','Tests']:
    for f in (ROOT/'src'/group).glob('*.luau'):
        script_name=f.name.replace('.server.luau','').replace('.client.luau','').replace('.luau','')
        if '.client.' in f.name:path='StarterPlayer/StarterPlayerScripts/SeaGameClient'
        elif group=='Server':path='ServerScriptService/SeaGame/'+script_name
        elif group=='Tests':path='ServerStorage/SeaGameTests/'+script_name
        else:path='ReplicatedStorage/SeaGame/'+group+'/'+script_name
        sources[str(f.relative_to(ROOT))]=scripts.get(path,'').replace('\r\n','\n').strip()==f.read_text(encoding='utf-8').replace('\r\n','\n').strip()
qa=json.loads((ROOT/'assets/gameplay/qa.json').read_text());manifest=json.loads((ROOT/'assets/gameplay/manifest.json').read_text())
log=Path('C:/Users/Administrator/AppData/Local/Roblox/logs/0.747.0.7471481_20261116T092718Z_Studio_08039_last.log')
events=[];runtime_errors=[]
for line in log.read_text(encoding='utf-8',errors='replace').splitlines():
    m=re.match(r'^(2026[^,]+).*\[FLog::(?:CreatorOutput|Output|CreatorError)\] (.+)$',line)
    if not m:continue
    timestamp,message=m.groups()
    if message.startswith('STEP3_'):events.append({'time':timestamp,'message':message})
    if timestamp>='2026-11-16T11:05:' and re.match(r'Error: (ReplicatedStorage.SeaGame|ServerScriptService.SeaGame|Players\.[^.]+\.PlayerScripts\.SeaGameClient)',message):runtime_errors.append(message)
report={'place':str(place.relative_to(ROOT)),'sha256':hashlib.sha256(place.read_bytes()).hexdigest(),'preservedMapAndLighting':preserved,'installedSourceMatches':sources,'temporaryTestsSaved':[p for p in scripts if 'TemporaryStep3Test' in p],'blenderQA':{'meshes':len(qa),'allPassed':all(x['pass'] for x in qa.values()),'triangles':sum(x['triangles'] for x in manifest['objects']),'intentionalUVOverlap':'Single palette atlas'},'runtimeErrorsInFinalGameModules':runtime_errors,'latestUnitCompletion':next((e for e in reversed(events) if e['message'].startswith('STEP3_UNIT_COMPLETE')),None),'latestLoopCompletion':next((e for e in reversed(events) if e['message'].startswith('STEP3_LOOP_COMPLETE')),None),'waterPerformance':next((e for e in reversed(events) if e['message'].startswith('STEP3_FINAL_WATER_PERF')),None),'verifiedEvents':events,'limitations':['Unpublished PlaceId=0/GameId=0: cloud DataStore rejoin not tested; dependency-injected storage tests passed.','No two-client session or physical phone test. iPhone XR Simulator portrait/landscape and actual touch hold tested.','Capture frame rate is separate from game performance; preview video has no recorded audio.']}
report['savedMapAuditPassed']=all(preserved.values()) and all(sources.values()) and not report['temporaryTestsSaved'] and not runtime_errors and report['blenderQA']['allPassed']
(ROOT/'build/step3-verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in report.items() if k not in ['verifiedEvents','sha256','limitations']},ensure_ascii=False,indent=2))
assert report['savedMapAuditPassed'],'Saved map or source audit failed'
