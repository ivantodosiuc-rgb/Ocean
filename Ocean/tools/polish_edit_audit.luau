local Http=game:GetService('HttpService');local report={}
report.flowers=0;report.unanchored=0;report.decorCollision=0;report.corals=#workspace.UnderwaterTerrain.PolishedReefs:GetChildren()
report.materials=0;report.loadedMeshes=0;report.badMeshes={}
for _,p in workspace:GetDescendants() do
 if p.Name:find('Flower') or p.Name:find('Hibiscus') then report.flowers+=1 end
 if p:IsA('BasePart') and p:GetAttribute('VisualPolishAsset') then
  if not p.Anchored then report.unanchored+=1 end
  if p:IsDescendantOf(workspace.UnderwaterTerrain.PolishedReefs) and (p.CanCollide or p.CanQuery or p.CanTouch) then report.decorCollision+=1 end
  if p:IsA('MeshPart') then
   local sa=p:FindFirstChildOfClass('SurfaceAppearance');if sa and sa.ColorMap~='' and sa.RoughnessMap~='' then report.materials+=1 else table.insert(report.badMeshes,p:GetFullName()) end
   if p.MeshId~='' then report.loadedMeshes+=1 end
  end
 end
end
report.lootPrefabs=#game.ReplicatedStorage.SeaGame.Assets.Loot:GetChildren();report.npcs={}
for _,m in workspace.NPCs:GetChildren() do if m:IsA('Model') then table.insert(report.npcs,m.Name) end end
report.boat={size=tostring(workspace.Ocean.LittleBoat.Size),pivot=tostring(workspace.Ocean.LittleBoat:GetPivot())}
local wet=workspace.Ocean.WetShoreRig:FindFirstChild('WetShore',true);report.wetBones=0
for _,b in wet:GetDescendants() do if b:IsA('Bone') then report.wetBones+=1 end end
report.wetAlpha=wet.SurfaceAppearance.AlphaMode.Name
print('POLISH_EDIT_AUDIT',Http:JSONEncode(report))
workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable;workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(132,105,180),Vector3.new(0,4,18));workspace.CurrentCamera.FieldOfView=55
