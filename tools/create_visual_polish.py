"""STEP 4 original meshes and painted trim textures; never opens or edits the live place."""
import bpy, bmesh, math, random, json, ast, sys
import numpy as np
from pathlib import Path
from mathutils import Vector, Matrix, Euler

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/polish'; OUT.mkdir(parents=True,exist_ok=True)
S=bpy.context.scene
for o in list(bpy.data.objects): bpy.data.objects.remove(o,do_unlink=True)
S.unit_settings.system='NONE'; random.seed(4802)
tree=ast.parse((ROOT/'tools/create_gameplay_assets.py').read_text(encoding='utf-8'))
COLORS=next(ast.literal_eval(n.value) for n in tree.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='COLORS' for t in n.targets))
OLD_KEYS=list(COLORS)
COLORS.update({'mint':'69CDB0','peach':'EFA078','cobalt':'558ED6','leaf':'83C94C','leafDark':'408F64','rope':'DAB991','warmWood':'B68050','bronze':'BDA36D','ochre':'D9B25C','butter':'F5DC8C'})
KEYS=list(COLORS); M={}; ASSETS=[]
exec(compile(ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef)],type_ignores=[]),'prop_helpers','exec'))
for key,col in COLORS.items():
 m=bpy.data.materials.new('P_'+key);m.diffuse_color=(*rgb(col),1);M[key]=m

def image_map(name,array,data=False):
 h,w,_=array.shape;im=bpy.data.images.new(name,width=w,height=h,alpha=True)
 im.colorspace_settings.name='Non-Color' if data else 'sRGB'
 im.pixels.foreach_set(array.astype(np.float32).ravel());im.filepath_raw=str(OUT/(name+'.png'));im.file_format='PNG';im.save();im.pack();return im

