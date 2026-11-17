"""Original Blender expansion: 50 collectible silhouettes, smooth land and an explorable wreck."""
import bpy,bmesh,math,json,sys,random
from pathlib import Path
from mathutils import Vector,Matrix,Euler
ROOT=Path(__file__).resolve().parents[1]
base=(ROOT/'tools/create_gameplay_assets.py').read_text(encoding='utf-8')
exec(base[:base.index('# Six tools')])
OUT=ROOT/'assets/depth';OUT.mkdir(parents=True,exist_ok=True)
random.seed(409)
# The six existing collectibles remain compatible with saved inventories.
exec(base[base.index('def shell('):base.index('# Icons share')])
CATALOG=[
 ('CommonShell','Common Shell','shell','pink',10,28,0),
 ('Starfish','Starfish','star','coral',20,19,0),
 ('PearlShell','Pearl Shell','pearl','aqua',50,8,3),
 ('OldBottle','Old Bottle','bottle','bottle',100,5,6),
 ('TreasureChest','Treasure Chest','chest','gold',250,3,18),
 ('AncientRelic','Ancient Relic','relic','purple',600,1,35),
 ('SunriseScallop','Sunrise Scallop','scallop','goldLight',18,18,0),
 ('SpiralShell','Spiral Shell','spiral','coral',32,14,2),
 ('CowrieShell','Tiger Cowrie','cowrie','cream',38,12,3),
 ('NautilusShell','Nautilus Shell','nautilus','pink',75,8,8),
 ('ConeShell','Violet Cone Shell','cone','lilac',48,11,5),
 ('TurbanShell','Turban Shell','turban','aqua',65,9,7),
 ('BlueStar','Blue Sea Star','blueStar','blue',30,15,2),
 ('BrittleStar','Brittle Star','brittle','red',42,11,5),
 ('SandDollar','Sand Dollar','dollar','cream',24,16,0),
 ('SeaUrchin','Sea Urchin','urchin','purple',55,10,6),
 ('CoralFragment','Branching Coral','coral','red',62,12,8),
 ('SeaGlass','Sea Glass','glass','aqua',35,14,3),
 ('PinkPearl','Rose Pearl','pinkPearl','pink',130,5,12),
 ('BlackPearl','Midnight Pearl','blackPearl','navy',420,2,28),
 ('AmberStone','Ocean Amber','amber','goldDark',95,8,10),
 ('JadeBead','Carved Jade Bead','bead','teal',120,6,13),
 ('MessageBottle','Message in a Bottle','message','blue',165,5,16),
 ('CeramicJug','Painted Amphora','jug','coral',190,5,19),
 ('PorcelainPlate','Sailor Porcelain','plate','cream',145,6,15),
 ('CopperCoin','Copper Sea Coin','coin','woodLight',65,12,10),
 ('SilverCoin','Silver Crown Coin','silverCoin','ice',150,8,18),
 ('GoldDoubloon','Gold Doubloon','goldCoin','gold',340,5,25),
 ('CoralRing','Coral Ring','ring','coral',240,4,22),
 ('CaptainsRing','Captain\'s Signet','signet','teal',650,2,30),
 ('RubyBrooch','Ruby Sun Brooch','brooch','red',840,2,34),
 ('SapphirePendant','Sapphire Pendant','pendant','blue',920,2,37),
 ('BronzeKey','Bronze Cabin Key','key','goldDark',210,5,20),
 ('AnchorCharm','Anchor Charm','anchor','ice',280,4,24),
 ('Compass','Mariner Compass','compass','gold',390,3,26),
 ('PocketWatch','Captain\'s Watch','watch','goldLight',520,3,28),
 ('Spyglass','Brass Spyglass','spyglass','gold',480,3,27),
 ('ShipBell','Ship Bell','bell','goldDark',720,2,32),
 ('CopperLantern','Pearl Lantern','lantern','woodLight',790,2,34),
 ('RoyalCrown','Sunken Crown','crown','gold',1800,1,43),
 ('GoldenChalice','Golden Chalice','chalice','gold',1250,2,40),
 ('RubyCluster','Ruby Cluster','ruby','red',980,3,36),
 ('SapphireCluster','Sapphire Cluster','sapphire','blue',1100,3,40),
 ('AmethystCluster','Amethyst Geode','amethyst','purple',1350,2,44),
 ('AquamarineCluster','Aquamarine Bloom','aquamarine','aqua',1550,2,48),
 ('GoldenIdol','Golden Tide Idol','idol','gold',2400,1,51),
 ('AncientTrident','Ancient Trident','trident','deepTeal',3200,1,56),
 ('AtlanteanTablet','Atlantean Tablet','tablet','teal',2800,1,53),
 ('CrystalHeart','Heart of the Ocean','heart','blue',4500,.6,60),
 ('ObsidianFang','Obsidian Fang','fang','navy',2100,1.5,50),
]
assert len(CATALOG)==50

