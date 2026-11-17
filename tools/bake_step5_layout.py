"""Fit original/new set dressing and loot nodes to the actual visible ocean triangles."""
from pathlib import Path
import bpy,math,json,random,struct,base64,sys
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/step5';sys.path.insert(0,str(ROOT/'tools'))
from step5_geometry import POIS,SEED,zone_for
rows=json.loads((OUT/'current-inventory.json').read_text())['meshes'];mapping=json.loads((ROOT/'assets/surfaces/mesh-mapping.json').read_text());geo={}
files={'island':'assets/SuckTheSea_Island.blend','depth':'assets/depth/SuckTheSea_Depth.blend','polish':'assets/polish/SuckTheSea_VisualPolish.blend','comfort':'assets/comfort/SuckTheSea_Comfort.blend','sparkle':'assets/sparkle/SuckTheSea_Sparkle.blend','step5':'assets/step5/SuckTheSea_Expedition.blend'}
for family,path in files.items():
 bpy.ops.wm.open_mainfile(filepath=str(ROOT/path));bpy.context.view_layer.update()
 for o in bpy.context.scene.objects:
  if o.type!='MESH':continue
  o.data.calc_loop_triangles();geo[family+'__'+o.name]=(np.array([(o.matrix_world@v.co)[:]for v in o.data.vertices]),[tuple(t.vertices)for t in o.data.loop_triangles])
gv=[];gf=[]
for key,(v,f) in geo.items():
 if key=='depth__Ground__GoldenShore' or key.startswith('step5__Seabed__'):
  k=len(gv);gv.extend(v[:,[0,2,1]]*np.array([1,1,-1]));gf.extend(tuple(k+i for i in t)for t in f)
ground=BVHTree.FromPolygons(gv,gf,all_triangles=True)
def hit(x,z,bvh=ground,y=30):
 p,n,_,_=bvh.ray_cast(Vector((float(x),float(y),float(z))),Vector((0,-1,0)),250)
 return (np.array(p),np.array(n)) if p else (None,None)
def source(row):
 key=row.get('source')
 if key in geo:return key
 m=mapping.get(row['mesh']);return m['family']+'__'+m['source'] if m else None
def worldgeo(row):
 v,f=geo[source(row)];lo=v.min(0);hi=v.max(0);q=v-(lo+hi)/2;q=q[:,[0,2,1]]*np.array([-1,1,1]);q*=np.array(row['size'])/np.maximum((hi-lo)[[0,2,1]],1e-6);cf=np.array(row['cf']);return q@cf[3:].reshape(3,3).T+cf[:3],f
def contact(v,embed=.07,bvh=ground):
 low=v[:,1].min();band=min(.3,max(.09,np.ptp(v[:,1])*.025));foot=v[v[:,1]<=low+band];gaps=[]
 for p in foot:
  q,n=hit(p[0],p[2],bvh)
  if q is not None:gaps.append(p[1]-q[1])
 if not gaps:raise ValueError('Object has no supporting ground')
 return -max(gaps)-embed,len(gaps)
fits=[];old_world={};structures=[]
for r in rows:
 if not source(r):continue
 v,f=worldgeo(r);old_world[r['path']]=(v,f)
 if '.UnderwaterTerrain.' in r['path'] and any('.'+n+'.' in r['path']for n in ('CoralGardens','PolishedReefs','ReefLife')):
  dy,count=contact(v);fits.append({'path':r['path'],'deltaY':float(dy),'samples':count});v[:,1]+=dy
 # All static obstacles, including those with disabled physics, exclude loot nodes.
 if any(x in r['path']for x in ('.Decorations.','.Buildings.','.UnderwaterTerrain.ReefLife.','.UnderwaterTerrain.PolishedReefs.','.UnderwaterTerrain.CoralGardens.')):structures.append((v,f))
