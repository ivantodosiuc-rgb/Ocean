import bpy,sys,json
from pathlib import Path
from mathutils import Vector
R=Path(__file__).resolve().parents[1];O=R/'build/screenshots';S=bpy.context.scene
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts');import review_shots
obs=[o for o in S.objects if o.type=='MESH']
for ob in obs:review_shots.run(objects=[ob.name],out=str(O/('sparkle-qa/'+ob.name+'.png')),views=['front','back','three_quarter'],mode='wire',res=140)
world=bpy.data.worlds.new('Lagoon studio');world.use_nodes=True;world.node_tree.nodes.get('Background').inputs[0].default_value=(.5,.64,.7,1);world.node_tree.nodes.get('Background').inputs[1].default_value=.8;S.world=world
for name,pos,energy,size in [('Key',(-6,-8,12),2000,8),('Rim',(5,3,9),1600,7)]:
 ld=bpy.data.lights.new(name,'AREA');ld.energy=energy;ld.size=size;l=bpy.data.objects.new(name,ld);S.collection.objects.link(l);l.location=pos;l.rotation_euler=(Vector((0,0,2))-l.location).to_track_quat('-Z','Y').to_euler()
cd=bpy.data.cameras.new('Review');cam=bpy.data.objects.new('Review',cd);S.collection.objects.link(cam);S.camera=cam;cd.type='ORTHO'
S.render.engine='CYCLES';S.cycles.samples=16;S.cycles.use_denoising=True;S.view_settings.view_transform='AgX';S.render.resolution_x=1440;S.render.resolution_y=900;S.render.resolution_percentage=100
def render(prefix,spacing,file,back=False):
 group=[o for o in obs if o.name.startswith(prefix)]
 for o in obs:o.hide_render=o not in group
 for i,o in enumerate(group):o.location=((i%6-2.5)*spacing,0,(1-i//6)*3.6 if len(group)>6 else 0)
 center=Vector((0 if len(group)>5 else -(6-len(group))*spacing/2,0,3 if len(group)>6 else 1))
 cam.location=center+Vector((2,18 if back else -18,8));cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler();cd.ortho_scale=spacing*min(6,len(group))+2;S.render.filepath=str(O/file);bpy.ops.render.render(write_still=True)
 for o in group:o.location=(0,0,0)
render('Tool__',2.15,'sparkle-tools-blender.png');render('Tool__',2.15,'sparkle-tools-back.png',True)
render('Icon__',2.5,'sparkle-icons-blender.png');render('Rock__',5.8,'sparkle-rocks-blender.png');render('Rock__',5.8,'sparkle-rocks-back.png',True)
print('REVIEW_COMPLETE',flush=True)
