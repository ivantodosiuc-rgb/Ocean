local W=workspace
local Lighting=game:GetService('Lighting')
local imported=W:FindFirstChild('SuckTheSea_Studio')
assert(imported,'Import the Blender FBX first')
assert(not W:FindFirstChild('StarterIsland'),'Map already organized; do not duplicate')
local undo=game:GetService('ChangeHistoryService')
undo:SetWaypoint('Before Suck The Sea scene setup')
local folders={}
for _,name in {'StarterIsland','Buildings','Decorations','NPCs','Ocean','UnderwaterTerrain'} do
 local f=Instance.new('Folder');f.Name=name;f.Parent=W;folders[name]=f
end
-- The FBX importer applies a front-axis half turn. Restore the authored axes.
imported:PivotTo(CFrame.Angles(0,math.pi,0)*imported:GetPivot())
local meshCount=0
for _,p in imported:GetDescendants() do
 if p:IsA('MeshPart') then
  local category,name=p.Name:match('^(.-)__(.+)$')
  if folders[category] then
   p.Name=name;p.Parent=folders[category];p.Anchored=true;p.CanTouch=false
   p.CanCollide=false;p.CastShadow=true;p.RenderFidelity=Enum.RenderFidelity.Automatic
   p.Material=Enum.Material.SmoothPlastic
   if category=='StarterIsland' and (name=='GoldenShore' or name=='Meadow') then
    p.CanCollide=true;p.CollisionFidelity=Enum.CollisionFidelity.PreciseConvexDecomposition
   elseif category=='StarterIsland' and name=='Plaza' then
    p.CanCollide=true;p.CollisionFidelity=Enum.CollisionFidelity.Hull
   elseif category=='UnderwaterTerrain' and (name:find('Shoal') or name:find('ReefRock')) then
    p.CanCollide=true;p.CollisionFidelity=Enum.CollisionFidelity.Hull
   elseif category=='Decorations' and name:find('Rock') then
    p.CanCollide=true;p.CollisionFidelity=Enum.CollisionFidelity.Hull
   end
   p:SetAttribute('AuthoredIn','Blender 5.2.1');meshCount+=1
  end
 end
end
imported:Destroy()
local function part(parent,name,size,cf,color,shape,visible)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf
 p.Color=color or Color3.fromRGB(185,155,105);p.Material=Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 if shape then p.Shape=shape end
 if visible==false then p.Transparency=1;p.CastShadow=false end
 p.Parent=parent;return p
end
local function collider(parent,name,size,cf)
 local p=part(parent,name,size,cf,nil,nil,false);p:SetAttribute('CollisionProxy',true);return p
end
local collisions=Instance.new('Folder');collisions.Name='WalkableCollisions';collisions.Parent=folders.StarterIsland
-- Continuous boardwalk collision avoids gaps between the individual visual planks.
collider(folders.Ocean,'PierWalkwayCollision',Vector3.new(12.8,.7,52),CFrame.new(0,3.25,93))
collider(folders.Ocean,'PierHeadCollision',Vector3.new(28.8,.7,16.4),CFrame.new(0,3.25,126.2))
-- A short beach transition, entirely below the matching wooden boards.
collider(folders.Ocean,'PierLandingCollision',Vector3.new(12.8,.8,8),CFrame.new(0,3.15,69))
for _,spec in {{'StrawShop',-41,-21,5.7,12},{'UpgradeShop',27,-43,5.6,-23},{'TreasureShop',49,13,5.6,-65}} do
 local model=Instance.new('Model');model.Name=spec[1]..'_Collisions';model.Parent=folders.Buildings
 local cf=CFrame.new(spec[2],spec[4],spec[3])*CFrame.Angles(0,math.rad(spec[5]),0)
 collider(model,'Deck',Vector3.new(22.5,1.25,16.5),cf*CFrame.new(0,.625,0))
 collider(model,'BackWall',Vector3.new(20,.6,8.5),cf*CFrame.new(0,5.5,-6.6)*CFrame.Angles(math.pi/2,0,0))
 for _,side in {-1,1} do
  collider(model,'SideWall',Vector3.new(.65,8.5,8.5),cf*CFrame.new(side*9.5,5.5,-2.3))
 end
 collider(model,'Counter',Vector3.new(15,3.2,3),cf*CFrame.new(0,2.85,4.8))
 for j=0,2 do collider(model,'PorchStep'..j,Vector3.new(9.4,.35,1.5),cf*CFrame.new(0,.85-j*.27,9.2+j*1.3)) end
