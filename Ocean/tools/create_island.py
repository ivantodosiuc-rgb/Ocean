"""Original Suck The Sea art: Blender source and a conventional FBX import scene."""
import bpy, bmesh, math, random, json, sys
from mathutils import Vector
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets';OUT.mkdir(exist_ok=True)
random.seed(27)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
scene=bpy.context.scene
scene.unit_settings.system='NONE'
COLORS={
 'sand':'F4D594','sandDark':'D7AA68','grass':'7DCA4D','grassLight':'A5DE59',
 'leaf':'359A54','leafLight':'69C850','leafDark':'187B54','trunk':'B9804C',
 'wood':'B27749','woodLight':'E0AB70','woodDark':'674739','cream':'FFF1CB',
 'teal':'38BDB0','tealDark':'177E83','coral':'F5816B','pink':'EE91B4',
 'gold':'FFC84E','rock':'91ABB0','rockLight':'B7CBCA','rockDark':'6F9099',
 'lavender':'AC8CCD','white':'FFFAE6','blue':'4F93BC','ink':'294F5B',
 'rope':'E7C998','skin':'EDB985','skinDark':'BA815A','denim':'466D89'}
mats={}
def rgb(s):return tuple(int(s[i:i+2],16)/255 for i in (0,2,4))
for name,c in COLORS.items():
 m=bpy.data.materials.new(name);m.diffuse_color=(*rgb(c),1);mats[name]=m
def finish(o,name,mat):
 o.name=name;o.data.materials.append(mats[mat]);return o
def cube(name,p,s,mat,bevel=.12):
 bpy.ops.mesh.primitive_cube_add(size=1,location=p);o=bpy.context.object;o.scale=s
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 if bevel:
  m=o.modifiers.new('Soft carved edges','BEVEL');m.width=bevel;m.segments=2
  bpy.ops.object.modifier_apply(modifier=m.name)
 return finish(o,name,mat)
def uvball(name,p,s,mat,seg=12,rings=8):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=seg,ring_count=rings,radius=1,location=p)
 o=bpy.context.object;o.scale=s;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 for f in o.data.polygons:f.use_smooth=True
 return finish(o,name,mat)
def ico(name,p,s,mat,sub=1):
 bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=sub,radius=1,location=p)
 o=bpy.context.object;o.scale=s;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 return finish(o,name,mat)
def cyl(name,p,r,depth,mat,vertices=12):
 bpy.ops.mesh.primitive_cone_add(vertices=vertices,radius1=r,radius2=r,depth=depth,location=p)
 return finish(bpy.context.object,name,mat)
def beam(name,a,b,r,mat,r2=None,verts=10):
 d=Vector(b)-Vector(a);mid=(Vector(b)+Vector(a))/2
 bpy.ops.mesh.primitive_cone_add(vertices=verts,radius1=r,radius2=r if r2 is None else r2,depth=d.length,location=mid)
 o=bpy.context.object;o.rotation_euler=d.to_track_quat('Z','Y').to_euler();return finish(o,name,mat)
def torus(name,p,r,tube,mat,rotation=None):
 bpy.ops.mesh.primitive_torus_add(major_radius=r,minor_radius=tube,major_segments=24,minor_segments=6,location=p)
 o=bpy.context.object
 if rotation:o.rotation_euler=rotation
 return finish(o,name,mat)
def mesh(name,v,f,mat):
 data=bpy.data.meshes.new(name);data.from_pydata(v,[],f);data.update()
 o=bpy.data.objects.new(name,data);scene.collection.objects.link(o);return finish(o,name,mat)
def joinnew(before,name,origin=(0,0,0)):
 obs=[o for o in scene.objects if o not in before and o.type=='MESH']
 bpy.ops.object.select_all(action='DESELECT')
 for o in obs:o.select_set(True)
 bpy.context.view_layer.objects.active=obs[0];bpy.ops.object.join();o=bpy.context.object;o.name=name
 scene.cursor.location=origin;bpy.ops.object.origin_set(type='ORIGIN_CURSOR');return o