def rotate(ob,angle,axis='X',offset=(0,0,0)):
 tr=Matrix.Translation(offset)@Matrix.Rotation(angle,4,axis)
 for v in ob.data.vertices:v.co=tr@v.co
 return ob

def jewel(pos,color,scale=1,sides=6):
 rings=[(-.42,.07),(-.2,.32),(.1,.36),(.45,.04)]
 ob=lathe('Polished jewel',[(z*scale,r*scale) for z,r in rings],color,sides)
 for v in ob.data.vertices:v.co+=Vector(pos)
 for f in ob.data.polygons:f.use_smooth=False
 return ob

def starfish(color,arms=5,reach=1.05,thickness=.26):
 outline=[(math.sin(i*math.pi/arms)*(reach if i%2==0 else .32),math.cos(i*math.pi/arms)*(reach if i%2==0 else .32)) for i in range(arms*2)]
 ob=flat_symbol('Rounded star arms',outline,color,thickness,radius=.07)
 rotate(ob,math.pi/2,offset=(0,0,thickness/2))
 ell('Star central disk',(0,0,.22),(.32,.32,.12),color,20,10)

def coin(color,variant=0):
 lathe('Coin milled body',[(0,.58),(.035,.68),(.15,.68),(.19,.58)],color,32)
 ring('Raised coin rim',(0,0,.19),.57,.035,'goldLight' if color!='ice' else 'white',segments=32)
 if variant==0:
  for a in [0,math.pi/2]:tube('Anchor coin cross',[(-.29*math.cos(a),-.29*math.sin(a),.20),(.29*math.cos(a),.29*math.sin(a),.20)],.045,'cream',8)
 elif variant==1:
  ell('Coin pearl',(0,0,.23),(.23,.23,.07),'white',16,8)
 else:
  for i in range(5):a=i*math.tau/5;tube('Sun coin ray',[(.1*math.cos(a),.1*math.sin(a),.21),(.32*math.cos(a),.32*math.sin(a),.21)],.045,'goldLight',8)

def spiral(color,turns=2.25,conical=False):
 pts=[];rs=[]
 for i in range(65):
  t=i/64;a=t*math.tau*turns;r=.78*(1-t)+.05
  pts.append((r*math.cos(a),r*math.sin(a),.20+t*(.7 if conical else .12)))
  rs.append(.20*(1-t)+.07)
 tube('Continuous shell spiral',pts,rs,color,12)
 ell('Shell center',pts[-1],(.12,.12,.12),'cream',12,8)

def coral(color='coral',height=1.5):
 ell('Coral base',(0,0,.12),(.55,.4,.17),'cream',16,10)
 for i in range(5):
  a=i*2.4;r=.32;z=height*(.7+.3*math.sin(i+1)**2)
  pts=[(0,0,.1),(r*.6*math.cos(a),r*.6*math.sin(a),z*.5),(r*math.cos(a),r*math.sin(a),z)]
  tube('Round coral branch',pts,[.13,.12,.075],color,10)
  ell('Coral growing tip',pts[-1],(.076,.076,.10),color,12,8)
  mid=pts[1];end=(mid[0]+.35*math.cos(a+1),mid[1]+.35*math.sin(a+1),z*.8)
  tube('Coral fork',[mid,end],[.085,.045],color,10);ell('Fork tip',end,(.045,.045,.055),color,10,6)

def bottle(color,message=False):
 lathe('Bottle silhouette',[(0,.23),(.1,.35),(.8,.35),(.96,.27),(1.07,.12),(1.35,.12)],color,24)
 lathe('Cork',[(1.31,.105),(1.5,.115)],'wood',16)
 ring('Bottle lip',(0,0,1.33),.12,.035,'aqua')
 box('Visible parchment',(0,-.335,.56),(.38,.055,.52),'cream',.05)
 if message:
  for z in [.45,.55,.65]:tube('Ink lines',[(-.12,-.371,z),(.12,-.371,z)],.012,'woodDark',6)
  ring('Wax seal',(0,-.375,.34),.08,.035,'red',rot=(math.pi/2,0,0),segments=16)

