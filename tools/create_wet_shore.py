"""One deformable, feathered wet-sand ribbon, authored in Blender and driven locally in Studio."""
import bpy,bmesh,math,json,sys
import numpy as np
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/polish';S=bpy.context.scene
for o in list(bpy.data.objects):bpy.data.objects.remove(o,do_unlink=True)
S.unit_settings.system='NONE'
def interp(points,r):
 for (x,a),(y,b) in zip(points,points[1:]):
  if r<=y:return a+(b-a)*max(0,(r-x)/(y-x))
 return points[-1][1]
def ground(r,a):
 aa=-a;shape=1+.045*math.sin(3*aa+.5)+.025*math.cos(7*aa)+.012*math.sin(11*aa)
 return interp([(0,5.55),(38,5.55),(62,4.95),(71,3.75),(79,1.5),(86,-.4),(93,-3.4),(101,-8)],r/shape)
def contour(a,h):
 lo,hi=70,110
 for _ in range(24):
  r=(lo+hi)*.5
  if ground(r,a)>h:lo=r
  else:hi=r
 return (lo+hi)*.5
n=120;steps=6;vs=[];faces=[];coords=[];anchors={}
for i in range(n):
 a=i*math.tau/n
 for edge,h in [('Inner',1.1),('Outer',.10)]:
  r=contour(a,h);anchors[f'{edge}_{i:02d}']=(r*math.cos(a),-r*math.sin(a),h+.065)
for layer in range(2):
 for i in range(n):
  inner=np.array(anchors[f'Inner_{i:02d}']);outer=np.array(anchors[f'Outer_{i:02d}'])
  for j in range(steps):
   t=j/(steps-1);p=inner*(1-t)+outer*t;p[2]-=layer*.025;vs.append(tuple(p));coords.append((i/n,t))
ct=n*steps
for layer in range(2):
 for i in range(n):
  for j in range(steps-1):
   a=layer*ct+i*steps+j;b=layer*ct+((i+1)%n)*steps+j;f=(a,b,b+1,a+1);faces.append(f if layer==0 else tuple(reversed(f)))
for i in range(n):
 for j in [0,steps-1]:
  a=i*steps+j;b=((i+1)%n)*steps+j;faces.append((a,a+ct,b+ct,b))
me=bpy.data.meshes.new('Wet shoreline ribbon');me.from_pydata(vs,[],faces);me.update();ob=bpy.data.objects.new('WetShore',me);S.collection.objects.link(ob)
uv=me.uv_layers.new(name='UVMap')
for p in me.polygons:
 p.use_smooth=True
 for li in p.loop_indices:
  vi=me.loops[li].vertex_index;u,v=coords[vi];uv.data[li].uv=(.02+u*.96,.02+v*.96)
 # End faces are under the surface, with transparent outside texels.
 if abs(p.normal.z)<.2:
  for j,li in enumerate(p.loop_indices):uv.data[li].uv=(.02+j*.002,.001+j%2*.001)
bm=bmesh.new();bm.from_mesh(me);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bmesh.ops.triangulate(bm,faces=list(bm.faces));bm.to_mesh(me);bm.free()
arm=bpy.data.armatures.new('ShoreRig');rig=bpy.data.objects.new('ShoreRig',arm);S.collection.objects.link(rig);bpy.context.view_layer.objects.active=rig;rig.select_set(True);bpy.ops.object.mode_set(mode='EDIT')
root=arm.edit_bones.new('Root');root.head=(0,0,0);root.tail=(0,0,1)
for name,p in anchors.items():
 b=arm.edit_bones.new(name);b.head=p;b.tail=(p[0],p[1],p[2]+.4);b.parent=root;b.use_connect=False
bpy.ops.object.mode_set(mode='OBJECT')
for name in anchors:ob.vertex_groups.new(name=name)
for layer in range(2):
 for i in range(n):
  for j in range(steps):
   vi=layer*ct+i*steps+j;t=j/(steps-1)
   if t<1:ob.vertex_groups[f'Inner_{i:02d}'].add([vi],1-t,'REPLACE')
   if t>0:ob.vertex_groups[f'Outer_{i:02d}'].add([vi],t,'REPLACE')
mod=ob.modifiers.new('Shoreline deformation','ARMATURE');mod.object=rig;ob.parent=rig
mat=bpy.data.materials.new('WetSandFeather');bs=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED');mat.surface_render_method='BLENDED'
v,u=np.mgrid[0:256,0:64];t=np.clip((v/255-.02)/.96,0,1)
fade=np.sin(t*math.pi)**.8*.44;fade*=1+.06*np.sin(u*.47+v*.04)
for name,isdata in [('WetSand_Color',False),('WetSand_Roughness',True)]:
 pixels=np.ones((256,64,4),dtype=np.float32)
 if not isdata:
  pixels[:,:,:3]=np.array([.58,.49,.34]);pixels[:,:,3]=fade
 else:pixels[:,:,:3]=(.24+.10*t)[:,:,None]
 im=bpy.data.images.new(name,width=64,height=256,alpha=True);im.colorspace_settings.name='Non-Color' if isdata else 'sRGB';im.pixels.foreach_set(pixels.ravel());im.filepath_raw=str(OUT/(name+'.png'));im.file_format='PNG';im.save();im.pack()
 tex=mat.node_tree.nodes.new('ShaderNodeTexImage');tex.image=im;mat.node_tree.links.new(tex.outputs['Color'],bs.inputs['Roughness' if isdata else 'Base Color'])
 if not isdata:mat.node_tree.links.new(tex.outputs['Alpha'],bs.inputs['Alpha'])
me.materials.append(mat)
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts');import qa_check
qa=qa_check.run(objects=['WetShore'],profile='roblox');(OUT/'wet-shore-qa.json').write_text(json.dumps(qa,indent=2,default=str));print('WET_SHORE_QA',qa['errors'],qa['warnings'],flush=True)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'SuckTheSea_WetShore.blend'))
assert qa['pass']
bpy.ops.object.select_all(action='DESELECT');ob.select_set(True);rig.select_set(True);bpy.context.view_layer.objects.active=ob
bpy.ops.export_scene.fbx(filepath=str(OUT/'SuckTheSea_WetShoreV2.fbx'),use_selection=True,object_types={'MESH','ARMATURE'},axis_forward='-Z',axis_up='Y',global_scale=.01,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',mesh_smooth_type='FACE',add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
print('WET_SHORE_EXPORTED',len(me.loop_triangles),len(anchors),'bones plus unweighted Root',flush=True)