end
-- Solid seafloor and shallow shelves remain in place when water is lowered.
local sand=Color3.fromRGB(224,197,137)
part(folders.UnderwaterTerrain,'DeepSeabed',Vector3.new(1600,12,1600),CFrame.new(0,-46,0),sand).Material=Enum.Material.Sand
part(folders.UnderwaterTerrain,'InnerSandShelf',Vector3.new(6,220,210),CFrame.new(0,-15,0)*CFrame.Angles(0,0,math.pi/2),sand,Enum.PartType.Cylinder).Material=Enum.Material.Sand
part(folders.UnderwaterTerrain,'OuterSandShelf',Vector3.new(6,270,260),CFrame.new(0,-26,0)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(209,188,139),Enum.PartType.Cylinder).Material=Enum.Material.Sand
local groundParams=RaycastParams.new();groundParams.FilterType=Enum.RaycastFilterType.Include
groundParams.FilterDescendantsInstances={folders.StarterIsland:FindFirstChild('GoldenShore'),folders.StarterIsland:FindFirstChild('Meadow')}
local function floorAt(x,z)
 local hit=W:Raycast(Vector3.new(x,45,z),Vector3.new(0,-70,0),groundParams)
 return hit and hit.Position.Y or 6
end
local coral=folders.UnderwaterTerrain:FindFirstChild('Coral_0_0')
if coral then
 for i=1,14 do
  local a=i*math.pi*2/14;local p=coral:Clone();p.Name='LagoonCoral_'..i
  p.Size*=.72;p.CFrame=CFrame.new(math.cos(a)*101,-10.6,math.sin(a)*95)*CFrame.Angles(0,a,0);p.Parent=folders.UnderwaterTerrain
 end
end
local terrain=W.Terrain
terrain.WaterColor=Color3.fromRGB(25,177,187)
terrain.WaterTransparency=.48;terrain.WaterReflectance=.12
terrain.WaterWaveSize=.1;terrain.WaterWaveSpeed=7
terrain:FillBlock(CFrame.new(0,-20,0),Vector3.new(1600,40,1600),Enum.Material.Water)
folders.Ocean:SetAttribute('WaterLevel',0)
folders.Ocean:SetAttribute('MinimumWaterLevel',-36)
folders.Ocean:SetAttribute('WaterBoundsMin',Vector3.new(-800,-40,-800))
folders.Ocean:SetAttribute('WaterBoundsMax',Vector3.new(800,0,800))
folders.Ocean:SetAttribute('WaterRepresentation','Terrain water; only water voxels in these bounds may be rewritten. Keep seabed and island meshes.')
folders.Ocean:SetAttribute('DrainMechanicImplemented',false)
terrain:SetAttribute('SuckTheSeaOcean',true)
local sites=Instance.new('Folder');sites.Name='FutureTreasureSites';sites.Parent=folders.UnderwaterTerrain
for i,pos in {Vector3.new(-123,-7.3,19),Vector3.new(115,-12.3,-48),Vector3.new(80,-19.3,135),Vector3.new(-65,-24.3,-126)} do
 local marker=part(sites,'TreasureSite_'..i,Vector3.one,CFrame.new(pos),nil,nil,false)
 marker.CanCollide=false;marker.CanQuery=false;marker:SetAttribute('RevealAtWaterLevel',pos.Y)
