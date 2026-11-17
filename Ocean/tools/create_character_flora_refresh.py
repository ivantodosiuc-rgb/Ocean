"""Original sculpted villagers and lush tropical planting for Suck The Sea."""
import bpy,bmesh,math,random,json,sys
from pathlib import Path
from mathutils import Vector,Matrix,Euler
from mathutils.bvhtree import BVHTree
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/refresh';OUT.mkdir(parents=True,exist_ok=True)
SHOTS=ROOT/'build/screenshots';SHOTS.mkdir(parents=True,exist_ok=True)
random.seed(1043)
# Read the authored meadow for precise vegetation grounding, without editing it.
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'assets/SuckTheSea_Island.blend'))
meadow=bpy.data.objects['StarterIsland__Meadow']
surface=BVHTree.FromPolygons([meadow.matrix_world@v.co for v in meadow.data.vertices],[list(p.vertices) for p in meadow.data.polygons])
for ob in list(bpy.data.objects):bpy.data.objects.remove(ob,do_unlink=True)
scene=bpy.context.scene;scene.unit_settings.system='NONE'
COLORS={
 'skinFinn':'F4C192','skinMaya':'DFA478','skinCaptain':'E9B28E','blush':'E89C83',
 'cream':'FFF1D2','white':'FFFDF1','ink':'263C49','brown':'694638','hairFinn':'8B502B','hairLight':'AF6A36','hairMaya':'633F38',
 'teal':'28B9AB','tealDark':'168684','coral':'F88264','denim':'386F8D','denimLight':'6299A8','navy':'294E70','coatLight':'3C7691',
 'gold':'FFC85B','goldLight':'FFE48A','leather':'A76A3C','sole':'694B39','lens':'64D9E0','silver':'C6DEE0',
 'grass':'66CE39','grassLight':'A5E94D','grassMid':'7AD73C','grassShade':'47AB32',
 'leaf':'319B51','leafLight':'65C653','leafDark':'21884F','petalCoral':'FF877D','petalPink':'FFA3A0','petalRed':'F45F73',
 'petalWhite':'FFF6D9','petalYellow':'FFD35E','petalLilac':'BC9BEF','petalPurple':'9371CE'}
def rgb(s):return tuple(int(s[i:i+2],16)/255 for i in (0,2,4))
M={}
for name,color in COLORS.items():
 m=bpy.data.materials.new('REF_'+name);m.diffuse_color=(*rgb(color),1);m.use_nodes=True
 bs=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED');bs.inputs['Base Color'].default_value=(*rgb(color),1);bs.inputs['Roughness'].default_value=.78
 M[name]=m
def mesh(name,verts,faces,color,smooth=True):
 me=bpy.data.meshes.new(name);me.from_pydata(verts,[],faces);me.update()
 ob=bpy.data.objects.new(name,me);scene.collection.objects.link(ob);me.materials.append(M[color])
 for p in me.polygons:p.use_smooth=smooth
 vg=ob.vertex_groups.new(name=name);vg.add(list(range(len(me.vertices))),1,'REPLACE')
 return ob
def ell(name,pos,size,color,seg=16,rings=10,rot=None):
 bm=bmesh.new();bmesh.ops.create_uvsphere(bm,u_segments=seg,v_segments=rings,radius=1)
 tr=Matrix.Translation(Vector(pos))@(Euler(rot).to_matrix().to_4x4() if rot else Matrix.Identity(4))@Matrix.Diagonal((*size,1))
 bmesh.ops.transform(bm,matrix=tr,verts=list(bm.verts));me=bpy.data.meshes.new(name);bm.to_mesh(me);bm.free()
 ob=bpy.data.objects.new(name,me);scene.collection.objects.link(ob);me.materials.append(M[color])
 for p in me.polygons:p.use_smooth=True
 vg=ob.vertex_groups.new(name=name);vg.add(list(range(len(me.vertices))),1,'REPLACE');return ob
