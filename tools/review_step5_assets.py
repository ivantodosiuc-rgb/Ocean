from pathlib import Path
import bpy,math
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/step5'
bpy.ops.wm.open_mainfile(filepath=str(OUT/'SuckTheSea_Expedition.blend'));S=bpy.context.scene
original=list(S.objects);props=[o for o in original if not o.name.startswith('Seabed')]
for o in original:o.hide_render=True
copies=[]
for i,ob in enumerate(props):
 o=ob.copy();o.data=ob.data.copy();S.collection.objects.link(o);o.hide_render=False
 bounds=[Vector(p)for p in o.bound_box];lo=Vector(tuple(min(p[a]for p in bounds)for a in range(3)));hi=Vector(tuple(max(p[a]for p in bounds)for a in range(3)));center=(lo+hi)/2
 factor=8/max(hi-lo)
 for v in o.data.vertices:v.co=(v.co-center)*factor
 o.location=((i%7-3)*12,(i//7-1)*13,4);copies.append(o)
camd=bpy.data.cameras.new('QA');cam=bpy.data.objects.new('QA',camd);S.collection.objects.link(cam);camd.type='ORTHO';camd.ortho_scale=90;S.camera=cam
S.render.engine='CYCLES';S.cycles.samples=24;S.cycles.use_denoising=True
try:
 p=bpy.context.preferences.addons['cycles'].preferences;p.compute_device_type='OPTIX';p.get_devices()
 for d in p.devices:d.use=d.type=='OPTIX'
 S.cycles.device='GPU'
except:pass
S.world.color=(.35,.35,.35);S.render.resolution_x=1800;S.render.resolution_y=1050;S.render.resolution_percentage=100
for name,pos,energy,size in [('Key',(-25,-20,55),18000,45),('Fill',(30,10,45),12000,40)]:
 d=bpy.data.lights.new(name,'AREA');o=bpy.data.objects.new(name,d);S.collection.objects.link(o);o.location=pos;o.rotation_euler=(-o.location).to_track_quat('-Z','Y').to_euler();d.energy=energy;d.size=size
for name,pos in [('front',(10,-62,78)),('rear',(-15,63,68))]:
 cam.location=pos;cam.rotation_euler=(Vector((0,0,3))-cam.location).to_track_quat('-Z','Y').to_euler();S.render.filepath=str(OUT/('review-'+name+'.png'));bpy.ops.render.render(write_still=True)
S.render.engine='BLENDER_WORKBENCH';S.display.shading.light='STUDIO';S.display.shading.color_type='SINGLE';S.display.shading.single_color=(.52,.66,.66);S.display.shading.show_cavity=True;S.display.shading.cavity_type='BOTH'
for o in copies:o.show_wire=True;o.show_all_edges=True
S.render.filepath=str(OUT/'review-wire.png');bpy.ops.render.render(write_still=True)
print('ASSET_REVIEW_DONE')
