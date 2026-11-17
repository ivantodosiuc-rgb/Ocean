--!strict
local Players=game:GetService('Players')
local Config=require(game:GetService('ReplicatedStorage').SeaGame.Shared.Config)
local Economy=require(game:GetService('ReplicatedStorage').SeaGame.Shared.Economy)
local Wrecks={};Wrecks.__index=Wrecks
function Wrecks.new(ocean,loot,notice,fx)
 local self=setmetatable({ocean=ocean,loot=loot,notice=notice,fx=fx,chests={},random=Random.new()},Wrecks)
 local points=workspace.UnderwaterTerrain:FindFirstChild('PointsOfInterest')
 if not points then return self end
 for _,chest in points:GetDescendants() do if chest:IsA('Model') and chest:GetAttribute('ExpeditionChest') then
  local root=chest:FindFirstChild('ChestRoot');local lid=chest:FindFirstChild('Lid')
  if not root or not lid or not lid:IsA('BasePart') then continue end
  local prompt=Instance.new('ProximityPrompt');prompt.Name='OpenChest';prompt.ActionText='Open treasure chest';prompt.ObjectText=chest:GetAttribute('DisplayName') or 'Captain\'s Cache';prompt.HoldDuration=.65;prompt.MaxActivationDistance=8;prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.RequiresLineOfSight=false;prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.Parent=root
  chest:SetAttribute('LidClosedCFrame',lid.CFrame)
  local record={model=chest,root=root,lid=lid,closed=lid.CFrame,hinge=chest:GetAttribute('LidHinge'),prompt=prompt,opened=false}
  self.chests[chest.Name]=record
  prompt.Triggered:Connect(function(player) self:open(player,chest.Name) end)
 end end
 return self
end
function Wrecks:open(player,id:string)
 local chest=self.chests[id];local char=player.Character;local root=char and char:FindFirstChild('HumanoidRootPart');local human=char and char:FindFirstChildOfClass('Humanoid')
 if not chest or chest.opened then return false,'This chest is already open.' end
 if not root or not human or human.Health<=0 or (root.Position-chest.root.Position).Magnitude>9 then return false,'Move closer to the chest.' end
 if self.ocean.refilling or self.ocean.applied>chest.root.Position.Y+.5 then self.notice(player,'Lower the sea to uncover this chest.','info');return false,'Chest is underwater.' end
 local drops=chest.model:GetAttribute('DropCount') or 4
 local sites=chest.model:FindFirstChild('DropSites')
 if not sites or #sites:GetChildren()<drops then return false,'Treasure landing spots are unavailable.' end
 if self.loot.count+drops>Config.Ocean.maxActiveLoot+8 then return false,'Collect nearby treasure first.' end
 -- Claim the chest before animation or spawning. A second caller cannot open it again.
 chest.opened=true;chest.prompt.Enabled=false;chest.model:SetAttribute('Opened',true)
 local openedAt=workspace:GetServerTimeNow();chest.model:SetAttribute('OpenedAt',openedAt)
 local hinge=chest.hinge;local target=hinge*CFrame.Angles(math.rad(-106),0,0)*hinge:Inverse()*chest.closed
 -- The client animates every frame; replicate only the resting pose for late joiners.
 task.delay(1.7,function() if chest.model.Parent and chest.opened and chest.model:GetAttribute('OpenedAt')==openedAt then chest.lid.CFrame=target end end)
 local valueFloor=chest.model:GetAttribute('MinimumValue') or 600;local depth=chest.model:GetAttribute('LootDepth') or 42;local count=0
 for i=1,drops do
  local site=sites:FindFirstChild('Drop_'..i)
  if site and site:IsA('BasePart') then
   local lootId=Economy.rollLoot(self.random,depth,valueFloor)
   if lootId and self.loot:spawnReward(site.Position,lootId,site:GetAttribute('SurfaceNormal') or Vector3.yAxis,chest.root.Position+Vector3.new(0,2,0)) then count+=1 end
  end
 end
 self.fx('ChestOpened',{id=id,openedAt=openedAt,position=chest.root.Position,player=player.UserId,count=count})
 self.notice(player,'Chest opened! Collect the treasure around it.','success')
 return true,'Chest opened!',count
end
function Wrecks:restart()
 for _,chest in self.chests do chest.opened=false;chest.model:SetAttribute('Opened',false);chest.model:SetAttribute('OpenedAt',nil);chest.prompt.Enabled=true;chest.lid.CFrame=chest.closed end
end
return Wrecks