# Move the existing two hero structures and their caches together; retain their assembly/pivots.
moves=[]
for struct_name,chest_name,target,old in [('TheMarigoldWreck','CaptainsCache',(166,136,-78),(122,100,-30.34667778)),('TidekeeperRuins','TidekeepersCache',(-174,192,-114),(-132,146,-51.2965355))]:
 delta=np.array((target[0]-old[0],target[2]-old[2],target[1]-old[1]));prefix='Workspace.UnderwaterTerrain.PointsOfInterest.'
 group=[(r,old_world[r['path']])for r in rows if r['path'].startswith(prefix+struct_name+'.') and r['path']in old_world]
 combined=np.concatenate([v+delta for _,(v,f)in group]);dy,count=contact(combined,.10);delta[1]+=dy
 moves.append({'name':struct_name,'chest':chest_name,'delta':delta.tolist(),'samples':count})
 for r in rows:
  if r['path'].startswith((prefix+struct_name+'.',prefix+chest_name+'.')) and r['path']in old_world:
   v,f=old_world[r['path']];v+=delta
   if r['path'].startswith(prefix+struct_name+'.'):structures.append((v,f))

# Author landmark compositions first, then a repeatable supporting reef rhythm between them.
placements=[];occupied=[];rng=random.Random(SEED)
def prop(asset,x,z,yaw=0,scale=1,poi='',collide=True):
 key='step5__Prop__'+asset;v,f=geo[key];q=v[:,[0,2,1]]*np.array([1,1,-1])*scale;c=math.cos(yaw);s=math.sin(yaw);rot=np.array([[c,0,s],[0,1,0],[-s,0,c]])
 q=q@rot.T+np.array([x,0,z]);dy,samples=contact(q,.10);q[:,1]+=dy
 placements.append(dict(name=f'{poi}_{asset}_{len(placements):03d}',asset=asset,x=x,z=z,y=float(dy),yaw=yaw,scale=scale,poi=poi,zone=zone_for(dy),samples=samples,collide=collide))
 structures.append((q,f));occupied.append((x,z,float(max(np.ptp(q[:,0]),np.ptp(q[:,2]))*.4)))
 return placements[-1]
for p in POIS:
 x,z=p['x'],p['z'];yaw=math.atan2(-x,-z);kind=p['kind'];name=p['id']
 if kind=='small_arch':prop('SmallArch',x,z,yaw,1,name)
 elif kind=='coral_arch':prop('CoralArch',x,z,yaw,1,name)
 elif kind=='large_arch':prop('LargeArch',x,z,yaw,1,name)
 elif kind=='ruined_arch':prop('RuinedArch',x,z,yaw,1,name)
 elif kind=='abyss_arch':prop('AbyssArch',x,z,yaw,1,name)
 elif kind in ('cave','crystal_cave'):prop('CrystalCave'if kind=='crystal_cave'else'SeaCave',x,z,yaw,1,name)
 elif kind=='anchor':prop('SunkenAnchor',x,z,yaw,1.2,name);prop('WreckFragment',x-12,z+7,yaw+.4,.7,name)
 elif kind=='vault':
  prop('RuinedArch',x,z+6,0,1.15,name)
  for side in [-1,1]:prop('AncientColumn',x+side*15,z-5,0,1.25,name);prop('BrokenWall',x+side*11,z+17,.3*side,1.2,name)
 elif kind=='rock_pool':
  for j in range(4):a=j*math.tau/4;prop('RockShelf',x+math.cos(a)*9,z+math.sin(a)*9,a,.55,name)
 elif kind=='shell_cove':prop('SmallArch',x-9,z+5,yaw,.65,name);prop('RockShelf',x+8,z-2,yaw,.6,name)
 elif kind=='existing_wreck':prop('SunkenAnchor',x-24,z-7,yaw,.95,name);prop('WreckFragment',x+20,z+12,yaw+.7,.85,name)
 elif kind=='existing_ruins':prop('AncientColumn',x+20,z-6,yaw,1.3,name);prop('BrokenWall',x-18,z+10,yaw,.9,name)
 if p['zone']>=2:
  for j in range(3 if kind not in ('coral_garden','glowing_reef')else 7):
   a=yaw+.7+j*2.12;r=13+(j%3)*5;prop('CrystalCoralFormation',x+math.cos(a)*r,z+math.sin(a)*r,a,(.55+j%3*.24)*(1.3 if p['zone']==5 else 1),name,False)
  if p['zone']in (3,4):prop('AncientColumn',x+10,z-13,yaw,.6,name)
 # A large visual anchor and two middle-scale stone shelves in each composition.
 for j in range(2):
  a=yaw+1+j*3.1;r=19+(j%2)*7;prop('RockShelf',x+math.cos(a)*r,z+math.sin(a)*r,a,.65+j*.25,name)
