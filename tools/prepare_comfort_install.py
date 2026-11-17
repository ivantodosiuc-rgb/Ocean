from pathlib import Path
import json
root=Path(__file__).resolve().parents[1]
groups={'Shared':['Config','Economy','LootCatalog','Needs'],'Server':['Game','Ocean','Loot','Restroom'],'Client':['UI','Controller','ComfortUI','RestroomEffects','Components'],'Tests':['EconomyProfiles','Comfort','OceanProgress']}
entries=[]
for group,names in groups.items():
 for name in names:
  path=root/'src'/group/(name+'.luau');previous=root/'build/backups/comfort-src'/group/path.name
  prefix='game.ServerScriptService.SeaGame' if group=='Server' else 'game.ServerStorage.SeaGameTests' if group=='Tests' else 'game.ReplicatedStorage.SeaGame.'+group
  entries.append({'path':prefix+'.'+name,'old':previous.read_text(encoding='utf-8') if previous.exists() else None,'source':path.read_text(encoding='utf-8')})
(root/'build/comfort-install.json').write_text(json.dumps(entries,ensure_ascii=True),encoding='utf-8')
print(json.dumps(entries,ensure_ascii=True))
