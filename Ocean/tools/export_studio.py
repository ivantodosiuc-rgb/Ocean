import bpy,sys,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'assets/SuckTheSea_Island.blend'))
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.fbx(filepath=str(ROOT/'assets/SuckTheSea_Studio.fbx'),use_selection=False,object_types={'MESH'},axis_forward='-Z',axis_up='Y',global_scale=.01,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',mesh_smooth_type='FACE',use_mesh_modifiers=True,add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-game-optimization/scripts')
import mesh_stats
report=mesh_stats.run(budget='roblox')
(ROOT/'assets/budget-report.json').write_text(json.dumps(report,default=str,indent=2))
print('STUDIO_FBX_READY',flush=True)
