local cf=workspace.UnderwaterTerrain.PointsOfInterest.TheMarigoldWreck:GetPivot()
local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=55
camera.CFrame=CFrame.lookAt((cf*CFrame.new(36,24,40)).Position,(cf*CFrame.new(0,3,0)).Position)
require(game.ReplicatedStorage.SeaGame.Client.Controller).current.ui:close()
