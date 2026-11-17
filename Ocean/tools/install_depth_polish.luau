assert(not game:GetService('RunService'):IsRunning())
local imported=assert(workspace:FindFirstChild('SuckTheSea_DepthPolish'));imported:PivotTo(CFrame.Angles(0,math.pi,0)*imported:GetPivot())
local env=game.ReplicatedStorage.SeaGame.Assets.Environment
local live=workspace.UnderwaterTerrain.PointsOfInterest.TheMarigoldWreck;local cf=live:GetPivot()
local count=0
for _,p in imported:GetDescendants() do if p:IsA('MeshPart') then
 local group,name=p.Name:match('^(%a+)__(.+)$');p.Name=name;p.Color=Color3.new(1,1,1);p.Anchored=true;p.CanTouch=false;p.RenderFidelity=Enum.RenderFidelity.Automatic;p:SetAttribute('AuthoredIn','Blender 5.2.1');p:SetAttribute('ExpansionAsset',true)
 if group=='Ship' then
  local old=env.Shipwreck:FindFirstChild(name);if old then old:Destroy() end
  p.CanCollide=false;p.CanQuery=false;p.CastShadow=true;p.Material=if name=='Sail' then Enum.Material.Fabric else Enum.Material.SmoothPlastic;p.Parent=env.Shipwreck
  local prior=live:FindFirstChild(name);if prior then prior:Destroy() end
  local clone=p:Clone();clone.CFrame=cf*p.CFrame;clone.Parent=live
  if name=='Bow' then clone.CanCollide=true;clone.CanQuery=true;clone.CollisionFidelity=Enum.CollisionFidelity.PreciseConvexDecomposition end
 else
  local parent=if group=='Ground' then workspace.StarterIsland else workspace.UnderwaterTerrain.Seafloor
  local old=parent:FindFirstChild(name);if old then old:Destroy() end
  p.CanCollide=true;p.CanQuery=true;p.CastShadow=true;p.CollisionFidelity=Enum.CollisionFidelity.PreciseConvexDecomposition;p.Material=Enum.Material.Sand
  if name=='Meadow' then p.TextureID='';p.Color=Color3.fromRGB(101,203,68);p.Material=Enum.Material.SmoothPlastic end
  p.Parent=parent
 end
 count+=1
end end
assert(count==18);imported:Destroy()
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={workspace.UnderwaterTerrain.Seafloor};ray.IgnoreWater=true;ray.RespectCanCollide=true
local random=Random.new(675)
local gardens=Instance.new('Folder');gardens.Name='CoralGardens';gardens.Parent=workspace.UnderwaterTerrain
local centers={{-104,-38},{88,-97},{148,66},{-110,112},{-37,168},{168,-90}}
for index,center in centers do
 for i=1,11 do
  local a=i*2.4;local r=3+math.sqrt(i)*2.1;local x=center[1]+math.cos(a)*r;local z=center[2]+math.sin(a)*r
  local hit=workspace:Raycast(Vector3.new(x,1,z),Vector3.new(0,-85,0),ray)
  if hit then
   local kind=if i%4==0 then 'ReefBoulder' elseif i%3==0 then 'Seagrass' elseif i%2==0 then 'CoralPurple' else 'CoralRed'
   local m=env.Decor[kind]:Clone();m.Name=string.format('Garden%02d_%02d_%s',index,i,kind);m:ScaleTo(random:NextNumber(1.0,2.2));m:PivotTo(CFrame.new(hit.Position-Vector3.new(0,.13,0))*CFrame.Angles(0,a,0));m.Parent=gardens
   for _,p in m:GetChildren() do if p:IsA('BasePart') then p.CastShadow=false;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false end end
  end
 end
end
game:GetService('Selection'):Set({});print('DEPTH_POLISH_INSTALLED',count,'gardenProps',#gardens:GetChildren())
