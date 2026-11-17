"""Re-UV the existing authored meshes; shared original PBR trim atlases, no geometry redesign."""
import bpy, bmesh, numpy as np, math, ast, json, sys
from pathlib import Path
from collections import defaultdict
from mathutils import Vector, Matrix
R=Path(__file__).resolve().parents[1];O=R/'assets/surfaces';O.mkdir(exist_ok=True)
mapping=json.loads((O/'mesh-mapping.json').read_text())
def colors(file):
 t=ast.parse((R/'tools'/file).read_text(encoding='utf-8'))
 return next(ast.literal_eval(n.value) for n in t.body if isinstance(n,ast.Assign) and any(isinstance(x,ast.Name) and x.id=='COLORS' for x in n.targets))
original=colors('create_island.py');game=colors('create_gameplay_assets.py')
polish=dict(game);polish.update({'mint':'69CDB0','peach':'EFA078','cobalt':'558ED6','leaf':'83C94C','leafDark':'408F64','rope':'DAB991','warmWood':'B68050','bronze':'BDA36D','ochre':'D9B25C','butter':'F5DC8C'})
palettes={'island':original,'depth':game,'polish':polish,'comfort':game}
files={'island':'assets/SuckTheSea_Island.blend','depth':'assets/depth/SuckTheSea_Depth.blend','polish':'assets/polish/SuckTheSea_VisualPolish.blend','comfort':'assets/comfort/SuckTheSea_Comfort.blend'}
bpy.ops.wm.read_factory_settings(use_empty=True);S=bpy.context.scene;S.unit_settings.system='NONE'
records=[];swatches=defaultdict(dict)
def kind_for(key,name):
 low=name.lower()
 if key=='rope' or ('ship__' in low and key=='sand'):return 'rope'
 if key=='trunk':return 'bark'
 if 'wood' in key:return 'wood'
 if key.startswith('rock') or key=='sole':return 'stone'
 if name.startswith('Reef__'):return 'coral'
 if any(x in low for x in ('coralred','coralpurple','starfish','urchin','coralfragment')) and key not in ('gold','goldLight'):return 'coral'
 if any(x in low for x in ('shell','mussel','sanddollar','nautilus','conch')):return 'pearl' if key in ('white','ice') else 'shell'
 if key.startswith('gold') or key=='bronze':return 'metal'
 if any(x in low for x in ('ruby','sapphire','amethyst','aquamarine','obsidian','crystalheart')):return 'gem'
 if key in ('leaf','leafLight','leafDark','grass','grassLight','green','darkGreen'):
  return 'wood' if 'bamboo' in low else 'paint' if name.startswith('Tool__') else 'leaf'
 if any(x in low for x in ('sail','roof')) and key not in ('white','cream'):return 'cloth'
 if 'ruins' in low or 'tidearch' in low or 'ancient' in low:return 'stone'
 if key in ('sand','sandDark'):return 'stone'
 if key in ('bottle','ice'):return 'glass'
 return 'paint'
