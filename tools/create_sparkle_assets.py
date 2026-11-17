"""Original sculpted coastal rocks, enamel straws and dimensional simulator icons."""
from pathlib import Path
import bpy,bmesh,math,json,sys,random
import numpy as np
from mathutils import Vector,Matrix,Euler,noise
ROOT=Path(__file__).resolve().parents[1]
source=(ROOT/'tools/create_gameplay_assets.py').read_text(encoding='utf-8')
exec(source[:source.index('# Six tools')])
OUT=ROOT/'assets/sparkle';OUT.mkdir(parents=True,exist_ok=True)
exec(source[source.index("for kind in ['BasicStraw'"):source.index('def shell(')])
comfort=(ROOT/'tools/create_comfort_assets.py').read_text(encoding='utf-8')
exec(comfort[comfort.index("for kind,color in [('CoralTwister'"):comfort.index('def join_unshifted')])

def join_extra(ob,before):
    additions=[x for x in S.objects if x not in before and x.type=='MESH']
    bpy.ops.object.select_all(action='DESELECT');ob.select_set(True)
    for x in additions:x.select_set(True)
    bpy.context.view_layer.objects.active=ob;bpy.ops.object.join()

# Sculpted grip panels, real wall thickness, inset enamel and small polished inlays.
for ob in list(ASSETS):
    before=set(S.objects);kind=ob.name.split('__')[1]
    if kind in ('BasicStraw','ColorfulStraw','BambooStraw','GoldenStraw','CrystalStraw'):
        col={'BasicStraw':'pink','ColorfulStraw':'aqua','BambooStraw':'woodLight','GoldenStraw':'goldLight','CrystalStraw':'white'}[kind]
        rad={'BasicStraw':.09,'ColorfulStraw':.115,'BambooStraw':.135,'GoldenStraw':.13,'CrystalStraw':.145}[kind]
        for z in [.50,.56,.62,.68]:ring('Fine tactile grip',(0,0,z),rad,.012,col,segments=24)
        ring('Polished intake lip',(0,0,.025),rad,.018,col,segments=24)
    if kind=='ColorfulStraw':
        for z,c in [(.85,'pink'),(1.15,'goldLight'),(1.45,'ice'),(1.75,'purple')]:ring('Candy enamel stripe',(0,0,z),.113,.028,c,segments=24)
    if kind=='BambooStraw':
        flat_symbol('Leaf charm',[(-.08,.9),(-.38,1.12),(-.39,1.42),(-.13,1.32)],'green',.065,(0,-.1,0),.035)
        tube('Leaf midrib',[(-.12,-.145,1),(-.32,-.145,1.3)],.012,'goldLight',8)
    if kind=='GoldenStraw':
        for a in range(8):
            angle=a*math.tau/8;ell('Golden inlay',(.135*math.cos(angle),.135*math.sin(angle),.95),(.025,.025,.13),'goldLight',10,6)
    if kind=='Leviathan':
        for a in range(8):
            angle=a*math.tau/8;ell('Flush brass rivet',(.32*math.cos(angle),-.39,1.17+.32*math.sin(angle)),(.026,.022,.026),'goldLight',10,6)
    if kind=='PrismStraw':
        for i,col in enumerate(['pink','goldLight','green','aqua','blue','purple']):
            pts=[(.205*math.cos(i*math.tau/6+t*.4),.205*math.sin(i*math.tau/6+t*.4),.25+t*.095) for t in range(18)]
            tube('Prismatic enamel ribbon',pts,.026,col,8)
    join_extra(ob,before)

before=set(S.objects)
points=[(0,0,z) for z in [0,.25,.5,1,1.5,1.95,2.14]]+[(-.05,0,2.33),(-.23,0,2.45),(-.48,0,2.5),(-.72,0,2.5)]
tube('Royal pearl tube',points,.165,'cream',24,True)
ell('Aurora reactor',(0,0,1.12),(.42,.34,.56),'navy',24,16)
ring('Reactor bezel',(0,-.32,1.12),.29,.065,'goldLight',rot=(math.pi/2,0,0),segments=32)
ell('Prismatic lens',(0,-.37,1.12),(.22,.075,.25),'ice',12,8)
for i,col in enumerate(['red','gold','green','aqua','blue','purple']):
    a=i*math.tau/6
    tube('Aurora ribbon',[(.33*math.cos(a+t*.1),.33*math.sin(a+t*.1),.30+t*.08) for t in range(20)],.042,col,10)
for z in [.20,.48,1.77,2.02]:ring('Royal collar',(0,0,z),.205 if z<.5 else .19,.052,'goldLight',segments=28)
for side in [-1,1]:
    flat_symbol('Royal sweeping wing',[(side*.22,.71),(side*.72,1.05),(side*.59,1.43),(side*.35,1.27)],'gold',.13,radius=.045)
    flat_symbol('Wing enamel',[(side*.35,.9),(side*.60,1.07),(side*.53,1.26)],'aqua' if side<0 else 'pink',.04,(0,-.09,0),.02)