for index,(ident,label,kind,color,value,weight,depth) in enumerate(CATALOG[6:],6):
 before=set(S.objects)
 if kind=='scallop':
  shell('Broad sun scallop',color,1.12)
  for i in range(7):a=-1.1+i*.36;ell('Scallop edge pearl',(math.sin(a)*1.15,-math.cos(a)*1.15,.15),(.06,.07,.05),'coral',10,6)
 elif kind in ['spiral','nautilus','turban']:
  spiral(color,2.6 if kind=='nautilus' else 1.7 if kind=='turban' else 2.1,kind=='turban')
  if kind=='nautilus':ell('Nautilus lip',(.77,0,.21),(.25,.14,.22),'cream',20,12)
 elif kind=='cowrie':
  ell('Smooth cowrie body',(0,0,.38),(.55,.88,.38),'cream',32,18)
  for i in range(9):
   a=i*2.4;y=(i%3-1)*.33;x=math.sin(a)*.33;z=.38+.38*math.sqrt(max(0,1-(x/.55)**2-(y/.88)**2))-.012
   ell('Tiger cowrie spot',(x,y,z),(.075,.09,.023),'woodDark',10,6)
 elif kind=='cone':
  lathe('Cone shell',[(0,.49),(.12,.54),(.35,.42),(.7,.3),(1.05,.18),(1.48,.025)],color,32)
  for z,r in [(.19,.50),(.43,.38),(.77,.27),(1.08,.17)]:ring('Shell growth ridge',(0,0,z),r,.025,'cream',segments=32)
 elif kind in ['blueStar','brittle']:starfish(color,7 if kind=='blueStar' else 5,1 if kind=='blueStar' else 1.35,.28 if kind=='blueStar' else .18)
 elif kind=='dollar':
  ell('Sand dollar',(0,0,.14),(.85,.77,.14),color,32,12)
  for i in range(5):
   a=i*math.tau/5;pts=[(.12*math.cos(a),.12*math.sin(a),.27),(.36*math.cos(a),.36*math.sin(a),.25),(.54*math.cos(a),.54*math.sin(a),.22)]
   tube('Dollar petal emboss',pts,.023,'sand',8)
 elif kind=='urchin':
  ell('Urchin body',(0,0,.43),(.52,.52,.43),color,24,14)
  for i in range(26):
   a=i*2.4;u=.18+(i%5)*.16;v=Vector((math.cos(a)*math.sqrt(1-u*u),math.sin(a)*math.sqrt(1-u*u),u))
   start=Vector((0,0,.40))+v*.42;end=Vector((0,0,.40))+v*(.70+(i%3)*.07)
   tube('Soft urchin spine',[start,end],[.052,.012],color,8)
 elif kind=='coral':coral(color)
 elif kind=='glass':
  for i,(x,y,s) in enumerate([(-.16,0,.65),(.16,.10,.6),(.02,-.14,.52)]):jewel((x,y,.25),['aqua','ice','teal'][i],s,5)
 elif kind in ['pinkPearl','blackPearl']:
  shell('Pearl oyster cup','cream',.64)
  ell('Pearl',(0,-.4,.43),(.36,.36,.36),color,32,20)
  ell('Pearl highlight',(-.12,-.68,.57),(.05,.02,.07),'white',12,8)
 elif kind=='amber':
  ell('Polished amber',(0,0,.38),(.58,.45,.38),color,28,16)
  ell('Amber inclusion',(0,-.435,.42),(.14,.026,.18),'wood',14,8)
 elif kind=='bead':
  ring('Jade donut',(0,0,.34),.44,.22,color,rot=(math.pi/2,0,0),segments=32)
  ring('Carved gold inlay',(0,-.22,.34),.44,.045,'gold',rot=(math.pi/2,0,0),segments=32)
 elif kind=='message':bottle(color,True)
 elif kind=='jug':
  lathe('Amphora pot',[(0,.28),(.15,.43),(.42,.57),(.85,.54),(1.15,.24),(1.4,.22),(1.45,.28)],color,28)
  for side in [-1,1]:tube('Amphora handle',[(side*.23,0,1.3),(side*.65,0,1.15),(side*.7,0,.72),(side*.5,0,.65)],.08,'goldLight',12)
  for z,r in [(.22,.47),(.82,.55),(1.38,.24)]:ring('Painted amphora band',(0,0,z),r,.026,'cream',segments=28)
 elif kind=='plate':
  ell('Porcelain plate',(0,0,.12),(.9,.9,.12),color,36,12)
  ring('Blue plate rim',(0,0,.16),.76,.05,'blue',segments=36)
  for i in range(6):a=i*math.tau/6;tube('Porcelain petals',[(0,0,.24),(.34*math.cos(a),.34*math.sin(a),.23)],.027,'teal',10)
 elif kind in ['coin','silverCoin','goldCoin']:coin(color,{'coin':0,'silverCoin':1,'goldCoin':2}[kind])
 elif kind in ['ring','signet','brooch','pendant']:
  r=.43 if kind!='brooch' else .5
  ring('Jewelry band',(0,0,.56),r,.10,'gold',rot=(math.pi/2,0,0),segments=32)
  if kind in ['ring','signet']:jewel((0,0,.56+r),color,.5 if kind=='ring' else .75,6 if kind=='ring' else 4)
  else:
   for i in range(4):a=i*math.pi/2;tube('Gem prong',[(r*math.cos(a),0,.56+r*math.sin(a)),(0,0,.56)],.065,'goldLight',8)
   jewel((0,-.03,.56),color,1 if kind=='brooch' else 1.3,8 if kind=='brooch' else 4)
   if kind=='pendant':ring('Pendant eyelet',(0,0,1.16),.14,.06,'gold',rot=(math.pi/2,0,0),segments=20)
 elif kind=='key':
  ring('Key bow',(0,0,1.4),.31,.085,color,rot=(math.pi/2,0,0),segments=24)
  tube('Key stem',[(0,0,.09),(0,0,1.13)],.085,color,12)
  for z in [.18,.43]:box('Key tooth',(.14,0,z),(.38,.16,.12),color,.025)
 elif kind=='anchor':
  tube('Anchor stem',[(0,0,.12),(0,0,1.4)],.10,color,12);ring('Anchor eye',(0,0,1.55),.22,.075,color,rot=(math.pi/2,0,0))
  tube('Anchor crossbar',[(-.48,0,1.05),(.48,0,1.05)],.09,color,12)
  tube('Curved anchor flukes',[(-.7,0,.55),(-.5,0,.2),(0,0,.08),(.5,0,.2),(.7,0,.55)],.10,color,12)
  for x in [-.68,.68]:jewel((x,0,.52),color,.35,4)
 elif kind in ['compass','watch']:
  ob=lathe('Instrument case',[(-.13,.58),(.10,.65),(.17,.60)],color,36);rotate(ob,math.pi/2,offset=(0,0,.68))
  ell('Ivory dial',(0,-.18,.68),(.53,.04,.53),'cream',32,14)
  ring('Instrument bezel',(0,-.18,.68),.57,.055,'goldLight',rot=(math.pi/2,0,0),segments=32)
  if kind=='compass':flat_symbol('Compass needle',[(-.13,.66),(0,1.14),(.13,.66),(0,.2)],'red',.04,(0,-.23,0),.01)
  else:tube('Clock hand',[(.27,-.23,.68),(0,-.23,.68),(0,-.23,1.02)],.035,'navy',8);ring('Watch loop',(0,0,1.39),.14,.06,'gold',rot=(math.pi/2,0,0),segments=20)
 elif kind=='spyglass':
  for z1,z2,r,c in [(0,.7,.31,'gold'),(.64,1.18,.25,'wood'),(1.12,1.65,.19,'gold'),(1.57,1.78,.24,'navy')]:
   o=lathe('Telescope section',[(z1,r),(z2,r)],c,24);rotate(o,math.pi/2,'Y')
  o=ell('Telescope lens',(0,0,0),(.028,.27,.27),'blue',24,14)
 elif kind=='bell':
  lathe('Ship bell',[(0,.64),(.1,.66),(.23,.49),(.68,.3),(.98,.23),(1.05,.12)],color,32)
  ring('Bell lip',(0,0,.1),.64,.045,'goldLight',segments=32);ring('Bell hanger',(0,0,1.15),.15,.07,'gold',rot=(math.pi/2,0,0))
 elif kind=='lantern':
  box('Lantern foot',(0,0,.13),(.85,.7,.26),color,.08)
  box('Pearl lantern glow',(0,0,.67),(.57,.47,.9),'goldLight',.12)
  for x in [-.35,.35]:
   for y in [-.28,.28]:tube('Lantern frame',[(x,y,.18),(x,y,1.13)],.055,color,10)
  o=lathe('Lantern roof',[(1.08,.52),(1.32,.17)],color,8)
  ring('Lantern handle',(0,0,1.48),.24,.065,color,rot=(math.pi/2,0,0))
 elif kind=='crown':
  lathe('Royal circlet',[(0,.62),(.13,.68),(.40,.66),(.43,.58)],'gold',32)
  for i in range(6):
   a=i*math.tau/6;p=(.60*math.cos(a),.60*math.sin(a),.4)
   tube('Crown point',[p,(p[0]*1.06,p[1]*1.06,.91)],[.15,.025],'gold',10)
   ell('Crown tip',(p[0]*1.06,p[1]*1.06,.91),(.07,.07,.07),'goldLight',12,8)
   ell('Crown gem',(.67*math.cos(a),.67*math.sin(a),.26),(.09,.09,.12),'red' if i%2 else 'blue',10,8)
 elif kind=='chalice':
  lathe('Chalice body',[(0,.49),(.1,.52),(.2,.23),(.66,.12),(.8,.30),(1.1,.47),(1.39,.5),(1.45,.53)],'gold',28)
  ring('Cup engraved lip',(0,0,1.41),.51,.045,'goldLight',segments=28)
  ell('Chalice jewel',(0,-.42,1.02),(.13,.065,.17),'red',12,8)
 elif kind in ['ruby','sapphire','amethyst','aquamarine']:
  ell('Crystal matrix',(0,0,.15),(.68,.55,.18),'sole',20,12)
  n={'ruby':3,'sapphire':4,'amethyst':6,'aquamarine':5}[kind]
  for i in range(n):
   a=i*math.tau/n;r=.3 if i else 0;h=.65+(i%3)*.22
   jewel((r*math.cos(a),r*math.sin(a),h*.45),color,h,4 if kind=='ruby' else 6)
 elif kind=='idol':
  box('Idol base',(0,0,.16),(1.1,.8,.32),'goldDark',.12)
  ell('Idol body',(0,0,.71),(.39,.3,.55),'gold',24,14)
  box('Idol mask',(0,-.08,1.33),(.83,.52,.7),'gold',.18)
  for x in [-.19,.19]:ell('Turquoise idol eye',(x,-.34,1.38),(.10,.025,.10),'teal',14,8)
  for side in [-1,1]:tube('Idol arms',[(side*.28,0,.91),(side*.55,0,.65),(side*.34,-.19,.5)],.10,'gold',12)
 elif kind=='trident':
  tube('Trident shaft',[(0,0,0),(0,0,2.2)],.10,'gold',12)
  tube('Trident crescent',[(-.6,0,2.05),(-.55,0,1.48),(0,0,1.3),(.55,0,1.48),(.6,0,2.05)],.10,'deepTeal',12)
  for x,z in [(-.6,2.07),(0,2.22),(.6,2.07)]:jewel((x,0,z),color,.6,4)
 elif kind=='tablet':
  box('Round tablet',(0,0,.9),(1.35,.38,1.8),'deepTeal',.16)
  for z in [.4,.8,1.2]:tube('Ancient wave glyph',[(-.42,-.21,z),(-.15,-.21,z+.12),(.15,-.21,z),(.43,-.21,z+.12)],.032,'aqua',10)
  jewel((0,-.2,1.54),'gold',.35,4)
 elif kind=='heart':
  shape=[(-.65,1.05),(-.57,1.34),(-.25,1.46),(0,1.22),(.25,1.46),(.57,1.34),(.65,1.05),(.47,.65),(0,.15),(-.47,.65)]
  flat_symbol('Ocean heart crystal',shape,'blue',.5,radius=.07)
  tube('Heart golden setting',[(-.55,-.22,1.02),(-.4,-.24,.67),(0,-.25,.2),(.4,-.24,.67),(.55,-.22,1.02)],.055,'goldLight',10)
 elif kind=='fang':
  tube('Curved obsidian fang',[(.35,0,.08),(.05,0,.27),(-.18,0,.72),(-.22,0,1.25)],[.025,.16,.28,.24],'navy',12)
  ring('Fang golden binding',(-.22,0,1.18),.24,.055,'gold',segments=24)
 finish(before,'Loot__'+ident)

