import xml.etree.ElementTree as ET,json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
before=ET.parse(root/'build/backups/SuckTheSea-before-npc-flora-refresh.rbxlx').getroot()
after=ET.parse(root/'build/SuckTheSea.rbxlx').getroot()
def name(e):return e.findtext('./Properties/string[@name="Name"]') or e.attrib.get('class','')
def get(e,path):
 for segment in path:
  e=next(c for c in e.findall('Item') if name(c)==segment)
 return e
def refs(e):
 out={}
 def walk(p,path):
  for item in p.findall('Item'):
   key='/'.join(path+[name(item)]);out[item.attrib.get('referent','')]=key;walk(item,path+[name(item)])
 walk(e,[]);return out
def signature(e,ref):
 def value(p):
  text=(p.text or '').strip()
  if p.tag=='Ref':text=ref.get(text,text)
  return (p.tag,tuple(sorted((k,v) for k,v in p.attrib.items() if k!='referent')),text,tuple(value(c) for c in p))
 props=tuple(sorted((value(p) for p in e.find('Properties') if p.attrib.get('name') not in ['UniqueId','HistoryId']),key=str))
 return (e.attrib['class'],props,tuple(sorted((signature(c,ref) for c in e.findall('Item')),key=str)))
a,b=refs(before),refs(after)
results={}
for folder in ['StarterIsland','Buildings','Decorations','Ocean','UnderwaterTerrain']:
 results[folder]=signature(get(before,['Workspace',folder]),a)==signature(get(after,['Workspace',folder]),b)
results['Lighting']=signature(get(before,['Lighting']),a)==signature(get(after,['Lighting']),b)
report={'comparison':'Saved original before flora refresh vs current saved place; excludes replacement NPCs and editor camera','unchanged':results,'allRestored':all(results.values())}
(root/'build/restoration-verification.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
