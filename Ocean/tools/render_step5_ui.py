"""Original rendered 9-slice UI: carved tropical wood, sand inlay and raised buttons."""
from pathlib import Path
import bpy,math,json
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/step5/ui';OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
S=bpy.context.scene;S.render.engine='CYCLES';S.cycles.samples=48;S.cycles.use_denoising=True
try:
 pref=bpy.context.preferences.addons['cycles'].preferences;pref.compute_device_type='OPTIX';pref.get_devices()
 for d in pref.devices:d.use=d.type=='OPTIX'
 S.cycles.device='GPU'
except Exception:pass
S.render.resolution_x=512;S.render.resolution_y=512;S.render.resolution_percentage=100
S.render.film_transparent=True;S.render.image_settings.file_format='PNG';S.render.image_settings.color_mode='RGBA'
S.view_settings.view_transform='Standard';S.view_settings.exposure=.35;S.world.color=(.65,.65,.65)
def mat(name,color,grain=False):
 m=bpy.data.materials.new(name);m.use_nodes=True;b=m.node_tree.nodes.get('Principled BSDF');b.inputs['Base Color'].default_value=(*color,1);b.inputs['Roughness'].default_value=.65
 if grain:
  n=m.node_tree.nodes;ln=m.node_tree.links;tex=n.new('ShaderNodeTexCoord');mapping=n.new('ShaderNodeVectorMath');mapping.operation='MULTIPLY';mapping.inputs[1].default_value=(2,20,1);ln.new(tex.outputs['Generated'],mapping.inputs[0]);noise=n.new('ShaderNodeTexNoise');noise.inputs['Scale'].default_value=3;noise.inputs['Detail'].default_value=2;ln.new(mapping.outputs[0],noise.inputs['Vector'])
  ramp=n.new('ShaderNodeValToRGB');ramp.color_ramp.elements[0].position=.18;ramp.color_ramp.elements[0].color=(*[c*.68 for c in color],1);ramp.color_ramp.elements[1].position=.85;ramp.color_ramp.elements[1].color=(*[min(1,c*1.28) for c in color],1);ln.new(noise.outputs['Fac'],ramp.inputs[0]);ln.new(ramp.outputs[0],b.inputs['Base Color'])
  bump=n.new('ShaderNodeBump');bump.inputs['Strength'].default_value=.18;bump.inputs['Distance'].default_value=.018;ln.new(noise.outputs['Fac'],bump.inputs['Height']);ln.new(bump.outputs[0],b.inputs['Normal'])
 return m
wood=mat('Warm honey wood',(.39,.185,.077),True);dark=mat('Carved recess',(.15,.069,.028));edge=mat('Wood inner lip',(.60,.34,.14));rope=mat('Natural cotton rope',(.71,.58,.35));sand=mat('Sunlit cream sand',(.90,.79,.57));ripple=mat('Shore ripple inlay',(.74,.61,.37));ivory=mat('Ivory shell carving',(.95,.87,.67));white=mat('Tintable porcelain button',(.91,.94,.93));shadow=mat('Button deep bevel',(.40,.47,.47));gold=mat('Brass pin',(.83,.58,.20))
groups={};active=[]
def box(name,pos,size,material,bevel=.1):
 bpy.ops.mesh.primitive_cube_add(size=1,location=pos);o=bpy.context.object;o.name=name;o.dimensions=size;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);o.data.materials.append(material)
 mod=o.modifiers.new('Soft manufactured bevel','BEVEL');mod.width=bevel;mod.segments=5;bpy.context.view_layer.objects.active=o;bpy.ops.object.modifier_apply(modifier=mod.name)
 for f in o.data.polygons:f.use_smooth=True
 n=o.modifiers.new('Stable highlights','WEIGHTED_NORMAL');bpy.ops.object.modifier_apply(modifier=n.name);active.append(o);return o
