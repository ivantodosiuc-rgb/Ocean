import bpy,bmesh,sys,json
from pathlib import Path
from mathutils import Vector
from mathutils.bvhtree import BVHTree
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts')
import qa_check as qa
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'assets/SuckTheSea_Island.blend'))
names=['Buildings__StrawShop','Buildings__UpgradeShop','Buildings__TreasureShop','Ocean__LittleBoat']
for name in names:
 ob=bpy.data.objects[name];bm=bmesh.new();bm.from_mesh(ob.data)
 bm.verts.ensure_lookup_table();bm.faces.ensure_lookup_table()
 groups=qa._islands(bm)
 if name=='Ocean__LittleBoat':
  for g in set(groups):
   verts=[v for v in bm.verts if groups[v.index]==g]
   if len(verts)==56:
    c=sum((v.co for v in verts),Vector())/len(verts)
    # Both wooden benches were 0.1 stud short of the hull sides.
    if abs(c.x)<.1 and 1.3<c.z<2:
     for v in verts:v.co.x*=1.18
 else:
  for iteration in range(5):
   bm.normal_update();tris=[tuple(v.index for v in f.verts) for f in bm.faces]
   verts=[v.co.copy() for v in bm.verts];tree=BVHTree.FromPolygons(verts,tris,all_triangles=True)
   pairs=[]
   for i,f in enumerate(bm.faces):
    a,b,c=(verts[k] for k in tris[i]);n=f.normal;cen=(a+b+c)/3
    for p in [cen,cen.lerp(a,.6),cen.lerp(b,.6),cen.lerp(c,.6)]:
     for _,_,j,_ in tree.find_nearest_range(p,.001):
      if j<=i or set(tris[i])&set(tris[j]):continue
      n2=bm.faces[j].normal
      if n.dot(n2)<.999:continue
      aa,bb,cc=(verts[k] for k in tris[j]);q=p-n2*n2.dot(p-aa)
      if qa._point_in_tri(q,aa,bb,cc,n2):pairs.append((j,n2.copy()))
   if not pairs:break
   shifts={}
   for j,n in pairs:shifts.setdefault(groups[tris[j][0]],n*.012)
   for v in bm.verts:
    if groups[v.index] in shifts:v.co+=shifts[groups[v.index]]
  print('COPLANAR_FIX',name,iteration,len(pairs),flush=True)
 bm.to_mesh(ob.data);bm.free()
reports={}
for name in names+['Decorations__Palm_00','StarterIsland__GoldenShore','StarterIsland__Meadow']:
 reports[name]=qa.run(objects=[name],profile='roblox');print(name,reports[name]['errors'],flush=True)
(ROOT/'assets/blender-qa.json').write_text(json.dumps(reports,default=str,indent=2))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'assets/SuckTheSea_Island.blend'))
bpy.ops.export_scene.fbx(filepath=str(ROOT/'assets/SuckTheSea_Studio.fbx'),use_selection=False,object_types={'MESH'},axis_forward='-Z',axis_up='Y',global_scale=.01,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',mesh_smooth_type='FACE',use_mesh_modifiers=True,add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
