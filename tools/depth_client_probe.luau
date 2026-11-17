local c=require(game.ReplicatedStorage.SeaGame.Client.Controller).current;local p=game.Players.LocalPlayer
print('DEPTH_CLIENT_PROBE',c.state and c.state.held,c.holding,c.near,c.point,p.Character:GetPivot(),p.Character:FindFirstChildOfClass('Tool'),c.world.level,c.world.complete,c.world.refilling)
local param=RaycastParams.new();param.FilterType=Enum.RaycastFilterType.Include;param.FilterDescendantsInstances={workspace.Terrain};param.IgnoreWater=false
local hit=workspace:Raycast(Vector3.new(20,4,126),Vector3.new(0,-15,0),param);print('DEPTH_WATER_RAY',hit and hit.Position,hit and hit.Material)
local started=c:begin();print('DEPTH_BEGIN',started);task.wait(1);print('DEPTH_HOLDING_AFTER',c.holding,c.point,c.state and c.state.held)
