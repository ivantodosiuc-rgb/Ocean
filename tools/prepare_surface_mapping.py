import json, math
from pathlib import Path
R=Path(__file__).resolve().parents[1];O=R/'assets/surfaces'
sources=json.loads((O/'source-inventory.json').read_text());rows=json.loads((O/'studio-inventory.json').read_text())
ids={'115373682107179':'island','123124520356335':'depth','121356364373616':'polish','83351946147596':'comfort'}
mapping={};unmatched=[]
for row in rows:
 tex=row['maps'].get('ColorMapContent') or row['texture'];family=next((v for k,v in ids.items() if k in tex),None)
 if row['path']=='Workspace.StarterIsland.Meadow':family='depth'
 if not family or row['mesh'] in mapping:continue
 # Map the artist-authored identifier first; then compare proportional mesh bounds.
 ranked=[]
 for s in sources[family]:
  suffix=s['name'].split('__',1)[-1];name_match=suffix in row['path'].split('.') or row['name']==suffix
  size=[s['size'][0],s['size'][2],s['size'][1]]
  logs=[math.log(max(a,.00001)/max(b,.00001)) for a,b in zip(row['size'],size)]
  err=max(logs)-min(logs)
  ranked.append((0 if name_match else 1,err,s['name']))
 ranked.sort();best=ranked[0]
 if best[1]>.002:
  # Rotated source parts can have their imported local bounds rotated. Flag for inspection.
  unmatched.append(dict(row=row,ranked=ranked[:4]));continue
 mapping[row['mesh']]=dict(family=family,source=best[2],mesh=row['mesh'],sample=row['path'],error=best[1],export=family+'__'+best[2])
(O/'mesh-mapping.json').write_text(json.dumps(mapping,indent=2),encoding='utf-8')
(O/'unmatched.json').write_text(json.dumps(unmatched,indent=2),encoding='utf-8')
print('Mapped',len(mapping),'unmatched',len(unmatched))
for r in unmatched:print(r['row']['path'],r['row']['size'],r['ranked'])
