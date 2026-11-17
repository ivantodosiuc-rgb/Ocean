import bpy, json
from pathlib import Path
from mathutils import Vector
from mathutils.bvhtree import BVHTree
root=Path(__file__).resolve().parents[1]
log=Path('C:/Users/Administrator/AppData/Local/Roblox/logs/0.747.0.7471481_20261116T163659Z_Studio_94EE7_last.log')
records={}
for line in log.read_text(encoding='utf-8',errors='replace').splitlines():
    if '[FLog::CreatorOutput] POLISH_PLACEMENT ' in line:
        row=json.loads(line.split('POLISH_PLACEMENT ',1)[1]);records[row['name']]=row
rows=list(records.values());assert len(rows)==142
verts=[];faces=[]
for ob in bpy.context.scene.objects:
    if not (ob.name.startswith('Ground__') or ob.name.startswith('Seabed__')):continue
    ob.data.calc_loop_triangles();offset=len(verts)
    for v in ob.data.vertices:
        p=ob.matrix_world@v.co;verts.append((p.x,-p.y,p.z))
    faces.extend(tuple(offset+i for i in tri.vertices) for tri in ob.data.loop_triangles)
bvh=BVHTree.FromPolygons(verts,faces,all_triangles=True)
lines=["assert(not game:GetService('RunService'):IsRunning())",'local fixed=0']
for row in rows:
    hit=bvh.ray_cast(Vector((row['x'],row['z'],12)),Vector((0,0,-1)),110)[0]
    assert hit is not None
    row['visibleGround']=round(hit.z,5);row['correction']=round(hit.z-row['ground'],5)
    path='workspace.UnderwaterTerrain.PolishedReefs' if row['folder']=='PolishedReefs' else 'workspace.Decorations.CoastalPlanting'
    lines.append(f"do local m={path}:FindFirstChild('{row['name']}');local cf=m:GetPivot();local y={hit.z:.5f};m:PivotTo(cf+Vector3.new(0,y-.07-cf.Y,0));m:SetAttribute('GroundY',y);for _,p in m:GetDescendants() do if p:IsA('MeshPart') and p:GetAttribute('Wettable') then p:SetAttribute('ShoreBaseY',y) end end;fixed+=1 end")
lines.append("print('POLISH_VISIBLE_GROUND_FIT',fixed)")
(root/'build/fit-polish-placements.luau').write_text('\n'.join(lines),encoding='utf-8')
(root/'build/polish-ground-fit.json').write_text(json.dumps(rows,indent=2),encoding='utf-8')
print('POLISH_GROUND_FIT',len(rows),'max correction',max(abs(r['correction']) for r in rows),'over .15',sum(abs(r['correction'])>.15 for r in rows))