flat_symbol('Crown crest',[(-.24,1.69),(-.29,2.05),(-.12,1.93),(0,2.13),(.12,1.93),(.29,2.05),(.24,1.69)],'goldLight',.1,(0,-.12,0),.024)
finish(before,'Tool__AdminStraw')

# Rounded, asymmetrical rock masses: broad planes, softened shoulders and a stable foot.
COLORS.update({'rock':'98ADA9','rockWarm':'B6B5A4','rockDark':'718E91'})
for key in ['rock','rockWarm','rockDark']:
    m=bpy.data.materials.new('P_'+key);m.diffuse_color=(*rgb(COLORS[key]),1);m.use_nodes=True
    m.node_tree.nodes.get('Principled BSDF').inputs['Base Color'].default_value=(*rgb(COLORS[key]),1);M[key]=m
for idx,(name,shape) in enumerate([('Granite',(4.8,3.9,3.3)),('TideStone',(4.7,3.2,2.7)),('ReefStone',(3.8,3.6,3.7))]):
    before=set(S.objects);o=ell('Sculpted coastal stone',(0,0,0),(1,1,1),'rock',40,24)
    for vert in o.data.vertices:
        q=vert.co.copy();p=Vector(tuple(math.copysign(abs(c)**.9,c) for c in q))
        n=noise.noise_vector(q*1.8+Vector((idx*8,3,7)))
        p.x=(p.x+.18*n.x+.14*math.sin(q.z*3+idx))*(1-.12*q.z)*shape[0]/2;p.y=(p.y+.14*n.y+.09*q.x*q.z)*shape[1]/2
        p.z=(p.z+.12*n.z+.16*q.x-.09*q.y)*shape[2]/2
        p.z=max(-shape[2]*.41,p.z)
        vert.co=p
    o.data.update();o.data.materials.append(M['rockWarm']);o.data.materials.append(M['rockDark'])
    for f in o.data.polygons:
        f.material_index=0
    # Merge flattened bottom's duplicate vertices and clean the support cap.
    bm=bmesh.new();bm.from_mesh(o.data);bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.00001);bmesh.ops.dissolve_degenerate(bm,edges=list(bm.edges),dist=.00001);bm.to_mesh(o.data);bm.free()
    finish(before,'Rock__'+name)

# Icons use thick bevels and clean silhouettes that survive at 40 pixels.
exec(source[source.index('# Icons share'):source.index('# Atlas with')])
old=next(o for o in ASSETS if o.name=='Icon__Ocean');ASSETS.remove(old);bpy.data.objects.remove(old,do_unlink=True)
before=set(S.objects)
outline=[(-.85,.06),(-.82,.32),(-.49,.36),(-.18,.62),(-.09,1.05),(.12,1.42),(.43,1.53),(.76,1.37),(.88,1.07),(.76,.85),(.50,.79),(.34,.95),(.42,1.12),(.57,1.12),(.56,1.23),(.34,1.25),(.17,1.03),(.21,.72),(.55,.47),(.86,.35),(.94,.07)]
flat_symbol('Sculpted curling wave',outline,'blue',.32,radius=.075)
tube('Seafoam curl',[(-.66,-.19,.29),(-.3,-.19,.47),(-.12,-.19,.77),(-.04,-.19,1.12),(.17,-.19,1.43),(.45,-.19,1.48),(.74,-.19,1.30),(.79,-.19,1.06),(.62,-.19,.94),(.47,-.19,1.04)],.065,'white',12)
tube('Turquoise wave base',[(-.72,-.18,.14),(-.35,-.18,.2),(.1,-.18,.12),(.48,-.18,.22),(.78,-.18,.13)],.068,'aqua',12)
finish(before,'Icon__Ocean')
coin=next(o for o in ASSETS if o.name=='Icon__Coin')
for name,count in [('CoinStack',3),('CoinVault',5)]:
    before=set(S.objects)
    for i in range(count):
        o=coin.copy();o.data=coin.data.copy();S.collection.objects.link(o)
        z=.09*math.sin(i*1.1);x=(i-(count-1)/2)*.38;y=i*.13
        tr=Matrix.Translation((x,y,z))@Matrix.Rotation((i-(count-1)/2)*.11,4,'Y')
        for v in o.data.vertices:v.co=tr@v.co
    finish(before,'Icon__'+name)

