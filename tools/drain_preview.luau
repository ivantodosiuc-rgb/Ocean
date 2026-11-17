assert(game:GetService('RunService'):IsRunning(),'Preview only in Play, never edit the saved water level')
local t=workspace.Terrain
t:FillBlock(CFrame.new(0,-20,0),Vector3.new(3072,40,3072),Enum.Material.Air)
t:FillBlock(CFrame.new(0,-28,0),Vector3.new(3072,24,3072),Enum.Material.Water)
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include
local banks={};for _,p in workspace.UnderwaterTerrain:GetChildren() do if p.Name:find('Sandbank') then table.insert(banks,p) end end
params.FilterDescendantsInstances=banks;params.RespectCanCollide=true
for _,pos in {Vector3.new(-123,0,19),Vector3.new(115,0,-48),Vector3.new(80,0,135),Vector3.new(-65,0,-126)} do
 local hit=workspace:Raycast(pos+Vector3.new(0,30,0),Vector3.new(0,-80,0),params)
 print('DRAIN_PREVIEW_BANK',pos.X,pos.Z,hit and hit.Position.Y or 'MISSING')
end
workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(210,170,230),Vector3.new(0,-8,10));workspace.CurrentCamera.FieldOfView=55
game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.All,false)
print('DRAIN_PREVIEW_DONE','temporary Play level -16; saved map stays at 0')
