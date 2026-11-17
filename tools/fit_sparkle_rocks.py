import bpy,json,math
import numpy as np
from pathlib import Path
from mathutils import Vector,Matrix
from mathutils.bvhtree import BVHTree
R=Path(__file__).resolve().parents[1];O=R/'assets/sparkle'
rows=json.loads((O/'rock-inventory.json').read_text());verts=[];faces=[]
bpy.ops.wm.open_mainfile(filepath=str(R/'assets/depth/SuckTheSea_Depth.blend'))
bpy.context.view_layer.update()
for o in bpy.context.scene.objects:
 if o.type!='MESH' or not o.name.startswith(('Ground__','Seabed__')):continue
 o.data.calc_loop_triangles();k=len(verts);points=[o.matrix_world@v.co for v in o.data.vertices]
 verts.extend((p.x,p.z,-p.y) for p in points);faces.extend(tuple(k+i for i in t.vertices) for t in o.data.loop_triangles)
ground=BVHTree.FromPolygons(verts,faces,all_triangles=True)
bpy.ops.wm.open_mainfile(filepath=str(O/'SuckTheSea_Sparkle.blend'))
names=['Granite','TideStone','ReefStone'];result=[]
for i,row in enumerate(rows):
 name=names[i%3];o=bpy.data.objects['Rock__'+name];v=np.array([p.co[:] for p in o.data.vertices]);lo=v.min(0);hi=v.max(0)
 cf=np.array(row['cf']);oldrot=cf[3:].reshape(3,3);oldsize=np.array(row['size'])
 upright=abs(oldrot[1,1])>.8
 size=np.array([oldsize[0],oldsize[1] if upright else oldsize[2],oldsize[2] if upright else oldsize[1]])
 yaw=math.atan2(-oldrot[2,0],oldrot[0,0])+math.pi
 rot=np.array([[math.cos(yaw),0,math.sin(yaw)],[0,1,0],[-math.sin(yaw),0,math.cos(yaw)]])
 q=v-(lo+hi)/2;q=q[:,[0,2,1]];q[:,0]*=-1;q*=size/(hi-lo)[[0,2,1]]
 world=q@rot.T+cf[:3]
 low=world[:,1].min();feet=world[world[:,1]<low+.16];gaps=[]
 for p in feet:
  hit=ground.ray_cast(Vector((p[0],30,p[2])),Vector((0,-1,0)),150)[0]
  if hit is not None:gaps.append(float(p[1]-hit.y))
 assert gaps,row['path'];dy=-max(gaps)-.08
 assert abs(dy)<10,(row['path'],dy)
 pos=cf[:3].copy();pos[1]+=dy
 result.append({'path':row['path'],'source':name,'cf':pos.tolist()+rot.flatten().tolist(),'size':size.tolist(),'deltaY':dy,'footSamples':len(gaps),'maxGap':max(gaps)+dy})
(O/'rock-fit.json').write_text(json.dumps(result,indent=2))
print('FITTED',len(result),'MAX_DELTA',max(abs(x['deltaY']) for x in result),flush=True)
