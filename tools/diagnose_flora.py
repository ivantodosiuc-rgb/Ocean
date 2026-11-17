import bpy,bmesh,sys
from pathlib import Path
from mathutils.bvhtree import BVHTree
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts')
import qa_check
root=Path(__file__).resolve().parents[1]
bpy.ops.wm.open_mainfile(filepath=str(root/'assets/refresh/SuckTheSea_CharactersFlora.blend'))
o=bpy.data.objects['RefreshFlora__Coral'];bm=bmesh.new();bm.from_mesh(o.data);bm.faces.ensure_lookup_table();bm.verts.ensure_lookup_table()
vs=[v.co.copy() for v in bm.verts];ts=[tuple(v.index for v in f.verts) for f in bm.faces];sets=[set(t) for t in ts];tree=BVHTree.FromPolygons(vs,ts,all_triangles=True)
pairs=set()
for i,t in enumerate(ts):
 a,b,c=[vs[k] for k in t];n=bm.faces[i].normal;cen=(a+b+c)/3
 for p in [cen,cen.lerp(a,.6),cen.lerp(b,.6),cen.lerp(c,.6)]:
  for _,_,j,_ in tree.find_nearest_range(p,.001):
   if j==i or sets[i]&sets[j]:continue
   n2=bm.faces[j].normal
   if n.dot(n2)<.999:continue
   aa,bb,cc=[vs[k] for k in ts[j]];q=p-n2*n2.dot(p-aa)
   if qa_check._point_in_tri(q,aa,bb,cc,n2):pairs.add(tuple(sorted([i,j])))
for pair in pairs:
 print('PAIR',pair)
 for i in pair:
  v=o.data.vertices[ts[i][0]];print('GROUP',[o.vertex_groups[g.group].name for g in v.groups],tuple(bm.faces[i].calc_center_median()),tuple(bm.faces[i].normal))
