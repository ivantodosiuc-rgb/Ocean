import bpy,sys,math,json
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1];S=bpy.context.scene
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts');import review_shots
obs=[o for o in S.objects if o.type=='MESH']
for ob in obs:
 review_shots.run(objects=[ob.name],out=str(ROOT/('build/screenshots/polish-qa/'+ob.name+'.png')),views=['front','back','three_quarter'],mode='wire',res=180)
world=bpy.data.worlds.new('Lagoon daylight');world.use_nodes=True;bg=next(n for n in world.node_tree.nodes if n.type=='BACKGROUND');bg.inputs[0].default_value=(.46,.63,.68,1);bg.inputs[1].default_value=.65;S.world=world
ld=bpy.data.lights.new('Large softbox','AREA');ld.energy=2100;ld.size=15;l=bpy.data.objects.new('Large softbox',ld);S.collection.objects.link(l);l.location=(-7,-7,19)
cd=bpy.data.cameras.new('Polish review');cam=bpy.data.objects.new('Polish review',cd);S.collection.objects.link(cam);S.camera=cam;cd.type='ORTHO'
S.render.engine='CYCLES';S.cycles.samples=20;S.cycles.use_denoising=True;S.view_settings.view_transform='AgX';S.render.resolution_x=1700;S.render.resolution_y=1000;S.render.resolution_percentage=100
def render(names,filename,pos,look,scale):
 for o in obs:o.hide_render=o.name not in names
 cam.location=pos;cam.rotation_euler=(Vector(look)-cam.location).to_track_quat('-Z','Y').to_euler();cd.ortho_scale=scale;S.render.filepath=str(ROOT/('build/screenshots/'+filename));bpy.ops.render.render(write_still=True)
corals=sorted([o for o in obs if o.name.startswith('Reef__')],key=lambda o:o.name)
for i,o in enumerate(corals):o.location=((i%5-2)*5.6,(i//5-.5)*6,0)
render([o.name for o in corals],'polish-coral-collection.png',(6,-19,23),(0,0,1),31)
for o in corals:o.location=(0,0,0)
render(['Boat__LittleBoat'],'polish-boat-blender.png',(10,-12,10),(0,0,1),12)
l.location=(-12,-15,40);ld.energy=11000;ld.size=30
render([o.name for o in obs if o.name.startswith('Ship__')],'polish-wreck-blender.png',(39,-50,39),(0,-2,5),57)
print('POLISH_VISUAL_QA_RENDERED',len(obs),flush=True)
