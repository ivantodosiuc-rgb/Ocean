"""Original game props, loot and dimensional UI symbols. One atlas, small meshes."""
import bpy,bmesh,math,json,sys,random
from pathlib import Path
from mathutils import Vector,Matrix,Euler
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/gameplay';OUT.mkdir(parents=True,exist_ok=True)
for o in list(bpy.data.objects):bpy.data.objects.remove(o,do_unlink=True)
S=bpy.context.scene;S.unit_settings.system='NONE';random.seed(61)
COLORS={'cream':'FFF4DE','white':'FFFDF3','navy':'183E4C','teal':'31BEAF','deepTeal':'158B89','aqua':'7CE7DC','coral':'FA8B74','pink':'FFB0AD','red':'EA687B','gold':'FFC857','goldLight':'FFE796','goldDark':'D99B37','green':'88C94A','darkGreen':'5A9A3B','wood':'AA6C44','woodLight':'C88D58','woodDark':'704932','blue':'49BDEB','ice':'A4EDFA','purple':'AA84E5','lilac':'D6C0F8','sand':'EDC899','bottle':'58AD98','sole':'526778'}
M={}
def rgb(h):return tuple(int(h[i:i+2],16)/255 for i in (0,2,4))
for key,h in COLORS.items():
 m=bpy.data.materials.new('P_'+key);m.diffuse_color=(*rgb(h),1);m.use_nodes=True
 bs=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED');bs.inputs['Base Color'].default_value=(*rgb(h),1);bs.inputs['Roughness'].default_value=.55;M[key]=m
def mesh(name,vs,fs,color,smooth=True):
 me=bpy.data.meshes.new(name);me.from_pydata(vs,[],fs);me.update();o=bpy.data.objects.new(name,me);S.collection.objects.link(o);me.materials.append(M[color])
 for p in me.polygons:p.use_smooth=smooth
 vg=o.vertex_groups.new(name=name);vg.add(list(range(len(me.vertices))),1,'REPLACE');return o
def ell(name,pos,size,color,seg=16,rings=10,rot=None):
 bm=bmesh.new();bmesh.ops.create_uvsphere(bm,u_segments=seg,v_segments=rings,radius=1)
 tr=Matrix.Translation(Vector(pos))@(Euler(rot).to_matrix().to_4x4() if rot else Matrix.Identity(4))@Matrix.Diagonal((*size,1));bmesh.ops.transform(bm,matrix=tr,verts=list(bm.verts));me=bpy.data.meshes.new(name);bm.to_mesh(me);bm.free()
 o=bpy.data.objects.new(name,me);S.collection.objects.link(o);me.materials.append(M[color]);vg=o.vertex_groups.new(name=name);vg.add(list(range(len(me.vertices))),1,'REPLACE')
 for p in me.polygons:p.use_smooth=True
 return o
def bevel(o,width=.06,segments=3):
 bpy.context.view_layer.objects.active=o;mod=o.modifiers.new('Rounded edges','BEVEL');mod.width=width;mod.segments=segments;mod.limit_method='ANGLE';bpy.ops.object.modifier_apply(modifier=mod.name)
 mod=o.modifiers.new('Clean face normals','WEIGHTED_NORMAL');mod.keep_sharp=True;bpy.ops.object.modifier_apply(modifier=mod.name);return o
def box(name,pos,size,color,width=.06):
 vs=[(pos[0]+x*size[0]/2,pos[1]+y*size[1]/2,pos[2]+z*size[2]/2) for x,y,z in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]]
 return bevel(mesh(name,vs,[(0,3,2,1),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7),(4,5,6,7)],color),width)
