import json,re,xml.etree.ElementTree as ET
from pathlib import Path
root=Path(__file__).resolve().parents[1]
log=max(Path('C:/Users/Administrator/AppData/Local/Roblox/logs').glob('*Studio*last.log'),key=lambda p:p.stat().st_mtime)
lines=log.read_text(encoding='utf-8',errors='replace').splitlines()
report={'studioLog':log.name,'date':'2026-11-16','staticChecks':{},'walk':[],'returnWalk':[],'drainPreview':[]}
for line in lines:
 if '[FLog::CreatorOutput] ' not in line:continue
 text=line.split('[FLog::CreatorOutput] ',1)[1]
 if text.startswith('MAP_AUDIT ') and not text.endswith('DONE'):
  name,_,data=text[len('MAP_AUDIT '):].partition(' ')
  try:report['staticChecks'][name]=json.loads(data)
  except json.JSONDecodeError:pass
 if text.startswith('PLAYTEST_WALK '):report['walk'].append(text)
 if text.startswith('PLAYTEST_RETURN ') and not text.startswith('PLAYTEST_RETURN_DONE'):report['returnWalk'].append(text)
 if text.startswith('PLAYTEST_SPAWN '):report['spawn']=text
 if text.startswith('PLAYTEST_DONE '):report['walkSummary']=text
 if text.startswith('PLAYTEST_RETURN_DONE '):report['returnSummary']=text
 if text.startswith('DRAIN_PREVIEW_BANK '):report['drainPreview'].append(text)
 if text.startswith('FINAL_VERIFICATION '):report['finalStudioState']=json.loads(text[len('FINAL_VERIFICATION '):])
qa={}
for filename in ['blender-qa.json','prop-qa.json','chest-qa.json']:
 qa.update(json.loads((root/'assets'/filename).read_text(encoding='utf-8-sig')))
qa_final={'pass':all(v.get('pass') for v in qa.values()),'reviewedAssetRepresentatives':len(qa),'assets':qa,'acceptedWarnings':['UV overlap is intentional: all faces sample a shared 128x128 flat color palette. No unique-lightmap baking is intended.','Assets are positioned in the authored map; their lowest Z is intentionally not world zero.','Palm trunk segments retain 16 hidden contact triangle pairs per representative palm. They do not produce visible z-fighting; this small cost is within the scene budget.'],'visualReview':['Blender overview render','Four-angle solid and wireframe review: shop and boat','Four-angle chest review','Studio overview, village, underwater, treasure counter','Actual Studio Play spawn and pier walkthrough']}
(root/'assets/asset-qa-final.json').write_text(json.dumps(qa_final,ensure_ascii=False,indent=2),encoding='utf-8')
tree=ET.parse(root/'build/SuckTheSea.rbxlx');items=list(tree.iter('Item'))
report['savedFile']={'path':'build/SuckTheSea.rbxlx','bytes':(root/'build/SuckTheSea.rbxlx').stat().st_size,'meshParts':sum(p.get('class')=='MeshPart' for p in items),'scripts':sum(p.get('class') in ['Script','LocalScript','ModuleScript'] for p in items),'spawnLocations':sum(p.get('class')=='SpawnLocation' for p in items)}
report['blenderQA']={'pass':qa_final['pass'],'reviewedAssetRepresentatives':len(qa)}
report['limits']=['Verified in local Studio Play with one player. Mobile device FPS and multiplayer were not tested.','Drain preview tested level -16. The production draining controller and smooth transition are intentionally not implemented.']
(root/'build/verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({k:report[k] for k in ['walkSummary','returnSummary','finalStudioState','savedFile','blenderQA']},ensure_ascii=False,indent=2))