def text(name,word,p,size,mat):
 cu=bpy.data.curves.new(name,'FONT');cu.body=word;cu.align_x='CENTER';cu.align_y='CENTER'
 cu.size=size;cu.extrude=.055;cu.bevel_depth=.015;cu.bevel_resolution=1;cu.resolution_u=3
 font=Path('C:/Windows/Fonts/arialbd.ttf')
 if font.exists():cu.font=bpy.data.fonts.load(str(font),check_existing=True)
 ob=bpy.data.objects.new(name,cu);scene.collection.objects.link(ob);ob.location=p
 ob.rotation_euler=(math.pi/2,0,0)
 bpy.context.view_layer.objects.active=ob;ob.select_set(True);bpy.ops.object.convert(target='MESH');ob.select_set(False)
 ob.data.materials.append(mats[mat]);return ob
def begin():return set(scene.objects)
def place(template,name,x,z,y=0,angle=0,scale=1):
 ob=template.copy();ob.data=template.data;scene.collection.objects.link(ob);ob.name=name
 ob.location=(x,-z,y);ob.rotation_euler[2]=math.radians(angle);ob.scale=(scale,)*3
 return ob

# Asset templates: model at local origin, then link instances into the village.
templates=[]
b=begin()
for j in range(9):
 a=(.035*j*j,0,j*2.25);c=(.035*(j+1)**2,0,(j+1)*2.25)
 beam('Trunk ring',a,c,1.02-j*.055,'trunk',.98-j*.055,10)
 torus('Ring',c,.99-j*.055,.065,'woodLight')
top=Vector((2.8,0,20.25))
for k in range(9):
 ang=k*math.tau/9;v=[];f=[]
 for j in range(7):
  t=j/6;rad=11.5*t;h=2.7*math.sin(t*math.pi)-4.6*t*t
  center=top+Vector((math.cos(ang)*rad,math.sin(ang)*rad,h))
  width=1.65*math.sin(math.pi*t)**.7+.02
  tangent=Vector((-math.sin(ang),math.cos(ang),0))
  v.extend([tuple(center-tangent*width),tuple(center+Vector((0,0,.25))),tuple(center+tangent*width)])
 for j in range(6):
  for q in range(2):f.append((3*j+q,3*(j+1)+q,3*(j+1)+q+1,3*j+q+1))
 leaf=mesh('Sculpted palm frond',v,f,'leafLight' if k%3==0 else 'leaf')
 m=leaf.modifiers.new('Leaf thickness','SOLIDIFY');m.thickness=.12;bpy.context.view_layer.objects.active=leaf;bpy.ops.object.modifier_apply(modifier=m.name)
for a in range(3):uvball('Coconut',(top.x+math.cos(a*2.1)*.8,math.sin(a*2.1)*.8,19.8),(.62,.62,.75),'woodDark')
palm=joinnew(b,'KIT_Palm');templates.append(palm)
b=begin()
ico('Rock large',(0,0,1.8),(3.7,2.7,2.4),'rock',2)
ico('Rock small',(2.5,1,1),(1.9,1.6,1.4),'rockLight',1)
rock=joinnew(b,'KIT_Rock');templates.append(rock)
b=begin()
for x,y,z,s in [(-1,0,1.3,1.8),(1,0,1.8,2.1),(0,1,1.2,1.6)]:ico('Bush',(x,y,z),(s,s,s*.75),'leafLight' if x<0 else 'leaf',2)
bush=joinnew(b,'KIT_Bush');templates.append(bush)
b=begin()
for x,y,z in [(-.7,0,1.6),(.7,.4,2.1),(0,-.7,1.25)]:
 beam('Flower stem',(x,y,0),(x,y,z),.09,'leafDark',verts=6)
 uvball('Heart',(x,y,z),(.25,.25,.22),'gold')
 for k in range(5):
  a=k*math.tau/5;uvball('Petal',(x+.38*math.cos(a),y+.38*math.sin(a),z),(.36,.3,.15),'coral' if z>1.5 else 'white',8,5)
