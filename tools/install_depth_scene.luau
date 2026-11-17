assert(not game:GetService('RunService'):IsRunning(),'Edit only')
local history=game:GetService('ChangeHistoryService');history:SetWaypoint('Before underwater expansion')
local assets=game.ReplicatedStorage.SeaGame.Assets
local imported=assert(workspace:FindFirstChild('SuckTheSea_Depth'),'Import the reviewed Blender FBX first')
local meshes={};for _,p in imported:GetDescendants() do if p:IsA('MeshPart') then table.insert(meshes,p) end end
assert(#meshes==78,'Expected exactly 78 imported meshes')
imported:PivotTo(CFrame.Angles(0,math.pi,0)*imported:GetPivot())
local env=Instance.new('Folder');env.Name='Environment';env.Parent=assets
local decor=Instance.new('Folder');decor.Name='Decor';decor.Parent=env
local ship=Instance.new('Model');ship.Name='Shipwreck';ship.WorldPivot=CFrame.new();ship.Parent=env
local chestTemplate=Instance.new('Model');chestTemplate.Name='Chest';chestTemplate.WorldPivot=CFrame.new();chestTemplate.Parent=env
workspace.UnderwaterTerrain:ClearAllChildren()
local floor=Instance.new('Folder');floor.Name='Seafloor';floor.Parent=workspace.UnderwaterTerrain
local reefs=Instance.new('Folder');reefs.Name='ReefLife';reefs.Parent=workspace.UnderwaterTerrain
local points=Instance.new('Folder');points.Name='PointsOfInterest';points.Parent=workspace.UnderwaterTerrain
local function prefab(p,parent,name)
 local old=parent:FindFirstChild(name);if old then old:Destroy() end
 local model=Instance.new('Model');model.Name=name;model.WorldPivot=CFrame.new();p.Name='Visual';p.Parent=model;model.Parent=parent;return model
end
local counts={}
for _,p in meshes do
 local category,name=p.Name:match('^(%a+)__(.+)$');assert(category,p.Name)
 p.Color=Color3.new(1,1,1);p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=true;p.RenderFidelity=Enum.RenderFidelity.Automatic;p.Material=Enum.Material.SmoothPlastic
 p:SetAttribute('AuthoredIn','Blender 5.2.1');p:SetAttribute('ExpansionAsset',true)
 if category=='Loot' then prefab(p,assets.Loot,name)
 elseif category=='Decor' then prefab(p,decor,name)
 elseif category=='Ground' then
  local old=workspace.StarterIsland:FindFirstChild(name);if old then old:Destroy() end
  p.Name=name;p.CanCollide=true;p.CanQuery=true;p.CollisionFidelity=Enum.CollisionFidelity.PreciseConvexDecomposition;p.Parent=workspace.StarterIsland
  if name=='Meadow' then p.TextureID='';p.Color=Color3.fromRGB(106,214,67) end
 elseif category=='Seabed' then p.Name=name;p.CanCollide=true;p.CanQuery=true;p.CollisionFidelity=Enum.CollisionFidelity.PreciseConvexDecomposition;p.Parent=floor
 elseif category=='Ship' then p.Name=name;p.Parent=ship
 elseif category=='Chest' then p.Name=name;p.Parent=chestTemplate
 elseif category=='Landmark' then prefab(p,env,name)
 else error(category) end
 counts[category]=(counts[category] or 0)+1
end
imported:Destroy()
local function part(parent,name,size,cf,visible)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanTouch=false;p.CanQuery=true;p.CanCollide=true;p.CastShadow=false;p.Material=Enum.Material.Sand;p.Color=Color3.fromRGB(209,186,137)
 p.Transparency=if visible then 0 else 1;p.Parent=parent;return p
end
part(floor,'DeepFoundation',Vector3.new(768,8,768),CFrame.new(0,-88,0),true)
local limits=Instance.new('Folder');limits.Name='WorldBoundary';limits.Parent=workspace.Ocean
for _,v in {{384,0,8,768},{-384,0,8,768},{0,384,768,8},{0,-384,768,8}} do part(limits,'Boundary',Vector3.new(v[3],220,v[4]),CFrame.new(v[1],-20,v[2]),false) end
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={workspace.StarterIsland.GoldenShore,workspace.StarterIsland.Meadow,workspace.Buildings,workspace.Ocean};params.RespectCanCollide=true;params.IgnoreWater=true
local function ground(x,z,filter)
 local q=params
 if filter then q=RaycastParams.new();q.FilterType=Enum.RaycastFilterType.Include;q.FilterDescendantsInstances=filter;q.RespectCanCollide=true;q.IgnoreWater=true end
 return workspace:Raycast(Vector3.new(x,40,z),Vector3.new(0,-135,0),q)
end
local function bottom(p)
 local minimum=math.huge
 for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do minimum=math.min(minimum,p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)*.5).Y) end end end
 return minimum