# Mid-distance reef islands form paths between the major sites, not an even random grid.
coral_templates=[r for r in rows if '.PolishedReefs.'in r['path'] and r.get('source','').startswith('polish__')]
rock_templates=[r for r in rows if r.get('source','').startswith('sparkle__Rock__')]
reuses=[]
for band,radius in enumerate([134,177,219,260,307]):
 for cluster in range(10):
  angle=(cluster+.25*(band%2))*math.tau/10+.16;r=radius+rng.uniform(-6,6);cx,cz=math.cos(angle)*r,math.sin(angle)*r
  if any(math.hypot(cx-p['x'],cz-p['z'])<32 for p in POIS):continue
  for j in range(6):
   dx,dz=rng.uniform(-9,9),rng.uniform(-9,9);x,z=cx+dx,cz+dz
   if any(math.hypot(x-a,z-b)<rad+2 for a,b,rad in occupied):continue
   template=rng.choice(rock_templates if j==0 else coral_templates);v,f=worldgeo(template);center=np.array(template['cf'][:3]);q=v-center;sc=rng.uniform(.65,1.3)*(1.25 if band>=3 else 1);q*=sc;q+=np.array([x,0,z]);dy,count=contact(q);q[:,1]+=dy
   cf=template['cf'].copy();cf[:3]=[x,float(dy),z]
   reuses.append(dict(name=f'ReefBand{band+1}_{cluster:02d}_{j}',template=template['path'],cf=cf,scale=sc,zone=zone_for(q[:,1].min()),samples=count));structures.append((q,f))

