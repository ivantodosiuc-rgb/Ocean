import bpy,sys,json
from pathlib import Path
from mathutils import Vector
root=Path(__file__).resolve().parents[1]
bpy.ops.wm.open_mainfile(filepath=str(root/'assets/refresh/SuckTheSea_CharactersFlora.blend'))
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts')
import qa_check,review_shots
for name in ['RefreshNPC__Finn','RefreshNPC__Maya','RefreshNPC__CaptainShell','RefreshFlora__Coral']:
 for mode in ['random','wire']:
  review_shots.run(objects=[name],out=str(root/'build/screenshots'/f'qa-{name}-{mode}.png'),views=['front','back','three_quarter'],mode=mode,res=300)
for o in bpy.context.scene.objects:o.hide_render=True
scene=bpy.context.scene
for i,name in enumerate(['RefreshFlora__Coral','RefreshFlora__Cream','RefreshFlora__Lilac']):
 o=bpy.data.objects[name];o.hide_render=False;o.location=(i*4-4,0,0)
bpy.ops.mesh.primitive_plane_add(size=100);floor=bpy.context.object
mat=bpy.data.materials.new('Preview sand');mat.diffuse_color=(.8,.71,.53,1);floor.data.materials.append(mat)
world=bpy.data.worlds.new('Preview');world.use_nodes=True;world.node_tree.nodes['Background'].inputs[0].default_value=(.6,.7,.8,1);world.node_tree.nodes['Background'].inputs[1].default_value=.8;scene.world=world
ld=bpy.data.lights.new('Sun','AREA');ld.energy=1200;ld.size=8;l=bpy.data.objects.new('Sun',ld);scene.collection.objects.link(l);l.location=(-3,-5,10);l.rotation_euler=(Vector((0,0,0))-l.location).to_track_quat('-Z','Y').to_euler()
cd=bpy.data.cameras.new('Review flowers');c=bpy.data.objects.new('Review flowers',cd);scene.collection.objects.link(c);c.location=(4,-16,12);c.rotation_euler=(Vector((0,0,.5))-c.location).to_track_quat('-Z','Y').to_euler();cd.type='ORTHO';cd.ortho_scale=13;scene.camera=c
scene.render.engine='CYCLES';scene.cycles.samples=20;scene.cycles.use_denoising=True;scene.render.resolution_x=1400;scene.render.resolution_y=650;scene.render.resolution_percentage=100;scene.view_settings.view_transform='AgX';scene.render.filepath=str(root/'build/screenshots/refresh-flowers-blender.png');bpy.ops.render.render(write_still=True)
print('REFRESH_REVIEW_DONE',flush=True)