end
local corrected=0;local flowers=0
for _,old in workspace.Decorations:GetChildren() do if old:IsA('BasePart') then
 local n=old.Name;local pivot=old:GetPivot();local hit=ground(pivot.Position.X,pivot.Position.Z)
 if n:find('GrassTuft') then old:Destroy()
 elseif n:find('FlowerBed') and hit then
  local model=decor.HibiscusPatch:Clone();model.Name=n;model:ScaleTo(1.15);model:PivotTo(CFrame.new(pivot.Position.X,hit.Position.Y-.045,pivot.Position.Z)*pivot.Rotation);model.Parent=workspace.Decorations;old:Destroy();flowers+=1
 elseif n:find('ShoreRock') and hit then
  local model=decor.ReefBoulder:Clone();model.Name=n;model:ScaleTo(math.clamp(old.Size.Magnitude/8,1,1.9));model:PivotTo(CFrame.new(pivot.Position.X,hit.Position.Y-.35,pivot.Position.Z)*pivot.Rotation);model.Parent=workspace.Decorations
  for _,p in model:GetChildren() do if p:IsA('MeshPart') then p.CanCollide=true;p.CanQuery=true;p.CollisionFidelity=Enum.CollisionFidelity.Hull end end;old:Destroy();corrected+=1
 elseif hit and (n:find('Palm') or n:find('Bush') or n:find('Shell') or n:find('VillageBarrel') or n:find('TreasureDisplay')) then
  old.CFrame+=Vector3.new(0,hit.Position.Y-bottom(old)-.04,0);corrected+=1
  if n:find('Shell') then old.CastShadow=false end
 end
end end
local rng=Random.new(814);local seabedOnly={floor}
for i=1,88 do
 local angle=i*2.39996323;local radius=100+(i%12)*11.1;local x=math.cos(angle)*radius;local z=math.sin(angle)*radius
 if (Vector2.new(x,z)-Vector2.new(122,100)).Magnitude<31 or (Vector2.new(x,z)-Vector2.new(-132,146)).Magnitude<21 then continue end
 local hit=ground(x,z,seabedOnly)
 if hit then
  local kind=if i%4==0 then 'ReefBoulder' elseif i%3==0 then 'Seagrass' elseif i%2==0 then 'CoralPurple' else 'CoralRed'
  local m=decor[kind]:Clone();m.Name=kind..string.format('_%02d',i);m:ScaleTo(rng:NextNumber(.75,1.8));m:PivotTo(CFrame.new(hit.Position-Vector3.new(0,.1,0))*CFrame.Angles(0,rng:NextNumber(0,math.tau),0));m.Parent=reefs
  for _,p in m:GetChildren() do if p:IsA('MeshPart') then p.CastShadow=kind=='ReefBoulder';p.CanQuery=false;p.CanTouch=false;if kind=='ReefBoulder' then p.CanCollide=true;p.CollisionFidelity=Enum.CollisionFidelity.Hull end end end
 end
