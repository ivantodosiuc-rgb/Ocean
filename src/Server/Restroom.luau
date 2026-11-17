--!strict
local Players=game:GetService('Players')
local Package=game:GetService('ReplicatedStorage').SeaGame
local Config=require(Package.Shared.Config);local Needs=require(Package.Shared.Needs);local Economy=require(Package.Shared.Economy)
local Restroom={};Restroom.__index=Restroom
function Restroom.new(owner)
 return setmetatable({owner=owner,using={},dirty={},clock=0,occupant=nil},Restroom)
end
function Restroom:state(player)
 local data=self.owner.profiles:get(player)
 return {percent=Needs.percent(if data then data.NeedsWater else 0),using=self.using[player]~=nil}
end
function Restroom:send(player)
 if player.Parent then self.owner.remotes.FX:FireClient(player,'Needs',self:state(player)) end
end
function Restroom:credit(player,amount:number)
 local data=self.owner.profiles:get(player);if not data or amount<=0 then return end
 data.NeedsWater=math.min(Needs.Capacity,data.NeedsWater+amount);self.dirty[player]=true
 if data.NeedsWater>=Needs.Capacity-.000001 then data.NeedsWater=Needs.Capacity;self.owner:stopSuction(player) end
end
function Restroom:canSip(player):boolean
 local data=self.owner.profiles:get(player)
 return data~=nil and not self.using[player] and data.NeedsWater<Needs.Capacity-.000001
end
function Restroom:finish(player,completed:boolean)
 local use=self.using[player];if not use then return end
 self.using[player]=nil;self.occupant=nil
 local data=self.owner.profiles:get(player)
 if completed and data then data.NeedsWater=0;data.Revision+=1 end
 local root=use.root;local human=use.human
 if root.Parent and human.Parent then
  if completed and human.Health>0 then root.CFrame=self.booth.Exit.CFrame end
  root.Anchored=use.anchored;human.AutoRotate=use.rotate;human.WalkSpeed=if data then Economy.stats(data).walk else use.walk
  if use.held and human.Health>0 and use.held.Parent then human:EquipTool(use.held) end
 end
 self.booth:SetAttribute('Occupied',false);self.booth:SetAttribute('UseStartedAt',nil)
 self.booth.PrivacyDoor.CanCollide=false;self.booth.PrivacyDoor.CanQuery=false
 if self.prompt then self.prompt.Enabled=true end
 if player.Parent then self.owner.remotes.FX:FireClient(player,'RestroomEnd',{completed=completed});self:send(player);self.owner:sendState(player) end
end
function Restroom:use(player)
 local data=self.owner.profiles:get(player);local character=player.Character
 local root=character and character:FindFirstChild('HumanoidRootPart');local human=character and character:FindFirstChildOfClass('Humanoid')
 if not data or not root or not human or human.Health<=0 or not self.booth or (root.Position-self.booth.Entry.Position).Magnitude>Config.Restroom.Distance then return false,'Walk to the beach restroom.' end
 if self.occupant then return false,'The restroom is occupied.' end
 if data.NeedsWater<=.000001 then return false,'You feel fresh already!' end
 self.owner:stopSuction(player);self.occupant=player
 local tool=character:FindFirstChildOfClass('Tool')
 self.using[player]={root=root,human=human,anchored=root.Anchored,rotate=human.AutoRotate,walk=human.WalkSpeed,held=tool,ends=os.clock()+Config.Restroom.UseSeconds}
 human:UnequipTools();root.Anchored=true;human.AutoRotate=false;human.WalkSpeed=0;root.CFrame=self.booth.Inside.CFrame
 self.booth:SetAttribute('Occupied',true);self.booth:SetAttribute('UseStartedAt',workspace:GetServerTimeNow());self.prompt.Enabled=false
 self.booth.PrivacyDoor.CanCollide=true;self.booth.PrivacyDoor.CanQuery=true
 self.owner.remotes.FX:FireClient(player,'RestroomStart',{duration=Config.Restroom.UseSeconds,camera=self.booth.Camera.CFrame})
 self:send(player);return true,'A little shore break.'
end
function Restroom:start()
 self.booth=workspace.Buildings:FindFirstChild('BeachRestroom');assert(self.booth,'BeachRestroom is missing')
 local p=Instance.new('ProximityPrompt');p.Name='UseRestroom';p.ActionText='Use restroom';p.ObjectText='Beach restroom';p.Style=Enum.ProximityPromptStyle.Custom;p.RequiresLineOfSight=false;p.MaxActivationDistance=9;p.HoldDuration=.15;p.KeyboardKeyCode=Enum.KeyCode.E;p.GamepadKeyCode=Enum.KeyCode.ButtonX;p.Parent=self.booth.Entry;self.prompt=p
 p.Triggered:Connect(function(player) local ok,message=self:use(player);if not ok then self.owner:notice(player,message,'info') end end)
 self.booth.Entry.Touched:Connect(function(part)
  local player=Players:GetPlayerFromCharacter(part.Parent);if not player or self.occupant then return end
  local data=self.owner.profiles:get(player);if data and data.NeedsWater>.000001 then self:use(player) end
 end)
end
function Restroom:step(dt:number)
 for player,use in self.using do
  if not player.Parent or player.Character~=use.root.Parent or use.human.Health<=0 then self:finish(player,false)
  elseif os.clock()>=use.ends then self:finish(player,true) end
 end
 self.clock+=dt;if self.clock<.5 then return end;self.clock=0
 for player in self.dirty do self:send(player) end;table.clear(self.dirty)
end
return Restroom
