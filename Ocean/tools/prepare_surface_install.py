import json,xml.etree.ElementTree as ET
from pathlib import Path
R=Path(__file__).resolve().parents[1];O=R/'assets/surfaces'
mapping=json.loads((O/'mesh-mapping.json').read_text());support=json.loads((O/'support-fit.json').read_text())
live={k:v['export'] for k,v in mapping.items() if not v['source'].startswith(('Ground__','Seabed__'))}
data=json.dumps(dict(meshes=live,support=support),separators=(',',':'))
code='''assert(not game:GetService('RunService'):IsRunning(),'Edit mode required')
assert(not workspace:GetAttribute('SurfaceUpgradeInstalled'),'Surface update already installed')
local data=game:GetService('HttpService'):JSONDecode([==['''+data+''']==])
local imported=assert(workspace:FindFirstChild('SuckTheSea_Surfaces'),'Import reviewed FBX first')
local sources={};for _,p in imported:GetDescendants() do if p:IsA('MeshPart') then sources[p.Name]=p end end
local function find(path)
 local o=game
 for name in path:gmatch('[^.]+') do o=assert(o:FindFirstChild(name),path) end
 return o
end
local targets={}
for _,root in {workspace,game.ReplicatedStorage.SeaGame.Assets} do
 for _,p in root:GetDescendants() do if p:IsA('MeshPart') and not p:IsDescendantOf(imported) then
  local name=data.meshes[p.MeshId]
  if name then local src=assert(sources[name],name);assert(src:FindFirstChildOfClass('SurfaceAppearance'),'Missing PBR '..name);table.insert(targets,{part=p,source=src}) end
 end end
end
for _,r in data.support.fits do find(r.path) end
for _,r in data.support.starter do find(r.path) end
for _,kind in {'LagoonSand','IslandGrass'} do assert(sources['SurfaceTile__'..kind]:FindFirstChildOfClass('SurfaceAppearance'),kind) end
local history=game:GetService('ChangeHistoryService');local recording=history:TryBeginRecording('Surface textures and support','PBR textures and visible-ground placement')
local result={meshes=0,groundParts=0,grounded=0,dropSites=0,starterSites=0}
for i,r in targets do
 local p=r.part;local size,cf,pivot=p.Size,p.CFrame,p.PivotOffset;local collision,render=p.CollisionFidelity,p.RenderFidelity
 p:ApplyMesh(r.source);p.Size=size;p.CFrame=cf;p.PivotOffset=pivot;p.CollisionFidelity=collision;p.RenderFidelity=render
 for _,s in p:GetChildren() do if s:IsA('SurfaceAppearance') then s:Destroy() end end
 local appearance=r.source:FindFirstChildOfClass('SurfaceAppearance'):Clone();appearance.Name='SeaSurface';appearance.Color=Color3.new(1,1,1);appearance.Parent=p
 p.TextureID='';p.Material=Enum.Material.SmoothPlastic;p.Color=Color3.new(1,1,1);p:SetAttribute('SurfaceSource',r.source.Name);p:SetAttribute('SurfaceTextureVersion',1)
 result.meshes+=1;if i%45==0 then task.wait() end
end
local variants={}
for _,kind in {'LagoonSand','IslandGrass'} do
 local appearance=sources['SurfaceTile__'..kind]:FindFirstChildOfClass('SurfaceAppearance')
 local v=Instance.new('MaterialVariant');v.Name='Sea_'..kind;v.BaseMaterial=if kind=='IslandGrass' then Enum.Material.Grass else Enum.Material.Sand
 v.ColorMap=appearance.ColorMap;v.NormalMap=appearance.NormalMap;v.RoughnessMap=appearance.RoughnessMap
 v.StudsPerTile=if kind=='IslandGrass' then 8 else 12;v.Parent=game:GetService('MaterialService');variants[kind]=v
end
local grounds={workspace.StarterIsland.GoldenShore,workspace.StarterIsland.Meadow}
for _,p in workspace.UnderwaterTerrain.Seafloor:GetChildren() do if p:IsA('MeshPart') then table.insert(grounds,p) end end
for _,p in grounds do
 for _,s in p:GetChildren() do if s:IsA('SurfaceAppearance') then s:Destroy() end end
 local v=variants[if p.Name=='Meadow' then 'IslandGrass' else 'LagoonSand'];p.TextureID='';p.Material=v.BaseMaterial;p.MaterialVariant=v.Name;p.Color=Color3.new(1,1,1);p:SetAttribute('SurfaceTextureVersion',1);result.groundParts+=1
end
for i,r in data.support.fits do
 local m=find(r.path);local delta=Vector3.new(0,r.deltaY,0);m:PivotTo(m:GetPivot()+delta)
 m:SetAttribute('GroundedOnVisibleSurface',true)
 local old=m:GetAttribute('GroundY');if old then m:SetAttribute('GroundY',old+r.deltaY) end
 for _,key in {'LidHinge','LidClosedCFrame'} do local cf=m:GetAttribute(key);if typeof(cf)=='CFrame' then m:SetAttribute(key,cf+delta) end end
 local descendants=m:GetDescendants();if m:IsA('BasePart') then table.insert(descendants,m) end
 for _,p in descendants do if p:IsA('BasePart') then local y=p:GetAttribute('ShoreBaseY');if y then p:SetAttribute('ShoreBaseY',y+r.deltaY) end end end
 result.grounded+=1;if i%50==0 then task.wait() end
end
for _,r in data.support.drops do
 local chest=workspace.UnderwaterTerrain.PointsOfInterest[r.chest];local f=chest:FindFirstChild('DropSites')
 if not f then f=Instance.new('Folder');f.Name='DropSites';f.Parent=chest end
 local p=Instance.new('Part');p.Name='Drop_'..r.index;p.Size=Vector3.new(.1,.1,.1);p.Position=Vector3.new(unpack(r.position));p.Anchored=true;p.Transparency=1;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p:SetAttribute('SurfaceNormal',Vector3.new(unpack(r.normal)));p.Parent=f;result.dropSites+=1
end
for _,r in data.support.starter do local p=find(r.path);p.Position=Vector3.new(unpack(r.position));p:SetAttribute('SurfaceNormal',Vector3.new(unpack(r.normal)));result.starterSites+=1 end
imported:Destroy();workspace:SetAttribute('SurfaceUpgradeInstalled',true);game:GetService('Selection'):Set({})
if recording then history:FinishRecording(recording,Enum.FinishRecordingOperation.Commit) end
return result
'''
(R/'tools/install_surface_upgrade.luau').write_text(code,encoding='utf-8')
tree=ET.parse(R/'build/backups/SuckTheSea-before-surface-upgrade.rbxlx');sources={}
def walk(e,path=''):
 n=e.findtext('./Properties/string[@name="Name"]') or e.get('class','');path=path+'.'+n if path else n
 if e.get('class')=='ModuleScript':sources[path]=e.findtext('./Properties/ProtectedString[@name="Source"]') or ''
 for c in e.findall('Item'):walk(c,path)
for e in tree.getroot().findall('Item'):walk(e)
payload=[]
for name in ('GroundSites','Loot','Wrecks'):
 path='ServerScriptService.SeaGame.'+name;payload.append(dict(name=name,path='game.'+path,old=sources.get(path,''),new=(R/'src/Server'/(name+'.luau')).read_text(encoding='utf-8')))
(O/'source-payload.json').write_text(json.dumps(payload,ensure_ascii=False),encoding='utf-8')
print('Prepared installer',len(code),'bytes and',len(payload),'script changes')