def finish_set(before,name):
 # Environment objects retain a common authored pivot, including height above their floor.
 obs=[o for o in S.objects if o not in before and o.type=='MESH']
 bpy.ops.object.select_all(action='DESELECT')
 for o in obs:o.select_set(True)
 bpy.context.view_layer.objects.active=obs[0];bpy.ops.object.join();o=bpy.context.object;o.name=name
 S.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR');ASSETS.append(o);return o

# Rich silhouettes for repeating vegetation; all stems physically connect to their base.
before=set(S.objects)
ell('Plant base',(0,0,.10),(1.15,.72,.14),'darkGreen',24,12)
for i,(x,y,h) in enumerate([(-.57,0,1.2),(.10,.18,1.7),(.65,-.12,1.05)]):
 tube('Flower stalk',[(x,y,0),(x-.08,y,h*.55),(x,y,h)],.055,'darkGreen',10)
 for side in [-1,1]:ell('Soft flower leaf',(x+side*.24,y+.04*side,h*(.4+.07*side)),(.30,.10,.08),'green',18,10,rot=(.11*side,-side*.4,.17*side))
 for j in range(5):
  a=j*math.tau/5;ell('Hibiscus petal',(x+.25*math.cos(a),y+.25*math.sin(a),h+j*.014),(.3,.19,.09),['coral','pink','goldLight'][i],20,12,rot=(.08*j,.06,a))
 ell('Flower heart',(x,y,h+.035),(.16,.16,.11),'gold',18,12)