# Eight columns of painted swatches; shared by every prop, with eight-pixel gutters.
N=1024;tile=128;albedo=np.ones((N,N,4));rough=np.ones_like(albedo);metal=np.zeros_like(albedo);metal[:,:,3]=1
v,u=np.mgrid[0:tile,0:tile]/(tile-1)
for idx,key in enumerate(KEYS):
 base=np.array(rgb(COLORS[key])); grain=np.zeros_like(u);r=.65;met=0
 if key in ['wood','woodLight','woodDark','warmWood']:
  # Broad, intentionally stylized longitudinal grain and a quiet oval knot.
  phase=v*math.tau*7+.65*np.sin(u*math.tau*1.4)+.25*np.sin(u*math.tau*3.2+v*4)
  knot=np.sqrt(((u-.63)*1.5)**2+((v-.53)*3.1)**2)
  knotline=np.exp(-((knot-.22)/.022)**2)+.55*np.exp(-((knot-.32)/.018)**2)
  grain=.035*np.sin(phase)-.09*np.exp(-(np.sin(phase*.5)/.17)**2)-.075*knotline
  grain+=.023*np.sin(v*math.tau*2+u*2);r=.62
 elif key in ['teal','deepTeal','blue','navy']:
  grain=.022*np.sin(v*38+np.sin(u*9))+.018*np.sin(u*15+v*4);r=.43
 elif key in ['gold','goldLight','goldDark','bronze']:
  grain=.025*np.sin(v*12)+.015*np.sin(u*8);r=.32;met=.85
 elif key=='rope':
  grain=.05*np.sin((u*8+v*3)*math.tau)-.05*np.exp(-(np.sin((u*8-v*3)*math.pi)/.22)**2);r=.82
 elif key in ['green','darkGreen','leaf','leafDark']:
  grain=(v-.5)*.15+.025*np.cos(u*math.tau)+.035*np.exp(-((u-.5)/.035)**2);r=.78
 else:
  pores=np.maximum(0,np.cos(u*math.tau*8)*np.cos(v*math.tau*9))**12
  grain=(v-.5)*.16-pores*.035+.015*np.sin(u*17+v*8);r=.56
 x=(idx%8)*tile;y=(idx//8)*tile
 albedo[y:y+tile,x:x+tile,:3]=np.clip(base[None,None,:]*(1+grain[:,:,None]),0,1)
 rough[y:y+tile,x:x+tile,:3]=np.clip(r+grain[:,:,None]*.28,.15,.95)
 metal[y:y+tile,x:x+tile,:3]=met
color_im=image_map('LagoonPaint_Color',albedo);rough_im=image_map('LagoonPaint_Roughness',rough,True);metal_im=image_map('LagoonPaint_Metalness',metal,True)
atlas=bpy.data.materials.new('LagoonPaint');bs=next(n for n in atlas.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
for im,socket in [(color_im,'Base Color'),(rough_im,'Roughness'),(metal_im,'Metallic')]:
 node=atlas.node_tree.nodes.new('ShaderNodeTexImage');node.image=im;atlas.node_tree.links.new(node.outputs['Color'],bs.inputs[socket])

def paint_object(ob,old_atlas=False,source_keys=None):
 me=ob.data; olduv=me.uv_layers.active
 colors=[]
 for p in me.polygons:
  if old_atlas:
   keys=source_keys or OLD_KEYS
   uv=olduv.data[p.loop_start].uv;idx=min(len(keys)-1,int(uv.x*8)+int(uv.y*8)*8);key=keys[idx]
   if key=='sand' and 'Ship' in ob.name:key='rope'
  else:key=me.materials[p.material_index].name.removeprefix('P_')
  colors.append(key if key in KEYS else 'cream')
 while me.uv_layers:me.uv_layers.remove(me.uv_layers[0])
 uv=me.uv_layers.new(name='UVMap')
 # Per-piece projections preserve long grain on individual planks, not across a whole ship.
 groups={}
 for vert in me.vertices:
  for g in vert.groups:groups.setdefault(g.group,[]).append(vert.co.copy())
 bounds={g:(Vector(tuple(min(p[k] for p in vs) for k in range(3))),Vector(tuple(max(p[k] for p in vs) for k in range(3)))) for g,vs in groups.items()}
 fallback=(Vector(tuple(min(v.co[k] for v in me.vertices) for k in range(3))),Vector(tuple(max(v.co[k] for v in me.vertices) for k in range(3))))
 for p,key in zip(me.polygons,colors):
  counts={}
  for vi in p.vertices:
   for g in me.vertices[vi].groups:counts[g.group]=counts.get(g.group,0)+1
  lo,hi=bounds.get(max(counts,key=counts.get),fallback) if counts else fallback
  axis=max(range(3),key=lambda a:abs(p.normal[a]));axes=[i for i in range(3) if i!=axis]
  if key in ['wood','woodDark','woodLight','warmWood','rope']:axes.sort(key=lambda a:hi[a]-lo[a],reverse=True)
  elif 2 in axes:axes=[a for a in axes if a!=2]+[2]
  idx=KEYS.index(key);origin=Vector(((idx%8)/8,(idx//8)/8))
  coords=[]
  for li in p.loop_indices:
   co=me.vertices[me.loops[li].vertex_index].co
   q=[(co[a]-lo[a])/max(hi[a]-lo[a],.001) for a in axes];coords.append(q)
   uv.data[li].uv=origin+Vector((.008+q[0]*.109,.008+q[1]*.109))
  area=sum(coords[i][0]*coords[(i+1)%len(coords)][1]-coords[(i+1)%len(coords)][0]*coords[i][1] for i in range(len(coords)))
  if abs(area)<1e-8:
   for j,li in enumerate(p.loop_indices):a=j*math.tau/len(p.loop_indices);uv.data[li].uv=origin+Vector((.0625+.003*math.cos(a),.0625+.003*math.sin(a)))
  p.material_index=0
 me.materials.clear();me.materials.append(atlas)

def collect(before,name,ground=True):
 obs=[o for o in S.objects if o not in before and o.type=='MESH']
 for o in obs:paint_object(o)
 bpy.ops.object.select_all(action='DESELECT')
 for o in obs:o.select_set(True)
 bpy.context.view_layer.objects.active=obs[0];bpy.ops.object.join();ob=bpy.context.object;ob.name=name
 if name in ['Reef__VioletSeaFan','Reef__SunbeamAntlers','Reef__SunsetStaghorn']:
  # Weld branching intersections into one organic surface instead of coincident caps.
  ob.data.remesh_voxel_size=.038 if 'Fan' in name else .055
  bpy.ops.object.voxel_remesh()
  smooth=ob.modifiers.new('Soft living surface','SMOOTH');smooth.factor=.7;smooth.iterations=3;bpy.ops.object.modifier_apply(modifier=smooth.name)
  dec=ob.modifiers.new('Reef silhouette budget','DECIMATE');dec.ratio=min(1,3800/max(1,len(ob.data.polygons)*2));bpy.ops.object.modifier_apply(modifier=dec.name)
  ob.data.materials.clear();ob.data.materials.append(M['purple' if 'Fan' in name else 'coral' if 'Sunset' in name else 'ochre'])
  for p in ob.data.polygons:p.material_index=0;p.use_smooth=True
  paint_object(ob)
 S.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR')
 if ground:
  low=min(v.co.z for v in ob.data.vertices)
  for v in ob.data.vertices:v.co.z-=low
 bm=bmesh.new();bm.from_mesh(ob.data);bmesh.ops.triangulate(bm,faces=list(bm.faces));bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(ob.data);bm.free()
 ASSETS.append(ob);return ob

def branch(points,r,color,tip=None):
 tube('Living branch',points,r,color,10)
 rr=r[-1] if isinstance(r,list) else r
 ell('Rounded growing tip',points[-1],(rr*1.01,rr*1.01,rr*1.3),tip or color,10,6)

def plate(pos,r,color,phase=0):
 vs=[];fs=[];n=32;steps=5
 for layer in range(2):
  for j in range(steps):
   t=j/(steps-1);rad=.09+r*t
   for i in range(n):
    a=i*math.tau/n;rr=rad*(1+.05*math.sin(a*7+phase)*t)
    z=pos[2]+.18*t*t+.11*math.sin(a*5+phase)*t*t-layer*.13
    vs.append((pos[0]+rr*math.cos(a),pos[1]+rr*math.sin(a),z))
 count=n*steps
 for layer in range(2):
  for j in range(steps-1):
   for i in range(n):a=layer*count+j*n+i;b=layer*count+j*n+(i+1)%n;f=(a,b,b+n,a+n);fs.append(f if layer==0 else tuple(reversed(f)))
  cap=tuple(layer*count+i for i in range(n));fs.append(tuple(reversed(cap)) if layer==0 else cap)
 for i in range(n):a=(steps-1)*n+i;b=(steps-1)*n+(i+1)%n;fs.append((a,a+count,b+count,b))
 return mesh('Scalloped coral plate',vs,fs,color)

coral_names=['SunsetStaghorn','VioletSeaFan','TurquoiseTable','GoldenBrain','PeachCups','LavenderFingers','CrimsonLettuce','CobaltTubes','SunbeamAntlers','MintPagoda']
for kind in coral_names:
 before=set(S.objects)
 ell('Reef foot',(0,0,.16),(.7,.55,.22),'sole',14,8)
 if kind in ['SunsetStaghorn','SunbeamAntlers']:
  color='coral' if kind=='SunsetStaghorn' else 'ochre';height=3.5 if kind=='SunsetStaghorn' else 5.2
  for i in range(5):
   a=i*2.4;r=.9;h=height*(.7+.22*math.sin(i+1)**2)
   p0=(math.cos(a)*.18,math.sin(a)*.18,.12+i*.011);p1=(math.cos(a)*r*.6,math.sin(a)*r*.6,h*.48);p2=(math.cos(a)*r,math.sin(a)*r,h)
   branch([p0,p1,p2],[.24,.19,.105],color,'peach' if kind=='SunsetStaghorn' else 'butter')
   for sign in [-1,1]:
    mid=Vector(p1).lerp(Vector(p2),.25);end=mid+Vector((math.cos(a+sign)*.75,math.sin(a+sign)*.75,h*.25))
    branch([mid,mid.lerp(end,.6),end],[.15,.12,.075],color)
 elif kind=='VioletSeaFan':
  branch([(0,0,.1),(0,0,1.15)],[.27,.2],'purple')
  for i in range(9):
   a=-1.25+i*.31;end=Vector((math.sin(a)*2.1,.12*math.sin(i),1+math.cos(a)*2.25));mid=Vector((end.x*.5,0,1.3+(end.z-1.3)*.5))
   branch([(.08*math.sin(a),.035*math.cos(i),.56+i*.009),mid,end],[.17,.105,.065],'purple','lilac')
   for s in [-1,1]:branch([mid,mid.lerp(end,.5)+Vector((s*.22,.02,.12)),end+Vector((s*.32,.02,.05))],[.07,.06,.04],'lilac')
 elif kind in ['TurquoiseTable','MintPagoda']:
  color='teal' if kind=='TurquoiseTable' else 'mint'
  if kind=='MintPagoda':branch([(0,0,.1),(.08,0,2.4)],[.32,.22],color)
  for j in range(3):
   if kind=='TurquoiseTable':
    x,y=[(-.9,0),(.65,-.55),(.4,.6)][j];h=.8+j*.65
    branch([(0,0,.15),(x*.6,y*.6,h*.65),(x,y,h)],[.22,.18,.14],color)
    plate((x,y,h),1.1+(j%2)*.18,color,j)
   else:plate(((-.2 if j%2 else .2),0,.65+j*.85),1.9-j*.48,color,j)
 elif kind=='GoldenBrain':
  ell('Round brain coral',(0,0,1.0),(1.45,1.2,.95),'ochre',24,14)
  for row in range(7):
   yy=(row-3)*.29;pts=[]
   for i in range(25):
    x=-1.15+i*2.3/24;y=yy+.075*math.sin(i*.75+row);z=1+.96*math.sqrt(max(.02,1-(x/1.47)**2-(y/1.23)**2))
    pts.append((x,y,z))
   tube('Brain maze ridge',pts,.075,'butter',8)
 elif kind=='PeachCups':
  for i,(x,y,h) in enumerate([(-.6,0,1.3),(.55,.1,1.8),(0,-.55,.9)]):
   o=lathe('Thick coral chalice',[(0,.18),(.4,.24),(h*.8,.48),(h,.7),(h+.08,.69),(h+.08,.56),(h*.8,.36),(.45,.12)],'peach',24)
   for p in o.data.vertices:p.co+=Vector((x,y,.1))
 elif kind=='LavenderFingers':
  for i in range(7):
   a=i*2.4;r=.7 if i else 0;h=1.3+(i%3)*.4;x=r*math.cos(a);y=r*math.sin(a)
   branch([(0,0,.1),(x*.8,y*.8,h*.4),(x,y,h)],[.32,.33,.24],'purple','lilac')
 elif kind=='CrimsonLettuce':
  branch([(0,0,.1),(0,0,1.6)],[.38,.22],'red')
  for i in range(4):
   a=i*2.4;plate((math.cos(a)*.35,math.sin(a)*.35,.32+i*.38),1.2-i*.13,'red' if i%2==0 else 'coral',i*2)
 elif kind=='CobaltTubes':
  for i in range(5):
   a=i*2.4;x=.68*math.cos(a);y=.68*math.sin(a);h=1.6+(i%3)*.45
   tube('Open blue sponge',[(x*.5,y*.5,.12),(x,y,h*.65),(x*1.12,y*1.12,h)],[.28,.35,.4],'cobalt',14,True)
   ring('Pale sponge lip',(x*1.12,y*1.12,h),.33,.075,'ice',segments=20)
 collect(before,'Reef__'+kind)

def blade(name,angle,length,width,color,lean=.8):
 vs=[];fs=[];sections=7
 for layer in range(2):
  for j in range(sections):
   t=j/(sections-1);w=max(.012,width*math.sin(math.pi*(.12+.88*t)));center=Vector((math.cos(angle)*lean*t*t,math.sin(angle)*lean*t*t,length*t))
   side=Vector((-math.sin(angle),math.cos(angle),0));normal=Vector((math.cos(angle),math.sin(angle),-.3)).normalized()
   for sign in [-1,1]:vs.append(tuple(center+side*w*sign+normal*(.035 if layer else -.035)))
 n=sections*2
 for layer in range(2):
  for j in range(sections-1):a=layer*n+j*2;f=(a,a+1,a+3,a+2);fs.append(f if layer else tuple(reversed(f)))
 border=[0,1]+list(range(3,n,2))+list(reversed(range(2,n,2)))
 for i,a in enumerate(border):b=border[(i+1)%len(border)];fs.append((a,b,b+n,a+n))
 return mesh(name,vs,fs,color)
for ident in ['DuneGrass','BroadleafGrass','CoastalShrub']:
 before=set(S.objects)
 if ident=='CoastalShrub':
  for i,(x,y,z,s) in enumerate([(0,0,.7,1),(-.65,.1,.45,.65),(.55,-.3,.5,.7),(.2,.5,.6,.7)]):ell('Wax leaf cushion',(x,y,z),(s,.7*s,.75*s),'leaf' if i%2 else 'leafDark',16,10)
 else:
  for i in range(7 if ident=='DuneGrass' else 6):blade('Curved leaf',i*2.4,.7+(i%3)*.27,.08 if ident=='DuneGrass' else .19,'leaf' if i%2 else 'green',.5+(i%2)*.45)
 collect(before,'Coast__'+ident)
before=set(S.objects)
branch([(-1.6,0,.25),(-.6,.05,.2),(.4,0,.28),(1.5,.3,.42)],[.3,.35,.24,.13],'woodLight')
branch([(.1,0,.26),(.35,.5,.48),(.85,.9,.6)],[.18,.14,.06],'woodLight');collect(before,'Coast__Driftwood')

# Preserve the established wreck layout and treasure space; improve its actual materials.
with bpy.data.libraries.load(str(ROOT/'assets/depth/SuckTheSea_Depth.blend'),link=False) as (src,dst):
 dst.objects=[n for n in src.objects if n.startswith(('Ship__','Chest__'))]
for ob in dst.objects:
 S.collection.objects.link(ob);paint_object(ob,True);ASSETS.append(ob)

# New continuous gunwales, brass fastenings, braided stay and anchor, away from the entry.
before=set(S.objects)
for side in [-1,1]:
 pts=[]
 for i in range(37):
  y=-18+i;w=4.2+4.5*math.cos(y/20*math.pi/2);pts.append((side*w,y,5.0))
 tube('Painted gunwale',pts,.20,'deepTeal',10)
 tube('Warm gunwale inlay',[(x,y,z+.20) for x,y,z in pts[1:-1]],.065,'goldDark',8)
 for y in [-15,-9,9,15]:
  w=4.2+4.5*math.cos(y/20*math.pi/2);ell('Bronze hull bolt',(side*(w+.44),y,3.6),(.07,.14,.14),'bronze',10,6)
# The rope crosses only solid foredeck, never the chest aisle.
for strand in range(2):
 pts=[]
 for i in range(101):
  t=i/100;a=t*math.tau*9+strand*math.pi;pts.append((-5.8*(1-t)+.045*math.cos(a),-12,5.3+8.5*t+.045*math.sin(a)))
 tube('Twisted hemp stay',pts,.042,'rope' if strand else 'cream',6)
for i in range(4):ring('Mast binding',(0,-10,5.4+i*.17),.54,.075,'rope',segments=20)
tube('Anchor shaft',[(7.8,13,1.4),(7.8,13,4.1)],.14,'navy',10)
ring('Anchor shackle',(7.8,13,4.4),.32,.095,'bronze',rot=(math.pi/2,0,0))
tube('Anchor flukes',[(6.65,13,2.1),(6.9,13,1.55),(7.8,13,1.2),(8.65,13,1.55),(8.9,13,2.1)],.16,'navy',10)
tube('Anchor stock',[(7.0,13,3.5),(8.6,13,3.5)],.12,'bronze',10)
collect(before,'Ship__MaritimeDetails',False)

# A real open clinker-built skiff: curved hull, gunwale, ribs, seats, oars, rope and pennant.
before=set(S.objects)
NSECT=25;NCROSS=13;vs=[];fs=[]
for layer in range(2):
 for j in range(NSECT):
  t=j/(NSECT-1);y=-4.6+9.2*t;width=.12+2.15*math.sin(math.pi*t)**.65
  for i in range(NCROSS):
   a=-math.pi/2+i*math.pi/(NCROSS-1);x=width*math.sin(a);z=.15+1.55*(1-math.cos(a))+.55*abs(t-.5)*2
   vs.append((x*(1-.06*layer),y,z+.16*layer))
ct=NSECT*NCROSS
for layer in range(2):
 for j in range(NSECT-1):
  for i in range(NCROSS-1):a=layer*ct+j*NCROSS+i;f=(a,a+1,a+NCROSS+1,a+NCROSS);fs.append(f if layer else tuple(reversed(f)))
border=list(range(NCROSS))+[j*NCROSS+NCROSS-1 for j in range(1,NSECT)]+list(reversed(range((NSECT-1)*NCROSS,(NSECT-1)*NCROSS+NCROSS-1)))+[j*NCROSS for j in reversed(range(1,NSECT-1))]
for i,a in enumerate(border):b=border[(i+1)%len(border)];fs.append((a,b,b+ct,a+ct))
mesh('Curved painted skiff hull',vs,fs,'deepTeal')
for side in [-1,1]:
 for row in range(4):
  pts=[];a=side*(.35+row*.38)
  for j in range(NSECT):
   t=j/(NSECT-1);w=.12+2.15*math.sin(math.pi*t)**.65;pts.append((w*math.sin(a),-4.6+9.2*t,.17+1.55*(1-math.cos(a))+.55*abs(t-.5)*2))
  tube('Clinker plank edge',pts,.048,'woodLight' if row==3 else 'teal',6)
 pts=[(side*(.12+2.15*math.sin(math.pi*j/(NSECT-1))**.65),-4.6+9.2*j/(NSECT-1),1.72+.55*abs(j/(NSECT-1)-.5)*2) for j in range(NSECT)]
 tube('Honey wood gunwale',pts,.15,'woodLight',10)
 for y in [-2.0,1.4]:
  ring('Bronze oarlock',(side*2.1,y,1.95),.15,.045,'bronze',rot=(math.pi/2,0,0),segments=16)
for y,width in [(-2.6,3),(-.6,4),(1.7,3.5)]:box('Rounded seat',(0,y,1.38),(width,.62,.22),'woodLight',.10)
for y in [-4.6,4.6]:tube('Rounded stem cap',[(-.12,y,2.27),(0,y,2.29),(.12,y,2.27)],.15,'woodLight',10)
for y in [-3,-1.5,0,1.5,3]:
 w=.12+2.15*math.sin(math.pi*(y+4.6)/9.2)**.65
 points=[]
 for i in range(15):
  a=-math.pi/2+i*math.pi/14;points.append((w*.94*math.sin(a),y,.35+1.55*(1-math.cos(a))+.55*abs(y/4.6)))
 tube('Inner curved rib',points,.075,'warmWood',8)
for side in [-1,1]:
 tube('Oar shaft',[(side*.8,1.5,1.6),(side*2.7,-2.6,1.8)],.08,'woodDark',10)
 o=ell('Rounded oar blade',(side*2.92,-3.05,1.83),(.25,.75,.085),'woodLight',16,8,rot=(0,0,side*.44))
for j in range(3):ring('Coiled mooring rope',(.2,2.75,.77+j*.1),.45-j*.09,.065,'rope',segments=28)
tube('Mooring line',[(.2,2.75,.78),(.6,3.4,1.0),(.0,4.6,2.16),(.15,5.1,1.6)],.07,'rope',8)
tube('Pennant pole',[(0,-3.3,1),(0,-3.3,4.4)],.075,'woodDark',10)
flag=flat_symbol('Swallowtail pennant',[(0,4.28),(.95,4.2),(.7,3.98),(.95,3.7),(0,3.78)],'coral',.065,(0,-3.3,0),.025)
collect(before,'Boat__LittleBoat')

# Re-UV the existing dock without changing its geometry or world position.
island_tree=ast.parse((ROOT/'tools/create_island.py').read_text(encoding='utf-8'))
island_colors=next(ast.literal_eval(n.value) for n in island_tree.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='COLORS' for t in n.targets))
with bpy.data.libraries.load(str(ROOT/'assets/SuckTheSea_Island.blend'),link=False) as (src,dst):
 dst.objects=[n for n in src.objects if n in ['Ocean__PierBoard','Ocean__PierHead','Ocean__PierPile','Ocean__PierCap','Ocean__PileRope','Ocean__SafetyRope']]
for ob in dst.objects:
 S.collection.objects.link(ob)
 bpy.context.view_layer.update()
 ob.data.transform(ob.matrix_world);ob.matrix_world=Matrix.Identity(4)
 # Each disconnected plank or rope gets its own trim-space projection.
 adjacency=[[] for _ in ob.data.vertices]
 for e in ob.data.edges:a,b=e.vertices;adjacency[a].append(b);adjacency[b].append(a)
 seen=set()
 for v in ob.data.vertices:
  if v.index in seen:continue
  stack=[v.index];component=[];seen.add(v.index)
  while stack:
   i=stack.pop();component.append(i)
   for j in adjacency[i]:
    if j not in seen:seen.add(j);stack.append(j)
  if ob.name=='Ocean__PierBoard' and abs(sum(ob.data.vertices[i].co.y for i in component)/len(component)+118)<.01:
   for i in component:ob.data.vertices[i].co.y=-117.55+(ob.data.vertices[i].co.y+118)*.55
  ob.vertex_groups.new(name='Dock piece').add(component,1,'REPLACE')
 paint_object(ob,True,list(island_colors));ob.name=ob.name.replace('Ocean__','Dock__');ASSETS.append(ob)
before=set(S.objects)
for x in [-4.8,4.8]:box('Pier support stringer',(x,-98,2.85),(.7,62,.65),'woodDark',.08)
for x in [-10,10]:box('Head support stringer',(x,-126,2.85),(.7,17,.65),'woodDark',.08)
for y in [-119.2,-130]:box('Head support crossbeam',(0,y,2.5),(28,.65,.65),'woodDark',.08)
collect(before,'Dock__Understructure',False)

sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts');import qa_check
qa={}
for ob in ASSETS:
 if ob.name=='Ship__MaritimeDetails' or ob.name.startswith('Dock__'):continue
 qa[ob.name]=qa_check.run(objects=[ob.name],profile='roblox');print('POLISH_QA',ob.name,qa[ob.name]['errors'],flush=True)
qa['MaritimeAssembly']=qa_check.run(objects=[ob.name for ob in ASSETS if ob.name.startswith('Ship__')],profile='roblox')
print('POLISH_QA MaritimeAssembly',qa['MaritimeAssembly']['errors'],flush=True)
qa['DockAssembly']=qa_check.run(objects=[ob.name for ob in ASSETS if ob.name.startswith('Dock__')],profile='roblox')
print('POLISH_QA DockAssembly',qa['DockAssembly']['errors'],flush=True)
(OUT/'qa.json').write_text(json.dumps(qa,indent=2,default=str),encoding='utf-8')
stats=[]
for ob in ASSETS:
 ob.data.calc_loop_triangles();stats.append({'name':ob.name,'triangles':len(ob.data.loop_triangles),'dimensions':list(ob.dimensions),'materials':len(ob.data.materials)})
(OUT/'manifest.json').write_text(json.dumps({'objects':stats,'totalTriangles':sum(p['triangles'] for p in stats),'coralVariants':coral_names,'textures':['LagoonPaint_Color.png','LagoonPaint_Roughness.png','LagoonPaint_Metalness.png']},indent=2),encoding='utf-8')
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'SuckTheSea_VisualPolish.blend'))
assert all(q['pass'] for q in qa.values()),'Inspect assets/polish/qa.json before export'
bpy.ops.object.select_all(action='DESELECT')
for ob in ASSETS:ob.select_set(True)
bpy.ops.export_scene.fbx(filepath=str(OUT/'SuckTheSea_VisualPolish.fbx'),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',global_scale=.01,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',mesh_smooth_type='FACE',add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
print('VISUAL_POLISH_EXPORTED',len(ASSETS),sum(p['triangles'] for p in stats),flush=True)
