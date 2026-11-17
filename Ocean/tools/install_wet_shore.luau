assert(not game:GetService('RunService'):IsRunning())
local imported=assert(workspace:FindFirstChild('SuckTheSea_WetShoreV2'))
imported:PivotTo(CFrame.Angles(0,math.pi,0)*imported:GetPivot())
local mesh=assert(imported:FindFirstChild('WetShore',true))
assert(mesh:IsA('MeshPart'));mesh.Anchored=true;mesh.CanCollide=false;mesh.CanQuery=false;mesh.CanTouch=false;mesh.CastShadow=false;mesh.Color=Color3.new(1,1,1)
mesh.Transparency=.02
mesh.RenderFidelity=Enum.RenderFidelity.Precise;mesh:SetAttribute('AuthoredIn','Blender 5.2.1');mesh:SetAttribute('VisualPolishAsset',true)
local appearance=mesh:FindFirstChildOfClass('SurfaceAppearance')
if not appearance then appearance=Instance.new('SurfaceAppearance');appearance.ColorMap=mesh.TextureID;appearance.Parent=mesh end
appearance.AlphaMode=Enum.AlphaMode.Transparency
local bones=0;for _,o in mesh:GetDescendants() do if o:IsA('Bone') then bones+=1 end end
assert(bones==241,'Skinning missing from native import: '..bones)
local old=workspace.Ocean:FindFirstChild('WetShoreRig');if old then old:Destroy() end
imported.Name='WetShoreRig';imported.Parent=workspace.Ocean
print('WET_SHORE_INSTALLED',bones,appearance.ColorMap,appearance.RoughnessMap,mesh.Size)