finish(before,'Decor__HibiscusPatch')
before=set(S.objects);coral('coral',3.2);finish(before,'Decor__CoralRed')
before=set(S.objects);coral('purple',2.5);finish(before,'Decor__CoralPurple')
before=set(S.objects)
ell('Seagrass foot',(0,0,.10),(.60,.45,.14),'darkGreen',18,10)
for i in range(5):
 a=i*2.4;h=2+(i%3)*.4
 pts=[(.08*math.cos(a),.08*math.sin(a),.05),(.20*math.cos(a),.20*math.sin(a),h*.4),(.5*math.cos(a),.5*math.sin(a),h*.75),(.36*math.cos(a),.36*math.sin(a),h)]
 ob=tube('Ribbon seagrass',pts,[.16,.13,.09,.012],'green' if i%2 else 'teal',8)
finish(before,'Decor__Seagrass')
before=set(S.objects)
ell('Rounded reef boulder',(0,0,1.0),(2.2,1.55,1.1),'sole',32,20)
ell('Embedded smooth stone',(.95,.35,.64),(1.4,1.15,.7),'ice',24,14)
finish(before,'Decor__ReefBoulder')

def interp(points,x):
 for i in range(len(points)-1):
  a,ha=points[i];b,hb=points[i+1]
  if x<=b:
   t=max(0,min(1,(x-a)/(b-a)));return ha+(hb-ha)*(t*t*(3-2*t))
 return points[-1][1]

