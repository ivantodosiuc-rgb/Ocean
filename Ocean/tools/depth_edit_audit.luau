assert(not game:GetService('RunService'):IsRunning())
local assets=game.ReplicatedStorage.SeaGame.Assets
assert(#assets.Loot:GetChildren()==50)
assert(#workspace.UnderwaterTerrain.Seafloor:GetChildren()==13)
assert(#workspace.UnderwaterTerrain.CoralGardens:GetChildren()==66)
assert(workspace.UnderwaterTerrain.PointsOfInterest.TheMarigoldWreck:FindFirstChild('Bow'))
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={workspace.UnderwaterTerrain.Seafloor,workspace.StarterIsland.GoldenShore,workspace.StarterIsland.Meadow};ray.IgnoreWater=true;ray.RespectCanCollide=true
local samples=0;local maxSlope=0
for _,angle in {0,math.pi*.5,math.pi,math.pi*1.5} do
 local previous=nil
 for radius=50,235,5 do
  local hit=workspace:Raycast(Vector3.new(math.cos(angle)*radius,20,math.sin(angle)*radius),Vector3.new(0,-110,0),ray);assert(hit,'Final collision hole')
  if previous then maxSlope=math.max(maxSlope,math.abs(hit.Position.Y-previous)/5) end
  previous=hit.Position.Y;samples+=1
 end
end
print('DEPTH_FINAL_COLLISIONS_PASS',samples,maxSlope)
local inspect={}
for _,p in {workspace.StarterIsland.GoldenShore,workspace.StarterIsland.Meadow,workspace.UnderwaterTerrain.Seafloor.Slope_00} do table.insert(inspect,{name=p.Name,position=tostring(p.Position),size=tostring(p.Size),texture=p.TextureID,mesh=p.MeshId}) end
local water=workspace.Terrain:ReadVoxelChannels(Region3.new(Vector3.new(300,-4,300),Vector3.new(304,0,304)),4,{'LiquidOccupancy'}).LiquidOccupancy[1][1][1]
local outside=workspace.Terrain:ReadVoxelChannels(Region3.new(Vector3.new(600,-4,600),Vector3.new(604,0,604)),4,{'LiquidOccupancy'}).LiquidOccupancy[1][1][1]
assert(water==1 and outside==0,'Water resizing failed')
print('DEPTH_EDIT_AUDIT',game.HttpService:JSONEncode(inspect),water,outside)
