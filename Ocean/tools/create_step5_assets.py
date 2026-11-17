"""Author the expedition kit and continuous, chunked ocean floor in Blender."""
from pathlib import Path
import bpy,bmesh,math,json,sys,random
import numpy as np
from mathutils import Vector,Matrix,Euler,noise
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from step5_geometry import terrain_height,POIS,SEED
# Reuse only our primitive/model helper definitions in this fresh headless scene.
source=(ROOT/'tools/create_gameplay_assets.py').read_text(encoding='utf-8')
exec(source[:source.index('# Six tools')])
OUT=ROOT/'assets/step5';OUT.mkdir(parents=True,exist_ok=True)
random.seed(SEED)
COLORS.update({'stone':'89A9A5','stoneLight':'B3C6B7','stoneDark':'65878C','limestone':'C6C7AE','coralPink':'F59CBE','coralLavender':'A9A0E1','abyss':'367C93'})
for key in list(COLORS):
 if key in M:continue
 m=bpy.data.materials.new('P_'+key);m.diffuse_color=(*rgb(COLORS[key]),1);m.use_nodes=True
 bs=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED');bs.inputs['Base Color'].default_value=(*rgb(COLORS[key]),1);bs.inputs['Roughness'].default_value=.65;M[key]=m

def rock(name,pos,scale,color='stone',seed=0):
 o=ell(name,(0,0,0),(1,1,1),color,24,14)
 for vert in o.data.vertices:
  q=vert.co.copy();n=noise.noise_vector(q*2+Vector((seed,7,3)))
  p=Vector(tuple(math.copysign(abs(c)**.9,c) for c in q));p+=n*.12
  p.x+=q.z*.09;p.z=max(-.78,p.z)
  vert.co=Vector(pos)+Vector((p.x*scale[0],p.y*scale[1],p.z*scale[2]))
 return o

def arch_body(name,width,height,depth,color='stone',seed=1):
 vs=[];fs=[];steps=32;sides=14
 for i in range(steps+1):
  t=i/steps;a=math.pi*t
  # Broad shoulders and unequal feet give a naturally eroded silhouette.
  x=-width*.5*math.cos(a)+.35*math.sin(a*3+seed)*math.sin(a)
  z=1.4+height*math.sin(a);y=.65*math.sin(a*2+seed)*math.sin(a)
  tangent=Vector((width*.5*math.sin(a),0,height*math.cos(a))).normalized()
  normal=Vector((tangent.z,0,-tangent.x));thick=(width*.095)*(1+.28*math.cos(a*2)+.10*math.sin(a*5+seed))
  for j in range(sides):
   b=math.tau*j/sides;n=1+.065*math.sin(i*.73+j*1.8+seed)
   p=Vector((x,y,z))+normal*(math.cos(b)*thick*n)+Vector((0,math.sin(b)*depth*.5*n,0))
   p.z=max(0,p.z);vs.append(tuple(p))
 for i in range(steps):
  for j in range(sides):a=i*sides+j;b=i*sides+(j+1)%sides;fs.append((a,b,b+sides,a+sides))
 fs += [tuple(reversed(range(sides))),tuple(steps*sides+j for j in range(sides))]
 return mesh(name,vs,fs,color)

def coral(pos,scale=1,color='coralPink',seed=1):
 before=set(S.objects)
 rng=random.Random(seed)
 for i in range(4):
  a=i*2.1+seed;h=scale*(1.5+i*.24);p=Vector(pos)+Vector((0,0,-i*.023*scale))
  tip=p+Vector((math.cos(a)*scale*.9,math.sin(a)*scale*.7,h))
  mid=p+(tip-p)*.52
  tube('Organic coral branch',[p,mid,tip],[scale*.21,scale*.16,scale*.10],color,8)
  for side in [-1,1]:
   start=mid+Vector((0,0,side*.031*scale))
   t=mid+Vector((math.cos(a+side)*scale*.8,math.sin(a+side)*scale*.6,scale*.8))
   tube('Coral twig',[start,t],[scale*.15,scale*.075],color,8)
 # Fuse branch junctions into a continuous organic surface, eliminating internal caps.
 obs=list(set(S.objects)-before);bpy.ops.object.select_all(action='DESELECT')
 for o in obs:o.select_set(True)
 bpy.context.view_layer.objects.active=obs[0];bpy.ops.object.join();o=bpy.context.object
 o.data.remesh_voxel_size=scale*.085;bpy.ops.object.voxel_remesh()
 smooth=o.modifiers.new('Soft organic branch junctions','SMOOTH');smooth.factor=.75;smooth.iterations=3;bpy.ops.object.modifier_apply(modifier=smooth.name)
 dec=o.modifiers.new('Game branch topology','DECIMATE');dec.ratio=.52;bpy.ops.object.modifier_apply(modifier=dec.name)
 for f in o.data.polygons:f.use_smooth=True

