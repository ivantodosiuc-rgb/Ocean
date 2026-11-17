local boat=workspace.Ocean.LittleBoat
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={workspace.UnderwaterTerrain.Seafloor};ray.IgnoreWater=true;ray.RespectCanCollide=true
local hit=workspace:Raycast(Vector3.new(boat.Position.X,10,boat.Position.Z),Vector3.new(0,-110,0),ray);assert(hit)
-- Float height measured from the saved Edit-mode boat, independent of current tide.
local floatY=1.39760292
local deadline=os.clock()+45
repeat task.wait(.1) until (workspace.Ocean:GetAttribute('WaterLevel') or 0)<=-60 or os.clock()>deadline
task.wait(1)
assert(math.abs(boat.Position.Y-boat.Size.Y/2-hit.Position.Y)<.15,'Boat did not rest on seabed')
print('DEPTH_BOAT_GROUNDED',boat.Position.Y,hit.Position.Y)
deadline=os.clock()+35
repeat task.wait(.1) until (workspace.Ocean:GetAttribute('WaterLevel') or -1)>=-.01 or os.clock()>deadline
task.wait(1)
assert(math.abs(boat.Position.Y-floatY)<.15,'Boat did not rise with returned water')
print('DEPTH_BOAT_PASS','Boat rests on seabed and floats again')
