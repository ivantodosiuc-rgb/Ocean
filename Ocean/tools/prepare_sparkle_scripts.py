from pathlib import Path
import json,xml.etree.ElementTree as ET
R=Path(__file__).resolve().parents[1];tree=ET.parse(R/'build/backups/SuckTheSea-before-sparkle-update.rbxlx');old={}
def walk(e,path='game'):
 name=e.findtext('./Properties/string[@name="Name"]') or e.get('class','');path=path+'.'+name
 source=e.find('./Properties/ProtectedString[@name="Source"]')
 if source is not None:old[path]=source.text or ''
 for c in e.findall('Item'):walk(c,path)
for e in tree.getroot().findall('Item'):walk(e)
entries=[]
for group in ['Shared','Server','Client','Tests']:
 prefix={'Server':'game.ServerScriptService.SeaGame','Tests':'game.ServerStorage.SeaGameTests'}.get(group,'game.ReplicatedStorage.SeaGame.'+group)
 for p in (R/'src'/group).glob('*.luau'):
  if '.server.' in p.name or '.client.' in p.name:continue
  path=prefix+'.'+p.stem;source=p.read_text(encoding='utf-8')
  if old.get(path)==source:continue
  previous=old.get(path)
  h=0
  if previous is not None:
   for b in previous.encode('utf-8'):h=(h*131+b)%2147483647
  entries.append({'path':path,'source':source,'oldHash':h if previous is not None else None,'oldLength':len(previous.encode('utf-8')) if previous is not None else 0})
(R/'build/sparkle-script-changes.json').write_text(json.dumps(entries),encoding='utf-8')
print(json.dumps([{'path':e['path'],'new':e['oldHash'] is None,'length':len(e['source'])} for e in entries]))