# Authored dense garden beds flank clear walking routes at the main coral landmarks.
for poi in [p for p in POIS if p['id']in ('CoralAtrium','CoralArcade','LanternChasm','CrystalAlcove')]:
 for j in range(18):
  side=-1 if j%2 else 1;row=j//2;angle=math.atan2(poi['z'],poi['x']);tangent=np.array([-math.sin(angle),math.cos(angle)]);out=np.array([math.cos(angle),math.sin(angle)])
  offset=tangent*(side*(12+(row%3)*3.5))+out*((row//3-1)*6+rng.uniform(-1,1));x,z=poi['x']+offset[0],poi['z']+offset[1]
  template=coral_templates[(j*7+poi['zone'])%len(coral_templates)];v,f=worldgeo(template);q=v-np.array(template['cf'][:3]);sc=.95+(j%3)*.27;q*=sc;q+=np.array([x,0,z]);dy,count=contact(q);q[:,1]+=dy
  cf=template['cf'].copy();cf[:3]=[float(x),float(dy),float(z)];reuses.append(dict(name=f'Garden_{poi["id"]}_{j:02d}',template=template['path'],cf=cf,scale=sc,zone=poi['zone'],samples=count));structures.append((q,f))
# Build an obstruction BVH. Rays above the sand reject covered/blocked collectible sites.
sv=[];sf=[]
for v,f in structures:
 k=len(sv);sv.extend(v);sf.extend(tuple(k+i for i in t)for t in f)
obstacles=BVHTree.FromPolygons(sv,sf,all_triangles=True)
def clear(p,margin=1.25):
 for dx,dz in [(0,0),(margin,0),(-margin,0),(0,margin),(0,-margin)]:
  origin=Vector((p[0]+dx,p[1]+.15,p[2]+dz))
  if obstacles.ray_cast(origin,Vector((0,1,0)),5)[0] is not None:return False
  if obstacles.ray_cast(origin+Vector((0,4.5,0)),Vector((0,-1,0)),4.6)[0] is not None:return False
 return True
nodes=[];counts=[0]*5
for x in range(-342,343,6):
 for z in range(-342,343,6):
  if not 96**2<x*x+z*z<342**2:continue
  px=x+rng.uniform(-.7,.7);pz=z+rng.uniform(-.7,.7);p,n=hit(px,pz)
  if p is None or n[1]<.73 or not -167.5<p[1]<-.05 or not clear(p):continue
  nodes.append((round(p[0]*50),round(p[1]*50),round(p[2]*50),round(n[0]*32767),round(n[2]*32767)));counts[zone_for(p[1])-1]+=1
nodes.sort(key=lambda x:(-x[1],x[0],x[2]));raw=b''.join(struct.pack('<hhhhh',*n)for n in nodes)
old=(ROOT/'src/Server/GroundSites.luau').read_text();old=__import__('re').sub(r'local encoded=\[==\[.*?\]==\]','local encoded=[==['+base64.b64encode(raw).decode()+']==]',old,flags=__import__('re').S)
old=__import__('re').sub(r'buffer.create\(\d+\)',f'buffer.create({len(raw)})',old);old=__import__('re').sub(r'count=\d+,spacing=\d+,radius=\d+',f'count={len(nodes)},spacing=6,radius=342',old);old=old.replace('/100','/50').replace('0.01-stud','0.02-stud').replace('tools/bake_surface_support.py','tools/bake_step5_layout.py')
(ROOT/'src/Server/GroundSites.luau').write_text(old,encoding='utf-8')
# Chest rewards get validated clear patches close enough to see/collect on opening.
drops={}
for name,x,z in [('CaptainsCache',166,136),('TidekeepersCache',-174,192),('AbyssalCache',47,293)]:
 sites=[]
 for radius in [5,7,9,11,13]:
  for i in range(20):
   a=i*math.tau/20;p,n=hit(x+math.cos(a)*radius,z+math.sin(a)*radius)
   if p is not None and n[1]>.75 and clear(p,.8) and all(np.linalg.norm(p-np.array(s['position']))>2.7 for s in sites):sites.append({'position':p.tolist(),'normal':n.tolist()})
   if len(sites)>=5:break
  if len(sites)>=5:break
 assert len(sites)>=5,(name,len(sites));drops[name]=sites
# 120 angular samples and .75-stud water increments keep the packed source below 200KB.
contours=[]
for step in range(225):
 level=-step*.75;row=[]
 for i in range(120):
  a=i*math.tau/120
  for h in [level+1.1,level+.1]:
   lo,hi=65,354
   for _ in range(17):
    r=(lo+hi)/2;p,n=hit(math.cos(a)*r,math.sin(a)*r)
    if p is not None and p[1]>h:lo=r
    else:hi=r
   row.append(round((lo+hi)*50))
 contours.append(row)
raw=b''.join(struct.pack('<H',r)for row in contours for r in row);cpath=ROOT/'src/Client/ShoreContours.luau';code=cpath.read_text();code=__import__('re').sub(r'local encoded=\[==\[.*?\]==\]','local encoded=[==['+base64.b64encode(raw).decode()+']==]',code,flags=__import__('re').S);code=__import__('re').sub(r'buffer.create\(\d+\)',f'buffer.create({len(raw)})',code);code=code.replace('step=.25','step=.75').replace('levels=273','levels=225').replace('every .25','every .75');cpath.write_text(code,encoding='utf-8')
layout={'seed':SEED,'pois':[dict(p,y=float(hit(p['x'],p['z'])[0][1]))for p in POIS],'fits':fits,'moves':moves,'placements':placements,'reuses':reuses,'drops':drops,'sites':len(nodes),'zoneSiteCounts':counts,'groundVertices':len(gv),'obstacleTriangles':len(sf)}
(OUT/'layout.json').write_text(json.dumps(layout,indent=2));print('LAYOUT_BAKED',len(placements),len(reuses),len(fits),len(nodes),counts,flush=True)