def tube(name,points,radii,color,sides=10):
 pts=[Vector(p) for p in points];vs=[];fs=[];closed=(pts[0]-pts[-1]).length<.000001;previous_u=None
 if closed:pts=pts[:-1]
 for i,p in enumerate(pts):
  tangent=(pts[(i+1)%len(pts)]-pts[(i-1)%len(pts)]).normalized() if closed else (pts[min(i+1,len(pts)-1)]-pts[max(0,i-1)]).normalized()
  ref=Vector((0,0,1)) if abs(tangent.z)<.9 else Vector((0,1,0))
  u=(previous_u-tangent*previous_u.dot(tangent)).normalized() if previous_u is not None else tangent.cross(ref).normalized()
  if u.length<.1:u=tangent.cross(ref).normalized()
  v=tangent.cross(u).normalized();previous_u=u
  r=radii[i] if isinstance(radii,(tuple,list)) else radii
  for j in range(sides):vs.append(tuple(p+r*(u*math.cos(j*math.tau/sides)+v*math.sin(j*math.tau/sides))))
 for i in range(len(pts) if closed else len(pts)-1):
  ni=(i+1)%len(pts)
  for j in range(sides):fs.append((i*sides+j,i*sides+(j+1)%sides,ni*sides+(j+1)%sides,ni*sides+j))
 if not closed:fs.extend([tuple(reversed(range(sides))),tuple((len(pts)-1)*sides+j for j in range(sides))])
 return mesh(name,vs,fs,color)
def loft(name,rings,color,sides=20):
 vs=[];fs=[]
 for z,rx,ry,cy in rings:
  for j in range(sides):a=j*math.tau/sides;vs.append((rx*math.cos(a),cy+ry*math.sin(a),z))
 for i in range(len(rings)-1):
  for j in range(sides):fs.append((i*sides+j,i*sides+(j+1)%sides,(i+1)*sides+(j+1)%sides,(i+1)*sides+j))
 fs.extend([tuple(reversed(range(sides))),tuple((len(rings)-1)*sides+j for j in range(sides))])
 return mesh(name,vs,fs,color)
def ring(name,pos,rx,ry,r,color,sides=24):
 pts=[(pos[0]+rx*math.cos(i*math.tau/sides),pos[1]+ry*math.sin(i*math.tau/sides),pos[2]) for i in range(sides+1)]
 return tube(name,pts,r,color,6)
def join_since(before,name,location=(0,0,0)):
 obs=[o for o in scene.objects if o not in before and o.type=='MESH']
 bpy.ops.object.select_all(action='DESELECT')
 for o in obs:o.select_set(True)
 bpy.context.view_layer.objects.active=obs[0];bpy.ops.object.join();o=bpy.context.object;o.name=name
 scene.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR');o.location=location;return o
def smile(skin,eyes='tealDark',beard=False):
 ell('Soft cheek and jaw',(0,0,5.22),(.94,.77,.94),skin,24,16)
 for side in [-1,1]:
  ell('Ear',(side*.92,.015,5.21),(.19,.21,.29),skin)
  ell('Inner ear',(side*1.035,-.105,5.21),(.06,.075,.16),'blush',12,8)
  ell('Eye white',(side*.34,-.707,5.39),(.225,.12,.275),'white',16,10)
  ell('Iris',(side*.34,-.811,5.38),(.116,.055,.163),eyes,16,10)
  ell('Pupil',(side*.34,-.852,5.38),(.065,.026,.103),'ink',12,8)
  ell('Eye sparkle',(side*.34-.027,-.871,5.44),(.036,.018,.044),'white',10,6)
  brow='cream' if beard else 'hairMaya'
  points=[(side*.17,-.646,5.76),(side*.34,-.661,5.80),(side*.53,-.58,5.75)]
  tube('Expressive eyebrow',points,.058,brow,8)
  if not beard:ell('Warm cheek',(side*.54,-.622,5.04),(.145,.043,.085),'blush',12,8)
 ell('Rounded nose',(0,-.783,5.17),(.145,.16,.17),skin,16,10)
 tube('Friendly curved smile',[(-.25,-.708,4.97),(-.13,-.75,4.9),(0,-.765,4.885),(.13,-.75,4.9),(.25,-.708,4.97)],.033,'brown',6)
def hands(name,p,skin):
 ell(name,p,(.255,.235,.29),skin)
 ell(name+' thumb',(p[0]-.16 if p[0]>0 else p[0]+.16,p[1]-.08,p[2]+.05),(.13,.17,.18),skin,12,8)