# Shared original PBR atlas. Variations come from material, not flat vertex colour.
keys=list(COLORS);n=1024;tile=n//8;y,x=np.mgrid[0:tile,0:tile];u=x/tile;v=y/tile
color=np.ones((n,n,4),np.float32);rough=np.ones_like(color);metal=np.zeros_like(color);metal[:,:,3]=1
normal=np.ones_like(color);normal[:,:,:3]=(.5,.5,1)
rng=np.random.default_rng(1706)
for i,key in enumerate(keys):
    isrock=key.startswith('rock');isgold='gold' in key;iswood='wood' in key
    grain=rng.normal(0,.014 if isrock else .002,(tile,tile))
    h=grain+(.013*np.sin(u*33+np.sin(v*19)*3) if isrock else .008*np.sin((u*3+v)*math.tau))
    if isrock:h+=.022*np.sin(u*math.tau*2+np.sin(v*math.tau)*.8)*np.cos(v*math.tau*3)
    if iswood:h+=.024*np.sin(u*98+np.sin(v*9)*2)
    shade=1+h*(1.8 if isrock else 3)
    if isrock:shade*=.86+.23*np.clip(v+.07*np.sin(u*math.tau*3),0,1)
    if key in ['coral','teal','blue','purple','pink','lilac']:
        stripe=(np.cos((u*4+v)*math.tau)>.82)*.055;shade+=stripe
    region=np.s_[i//8*tile:(i//8+1)*tile,i%8*tile:(i%8+1)*tile]
    color[region][:,:,:3]=np.clip(np.array(rgb(COLORS[key]))[None,None,:]*shade[:,:,None],0,1)
    rough[region][:,:,:3]=np.clip((.76 if isrock else .24 if isgold else .4)+h[:,:,None]*.6,0,1)
    if isgold:metal[region][:,:,:3]=.72
    gy,gx=np.gradient(h);nn=np.stack((-gx*2,-gy*2,np.ones_like(h)),2);nn/=np.linalg.norm(nn,axis=2,keepdims=True);normal[region][:,:,:3]=nn*.5+.5
atlas=bpy.data.materials.new('Sparkle_Enamel_Stone');atlas.use_nodes=True;bs=atlas.node_tree.nodes.get('Principled BSDF')
for suffix,pixels,socket in [('Color',color,'Base Color'),('Normal',normal,'Normal'),('Roughness',rough,'Roughness'),('Metalness',metal,'Metallic')]:
    im=bpy.data.images.new('Sparkle_'+suffix,width=n,height=n,alpha=True);im.colorspace_settings.name='sRGB' if suffix=='Color' else 'Non-Color'
    im.pixels.foreach_set(pixels.ravel());im.filepath_raw=str(OUT/('Sparkle_'+suffix+'.png'));im.file_format='PNG';im.save();im.pack()
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
            p=me.vertices[me.loops[li].vertex_index].co
            if ob.name.startswith('Rock__') and abs(f.normal.z)<.8:
                zmax=max(v.co.z for v in me.vertices)
                uu=(math.atan2(p.y,p.x)/math.tau+.5)%1;vv=p.z/max(.01,zmax)
            else:uu=(p[a]*.13+.5)%1;vv=(p[b]*.13+.5)%1
            uv.data[li].uv=((idx%8+.07+.86*uu)/8,(idx//8+.07+.86*vv)/8)
        f.material_index=0
    me.materials.clear();me.materials.append(atlas)
    bm=bmesh.new();bm.from_mesh(me);bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.000001);bmesh.ops.dissolve_degenerate(bm,edges=list(bm.edges),dist=.000001);bmesh.ops.triangulate(bm,faces=list(bm.faces));bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(me);bm.free();me.calc_loop_triangles()
    stats.append({'name':ob.name,'triangles':len(me.loop_triangles),'bounds':[[min(v.co[a] for v in me.vertices) for a in range(3)],[max(v.co[a] for v in me.vertices) for a in range(3)]]})
S.view_settings.view_transform='AgX';bpy.context.view_layer.update()
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'SuckTheSea_Sparkle.blend'))
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts');import qa_check
qa={o.name:qa_check.run(objects=[o.name],profile='roblox') for o in ASSETS}
(OUT/'qa.json').write_text(json.dumps(qa,indent=2,default=str))
(OUT/'manifest.json').write_text(json.dumps({'objects':stats,'triangles':sum(s['triangles'] for s in stats)},indent=2))
errors={k:v['errors'] for k,v in qa.items() if v['errors']};print('QA_ERRORS',errors,flush=True)
if errors:raise RuntimeError('Asset QA failed')
bpy.ops.export_scene.fbx(filepath=str(OUT/'SuckTheSea_Sparkle.fbx'),object_types={'MESH'},axis_forward='-Z',axis_up='Y',global_scale=.01,apply_unit_scale=False,apply_scale_options='FBX_SCALE_NONE',mesh_smooth_type='FACE',add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True)
print('SPARKLE_DONE',len(stats),sum(s['triangles'] for s in stats),flush=True)
