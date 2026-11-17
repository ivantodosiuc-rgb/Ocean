"""Fit props and reward sites against visible triangles, never convex collision approximations."""
import bpy, json, math, random, struct, base64, xml.etree.ElementTree as ET
import numpy as np
from pathlib import Path
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree
R=Path(__file__).resolve().parents[1];O=R/'assets/surfaces'
rows=json.loads((O/'studio-inventory.json').read_text());mapping=json.loads((O/'mesh-mapping.json').read_text());source_inventory=json.loads((O/'source-inventory.json').read_text())
files={'island':'assets/SuckTheSea_Island.blend','depth':'assets/depth/SuckTheSea_Depth.blend','polish':'assets/polish/SuckTheSea_VisualPolish.blend','comfort':'assets/comfort/SuckTheSea_Comfort.blend'}
geometry={};groundverts=[];groundfaces=[]
for family,path in files.items():
 bpy.ops.wm.open_mainfile(filepath=str(R/path))
 for ob in bpy.context.scene.objects:
  if ob.type!='MESH':continue
  ob.data.calc_loop_triangles();points=np.array([(ob.matrix_world@v.co)[:] for v in ob.data.vertices]);faces=[tuple(t.vertices) for t in ob.data.loop_triangles]
  geometry[family,ob.name]=(points,faces)
  if family=='depth' and ob.name.startswith(('Ground__','Seabed__')):
   k=len(groundverts);groundverts.extend((p[0],p[2],-p[1]) for p in points);groundfaces.extend(tuple(k+i for i in f) for f in faces)
ground=BVHTree.FromPolygons(groundverts,groundfaces,all_triangles=True)
def hit(bvh,x,z,y=30):
 p,n,_,_=bvh.ray_cast(Vector((float(x),float(y),float(z))),Vector((0,-1,0)),180)
 return (p,n) if p else (None,None)
def worldgeo(row,dy=0):
 m=mapping[row['mesh']];v,faces=geometry[m['family'],m['source']];lo=v.min(axis=0);hi=v.max(axis=0);center=(lo+hi)/2
 q=v-center;q=q[:,[0,2,1]];q[:,0]*=-1
 q*=np.array(row['size'])/np.maximum((hi-lo)[[0,2,1]],.000001)
 cf=np.array(row['cf']);w=q@cf[3:].reshape(3,3).T+cf[:3];w[:,1]+=dy
 return w,faces
fits=[];shift={}
def fit_rows(group,target,bvh=ground,embed=.075):
 world=np.concatenate([worldgeo(r,shift.get(r['path'],0))[0] for r in group])
 # The foot band includes several vertices across the root footprint, rather than one center ray.
 low=world[:,1].min();band=min(.24,max(.08,np.ptp(world[:,1])*.025));foot=world[world[:,1]<=low+band]
 gaps=[]
 for v in foot:
  p,n=hit(bvh,v[0],v[2],low+18)
  if p is not None:gaps.append(float(v[1]-p.y))
 if not gaps:raise RuntimeError('No supporting ground '+target)
 dy=-max(gaps)-embed
 if abs(dy)>12:raise RuntimeError('Unexpected support correction '+target+' '+str(dy))
 for row in group:shift[row['path']]=shift.get(row['path'],0)+dy
 fits.append(dict(path=target,deltaY=round(dy,6),beforeMinimumGap=min(gaps),beforeMaximumGap=max(gaps),afterMaximumGap=max(gaps)+dy,footSamples=len(gaps)))
 return dy
for row in rows:
 p=row['path']
 if row['mesh'] not in mapping:continue
 if p.startswith('Workspace.Decorations.') or any(p.startswith('Workspace.UnderwaterTerrain.'+f+'.') for f in ('PolishedReefs','ReefLife','CoralGardens')):
  target=p.rsplit('.',1)[0] if row['name']=='Visual' else p
  fit_rows([row],target)
# Whole structures retain their assembled relationships. Chests are seated separately on their floor.
for name in ('TheMarigoldWreck','TidekeeperRuins'):
 prefix='Workspace.UnderwaterTerrain.PointsOfInterest.'+name
 fit_rows([r for r in rows if r['path'].startswith(prefix+'.')],prefix,embed=.14)
supports_v=list(groundverts);supports_f=list(groundfaces)
for row in rows:
 if any('.'+n+'.' in row['path'] for n in ('TheMarigoldWreck','TidekeeperRuins')):
  v,f=worldgeo(row,shift.get(row['path'],0));offset=len(supports_v);supports_v.extend(v.tolist());supports_f.extend(tuple(offset+i for i in t) for t in f)