for i,(kind,w,h,d,col) in enumerate([('SmallArch',16,11,4.5,'limestone'),('CoralArch',24,16,7,'stone'),('LargeArch',38,25,10,'stoneLight'),('AbyssArch',54,34,13,'abyss')]):
 before=set(S.objects);arch_body('Weather-carved arch',w,h,d,col,i+1)
 if kind=='CoralArch':coral((-w*.44,-d*.42,4),1.2,'coralPink',3);coral((w*.41,-d*.42,4),1,'aqua',5)
 if kind=='AbyssArch':
  coral((-w*.4,-d*.42,8),2,'coralLavender',9);coral((w*.43,-d*.42,7),1.7,'aqua',6)
 finish(before,'Prop__'+kind)

before=set(S.objects)
box('Sunken foundation',(0,0,.6),(26,9,1.2),'stoneDark',.25)
for side in [-1,1]:
 for i in range(4):box('Carved column block',(side*9.5,.15*math.sin(i),2.1+i*2.6),(4.3,5,2.75),'limestone' if i%2 else 'stoneLight',.24)
for i in range(9):
 a=(i+.5)*math.pi/9
 o=box('Eroded arch stone',(-9.5*math.cos(a),i*.026,10.5+7.5*math.sin(a)),(4.0,5.1,3.6),'limestone' if i%3 else 'stone',.3)
 # Rotate around its own centre, preserving the masonry arc.
 center=Vector((-9.5*math.cos(a),0,10.5+7.5*math.sin(a)))
 for v in o.data.vertices:v.co=center+Matrix.Rotation(math.pi/2-a,3,'Y')@(v.co-center)
finish(before,'Prop__RuinedArch')

for kind,scale in [('SeaCave',(13,14,11)),('CrystalCave',(16,17,13))]:
 before=set(S.objects)
 outer=rock('Cave eroded shell',(0,0,scale[2]*.78),scale,'stoneDark' if kind=='CrystalCave' else 'stone',7)
 cutter=ell('Cave opening cutter',(0,-scale[1]*.32,scale[2]*.53),(scale[0]*.65,scale[1]*1.05,scale[2]*.68),'navy',32,20)
 mod=outer.modifiers.new('Walkable hollow interior','BOOLEAN');mod.operation='DIFFERENCE';mod.solver='EXACT';mod.object=cutter
 bpy.context.view_layer.objects.active=outer;bpy.ops.object.modifier_apply(modifier=mod.name);bpy.data.objects.remove(cutter,do_unlink=True)
 if kind=='CrystalCave':coral((-10,-scale[1]*.5,3.2),1.2,'coralLavender',14)
 finish(before,'Prop__'+kind)

before=set(S.objects)
lathe('Fluted stone pillar',[(0,2.8),(.4,2.8),(.8,2.25),(1,1.8),(8.5,1.65),(9,2.1),(9.5,2.55),(10,2.55)],'limestone',24)
for i in range(8):
 a=i*math.tau/8;tube('Raised pillar flute',[(1.73*math.cos(a),1.73*math.sin(a),1.1),(1.6*math.cos(a),1.6*math.sin(a),8.6)],.09,'stoneLight',8)
finish(before,'Prop__AncientColumn')

before=set(S.objects)
for row in range(3):
 for i in range(5-row):box('Broken masonry',((i-2+row*.25)*2.6,.18*math.sin(i+row),.8+row*1.55),(2.7,2.8,1.7),'limestone' if (i+row)%3 else 'stone',.18)
finish(before,'Prop__BrokenWall')