def island_disc(name,profile,n=192,steps=42):
 radius=profile[-1][0];vs=[(0,0,profile[0][1])];fs=[]
 for j in range(1,steps+1):
  r=radius*j/steps
  for k in range(n):
   a=k*math.tau/n;rr=r*(1+.045*math.sin(3*a+.5)+.025*math.cos(7*a)+.012*math.sin(11*a))
   vs.append((rr*math.cos(a),rr*math.sin(a),interp(profile,r)))
 for k in range(n):fs.append((0,1+k,1+(k+1)%n))
 for j in range(steps-1):
  for k in range(n):a=1+j*n+k;b=1+j*n+(k+1)%n;fs.append((a,a+n,b+n,b))
 start=1+(steps-1)*n;bottom=len(vs);vs.append((0,0,-12))
 for k in range(n):fs.append((start+k,bottom,start+(k+1)%n))
 o=mesh(name,vs,fs,'green' if 'Meadow' in name else 'sand');ASSETS.append(o)
island_disc('Ground__GoldenShore',[(0,5.55),(38,5.55),(62,4.95),(71,3.75),(79,1.5),(86,-.4),(93,-3.4),(101,-8)],steps=44)
island_disc('Ground__Meadow',[(0,6),(35,6),(54,5.92),(60,5.7),(65,5.15),(68,4.52)],steps=26)

def seabed_height(x,z):
 r=math.hypot(x,z);a=math.atan2(z,x);effective=r/(1+.028*math.sin(3*a)+.018*math.cos(5*a))
 h=interp([(0,-2),(82,-1.2),(100,-5.8),(120,-13),(145,-25),(170,-38),(196,-51),(222,-63),(248,-73),(354,-81)],effective)
 h+=math.sin(x*.065)*math.cos(z*.07)*.4
 # Flat, walkable wreck and ruins clearings join the continuous slope.
 for px,pz,level,inner,outer in [(122,100,-30,22,39),(-132,146,-51,14,28)]:
  d=math.hypot(x-px,z-pz);t=max(0,min(1,(d-inner)/(outer-inner)));mix=1-t*t*(3-2*t);h=h*(1-mix)+level*mix
 return h
for sector in range(12):
 vs=[];fs=[];nr=45;na=20
 for j in range(nr+1):
  r=84+(354-84)*j/nr
  for i in range(na+1):
   a=(sector+i/na)*math.tau/12;x=r*math.cos(a);z=r*math.sin(a);vs.append((x,-z,seabed_height(x,z)))
 for j in range(nr):
  for i in range(na):a=j*(na+1)+i;fs.append((a,a+1,a+na+2,a+na+1))
 # A 3-stud closed underside preserves seam heights and gives robust collision.
 count=len(vs);vs.extend([(x,y,z-3) for x,y,z in vs]);fs.extend([tuple(count+i for i in reversed(f)) for f in list(fs)])
 border=list(range(na+1))+[j*(na+1)+na for j in range(1,nr+1)]+list(reversed(range(nr*(na+1),nr*(na+1)+na)))+[j*(na+1) for j in reversed(range(1,nr))]
 for i,a in enumerate(border):b=border[(i+1)%len(border)];fs.append((a,b,b+count,a+count))
 o=mesh('Seabed__Slope_%02d'%sector,vs,fs,'sand');ASSETS.append(o)