def clothing_front(name,zs,widths,depths,color,spread=.7):
 vs=[];fs=[];n=10
 for z,w,dep in zip(zs,widths,depths):
  for i in range(n+1):a=(i/n-.5)*2*spread;vs.append((w*math.sin(a),-dep*math.cos(a),z))
 for j in range(len(zs)-1):
  for i in range(n):k=j*(n+1)+i;fs.append((k,k+1,k+n+2,k+n+1))
 ob=mesh(name,vs,fs,color);bpy.context.view_layer.objects.active=ob
 md=ob.modifiers.new('Cloth thickness','SOLIDIFY');md.thickness=.065;md.offset=-1;bpy.ops.object.modifier_apply(modifier=md.name);return ob
def build_npc(name,variant,x):
 before=set(scene.objects);skin={'Finn':'skinFinn','Maya':'skinMaya','CaptainShell':'skinCaptain'}[name]
 wide=1.13 if variant=='captain' else 1
 # Rounded boots and shaped trouser legs, with a relaxed asymmetric stance.
 for s in [-1,1]:
  ell('Rounded boot sole',(s*.47,-.18,.14),(.43,.64,.14),'sole')
  ell('Sculpted boot',(s*.47,-.17,.37),(.415,.61,.32),'gold' if variant=='maya' else 'leather')
  tube('Shaped trouser leg',[(s*.47,0,.55),(s*.48,.025,1.15),(s*.43,.01,1.85),(s*.39,0,2.7)],[.31,.34,.35,.38],'denim',12)
  ell('Trouser cuff',(s*.47,0,.78),(.34,.34,.17),'denimLight')
 shirt='navy' if variant=='captain' else 'coral' if variant=='maya' else 'teal'
 loft('Tailored rounded torso',[(2.38,.68*wide,.44,0),(2.56,.84*wide,.51,0),(3,.91*wide,.55,0),(3.55,.94*wide,.55,0),(3.97,.85*wide,.47,0),(4.2,.68*wide,.37,0),(4.33,.33,.29,0)],shirt)
 tube('Neck',[(0,0,4.15),(0,0,4.7)],[.3,.28],skin,16)
 # Arms are bent organic tubes with rounded sleeves and sculpted hands.
 for s in [-1,1]:
  shoulder=(s*.78*wide,0,4.0);elbow=(s*1.2*wide,-.055,3.55)
  end=(s*1.27*wide,-.24,2.96)
  if variant=='maya' and s==1:elbow=(1.35,-.08,3.65);end=(1.55,-.42,4.0)
  if variant=='finn' and s==1:elbow=(1.3,-.12,3.48);end=(1.35,-.56,3.22)
  tube('Rolled sleeve',[shoulder,((shoulder[0]+elbow[0])*.5,-.02,3.83),elbow],[.37,.36,.30],shirt,12)
  ell('Rounded shoulder',(s*.84*wide,-.015,3.99),(.39,.355,.41),shirt,16,10)
  ell('Sleeve roll',elbow,(.32,.31,.22),'cream' if variant!='captain' else 'gold')
  tube('Forearm',[elbow,((elbow[0]+end[0])*.5,-.19,(elbow[2]+end[2])*.5),end],[.255,.24,.20],skin,12)
  hands('Hand',end,skin)
 if variant=='finn':
  clothing_front('Linen apron',[2.55,2.65,3.4,3.85],[.84,.86,.94,.88],[.57,.59,.62,.56],'cream')
  for s in [-1,1]:tube('Apron strap',[(s*.5,-.54,3.65),(s*.55,-.42,4.02),(s*.45,-.24,4.24)],.085,'cream',8)
  ell('Apron pocket',(0,-.59,2.98),(.38,.065,.23),'tealDark')
  ell('Shell badge',(0,-.565,3.58),(.17,.055,.19),'coral')
 elif variant=='maya':
  clothing_front('Overalls bib',[2.44,2.65,3.45,3.78],[.72,.85,.94,.90],[.52,.58,.61,.57],'tealDark')
  for s in [-1,1]:
   tube('Overall strap',[(s*.53,-.54,3.5),(s*.55,-.42,4.02),(s*.45,-.24,4.24)],.105,'tealDark',8)
   ell('Brass fastening',(s*.52,-.515,3.68),(.085,.045,.085),'gold',10,6)
  ell('Tool pouch',(-.84,-.25,2.7),(.32,.35,.43),'leather')
  tube('Spanner grip',[(1.55,-.43,3.96),(1.61,-.47,4.58)],[.1,.11],'silver',10)
  tube('Open spanner head',[(1.45,-.47,4.89),(1.36,-.47,4.68),(1.52,-.47,4.56),(1.75,-.47,4.64),(1.77,-.47,4.88)],.11,'silver',8)
 else:
  clothing_front('Cream shirt insert',[2.75,3.4,4.12],[1.02,1.05,.73],[.62,.63,.49],'cream',.38)
  for s in [-1,1]:
   tube('Gold coat piping',[(s*.70,-.47,2.47),(s*.72,-.56,3.0),(s*.56,-.52,3.8),(s*.37,-.28,4.23)],.055,'gold',8)
   for z in [2.85,3.15,3.45]:ell('Coat button',(s*.52,-.49,z),(.07,.05,.07),'gold',10,6)
  ell('Neckerchief knot',(0,-.45,4.18),(.22,.16,.19),'coral')
  tube('Neckerchief tail',[(0,-.46,4.16),(.14,-.58,3.9),(.17,-.58,3.72)],[.16,.12,.035],'coral',8)
 smile(skin,'tealDark' if variant=='finn' else 'brown' if variant=='captain' else 'coatLight',variant=='captain')
 if variant!='captain':
  hair='hairFinn' if variant=='finn' else 'hairMaya'
  loft('Sculpted hair cap',[(5.62,.9,.71,.07),(5.88,.83,.66,.07),(6.10,.57,.49,.06),(6.22,.08,.08,.05)],hair)
  for j in range(4):
   ell('Swept fringe',(-.58+j*.35,-.58,5.82+(.07 if j==2 else 0)),(.31,.22,.29),hair,14,8,rot=(0,.25-j*.17,-.16))
  for s in [-1,1]:ell('Temple curl',(s*.84,-.11,5.5),(.18,.31,.35),hair,14,8)
 if variant=='finn':
  loft('Fisher bucket hat',[(6.05,.87,.7,.08),(6.24,.93,.76,.08),(6.59,.75,.63,.08),(6.67,.63,.55,.08)],'teal')
  ell('Soft hat brim',(0,.04,6.13),(1.18,.99,.12),'tealDark',24,8)
  ring('Hat ribbon',(0,.08,6.27),.907,.737,.065,'cream')
  ell('Hat shell pin',(.34,-.65,6.43),(.16,.075,.17),'gold',12,8)
  # A little striped drink is held securely in his right hand.
  cup=loft('Drink cup',[(2.94,.22,.22,0),(3.55,.29,.29,0)],'coral',16);cup.location=(1.55,-.67,0)
  ring('Cup rim',(1.55,-.67,3.55),.29,.29,.045,'cream',16)
  tube('Bendy straw',[(1.55,-.67,3.45),(1.55,-.67,3.95),(1.79,-.67,4.1)],.045,'cream',8)
 elif variant=='maya':
  for j in range(3):ell('Ponytail curl',(.91+j*.07,.31,5.5-j*.37),(.45-j*.06,.44, .5),'hairMaya',16,10,rot=(0,.24,0))
  ell('Ponytail tie',(.9,.2,5.72),(.45,.45,.12),'coral')
  for s in [-1,1]:
   ell('Goggle rim',(s*.34,-.63,5.99),(.28,.13,.25),'gold')
   ell('Goggle lens',(s*.34,-.738,5.99),(.2,.045,.175),'lens',16,10)
   ell('Goggle shine',(s*.39,-.774,6.04),(.08,.015,.03),'white',10,6,rot=(0,0,.3))
  tube('Goggle bridge',[(-.10,-.69,6),(0,-.71,6.02),(.1,-.69,6)],.055,'gold',8)
 else:
  for s in [-1,1]:
   ell('Silver side hair',(s*.83,.09,5.38),(.27,.52,.55),'cream')
   ell('Beard cheek',(s*.46,-.46,4.83),(.4,.38,.48),'cream',18,12,rot=(0,s*.3,0))
   ell('Curled moustache',(s*.23,-.793,5.0),(.31,.14,.16),'white',18,10,rot=(0,s*.2,s*.12))
  ell('Soft pointed beard',(0,-.46,4.53),(.47,.36,.42),'cream',20,12)
  loft('Tricorn crown',[(5.98,.84,.68,.08),(6.29,.91,.72,.08),(6.72,.69,.6,.08),(6.89,.3,.28,.08)],'navy')
  vs=[];fs=[];n=36
  for inner,zoff in [(True,0),(False,0),(True,-.12),(False,-.12)]:
   for j in range(n):
    a=j*math.tau/n;r=.64 if inner else 1.34+.22*math.cos(3*a+math.pi/2)
    z=6.12 if inner else 6.28+.30*(.5+.5*math.cos(3*a+math.pi/2))
    vs.append((r*math.cos(a),.08+r*.82*math.sin(a),z+zoff))
  for j in range(n):
   k=(j+1)%n;fs.extend([(j,k,n+k,n+j),(2*n+j,3*n+j,3*n+k,2*n+k),(j,2*n+j,2*n+k,k),(n+j,n+k,3*n+k,3*n+j)])
  mesh('Sculpted tricorn brim',vs,fs,'navy')
  tube('Golden tricorn trim',[(*vs[n+j][:2],vs[n+j][2]+.025) for j in range(n)]+[(*vs[n][:2],vs[n][2]+.025)],.045,'gold',6)
  ell('Hat medallion',(0,-.625,6.56),(.22,.065,.24),'gold')
  for k in range(5):ell('Shell crest',((k-2)*.056,-.682,6.57),(.033,.025,.14-.022*abs(k-2)),'cream',10,6,rot=(0,(k-2)*.15,0))
 ob=join_since(before,'RefreshNPC__'+name,(x,0,0));return ob