def tube(name,points,radii,color,sides=12,hollow=False,stripes=False):
 pts=[Vector(p) for p in points];vs=[];fs=[];previous=None;closed=(pts[0]-pts[-1]).length<1e-7
 if closed:pts=pts[:-1]
 frames=[]
 for i,p in enumerate(pts):
  tangent=(pts[(i+1)%len(pts)]-pts[(i-1)%len(pts)]).normalized() if closed else (pts[min(i+1,len(pts)-1)]-pts[max(i-1,0)]).normalized()
  ref=Vector((0,1,0)) if abs(tangent.z)>.85 else Vector((0,0,1));u=(previous-tangent*previous.dot(tangent)).normalized() if previous is not None else tangent.cross(ref).normalized();v=tangent.cross(u).normalized();previous=u;frames.append((u,v))
 for inner in ([False,True] if hollow else [False]):
  for i,p in enumerate(pts):
   r=radii[i] if isinstance(radii,list) else radii;r*=.64 if inner else 1;u,v=frames[i]
   for j in range(sides):vs.append(tuple(p+r*(u*math.cos(j*math.tau/sides)+v*math.sin(j*math.tau/sides))))
 n=len(pts)*sides
 for layer in range(2 if hollow else 1):
  for i in range(len(pts) if closed else len(pts)-1):
   ni=(i+1)%len(pts)
   for j in range(sides):
    f=tuple(layer*n+k for k in (i*sides+j,i*sides+(j+1)%sides,ni*sides+(j+1)%sides,ni*sides+j));fs.append(tuple(reversed(f)) if layer else f)
 if not closed:
  if hollow:
   for end in [0,len(pts)-1]:
    for j in range(sides):a=end*sides+j;b=end*sides+(j+1)%sides;fs.append((a,b,n+b,n+a) if end else (a,n+a,n+b,b))
  else:fs.extend([tuple(reversed(range(sides))),tuple((len(pts)-1)*sides+j for j in range(sides))])
 o=mesh(name,vs,fs,color,sides>8)
 if stripes:
  for c in ['cream','coral','aqua']:o.data.materials.append(M[c])
  for f in o.data.polygons:f.material_index=(f.index//sides)%4 if f.index<(len(pts)-1)*sides else 0
 return o
def ring(name,pos,r,thick,color,rot=None,segments=24):
 pts=[Vector((r*math.cos(i*math.tau/segments),r*math.sin(i*math.tau/segments),0)) for i in range(segments+1)]
 if rot:pts=[Euler(rot).to_matrix()@p for p in pts]
 return tube(name,[tuple(Vector(pos)+p) for p in pts],thick,color,8)
def lathe(name,rings,color,segments=20):
 vs=[];fs=[]
 for z,r in rings:
  for i in range(segments):a=i*math.tau/segments;vs.append((r*math.cos(a),r*math.sin(a),z))
 for j in range(len(rings)-1):
  for i in range(segments):fs.append((j*segments+i,j*segments+(i+1)%segments,(j+1)*segments+(i+1)%segments,(j+1)*segments+i))
 fs.extend([tuple(reversed(range(segments))),tuple((len(rings)-1)*segments+i for i in range(segments))]);return mesh(name,vs,fs,color)
def flat_symbol(name,outline,color,depth=.13,offset=(0,0,0),radius=.04):
 vs=[(x+offset[0],y+offset[1],z+offset[2]) for y in [-depth/2,depth/2] for x,z in outline];n=len(outline)
 fs=[tuple(reversed(range(n))),tuple(n+i for i in range(n))]+[(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
 return bevel(mesh(name,vs,fs,color),radius,2)
ASSETS=[]
def finish(before,name):
 obs=[o for o in S.objects if o not in before and o.type=='MESH'];bpy.ops.object.select_all(action='DESELECT')
 for o in obs:o.select_set(True)
 bpy.context.view_layer.objects.active=obs[0];bpy.ops.object.join();o=bpy.context.object;o.name=name;S.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR')
 low=min(v.co.z for v in o.data.vertices)
 for v in o.data.vertices:v.co.z-=low
 ASSETS.append(o);return o

# Six tools, each a distinct silhouette. Hollow straws have closed wall thickness.
for kind in ['BasicStraw','ColorfulStraw','BambooStraw','GoldenStraw','CrystalStraw','OceanVacuum']:
 before=set(S.objects)
 points=[(0,0,z) for z in [0,.4,.8,1.2,1.6,2,2.15]]+[(-.06,0,2.33),(-.22,0,2.45),(-.48,0,2.5),(-.72,0,2.5)]
 radius={'BasicStraw':.085,'ColorfulStraw':.11,'BambooStraw':.13,'GoldenStraw':.125,'CrystalStraw':.14,'OceanVacuum':.17}[kind]
 color={'BasicStraw':'coral','ColorfulStraw':'teal','BambooStraw':'green','GoldenStraw':'gold','CrystalStraw':'blue','OceanVacuum':'deepTeal'}[kind]
 tube('Hollow drinking tube',points,radius,color,8 if kind=='CrystalStraw' else 16,True,kind=='ColorfulStraw')
 if kind=='BasicStraw':
  for z in [2.08,2.13,2.18]:ring('Bendy collar',(0,0,z),.086,.014,'pink',segments=16)
 if kind=='BambooStraw':
  for z in [.35,1.1,1.85]:ring('Bamboo node',(0,0,z),.131,.035,'darkGreen',segments=16)
  ell('Soft bamboo highlight',(-.035,-.111,1.4),(.04,.027,.18),'goldLight',12,8)
 if kind=='GoldenStraw':
  for z in [.25,.45,1.55,1.75]:ring('Gold trim',(0,0,z),.126,.035,'goldLight',segments=16)
  ell('Turquoise jewel',(0,-.126,1.25),(.115,.06,.16),'teal',12,8)
 if kind=='CrystalStraw':
  for a,z in [(0,.55),(2.2,1.15),(4.4,1.75)]:
   pos=(.14*math.cos(a),.14*math.sin(a),z);ell('Faceted crystal',pos,(.15,.13,.3),'ice',8,4,rot=(.15,0,a))
  ring('Silver collar',(0,0,2),.14,.035,'white',segments=16)
 if kind=='OceanVacuum':
  ell('Turbine body',(0,0,1.25),(.49,.38,.66),'teal',20,12)
  box('Cream side cover',(0,-.32,1.35),(.73,.18,.9),'cream',.13)
  ring('Fan brass bezel',(0,-.42,1.31),.265,.065,'gold',rot=(math.pi/2,0,0))
  ell('Fan hub',(0,-.45,1.31),(.09,.06,.09),'navy',12,8)
  for i in range(4):
   a=i*math.pi/2;ell('Fan blade',(.13*math.cos(a),-.44,1.31+.13*math.sin(a)),(.15,.055,.065),'blue',12,8,rot=(0,-a,0))
  tube('Comfort handle',[(.28,.1,1.65),(.72,.1,1.7),(.8,.1,.85),(.32,.1,.8)],.11,'navy',12)
  for x in [-.15,.15]:ell('Status light',(x,-.425,1.69),(.045,.025,.045),'aqua',10,6)
 finish(before,'Tool__'+kind)

def shell(name,color,scale=1,location=(0,0,0),tilt=0):
 vs=[];fs=[];steps=7;n=33
 for layer in [0,1]:
  for j in range(steps):
   t=j/(steps-1);r=.065+1.2*t
   for i in range(n):
    a=-1.35+2.7*i/(n-1);rr=r*(1+.035*math.cos(a*12)*t);z=.12+.24*math.sin(math.pi*t)*(.85+.15*math.cos(a*12))-.11*layer
    p=Euler((tilt,0,0)).to_matrix()@Vector((math.sin(a)*rr,-math.cos(a)*rr,z))*scale+Vector(location);vs.append(tuple(p))
 total=steps*n
 for layer in [0,1]:
  for j in range(steps-1):
   for i in range(n-1):a=layer*total+j*n+i;f=(a,a+1,a+n+1,a+n);fs.append(tuple(reversed(f)) if layer else f)
 border=list(range(n))+[j*n+n-1 for j in range(1,steps)]+list(reversed(range((steps-1)*n,(steps-1)*n+n-1)))+[j*n for j in reversed(range(1,steps-1))]
 for i,a in enumerate(border):b=border[(i+1)%len(border)];fs.append((a,b,total+b,total+a))
 o=mesh(name,vs,fs,color);return o
before=set(S.objects);shell('Scalloped shell','pink');finish(before,'Loot__CommonShell')
before=set(S.objects)
outline=[(math.sin(i*math.pi/5)*(1.02 if i%2==0 else .44),math.cos(i*math.pi/5)*(1.02 if i%2==0 else .44)) for i in range(10)]
star=flat_symbol('Plump starfish',outline,'coral',.28,radius=.12)
tr=Matrix.Translation((0,0,.18))@Matrix.Rotation(math.pi/2,4,'X')
for v in star.data.vertices:v.co=tr@v.co
for i in range(5):
 a=i*math.tau/5
 for r in [.32]:ell('Starfish pearl dot',(math.sin(a)*r,math.cos(a)*r,.29),(.055,.055,.035),'goldLight',8,6)
finish(before,'Loot__Starfish')
before=set(S.objects);shell('Lower pearl shell','cream',.8);shell('Open pearl lid','pink',.8,(0,0,.12),math.radians(-54));ell('Luminous pearl',(0,-.48,.36),(.27,.27,.27),'white',24,16);finish(before,'Loot__PearlShell')
before=set(S.objects);lathe('Sea glass bottle',[(0,.24),(.07,.32),(.68,.32),(.84,.27),(.98,.13),(1.25,.13)],'bottle');lathe('Old cork',[(1.23,.11),(1.38,.12)],'wood');ring('Bottle lip',(0,0,1.22),.132,.035,'aqua');box('Paper label',(0,-.312,.47),(.39,.045,.34),'cream',.055);flat_symbol('Bottle rune',[(-.055,0),(0,.09),(.055,0),(0,-.09)],'gold',.025,(0,-.345,.47),.008);finish(before,'Loot__OldBottle')
before=set(S.objects);box('Treasure chest body',(0,0,.44),(1.55,1.04,.88),'wood',.12);lid=lathe('Domed lid',[(-.76,.52),(.76,.52)],'woodLight',24)
tr=Matrix.Translation((0,0,.85))@Matrix.Rotation(math.pi/2,4,'Y')
for v in lid.data.vertices:v.co=tr@v.co
for x in [-.51,.51]:
 box('Gold chest strap',(x,0,.46),(.13,1.08,.89),'gold',.035);ring('Lid gold arch',(x,0,.85),.532,.067,'goldLight',rot=(0,math.pi/2,0))
box('Chest latch',(0,-.56,.73),(.24,.1,.34),'gold',.045);ell('Keyhole',(0,-.619,.75),(.043,.014,.065),'woodDark',10,6);finish(before,'Loot__TreasureChest')
before=set(S.objects);box('Relic stone foot',(0,0,.16),(.95,.72,.32),'deepTeal',.12);tube('Relic stem',[(0,0,.28),(0,0,.65)],.14,'gold',12);ring('Ancient halo',(0,0,.95),.55,.15,'gold',rot=(math.pi/2,0,0),segments=32)
for x in [-1,1]:tube('Gem support',[(x*.5,0,.95),(0,0,.95)],.075,'goldLight',8)
ell('Relic heart',(0,-.03,.95),(.29,.21,.35),'teal',10,6);flat_symbol('Relic crest',[(-.1,-.07),(0,.12),(.1,-.07),(0,-.18)],'cream',.08,(0,-.23,1),.025);finish(before,'Loot__AncientRelic')

# Icons share the same geometry/material language as the world pickups.
before=set(S.objects);coin=lathe('Coin blank',[(-.105,.67),(.105,.67)],'gold',40)
tr=Matrix.Translation((0,0,.73))@Matrix.Rotation(math.pi/2,4,'X')
for v in coin.data.vertices:v.co=tr@v.co
ring('Coin raised rim',(0,-.105,.73),.59,.055,'goldLight',rot=(math.pi/2,0,0),segments=32)
tube('Coin wave emblem',[(-.32,-.141,.72),(-.16,-.141,.85),(0,-.141,.72),(.16,-.141,.59),(.32,-.141,.72)],.065,'goldLight',10);finish(before,'Icon__Coin')
before=set(S.objects);box('Backpack body',(0,0,.68),(1.15,.48,1.35),'teal',.21);box('Backpack flap',(0,-.26,1.13),(1.08,.16,.48),'coral',.13);box('Front pocket',(0,-.29,.44),(.76,.18,.49),'aqua',.12);box('Bag buckle',(0,-.37,.95),(.21,.1,.27),'gold',.055);tube('Carry loop',[(-.23,0,1.25),(-.2,0,1.62),(.2,0,1.62),(.23,0,1.25)],.08,'navy',10);finish(before,'Icon__Backpack')
before=set(S.objects);flat_symbol('Power bolt',[(-.05,1.6),(-.61,.72),(-.12,.72),(-.3,0),(.6,.97),(.13,.97),(.32,1.6)],'coral',.25,radius=.065);finish(before,'Icon__Power')
before=set(S.objects);clock=lathe('Speed clock body',[(-.1,.64),(.1,.64)],'blue',32)
tr=Matrix.Translation((0,0,.7))@Matrix.Rotation(math.pi/2,4,'X')
for v in clock.data.vertices:v.co=tr@v.co
ell('Clock face',(0,-.12,.7),(.52,.035,.52),'cream',24,12);ring('Clock rim',(0,-.125,.7),.57,.055,'aqua',rot=(math.pi/2,0,0));tube('Clock hands',[(0,-.17,1.09),(0,-.17,.7),(.27,-.17,.7)],.04,'navy',8);box('Winder',(0,0,1.4),(.3,.18,.16),'gold',.045);finish(before,'Icon__Speed')
before=set(S.objects);box('Boot sole',(0,-.12,.12),(.8,1.15,.24),'sole',.1);ell('Boot toe',(0,-.29,.32),(.39,.51,.28),'gold');box('Boot shaft',(0,.14,.65),(.7,.62,.9),'coral',.15);box('Boot cuff',(0,.14,1.02),(.78,.7,.24),'cream',.09);finish(before,'Icon__Walk')
before=set(S.objects);drop=lathe('Ocean droplet',[(0,.12),(.12,.35),(.42,.45),(.72,.35),(1.07,.18),(1.42,.018)],'blue',32);ell('Droplet highlight',(-.13,-.30,.52),(.075,.05,.22),'ice',12,8,rot=(0,-.25,0));finish(before,'Icon__Ocean')

# Atlas with intentionally stacked small UV triangles in flat-color swatches.
keys=list(COLORS);size=128;img=bpy.data.images.new('GameplayPalette',width=size,height=size,alpha=True);pixels=[]
for y in range(size):
 for x in range(size):pixels.extend((*rgb(COLORS[keys[((y//16)*8+x//16)%len(keys)]]),1))
img.pixels.foreach_set(pixels);img.filepath_raw=str(OUT/'GameplayPalette.png');img.file_format='PNG';img.save();img.pack()
atlas=bpy.data.materials.new('GameplayAtlas');atlas.use_nodes=True;bs=next(n for n in atlas.node_tree.nodes if n.type=='BSDF_PRINCIPLED');bs.inputs['Roughness'].default_value=.58;tex=atlas.node_tree.nodes.new('ShaderNodeTexImage');tex.image=img;tex.interpolation='Closest';atlas.node_tree.links.new(tex.outputs['Color'],bs.inputs['Base Color'])
stats=[]
for ob in ASSETS:
 me=ob.data;uv=me.uv_layers.new(name='UVMap')
 for p in me.polygons:
  idx=keys.index(me.materials[p.material_index].name.removeprefix('P_'))
  for j,li in enumerate(p.loop_indices):a=j*math.tau/len(p.loop_indices);uv.data[li].uv=((idx%8+.5)/8+.012*math.cos(a),(idx//8+.5)/8+.012*math.sin(a))
  p.material_index=0
 me.materials.clear();me.materials.append(atlas);bm=bmesh.new();bm.from_mesh(me);bmesh.ops.dissolve_degenerate(bm,edges=list(bm.edges),dist=.000001);bmesh.ops.triangulate(bm,faces=list(bm.faces));bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(me);bm.free();me.calc_loop_triangles();stats.append({'name':ob.name,'triangles':len(me.loop_triangles)})
bpy.context.view_layer.update();S.view_settings.view_transform='Standard';bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'SuckTheSea_Gameplay.blend'))
bpy.ops.export_scene.fbx(filepath=str(OUT/'SuckTheSea_Gameplay.fbx'),object_types={'MESH'},axis_forward='-Z',axis_up='Y',global_scale=.01,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',mesh_smooth_type='FACE',add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts');import qa_check
qa={}
for ob in ASSETS:
 qa[ob.name]=qa_check.run(objects=[ob.name],profile='roblox');print('GAMEPLAY_QA',ob.name,qa[ob.name]['errors'],flush=True)
(OUT/'qa.json').write_text(json.dumps(qa,indent=2,default=str));(OUT/'manifest.json').write_text(json.dumps({'objects':stats,'total_triangles':sum(p['triangles'] for p in stats)},indent=2))
print('GAMEPLAY_ASSETS_CREATED',len(ASSETS),sum(p['triangles'] for p in stats),flush=True)
# Presentation sheet; source/FBX above retain individual asset origin (0,0,0).
for i,o in enumerate(ASSETS):o.location=((i%6-2.5)*3.3,(i//6)*3.6,0)
world=bpy.data.worlds.new('Preview');world.use_nodes=True;bg=next(n for n in world.node_tree.nodes if n.type=='BACKGROUND');bg.inputs[0].default_value=(.65,.75,.8,1);bg.inputs[1].default_value=.6;S.world=world
bpy.ops.mesh.primitive_plane_add(size=100);bpy.context.object.data.materials.append(M['cream'])
ld=bpy.data.lights.new('Soft sun','AREA');ld.energy=1800;ld.size=12;l=bpy.data.objects.new('Soft sun',ld);S.collection.objects.link(l);l.location=(-5,-6,14);l.rotation_euler=(Vector((0,2,0))-l.location).to_track_quat('-Z','Y').to_euler()
cd=bpy.data.cameras.new('Asset sheet');c=bpy.data.objects.new('Asset sheet',cd);S.collection.objects.link(c);c.location=(8,-27,21);c.rotation_euler=(Vector((0,3.4,1))-c.location).to_track_quat('-Z','Y').to_euler();cd.type='ORTHO';cd.ortho_scale=22;S.camera=c
S.render.engine='CYCLES';S.cycles.samples=24;S.cycles.use_denoising=True;S.render.resolution_x=1800;S.render.resolution_y=1100;S.render.resolution_percentage=100;S.view_settings.view_transform='AgX';S.render.filepath=str(ROOT/'build/screenshots/step3-blender-assets.png');bpy.ops.render.render(write_still=True)