end
local spawn=Instance.new('SpawnLocation');spawn.Name='VillageSpawn';spawn.Size=Vector3.new(7,.2,7)
spawn.CFrame=CFrame.new(0,6.6,0);spawn.Transparency=1;spawn.Anchored=true;spawn.CanCollide=false
spawn.Duration=0;spawn.Neutral=true;spawn.Enabled=true;spawn.Parent=folders.StarterIsland
for _,d in spawn:GetChildren() do if d:IsA('Decal') then d:Destroy() end end
local skin=Color3.fromRGB(239,186,134)
local cream=Color3.fromRGB(255,239,199)
local dark=Color3.fromRGB(57,57,63)
local function npc(name,x,z,shirt,style)
 local m=Instance.new('Model');m.Name=name;m.Parent=folders.NPCs;m:SetAttribute('Role',style)
 local base=CFrame.lookAt(Vector3.new(x,floorAt(x,z)+.05,z),Vector3.new(0,floorAt(x,z)+.05,0))
 local function body(n,s,p,c,shape)
  local ob=part(m,n,s,base*CFrame.new(p),c,shape);ob.CanCollide=false;return ob
 end
 local root=body('HumanoidRootPart',Vector3.new(2,2,1),Vector3.new(0,2.8,0),shirt)
 root.Transparency=1;m.PrimaryPart=root
 body('Torso',Vector3.new(1.9,2,.95),Vector3.new(0,3.2,0),shirt)
 body('ShirtHem',Vector3.new(1.95,.26,1),Vector3.new(0,2.36,0),cream)
 for _,s in {-1,1} do
  body(s==-1 and 'Left Leg' or 'Right Leg',Vector3.new(.8,1.7,.8),Vector3.new(s*.48,1.25,0),Color3.fromRGB(65,100,122))
  body('Shoe',Vector3.new(.88,.5,1.12),Vector3.new(s*.48,.27,-.12),Color3.fromRGB(89,60,45))
  local arm=body(s==-1 and 'Left Arm' or 'Right Arm',Vector3.new(.65,1.75,.7),Vector3.new(s*1.26,3.08,0),shirt)
  arm.CFrame*=CFrame.Angles(0,0,s*math.rad(9))
  body('Hand',Vector3.new(.65,.6,.66),Vector3.new(s*1.4,2.18,0),skin,Enum.PartType.Ball)
 end
 body('Head',Vector3.new(1.62,1.62,1.5),Vector3.new(0,4.92,0),skin,Enum.PartType.Ball)
 for _,s in {-1,1} do
  body('Eye',Vector3.new(.18,.26,.09),Vector3.new(s*.31,5.03,-.7),dark,Enum.PartType.Ball)
  body('EyeGlint',Vector3.new(.055,.07,.05),Vector3.new(s*.31-.025,5.08,-.748),cream,Enum.PartType.Ball)
 end
 body('Smile',Vector3.new(.35,.08,.06),Vector3.new(0,4.63,-.728),Color3.fromRGB(138,72,52))
 if style=='Straw merchant' then
  body('CapCrown',Vector3.new(1.72,.7,1.6),Vector3.new(0,5.62,.05),shirt,Enum.PartType.Ball)
  body('CapBrim',Vector3.new(1.6,.12,1.1),Vector3.new(0,5.47,-.62),shirt)
  body('Apron',Vector3.new(1.3,1.35,.08),Vector3.new(0,2.95,-.51),cream)
 elseif style=='Upgrade engineer' then
  body('Hair',Vector3.new(1.76,.8,1.6),Vector3.new(0,5.55,.12),Color3.fromRGB(105,60,42),Enum.PartType.Ball)
  body('Ponytail',Vector3.new(.75,1.6,.7),Vector3.new(.75,4.97,.52),Color3.fromRGB(105,60,42),Enum.PartType.Ball)
  body('Headband',Vector3.new(1.69,.18,.19),Vector3.new(0,5.48,-.63),Color3.fromRGB(255,199,72))
  body('Apron',Vector3.new(1.4,1.6,.1),Vector3.new(0,2.9,-.52),Color3.fromRGB(50,130,142))
  for _,s in {-1,1} do body('Goggle',Vector3.new(.52,.46,.22),Vector3.new(s*.35,5.66,-.66),Color3.fromRGB(255,204,92),Enum.PartType.Ball) end
 else
  body('WhiteBeard',Vector3.new(1.2,.8,.55),Vector3.new(0,4.5,-.55),cream,Enum.PartType.Ball)
  body('HatCrown',Vector3.new(1.6,.68,1.55),Vector3.new(0,5.77,0),dark)
  body('HatBrim',Vector3.new(2.6,.19,1.9),Vector3.new(0,5.48,0),dark)
  body('GoldHatBand',Vector3.new(1.64,.16,1.6),Vector3.new(0,5.6,0),Color3.fromRGB(255,201,72))
  for _,s in {-1,1} do for j=0,2 do body('CoatButton',Vector3.new(.12,.12,.08),Vector3.new(s*.37,2.75+j*.42,-.52),Color3.fromRGB(255,201,72),Enum.PartType.Ball) end end
 end
 local humanoid=Instance.new('Humanoid');humanoid.DisplayName=name;humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None;humanoid.Parent=m
 return m
