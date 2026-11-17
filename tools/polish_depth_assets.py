import bpy,bmesh,math,json,sys,ast,random
from pathlib import Path
from mathutils import Vector,Matrix,Euler
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/depth';S=bpy.context.scene;ASSETS=[]
source=ast.parse((ROOT/'tools/create_gameplay_assets.py').read_text(encoding='utf-8'))
COLORS=next(ast.literal_eval(n.value) for n in source.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='COLORS' for t in n.targets))
for file in ['create_gameplay_assets.py','create_depth_assets.py']:
 tree=ast.parse((ROOT/'tools'/file).read_text(encoding='utf-8'));defs=[n for n in tree.body if isinstance(n,ast.FunctionDef)]
 exec(compile(ast.Module(body=defs,type_ignores=[]),file,'exec'))
M={}
for key,color in COLORS.items():
 m=bpy.data.materials.get('P_'+key) or bpy.data.materials.new('P_'+key);m.diffuse_color=(*rgb(color),1);M[key]=m
changed=[]
for ob in S.objects:
 if not ob.name.startswith(('Seabed__','Ground__')):continue
 me=ob.data
 if ob.name.startswith('Seabed__'):
  height=lambda x,y:seabed_height(x,-y)
 else:
  profile=[(0,6),(35,6),(54,5.92),(60,5.7),(65,5.15),(68,4.52)] if 'Meadow' in ob.name else [(0,5.55),(38,5.55),(62,4.95),(71,3.75),(79,1.5),(86,-.4),(93,-3.4),(101,-8)]
  def height(x,y):
   a=math.atan2(y,x);r=math.hypot(x,y)/(1+.045*math.sin(3*a+.5)+.025*math.cos(7*a)+.012*math.sin(11*a));return interp(profile,r)
 normals=[Vector((0,0,1)) for _ in me.loops]
 for face in me.polygons:
  top=all(abs(me.vertices[i].co.z-height(me.vertices[i].co.x,me.vertices[i].co.y))<.02 for i in face.vertices)
  for li in face.loop_indices:
   v=me.vertices[me.loops[li].vertex_index].co
   if top:
    eps=.12;dx=(height(v.x+eps,v.y)-height(v.x-eps,v.y))/(eps*2);dy=(height(v.x,v.y+eps)-height(v.x,v.y-eps))/(eps*2);normals[li]=Vector((-dx,-dy,1)).normalized()
   else:normals[li]=face.normal.copy()
 me.normals_split_custom_set(normals);changed.append(ob)
# Remove the rectangular placeholder sail from the editable mast mesh.
mast=bpy.data.objects['Ship__Mast'];group=mast.vertex_groups.get('Torn teal sail')
if group:
 bm=bmesh.new();bm.from_mesh(mast.data);layer=bm.verts.layers.deform.active
 doomed=[v for v in bm.verts if layer and group.index in v[layer]]
 bmesh.ops.delete(bm,geom=doomed,context='VERTS');bm.to_mesh(mast.data);bm.free();changed.append(mast)
before=set(S.objects)
for side in [-1,1]:
 for row in range(5):
  z=1+row*.84;tube('Curved pointed bow',[(side*5.2,-17,z),(side*3.1,-21,z+.2),(side*.42,-24,z+.5)],.46,'wood' if row%2 else 'woodLight',10)
vs=[(-5.2,-17,4.9),(5.2,-17,4.9),(.45,-24,5.35),(-.45,-24,5.35),(-5.2,-17,5.22),(5.2,-17,5.22),(.45,-24,5.67),(-.45,-24,5.67)]
bevel(mesh('Bow deck',vs,[(0,3,2,1),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7),(4,5,6,7)],'woodLight'),.10)
finish_set(before,'Ship__Bow')
before=set(S.objects)
box('Bowsprit support',(0,-14,5.55),(1.5,1.6,1.2),'woodDark',.15)
tube('Bowsprit',[(0,-13.5,5.8),(0,-27.5,8.5)],[.33,.16],'wood',16)
for side in [-1,1]:tube('Bowsprit stays',[(side*6,-12,5.1),(0,-27.5,8.5)],.055,'sand',8)
finish_set(before,'Ship__Bowsprit')
before=set(S.objects);vs=[];fs=[];nx=12;nz=10
for layer in [0,1]:
 for j in range(nz+1):
  t=j/nz
  for i in range(nx+1):
   u=i/nx;x=-6+5.75*u;z=12-t*(4.3+.6*math.sin(u*15)**2);y=-10.16-.6*math.sin(u*math.pi)*math.sin(t*math.pi)+layer*.08;vs.append((x,y,z))
count=(nx+1)*(nz+1)
for layer in [0,1]:
 for j in range(nz):
  for i in range(nx):a=layer*count+j*(nx+1)+i;f=(a,a+1,a+nx+2,a+nx+1);fs.append(f if layer==0 else tuple(reversed(f)))
border=list(range(nx+1))+[j*(nx+1)+nx for j in range(1,nz+1)]+list(reversed(range(nz*(nx+1),nz*(nx+1)+nx)))+[j*(nx+1) for j in reversed(range(1,nz))]
for i,a in enumerate(border):b=border[(i+1)%len(border)];fs.append((a,b,b+count,a+count))
mesh('Billowed torn sail',vs,fs,'deepTeal');finish_set(before,'Ship__Sail')
keys=list(COLORS);atlas=bpy.data.materials['DepthAtlas']
for ob in ASSETS:
 me=ob.data;uv=me.uv_layers.new(name='UVMap')
 for p in me.polygons:
  idx=keys.index(me.materials[p.material_index].name.removeprefix('P_'))
  for j,li in enumerate(p.loop_indices):a=j*math.tau/len(p.loop_indices);uv.data[li].uv=((idx%8+.5)/8+.012*math.cos(a),(idx//8+.5)/8+.012*math.sin(a))
  p.material_index=0
 me.materials.clear();me.materials.append(atlas);bm=bmesh.new();bm.from_mesh(me);bmesh.ops.triangulate(bm,faces=list(bm.faces));bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(me);bm.free();changed.append(ob)
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts');import qa_check
qa=json.loads((OUT/'qa.json').read_text())
for ob in changed:
 qa[ob.name]=qa_check.run(objects=[ob.name],profile='roblox');print('POLISH_QA',ob.name,qa[ob.name]['errors'],flush=True)
(OUT/'qa.json').write_text(json.dumps(qa,indent=2,default=str))
assert all(v['pass'] for v in qa.values()),'Polish QA failed'
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'SuckTheSea_Depth.blend'))
bpy.ops.object.select_all(action='DESELECT')
for ob in changed:ob.select_set(True)
bpy.ops.export_scene.fbx(filepath=str(OUT/'SuckTheSea_DepthPolish.fbx'),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',global_scale=.01,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',mesh_smooth_type='FACE',add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
stats=[]
for ob in S.objects:
 if ob.type=='MESH':ob.data.calc_loop_triangles();stats.append({'name':ob.name,'triangles':len(ob.data.loop_triangles)})
(OUT/'manifest.json').write_text(json.dumps({'objects':stats,'total_triangles':sum(x['triangles'] for x in stats),'resources':50,'polishMeshes':[o.name for o in changed]},indent=2))
print('DEPTH_POLISH_EXPORTED',len(changed))
