"""Compare the saved native place to pre-comfort snapshot and local sources."""
import ast,hashlib,json,xml.etree.ElementTree as ET
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
tree=ast.parse((ROOT/'tools/collect_depth_verification.py').read_text(encoding='utf-8'))
exec(compile(ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name in {'name','get','refs','signature'}],type_ignores=[]),'audit_helpers','exec'))
place=ROOT/'build/SuckTheSea.rbxlx';before=ET.parse(ROOT/'build/backups/SuckTheSea-before-comfort.rbxlx').getroot();after=ET.parse(place).getroot();a,b=refs(before),refs(after)
preserved={}
for folder in ['NPCs','UnderwaterTerrain','Ocean']:
 preserved[folder]=signature(get(before,['Workspace',folder]),a)==signature(get(after,['Workspace',folder]),b)
preserved['Lighting']=signature(get(before,['Lighting']),a)==signature(get(after,['Lighting']),b)
for old in get(before,['Workspace','Buildings']).findall('Item'):
 preserved['Buildings/'+name(old)]=signature(old,a)==signature(get(after,['Workspace','Buildings',name(old)]),b)
for old in get(before,['Workspace','StarterIsland']).findall('Item'):
 preserved['StarterIsland/'+name(old)]=signature(old,a)==signature(get(after,['Workspace','StarterIsland',name(old)]),b)
scripts={};paths=[]
def visit(node,path):
 for item in node.findall('Item'):
  current=path+[name(item)];paths.append('/'.join(current))
  if item.attrib.get('class') in ['ModuleScript','Script','LocalScript']:scripts['/'.join(current)]=item.findtext('./Properties/*[@name="Source"]') or ''
  visit(item,current)
visit(after,[])
matches={}
for group in ['Shared','Client','Server','Tests']:
 for file in (ROOT/'src'/group).glob('*.luau'):
  ident=file.name.replace('.server.luau','').replace('.client.luau','').replace('.luau','')
  path='StarterPlayer/StarterPlayerScripts/SeaGameClient' if '.client.' in file.name else ('ServerScriptService/SeaGame/'+ident if group=='Server' else 'ServerStorage/SeaGameTests/'+ident if group=='Tests' else 'ReplicatedStorage/SeaGame/'+group+'/'+ident)
  matches[str(file.relative_to(ROOT))]=scripts.get(path,'').replace('\r\n','\n').strip()==file.read_text(encoding='utf-8').replace('\r\n','\n').strip()
qa=json.loads((ROOT/'assets/comfort/qa.json').read_text());manifest=json.loads((ROOT/'assets/comfort/manifest.json').read_text());runtime=json.loads((ROOT/'build/comfort-runtime-verification.json').read_text())
temps=[p for p in paths if any(x in p for x in ['ComfortRuntimeProbe','ComfortFlowStage','ComfortLiveTests','ComfortDeathCheck','ComfortLayoutCheck','ComfortToiletPreview','LiveLoot'])]
counts={'tools':len(get(after,['ReplicatedStorage','SeaGame','Assets','Tools']).findall('Item')),'loot':len(get(after,['ReplicatedStorage','SeaGame','Assets','Loot']).findall('Item')),'starterSites':len(get(after,['Workspace','StarterIsland','StarterMusselSites']).findall('Item')),'coastalDecorations':len(get(after,['Workspace','Decorations','CoastalPlanting']).findall('Item'))}
report={'place':str(place.relative_to(ROOT)),'sha256':hashlib.sha256(place.read_bytes()).hexdigest(),'sourceMatches':matches,'preserved':preserved,'counts':counts,'temporaryObjectsSaved':temps,'blenderQA':{'allPassed':all(v['pass'] for v in qa.values()),'meshes':len(qa),'triangles':manifest['total_triangles'],'notes':'Intentional procedural atlas UV reuse; hidden board contact faces remain, no QA errors.'},'runtime':runtime}
report['passed']=all(matches.values()) and all(preserved.values()) and counts=={'tools':11,'loot':51,'starterSites':16,'coastalDecorations':27} and not temps and report['blenderQA']['allPassed'] and runtime['liveTests']['ok'] and all(v['ok'] for v in runtime['layouts'].values()) and all(runtime['deathCleanup'].values())
(ROOT/'build/comfort-verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in report.items() if k not in ['runtime','sha256']},ensure_ascii=False,indent=2))
assert report['passed'],'Saved place audit failed'