before=set(S.objects)
tube('Anchor shaft',[(0,0,.8),(0,0,8.0)],.4,'stoneDark',12)
tube('Anchor stock',[(-3.5,0,6.2),(3.5,0,6.2)],.38,'woodDark',10)
ring('Anchor eye',(0,0,8.3),.85,.24,'stoneDark',rot=(math.pi/2,0,0),segments=24)
for side in [-1,1]:
 tube('Anchor curved arm',[(0,0,1),(side*2,0,.75),(side*3.6,0,2.1),(side*4.2,0,3.5)],.37,'stoneDark',12)
 flat_symbol('Anchor fluke',[(side*3.6,2.4),(side*5.0,3.0),(side*3.7,4.1)],'stoneDark',.5,radius=.12)
finish(before,'Prop__SunkenAnchor')

before=set(S.objects)
box('Fragment keel',(0,0,.55),(1.2,17,1.1),'woodDark',.16)
for side in [-1,1]:
 for level in range(3):
  for segment in range(5):
   y=-7+segment*3.4;x=side*(3.2+.6*math.cos(y*.18))
   tube('Broken hull plank',[(x,y,.8+level*.9),(x+side*.2,y+2.9,.85+level*.9)],.49,'woodLight' if level%2 else 'wood',8)
 for y in [-6,-1,4,7]:tube('Wreck rib',[(-3.7,y,2.2),(0,y,.65),(3.7,y,2.2)],.28,'woodDark',8)
finish(before,'Prop__WreckFragment')

before=set(S.objects);rock('Broad stone shelf',(0,0,2.7),(11,6.5,3.5),'stoneLight',5);finish(before,'Prop__RockShelf')
before=set(S.objects);coral((0,0,0),2.2,'coralLavender',18);coral((1.5,.4,0),1.5,'aqua',8);finish(before,'Prop__CrystalCoralFormation')

# New treasures complement the existing catalogue; existing IDs remain intact.
before=set(S.objects)
ell('Crab shell',(0,0,.4),(.8,.63,.42),'coral',24,14)
for side in [-1,1]:
 for i in range(3):tube('Carapace spines',[(side*.6,(i-1)*.35,.35),(side*(.95-i*.04),(i-1)*.5,.27)],.075,'coral',8)
for x in [-.28,.28]:ell('Shell eye ridge',(x,-.43,.61),(.12,.11,.13),'goldLight',12,8)
finish(before,'Loot__SmallCrabShell')

shellcode=source[source.index('def shell('):source.index("before=set(S.objects);shell")];exec(shellcode)
before=set(S.objects);o=shell('Rainbow scallop','pink',1.2)
for key in ['aqua','goldLight','lilac']:o.data.materials.append(M[key])
for f in o.data.polygons:
 center=sum((o.data.vertices[i].co for i in f.vertices),Vector())/len(f.vertices)
 f.material_index=int((math.atan2(center.y,center.x)+math.pi)/math.pi*7)%4
finish(before,'Loot__ColorfulShell')