flower=joinnew(b,'KIT_Flowers');templates.append(flower)
b=begin()
# Bulging stave barrel with two clean brass hoops.
for k in range(12):
 a=k*math.tau/12
 o=cube('Stave',(math.cos(a)*1.25,math.sin(a)*1.25,1.55),(.63,.25,2.9),'woodLight' if k%3==0 else 'wood',.12);o.rotation_euler[2]=a+math.pi/2
cyl('Barrel lid',(0,0,2.98),1.28,.16,'woodDark',12)
for z in [.55,2.5]:torus('Iron hoop',(0,0,z),1.38,.13,'tealDark')
barrel=joinnew(b,'KIT_Barrel');templates.append(barrel)
b=begin()
cube('Chest body',(0,0,1.15),(3.8,2.6,2.2),'wood',.22)
lid=cyl('Round lid',(0,0,2.4),1.3,3.8,'woodLight',12);lid.rotation_euler[1]=math.pi/2
cube('Gold band L',(-1.3,0,1.5),(.24,2.75,2.9),'gold',.08)
cube('Gold band R',(1.3,0,1.5),(.24,2.75,2.9),'gold',.08)
cube('Latch',(0,-1.43,1.8),(.5,.18,.7),'gold',.08)
chest=joinnew(b,'KIT_Chest');templates.append(chest)
b=begin()
for k in range(3):torus('Coiled rope',(0,0,.12+k*.16),.9-k*.09,.12,'rope')
rope=joinnew(b,'KIT_Rope');templates.append(rope)
b=begin()
for k in range(7):
 ang=(-.8+k*.27);o=uvball('Shell rib',(math.sin(ang)*.65,math.cos(ang)*.4,.14),(.14,.8,.22),'cream',8,5);o.rotation_euler[2]=-ang
shell=joinnew(b,'KIT_Shell');templates.append(shell)
b=begin()
for k in range(5):
 a=k*math.tau/5;start=(0,0,.2);mid=(math.cos(a),math.sin(a),1.6+k*.22);end=(math.cos(a)*1.8,math.sin(a)*1.8,2.8+k*.2)
 beam('Coral branch',start,mid,.35,'coral',.28,8);beam('Coral tip',mid,end,.28,'pink',.18,8)
 uvball('Rounded coral tip',end,(.2,.2,.2),'pink',8,5)
 end2=(mid[0]+.65,mid[1]-.3,mid[2]+1);beam('Coral fork',mid,end2,.22,'coral',.1,8)
coral=joinnew(b,'KIT_Coral');templates.append(coral)
b=begin()
# Hull has separate solid sides, floor and seats; open top.
verts=[];faces=[]
outline=[(-2.5,-4),(-2.9,-2),(-2.6,2),(0,5),(2.6,2),(2.9,-2),(2.5,-4)]
for z,sc in [(0,.7),(1.8,1)]:
 for x,y in outline:verts.append((x*sc,y*sc,z))
faces.append(tuple(reversed(range(7))))
for k in range(7):faces.append((k,(k+1)%7,(k+1)%7+7,k+7))
hull=mesh('Boat hull',verts,faces,'teal');m=hull.modifiers.new('Solid hull','SOLIDIFY');m.thickness=.25;bpy.context.view_layer.objects.active=hull;bpy.ops.object.modifier_apply(modifier=m.name)
cube('Boat floor',(0,-.5,.35),(3.4,5.2,.3),'woodLight',.15)
for y in [-2,1]:cube('Bench',(0,y,1.35),(4.8,.8,.35),'woodLight',.12)
for k in range(7):
 a=(*outline[k],1.8);c=(*outline[(k+1)%7],1.8);beam('Cream gunwale',a,c,.16,'cream')
beam('Oar handle',(-3,-3,2),(3.5,2,2),.12,'woodLight');o=cube('Oar blade',(3.6,2.1,2),(1.2,1.9,.18),'cream');o.rotation_euler[2]=-.7
boat=joinnew(b,'KIT_Boat');templates.append(boat)

