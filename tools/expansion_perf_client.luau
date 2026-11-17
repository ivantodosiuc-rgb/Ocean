local RunService=game:GetService('RunService')
local p=game.Players.LocalPlayer
local ctl=require(game.ReplicatedStorage.SeaGame.Client.Controller).current
if workspace:GetAttribute('DepthPerformanceRunning') then return end
workspace:SetAttribute('DepthPerformanceRunning',true)
ctl:stop();ctl.ui:close()
if not p.Character:FindFirstChildOfClass('Tool') then assert(ctl.remotes.Request:InvokeServer('ToggleHeld').ok) end
p.Character:PivotTo(CFrame.lookAt(Vector3.new(10,8,126),Vector3.new(22,4,126)))
workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(28,15,142),Vector3.new(10,6,126))
task.wait(2)
local function measure(label,sipping)
 local frames={};local con=RunService.RenderStepped:Connect(function(dt) frames[#frames+1]=dt*1000 end)
 local start=workspace.Ocean:GetAttribute('WaterLevel');local endAt=os.clock()+7
 while os.clock()<endAt do if sipping and not ctl.holding then ctl:begin() end;task.wait(.1) end
 con:Disconnect();table.sort(frames);local sum=0;for _,n in frames do sum+=n end
 local finish=workspace.Ocean:GetAttribute('WaterLevel')
 if sipping and finish>=start-.2 then workspace:SetAttribute('DepthPerformanceRunning',false);error('Performance sample invalid: no actual water was drained') end
 print('EXPANSION_PERF',label,#frames,sum/#frames,frames[math.ceil(#frames*.95)],frames[#frames],start,finish)
end
measure('idle',false);measure('suction',true);ctl:stop()
workspace:SetAttribute('DepthPerformanceRunning',false)
workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
