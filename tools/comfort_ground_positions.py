import bpy,json
from pathlib import Path
from mathutils import Vector
from mathutils.bvhtree import BVHTree
ROOT=Path(__file__).resolve().parents[1]
def tree(names):
 verts=[];faces=[]
 for ob in bpy.context.scene.objects:
  if not any(ob.name.startswith(n) for n in names):continue
  ob.data.calc_loop_triangles();offset=len(verts)
  for v in ob.data.vertices:
   p=ob.matrix_world@v.co;verts.append((p.x,-p.y,p.z))
  faces.extend(tuple(offset+i for i in tri.vertices) for tri in ob.data.loop_triangles)
 return BVHTree.FromPolygons(verts,faces,all_triangles=True)
ground=tree(['Ground__']);grass=tree(['Ground__Meadow'])
def point(x,z):
 p=ground.ray_cast(Vector((x,z,20)),Vector((0,0,-1)),40)[0];assert p is not None;return [x,round(p.z,5),z]
plants=[[-42,34],[-40,33], [36,43],[37.7,42.3], [54,-27],[55.7,-27.7],[-28,-36],[-30,-35],[-11,-48],[3,-40],[15,-28],[27,-20],[39,-9],[38,27],[26,39],[6,42],[-15,37],[-38,10]]
for x,z in plants:
 for dx,dz in [(0,0),(2.5,0),(-2.5,0),(0,2.5),(0,-2.5)]:assert grass.ray_cast(Vector((x+dx,z+dz,20)),Vector((0,0,-1)),30)[0] is not None,(x,z)
mussels=[[-14,63],[-18,65],[-23,62],[-31,61],[-42,57],[-51,50],[22,64],[28,62],[39,57],[51,48],[-64,14],[-65,8],[65,-10],[64,-17],[-21,-62],[-28,-61]]
data={'plants':[point(x,z) for x,z in plants],'mussels':[point(x,z) for x,z in mussels],'booth':point(-43,24)}
(ROOT/'build/comfort-ground.json').write_text(json.dumps(data,indent=2));print('COMFORT_GROUND',data,flush=True)
