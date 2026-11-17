local p=game.Players.LocalPlayer;local ctl=require(game.ReplicatedStorage.SeaGame.Client.Controller).current
ctl:stop();ctl.ui:close()
if not p.Character:FindFirstChildOfClass('Tool') then assert(ctl.remotes.Request:InvokeServer('ToggleHeld').ok) end
p.Character:PivotTo(CFrame.lookAt(Vector3.new(10,8,126),Vector3.new(22,4,126)))
local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=55
camera.CFrame=CFrame.lookAt(Vector3.new(30,17,149),Vector3.new(7,7,117))
task.wait(1)
local finish=os.clock()+32;local frames={};local active=0
local connection=game:GetService('RunService').RenderStepped:Connect(function(dt) if ctl.holding then frames[#frames+1]=dt*1000 end end)
while os.clock()<finish do if not ctl.holding then ctl:begin() end;if ctl.holding then active+=1 end;task.wait(.1) end
ctl:stop();connection:Disconnect();task.wait(2)
assert(active>150,'Suction did not remain active')
assert(ctl.world.OceanRemainingPercent<100,'No server progress reached the client')
assert(ctl.ui.seaLabel.Text==string.format('%.2f%%',ctl.world.OceanRemainingPercent),'HUD formatting does not match server state')
assert(math.abs(ctl.ui.seaTarget-ctl.world.OceanRemainingPercent)<1e-9,'HUD discarded precision')
table.sort(frames);local sum=0;for _,n in frames do sum+=n end
print('OCEAN_CLIENT_PASS',ctl.ui.seaLabel.Text,ctl.world.OceanRemainingPercent,'frames',#frames,'averageMs',sum/#frames,'p95Ms',frames[math.ceil(#frames*.95)])
