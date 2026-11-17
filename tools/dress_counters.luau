local straw=CFrame.new(-41,5.7,-21)*CFrame.Angles(0,math.rad(12),0)
local delta=straw*CFrame.new(-1,5,4.8)*CFrame.new(-42,10.7,-24.5):Inverse()
for _,name in {'StrawCup','DisplayStraw'} do local p=workspace.Buildings[name];p.CFrame=delta*p.CFrame end
local treasure=CFrame.new(49,5.6,13)*CFrame.Angles(0,math.rad(-65),0)
local display=Instance.new('Model');display.Name='TreasureCounterDisplay';display.Parent=workspace.Buildings
for i=0,1 do
 local p=workspace.Decorations['TreasureDisplay_'..i];local rotation=p.CFrame.Rotation;p.Size*=.72
 p.CFrame=treasure*CFrame.new(-4.9+i*3.4,4.425+p.Size.Y/2,4.8)*rotation;p.Parent=display
end
for i=0,1 do
 local p=workspace.Decorations['Shell_'..i];local rotation=p.CFrame.Rotation
 p.CFrame=treasure*CFrame.new(2+i*2.5,4.425+p.Size.Y/2,4.8)*rotation;p.Parent=display
end
workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable;workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(12,15,35),Vector3.new(43,10,15));workspace.CurrentCamera.FieldOfView=58
print('COUNTER_DISPLAYS_VERIFIED','straw cups on STRAWS counter; two chests and two shells on TREASURES counter')