def line(name,points,width,material):
 c=bpy.data.curves.new(name,'CURVE');c.dimensions='3D';c.bevel_depth=width;c.bevel_resolution=3;p=c.splines.new('POLY');p.points.add(len(points)-1)
 for a,b in zip(p.points,points):a.co=(*b,1)
 o=bpy.data.objects.new(name,c);S.collection.objects.link(o);o.data.materials.append(material);active.append(o);return o
def start():active.clear()
def finish(name):groups[name]=list(active)
start()
for y in [-2.72,2.72]:
 box('Long driftwood rail',(0,y,0),(5.92,.46,.25),wood,.12)
 box('Inset edge highlight',(0,y-math.copysign(.17,y),.075),(5.55,.055,.08),edge,.025)
 for k in range(3):line('Sculpted flowing wood fibre',[(-2.5+i*.125,y+(k-1)*.087+math.sin(i*.31+k)*.022,.137)for i in range(41)],.009,dark)
for x in [-2.72,2.72]:
 o=box('Upright driftwood rail',(x,0,-.03),(.46,5.92,.25),wood,.12)
 box('Inset vertical lip',(x-math.copysign(.17,x),0,.05),(.055,5.55,.08),edge,.025)
for x in [-2.73,2.73]:
 for y in [-2.73,2.73]:
  for k in [-1,0,1]:line('Corner rope lashing',[(x-.17,y+k*.065,.10),(x-.09,y+k*.065,.19),(x+.10,y+k*.065,.19),(x+.18,y+k*.065,.09)],.019,rope)
finish('WoodFrame')
start();box('Sand inlay',(0,0,-.06),(5.9,5.9,.18),sand,.20)
# Discrete shell and tidal-line engravings stay in the preserved 9-slice corners.
for side in [-1,1]:
 cx=side*2.37;cy=-2.37
 for j in range(7):
  a=math.pi*.18+j*math.pi*.64/6
  line('Scallop fan engraving',[(cx,cy-.12,.044),(cx+math.cos(a)*.16,cy+.02+math.sin(a)*.14,.044),(cx+math.cos(a)*.25,cy+.02+math.sin(a)*.29,.044)],.009,ripple)
 for k in range(3):
  line('Carved tidal line',[(side*(1.93+i*.03),2.31+k*.105+math.sin(i*.24+k*.4)*.025,.044)for i in range(24)],.009,ripple)
finish('SandPanel')
start();box('Rounded button deep side',(0,-.045,-.07),(5.9,5.9,.25),shadow,.28);box('Raised porcelain face',(0,.025,.065),(5.8,5.71,.20),white,.25);finish('ButtonFace')
# One camera and soft lighting, fixed framing yields 512px assets with 60px corner regions.
camera=bpy.data.cameras.new('UI orthographic');cam=bpy.data.objects.new('UI orthographic',camera);S.collection.objects.link(cam);cam.location=(0,0,12);camera.type='ORTHO';camera.ortho_scale=6.4;S.camera=cam
for name,pos,energy,size in [('Key',(-3,4,7),900,6),('Fill',(3,-2,6),250,5)]:
 d=bpy.data.lights.new(name,'AREA');o=bpy.data.objects.new(name,d);S.collection.objects.link(o);o.location=pos;o.rotation_euler=(Vector((0,0,0))-o.location).to_track_quat('-Z','Y').to_euler();d.energy=energy;d.shape='DISK';d.size=size
for name,obs in groups.items():
 for items in groups.values():
  for o in items:o.hide_render=o not in obs
 S.render.filepath=str(OUT/(name+'.png'));bpy.ops.render.render(write_still=True)
for items in groups.values():
 for o in items:o.hide_render=False
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'SuckTheSea_UISkin.blend'))
(OUT/'manifest.json').write_text(json.dumps({'sliceCenter':[64,64,448,448],'woodSliceCenter':[72,72,440,440],'resolution':512,'assets':list(groups),'author':'Original geometry and materials authored for Suck The Sea!'},indent=2))
print('UI_SKIN_RENDERED',flush=True)
