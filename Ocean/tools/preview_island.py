import bpy,math
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1]
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'assets/SuckTheSea_Island.blend'))
scene=bpy.context.scene
# Fix slots on instances explicitly, then re-export the identical geometry.
pal=bpy.data.materials['SuckTheSea_ColorAtlas']
for ob in scene.objects:
 if ob.type=='MESH':
  for slot in ob.material_slots:slot.link='DATA';slot.material=pal
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'assets/SuckTheSea_Island.blend'))
bpy.ops.export_scene.fbx(filepath=str(ROOT/'assets/SuckTheSea_Island.fbx'),object_types={'MESH'},axis_forward='-Z',axis_up='Y',global_scale=1,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',mesh_smooth_type='FACE',add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
# Preview-only water and lights. Not part of the exported FBX.
bpy.ops.mesh.primitive_plane_add(size=2200,location=(0,0,0))
water=bpy.context.object
mat=bpy.data.materials.new('PreviewOcean');mat.diffuse_color=(.045,.52,.63,1);mat.use_nodes=True
p=mat.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(.025,.44,.55,1);p.inputs['Roughness'].default_value=.23;water.data.materials.append(mat)
world=bpy.data.worlds.new('Day') if not scene.world else scene.world;scene.world=world;world.use_nodes=True;world.node_tree.nodes['Background'].inputs[0].default_value=(.5,.73,1,1);world.node_tree.nodes['Background'].inputs[1].default_value=.7
bpy.ops.object.light_add(type='SUN',location=(0,0,100));sun=bpy.context.object;sun.rotation_euler=(.45,-.4,-.5);sun.data.energy=2.3;sun.data.angle=.13
bpy.ops.object.camera_add(location=(168,-225,190));cam=bpy.context.object;cam.rotation_euler=(Vector((0,-10,0))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=270;scene.camera=cam
scene.render.engine='CYCLES';scene.cycles.samples=24;scene.cycles.use_denoising=True
scene.render.resolution_x=1600;scene.render.resolution_y=1200;scene.render.resolution_percentage=100
scene.view_settings.view_transform='AgX';scene.render.image_settings.file_format='PNG';scene.render.filepath=str(ROOT/'build/screenshots/blender-overview.png')
bpy.ops.render.render(write_still=True)
