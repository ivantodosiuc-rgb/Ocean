local p=game.Players.LocalPlayer
local ctl=require(game.ReplicatedStorage.SeaGame.Client.Controller).current
ctl:stop();ctl.ui:close()
local char=p.Character
char:PivotTo(CFrame.lookAt(Vector3.new(10,8,126),Vector3.new(22,4,126)))
local cam=workspace.CurrentCamera
cam.CameraType=Enum.CameraType.Scriptable
cam.CFrame=CFrame.lookAt(Vector3.new(28,15,142),Vector3.new(10,6,126))
local deadline=os.clock()+45
while not ctl.holding and os.clock()<deadline do task.wait(.1) end
assert(ctl.holding,'Recording: native hold did not begin')
local before=workspace.Ocean:GetAttribute('WaterLevel')
task.wait(4)
assert(ctl.holding and ctl.fx.streams[p.UserId],'Recording: suction stopped')
local after=workspace.Ocean:GetAttribute('WaterLevel')
assert(after<before-.1,'Recording: ocean did not drain')
print('STEP3_RECORD_NATIVE_PASS',before,after)
