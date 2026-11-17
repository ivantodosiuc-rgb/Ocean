import bpy,sys,math,json
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts')
import review_shots
S=bpy.context.scene
all_mesh=[o for o in S.objects if o.type=='MESH']
loot=sorted([o for o in all_mesh if o.name.startswith('Loot__')],key=lambda o:o.name)
for o in all_mesh:o.hide_render=o not in loot
for i,o in enumerate(loot):o.location=((i%10-4.5)*3.0,(i//10-2)*3.5,0)
world=bpy.data.worlds.new('Depth preview world');world.use_nodes=True;bg=next(n for n in world.node_tree.nodes if n.type=='BACKGROUND');bg.inputs[0].default_value=(.65,.75,.8,1);bg.inputs[1].default_value=.65;S.world=world
ld=bpy.data.lights.new('Softbox','AREA');ld.energy=2500;ld.size=16;l=bpy.data.objects.new('Softbox',ld);S.collection.objects.link(l);l.location=(-6,-5,20)
cd=bpy.data.cameras.new('Resource collection');cam=bpy.data.objects.new('Resource collection',cd);S.collection.objects.link(cam);cam.location=(6,-24,32);cam.rotation_euler=(Vector((0,0,.4))-cam.location).to_track_quat('-Z','Y').to_euler();cd.type='ORTHO';cd.ortho_scale=33;S.camera=cam
S.render.engine='CYCLES';S.cycles.samples=20;S.cycles.use_denoising=True;S.view_settings.view_transform='AgX';S.render.resolution_x=2100;S.render.resolution_y=1400;S.render.resolution_percentage=100;S.render.film_transparent=False
S.render.filepath=str(ROOT/'build/screenshots/depth-50-resources.png');bpy.ops.render.render(write_still=True)
for o in loot:o.location=(0,0,0)
for o in all_mesh:o.hide_render=False
# Required multiview topology sheets for every individually created asset.
for o in all_mesh:
 review_shots.run(objects=[o.name],out=str(ROOT/('build/screenshots/depth-qa/'+o.name+'.png')),views=['front','back','three_quarter'],mode='wire',res=210)
ship=[o.name for o in all_mesh if o.name.startswith('Ship__')]
review_shots.run(objects=ship,out=str(ROOT/'build/screenshots/depth-wreck-shape.png'),views=['front','top','three_quarter'],mode='random',res=600)
print('DEPTH_VISUAL_QA_COMPLETE',len(all_mesh))
