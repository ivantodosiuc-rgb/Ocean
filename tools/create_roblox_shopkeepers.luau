--!strict
-- One-time editor operation. No runtime scripts are added to the map.
local Players=game:GetService('Players')
local ServerStorage=game:GetService('ServerStorage')
local History=game:GetService('ChangeHistoryService')
assert(game:GetService('RunService'):IsEdit(),'Run in Edit mode')
assert(not workspace:GetAttribute('CharacterFloraRefresh'),'Restore the original island first')
assert(workspace.Decorations:FindFirstChild('FlowerBed_00'),'Original flowers required')
assert(not workspace.Decorations:FindFirstChild('LushGrass'),'New grass must be absent')
assert(not workspace:GetAttribute('RobloxShopkeepers'),'Shopkeepers already installed')
local specs={
 {name='Finn',shop='StrawShop',body='Man',hair='62234425',hat='',shirt=382537702,pants=398635338,skin=Color3.fromRGB(234,184,146),width=.9,height=.97},
 {name='Maya',shop='UpgradeShop',body='Woman',hair='62724852',hat='',shirt=398634295,pants=398635338,skin=Color3.fromRGB(204,153,112),width=.9,height=.96},
 {name='Captain Shell',shop='TreasureShop',body='Man',hair='',hat='417457461',shirt=144076436,pants=398635338,skin=Color3.fromRGB(218,171,132),width=1.03,height=1.02},
}
local bodies={
 Man={Torso=86500008,RightArm=86500036,LeftArm=86500054,LeftLeg=86500064,RightLeg=86500078},
 Woman={Torso=86499666,RightArm=86499698,LeftArm=86499716,LeftLeg=86499753,RightLeg=86499793},
}
local staging=Instance.new('Folder');staging.Name='ShopkeeperStaging';staging.Parent=ServerStorage
local ready={}
for _,spec in specs do
 local description=Instance.new('HumanoidDescription')
 for property,id in bodies[spec.body] do (description :: any)[property]=id end
 description.HairAccessory=spec.hair;description.HatAccessory=spec.hat;description.Shirt=spec.shirt;description.Pants=spec.pants
 description.HeadColor=spec.skin;description.LeftArmColor=spec.skin;description.RightArmColor=spec.skin;description.TorsoColor=spec.skin;description.LeftLegColor=spec.skin;description.RightLegColor=spec.skin
 description.WidthScale=spec.width;description.DepthScale=.95;description.HeightScale=spec.height;description.HeadScale=1;description.BodyTypeScale=0;description.ProportionScale=0
 local ok,result=pcall(function() return Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15,Enum.AssetTypeVerification.Always) end)
 description:Destroy()
 assert(ok,'Unable to create '..spec.name..': '..tostring(result))
 local model=result :: Model;model.Name=spec.name
 for _,p in model:GetDescendants() do
  if p:IsA('LuaSourceContainer') then p:Destroy()
  elseif p:IsA('BasePart') then p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CastShadow=p.Name~='HumanoidRootPart' end
 end
 local humanoid=model:FindFirstChildOfClass('Humanoid') :: Humanoid
 assert(humanoid and humanoid.RigType==Enum.HumanoidRigType.R15,'Expected standard R15 character')
 humanoid.DisplayName=spec.name;humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None;humanoid.HealthDisplayType=Enum.HumanoidHealthDisplayType.AlwaysOff
 humanoid.AutoRotate=false;humanoid.WalkSpeed=0;humanoid.BreakJointsOnDeath=false
 local counter=workspace.Buildings[spec.shop..'_Collisions'].Counter
 local deck=workspace.Buildings[spec.shop..'_Collisions'].Deck
 local left=model:FindFirstChild('LeftFoot') :: BasePart;local right=model:FindFirstChild('RightFoot') :: BasePart
 assert(left and right,'R15 feet required')
 local bottom=math.min(left.Position.Y-left.Size.Y/2,right.Position.Y-right.Size.Y/2)
 local lift=model:GetPivot().Position.Y-bottom
 local spot=(counter.CFrame*CFrame.new(0,0,-3.1)).Position
 local target=Vector3.new(spot.X,deck.Position.Y+deck.Size.Y/2+lift+.015,spot.Z)
 model:PivotTo(CFrame.new(target)*counter.CFrame.Rotation*CFrame.Angles(0,math.pi,0))
 model:SetAttribute('AvatarSource','Roblox official Man/Woman R15 packages')
 model:SetAttribute('Counter',spec.shop);model:SetAttribute('StaticNPC',true)
 model.Parent=staging;table.insert(ready,model)
 print('ROBLOX_NPC_READY',spec.name,model:GetPivot().Position,#model:GetChildren())
end
assert(#ready==3,'All three avatars must be ready')
History:SetWaypoint('Before standard Roblox shopkeepers')
local old=Instance.new('Folder');old.Name='PreviousShopkeepers';old.Parent=ServerStorage
for _,model in workspace.NPCs:GetChildren() do model.Parent=old end
for _,model in ready do model.Parent=workspace.NPCs end
staging:Destroy();old:Destroy()
workspace:SetAttribute('RobloxShopkeepers','2026-11-16-v1')
History:SetWaypoint('Three Roblox avatars behind shop counters')
game:GetService('Selection'):Set({})
print('ROBLOX_SHOPKEEPERS_INSTALLED',#workspace.NPCs:GetChildren())
