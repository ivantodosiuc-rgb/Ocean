for _,p in workspace.UnderwaterTerrain:GetChildren() do if p:IsA('MeshPart') and p.Name:find('Sandbank') then p.CanCollide=true;p.CollisionFidelity=Enum.CollisionFidelity.PreciseConvexDecomposition end end
workspace.Terrain:FillBlock(CFrame.new(0,-20,0),Vector3.new(3072,40,3072),Enum.Material.Water)
workspace.Ocean:SetAttribute('WaterBoundsMin',Vector3.new(-1536,-40,-1536));workspace.Ocean:SetAttribute('WaterBoundsMax',Vector3.new(1536,0,1536))
local original=workspace.UnderwaterTerrain.DeepSeabed
for _,x in {-768,768} do for _,z in {-768,768} do local p=original:Clone();p.Name='DeepSeabed_'..x..'_'..z;p.Size=Vector3.new(1536,12,1536);p.CFrame=CFrame.new(x,-46,z);p.Parent=workspace.UnderwaterTerrain end end
original:Destroy()
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(115,100,151),Vector3.new(0,3,22))
print('MAP_REFINEMENT_DONE')
