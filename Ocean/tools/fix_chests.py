import bpy,bmesh,sys,json
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts')
import qa_check,review_shots
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'assets/SuckTheSea_Island.blend'))
names=[o.name for o in bpy.context.scene.objects if 'TreasureDisplay' in o.name or 'FutureTreasure' in o.name]
report={}
for name in names:
 ob=bpy.data.objects[name];bm=bmesh.new();bm.from_mesh(ob.data);bm.verts.ensure_lookup_table();groups=qa_check._islands(bm)
 for g in set(groups):
  vs=[v for v in bm.verts if groups[v.index]==g];center=sum((v.co for v in vs),Vector())/len(vs)
  if len(vs)==56 and abs(center.x)>.2 and abs(center.y)<.1:
   for v in vs:v.co.z+=.02*(abs(center.x)/1.3)
 bm.to_mesh(ob.data);bm.free()
 report[name]=qa_check.run(objects=[name],profile='roblox');print(name,report[name]['errors'],flush=True)
(ROOT/'assets/chest-qa.json').write_text(json.dumps(report,default=str,indent=2))
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'assets/SuckTheSea_Island.blend'))
def export(path,sel):
 bpy.ops.export_scene.fbx(filepath=str(ROOT/'assets'/path),use_selection=sel,object_types={'MESH'},axis_forward='-Z',axis_up='Y',global_scale=.01,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',mesh_smooth_type='FACE',use_mesh_modifiers=True,add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
export('SuckTheSea_Studio.fbx',False)
bpy.ops.object.select_all(action='DESELECT')
for name in names:bpy.data.objects[name].select_set(True)
export('SuckTheSea_Chests.fbx',True)
review_shots.run(objects=[names[0]],out=str(ROOT/'build/screenshots/qa-chest.png'),views=['front','right','top','three_quarter'],mode='random',res=400)
