"""Restore only Studio-normalized torso collisions and accessory matrices from the existing NPC snapshot."""
import xml.etree.ElementTree as ET
from pathlib import Path
root=Path(__file__).resolve().parents[1]
tree=ET.parse(root/'build/backups/SuckTheSea-before-step4.rbxlx').getroot()
def name(e):return e.findtext('./Properties/string[@name="Name"]') or e.attrib.get('class','')
def child(e,n):return next(c for c in e.findall('Item') if name(c)==n)
npcs=child(child(tree,'Workspace'),'NPCs')
lines=["assert(not game:GetService('RunService'):IsRunning())"]
for npc in npcs.findall('Item'):
    if npc.attrib.get('class')!='Model':continue
    for part in npc.findall('Item'):
        if name(part) in ['LowerTorso','UpperTorso']:
            old=part.findtext('./Properties/bool[@name="CanCollide"]')
            lines.append(f"workspace.NPCs['{name(npc)}']['{name(part)}'].CanCollide={old}")
        if part.attrib.get('class')=='Accessory':
            handle=child(part,'Handle');cf=handle.find('./Properties/CoordinateFrame[@name="CFrame"]')
            values=[cf.findtext(k) for k in ['X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22']]
            lines.append(f"workspace.NPCs['{name(npc)}']['{name(part)}'].Handle.CFrame=CFrame.new({','.join(values)})")
lines.append("print('POLISH_NPC_SNAPSHOT_RESTORED')")
(root/'build/restore-polish-npc-snapshot.luau').write_text('\n'.join(lines),encoding='utf-8')
