import bpy, json, xml.etree.ElementTree as ET
from pathlib import Path
from collections import Counter
R=Path(__file__).resolve().parents[1]
O=R/'assets/surfaces'; O.mkdir(parents=True,exist_ok=True)
sources={ 'island':'assets/SuckTheSea_Island.blend', 'depth':'assets/depth/SuckTheSea_Depth.blend', 'polish':'assets/polish/SuckTheSea_VisualPolish.blend', 'comfort':'assets/comfort/SuckTheSea_Comfort.blend'}
report={}
for family,path in sources.items():
 bpy.ops.wm.open_mainfile(filepath=str(R/path))
 rows=[]
 for ob in bpy.context.scene.objects:
  if ob.type!='MESH':continue
  vs=[ob.matrix_world@v.co for v in ob.data.vertices]
  lo=[min(v[k] for v in vs) for k in range(3)];hi=[max(v[k] for v in vs) for k in range(3)]
  ob.data.calc_loop_triangles()
  rows.append(dict(name=ob.name,lo=lo,hi=hi,size=[hi[k]-lo[k] for k in range(3)],triangles=len(ob.data.loop_triangles),groups=[g.name for g in ob.vertex_groups],materials=[m.name for m in ob.data.materials],uv=len(ob.data.uv_layers)))
 report[family]=rows
 print(family,len(rows),','.join(r['name'] for r in rows),flush=True)
(O/'source-inventory.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
tree=ET.parse(R/'build/SuckTheSea.rbxlx');rows=[]
def walk(e,path=''):
 n=e.findtext('./Properties/string[@name="Name"]') or e.get('class','');path=path+'.'+n if path else n
 if e.get('class')=='MeshPart':
  p=e.find('Properties');props={c.get('name'):c for c in p}
  def vector(k):return [float(props[k].findtext(a)) for a in ('X','Y','Z')]
  def content(k):return ''.join(props[k].itertext()).strip() if k in props else ''
  def frame(k):return [float(c.text) for c in props[k]] if k in props else None
  sa=next((c for c in e.findall('Item') if c.get('class')=='SurfaceAppearance'),None)
  maps={c.get('name'):''.join(c.itertext()).strip() for c in sa.find('Properties') if c.tag=='Content'} if sa is not None else {}
  rows.append(dict(path=path,name=n,mesh=content('MeshContent'),size=vector('size'),cf=frame('CFrame'),pivot=frame('PivotOffset'),maps=maps,texture=content('TextureContent')))
 for c in e.findall('Item'):walk(c,path)
for c in tree.getroot().findall('Item'):walk(c)
(O/'studio-inventory.json').write_text(json.dumps(rows,indent=2),encoding='utf-8')
print('STUDIO',len(rows),'UNIQUE',len(set(r['mesh'] for r in rows)),flush=True)