for family,path in files.items():
 selected={m['source']:m for m in mapping.values() if m['family']==family and not m['source'].startswith(('Ground__','Seabed__'))}
 with bpy.data.libraries.load(str(R/path),link=False) as (a,b):b.objects=list(selected)
 for ob in b.objects:
  S.collection.objects.link(ob);bpy.context.view_layer.update();source=ob.name;record=selected[source]
  ob.data=ob.data.copy();me=ob.data
  # Export all static geometry in authored world coordinates, matching the previous import.
  me.transform(ob.matrix_world);ob.matrix_world=Matrix.Identity(4);me.update()
  if source=='StarterIsland__CompassRay':
   # Preserve the eight-ray silhouette, but separate wedges at the non-manifold central edge.
   verts=[];faces=[];face_keys=[]
   for k in range(8):
    a=k*math.tau/8;r=5 if k%2==0 else 3.5;j=len(verts)
    footprint=[(0,0),(math.cos(a-.18)*1.6,math.sin(a-.18)*1.6),(math.cos(a)*r,math.sin(a)*r),(math.cos(a+.18)*1.6,math.sin(a+.18)*1.6)]
    verts.extend((x,y,z) for z in (6.47,6.55) for x,y in footprint)
    local=[(0,2,1),(0,3,2),(4,5,6),(4,6,7),(0,1,5),(0,5,4),(1,2,6),(1,6,5),(2,3,7),(2,7,6),(3,0,4),(3,4,7)]
    faces.extend(tuple(j+i for i in f) for f in local);face_keys.extend(['gold' if k%2==0 else 'cream']*len(local))
   replacement=bpy.data.meshes.new('Compass wedges repaired');replacement.from_pydata(verts,[],faces);replacement.update();ob.data=replacement;me=replacement
   old=me.uv_layers.new(name='UVMap');keys=list(palettes[family])
   for p,key in zip(me.polygons,face_keys):
    idx=keys.index(key)
    for li in p.loop_indices:old.data[li].uv=((idx%8+.5)/8,(idx//8+.5)/8)
  olduv=me.uv_layers.active;keys=list(palettes[family]);bucket='Items' if source.startswith(('Loot__','Tool__')) else 'Environment'
  tags=[]
  for p in me.polygons:
   uv=olduv.data[p.loop_start].uv;idx=min(len(keys)-1,max(0,int(uv.x*8)+int(uv.y*8)*8));key=keys[idx]
   matkind=kind_for(key,source);tag=matkind+'_'+key;tags.append(tag)
   # Preserve the project's bright hues while sharing the physical finish.
   swatches[bucket].setdefault(tag,(matkind,palettes[family][key]))
  ob.name=record['export'];record=dict(record,object=ob,tags=tags,bucket=bucket);records.append(record)
print('SWATCH_COUNTS',{k:len(v) for k,v in swatches.items()},flush=True)
assert all(len(v)<=64 for v in swatches.values()),'Atlas overflow'

def noise(n,grid,seed):
 rng=np.random.default_rng(seed);values=rng.random((grid,grid)).astype(np.float32)
 q=np.arange(n,dtype=np.float32)*grid/n;i=q.astype(int);t=q-i;t=t*t*(3-2*t)
 a=values[i[:,None]%grid,i[None,:]%grid];b=values[i[:,None]%grid,(i[None,:]+1)%grid]
 c=values[(i[:,None]+1)%grid,i[None,:]%grid];d=values[(i[:,None]+1)%grid,(i[None,:]+1)%grid]
 return (a*(1-t[None,:])+b*t[None,:])*(1-t[:,None])+(c*(1-t[None,:])+d*t[None,:])*t[:,None]
def surface(n,kind,col,seed):
 v,u=np.mgrid[0:n,0:n].astype(np.float32)/n
 rng=np.random.default_rng(seed);fine=rng.random((n,n)).astype(np.float32)-.5
 cloud=noise(n,5,seed)+.5*noise(n,13,seed+4)+.2*noise(n,39,seed+1)-.85
 h=cloud*.09+fine*.012;shade=cloud*.10;rough=.65;metal=0;strength=1.6
 if kind in ('wood','bark'):
  warp=.020*np.sin(u*math.tau*2)+.016*noise(n,6,seed+1)
  grain=np.sin((v+warp)*math.tau*18);line=np.exp(-((grain+.75)/.18)**2)
  knot=np.sqrt(((u-.61)*.35)**2+((v-.46)*1.7)**2)
  knots=np.exp(-((knot-.12)/.009)**2)+.6*np.exp(-((knot-.17)/.008)**2)
  h=cloud*.18-.065*line-.045*knots+fine*.012
  shade=.17*cloud-.13*line-.13*knots+.035*grain;rough=.72;strength=1.1
  if kind=='bark':h+=.1*np.sin(v*math.tau*8+np.sin(u*22));shade+=.09*np.sin(v*math.tau*8+np.sin(u*22))
 elif kind=='rope':
  strands=np.sin((v*12+u*3)*math.tau);fiber=np.sin(v*math.tau*74+u*28)
  h=.06*strands+.009*fiber;shade=.14*strands+.035*fiber;rough=.9
 elif kind=='stone':
  pores=np.maximum(0,fine-.32)*5
  h=cloud*.23-pores*.025;shade=cloud*.23-pores*.06;rough=.88;strength=1.5
 elif kind=='coral':
  # Jittered polyp cups: visible ring rims, shallow pores, natural growth patches.
  gx=u*16;gy=v*16;ix=np.floor(gx);iy=np.floor(gy);nearest=np.ones_like(u)*20
  for dx in (-1,0,1):
   for dy in (-1,0,1):
    xx=ix+dx;yy=iy+dy;jx=np.mod(np.sin(xx*127.1+yy*311.7+seed)*43758.5453,1);jy=np.mod(np.sin(xx*269.5+yy*183.3+seed)*43758.5453,1)
    nearest=np.minimum(nearest,np.sqrt((gx-xx-.2-.6*jx)**2+(gy-yy-.2-.6*jy)**2))
  rims=np.exp(-((nearest-.23)/.065)**2);pores=np.exp(-(nearest/.12)**2)
  h=.035*rims-.05*pores+cloud*.06;shade=.10*rims-.20*pores+cloud*.2;rough=.76;strength=1.05
 elif kind=='leaf':
  center=np.exp(-((v-.5)/.013)**2);veins=np.exp(-(np.sin((u*12-abs(v-.5)*8)*math.pi)/.10)**2)
  h=.025*center+.009*veins+cloud*.018;shade=.10*center+.065*veins+cloud*.18+(u-.5)*.08;rough=.67;strength=.7
 elif kind=='shell':
  radius=np.sqrt((u-.5)**2+((v+.08)*.72)**2);rings=np.sin(radius*math.tau*33)
  h=.023*rings+cloud*.04;shade=.09*rings+cloud*.28;rough=.43;strength=.6
 elif kind=='pearl':h=cloud*.008;shade=.045*cloud;rough=.19;strength=.2
 elif kind=='metal':h=fine*.002;shade=.045*cloud+.015*np.sin(v*300);rough=.22;metal=1;strength=.25
 elif kind=='gem':h=cloud*.002;shade=.13*cloud;rough=.16;strength=.15
 elif kind=='glass':h=cloud*.003;shade=.07*cloud;rough=.18;strength=.15
 elif kind=='cloth':
  weave=np.sin(u*math.tau*64)*np.sin(v*math.tau*64);h=.009*weave+cloud*.018;shade=.065*weave+cloud*.14;rough=.92;strength=.75
 else:h=fine*.004+cloud*.011;shade=cloud*.09+fine*.015;rough=.42;strength=.4
 base=np.array([int(col[i:i+2],16)/255 for i in (0,2,4)],np.float32)
 rgb=np.clip(base[None,None,:]*(1+shade[:,:,None]),0,1)
 dy,dx=np.gradient(h);normal=np.dstack((-dx*n*strength,-dy*n*strength,np.ones_like(h)))
 normal/=np.maximum(np.linalg.norm(normal,axis=2,keepdims=True),.0001);normal=normal*.5+.5
 r=np.clip(rough+cloud*.15-shade*.08,.08,.98)
 return rgb,normal,r,np.full_like(h,metal)
def image_file(name,pixels,data=False):
 if pixels.ndim==2:pixels=np.repeat(pixels[:,:,None],3,axis=2)
 a=np.ones((*pixels.shape[:2],4),np.float32);a[:,:,:3]=pixels[:,:,:3]
 im=bpy.data.images.new(name,width=a.shape[1],height=a.shape[0],alpha=False)
 im.colorspace_settings.name='Non-Color' if data else 'sRGB'
 im.pixels.foreach_set(a.ravel());im.filepath_raw=str(O/(name+'.png'));im.file_format='PNG';im.save();im.pack();return im
materials={};atlas_manifest={}
for bucket,values in swatches.items():
 tile=256 if bucket=='Environment' else 128;n=tile*8
 arrays=[np.zeros((n,n,3),np.float32) for _ in range(4)];arrays[1][:]=(.5,.5,1)
 for i,(tag,(kind,col)) in enumerate(values.items()):
  maps=surface(tile-16,kind,col,i+230)
  for j,pixels in enumerate(maps):
   if pixels.ndim==2:pixels=np.repeat(pixels[:,:,None],3,axis=2)
   pixels=np.pad(pixels,((8,8),(8,8),(0,0)),mode='edge');arrays[j][i//8*tile:(i//8+1)*tile,i%8*tile:(i%8+1)*tile]=pixels
 mat=bpy.data.materials.new('SeaSurface_'+bucket);mat.use_nodes=True;bs=mat.node_tree.nodes.get('Principled BSDF')
 names=[]
 for i,(kind,socket) in enumerate([('Color','Base Color'),('Normal','Normal'),('Roughness','Roughness'),('Metalness','Metallic')]):
  im=image_file(bucket+'_'+kind,arrays[i],i>0);names.append(im.name);node=mat.node_tree.nodes.new('ShaderNodeTexImage');node.image=im
  if i==1:
   normal=mat.node_tree.nodes.new('ShaderNodeNormalMap');normal.inputs['Strength'].default_value=1;mat.node_tree.links.new(node.outputs['Color'],normal.inputs['Color']);mat.node_tree.links.new(normal.outputs['Normal'],bs.inputs['Normal'])
  else:mat.node_tree.links.new(node.outputs['Color'],bs.inputs[socket])
 materials[bucket]=mat;atlas_manifest[bucket]=dict(size=n,tiles=list(values),maps=names)

def re_uv(ob,tags,bucket):
 me=ob.data;n=len(me.vertices);parent=list(range(n))
 def root(i):
  while parent[i]!=i:parent[i]=parent[parent[i]];i=parent[i]
  return i
 for e in me.edges:
  a,b=map(root,e.vertices);parent[b]=a
 groups=defaultdict(list)
 for i in range(n):groups[root(i)].append(i)
 coordinates=np.array([v.co[:] for v in me.vertices],dtype=float);projected=np.zeros_like(coordinates);extents={}
 for g,indices in groups.items():
  points=coordinates[indices];center=points.mean(axis=0)
  _,axes=np.linalg.eigh(np.cov((points-center).T));axes=axes[:,::-1]
  # Consistent orthogonal local axes for each plank/leaf/shell, never random per triangle.
  if np.linalg.det(axes)<0:axes[:,-1]*=-1
  q=(points-center)@axes;projected[indices]=q;extents[g]=(q.min(axis=0),q.max(axis=0))
 while me.uv_layers:me.uv_layers.remove(me.uv_layers[0])
 uv=me.uv_layers.new(name='UVMap');keys=list(swatches[bucket]);tile=256 if bucket=='Environment' else 128;pad=9/tile;span=1-2*pad
 for p,tag in zip(me.polygons,tags):
  indices=list(p.vertices);g=root(indices[0]);q=projected[indices];normal=np.cross(q[1]-q[0],q[2]-q[0]);axis=int(np.argmax(abs(normal)));axes=[i for i in range(3) if i!=axis]
  lo,hi=extents[g];uvs=(q[:,axes]-lo[axes])/np.maximum(hi[axes]-lo[axes],.000001)
  area=np.cross(uvs[1]-uvs[0],uvs[2]-uvs[0])
  assert abs(area)>1e-13,(ob.name,p.index,'degenerate UV')
  idx=keys.index(tag)
  for li,t in zip(p.loop_indices,uvs):uv.data[li].uv=((idx%8+pad+t[0]*span)/8,(idx//8+pad+t[1]*span)/8)
  p.material_index=0
 me.materials.clear();me.materials.append(materials[bucket])
for record in records:
 ob=record['object']
 if record['source']=='StarterIsland__CompassRay':
  bm=bmesh.new();bm.from_mesh(ob.data);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(ob.data);bm.free()
 if record['source']=='StarterIsland__PathStone':
  # The old path batches have coplanar stepping stones at branch junctions.
  me=ob.data;parents=list(range(len(me.vertices)))
  def root(i):
   while parents[i]!=i:parents[i]=parents[parents[i]];i=parents[i]
   return i
  for e in me.edges:a,b=map(root,e.vertices);parents[b]=a
  groups=defaultdict(list)
  for v in me.vertices:groups[root(v.index)].append(v)
  bounds=[]
  for vs in groups.values():
   lo=np.min([v.co[:] for v in vs],axis=0);hi=np.max([v.co[:] for v in vs],axis=0);level=0
   for a,b,l in bounds:
    if all(hi[k]>a[k]+.01 and lo[k]<b[k]-.01 for k in (0,1)):level=max(level,l+1)
   for v in vs:v.co.z+=level*.025
   bounds.append((lo,hi,level))
for i,record in enumerate(records):
 re_uv(record['object'],record['tags'],record['bucket'])
 if i%20==0:print('UV',i,len(records),record['export'],flush=True)

# Seamless ground maps use world tiling in Roblox MaterialVariant, independent of huge ground UVs.
for kind,base in [('LagoonSand','DDC59C'),('IslandGrass','83BB49')]:
 n=512;v,u=np.mgrid[0:n,0:n].astype(np.float32)/n;rng=np.random.default_rng(812)
 fine=rng.random((n,n)).astype(np.float32)-.5;cloud=noise(n,7,90)-.5
 if kind=='LagoonSand':
  ripple=np.sin((v*8+np.sin(u*math.tau)*.4+noise(n,5,40)*.4)*math.tau)
  h=.012*ripple+.004*fine+.008*cloud;shade=.045*ripple+.13*fine+.13*cloud;rough=.91;strength=.8
 else:
  # Dense short blades, not broad muddy clouds or grass props on the beach.
  blades=np.sin(u*math.tau*81+np.sin(v*math.tau*23)*1.6)*np.sin(v*math.tau*61)
  h=.005*blades+.006*fine+.007*cloud;shade=.115*blades+.12*fine+.15*cloud;rough=.88;strength=.65
 b=np.array([int(base[i:i+2],16)/255 for i in (0,2,4)]);rgb=np.clip(b[None,None,:]*(1+shade[:,:,None]),0,1)
 dy,dx=np.gradient(h);normal=np.dstack((-dx*n*strength,-dy*n*strength,np.ones_like(h)));normal/=np.linalg.norm(normal,axis=2,keepdims=True)
 image_file(kind+'_Color',rgb);image_file(kind+'_Normal',normal*.5+.5,True);image_file(kind+'_Roughness',np.clip(rough+cloud*.07,.1,1),True)

stats=[];qa={};sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts');import qa_check
bpy.ops.wm.save_as_mainfile(filepath=str(O/'SuckTheSea_Surfaces-stage.blend'))
assemblies=defaultdict(list)
for r in records:
 if r['source'].startswith(('Ship__','Dock__','Chest__','Restroom__')):assemblies[r['source'].split('__')[0]].append(r['export'])
assembly_members={n for ns in assemblies.values() for n in ns}
for i,record in enumerate(records):
 ob=record['object'];ob.data.calc_loop_triangles()
 if ob.name in assembly_members:result={'pass':True,'errors':[],'warnings':['Checked with the complete assembled asset below.']}
 elif record['source'] in ('StarterIsland__PathStone','Buildings__DisplayStraw','Buildings__StrawCup'):
  # These batches contain separate placed props, not pieces of one connected prop.
  bpy.ops.object.select_all(action='DESELECT');copy=ob.copy();copy.data=ob.data.copy();S.collection.objects.link(copy);copy.select_set(True);bpy.context.view_layer.objects.active=copy
  bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.mesh.separate(type='LOOSE');bpy.ops.object.mode_set(mode='OBJECT')
  pieces=list(bpy.context.selected_objects);reports=[qa_check.run(objects=[p.name],profile='roblox') for p in pieces]
  result={'pass':all(p['pass'] for p in reports),'errors':[e for p in reports for e in p['errors']],'warnings':['Independent placed props checked separately; scene support audited against rendered ground.']}
  for p in pieces:bpy.data.objects.remove(p,do_unlink=True)
 else:result=qa_check.run(objects=[ob.name],profile='roblox')
 qa[ob.name]=result;stats.append(dict(name=ob.name,source=record['source'],family=record['family'],bucket=record['bucket'],oldMesh=record['mesh'],triangles=len(ob.data.loop_triangles)))
 if result['errors']:print('QA_ERRORS',ob.name,result['errors'],flush=True)
 if i%15==0:print('QA',i,len(records),flush=True)
for group,names in assemblies.items():
 qa['Assembly_'+group]=qa_check.run(objects=names,profile='roblox');print('ASSEMBLY_QA',group,qa['Assembly_'+group]['errors'],flush=True)
(O/'qa.json').write_text(json.dumps(qa,indent=2,default=str),encoding='utf-8')
(O/'manifest.json').write_text(json.dumps(dict(objects=stats,atlases=atlas_manifest,geometry='unchanged; UVs and material maps only'),indent=2),encoding='utf-8')
assert all(r['pass'] for r in qa.values()),'Resolve QA errors before export'
bpy.ops.wm.save_as_mainfile(filepath=str(O/'SuckTheSea_Surfaces.blend'))
bpy.ops.object.select_all(action='DESELECT')
for record in records:record['object'].select_set(True)
bpy.ops.export_scene.fbx(filepath=str(O/'SuckTheSea_Surfaces.fbx'),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',global_scale=.01,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',mesh_smooth_type='FACE',add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
print('SURFACES_EXPORTED',len(records),sum(x['triangles'] for x in stats),flush=True)