end
npc('Finn',-37,-7,Color3.fromRGB(42,177,163),'Straw merchant')
npc('Maya',21,-28,Color3.fromRGB(245,138,97),'Upgrade engineer')
npc('Captain Shell',36.5,20,Color3.fromRGB(56,99,133),'Treasure keeper')
Lighting.ClockTime=14.3;Lighting.GeographicLatitude=18;Lighting.Brightness=2.7
Lighting.Ambient=Color3.fromRGB(142,161,179);Lighting.OutdoorAmbient=Color3.fromRGB(161,180,190)
Lighting.EnvironmentDiffuseScale=.55;Lighting.EnvironmentSpecularScale=.45
Lighting.GlobalShadows=true;Lighting.ShadowSoftness=.32;Lighting.ExposureCompensation=.05
pcall(function() Lighting.LightingStyle=Enum.LightingStyle.Realistic end)
local at=Instance.new('Atmosphere');at.Name='TropicalAtmosphere';at.Density=.25;at.Offset=.1
at.Color=Color3.fromRGB(199,234,248);at.Decay=Color3.fromRGB(159,197,215);at.Glare=.08;at.Haze=1.1;at.Parent=Lighting
local cc=Instance.new('ColorCorrectionEffect');cc.Name='IslandColorGrade';cc.Saturation=.12;cc.Contrast=.025;cc.Brightness=.015;cc.Parent=Lighting
local bloom=Instance.new('BloomEffect');bloom.Name='SoftSunBloom';bloom.Intensity=.09;bloom.Size=18;bloom.Threshold=1.6;bloom.Parent=Lighting
local sky=Instance.new('Sky');sky.Name='TropicalSky';sky.CelestialBodiesShown=true;sky.Parent=Lighting
game:GetService('StarterPlayer').CameraMaxZoomDistance=110
game:GetService('StarterPlayer').CameraMinZoomDistance=5
W.FallenPartsDestroyHeight=-120
game:GetService('Selection'):Set({})
W.CurrentCamera.CameraType=Enum.CameraType.Fixed
W.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(168,136,208),Vector3.new(0,1,22))
W.CurrentCamera.FieldOfView=55
folders.StarterIsland:SetAttribute('Project','Suck The Sea!')
folders.StarterIsland:SetAttribute('MapVersion','Starter island 1.0')
undo:SetWaypoint('Suck The Sea starter map')
print('OCEAN_MAP_READY',meshCount,'Blender meshes',#folders.NPCs:GetChildren(),'NPCs')