# The wreck is an actual open hull, with a cargo floor and a gap to walk through.
for side in [-1,1]:
 before=set(S.objects)
 for row in range(5):
  for seg in range(10):
   if side==1 and seg in [4,5] and row>=1:continue
   y0=-18+seg*3.6;y1=y0+3.57
   def width(y):return 4.2+4.5*math.cos(y/20*math.pi/2)
   z=1+row*.84;points=[(side*(width(y0)-(.7 if row==0 else 0)),y0,z),(side*(width((y0+y1)/2)-(.7 if row==0 else 0)),(y0+y1)/2,z+.08),(side*(width(y1)-(.7 if row==0 else 0)),y1,z)]
   tube('Curved hull plank',points,.46,'wood' if (seg+row)%3 else 'woodLight',8)
 for y in [-16,-10,-4,4,10,16]:tube('Hull rib',[(side*3.8,y,.15),(side*6.5,y,2.4),(side*(4.2+4.5*math.cos(y/20*math.pi/2)),y,4.8)],.25,'woodDark',10)
 finish_set(before,'Ship__HullPort' if side<0 else 'Ship__HullStarboard')
before=set(S.objects)
for j in range(17):
 y=-15+j*1.8;width=7.3 if abs(y)<10 else 5.7
 box('Cargo floor plank',(0,y,.70),(width*2,1.73,.35),'woodLight' if j%3==0 else 'wood',.10)
 # Broken upper deck leaves a generous opening above the chest.
 if abs(y)>7:box('Deck plank',(0,y,5.05),(width*2,1.72,.35),'woodLight',.10)
 else:
  for side in [-1,1]:box('Deck side walkway',(side*5.8,y,5.05),(2.5,1.72,.35),'woodLight',.10)
for side in [-1,1]:
 box('Lower deck stringer',(side*5.5,-.6,.40),(.45,32,.4),'woodDark',.05)
 box('Upper deck stringer',(side*5.8,-.6,4.7),(.45,32,.4),'woodDark',.05)
 for y in [-12,12]:tube('Deck support post',[(side*5.5,y,.4),(side*5.8,y,4.9)],.27,'woodDark',12)
finish_set(before,'Ship__Deck')
before=set(S.objects)
for y in [-17,17]:
 box('Transom',(0,y,3.2),(10,.65,4.2),'wood',.18)
 box('Painted transom trim',(0,y,5.1),(10.8,.85,.45),'deepTeal',.14)
for side in [-1,1]:
 for y in [-15,-9,9,15]:tube('Rail post',[(side*7.1,y,4.8),(side*7.1,y,7)],.18,'woodDark',12)
 for y0,y1 in [(-15,-9),(9,15)]:tube('Hand rail',[(side*7.1,y0,7),(side*7.1,y1,7)],.2,'deepTeal',12)
finish_set(before,'Ship__Railings')
before=set(S.objects)
tube('Broken mast',[(0,-10,.5),(0,-10,11),(1.5,-10,17)],[.62,.45,.25],'woodDark',20)
tube('Yard arm',[(-7,-10,12),(7,-10,12)],.22,'wood',16)
for side in [-1,1]:tube('Mast rigging',[(side*6,-11,5.1),(0,-10,14)],.065,'sand',8)
box('Torn teal sail',(-2,-10.15,10),(3.7,.12,3.4),'deepTeal',.08)
finish_set(before,'Ship__Mast')
before=set(S.objects)
for x,y in [(-3,-12),(3,12),(-5,3)]:
 ob=lathe('Wreck barrel',[(0,.78),(.25,.9),(1.3,1.01),(2.1,.9),(2.3,.78)],'wood',20)
 for v in ob.data.vertices:v.co+=Vector((x,y,.9))
 for h in [1.2,2.7]:ring('Barrel band',(x,y,h),.94,.09,'deepTeal')
finish_set(before,'Ship__Cargo')

# Two independent chest pieces allow a smooth, honest lid-opening animation in Studio.
before=set(S.objects)
box('Chest floor',(0,0,.20),(3.6,2.45,.4),'wood',.13)
for x in [-1.6,1.6]:box('Chest side',(x,0,1.05),(.4,2.45,1.7),'wood',.12)
for y in [-1.02,1.02]:box('Chest wall',(0,y,1.05),(3.3,.4,1.7),'wood',.12)
for x in [-1.12,1.12]:
 for y in [-1.25,1.25]:box('Chest brass upright',(x,y,1.0),(.23,.15,1.85),'gold',.045)