before=set(S.objects)
for i in range(7):
 coin_before=set(S.objects)
 x=(i%3-1)*.45;y=(i//3-1)*.35;z=.12+i*.043
 o=lathe('Golden coin',[(0,.34),(.10,.34),(.14,.30)],'gold',24)
 for v in o.data.vertices:v.co+=Vector((x,y,z))
 ring('Coin rim',(x,y,z+.13),.29,.026,'goldLight',segments=20)
 for coin in set(S.objects)-coin_before:
  center=Vector((x,y,z));rotation=Euler((i*.031,.025*(i+1),i*.37)).to_matrix()
  for v in coin.data.vertices:v.co=center+rotation@(v.co-center)
finish(before,'Loot__GoldenCoinPile')

for kind,scale,col in [('GiantPearl',.92,'cream'),('LegendaryPearl',1.05,'ice')]:
 before=set(S.objects);shell('Pearl cradle','lilac' if kind=='LegendaryPearl' else 'pink',1.45)
 ell('Lustrous pearl',(0,-.65,.59),(scale,scale,scale),col,32,20)
 if kind=='LegendaryPearl':ring('Gilded pearl cradle',(0,-.65,.42),.94,.07,'goldLight',segments=32)
 finish(before,'Loot__'+kind)

before=set(S.objects);rock('Coral stone base',(0,0,.18),(.65,.55,.24),'stoneLight',2);coral((0,0,.12),.6,'ice',6);finish(before,'Loot__CrystalCoral')

before=set(S.objects)
box('Royal chest base',(0,0,.45),(1.9,1.2,.9),'abyss',.12)
lid=ell('Royal arched lid',(0,0,1.0),(.98,.63,.42),'blue',24,12)
for x in [-.72,.72]:box('Golden binding',(x,0,.82),(.15,1.28,1.2),'goldLight',.045)
box('Royal latch',(0,-.66,.76),(.3,.12,.4),'gold',.055)
ell('Latch jewel',(0,-.74,.79),(.12,.045,.14),'purple',12,8)
finish(before,'Loot__RoyalTreasureChest')

# Sculpted shell HUD icon, keeping the existing coin/bag/wave icon family.
before=set(S.objects);o=shell('Shell icon','pink',1.15)
for v in o.data.vertices:v.co=Matrix.Rotation(math.pi/2,3,'X')@v.co
finish(before,'Icon__Shell')

# 60 closed terrain chunks. All shared edges sample the exact same height function.
radial=[84,138,192,246,300,354]
for band in range(5):
 for sector in range(12):
  vs=[];fs=[];nr=10;na=24
  for j in range(nr+1):
   r=radial[band]+(radial[band+1]-radial[band])*j/nr
   for i in range(na+1):
    a=(sector+i/na)*math.tau/12;x=r*math.cos(a);z=r*math.sin(a);vs.append((x,-z,terrain_height(x,z)))
  for j in range(nr):
   for i in range(na):a=j*(na+1)+i;fs.append((a,a+1,a+na+2,a+na+1))
  count=len(vs);vs.extend((x,y,z-2.5) for x,y,z in list(vs));fs.extend(tuple(count+k for k in reversed(f)) for f in list(fs))
  border=list(range(na+1))+[j*(na+1)+na for j in range(1,nr+1)]+list(reversed(range(nr*(na+1),nr*(na+1)+na)))+[j*(na+1) for j in reversed(range(1,nr))]
  for i,a in enumerate(border):b=border[(i+1)%len(border)];fs.append((a,b,b+count,a+count))
  o=mesh('Seabed__B%d_S%02d'%(band+1,sector),vs,fs,'sand');ASSETS.append(o)

# Shared hand-authored procedural surfaces: stone strata, wood fibres and coral pores.
keys=list(COLORS);n=1024;tile=n//8;y,x=np.mgrid[0:tile,0:tile];u=x/tile;v=y/tile
color=np.ones((n,n,4),np.float32);rough=np.ones_like(color);metal=np.zeros_like(color);metal[:,:,3]=1;normal=np.ones_like(color);normal[:,:,:3]=(.5,.5,1)
rng=np.random.default_rng(SEED)
for i,key in enumerate(keys):
 stone=key in ('stone','stoneLight','stoneDark','limestone','abyss');wood='wood' in key;gold='gold' in key
 h=.01*np.sin(u*math.tau*3+np.sin(v*math.tau)*.4)*np.cos(v*math.tau*2)
 if stone:h+=.025*np.sin(v*math.tau*5+np.sin(u*math.tau*2)*.8)+rng.normal(0,.006,(tile,tile))
 if wood:h+=.035*np.sin(u*math.tau*14+np.sin(v*math.tau)*.7)+.01*np.sin(u*math.tau*33)
 if 'coral' in key.lower():h+=.018*np.cos(u*math.tau*17)*np.cos(v*math.tau*13)
 shade=1+h*(2.2 if stone or wood else 1.1)
 region=np.s_[i//8*tile:(i//8+1)*tile,i%8*tile:(i%8+1)*tile]
 color[region][:,:,:3]=np.clip(np.array(rgb(COLORS[key]))[None,None,:]*shade[:,:,None],0,1)
 rough[region][:,:,:3]=np.clip((.78 if stone else .26 if gold else .58)+h[:,:,None],0,1)
 if gold:metal[region][:,:,:3]=.65
 gy,gx=np.gradient(h);nn=np.stack((-gx*2,-gy*2,np.ones_like(h)),2);nn/=np.linalg.norm(nn,axis=2,keepdims=True);normal[region][:,:,:3]=nn*.5+.5
atlas=bpy.data.materials.new('Expedition_Stone_Wood_Coral');atlas.use_nodes=True;bs=next(n for n in atlas.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
for suffix,pixels,socket in [('Color',color,'Base Color'),('Normal',normal,'Normal'),('Roughness',rough,'Roughness'),('Metalness',metal,'Metallic')]:
 im=bpy.data.images.new('Expedition_'+suffix,width=n,height=n,alpha=True);im.colorspace_settings.name='sRGB' if suffix=='Color' else 'Non-Color';im.pixels.foreach_set(pixels.ravel());im.filepath_raw=str(OUT/('Expedition_'+suffix+'.png'));im.file_format='PNG';im.save();im.pack()
 node=atlas.node_tree.nodes.new('ShaderNodeTexImage');node.image=im
 if suffix=='Normal':
  nm=atlas.node_tree.nodes.new('ShaderNodeNormalMap');atlas.node_tree.links.new(node.outputs['Color'],nm.inputs['Color']);atlas.node_tree.links.new(nm.outputs['Normal'],bs.inputs[socket])
 else:atlas.node_tree.links.new(node.outputs['Color'],bs.inputs[socket])

stats=[]
for ob in ASSETS:
 me=ob.data;uv=me.uv_layers.get('UVMap') or me.uv_layers.new(name='UVMap')
 for f in me.polygons:
  idx=keys.index(me.materials[f.material_index].name.removeprefix('P_'));axis=max(range(3),key=lambda a:abs(f.normal[a]));a,b=[j for j in range(3) if j!=axis]
  for li in f.loop_indices:
   p=me.vertices[me.loops[li].vertex_index].co;uu=(p[a]*.071+.31)%1;vv=(p[b]*.071+.27)%1
   uv.data[li].uv=((idx%8+.055+.89*uu)/8,(idx//8+.055+.89*vv)/8)
  f.material_index=0
 me.materials.clear();me.materials.append(atlas)
 bm=bmesh.new();bm.from_mesh(me);bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.000001);bmesh.ops.dissolve_degenerate(bm,edges=list(bm.edges),dist=.000001);bmesh.ops.triangulate(bm,faces=list(bm.faces));bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(me);bm.free();me.calc_loop_triangles()
 if ob.name.startswith('Seabed__'):
  normals=[None]*len(me.loops)
  for f in me.polygons:
   top=all(abs(me.vertices[i].co.z-terrain_height(me.vertices[i].co.x,-me.vertices[i].co.y))<.05 for i in f.vertices);f.use_smooth=top
   for li in f.loop_indices:
    v=me.vertices[me.loops[li].vertex_index].co
    if top:
     dx=(terrain_height(v.x+.05,-v.y)-terrain_height(v.x-.05,-v.y))/.1;dz=(terrain_height(v.x,-v.y+.05)-terrain_height(v.x,-v.y-.05))/.1
     normals[li]=Vector((-dx,dz,1)).normalized()
    else:normals[li]=f.normal
  me.normals_split_custom_set(normals)
 stats.append({'name':ob.name,'triangles':len(me.loop_triangles),'bounds':[[min(v.co[a] for v in me.vertices)for a in range(3)],[max(v.co[a]for v in me.vertices)for a in range(3)]]})
S.view_settings.view_transform='AgX';bpy.context.view_layer.update();bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'SuckTheSea_Expedition.blend'))
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts');import qa_check
qa={o.name:qa_check.run(objects=[o.name],profile='roblox')for o in ASSETS}
(OUT/'qa.json').write_text(json.dumps(qa,indent=2,default=str));(OUT/'manifest.json').write_text(json.dumps({'objects':stats,'triangles':sum(x['triangles']for x in stats),'pois':POIS,'seed':SEED},indent=2))
errors={k:v['errors']for k,v in qa.items()if v['errors']};print('STEP5_QA_ERRORS',errors,flush=True)
if errors:raise RuntimeError('Fix asset QA before export')
bpy.ops.export_scene.fbx(filepath=str(OUT/'SuckTheSea_Expedition.fbx'),object_types={'MESH'},axis_forward='-Z',axis_up='Y',global_scale=.01,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',mesh_smooth_type='FACE',add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
bpy.ops.object.select_all(action='DESELECT')
for o in ASSETS:o.select_set(o.name.startswith('Seabed__'))
bpy.ops.export_scene.fbx(filepath=str(OUT/'SuckTheSea_Seabed.fbx'),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',global_scale=.01,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',mesh_smooth_type='FACE',add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
print('STEP5_ASSETS_DONE',len(stats),sum(x['triangles']for x in stats),flush=True)
