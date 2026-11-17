"""Original Blender restroom, eleven textured straws and starter mussel."""
from pathlib import Path
import bpy,bmesh,math,json,sys,random
from mathutils import Vector,Matrix,Euler
ROOT=Path(__file__).resolve().parents[1]
source=(ROOT/'tools/create_gameplay_assets.py').read_text(encoding='utf-8')
exec(source[:source.index('# Six tools')])
OUT=ROOT/'assets/comfort';OUT.mkdir(parents=True,exist_ok=True)
# Retain the six established silhouettes, with new textured finishes below.
exec(source[source.index('for kind in ['):source.index('def shell(')])
for kind,color in [('CoralTwister','coral'),('TidalCoil','blue'),('StarSiphon','purple'),('Leviathan','navy'),('PrismStraw','lilac')]:
 before=set(S.objects)
 pts=[(0,0,z) for z in [0,.5,1,1.5,1.95,2.12]]+[(-.05,0,2.3),(-.23,0,2.45),(-.48,0,2.5),(-.72,0,2.5)]
 tube('Hollow enamel tube',pts,.16,color,16,True)
 for z in [.18,1.95]:ring('Polished brass collar',(0,0,z),.17,.04,'goldLight',segments=20)
 if kind=='CoralTwister':
  tube('Coral spiral',[(.24*math.cos(t*.36),.24*math.sin(t*.36),.35+t*.045) for t in range(31)],.065,'pink',10)
  for z,a in [(.6,1),(1.2,3.5),(1.7,5.5)]:
   tube('Soft coral branch',[(0,0,z),(.3*math.cos(a),.3*math.sin(a),z+.1),(.46*math.cos(a),.46*math.sin(a),z+.4)],[.13,.1,.04],'red',10)
 elif kind=='TidalCoil':
  ell('Pearl turbine',(0,0,1.15),(.38,.32,.52),'cream',20,12)
  for z in [.75,1,1.25,1.5]:ring('Tide coil',(0,0,z),.36,.055,'blue',segments=24)
  ell('Ocean lens',(0,-.34,1.15),(.2,.09,.25),'aqua',16,10)
 elif kind=='StarSiphon':
  ell('Star engine',(0,0,1.2),(.3,.26,.5),'purple',16,10)
  for z in [.65,1.65]:ring('Star halo',(0,0,z),.4,.045,'gold',segments=24)
  for z in [.65,1.65]:
   for a in [0,math.tau/3,2*math.tau/3]:tube('Halo support',[(.12*math.cos(a),.12*math.sin(a),z),(.39*math.cos(a),.39*math.sin(a),z)],.035,'gold',8)
  outline=[(math.sin(i*math.pi/5)*(.29 if i%2==0 else .14),1.2+math.cos(i*math.pi/5)*(.29 if i%2==0 else .14)) for i in range(10)]
  flat_symbol('Raised golden star',outline,'goldLight',.1,(0,-.28,0),.025)
 elif kind=='Leviathan':
  ell('Nautilus engine',(0,0,1.15),(.46,.36,.6),'navy',20,12)
  ring('Nautilus brass',(0,-.35,1.15),.32,.065,'gold',rot=(math.pi/2,0,0))
  ell('Pressure eye',(0,-.4,1.15),(.23,.08,.23),'aqua',20,12)
  for side in [-1,1]:flat_symbol('Sweep fin',[(side*.2,.6),(side*.65,.95),(side*.35,1.7)],'teal',.15,radius=.05)
 else:
  for z,col in [(.45,'pink'),(.8,'goldLight'),(1.15,'aqua'),(1.5,'blue'),(1.85,'purple')]:
   ring('Prismatic band',(0,0,z),.18,.055,col,segments=20)
  ell('Prism heart',(0,-.13,1.2),(.23,.16,.31),'ice',8,6)
  for a in [-1,1]:tube('Golden wishbone',[(a*.2,0,.65),(a*.32,0,1.2),(a*.2,0,1.7)],.045,'goldLight',10)
 finish(before,'Tool__'+kind)

