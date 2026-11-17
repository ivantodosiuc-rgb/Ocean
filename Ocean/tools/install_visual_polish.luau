assert(not game:GetService('RunService'):IsRunning(),'Edit mode required')
local history=game:GetService('ChangeHistoryService');history:SetWaypoint('Before STEP4 visuals')
local imported=assert(workspace:FindFirstChild('SuckTheSea_VisualPolish'),'Import reviewed FBX first')
local assets=game.ReplicatedStorage.SeaGame.Assets;local env=assets.Environment
local library=Instance.new('Folder');library.Name='Polish';library.Parent=env
imported:PivotTo(CFrame.Angles(0,math.pi,0)*imported:GetPivot())
local ship=workspace.UnderwaterTerrain.PointsOfInterest.TheMarigoldWreck;local shipCF=ship:GetPivot()
local chests={};for _,m in workspace.UnderwaterTerrain.PointsOfInterest:GetChildren() do if m:GetAttribute('ExpeditionChest') then table.insert(chests,{model=m,cf=m:GetPivot()}) end end
local meshes={};for _,p in imported:GetDescendants() do if p:IsA('MeshPart') then table.insert(meshes,p) end end
assert(#meshes==34,'Expected 34 reviewed meshes, got '..#meshes)
local function prefab(p,name)
 local m=Instance.new('Model');m.Name=name;m.WorldPivot=CFrame.new();p.Name='Visual';p.Parent=m;m.Parent=library;return m
end
local counts={};local appearances=0
for _,p in meshes do
 local group,name=p.Name:match('^(%a+)__(.+)$');assert(group,p.Name)
 p.Color=Color3.new(1,1,1);p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Material=Enum.Material.SmoothPlastic;p.RenderFidelity=Enum.RenderFidelity.Automatic
 p:SetAttribute('AuthoredIn','Blender 5.2.1');p:SetAttribute('VisualPolishAsset',true)
 local appearance=p:FindFirstChildOfClass('SurfaceAppearance');if appearance then appearances+=1;appearance.Color=Color3.new(1,1,1) end
 counts[group]=(counts[group] or 0)+1
 if group=='Reef' or group=='Coast' then prefab(p,name)
 elseif group=='Ship' then
  p.Name=name;p.CastShadow=true
  local old=env.Shipwreck:FindFirstChild(name);if old then old:Destroy() end;p.Parent=env.Shipwreck
  local prior=ship:FindFirstChild(name);local collision=prior and prior.CanCollide;local query=prior and prior.CanQuery;local fidelity=prior and prior:IsA('MeshPart') and prior.CollisionFidelity
  if prior then prior:Destroy() end
  local clone=p:Clone();clone.CFrame=shipCF*p.CFrame;clone.CanCollide=collision or false;clone.CanQuery=query or false
  if fidelity then clone.CollisionFidelity=fidelity end;clone.Parent=ship
 elseif group=='Chest' then
  p.Name=name;p.CastShadow=true;local old=env.Chest:FindFirstChild(name);if old then old:Destroy() end;p.Parent=env.Chest
  for _,record in chests do local prior=record.model:FindFirstChild(name);if prior then prior:Destroy() end;local clone=p:Clone();clone.CFrame=record.cf*p.CFrame;clone.Parent=record.model;if name=='Lid' then record.model:SetAttribute('LidClosedCFrame',clone.CFrame) end end
 elseif group=='Boat' then
  local old=workspace.Ocean:FindFirstChild('LittleBoat');assert(old);old:Destroy();p.Name='LittleBoat';p.CastShadow=true
  p.CFrame=CFrame.new(22,-.45,123)*CFrame.Angles(0,math.rad(8),0)*p.CFrame;p.Parent=workspace.Ocean
 elseif group=='Dock' then
  local old=workspace.Ocean:FindFirstChild(name);if old then p.CanCollide=old.CanCollide;p.CanQuery=old.CanQuery;p.CollisionFidelity=old.CollisionFidelity;old:Destroy() end
  p.Name=name;p.CastShadow=true;p.Parent=workspace.Ocean
 else error(group) end
end
imported:Destroy()
local floor=workspace.UnderwaterTerrain.Seafloor
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={workspace.StarterIsland.GoldenShore,workspace.StarterIsland.Meadow,floor};params.RespectCanCollide=true;params.IgnoreWater=true
local function ground(x,z) return workspace:Raycast(Vector3.new(x,20,z),Vector3.new(0,-110,0),params) end
local rng=Random.new(40319)
local function place(kind,parent,x,z,scale,angle,name,wet)
 local hit=ground(x,z);if not hit then return nil end
 local m=assert(library:FindFirstChild(kind),kind):Clone();m.Name=name or kind;m:ScaleTo(scale)
 local up=hit.Normal:Lerp(Vector3.yAxis,.7).Unit;local right=Vector3.xAxis-up*up.X;right=right.Unit
 m:PivotTo(CFrame.fromMatrix(hit.Position-Vector3.new(0,.07,0),right,up,right:Cross(up))*CFrame.Angles(0,angle,0));m.Parent=parent
 m:SetAttribute('PolishVariant',kind);m:SetAttribute('GroundY',hit.Position.Y)
 for _,p in m:GetDescendants() do if p:IsA('MeshPart') then
  p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false
  if wet then p:SetAttribute('Wettable',true);p:SetAttribute('ShoreBaseY',hit.Position.Y);end
 end end
 return m
end
local flowers={};for _,m in workspace.Decorations:GetChildren() do if m.Name:find('Flower') or m.Name:find('Hibiscus') then table.insert(flowers,m) end end
local coast=Instance.new('Folder');coast.Name='CoastalPlanting';coast.Parent=workspace.Decorations
for i,old in flowers do
 local cf=old:GetPivot();old:Destroy()
 place(if i%3==0 then 'CoastalShrub' else 'BroadleafGrass',coast,cf.X,cf.Z,if i%3==0 then 1.05 else 1.3,rng:NextNumber(0,math.tau),'GardenFoliage_'..i,false)
 place('DuneGrass',coast,cf.X+1.7,cf.Z-.7,.8,rng:NextNumber(0,math.tau),'GardenGrass_'..i,false)
end
for i=1,16 do
 local a=i*math.tau/16+.17;local r=72+(i%3)*2
 if math.abs(math.cos(a)*r)<16 and math.sin(a)>0 then continue end
 place(if i%4==0 then 'Driftwood' else 'DuneGrass',coast,math.cos(a)*r,math.sin(a)*r,rng:NextNumber(.85,1.25),a,'BeachDetail_'..i,true)
end
local kinds={'SunsetStaghorn','VioletSeaFan','TurquoiseTable','GoldenBrain','PeachCups','LavenderFingers','CrimsonLettuce','CobaltTubes','SunbeamAntlers','MintPagoda'}
local reefCount=0;local variants={}
local reefFolder=Instance.new('Folder');reefFolder.Name='PolishedReefs';reefFolder.Parent=workspace.UnderwaterTerrain
for _,container in {workspace.UnderwaterTerrain.ReefLife,workspace.UnderwaterTerrain.CoralGardens} do
 for _,old in container:GetChildren() do if old.Name:find('Coral') then
  local cf=old:GetPivot();old:Destroy();reefCount+=1
  local kind=kinds[(reefCount-1)%#kinds+1];local scale=rng:NextNumber(.8,1.45)
  if kind=='SunbeamAntlers' then scale*=.9 end
  local m=place(kind,reefFolder,cf.X,cf.Z,scale,rng:NextNumber(0,math.tau),string.format('Reef_%03d_%s',reefCount,kind),true)
  if m then variants[kind]=(variants[kind] or 0)+1 end
 end end
end
-- Small composed groups on shallow sand, with generous empty areas between gardens.
for cluster=1,9 do
 local a=cluster*math.tau/9+.2;local r=93+(cluster%3)*5
 if math.abs(math.cos(a)*r)<18 and math.sin(a)>0 then continue end
 for j=1,3 do
  local kind=kinds[((cluster-1)*3+j-1)%#kinds+1]
  local x,z=math.cos(a)*r+math.cos(j*2.4)*3,math.sin(a)*r+math.sin(j*2.4)*3
  local m=place(kind,reefFolder,x,z,rng:NextNumber(.75,1.2),a+j,string.format('Shallows_%02d_%s',cluster,kind),true)
  if m then reefCount+=1;variants[kind]=(variants[kind] or 0)+1 end
 end
end
for _,p in workspace.Decorations:GetDescendants() do if p:IsA('MeshPart') and (p.Name:find('Rock') or (p.Parent:IsA('Model') and p.Parent.Name:find('Rock'))) then p:SetAttribute('Wettable',true);p:SetAttribute('ShoreBaseY',p.Position.Y-p.Size.Y*.5) end end
local terrain=workspace.Terrain
terrain.WaterColor=Color3.fromRGB(26,153,166);terrain.WaterTransparency=.6;terrain.WaterReflectance=.035;terrain.WaterWaveSize=.055;terrain.WaterWaveSpeed=4.5
local light=game:GetService('Lighting');light.ClockTime=14.35;light.GeographicLatitude=24;light.GlobalShadows=true;light.ShadowSoftness=.44;light.Brightness=1.85;light.ExposureCompensation=-.03
light.Ambient=Color3.fromRGB(94,114,132);light.OutdoorAmbient=Color3.fromRGB(153,170,182);light.EnvironmentDiffuseScale=.7;light.EnvironmentSpecularScale=.32
local atmosphere=light:FindFirstChildOfClass('Atmosphere');if atmosphere then atmosphere.Density=.25;atmosphere.Offset=.23;atmosphere.Color=Color3.fromRGB(210,236,242);atmosphere.Decay=Color3.fromRGB(109,166,188);atmosphere.Haze=1.15;atmosphere.Glare=.12 end
for _,effect in light:GetChildren() do
 if effect:IsA('ColorCorrectionEffect') then effect.Saturation=.07;effect.Contrast=.045;effect.Brightness=0;effect.TintColor=Color3.fromRGB(255,252,244)
 elseif effect:IsA('BloomEffect') then effect.Intensity=.045;effect.Threshold=1.6;effect.Size=24
 elseif effect:IsA('DepthOfFieldEffect') then effect.Enabled=false end
end
workspace.StarterIsland.Meadow.Color=Color3.fromRGB(104,203,69);workspace.StarterIsland.Meadow.Material=Enum.Material.SmoothPlastic
game:GetService('Selection'):Set({});history:SetWaypoint('STEP4 Blender assets and composition')
print('VISUAL_POLISH_INSTALLED',game.HttpService:JSONEncode({meshes=#meshes,groups=counts,appearances=appearances,flowersRemoved=#flowers,coastalProps=#coast:GetChildren(),corals=reefCount,variants=variants}))
