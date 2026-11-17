local p=game.Players.LocalPlayer;local c=require(game.ReplicatedStorage.SeaGame.Client.Controller).current;c:stop();c.ui:close()
local char=p.Character;local endAt=os.clock()+40
assert(char:FindFirstChildOfClass('Tool'),'Start with straw held')
print('DEPTH_NATIVE_ONE_READY')
while char:FindFirstChildOfClass('Tool') and os.clock()<endAt do task.wait(.05) end
assert(not char:FindFirstChildOfClass('Tool'),'Key 1 did not put straw away')
print('DEPTH_NATIVE_ONE_HIDDEN')
while not char:FindFirstChildOfClass('Tool') and os.clock()<endAt do task.wait(.05) end
assert(char:FindFirstChildOfClass('Tool'),'Key 1 did not draw straw again')
print('DEPTH_NATIVE_ONE_PASS')
workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable;workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(175,12,155),Vector3.new(122,-24,100));workspace.CurrentCamera.FieldOfView=55
