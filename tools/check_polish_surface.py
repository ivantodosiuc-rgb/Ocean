"""Independently check Studio bone positions against rendered Blender geometry."""
import bpy, json
from pathlib import Path
from mathutils import Vector
from mathutils.bvhtree import BVHTree
root=Path(__file__).resolve().parents[1]
log=Path('C:/Users/Administrator/AppData/Local/Roblox/logs/0.747.0.7471481_20261116T163659Z_Studio_94EE7_last.log')
verts=[];faces=[]
for ob in bpy.context.scene.objects:
    if not(ob.name=='Ground__GoldenShore' or ob.name.startswith('Seabed__')):continue
    ob.data.calc_loop_triangles();offset=len(verts)
    for v in ob.data.vertices:
        p=ob.matrix_world@v.co;verts.append((p.x,-p.y,p.z))
    faces.extend(tuple(offset+i for i in tri.vertices) for tri in ob.data.loop_triangles)
bvh=BVHTree.FromPolygons(verts,faces,all_triangles=True)
result={}
for line in log.read_text(encoding='utf-8',errors='replace').splitlines():
    if line[:19]<'2026-11-16T16:54:00':continue
    if '[FLog::CreatorOutput] POLISH_CONTOUR_POINTS ' not in line:continue
    row=json.loads(line.split('POLISH_CONTOUR_POINTS ',1)[1]);level=str(row['level'])
    report=result.setdefault(level,dict(points=0,maximumError=0,minimumGap=100,maximumGap=-100))
    for x,y,z in row['points']:
        hit=bvh.ray_cast(Vector((x,z,12)),Vector((0,0,-1)),110)[0];assert hit is not None
        gap=y-hit.z;report['points']+=1;report['maximumError']=max(report['maximumError'],abs(gap-.075))
        report['minimumGap']=min(report['minimumGap'],gap);report['maximumGap']=max(report['maximumGap'],gap)
assert result
(root/'build/polish-visible-surface-check.json').write_text(json.dumps(result,indent=2))
print('POLISH_VISIBLE_SURFACE_CHECK',json.dumps(result))
assert all(r['maximumError']<.025 for r in result.values()),'Wet band missed rendered terrain'
