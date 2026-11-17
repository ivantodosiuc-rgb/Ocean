import bpy,bmesh,json
from pathlib import Path
R=Path(__file__).resolve().parents[1];O=R/'assets/surfaces'
bpy.ops.wm.open_mainfile(filepath=str(O/'SuckTheSea_Surfaces-stage.blend'))
o=bpy.data.objects['island__StarterIsland__CompassRay'];bm=bmesh.new();bm.from_mesh(o.data)
for e in bm.edges:
 if len(e.link_faces)==2 and not e.is_contiguous:print('BAD_EDGE',[(v.index,tuple(v.co)) for v in e.verts],[(f.index,[v.index for v in f.verts]) for f in e.link_faces])