npcs=[build_npc('Finn','finn',-5.5),build_npc('Maya','maya',0),build_npc('CaptainShell','captain',5.5)]

# Thick curved petals and leaves. Every blade is closed geometry, not a billboard.
def petal(name,base,angle,length,width,rise,color,steps=6):
 vs=[];fs=[];ca,sa=math.cos(angle),math.sin(angle)
 for bottom in [False,True]:
  for j in range(steps+1):
   t=j/steps;w=max(.018,width*math.sin(math.pi*t)**.75)
   for q in [-1,0,1]:
    u=length*t;v=q*w;z=rise*t+.18*math.sin(math.pi*t)+.12*q*q*math.sin(math.pi*t)-(.035 if bottom else 0)
    vs.append((base[0]+ca*u-sa*v,base[1]+sa*u+ca*v,base[2]+z))
 n=(steps+1)*3
 for j in range(steps):
  for q in range(2):
   k=j*3+q;fs.extend([(k,k+1,k+4,k+3),(n+k+3,n+k+4,n+k+1,n+k)])
 border=[j*3 for j in range(steps+1)]+[steps*3+1]+[j*3+2 for j in reversed(range(steps+1))]+[1]
 for j,k in enumerate(border):kk=border[(j+1)%len(border)];fs.append((k,kk,n+kk,n+k))
 return mesh(name,vs,fs,color)
