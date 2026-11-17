local ctl=require(game.ReplicatedStorage.SeaGame.Client.Controller).current
local ship=workspace.UnderwaterTerrain.PointsOfInterest.TheMarigoldWreck
local cf=ship:GetPivot();local camera=workspace.CurrentCamera
camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=55
camera.CFrame=CFrame.lookAt((cf*CFrame.new(5,17,13)).Position,(cf*CFrame.new(0,1,0)).Position)
task.wait(3)
local result=game.ReplicatedStorage.SeaGame.Remotes.Request:InvokeServer('OpenChest','CaptainsCache')
assert(result.ok,'Recorded chest opening failed')
print('DEPTH_CHEST_ANIMATION_RECORDED')
