assert(not game:GetService('RunService'):IsRunning())
local flower
for _,o in workspace.Decorations:GetChildren() do if o.Name:find('FlowerBed') then flower=o;break end end
assert(flower)
local point=flower:GetPivot().Position
workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable
workspace.CurrentCamera.FieldOfView=45
workspace.CurrentCamera.CFrame=CFrame.lookAt(point+Vector3.new(12,7,16),point+Vector3.new(0,1.6,0))
game:GetService('Selection'):Set({})
print('DEPTH_FLOWER_VIEW',flower.Name,point)
