local RunService=game:GetService('RunService');local ctl=require(game.ReplicatedStorage.SeaGame.Client.Controller).current
local ship=workspace.UnderwaterTerrain.PointsOfInterest.TheMarigoldWreck;local cf=ship:GetPivot();local camera=workspace.CurrentCamera
camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=52;camera.CFrame=CFrame.lookAt((cf*CFrame.new(5,17,13)).Position,(cf*CFrame.new(0,1,0)).Position)
local chest=workspace.UnderwaterTerrain.PointsOfInterest.CaptainsCache;local lid=chest.Lid;local original=lid.CFrame;local samples={};local start=nil
local connection=RunService.RenderStepped:Connect(function()
 if start then local relative=original:ToObjectSpace(lid.CFrame);local _,angle=relative:ToAxisAngle();table.insert(samples,{time=os.clock()-start,angle=angle,position=lid.Position}) end
end)
task.wait(3.5);start=os.clock();local result=game.ReplicatedStorage.SeaGame.Remotes.Request:InvokeServer('OpenChest','CaptainsCache');assert(result.ok,'Chest opening failed')
task.wait(3);connection:Disconnect()
local maxStep=0;local maxAngle=0;for i=2,#samples do if samples[i].time-samples[i-1].time<.05 then maxStep=math.max(maxStep,(samples[i].position-samples[i-1].position).Magnitude) end;maxAngle=math.max(maxAngle,samples[i].angle) end
assert(maxAngle>math.rad(106),'Lid spring has no overshoot');assert(maxStep<.8,'Lid teleported during animation')
local rays=0;for _,o in workspace.LocalSeaEffects:GetChildren() do if o.Name=='ChestRewardLight' then rays+=1 end end
print('POLISH_CHEST_ANIMATION_PASS',game.HttpService:JSONEncode({frames=#samples,maxStep=maxStep,maxAngleDegrees=math.deg(maxAngle),restAngleDegrees=math.deg(samples[#samples].angle),temporaryLightsAfter3s=rays}))
