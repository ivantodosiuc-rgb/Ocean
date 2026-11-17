import bpy,json,math,sys
from pathlib import Path
from mathutils import Vector
R=Path(__file__).resolve().parents[1];O=R/'build/screenshots';S=bpy.context.scene
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts');import review_shots
# A scene-wide wire thickness creates long miter spikes on tiny triangles. Keep the
# review overlay thin and disable even-offset miters; this never changes exported meshes.
wire_source=Path(review_shots.__file__).read_text(encoding='utf-8').replace('wire_t = _bounds(obs)[1] * 0.006','wire_t = 0.012').replace('w.modifiers.new("QA_Wire", "WIREFRAME").thickness = wire_t','mod = w.modifiers.new("QA_Wire", "WIREFRAME"); mod.thickness = wire_t; mod.use_even_offset = False')
exec(compile(wire_source,review_shots.__file__,'exec'),review_shots.__dict__)
obs=[o for o in S.objects if o.type=='MESH'];saved={o:o.matrix_world.copy() for o in obs}
world=bpy.data.worlds.new('Surface review sky');world.node_tree.nodes.get('Background').inputs[0].default_value=(.6,.68,.75,1);world.node_tree.nodes.get('Background').inputs[1].default_value=.8;S.world=world
ld=bpy.data.lights.new('Review sun','SUN');ld.energy=2;ld.angle=.3;l=bpy.data.objects.new('Review sun',ld);S.collection.objects.link(l);l.rotation_euler=(.5,-.5,-.5)
cd=bpy.data.cameras.new('Surface camera');cam=bpy.data.objects.new('Surface camera',cd);S.collection.objects.link(cam);S.camera=cam;cd.type='ORTHO'
S.render.engine='CYCLES';S.cycles.samples=12;S.cycles.use_denoising=True;S.view_settings.view_transform='AgX';S.render.resolution_percentage=100
groups={
 'village':[o for o in obs if '__Buildings__' in o.name and o.name.endswith('Shop')]+[o for o in obs if '__Restroom__' in o.name],
 'reef':[o for o in obs if '__Reef__' in o.name or '__Coast__' in o.name],
 'treasures':[o for o in obs if '__Loot__' in o.name],
 'tools':[o for o in obs if '__Tool__' in o.name],
 'ship':[o for o in obs if '__Ship__' in o.name],
 'island_props':[o for o in obs if o.name.startswith('island__') and '__Buildings__' not in o.name],
}
for label,objects in groups.items():
 for ob in obs:ob.matrix_world=saved[ob].copy();ob.hide_render=ob not in objects
 if label not in ('village','ship'):
  cols=8 if len(objects)>20 else 5
  for i,ob in enumerate(objects):
   pts=[ob.matrix_world@Vector(c) for c in ob.bound_box];lo=Vector(tuple(min(p[k] for p in pts) for k in range(3)));hi=Vector(tuple(max(p[k] for p in pts) for k in range(3)));center=(lo+hi)/2;scale=3.3/max(hi-lo)
   ob.scale*=scale;ob.location=Vector(((i%cols)*4,(i//cols)*4,0))-center*scale
 bpy.context.view_layer.update()
 pts=[o.matrix_world@Vector(c) for o in objects for c in o.bound_box];lo=Vector(tuple(min(p[k] for p in pts) for k in range(3)));hi=Vector(tuple(max(p[k] for p in pts) for k in range(3)));center=(lo+hi)/2;extent=max(hi-lo)
 S.render.resolution_x=1400;S.render.resolution_y=1100
 for side,direction in [('front',Vector((.25,-1,1.55))),('back',Vector((-.3,1,1.4)))]:
  cam.location=center+direction*extent;cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler();cd.ortho_scale=extent*1.28;S.render.engine='CYCLES';S.render.filepath=str(O/('surfaces-'+label+'-'+side+'.png'));bpy.ops.render.render(write_still=True)
 review_shots.run(objects=[o.name for o in objects],out=str(O/('surfaces-'+label+'-wire.png')),views=['front','back','three_quarter'],mode='wire',res=500)
 print('REVIEWED',label,len(objects),flush=True)
