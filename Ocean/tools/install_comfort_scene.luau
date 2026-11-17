assert(not game:GetService('RunService'):IsRunning(),'Edit only')
local history=game:GetService('ChangeHistoryService');local recording=history:TryBeginRecording('Install beach comfort','Beach restroom, straws and mussels')
local imported=assert(workspace:FindFirstChild('SuckTheSea_Comfort'),'Missing reviewed native FBX import')
assert(not workspace.Buildings:FindFirstChild('BeachRestroom'),'Already installed')
local assets=game.ReplicatedStorage.SeaGame.Assets
imported:PivotTo(CFrame.Angles(0,math.pi,0)*imported:GetPivot())
local booth=Instance.new('Model');booth.Name='BeachRestroom';booth.WorldPivot=CFrame.new()
local total=0
for _,p in imported:GetDescendants() do if p:IsA('MeshPart') then
 local group,id=p.Name:match('^(%a+)__(.+)$');assert(group,p.Name)
 p.Color=Color3.new(1,1,1);p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=true;p.Material=Enum.Material.SmoothPlastic;p.RenderFidelity=Enum.RenderFidelity.Automatic;p:SetAttribute('AuthoredIn','Blender 5.2.1');p:SetAttribute('ComfortAsset',true)
 local appearance=p:FindFirstChildOfClass('SurfaceAppearance');assert(appearance,'Missing imported texture');appearance.Color=Color3.new(1,1,1)
 if group=='Restroom' then p.Name=id;p.Parent=booth
 else
  local parent=if group=='Tool' then assets.Tools else assets.Loot;local old=parent:FindFirstChild(id);if old then old:Destroy() end
  local model=Instance.new('Model');model.Name=id;model.WorldPivot=CFrame.new();p.Name='Visual';p.Parent=model;model.Parent=parent
  if id=='PrismStraw' then p:SetAttribute('Prismatic',true) end
 end
 total+=1
end end
assert(total==16,total);imported:Destroy()
local ground=Vector3.new(-43,5.93025,24);local cf=CFrame.new(ground)*CFrame.Angles(0,math.rad(115),0)
booth.Parent=workspace.Buildings;booth:PivotTo(cf);booth:SetAttribute('Occupied',false)
local function part(name,size,localCF,collide,touch)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf*localCF;p.Anchored=true;p.Transparency=1;p.CanCollide=collide==true;p.CanTouch=touch==true;p.CanQuery=collide==true;p.CastShadow=false;p.Parent=booth;return p
end
part('FloorCollision',Vector3.new(7.5,.55,7.5),CFrame.new(0,.28,0),true)
part('StepCollision',Vector3.new(4.7,.33,1.7),CFrame.new(0,.2,4.1),true)
part('LeftWallCollision',Vector3.new(.4,7,7.2),CFrame.new(-3.43,4,0),true)
part('RightWallCollision',Vector3.new(.4,7,7.2),CFrame.new(3.43,4,0),true)
part('BackWallCollision',Vector3.new(7.2,7,.4),CFrame.new(0,4,-3.43),true)
part('FrontLeftCollision',Vector3.new(1.4,7,.4),CFrame.new(-2.75,4,3.43),true)
part('FrontRightCollision',Vector3.new(1.4,7,.4),CFrame.new(2.75,4,3.43),true)
part('PrivacyDoor',Vector3.new(3.6,6.3,.25),CFrame.new(0,3.7,3.52),false)
part('Entry',Vector3.new(3.5,4,1.3),CFrame.new(0,2.7,4.7),false,true)
part('Inside',Vector3.new(.2,.2,.2),CFrame.new(0,3.7,.8)*CFrame.Angles(0,math.pi,0),false)
part('Exit',Vector3.new(.2,.2,.2),CFrame.new(0,3.3,8.5)*CFrame.Angles(0,math.pi,0),false)
part('DoorHinge',Vector3.new(.2,.2,.2),CFrame.new(-1.81,0,3.52),false)
local camera=part('Camera',Vector3.new(.2,.2,.2),CFrame.new(),false);camera.CFrame=CFrame.lookAt(cf:PointToWorldSpace(Vector3.new(12,9,17)),cf:PointToWorldSpace(Vector3.new(0,3.5,0)))
local sign=part('RestroomSign',Vector3.new(2.65,.7,.08),CFrame.new(0,7.68,3.94),false);sign.Transparency=1
local gui=Instance.new('SurfaceGui');gui.Name='RestroomLettering';gui.Face=Enum.NormalId.Back;gui.CanvasSize=Vector2.new(530,140);gui.LightInfluence=.2;gui.Parent=sign
local text=Instance.new('TextLabel');text.BackgroundTransparency=1;text.Size=UDim2.fromScale(1,1);text.Font=Enum.Font.FredokaOne;text.Text='WC';text.TextSize=97;text.TextColor3=Color3.fromRGB(255,238,175);text.Parent=gui
-- Grass belongs on the meadow. Driftwood remains on the beach.
local plants=workspace.Decorations.CoastalPlanting
local removed=0
for _,m in plants:GetChildren() do if m.Name:match('^BeachDetail_') and m:GetAttribute('PolishVariant')~='Driftwood' then m:Destroy();removed+=1 end end
local moves={GardenFoliage_7={-42,5.84663,34},GardenGrass_7={-40,5.91187,33},GardenFoliage_8={36,5.81871,43},GardenGrass_8={37.7,5.77344,42.3},GardenFoliage_9={54,5.70442,-27},GardenGrass_9={55.7,5.4996,-27.7},GardenFoliage_12={26,5.94644,39},GardenGrass_12={27.5,5.94,38.3}}
for name,p in moves do local m=assert(plants:FindFirstChild(name));local old=m:GetPivot();m:PivotTo(CFrame.new(p[1],p[2]-.07,p[3])*old.Rotation);m:SetAttribute('GroundY',p[2]);for _,v in m:GetDescendants() do if v:IsA('BasePart') then v:SetAttribute('Wettable',nil);v:SetAttribute('ShoreBaseY',nil) end end end
local sites=Instance.new('Folder');sites.Name='StarterMusselSites';sites.Parent=workspace.StarterIsland
local positions={{-14,5.61222,63},{-18,5.2635,65},{-23,5.32702,62},{-31,4.86533,61},{-42,3.7056,57},{-51,2.87464,50},{22,3.87762,64},{28,3.9115,62},{39,3.92023,57},{51,3.33103,48},{-64,3.90842,14},{-65,3.84733,8},{65,5.47164,-10},{64,5.29315,-17},{-21,5.27571,-62},{-28,4.91652,-61}}
for i,p in positions do local s=Instance.new('Part');s.Name=string.format('MusselSite_%02d',i);s.Size=Vector3.new(.2,.2,.2);s.Position=Vector3.new(p[1],p[2]+.015,p[3]);s.Anchored=true;s.Transparency=1;s.CanCollide=false;s.CanQuery=false;s.CanTouch=false;s.Parent=sites end
game:GetService('Selection'):Set({})
if recording then history:FinishRecording(recording,Enum.FinishRecordingOperation.Commit) end
return {meshes=total,beachGrassRemoved=removed,plantsRelocated=8,starterMusselSites=#positions,booth=booth:GetFullName()}
