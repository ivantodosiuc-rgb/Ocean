import bpy,sys,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'assets/SuckTheSea_Island.blend'))
sys.path.insert(0,'C:/Users/Administrator/.codex/skills/blender-asset-qa/scripts')
import qa_check,review_shots
prefixes=['Ocean__DockBarrel','Ocean__RopeCoil','Decorations__Bush','Decorations__FlowerBed','Decorations__ShoreRock','Decorations__Chest','Decorations__Shell','UnderwaterTerrain__Coral','UnderwaterTerrain__FutureTreasure','UnderwaterTerrain__Sandbank']
report={}
for prefix in prefixes:
 ob=next((o for o in bpy.context.scene.objects if o.name.startswith(prefix)),None)
 if ob:
  report[ob.name]=qa_check.run(objects=[ob.name],profile='roblox')
  print(ob.name,report[ob.name]['errors'],flush=True)
(ROOT/'assets/prop-qa.json').write_text(json.dumps(report,default=str,indent=2))
for name in ['Buildings__StrawShop','Ocean__LittleBoat']:
 for mode in ['random','wire']:
  review_shots.run(objects=[name],out=str(ROOT/'build/screenshots'/f'qa-{name}-{mode}.png'),views=['front','right','top','three_quarter'],mode=mode,res=400)
print('ASSET_REVIEW_DONE',flush=True)