# Rounded roof-board huts, built at origin, all geometry genuinely authored in Blender.
def shop(key,label,roof,awning):
 b=begin()
 cube('Deck',(0,0,.55),(23,17,1.1),'woodDark',.3)
 for i in range(16):cube('Deck board',(-10.7+i*1.42,0,1.15),(1.35,16.5,.22),'woodLight' if i%4==0 else 'wood',.08)
 for x in [-9.7,9.7]:
  for y in [-6.7,6.7]:cube('Timber post',(x,y,6.4),(.9,.9,10.7),'woodDark',.15)
 for x in [-9.6,9.6]:cube('Side beam',(x,0,10.8),(.8,15,.9),'woodLight')
 for i in range(13):cube('Back wall',(-9.4+i*1.56,6.6,5.5),(1.5,.5,8.2),'wood' if i%2 else 'woodLight',.1)
 for x in [-9.5,9.5]:
  for j in range(6):cube('Side slat',(x,2.3,2+j*1.25),(.5,8.3,1.18),'woodLight',.1)
 # broad curved roofs, overlapping boards on two slopes
 for side in [-1,1]:
  for j in range(7):
   y=side*(j*.95+.4);z=14.5-j*.43-.055*j*j
   o=cube('Rounded roof board',(0,y,z),(24.8,1.3,.45),roof,.16);o.rotation_euler[0]=side*(-.44-.07*j)
 beam('Ridge',(-12.5,0,14.85),(12.5,0,14.85),.35,'woodDark')
 cube('Counter',(0,-4.8,4.1),(15,3.0,.65),'cream',.22)
 for x in [-5.8,5.8]:cube('Counter leg',(x,-4.8,2.55),(.6,.7,3),'woodDark')
 for j in range(10):cube('Counter front',(-6.7+j*1.5,-6,2.7),(1.4,.35,2.3),'wood',.08)
 # stripe awning across open front
 for j in range(10):
  x=-10.8+j*2.4;o=cube('Canvas stripe',(x,-8.1,10.3),(2.38,4.2,.3),awning if j%2==0 else 'cream',.12);o.rotation_euler[0]=.16
  cube('Scalloped valance',(x,-10.1,9.75),(2.38,.25,.9),awning if j%2==0 else 'cream',.26)
 cube('Signboard',(0,-7.15,12.2),(18,.65,2.65),'woodDark',.35)
 text('Carved lettering',label,(0,-7.53,12.2),1.85,'cream')
 for x in [-8.3,8.3]:uvball('Sign brass pin',(x,-7.55,12.2),(.13,.09,.13),'gold',8,4)
 # porch steps, max rise < 0.5 stud
 for j in range(3):cube('Porch step',(0,-9.2-j*1.3,.85-j*.27),(9.4,1.5,.35),'woodLight',.12)
 obj=joinnew(b,key)
 return obj
straw=shop('KIT_StrawShop','STRAWS','tealDark','teal');templates.append(straw)
upgrade=shop('KIT_UpgradeShop','UPGRADES','coral','gold');templates.append(upgrade)
treasure=shop('KIT_TreasureShop','TREASURES','blue','lavender');templates.append(treasure)

# Map ground, coordinates in Blender Z-up; front of village is -Y.
def boundary(a):return 85*(1+.055*math.sin(3*a+.5)+.035*math.cos(7*a)+.025*math.sin(11*a))
def disc(name,rings,mat,n=96):
 v=[];f=[]
 for r,z in rings:
  for k in range(n):
   a=k*math.tau/n;rr=r*(1+.055*math.sin(3*a+.5)+.035*math.cos(7*a)+.025*math.sin(11*a));v.append((rr*math.cos(a),rr*math.sin(a),z))
 for j in range(len(rings)-1):
  for k in range(n):f.append((j*n+k,j*n+(k+1)%n,(j+1)*n+(k+1)%n,(j+1)*n+k))
 f.append(tuple(reversed(range(n))));f.append(tuple((len(rings)-1)*n+k for k in range(n)))
 ob=mesh(name,v,f,mat)
 # Recalculate consistent outward normals after bottom-to-top construction.
 bm=bmesh.new();bm.from_mesh(ob.data);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(ob.data);bm.free()
 return ob
