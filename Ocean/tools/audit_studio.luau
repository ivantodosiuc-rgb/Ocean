local H=game:GetService('HttpService')
local function report(name,data) print('MAP_AUDIT '..name..' '..H:JSONEncode(data)) end
local ray=RaycastParams.new();ray.RespectCanCollide=true;ray.IgnoreWater=true
local missing={};local count=0
for x=-60,60,4 do for z=-60,60,4 do if x*x+z*z<=3600 then
 count+=1;local hit=workspace:Raycast(Vector3.new(x,40,z),Vector3.new(0,-60,0),ray)
 if not hit or hit.Position.Y<3 then table.insert(missing,{x,z,hit and hit.Position.Y or -999}) end
end end end
report('IslandSurface',{samples=count,missing=missing})
local dockMissing={};local dockSamples=0
for z=68,132,2 do for _,x in {-5,0,5} do
 dockSamples+=1;local hit=workspace:Raycast(Vector3.new(x,10,z),Vector3.new(0,-20,0),ray)
 if not hit or hit.Position.Y<3 then table.insert(dockMissing,{x,z}) end
end end
report('PierSurface',{samples=dockSamples,missing=dockMissing})
local totals={parts=0,meshes=0,unanchored=0,scripts=0,screenGui=0,npcs={}}
for _,p in workspace:GetDescendants() do
 if p:IsA('BasePart') then totals.parts+=1;if not p.Anchored and not p:IsA('Terrain') then totals.unanchored+=1 end end
 if p:IsA('MeshPart') then totals.meshes+=1 end
 if p:IsA('LuaSourceContainer') then totals.scripts+=1 end
end
for _,p in game:GetService('StarterGui'):GetDescendants() do if p:IsA('ScreenGui') then totals.screenGui+=1 end end
for _,m in workspace.NPCs:GetChildren() do table.insert(totals.npcs,{name=m.Name,position=tostring(m:GetPivot().Position)}) end
report('Scene',totals)
for _,n in {'StrawShop','UpgradeShop','TreasureShop'} do
 local p=workspace.Buildings:FindFirstChild(n)
 report(n,{exists=p~=nil,position=p and tostring(p.Position),texture=p and p.TextureID})
end
report('Ocean',{waterLevel=workspace.Ocean:GetAttribute('WaterLevel'),minLevel=workspace.Ocean:GetAttribute('MinimumWaterLevel'),treasureSites=#workspace.UnderwaterTerrain.FutureTreasureSites:GetChildren()})
local L=game:GetService('Lighting');L.EnvironmentDiffuseScale=.25;L.Ambient=Color3.fromRGB(85,90,98);L.OutdoorAmbient=Color3.fromRGB(130,130,130);L.TropicalAtmosphere.Density=.18;L.TropicalAtmosphere.Offset=.3;L.IslandColorGrade.TintColor=Color3.fromRGB(255,249,235)
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(118,96,155),Vector3.new(0,3,22))
print('MAP_AUDIT_DONE')
