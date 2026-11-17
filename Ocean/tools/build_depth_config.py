import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
catalog=json.loads((ROOT/'assets/depth/catalog.json').read_text())
colors={'COMMON':(255,176,173),'UNCOMMON':(124,231,220),'RARE':(255,200,87),'LEGENDARY':(170,132,229)}
rows=['--!strict','-- Original Blender collectibles, grouped by the depth at which they are discovered.','return {']
for d in catalog:
 rarity='LEGENDARY' if d['value']>=1250 else 'RARE' if d['value']>=300 else 'UNCOMMON' if d['value']>=75 else 'COMMON'
 c=colors[rarity]
 rows.append(' {id=%s,name=%s,weight=%s,value=%s,minDepth=%s,rarity=%s,color=Color3.fromRGB(%s)},'%(json.dumps(d['id']),json.dumps(d['name']),d['weight'],d['value'],d['minDepth'],json.dumps(rarity),','.join(map(str,c))))
rows.append('}')
(ROOT/'src/Shared/LootCatalog.luau').write_text('\n'.join(rows)+'\n',encoding='utf-8')
f=ROOT/'src/Shared/Config.luau';s=f.read_text();s=re.sub(r'Config\.Loot=\{.*?\n\}',"Config.Loot=require(script.Parent.LootCatalog)",s,flags=re.S);f.write_text(s,encoding='utf-8')
q=json.loads((ROOT/'assets/depth/qa.json').read_text())
for name,v in q.items():
 if not v['pass']:print(name,len(v['errors']),v['errors'][:6])
print('CATALOG_READY',len(catalog))