def join_unshifted(before,name):
 obs=[o for o in S.objects if o not in before and o.type=='MESH'];bpy.ops.object.select_all(action='DESELECT')
 for o in obs:o.select_set(True)
 bpy.context.view_layer.objects.active=obs[0];bpy.ops.object.join();o=bpy.context.object;o.name=name;S.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR');ASSETS.append(o);return o

before=set(S.objects)
ell('Lower mussel shell',(0,0,.12),(.29,.5,.115),'navy',24,14)
ell('Upper mussel shell',(0,0,.175),(.285,.49,.13),'purple',24,14)
for i in range(5):
 x=(i-2)*.063;ys=[-.34+j*.068 for j in range(11)]
 tube('Shell growth ridge',[(x,y,.175+.132*math.sqrt(max(.02,1-(x/.285)**2-(y/.49)**2))) for y in ys],.006,'blue',6)
finish(before,'Loot__StarterMussel')

before=set(S.objects)
box('Raised foundation',(0,0,.22),(7.6,7.6,.44),'woodDark',.15)
for x in [-3,-2,-1,0,1,2,3]:box('Warm floor board',(x,0,.49),(.96,7.1,.16),'woodLight',.045)
for side in [-1,1]:
 for i in range(8):box('Painted side siding',(side*3.45,0,.95+i*.85),(.23,6.95,.81),'teal' if i%3 else 'deepTeal',.045)
for i in range(8):box('Back siding',(0,3.45,.95+i*.85),(6.9,.23,.81),'teal',.045)
for x in [-3.45,3.45]:
 for y in [-3.45,3.45]:box('Ivory corner post',(x,y,4.1),(.38,.38,7.25),'cream',.07)
for x in [-2.7,2.7]:box('Front panel',(x,-3.45,4.05),(1.12,.25,6.9),'teal',.07)
for x in [-1.96,1.96]:box('Door frame',(x,-3.64,3.7),(.32,.36,6.5),'cream',.07)
box('Door lintel',(0,-3.61,7),(4.2,.34,.37),'cream',.07)
for y in [-3.6,3.6]:box('Roof edge',(0,y,7.7),(7.8,.3,.33),'woodLight',.07)
box('Front step',(0,-4.1,.19),(4.7,1.7,.32),'woodLight',.12)
box('Sign back',(0,-3.75,7.68),(2.9,.28,.8),'navy',.14)
join_unshifted(before,'Restroom__Cabin')
before=set(S.objects)
for side in [-1,1]:
 for i in range(10):
  y=-3.8+i*.84
  o=box('Soft terracotta roof',(side*2.05,y,8.35),(4.65,.89,.22),'coral' if i%3 else 'pink',.07)
  tr=Matrix.Translation((side*2.05,y,8.35))@Matrix.Rotation(side*.24,4,'Y')@Matrix.Translation((-side*2.05,-y,-8.35))
  for v in o.data.vertices:v.co=tr@v.co
tube('Roof ridge',[(0,-4.3,8.9),(0,4.3,8.9)],.2,'red',12)
join_unshifted(before,'Restroom__Roof')
before=set(S.objects)
for x in [-1.42,-.71,0,.71,1.42]:box('Honey oak door',(x,-3.52,3.7),(.68,.22,6.1),'woodLight',.055)
for z in [1.15,6.25]:box('Door brace',(0,-3.68,z),(3.3,.16,.27),'wood',.045)
for z in [1.6,5.7]:box('Brass hinge',(-1.65,-3.66,z),(.42,.13,.25),'gold',.04)
tube('Knob spindle',[(1.3,-3.60,3.6),(1.3,-3.82,3.6)],.075,'gold',12)
ell('Door knob',(1.3,-3.82,3.6),(.14,.13,.14),'gold',16,10)
ring('Moon crescent',(0,-3.69,5.15),.37,.08,'cream',rot=(math.pi/2,0,0),segments=24)
join_unshifted(before,'Restroom__Door')
before=set(S.objects)
box('Toilet pedestal',(0,1.8,1.2),(1.05,1.35,1.25),'white',.23)
ell('Porcelain bowl',(0,1.6,1.78),(.93,1.13,.55),'cream',24,14)
ring('Closed seat',(0,1.5,2.12),.74,.16,'white',segments=32)
box('Cistern',(0,2.65,2.4),(1.8,.65,1.8),'white',.22)
box('Flush lever',(.5,2.29,2.85),(.4,.12,.13),'gold',.045)
join_unshifted(before,'Restroom__Toilet')

