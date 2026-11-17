"""Audit the saved native place: preserved gameplay/NPCs, new textures, exact placement deltas."""
import ast,json,hashlib,xml.etree.ElementTree as ET
from pathlib import Path
R=Path(__file__).resolve().parents[1];ROOT=R
t=ast.parse((R/'tools/collect_depth_verification.py').read_text(encoding='utf-8'))
exec(compile(ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name in {'name','get','refs','signature'}],type_ignores=[]),'helpers','exec'))
old=ET.parse(R/'build/backups/SuckTheSea-before-surface-upgrade.rbxlx').getroot();new=ET.parse(R/'build/SuckTheSea.rbxlx').getroot();oref,nref=refs(old),refs(new)
def index(root):
 out={}
 def visit(e,path=''):
  for c in e.findall('Item'):
   p=path+'.'+name(c) if path else name(c);out[p]=c;visit(c,p)
 visit(root);return out
oi,ni=index(old),index(new);fit=json.loads((R/'assets/surfaces/support-fit.json').read_text());issues=[]
def numbers(e,key):return [float(c.text) for c in e.find('./Properties/*[@name="'+key+'"]')]
def prop(e,key):
 p=e.find('./Properties/*[@name="'+key+'"]');return ET.tostring(p,encoding='unicode').strip() if p is not None else None
for path,e in oi.items():
 if e.get('class')!='MeshPart':continue
 if path not in ni:issues.append('Removed mesh '+path);continue
 current=ni[path];expected=numbers(e,'CFrame')
 for r in fit['fits']:
  if path==r['path'] or path.startswith(r['path']+'.'):expected[1]+=r['deltaY']
 if max(abs(a-b) for a,b in zip(expected,numbers(current,'CFrame')))>0.0004:issues.append('Unexpected transform '+path)
 if max(abs(a-b) for a,b in zip(numbers(e,'size'),numbers(current,'size')))>0.0002:issues.append('Changed mesh scale '+path)
 for k in ('Anchored','CanCollide','CanQuery','CanTouch','CollisionGroup','CastShadow','RenderFidelity'):
  if prop(e,k)!=prop(current,k):issues.append('Changed '+k+' '+path)
preserved={p:signature(get(old,p.split('.')),oref)==signature(get(new,p.split('.')),nref) for p in ('Workspace.NPCs','Lighting','Workspace.Terrain','Workspace.Ocean.WetShoreRig','StarterGui','StarterPlayer','ReplicatedStorage.SeaGame.Shared','ReplicatedStorage.SeaGame.Client')}
matches={}
for group in ('Shared','Client','Server','Tests'):
 for file in (R/'src'/group).glob('*.luau'):
  ident=file.name.replace('.server.luau','').replace('.client.luau','').replace('.luau','')
  path='StarterPlayer.StarterPlayerScripts.SeaGameClient' if '.client.' in file.name else ('ServerScriptService.SeaGame.'+ident if group=='Server' else 'ServerStorage.SeaGameTests.'+ident if group=='Tests' else 'ReplicatedStorage.SeaGame.'+group+'.'+ident)
  code=ni[path].findtext('./Properties/*[@name="Source"]') or ''
  matches[str(file.relative_to(R))]=code.replace('\r\n','\n').strip()==file.read_text(encoding='utf-8').replace('\r\n','\n').strip()
temporary=[p for p in ni if any(s in p for s in ('SurfaceLiveCheck','SurfacePreloadCheck','SurfaceWaterPreview','SurfaceChestCheck','SurfacePerformanceCheck','SurfaceChestSaleCheck','SurfaceInstancePreload','SuckTheSea_Surfaces','LiveLoot'))]
appearance_count=0;missing=[]
for p,e in ni.items():
 if e.get('class')=='SurfaceAppearance' and name(e)=='SeaSurface':
  appearance_count+=1
  for k in ('ColorMapContent','NormalMapContent','RoughnessMapContent','MetalnessMapContent'):
   value=e.find('./Properties/*[@name="'+k+'"]')
   if value is None or not ''.join(value.itertext()).strip():missing.append(p+' '+k)
qa=json.loads((R/'assets/surfaces/qa.json').read_text());manifest=json.loads((R/'assets/surfaces/manifest.json').read_text());runtime=json.loads((R/'build/surface-runtime-verification.json').read_text())
counts=dict(texturedMeshParts=appearance_count,corals=len(get(new,['Workspace','UnderwaterTerrain','PolishedReefs']).findall('Item')),lootPrefabs=len(get(new,['ReplicatedStorage','SeaGame','Assets','Loot']).findall('Item')),tools=len(get(new,['ReplicatedStorage','SeaGame','Assets','Tools']).findall('Item')),groundedObjects=len(fit['fits']),rewardLandingSites=len(fit['drops']),bakedLootSites=fit['lootNodes'])
report=dict(place='build/SuckTheSea.rbxlx',sha256=hashlib.sha256((R/'build/SuckTheSea.rbxlx').read_bytes()).hexdigest(),preserved=preserved,sourceMatches=matches,placementAndPhysicsIssues=issues,missingPBRMaps=missing,temporaryObjects=temporary,counts=counts,blenderQA=dict(allPassed=all(x['pass'] for x in qa.values()),authoredMeshes=len(manifest['objects']),triangles=sum(x['triangles'] for x in manifest['objects']),maximumTriangles=max(x['triangles'] for x in manifest['objects']),acceptedWarnings='Shared procedural trim UVs; independent placed props; source world-coordinate origins; hidden construction contacts; intentional touching vertices on separate material pieces.'),runtime=runtime)
report['passed']=all(preserved.values()) and all(matches.values()) and not issues and not missing and not temporary and appearance_count==384 and counts['corals']==104 and counts['lootPrefabs']==51 and counts['tools']==11 and report['blenderQA']['allPassed'] and runtime['live']['pass'] and runtime['captain']['pass'] and runtime['ruins']['pass'] and not runtime['preload']['failed']
(R/'build/surface-verification.json').write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding='utf-8')
print(json.dumps({k:v for k,v in report.items() if k not in ('runtime','sha256','sourceMatches')},ensure_ascii=False,indent=2));print('SOURCE_MATCHES',sum(matches.values()),len(matches))
assert report['passed'],'Saved surface upgrade audit failed'