disc('StarterIsland__GoldenShore',[(85,-12),(88,-3),(83,.8),(76,3),(66,4.7),(38,5.55),(1,5.55)],'sand')
disc('StarterIsland__Meadow',[(66,4.5),(65,5.4),(60,5.85),(35,6),(1,6)],'grass')
# small northern grassy overlook with a gentle ramp-like slope
# Village square: compass mosaic of real geometry, no screen UI.
cyl('StarterIsland__Plaza',(0,0,6.05),17,.7,'rockLight',64)
torus('StarterIsland__PlazaTrim',(0,0,6.43),15.5,.18,'cream')
cyl('StarterIsland__Compass',(0,0,6.46),5.9,.12,'tealDark',48)
for k in range(8):
 a=k*math.tau/8;r=5 if k%2==0 else 3.5
 v=[(0,0,6.55),(math.cos(a-.18)*1.6,math.sin(a-.18)*1.6,6.55),(math.cos(a)*r,math.sin(a)*r,6.55),(math.cos(a+.18)*1.6,math.sin(a+.18)*1.6,6.55)]
 ob=mesh('StarterIsland__CompassRay',v,[(0,1,2,3)],'gold' if k%2==0 else 'cream')
 m=ob.modifiers.new('Inlay','SOLIDIFY');m.thickness=.08;bpy.context.view_layer.objects.active=ob;bpy.ops.object.modifier_apply(modifier=m.name)

def path(points):
 for seg in range(len(points)-1):
  a=Vector(points[seg]);bb=Vector(points[seg+1]);steps=max(1,int((bb-a).length/4))
  for j in range(steps):
   p=a.lerp(bb,j/steps);r=math.hypot(p.x,p.y)
   z=6.0 if r<57 else max(3.0,6-(r-57)*.16)
   o=cyl('StarterIsland__PathStone',(p.x,-p.y,z+.1),2.5,.35,'rockLight' if j%3 else 'cream',7)
   o.scale=(1.15,1,1);o.rotation_euler[2]=random.random()
path([(-14,-5),(-26,-9),(-38,-6)])
path([(7,-14),(14,-25),(25,-30)])
path([(15,5),(29,11),(46,24)])
path([(0,15),(-3,34),(1,52),(0,70)])
place(straw,'Buildings__StrawShop',-41,-21,5.7,12)
place(upgrade,'Buildings__UpgradeShop',27,-43,5.6,-23)
place(treasure,'Buildings__TreasureShop',49,13,5.6,-65)
# A handful of counter props with clear silhouettes.
for i in range(3):
 x=-45+i*3
 cyl('Buildings__StrawCup',(x,24.5,10.7),.65,1.25,'teal',10)
 for k in range(3):beam('Buildings__DisplayStraw',(x+(k-1)*.3,24.5,11),(x+(k-1)*.3,24.5,13),.13,'coral' if k%2 else 'gold',verts=8)

# Dock: 14-wide boardwalk starts on beach, runs into lagoon, with a broad T head.
for j in range(26):cube('Ocean__PierBoard',(0,-(68+j*2),3.4),(13,1.88,.5),'woodLight' if j%5==0 else 'wood',.13)
for j in range(9):cube('Ocean__PierHead',(0,-(119+j*1.8),3.4),(29,1.7,.5),'woodLight' if j%4==0 else 'wood',.12)
for z in [72,86,100,114,130]:
 for x in [-6.3,6.3] if z<119 else [-13,13]:
  cyl('Ocean__PierPile',(x,-z,.2),.65,11,'woodDark',10)
  cyl('Ocean__PierCap',(x,-z,5.8),.78,.5,'woodLight',10)
  torus('Ocean__PileRope',(x,-z,5.1),.68,.13,'rope')
for side in [-1,1]:
 for z in [72,86,100]:
  a=(side*6.3,-z,5.15);c=(side*6.3,-(z+14),5.15);mid=(side*6.3,-(z+7),4.55)
  beam('Ocean__SafetyRope',a,mid,.12,'rope');beam('Ocean__SafetyRope',mid,c,.12,'rope')
