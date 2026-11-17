assert(not game:GetService('RunService'):IsRunning(),'Edit mode only')
assert(not workspace:GetAttribute('ExpeditionInstalled'),'One-time installer already applied')
local imported=assert(workspace:FindFirstChild('SuckTheSea_Expedition'),'Native import is required')
local layout=game.HttpService:JSONDecode([====[LAYOUT_JSON]====])
local history=game:GetService('ChangeHistoryService');local record=history:TryBeginRecording('ExpeditionDepth','Five ocean zones and authored exploration sites')
local assets=game.ReplicatedStorage.SeaGame.Assets
local backup=Instance.new('Folder');backup.Name='Step5SceneBackup';backup.Parent=game.ServerStorage
local lib=Instance.new('Folder');lib.Name='Expedition';lib.Parent=assets.Environment
local byName={};for _,p in imported:GetDescendants() do if p:IsA('MeshPart') then byName[p.Name]=p end end
local function find(path)
 local p=game;for name in path:gmatch('[^.]+') do p=assert(p:FindFirstChild(name),path) end;return p
end
local function visual(p,name)
 p=p:Clone();p.Name=name or 'Visual';p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Color=Color3.new(1,1,1);p.CFrame=CFrame.Angles(0,math.pi,0)*p.CFrame;p.RenderFidelity=Enum.RenderFidelity.Automatic
 local sa=p:FindFirstChildOfClass('SurfaceAppearance');if sa then p.TextureID=sa.ColorMap end
 return p
end
local function prefab(source,folder,id)
 local m=Instance.new('Model');m.Name=id;local p=visual(source);p:SetAttribute('SurfaceSource','step5__'..source.Name);p.Parent=m;m.WorldPivot=CFrame.new();m.Parent=folder;return m
end
for name,p in byName do
 local kind,id=name:match('^(%a+)__(.+)$')
 if kind=='Loot' then assert(not assets.Loot:FindFirstChild(id));prefab(p,assets.Loot,id)
 elseif kind=='Icon' then prefab(p,assets.Icons,id)
 elseif kind=='Prop' then prefab(p,lib,id) end
end
local seabed=workspace.UnderwaterTerrain.Seafloor
for _,p in seabed:GetChildren() do p.Parent=backup end
for name,p in byName do if name:match('^Seabed__') then
 local model=Instance.new('Model');model.Name=name:gsub('Seabed__','Chunk_');model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 local part=visual(p,'Sand');part.CanCollide=true;part.CanQuery=true;part.CanTouch=false;part.CollisionFidelity=Enum.CollisionFidelity.PreciseConvexDecomposition
 -- World-aligned tiling preserves sand grain scale over long slope sections.
 for _,sa in part:GetChildren() do if sa:IsA('SurfaceAppearance') then sa:Destroy() end end
 part.TextureID='';part.Material=Enum.Material.Sand;part.MaterialVariant='Sea_LagoonSand';part.Color=Color3.fromRGB(238,214,165)
 part:SetAttribute('SurfaceSource','step5__'..name);part:SetAttribute('Wettable',true);part:SetAttribute('ShoreBaseY',part.Position.Y-part.Size.Y*.45);game.CollectionService:AddTag(part,'SeaWettable');part.Parent=model;model.Parent=seabed
end end
-- Support plane protects the outer fringe; its top stays below the visible lowest sand.
local floor=Instance.new('Part');floor.Name='AbyssSafetyFloor';floor.Size=Vector3.new(768,4,768);floor.CFrame=CFrame.new(0,-170,0);floor.Material=Enum.Material.Sand;floor.MaterialVariant='Sea_LagoonSand';floor.Color=Color3.fromRGB(205,193,158);floor.Anchored=true;floor.CanTouch=false;floor.Parent=seabed
for _,f in layout.fits do local p=find(f.path);p.CFrame+=Vector3.new(0,f.deltaY,0);p:SetAttribute('SupportMaxGap',-.07);p:SetAttribute('SupportSamples',f.samples) end
local points=workspace.UnderwaterTerrain.PointsOfInterest
local function moveChest(chest,delta)
 chest:PivotTo(chest:GetPivot()+delta)
 for _,key in {'LidHinge','LidClosedCFrame'} do local cf=chest:GetAttribute(key);if typeof(cf)=='CFrame' then chest:SetAttribute(key,cf+delta) end end
end
for _,move in layout.moves do
 local delta=Vector3.new(table.unpack(move.delta));points[move.name]:PivotTo(points[move.name]:GetPivot()+delta);moveChest(points[move.chest],delta)
 points[move.chest]:SetAttribute('LootDepth',if move.chest=='CaptainsCache' then 80 else 112)
 points[move.chest]:SetAttribute('MinimumValue',if move.chest=='CaptainsCache' then 600 else 1250)
end
local models={}
for _,p in layout.pois do
 local m=points:FindFirstChild(p.id)
 if not m then m=Instance.new('Model');m.Name=p.id;m.WorldPivot=CFrame.new(p.x,p.y,p.z);m.Parent=points end
 m:SetAttribute('PointOfInterest',true);m:SetAttribute('DisplayName',p.name);m:SetAttribute('DepthZone',p.zone);m:SetAttribute('DiscoveryPosition',Vector3.new(p.x,p.y,p.z));m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;models[p.id]=m
