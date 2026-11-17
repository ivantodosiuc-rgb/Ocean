import bpy,bmesh,sys,json,math
from mathutils import Matrix
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'assets/SuckTheSea_Island.blend'))
palette=bpy.data.materials['SuckTheSea_ColorAtlas']
for ob in list(bpy.context.scene.objects):
 if ob.type!='MESH':continue
 ob.data=ob.data.copy()
 ob.data.materials.clear();ob.data.materials.append(palette)
 for slot in ob.material_slots:slot.link='DATA';slot.material=palette
 bm=bmesh.new();bm.from_mesh(ob.data)
 bmesh.ops.transform(bm,matrix=Matrix.Diagonal((*ob.scale,1)),verts=list(bm.verts));ob.scale=(1,1,1)
 bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.00001)
 bmesh.ops.dissolve_degenerate(bm,edges=list(bm.edges),dist=.00001)
 bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
 bm.to_mesh(ob.data);bm.free()
 uv=ob.data.uv_layers.active
 for face in ob.data.polygons:
  old=uv.data[face.loop_indices[0]].uv.copy()
  center=((math.floor(old.x*8)+.5)/8,(math.floor(old.y*8)+.5)/8)
  for j,li in enumerate(face.loop_indices):
   a=j*math.tau/len(face.loop_indices)
   uv.data[li].uv=(center[0]+.015*math.cos(a),center[1]+.015*math.sin(a))
 bpy.context.view_layer.objects.active=ob
bpy.ops.object.select_all(action='SELECT')
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-game-optimization/scripts')
import mesh_stats
(ROOT/'assets/budget-report.json').write_text(json.dumps(mesh_stats.run(budget='roblox'),default=str,indent=2))
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts')
import qa_check
qa={}
names=['Buildings__StrawShop','Buildings__UpgradeShop','Buildings__TreasureShop','Decorations__Palm_00','Ocean__LittleBoat','StarterIsland__GoldenShore','StarterIsland__Meadow']
for name in names:
 qa[name]=qa_check.run(objects=[name],profile='roblox')
 print(name,qa[name].get('errors'),flush=True)
(ROOT/'assets/blender-qa.json').write_text(json.dumps(qa,default=str,indent=2))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'assets/SuckTheSea_Island.blend'))
bpy.ops.export_scene.fbx(filepath=str(ROOT/'assets/SuckTheSea_Studio.fbx'),use_selection=False,object_types={'MESH'},axis_forward='-Z',axis_up='Y',global_scale=.01,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',mesh_smooth_type='FACE',use_mesh_modifiers=True,add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
print('CLEAN_FBX_READY',flush=True)