box('Keyhole plate',(0,-1.27,1.47),(.46,.14,.65),'goldLight',.07)
ell('Dark keyhole',(0,-1.35,1.48),(.07,.018,.11),'navy',12,8)
finish_set(before,'Chest__Base')
before=set(S.objects)
box('Rounded lid',(0,0,2.0),(3.65,2.5,.65),'woodLight',.24)
for x in [-1.12,1.12]:box('Lid brass strap',(x,0,2.05),(.24,2.54,.67),'gold',.10)
finish_set(before,'Chest__Lid')

before=set(S.objects)
for side in [-1,1]:
 box('Ruined column base',(side*5,0,.6),(3.2,3,1.2),'sole',.3)
 tube('Ruined carved column',[(side*5,0,1),(side*5,0,9)],[1.15,.95],'ice',20)
 for z in [1.5,7.8]:ring('Column bands',(side*5,0,z),1.1,.15,'teal',segments=24)
tube('Ancient arch',[(-5,0,8),(-4.2,0,10.1),(-2.3,0,11.5),(0,0,12),(2.3,0,11.5),(4.2,0,10.1),(5,0,8)],.9,'ice',14)
jewel((0,-.85,11.8),'gold',1.3,6)
finish_set(before,'Landmark__TideArch')

# Shared flat-color atlas: all models use one material and one small texture.
keys=list(COLORS);img=bpy.data.images.new('DepthPalette',width=128,height=128,alpha=True);pixels=[]
for y in range(128):
 for x in range(128):pixels.extend((*rgb(COLORS[keys[((y//16)*8+x//16)%len(keys)]]),1))
img.pixels.foreach_set(pixels);img.filepath_raw=str(OUT/'DepthPalette.png');img.file_format='PNG';img.save();img.pack()
atlas=bpy.data.materials.new('DepthAtlas');atlas.use_nodes=True;bs=next(n for n in atlas.node_tree.nodes if n.type=='BSDF_PRINCIPLED');bs.inputs['Roughness'].default_value=.60;tex=atlas.node_tree.nodes.new('ShaderNodeTexImage');tex.image=img;tex.interpolation='Closest';atlas.node_tree.links.new(tex.outputs['Color'],bs.inputs['Base Color'])
stats=[]
for ob in ASSETS:
 me=ob.data;uv=me.uv_layers.new(name='UVMap')
 for p in me.polygons:
  idx=keys.index(me.materials[p.material_index].name.removeprefix('P_'))
  for j,li in enumerate(p.loop_indices):a=j*math.tau/len(p.loop_indices);uv.data[li].uv=((idx%8+.5)/8+.012*math.cos(a),(idx//8+.5)/8+.012*math.sin(a))
  p.material_index=0
 me.materials.clear();me.materials.append(atlas)
 bm=bmesh.new();bm.from_mesh(me);bmesh.ops.dissolve_degenerate(bm,edges=list(bm.edges),dist=.000001);bmesh.ops.triangulate(bm,faces=list(bm.faces));bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(me);bm.free()
 me.calc_loop_triangles();stats.append({'name':ob.name,'triangles':len(me.loop_triangles)})
 assert len(me.loop_triangles)<=20000,(ob.name,len(me.loop_triangles))
bpy.context.view_layer.update();S.view_settings.view_transform='Standard'
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'SuckTheSea_Depth.blend'))
(OUT/'manifest.json').write_text(json.dumps({'objects':stats,'total_triangles':sum(x['triangles'] for x in stats),'resources':len(CATALOG)},indent=2))
(OUT/'catalog.json').write_text(json.dumps([dict(zip(['id','name','kind','palette','value','weight','minDepth'],row)) for row in CATALOG],indent=2))
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts');import qa_check
qa={}
for ob in ASSETS:
 qa[ob.name]=qa_check.run(objects=[ob.name],profile='roblox');print('DEPTH_QA',ob.name,qa[ob.name]['errors'],flush=True)
(OUT/'qa.json').write_text(json.dumps(qa,indent=2,default=str))
bpy.ops.export_scene.fbx(filepath=str(OUT/'SuckTheSea_Depth.fbx'),object_types={'MESH'},axis_forward='-Z',axis_up='Y',global_scale=.01,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',mesh_smooth_type='FACE',add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
print('DEPTH_GENERATED',len(ASSETS),sum(x['triangles'] for x in stats),flush=True)