def flower_bed(kind):
 before=set(scene.objects)
 for i in range(7):
  a=i*math.tau/7;petal('Curved tropical leaf',(0,0,.08+i*.012),a,1.5+(i%3)*.18,.32,.18 if i%2 else .45,'leafLight' if i%3==0 else 'leaf',5)
 blossom=[(-.48,-.12,1.15),(.58,.27,.85)] if kind=='Coral' else [(-.58,-.15,.85),(.53,-.10,1.17),(.03,.65,.98)]
 for i,(x,y,z) in enumerate(blossom):
  tube('Living stem',[(0,0,.05),(x*.6,y*.6,z*.55),(x,y,z)],[.065,.06,.045],'leafDark',8)
  ell('Flower heart',(x,y,z+.06),(.2,.2,.12),'petalYellow',12,8)
  for k in range(5):
   color=('petalCoral' if k%2 else 'petalPink') if kind=='Coral' else 'petalWhite' if kind=='Cream' else ('petalLilac' if k%2 else 'petalPurple')
   petal('Sculpted flower petal',(x,y,z),k*math.tau/5+i*.3,.78 if kind=='Coral' else .61,.36 if kind=='Coral' else .31,.06,color,6)
  if kind=='Coral':
   tube('Hibiscus stamen',[(x,y,z),(x+.13,y-.08,z+.55)],[.04,.025],'gold',8)
   for k in range(3):ell('Pollen',(x+.13+math.cos(k*2.1)*.06,y-.08+math.sin(k*2.1)*.06,z+.55),(.06,.06,.06),'goldLight',8,6)
 return join_since(before,'RefreshFlora__'+kind)