place(boat,'Ocean__LittleBoat',20,123,.25,-15,1.2)
for x,z in [(-9,124),(9,132),(-9,130)]:place(barrel,'Ocean__DockBarrel',x,z,3.65,random.randrange(360))
place(rope,'Ocean__RopeCoil',4,125,3.7)

# Palms frame views rather than closing the paths.
palm_spots=[(-67,-24),(-60,16),(-39,48),(-53,44),(-20,65),(35,58),(60,42),(72,3),(53,-44),(-13,-64),(-45,-55),(16,62),(-71,1),(4,-72)]
for i,(x,z) in enumerate(palm_spots):
 r=math.hypot(x,z);y=5.5 if r<63 else 3.4
 place(palm,f'Decorations__Palm_{i:02}',x,z,y,random.randrange(360),random.uniform(.85,1.15))
for i,(x,z) in enumerate([(-22,-23),(-19,22),(22,22),(-55,-8),(52,-10),(-5,-44),(-59,39),(42,47),(57,-35),(-29,-53),(-35,29),(19,53)]):
 place(bush,f'Decorations__Bush_{i:02}',x,z,5.7,random.randrange(360),random.uniform(.8,1.3))
 place(flower,f'Decorations__FlowerBed_{i:02}',x+3,z+2,5.7,random.randrange(360),1.3)
for i,(x,z) in enumerate([(-71,29),(61,48),(-69,-37),(20,-72),(-48,58),(70,-19),(46,61),(-18,-70)]):
 place(rock,f'Decorations__ShoreRock_{i:02}',x,z,2.9,random.randrange(360),random.uniform(1.0,1.65))
for i,(x,z) in enumerate([(-56,-29),(-26,-24),(29,-57),(58,7),(55,26)]):place(barrel,f'Decorations__VillageBarrel_{i:02}',x,z,5.8,i*63)
for i,(x,z) in enumerate([(49,24),(56,22)]):place(chest,f'Decorations__TreasureDisplay_{i}',x,z,6.0,i*24)
for i,(x,z) in enumerate([(55,17),(56,15),(-20,73),(67,35),(-62,43)]):place(shell,f'Decorations__Shell_{i}',x,z,3.1 if i>1 else 10.5,i*55,1.7)

# Future revealed land is actual solid geometry at distinct submerged elevations.
for i,(x,z,r,h) in enumerate([(-123,19,37,-8),(115,-48,43,-13),(80,135,32,-20),(-65,-126,39,-25)]):
 ob=disc(f'UnderwaterTerrain__Sandbank_{i+1}',[(r,-39),(r,h-4),(r*.8,h),(r*.05,h+.7)],'sand',48)
 ob.location=(x,-z,0)
 for j in range(5):
  a=j*math.tau/5;xx=x+math.cos(a)*r*.55;zz=z+math.sin(a)*r*.55
  place(coral,f'UnderwaterTerrain__Coral_{i}_{j}',xx,zz,h+.3,j*66,1.8 if j%2 else 1.3)
  if j%2:place(rock,f'UnderwaterTerrain__ReefRock_{i}_{j}',xx+4,zz-2,h,j*31,1.3)
 place(chest,f'UnderwaterTerrain__FutureTreasure_{i+1}',x,z,h+1,i*77)

# Small ground plants on beach edge.
for i in range(26):
 a=i*math.tau/26;rr=random.uniform(63,71);x=math.cos(a)*rr;z=math.sin(a)*rr
 if abs(x)<9 and z>0:continue
 for j in range(3):
  ob=ico('Decorations__GrassTuft',(x+j*.4,-z,5.25),(.35,.6,1.1),'grassLight',1);ob.rotation_euler[1]=j*.18

# Remove source templates after all instances have been linked.
for o in templates:bpy.data.objects.remove(o,do_unlink=True)

# Join tiny pieces per logical group (building meshes already joined) to keep draw calls bounded.
for prefix in ['StarterIsland__PathStone','StarterIsland__CompassRay','Ocean__PierBoard','Ocean__PierHead','Ocean__PierPile','Ocean__PierCap','Ocean__PileRope','Ocean__SafetyRope','Decorations__GrassTuft','Buildings__DisplayStraw','Buildings__StrawCup']:
 obs=[o for o in scene.objects if o.name.startswith(prefix)]
 if len(obs)>1:
  bpy.ops.object.select_all(action='DESELECT')
  for o in obs:o.select_set(True)
  bpy.context.view_layer.objects.active=obs[0];bpy.ops.object.join();bpy.context.object.name=prefix

