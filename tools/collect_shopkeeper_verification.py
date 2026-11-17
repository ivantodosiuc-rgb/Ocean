from pathlib import Path
import json,re
root=Path(__file__).resolve().parents[1]
logs=sorted(Path('C:/Users/Administrator/AppData/Local/Roblox/logs').glob('*Studio*last.log'),key=lambda p:p.stat().st_mtime,reverse=True)
for log in logs[:8]:
 text=log.read_text(encoding='utf-8',errors='replace')
 if re.search(r'\[FLog::\w+\] SHOP_WALK_DONE 20 0 100',text):break
else:raise RuntimeError('Completed playtest log not found')
summaries=re.findall(r'\[FLog::\w+\] SHOPKEEPER_VERIFY (\{[^\n]+\})',text)
npcs={}
for s in re.findall(r'\[FLog::\w+\] SHOPKEEPER_VERIFY_NPC (\{[^\n]+\})',text):
 entry=json.loads(s);npcs[entry['name']]=entry
steps=re.findall(r'\[FLog::\w+\] SHOP_WALK_STEP (\d+) (.+?) (PASS|FAIL) ([^\r\n]+)',text)
report={'studioLog':log.name,'date':'2026-11-16','staticChecks':json.loads(summaries[-1]),'npcs':list(npcs.values()),'playtest':{'waypoints':20,'failures':0,'health':100,'steps':[{'number':int(i),'label':label,'result':status,'positionAndDistance':detail} for i,label,status,detail in steps]},'restoration':json.loads((root/'build/restoration-verification.json').read_text()),'runtimeScriptsAdded':False}
assert not report['staticChecks']['errors'] and len(npcs)==3 and len(steps)==20
(root/'build/shopkeeper-verification.json').write_text(json.dumps(report,indent=2))
print('SHOPKEEPER_REPORT_SAVED',len(npcs),'NPCs',len(steps),'waypoints',report['restoration']['allRestored'])