# One 1024px atlas. Real grain/stripe/ripple variation, with planar per-face UVs.
import numpy as np
keys=list(COLORS);n=1024;tile=128;y,x=np.mgrid[0:tile,0:tile];u=x/tile;v=y/tile
rgba=np.ones((n,n,4),dtype=np.float32);rough=np.ones((n,n,4),dtype=np.float32);metal=np.zeros((n,n,4),dtype=np.float32);metal[:,:,3]=1
for k,key in enumerate(keys):
 row,col=divmod(k,8);wood='wood' in key
 grain=np.sin(u*90+np.sin(v*8)*2)*.035+np.sin(u*190+v*13)*.018 if wood else np.sin(u*math.tau*3+v*math.tau*2)*.025
 if key in ['coral','pink','blue','purple','lilac']:grain+=np.cos((u+v*.3)*math.tau*5)*.05
 shade=np.clip(1+grain,0,1.12);base=np.array(rgb(COLORS[key]));rgba[row*tile:(row+1)*tile,col*tile:(col+1)*tile,:3]=np.clip(base[None,None,:]*shade[:,:,None],0,1)
 rough[row*tile:(row+1)*tile,col*tile:(col+1)*tile,:3]=(.65 if wood else .3 if 'gold' in key else .43)
 if 'gold' in key:metal[row*tile:(row+1)*tile,col*tile:(col+1)*tile,:3]=.7
atlas=bpy.data.materials.new('ComfortPaint');atlas.use_nodes=True;bs=atlas.node_tree.nodes.get('Principled BSDF')
for name,pixels,socket in [('ComfortColor',rgba,'Base Color'),('ComfortRoughness',rough,'Roughness'),('ComfortMetalness',metal,'Metallic')]:
 im=bpy.data.images.new(name,width=n,height=n,alpha=True);im.pixels.foreach_set(pixels.ravel());im.filepath_raw=str(OUT/(name+'.png'));im.file_format='PNG';im.save();im.pack()
 if socket!='Base Color':im.colorspace_settings.name='Non-Color'
 node=atlas.node_tree.nodes.new('ShaderNodeTexImage');node.image=im;atlas.node_tree.links.new(node.outputs['Color'],bs.inputs[socket])
stats=[]
for ob in ASSETS:
 me=ob.data;uv=me.uv_layers.get('UVMap') or me.uv_layers.new(name='UVMap')
 for face in me.polygons:
  idx=keys.index(me.materials[face.material_index].name.removeprefix('P_'));axis=max(range(3),key=lambda i:abs(face.normal[i]));a,b=[i for i in range(3) if i!=axis]
  for li in face.loop_indices:
   p=me.vertices[me.loops[li].vertex_index].co;uv.data[li].uv=((idx%8+.08+.84*((p[a]*.11+.5)%1))/8,(idx//8+.08+.84*((p[b]*.11+.5)%1))/8)
  face.material_index=0
 me.materials.clear();me.materials.append(atlas);bm=bmesh.new();bm.from_mesh(me);bmesh.ops.dissolve_degenerate(bm,edges=list(bm.edges),dist=.000001);bmesh.ops.triangulate(bm,faces=list(bm.faces));bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(me);bm.free();me.calc_loop_triangles()
 stats.append({'name':ob.name,'triangles':len(me.loop_triangles)})
S.view_settings.view_transform='Standard';bpy.context.view_layer.update()
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'SuckTheSea_Comfort.blend'))
bpy.ops.export_scene.fbx(filepath=str(OUT/'SuckTheSea_Comfort.fbx'),object_types={'MESH'},axis_forward='-Z',axis_up='Y',global_scale=.01,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',mesh_smooth_type='FACE',add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts');import qa_check
qa={o.name:qa_check.run(objects=[o.name],profile='roblox') for o in ASSETS}
(OUT/'qa.json').write_text(json.dumps(qa,indent=2,default=str));(OUT/'manifest.json').write_text(json.dumps({'objects':stats,'total_triangles':sum(a['triangles'] for a in stats)},indent=2))
print('COMFORT_ASSETS',stats,flush=True)
