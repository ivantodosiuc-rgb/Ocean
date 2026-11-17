import ast, xml.etree.ElementTree as ET
from pathlib import Path
root=Path(__file__).resolve().parents[1]
tree=ast.parse((root/'tools/collect_depth_verification.py').read_text())
exec(compile(ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name in {'name','get','refs','signature'}],type_ignores=[]),'helpers','exec'))
a=ET.parse(root/'build/backups/SuckTheSea-before-step4.rbxlx').getroot();b=ET.parse(root/'build/SuckTheSea.rbxlx').getroot()
ar,br=refs(a),refs(b)
def flatten(node,path=''):
    out={}
    def walk(n,p):
        out[p]=n
        for c in n.findall('Item'):walk(c,p+'/'+name(c))
    walk(node,path);return out
aa,bb=flatten(get(a,['Workspace','NPCs'])),flatten(get(b,['Workspace','NPCs']))
count=0
for key in sorted(aa.keys()|bb.keys()):
    if key not in aa or key not in bb:print('NODE',key,key in aa,key in bb);continue
    ap=signature(aa[key],ar)[1];bp=signature(bb[key],br)[1]
    if ap!=bp:
        old={v[1][0][1]:v for v in ap};new={v[1][0][1]:v for v in bp}
        for prop in sorted(old.keys()|new.keys()):
            if old.get(prop)!=new.get(prop):
                count+=1;print('DIFF',key,prop,str(old.get(prop))[:270],str(new.get(prop))[:270])
print('TOTAL',count)