flowers=[flower_bed(k) for k in ['Coral','Cream','Lilac']]

# Scatter lawn in spatial chunks, respecting all walkways, the plaza and shop decks.
paths=[[(-14,-5),(-26,-9),(-38,-6)],[(7,-14),(14,-25),(25,-30)],[(15,5),(29,11),(46,24)],[(0,15),(-3,34),(1,52),(0,70)]]
def segment_distance(x,z,a,b):
 dx,dz=b[0]-a[0],b[1]-a[1];t=max(0,min(1,((x-a[0])*dx+(z-a[1])*dz)/(dx*dx+dz*dz)))
 return math.hypot(x-a[0]-t*dx,z-a[1]-t*dz)
def allowed(x,z):
 if x*x+z*z<19.3**2:return False
 for path in paths:
  for a,b in zip(path,path[1:]):
   if segment_distance(x,z,a,b)<4.8:return False
 for xx,zz,angle in [(-41,-21,12),(27,-43,-23),(49,13,-65)]:
  a=math.radians(angle);dx=x-xx;dz=z-zz;lx=math.cos(a)*dx-math.sin(a)*dz;lz=math.sin(a)*dx+math.cos(a)*dz
  if abs(lx)<14 and -11<lz<15:return False
 for xx,zz in [(-37,-7),(21,-28),(36.5,20)]:
  if math.hypot(x-xx,z-zz)<4:return False
 return True
chunks={};grass_clumps=0
for ix in range(-23,24):
 for iz in range(-23,24):
  x=ix*2.8+random.uniform(-.85,.85);z=iz*2.8+random.uniform(-.85,.85)
  if random.random()>.82 or not allowed(x,z):continue
  hit=surface.ray_cast(Vector((x,-z,30)),Vector((0,0,-1)))
  if hit[0] is None or hit[0].z<5.35:continue
  ground=hit[0].z-.045;key=(math.floor((x+72)/24),math.floor((z+72)/24));vs,fs,cs=chunks.setdefault(key,([],[],[]))
  grass_clumps+=1
  for blade in range(4):
   a=random.random()*math.tau;h=random.uniform(.42,.92);w=random.uniform(.09,.16);lean=random.uniform(.15,.42)
   bx=x+random.uniform(-.24,.24);by=-z+random.uniform(-.24,.24);c=math.cos(a);s=math.sin(a)
   outline=[(-w,0,0),(w,0,0),(w*.65,lean*.35,h*.5),(0,lean,h),(-w*.65,lean*.35,h*.5)]
   off=len(vs)
   for back in [0,.018]:
    for px,py,pz in outline:vs.append((bx+c*px-s*py,by+s*px+c*py+back,ground+pz))
   faces=[(0,1,2),(0,2,4),(2,3,4),(5,7,6),(5,9,7),(7,9,8)]+[(j,(j+1)%5,(j+1)%5+5,j+5) for j in range(5)]
   fs.extend([tuple(off+i for i in f) for f in faces]);cs.extend([random.choice(['grass','grassMid','grassLight'])]*len(faces))
grass=[]
for (gx,gz),(vs,fs,cs) in chunks.items():
 ob=mesh(f'RefreshGrass__Patch_{gx}_{gz}',vs,fs,'grass',False)
 ob.data.materials.clear()
 for c in ['grass','grassMid','grassLight']:ob.data.materials.append(M[c])
 for p,c in zip(ob.data.polygons,cs):p.material_index=['grass','grassMid','grassLight'].index(c)
 grass.append(ob)