# Bake the flat art palette to one tiny UV atlas. One material, no custom shader dependencies.
names=list(COLORS);N=8;SIZE=128
img=bpy.data.images.new('SuckTheSea_Palette',width=SIZE,height=SIZE,alpha=True)
pixels=[]
for yy in range(SIZE):
 for xx in range(SIZE):
  idx=(yy//16)*N+(xx//16);color=rgb(COLORS[names[idx%len(names)]])
  pixels.extend((*color,1))
img.pixels.foreach_set(pixels);img.filepath_raw=str(OUT/'SuckTheSea_Palette.png');img.file_format='PNG';img.save();img.pack()
palette=bpy.data.materials.new('SuckTheSea_ColorAtlas');palette.use_nodes=True
bsdf=palette.node_tree.nodes.get('Principled BSDF');bsdf.inputs['Roughness'].default_value=.83
tex=palette.node_tree.nodes.new('ShaderNodeTexImage');tex.image=img;tex.interpolation='Closest';palette.node_tree.links.new(tex.outputs['Color'],bsdf.inputs['Base Color'])
seen=set();stats=[]
for ob in list(scene.objects):
 if ob.type!='MESH':continue
 me=ob.data
 if me.name not in seen:
  seen.add(me.name)
  uv=me.uv_layers.new(name='UVMap') if not me.uv_layers else me.uv_layers[0]
  for poly in me.polygons:
   name=me.materials[poly.material_index].name if me.materials else 'cream'
   idx=names.index(name) if name in names else 0;coord=((idx%N+.5)/N,(idx//N+.5)/N)
   for li in poly.loop_indices:uv.data[li].uv=coord
   poly.material_index=0
  me.materials.clear();me.materials.append(palette)
  # Triangulation is explicit and consistent for export and QA.
  bm=bmesh.new();bm.from_mesh(me);bmesh.ops.triangulate(bm,faces=list(bm.faces));bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(me);bm.free()
 me.calc_loop_triangles();stats.append({'name':ob.name,'triangles':len(me.loop_triangles),'mesh':me.name})

# Export convention: Blender numeric coordinates map 1:1 to Roblox studs via importer scale.
scene.view_settings.view_transform='Standard'
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'SuckTheSea_Island.blend'))
bpy.ops.export_scene.fbx(filepath=str(OUT/'SuckTheSea_Island.fbx'),use_selection=False,object_types={'MESH'},
 axis_forward='-Z',axis_up='Y',global_scale=1,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',
 mesh_smooth_type='FACE',use_mesh_modifiers=True,add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
(OUT/'asset-manifest.json').write_text(json.dumps({'objects':stats,'object_count':len(stats),'unique_meshes':len(seen),'triangles_total':sum(s['triangles'] for s in stats),'coordinates':'Blender (X,-Z,Y) maps to intended Roblox (X,Y,Z); verify importer scale 1 stud per Blender unit'},indent=2))
print('OCEAN_ASSETS_READY',len(stats),sum(s['triangles'] for s in stats),flush=True)

# Asset QA on representative exported geometry without making more content.
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-game-optimization/scripts')
import mesh_stats
report=mesh_stats.run(budget='roblox')
(OUT/'budget-report.json').write_text(json.dumps(report,default=str,indent=2))
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts')
import qa_check
qa={}
for name in ['Buildings__StrawShop','Decorations__Palm_00','Ocean__LittleBoat','StarterIsland__GoldenShore','StarterIsland__Meadow']:
 try:qa[name]=qa_check.run(objects=[name],profile='roblox')
 except Exception as e:qa[name]={'error':str(e)}
(OUT/'blender-qa.json').write_text(json.dumps(qa,default=str,indent=2))
print('OCEAN_QA_WRITTEN',flush=True)
