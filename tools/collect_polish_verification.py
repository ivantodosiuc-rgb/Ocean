"""Audit saved native Studio map against STEP4 backup and local source files."""
import ast, hashlib, json, re, xml.etree.ElementTree as ET
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
helpers=ast.parse((ROOT/'tools/collect_depth_verification.py').read_text(encoding='utf-8'))
exec(compile(ast.Module(body=[n for n in helpers.body if isinstance(n,ast.FunctionDef) and n.name in {'name','get','refs','signature'}],type_ignores=[]),'audit_helpers','exec'))
place=ROOT/'build/SuckTheSea.rbxlx'
before=ET.parse(ROOT/'build/backups/SuckTheSea-before-step4.rbxlx').getroot();after=ET.parse(place).getroot()
a,b=refs(before),refs(after)
preserved={f:signature(get(before,['Workspace',f]),a)==signature(get(after,['Workspace',f]),b) for f in ['Buildings','NPCs']}
def scripts(root):
    result={}
    def visit(node,path):
        for item in node.findall('Item'):
            full=path+[name(item)]
            if item.attrib.get('class') in ['ModuleScript','Script','LocalScript']:
                result['/'.join(full)]=item.findtext('./Properties/*[@name="Source"]') or ''
            visit(item,full)
    visit(root,[]);return result
old_scripts,new_scripts=scripts(before),scripts(after)
matches={}
for group in ['Shared','Server','Client','Tests']:
    for f in (ROOT/'src'/group).glob('*.luau'):
        ident=f.name.replace('.server.luau','').replace('.client.luau','').replace('.luau','')
        path='StarterPlayer/StarterPlayerScripts/SeaGameClient' if '.client.' in f.name else ('ServerScriptService/SeaGame/'+ident if group=='Server' else 'ServerStorage/SeaGameTests/'+ident if group=='Tests' else 'ReplicatedStorage/SeaGame/'+group+'/'+ident)
        matches[str(f.relative_to(ROOT))]=new_scripts.get(path,'').replace('\r\n','\n').strip()==f.read_text(encoding='utf-8').replace('\r\n','\n').strip()
protected={p:s==new_scripts.get(p) for p,s in old_scripts.items() if p.startswith(('ReplicatedStorage/SeaGame/Shared/','ServerScriptService/SeaGame/')) and not p.endswith('/Wrecks') or p in ['ReplicatedStorage/SeaGame/Client/UI','ReplicatedStorage/SeaGame/Client/Theme','ReplicatedStorage/SeaGame/Client/Components','ReplicatedStorage/SeaGame/Client/Controller']}
loot=get(after,['ReplicatedStorage','SeaGame','Assets','Loot'])
loot_before=get(before,['ReplicatedStorage','SeaGame','Assets','Loot'])
# References inside loot are normalized against their own document.
loot_equal=signature(loot,b)==signature(loot_before,a)
qa=json.loads((ROOT/'assets/polish/qa.json').read_text());wetqa=json.loads((ROOT/'assets/polish/wet-shore-qa.json').read_text());manifest=json.loads((ROOT/'assets/polish/manifest.json').read_text())
events=[];runtime_errors=[]
logs=[Path('C:/Users/Administrator/AppData/Local/Roblox/logs')/n for n in ['0.747.0.7471481_20261116T092718Z_Studio_08039_last.log','0.747.0.7471481_20261116T163659Z_Studio_94EE7_last.log']]
for log in logs:
    for line in log.read_text(encoding='utf-8',errors='replace').splitlines():
        m=re.match(r'^(2026[^,]+).*\[FLog::(?:CreatorOutput|CreatorError)\] (.+)$',line)
        if not m:continue
        at,message=m.groups()
        if message.startswith(('POLISH_','OCEAN_LIVE_PASS','OCEAN_CLIENT_PASS','STEP3_UNIT_COMPLETE','OCEAN_UNIT_COMPLETE')) and not message.startswith(('POLISH_CONTOUR_POINTS','POLISH_PLACEMENT')):
            events.append(dict(time=at,message=message))
        if at>='2026-11-16T16:54:00' and re.match(r'Error: (ReplicatedStorage.SeaGame|ServerScriptService.SeaGame|Players\.[^.]+\.PlayerScripts\.SeaGameClient)',message):runtime_errors.append(message)
temporary=[p for p in b.values() if 'TemporaryStep3Test' in p or 'TemporarySceneEdit' in p or 'LocalSeaEffects' in p]
report=dict(place=str(place.relative_to(ROOT)),sha256=hashlib.sha256(place.read_bytes()).hexdigest(),preservedBuildingsAndNPCs=preserved,protectedCodeUnchanged=protected,installedSourceMatches=matches,lootPrefabs=len(loot.findall('Item')),lootPrefabsUnchanged=loot_equal,temporaryObjectsSaved=temporary,blenderQA=dict(meshes=len(manifest['objects'])+1,allPassed=all(q['pass'] for q in qa.values()) and wetqa['pass'],triangles=sum(o['triangles'] for o in manifest['objects'])+2880,acceptedWarnings='Intentional atlas UV stacking and authored assembly origins; unweighted armature Root. Final mesh QA has no errors.'),visibleSurfaceCheck=json.loads((ROOT/'build/polish-visible-surface-check.json').read_text()),runtimeErrorsInFinalGameModules=runtime_errors,verifiedEvents=events,limitations=['Single-client Studio performance measurements; no physical mobile-device or multi-client performance pass.','Cloud DataStore rejoin is not verified: the experience remains unpublished.','Underwater screenshots use Play-only in-memory progress fixtures.','Chest videos are actual Studio recordings without audio capture.'])
report['passed']=all(preserved.values()) and all(protected.values()) and all(matches.values()) and loot_equal and len(loot.findall('Item'))==50 and not temporary and not runtime_errors and report['blenderQA']['allPassed'] and len(report['visibleSurfaceCheck'])==5
(ROOT/'build/polish-verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in report.items() if k not in ['verifiedEvents','protectedCodeUnchanged','sha256']},ensure_ascii=False,indent=2))
assert report['passed'],'Final native map audit failed'
