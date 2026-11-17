local HttpService=game:GetService('HttpService');local result={npcs={},errors={},flowers=0,scripts=0}
local function check(ok,message) if not ok then table.insert(result.errors,message) end end
check(game:GetService('RunService'):IsEdit(),'Not in edit mode')
check(not workspace:GetAttribute('CharacterFloraRefresh'),'Old refresh attribute remains')
check(not workspace.Decorations:FindFirstChild('LushGrass'),'New grass remains')
check(not workspace.Decorations:FindFirstChild('TropicalFlowers'),'New flowers remain')
check(workspace.Decorations:FindFirstChild('GrassTuft')~=nil,'Original grass missing')
for _,p in workspace.Decorations:GetChildren() do if p.Name:match('^FlowerBed_') then result.flowers+=1 end end
check(result.flowers==12,'Original flower count changed')
for _,m in workspace.NPCs:GetChildren() do
 local humanoid=m:FindFirstChildOfClass('Humanoid');local shop=m:GetAttribute('Counter');local counter=workspace.Buildings[shop..'_Collisions'].Counter;local deck=workspace.Buildings[shop..'_Collisions'].Deck
 local foot=math.min(m.LeftFoot.Position.Y-m.LeftFoot.Size.Y/2,m.RightFoot.Position.Y-m.RightFoot.Size.Y/2);local gap=foot-(deck.Position.Y+deck.Size.Y/2)
 local relative=counter.CFrame:PointToObjectSpace(m:GetPivot().Position);local facing=m:GetPivot().LookVector:Dot(counter.CFrame.ZVector)
 local parts,joints,accessories=0,0,0
 for _,p in m:GetDescendants() do if p:IsA('BasePart') then parts+=1;check(p.Anchored,m.Name..' has unanchored part') elseif p:IsA('Motor6D') or p:IsA('AnimationConstraint') then joints+=1 elseif p:IsA('Accessory') then accessories+=1 end end
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={m};local hits=workspace:GetPartsInPart(counter,overlap)
 check(humanoid.RigType==Enum.HumanoidRigType.R15,m.Name..' is not R15');check(math.abs(gap)<.04,m.Name..' feet not on deck');check(relative.Z<-counter.Size.Z/2,m.Name..' not behind counter');check(facing>.999,m.Name..' faces away');check(#hits==0,m.Name..' intersects counter');check(accessories>0,m.Name..' missing accessories');check(joints>=15,m.Name..' missing rig joints')
 local entry={name=m.Name,rig=humanoid.RigType.Name,parts=parts,joints=joints,accessories=accessories,feetGap=gap,counterZ=relative.Z,facing=facing,counterIntersections=#hits}
 table.insert(result.npcs,entry);print('SHOPKEEPER_VERIFY_NPC '..HttpService:JSONEncode(entry))
end
for _,p in workspace:GetDescendants() do if p:IsA('LuaSourceContainer') then result.scripts+=1 end end
check(result.scripts==0,'Runtime script added');check(#result.npcs==3,'Expected three NPCs')
result.meadowTexture=workspace.StarterIsland.Meadow.TextureID;result.lightingBrightness=game:GetService('Lighting').Brightness
print('SHOPKEEPER_VERIFY '..HttpService:JSONEncode({errors=result.errors,flowers=result.flowers,scripts=result.scripts,meadowTexture=result.meadowTexture,lightingBrightness=result.lightingBrightness}))
workspace.CurrentCamera.CameraType=Enum.CameraType.Custom;workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(100,100,145),Vector3.new(0,5,8));workspace.CurrentCamera.Focus=CFrame.new(0,5,8);workspace.CurrentCamera.FieldOfView=55;game:GetService('Selection'):Set({})
