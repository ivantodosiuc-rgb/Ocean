local m=workspace:FindFirstChild('SuckTheSea_Chests');assert(m,'Chest import not finished')
m:PivotTo(CFrame.Angles(0,math.pi,0)*m:GetPivot())
local count=0
for _,p in m:GetChildren() do if p:IsA('MeshPart') then
 local category,name=p.Name:match('^(.-)__(.+)$');local f=workspace[category]
 local old=f:FindFirstChild(name);if old then old:Destroy() end
 p.Name=name;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.Material=Enum.Material.SmoothPlastic;p.RenderFidelity=Enum.RenderFidelity.Automatic
 p:SetAttribute('AuthoredIn','Blender 5.2.1');p.Parent=f;count+=1
end end
m:Destroy();assert(count==6,'Expected all six chest meshes')
-- The distant seabed uses deep-water color; the playable lagoon has golden sand.
-- This also prevents sand from appearing at the terrain-water draw-distance boundary.
for _,p in workspace.UnderwaterTerrain:GetChildren() do
 if p:IsA('BasePart') and p.Name:find('DeepSeabed_') then
  p.Position-=Vector3.new(0,1,0);p.Color=Color3.fromRGB(18,143,156);p.Material=Enum.Material.SmoothPlastic
 end
end
local bed=Instance.new('Part');bed.Name='LagoonSandFloor';bed.Size=Vector3.new(560,10,560);bed.CFrame=CFrame.new(0,-45,0)
bed.Color=Color3.fromRGB(224,197,137);bed.Material=Enum.Material.Sand;bed.Anchored=true;bed.CanTouch=false;bed.Parent=workspace.UnderwaterTerrain
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(118,105,155),Vector3.new(0,2,24));workspace.CurrentCamera.FieldOfView=50
game:GetService('Selection'):Set({})
print('FINAL_CHESTS_UPDATED',count)
print('FINAL_MAP_STATE','edit',game:GetService('RunService'):IsEdit(),'water',workspace.Ocean:GetAttribute('WaterLevel'))
