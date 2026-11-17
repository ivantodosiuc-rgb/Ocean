assert(not game:GetService('RunService'):IsRunning())
local imported=assert(workspace:FindFirstChild('SuckTheSea_Surfaces'))
local source={};for _,p in imported:GetDescendants() do if p:IsA('MeshPart') then source[p.Name]=p end end
assert(math.abs(source.island__Buildings__StrawShop.Size.Y-15.2)<.01,'Incorrect import axes')
local targets={};for _,root in {workspace,game.ReplicatedStorage.SeaGame.Assets} do for _,p in root:GetDescendants() do if p:IsA('MeshPart') and p:GetAttribute('SurfaceSource') then local s=assert(source[p:GetAttribute('SurfaceSource')]);assert(s:FindFirstChildOfClass('SurfaceAppearance'));table.insert(targets,{p,s}) end end end
local history=game:GetService('ChangeHistoryService');local recording=history:TryBeginRecording('Finalize surface import')
local changed=0
for i,r in targets do
 local p,s=r[1],r[2];local size,cf,pivot=p.Size,p.CFrame,p.PivotOffset;local col,render=p.CollisionFidelity,p.RenderFidelity
 if p.MeshId~=s.MeshId then p:ApplyMesh(s);p.Size=size;p.CFrame=cf;p.PivotOffset=pivot;p.CollisionFidelity=col;p.RenderFidelity=render;changed+=1 end
 for _,a in p:GetChildren() do if a:IsA('SurfaceAppearance')then a:Destroy()end end
 local a=s:FindFirstChildOfClass('SurfaceAppearance'):Clone();a.Name='SeaSurface';a.Color=Color3.new(1,1,1);a.Parent=p;p.TextureID=''
 if i%30==0 then task.wait()end
end
for _,kind in {'LagoonSand','IslandGrass'}do local a=source['SurfaceTile__'..kind]:FindFirstChildOfClass('SurfaceAppearance');local v=game.MaterialService['Sea_'..kind];v.ColorMap=a.ColorMap;v.NormalMap=a.NormalMap;v.RoughnessMap=a.RoughnessMap end
imported:Destroy();workspace:SetAttribute('SurfaceImportVerified',true)
if recording then history:FinishRecording(recording,Enum.FinishRecordingOperation.Commit)end
return {updated=#targets,geometryCorrected=changed}
