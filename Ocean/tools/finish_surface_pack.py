import bpy,json,sys,numpy as np
from pathlib import Path
R=Path(__file__).resolve().parents[1];O=R/'assets/surfaces'
bpy.ops.wm.open_mainfile(filepath=str(O/'SuckTheSea_Surfaces.blend'))
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts');import qa_check
qa=json.loads((O/'qa.json').read_text())
manifest=json.loads((O/'manifest.json').read_text())
for bucket,atlas in manifest['atlases'].items():
 im=bpy.data.images[bucket+'_Normal']
 if im.get('SurfaceNormalTuned'):continue
 n=im.size[0];a=np.empty(n*n*4,np.float32);im.pixels.foreach_get(a);a=a.reshape(n,n,4);tile=n//8
 for i,tag in enumerate(atlas['tiles']):
  kind=tag.split('_')[0];factor=.24 if kind in ('wood','bark','coral') else .55 if kind in ('stone','shell') else 1
  region=a[i//8*tile:(i//8+1)*tile,i%8*tile:(i%8+1)*tile,:3];normal=region*2-1;normal[:,:,:2]*=factor;normal/=np.maximum(np.linalg.norm(normal,axis=2,keepdims=True),.00001);region[:]=normal*.5+.5
 im.pixels.foreach_set(a.ravel());im.save();im.pack();im['SurfaceNormalTuned']=True
for kind in ('LagoonSand','IslandGrass'):
 mat=bpy.data.materials.new(kind);bs=mat.node_tree.nodes.get('Principled BSDF')
 for name,socket in [('Color','Base Color'),('Normal','Normal'),('Roughness','Roughness')]:
  im=bpy.data.images.load(str(O/(kind+'_'+name+'.png')),check_existing=True);im.colorspace_settings.name='sRGB' if name=='Color' else 'Non-Color';im.pack()
  node=mat.node_tree.nodes.new('ShaderNodeTexImage');node.image=im
  if name=='Normal':
   normal=mat.node_tree.nodes.new('ShaderNodeNormalMap');mat.node_tree.links.new(node.outputs['Color'],normal.inputs['Color']);mat.node_tree.links.new(normal.outputs['Normal'],bs.inputs[socket])
  else:mat.node_tree.links.new(node.outputs['Color'],bs.inputs[socket])
 bpy.ops.mesh.primitive_cube_add(size=1,location=(0,0,-100));ob=bpy.context.object;ob.name='SurfaceTile__'+kind;ob.data.materials.append(mat)
 qa[ob.name]=qa_check.run(objects=[ob.name],profile='roblox');assert qa[ob.name]['pass'],qa[ob.name]['errors']
(O/'qa.json').write_text(json.dumps(qa,indent=2,default=str),encoding='utf-8')
bpy.ops.wm.save_as_mainfile(filepath=str(O/'SuckTheSea_Surfaces.blend'))
bpy.ops.object.select_all(action='DESELECT')
for ob in bpy.context.scene.objects:
 if ob.type=='MESH':ob.select_set(True)
bpy.ops.export_scene.fbx(filepath=str(O/'SuckTheSea_Surfaces.fbx'),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',global_scale=.01,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',mesh_smooth_type='FACE',add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
print('FINAL_PACK',len([o for o in bpy.context.scene.objects if o.type=='MESH']),flush=True)
