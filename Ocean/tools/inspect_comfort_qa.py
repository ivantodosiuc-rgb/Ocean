import bpy,types
from pathlib import Path
path=Path('C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts/qa_check.py')
source=path.read_text(encoding='utf-8').replace('    zf = _describe(zf_pairs)',"    print('ZPAIR_CENTERS', [[list(sum((verts[k] for k in tris[i]), Vector())/3), list(sum((verts[k] for k in tris[j]), Vector())/3)] for i,j in zf_pairs])\n    zf = _describe(zf_pairs)")
module=types.ModuleType('inspectqa');module.__file__=str(path);exec(compile(source,str(path),'exec'),module.__dict__)
module.run(objects=['Restroom__Cabin'],profile='roblox')