end
local function blocker(parent,name,cf,size)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Transparency=1;p.Anchored=true;p.CanTouch=false;p.CastShadow=false;p.Parent=parent
end
for _,f in layout.placements do
 local m=lib[f.asset]:Clone();m.Name=f.name;m:ScaleTo(f.scale);m:PivotTo(CFrame.new(f.x,f.y,f.z)*CFrame.Angles(0,f.yaw,0));local p=m.Visual
 p:SetAttribute('Wettable',true);p:SetAttribute('ShoreBaseY',f.y);p:SetAttribute('SupportMaxGap',-.10);p:SetAttribute('SupportSamples',f.samples);game.CollectionService:AddTag(p,'SeaWettable')
 if f.collide then
  if f.asset:find('Arch') then
   local _,size=m:GetBoundingBox();local pivot=m:GetPivot()
   for _,side in {-1,1} do blocker(m,'ArchFootCollider',pivot*CFrame.new(side*size.X*.41,size.Y*.25,0),Vector3.new(size.X*.17,size.Y*.5,size.Z*.75)) end
   blocker(m,'ArchCrownCollider',pivot*CFrame.new(0,size.Y*.88,0),Vector3.new(size.X*.6,size.Y*.15,size.Z*.7))
  elseif f.asset=='SeaCave' or f.asset=='CrystalCave' or f.asset=='RockShelf' then p.CanCollide=true;p.CanQuery=true;p.CollisionFidelity=Enum.CollisionFidelity.PreciseConvexDecomposition
  else p.CanCollide=true;p.CanQuery=true;p.CollisionFidelity=Enum.CollisionFidelity.Hull end
 end
 m.Parent=models[f.poi]
end
local reefs=Instance.new('Folder');reefs.Name='ExpeditionReefs';reefs.Parent=workspace.UnderwaterTerrain
for _,f in layout.reuses do
 local p=find(f.template):Clone();p.Name='Visual';p.Size*=f.scale;p.CFrame=CFrame.new(table.unpack(f.cf));p.Anchored=true;p.CanTouch=false;p.CanQuery=false;p.CanCollide=false;p.CastShadow=p.Size.Magnitude>8
 local m=Instance.new('Model');m.Name=f.name;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;p.Parent=m;m.Parent=reefs;p:SetAttribute('SupportMaxGap',-.07);p:SetAttribute('SupportSamples',f.samples);p:SetAttribute('ShoreBaseY',p.Position.Y-p.Size.Y*.45);p:SetAttribute('Wettable',true);game.CollectionService:AddTag(p,'SeaWettable')
end
-- The treasury reuses the proven animated chest assembly and server reward flow.
local chest=points.TidekeepersCache:Clone();chest.Name='AbyssalCache';chest.Parent=points
local target=Vector3.new(47,-145.6,293);moveChest(chest,target-chest:GetPivot().Position);chest:SetAttribute('DisplayName','Royal Abyssal Treasury');chest:SetAttribute('MinimumValue',4200);chest:SetAttribute('LootDepth',150);chest:SetAttribute('DropCount',4);chest:SetAttribute('Opened',false);chest:SetAttribute('OpenedAt',nil)
for name,sites in layout.drops do
 local c=points[name];c.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 local folder=c:FindFirstChild('DropSites')or Instance.new('Folder');folder.Name='DropSites';folder.Parent=c;folder:ClearAllChildren()
 for i,s in sites do local p=Instance.new('Part');p.Name='Drop_'..i;p.Size=Vector3.one*.12;p.Position=Vector3.new(table.unpack(s.position));p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p:SetAttribute('SurfaceNormal',Vector3.new(table.unpack(s.normal)));p.Parent=folder end
end
for _,root in {workspace.Decorations,workspace.UnderwaterTerrain} do for _,p in root:GetDescendants() do if p:IsA('MeshPart')and p:GetAttribute('Wettable')then
 p:SetAttribute('ShoreBaseY',p.Position.Y-p.Size.Y*.45);game.CollectionService:AddTag(p,'SeaWettable')
end end end
workspace.Ocean:SetAttribute('MinimumWaterLevel',-168);workspace.Ocean:SetAttribute('DrainableBottom',-168);workspace.Ocean:SetAttribute('WaterBoundsMin',Vector3.new(-384,-172,-384));workspace.Ocean:SetAttribute('TotalOceanVolume',99090432);workspace.Ocean:SetAttribute('RemainingWaterVolume',99090432);workspace.Ocean:SetAttribute('OceanRemainingPercent',100)
workspace:SetAttribute('ExpeditionSeed',layout.seed);workspace:SetAttribute('ExpeditionInstalled',true);workspace:SetAttribute('OceanDepthZoneHeight',32)
workspace.FallenPartsDestroyHeight=-350
-- Runtime-independent static geometry: streaming affects clients only.
for _,container in {workspace.Buildings,workspace.NPCs} do for _,m in container:GetChildren() do if m:IsA('Model')then m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic end end end
local rig=workspace.Ocean:FindFirstChild('WetShoreRig');if rig then rig.ModelStreamingMode=Enum.ModelStreamingMode.Persistent end
for _,m in workspace.Ocean:GetChildren()do if m:IsA('Model')and m.Name:find('Boat')then m.ModelStreamingMode=Enum.ModelStreamingMode.Persistent end end
for _,m in {workspace.StarterIsland}do if m:IsA('Model')then m.ModelStreamingMode=Enum.ModelStreamingMode.Persistent end end
imported:Destroy();game.Selection:Set({})
if record then history:FinishRecording(record,Enum.FinishRecordingOperation.Commit)end
return {chunks=60,landmarks=#layout.pois,newProps=#layout.placements,reusedProps=#layout.reuses,refitted=#layout.fits,resources=#assets.Loot:GetChildren()}
