"""Bake wet shoreline against rendered Blender triangles, not approximate Roblox collision hulls."""
import bpy, math, json, struct, base64
from pathlib import Path
from mathutils import Vector
from mathutils.bvhtree import BVHTree
root=Path(__file__).resolve().parents[1]
verts=[];faces=[]
for ob in bpy.context.scene.objects:
    if not (ob.name=='Ground__GoldenShore' or ob.name.startswith('Seabed__')): continue
    ob.data.calc_loop_triangles();offset=len(verts)
    for v in ob.data.vertices:
        p=ob.matrix_world@v.co
        verts.append((p.x,-p.y,p.z))
    faces.extend(tuple(offset+i for i in tri.vertices) for tri in ob.data.loop_triangles)
bvh=BVHTree.FromPolygons(verts,faces,all_triangles=True)
def height(r,a):
    hit=bvh.ray_cast(Vector((math.cos(a)*r,math.sin(a)*r,12)),Vector((0,0,-1)),110)[0]
    return hit.z if hit else -84
rows=[]
for step in range(273):
    level=-step*.25;row=[]
    for i in range(120):
        a=i*math.tau/120
        for h in (level+1.1,level+.10):
            lo,hi=65,340
            for _ in range(18):
                r=(lo+hi)/2
                if height(r,a)>h:lo=r
                else:hi=r
            row.append(round((lo+hi)/2,4))
    rows.append(row)
encoded=base64.b64encode(b''.join(struct.pack('<H',round(r*100)) for row in rows for r in row)).decode('ascii')
text='''--!nonstrict
-- Blender triangle contours: quantized to .01 stud, sampled every .25 stud of water.
-- Packed below Roblox's 200,000-character Source limit. Decoded once per client.
local encoded=[==['''+encoded+''']==]
local alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local values={};for i=1,#alphabet do values[string.byte(alphabet,i)]=i-1 end
local data=buffer.create(131040);local offset=0
for i=1,#encoded,4 do
 local a,b,c,d=string.byte(encoded,i,i+3)
 local n=values[a]*262144+values[b]*4096+values[c]*64+values[d]
 buffer.writeu8(data,offset,math.floor(n/65536));buffer.writeu8(data,offset+1,math.floor(n/256)%256);buffer.writeu8(data,offset+2,n%256);offset+=3
end
local contours={step=.25,count=120,levels=273}
function contours.radius(row,column) return buffer.readu16(data,((row-1)*240+column-1)*2)/100 end
return contours
'''
(root/'src/Client/ShoreContours.luau').write_text(text,encoding='utf-8')
print('SHORE_CONTOURS_BAKED',len(rows),len(rows[0]),len(text))