end
local wreck=ship:Clone();wreck.Name='TheMarigoldWreck';local wreckCF=CFrame.new(122,-30.35,100)*CFrame.Angles(0,math.rad(-24),0);wreck:PivotTo(wreckCF);wreck.Parent=points
local collisions=Instance.new('Folder');collisions.Name='WalkableHull';collisions.Parent=wreck
part(collisions,'CargoFloor',Vector3.new(14,.4,31),wreckCF*CFrame.new(0,.69,0),false)
for _,z in {-11.8,11.8} do part(collisions,'UpperDeck',Vector3.new(13,.35,8.5),wreckCF*CFrame.new(0,5.04,z),false) end
for _,x in {-5.8,5.8} do part(collisions,'DeckWalkway',Vector3.new(2.4,.35,15),wreckCF*CFrame.new(x,5.04,0),false) end
part(collisions,'PortWall',Vector3.new(.6,4.2,30),wreckCF*CFrame.new(-7.6,2.7,0),false)
for _,z in {-10,10} do part(collisions,'StarboardWall',Vector3.new(.6,4.2,12),wreckCF*CFrame.new(7.6,2.7,z),false) end
for _,z in {-17,17} do part(collisions,'TransomWall',Vector3.new(10,.65,4.2),wreckCF*CFrame.new(0,3.2,z)*CFrame.Angles(math.pi/2,0,0),false) end
local stair=Instance.new('TrussPart');stair.Name='CargoLadder';stair.Size=Vector3.new(2,5,2);stair.CFrame=wreckCF*CFrame.new(-3.8,3,7);stair.Anchored=true;stair.Color=Color3.fromRGB(170,108,68);stair.Material=Enum.Material.Wood;stair.Parent=wreck
local arch=env.TideArch:Clone();arch.Name='TidekeeperRuins';arch:PivotTo(CFrame.new(-132,-51.3,146)*CFrame.Angles(0,.7,0));arch.Parent=points
for _,p in arch:GetChildren() do if p:IsA('MeshPart') then p.CanCollide=true;p.CanQuery=true;p.CollisionFidelity=Enum.CollisionFidelity.PreciseConvexDecomposition end end
local function chest(name,label,cf,count,value,depth)
 local m=chestTemplate:Clone();m.Name=name;m:PivotTo(cf);m:SetAttribute('ExpeditionChest',true);m:SetAttribute('DisplayName',label);m:SetAttribute('DropCount',count);m:SetAttribute('MinimumValue',value);m:SetAttribute('LootDepth',depth);m:SetAttribute('Opened',false);m:SetAttribute('LidHinge',cf*CFrame.new(0,1.87,-1.20))
 local p=part(m,'ChestRoot',Vector3.new(.2,.2,.2),cf*CFrame.new(0,1.1,0),false);p.CanCollide=false;p.CanQuery=false;m.Parent=points;return m
end
chest('CaptainsCache','Captain\'s Cache',wreckCF*CFrame.new(0,.9,0),4,600,42)
chest('TidekeepersCache','Tidekeeper\'s Cache',CFrame.new(-132,-50.85,146)*CFrame.Angles(0,.7,0),5,1250,68)
local ladder=workspace.Ocean:FindFirstChild('ReturnLadder');if ladder then ladder.Size=Vector3.new(2,82,2);ladder.CFrame=CFrame.new(14.1,-35,125) end
-- Replace water only; land and every building stay as authored meshes.
local terrain=workspace.Terrain
for x=0,1 do for z=0,1 do local low=Vector3.new(-1536+x*1536,-84,-1536+z*1536);terrain:ReplaceMaterial(Region3.new(low,low+Vector3.new(1536,88,1536)),4,Enum.Material.Water,Enum.Material.Air) end end
terrain:FillBlock(CFrame.new(0,-42,0),Vector3.new(768,84,768),Enum.Material.Water)
terrain.WaterColor=Color3.fromRGB(20,177,188);terrain.WaterTransparency=.53;terrain.WaterReflectance=.10;terrain.WaterWaveSize=.07;terrain.WaterWaveSpeed=5
workspace.Ocean:SetAttribute('WaterLevel',0);workspace.Ocean:SetAttribute('MinimumWaterLevel',-68);workspace.Ocean:SetAttribute('WaterBoundsMin',Vector3.new(-384,-84,-384));workspace.Ocean:SetAttribute('WaterBoundsMax',Vector3.new(384,0,384));workspace.Ocean:SetAttribute('DrainMechanicImplemented',true)
local light=game:GetService('Lighting');light.ClockTime=14.2;light.GeographicLatitude=22;light.GlobalShadows=true;light.ShadowSoftness=.3;light.Brightness=2.1;light.ExposureCompensation=.05;light.Ambient=Color3.fromRGB(88,108,130);light.OutdoorAmbient=Color3.fromRGB(145,161,176);light.EnvironmentDiffuseScale=.65;light.EnvironmentSpecularScale=.4;light.LightingStyle=Enum.LightingStyle.Realistic;light.PrioritizeLightingQuality=true
local atmosphere=light:FindFirstChildOfClass('Atmosphere');if atmosphere then atmosphere.Density=.22;atmosphere.Offset=.25;atmosphere.Color=Color3.fromRGB(211,237,243);atmosphere.Decay=Color3.fromRGB(102,161,180);atmosphere.Haze=.8;atmosphere.Glare=.15 end
for _,p in light:GetChildren() do if p:IsA('ColorCorrectionEffect') then p.Saturation=.13;p.Contrast=.06;p.Brightness=.015 elseif p:IsA('BloomEffect') then p.Intensity=.08;p.Threshold=1.3 elseif p:IsA('DepthOfFieldEffect') then p.Enabled=false end end
game:GetService('Selection'):Set({});history:SetWaypoint('Underwater expansion installed')
print('DEPTH_SCENE_INSTALLED',game.HttpService:JSONEncode(counts),'grounded',corrected,'flowers',flowers,'reefs',#reefs:GetChildren())