support=BVHTree.FromPolygons(supports_v,supports_f,all_triangles=True)
for name in ('CaptainsCache','TidekeepersCache'):
 prefix='Workspace.UnderwaterTerrain.PointsOfInterest.'+name
 base=next(r for r in rows if r['path']==prefix+'.Base');dy=fit_rows([base],prefix,support,embed=.035)
 for row in rows:
  if row['path'].startswith(prefix+'.') and row is not base:shift[row['path']]=dy

# Deterministic points replace startup raycasts against the inflated Roblox collision hulls.
rng=random.Random(84129);nodes=[]
for x in range(-240,241,5):
 for z in range(-240,241,5):
  if x*x+z*z>240*240:continue
  px=x+rng.uniform(-.6,.6);pz=z+rng.uniform(-.6,.6);p,n=hit(ground,px,pz)
  if p is not None and n.y>.76 and -.03>p.y>-67.5:
   nodes.append((round(p.x*100),round(p.y*100),round(p.z*100),round(n.x*32767),round(n.z*32767)))
nodes.sort(key=lambda a:a[1],reverse=True)
raw=b''.join(struct.pack('<hhhhh',*p) for p in nodes);encoded=base64.b64encode(raw).decode()
module='''--!strict
-- Offline samples from the visible Blender ground triangles. Rebuild with tools/bake_surface_support.py.
-- Positions have 0.01-stud precision. Normals are normalized signed 16-bit components.
local encoded=[==['''+encoded+''']==]
local alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local values:{[number]:number}={};for i=1,#alphabet do values[string.byte(alphabet,i)]=i-1 end
local data=buffer.create('''+str(len(raw))+''');local offset=0
for i=1,#encoded,4 do
 local a,b,c,d=string.byte(encoded,i,i+3)
 local n=values[a]*262144+values[b]*4096+(values[c] or 0)*64+(values[d] or 0)
 for _,divisor in {65536,256,1} do if offset<buffer.len(data) then buffer.writeu8(data,offset,math.floor(n/divisor)%256);offset+=1 end end
end
local Sites={count='''+str(len(nodes))+''',spacing=5,radius=240}
function Sites.get(index:number):(Vector3,Vector3)
 assert(index>=1 and index<=Sites.count,'Ground site index')
 local i=(index-1)*10;local x=buffer.readi16(data,i)/100;local y=buffer.readi16(data,i+2)/100;local z=buffer.readi16(data,i+4)/100
 local nx=buffer.readi16(data,i+6)/32767;local nz=buffer.readi16(data,i+8)/32767
 return Vector3.new(x,y,z),Vector3.new(nx,math.sqrt(math.max(0,1-nx*nx-nz*nz)),nz)
end
return Sites
'''
assert len(module)<190000
(R/'src/Server/GroundSites.luau').write_text(module,encoding='utf-8')
tree=ET.parse(R/'build/SuckTheSea.rbxlx');parts={}
def walk(e,path=''):
 n=e.findtext('./Properties/string[@name="Name"]') or e.get('class','');path=path+'.'+n if path else n
 cf=e.find('./Properties/CoordinateFrame[@name="CFrame"]')
 if cf is not None:parts[path]=[float(c.text) for c in cf]
 for c in e.findall('Item'):walk(c,path)
for e in tree.getroot().findall('Item'):walk(e)
drops=[];starter=[]
for name,count in [('CaptainsCache',4),('TidekeepersCache',5)]:
 prefix='Workspace.UnderwaterTerrain.PointsOfInterest.'+name;root=np.array(parts[prefix+'.ChestRoot'][:3]);root[1]+=next(r['deltaY'] for r in fits if r['path']==prefix)
 for i in range(count):
  a=i*math.tau/count;x=root[0]+math.cos(a)*3.4;z=root[2]+math.sin(a)*3.4;p,n=hit(support,x,z,root[1]+8)
  assert p is not None
  drops.append(dict(chest=name,index=i+1,position=list(p),normal=list(n)))
for path,cf in parts.items():
 if path.startswith('Workspace.StarterIsland.StarterMusselSites.'):
  p,n=hit(ground,cf[0],cf[2]);starter.append(dict(path=path,position=list(p),normal=list(n)))
report=dict(fits=fits,drops=drops,starter=starter,lootNodes=len(nodes),sourceLength=len(module),maxCorrection=max(abs(f['deltaY']) for f in fits))
(O/'support-fit.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print('SUPPORT_FIT',len(fits),'nodes',len(nodes),'largest',report['maxCorrection'],'moved > .1',sum(abs(f['deltaY'])>.1 for f in fits),flush=True)
for f in sorted(fits,key=lambda a:-abs(a['deltaY']))[:12]:print(f['path'],round(f['deltaY'],3),flush=True)