# One color atlas shared by the whole refresh, with valid nonzero-area UVs.
keys=list(COLORS);size=128;img=bpy.data.images.new('RefreshPalette',width=size,height=size,alpha=True)
pixels=[]
for y in range(size):
 for x in range(size):pixels.extend((*rgb(COLORS[keys[((y//16)*8+x//16)%len(keys)]]),1))
img.pixels.foreach_set(pixels);img.filepath_raw=str(OUT/'RefreshPalette.png');img.file_format='PNG';img.save();img.pack()
atlas=bpy.data.materials.new('Refresh_ColorAtlas');atlas.use_nodes=True
bs=next(n for n in atlas.node_tree.nodes if n.type=='BSDF_PRINCIPLED');bs.inputs['Roughness'].default_value=.8
tex=atlas.node_tree.nodes.new('ShaderNodeTexImage');tex.image=img;tex.interpolation='Closest';atlas.node_tree.links.new(tex.outputs['Color'],bs.inputs['Base Color'])
stats=[]
for ob in list(scene.objects):
 if ob.type!='MESH':continue
 me=ob.data;uv=me.uv_layers.new(name='UVMap')
 for p in me.polygons:
  color=me.materials[p.material_index].name.removeprefix('REF_');idx=keys.index(color)
  for j,li in enumerate(p.loop_indices):
   a=j*math.tau/len(p.loop_indices);uv.data[li].uv=((idx%8+.5)/8+.013*math.cos(a),(idx//8+.5)/8+.013*math.sin(a))
  p.material_index=0
 me.materials.clear();me.materials.append(atlas)
 bm=bmesh.new();bm.from_mesh(me)
 bmesh.ops.dissolve_degenerate(bm,edges=list(bm.edges),dist=.000001)
 bmesh.ops.triangulate(bm,faces=list(bm.faces));bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(me);bm.free()
 me.calc_loop_triangles();stats.append({'name':ob.name,'triangles':len(me.loop_triangles)})
bpy.context.view_layer.update()
scene.view_settings.view_transform='Standard'
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'SuckTheSea_CharactersFlora.blend'))
bpy.ops.export_scene.fbx(filepath=str(OUT/'SuckTheSea_Refresh.fbx'),use_selection=False,object_types={'MESH'},axis_forward='-Z',axis_up='Y',global_scale=.01,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',mesh_smooth_type='FACE',use_mesh_modifiers=True,add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
(OUT/'manifest.json').write_text(json.dumps({'objects':stats,'total_triangles':sum(x['triangles'] for x in stats),'grass_clumps':grass_clumps,'npc_origins':{'Finn':[-5.5,0,0],'Maya':[0,0,0],'CaptainShell':[5.5,0,0]}},indent=2))
print('REFRESH_CREATED',len(stats),sum(x['triangles'] for x in stats),'GRASS_CLUMPS',grass_clumps,flush=True)
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts')
import qa_check
qa={}
for ob in npcs+flowers:
 qa[ob.name]=qa_check.run(objects=[ob.name],profile='roblox')
 print('QA',ob.name,qa[ob.name]['errors'],flush=True)
(OUT/'qa.json').write_text(json.dumps(qa,default=str,indent=2))
# Preview-only studio; do not write lighting/cameras into the export source.
for ob in flowers+grass:ob.hide_render=True
world=bpy.data.worlds.new('Preview daylight');world.use_nodes=True;world.node_tree.nodes.get('Background').inputs[0].default_value=(.36,.55,.62,1);world.node_tree.nodes.get('Background').inputs[1].default_value=.65;scene.world=world
bpy.ops.mesh.primitive_plane_add(size=200);floor=bpy.context.object;floor.data.materials.append(M['cream'])
sun_data=bpy.data.lights.new('Soft key','AREA');sun_data.energy=1400;sun_data.shape='DISK';sun_data.size=10
sun=bpy.data.objects.new('Soft key',sun_data);scene.collection.objects.link(sun);sun.location=(-4,-9,13);sun.rotation_euler=(Vector((0,0,3))-sun.location).to_track_quat('-Z','Y').to_euler()
camdata=bpy.data.cameras.new('Character preview');cam=bpy.data.objects.new('Character preview',camdata);scene.collection.objects.link(cam);cam.location=(10,-35,13);target=Vector((0,0,3.3));cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler();camdata.type='ORTHO';camdata.ortho_scale=17.5;scene.camera=cam
scene.render.engine='CYCLES';scene.cycles.samples=24;scene.cycles.use_denoising=True;scene.render.resolution_x=1600;scene.render.resolution_y=1100;scene.render.resolution_percentage=100
scene.view_settings.view_transform='AgX';scene.render.filepath=str(SHOTS/'refresh-npcs-blender.png');bpy.ops.render.render(write_still=True)
print('REFRESH_PREVIEW_DONE',flush=True)
