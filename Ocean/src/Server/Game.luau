--!strict
local Players=game:GetService('Players');local ReplicatedStorage=game:GetService('ReplicatedStorage');local RunService=game:GetService('RunService')
local Package=ReplicatedStorage.SeaGame;local Config=require(Package.Shared.Config);local Economy=require(Package.Shared.Economy)
local Profiles=require(script.Parent.Profiles);local Ocean=require(script.Parent.Ocean);local Loot=require(script.Parent.Loot);local Wrecks=require(script.Parent.Wrecks)
local Restroom=require(script.Parent.Restroom);local Needs=require(Package.Shared.Needs)
local Commerce=require(script.Parent.Commerce)
local Game={};Game.__index=Game
local function finiteVector(value:any):boolean
 return typeof(value)=='Vector3' and value.X==value.X and value.Y==value.Y and value.Z==value.Z and value.Magnitude<10000
end
function Game.new()
 local self=setmetatable({active={},buckets={},noticeTimes={},connections={},clock=0,worldClock=0,fxClock=0,dead=false},Game)
 self.remotes=Package.Remotes;self.ocean=Ocean.new()
 self.profiles=Profiles.new(function(player,status) self:sendState(player);if status=='Retrying' then self:notice(player,'Saving is taking longer. Your progress is still here.','warning') end end)
 self.loot=Loot.new(self.ocean,self.profiles,function(player) self:sendState(player) end,function(kind,payload) self.remotes.FX:FireAllClients(kind,payload) end,function(player,message,kind) self:notice(player,message,kind) end)
 self.wrecks=Wrecks.new(self.ocean,self.loot,function(player,message,kind) self:notice(player,message,kind) end,function(kind,payload) self.remotes.FX:FireAllClients(kind,payload) end)
 self.restroom=Restroom.new(self)
 self.commerce=Commerce.new(self)
 return self
end
function Game:snapshot(player)
 local data=self.profiles:get(player);if not data then return nil end
 local tool=player.Character and player.Character:FindFirstChildOfClass('Tool')
 return {coins=data.Coins,owned=table.clone(data.Owned),equipped=data.Equipped,held=tool~=nil and tool:GetAttribute('SeaStraw')==data.Equipped,upgrades=table.clone(data.Upgrades),bag=table.clone(data.Bag),count=Economy.count(data),capacity=Economy.capacity(data),value=Economy.value(data),stats=Economy.stats(data),saveStatus=self.profiles:status(player),revision=data.Revision}
end
function Game:sendState(player) local state=self:snapshot(player);if state and player.Parent then self.remotes.State:FireClient(player,state);if self.restroom then self.restroom:send(player) end end end
function Game:notice(player,message,kind)
 local now=os.clock();local last=self.noticeTimes[player]
 if last and last.message==message and now-last.time<2 then return end
 self.noticeTimes[player]={message=message,time=now};self.remotes.FX:FireClient(player,'Notice',{message=message,kind=kind or 'info'})
end
function Game:allow(player,channel:string,capacity:number,refill:number):boolean
 local all=self.buckets[player];if not all then all={};self.buckets[player]=all end
 local bucket=all[channel];local now=os.clock();if not bucket then bucket={tokens=capacity,time=now};all[channel]=bucket end
 bucket.tokens=math.min(capacity,bucket.tokens+(now-bucket.time)*refill);bucket.time=now
 if bucket.tokens<1 then return false end;bucket.tokens-=1;return true
end
function Game:nearShop(player,shop:string):boolean
 local character=player.Character;local root=character and character:FindFirstChild('HumanoidRootPart');local human=character and character:FindFirstChildOfClass('Humanoid');local npc=workspace.NPCs:FindFirstChild(Config.ShopNames[shop] or '')
 return root~=nil and human~=nil and human.Health>0 and npc~=nil and (root.Position-npc:GetPivot().Position).Magnitude<=Config.ShopDistance
end
function Game:movement(player)
 local data=self.profiles:get(player);local character=player.Character;local human=character and character:FindFirstChildOfClass('Humanoid')
 if not data or not human then return end
 local held=character:FindFirstChildOfClass('Tool');local admin=held and held:GetAttribute('SeaStraw')=='AdminStraw' and data.Owned.AdminStraw==true
 if human:GetAttribute('SeaBaseJumpHeight')==nil then human:SetAttribute('SeaBaseJumpHeight',human.JumpHeight);human:SetAttribute('SeaBaseJumpPower',human.JumpPower) end
 human.WalkSpeed=if admin then Config.AdminStraw.walk else Economy.stats(data).walk
 human.JumpHeight=if admin then Config.AdminStraw.jumpHeight else human:GetAttribute('SeaBaseJumpHeight')
 human.JumpPower=if admin then math.sqrt(2*workspace.Gravity*Config.AdminStraw.jumpHeight) else human:GetAttribute('SeaBaseJumpPower')
 character:SetAttribute('AdminMovement',admin==true)
end
function Game:equipTool(player)
 local data=self.profiles:get(player);local character=player.Character;local backpack=player:FindFirstChildOfClass('Backpack')
 if not data or not character or not backpack then return end
 local humanoid=character:FindFirstChildOfClass('Humanoid');if not humanoid or humanoid.Health<=0 then return end
 self:stopSuction(player)
 for _,parent in {character,backpack} do for _,p in parent:GetChildren() do if p:IsA('Tool') and p:GetAttribute('SeaStraw') then p:Destroy() end end end
 local prefab=Package.Assets.Tools:FindFirstChild(data.Equipped);assert(prefab,'Missing straw model '..data.Equipped)
 local tool=Instance.new('Tool');tool.Name=Config.StrawById[data.Equipped].name;tool.CanBeDropped=false;tool.RequiresHandle=true;tool:SetAttribute('SeaStraw',data.Equipped);tool.ToolTip='Hold right mouse button near the sea'
 local handle=Instance.new('Part');handle.Name='Handle';handle.Size=Vector3.new(.16,.3,.16);handle.Transparency=1;handle.CanCollide=false;handle.CanQuery=false;handle.CanTouch=false;handle.Massless=true;handle.Parent=tool
 for _,p in prefab:GetDescendants() do if p:IsA('BasePart') then
  local visual=p:Clone();visual.Name='StrawVisual';visual.CFrame=CFrame.new(0,-1.35,0)*p.CFrame;visual.Anchored=false;visual.CanCollide=false;visual.CanTouch=false;visual.CanQuery=false;visual.Massless=true;visual.Parent=tool
  local weld=Instance.new('Weld');weld.Part0=handle;weld.Part1=visual;weld.C0=visual.CFrame;weld.Parent=handle
 end end
 local tip=Instance.new('Attachment');tip.Name='SuctionTip';tip.Position=Vector3.new(0,-1.35,0);tip.Parent=handle
 local mouth=Instance.new('Attachment');mouth.Name='MouthTip';mouth.Position=Vector3.new(-.72,1.15,0);mouth.Parent=handle
 tool.Grip=CFrame.new(0,-.05,0)*CFrame.Angles(0,0,math.rad(-8));tool.Parent=backpack;humanoid:EquipTool(tool)
 self:movement(player)
 tool.Equipped:Connect(function() task.defer(function() self:movement(player);self:sendState(player) end) end)
 tool.Unequipped:Connect(function() self:stopSuction(player);task.defer(function() self:movement(player);self:sendState(player) end) end)
 task.defer(function() self:sendState(player) end)
end
function Game:stopSuction(player)
 if self.active[player] then self.active[player]=nil;self.remotes.FX:FireAllClients('SuctionStop',{player=player.UserId}) end
 if player.Character then player.Character:SetAttribute('SuckingOcean',false) end
end
function Game:validTarget(player,point:any):boolean
 if not self.restroom:canSip(player) then return false end
 if not finiteVector(point) or not self.ocean:canDrain() or self.ocean:isComplete() then return false end
 local character=player.Character;local root=character and character:FindFirstChild('HumanoidRootPart');local humanoid=character and character:FindFirstChildOfClass('Humanoid');local data=self.profiles:get(player)
 if not root or not humanoid or humanoid.Health<=0 or not data then return false end
 local equipped=character:FindFirstChildOfClass('Tool');if not equipped or equipped:GetAttribute('SeaStraw')~=data.Equipped then return false end
 local target=Vector3.new(point.X,self.ocean.applied,point.Z)
 if (root.Position-target).Magnitude>Economy.stats(data).reach or math.abs(point.Y-self.ocean.applied)>3 then return false end
 if math.abs(point.X)>Config.Ocean.halfSize-4 or math.abs(point.Z)>Config.Ocean.halfSize-4 then return false end
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={character,workspace.NPCs,self.loot.folder};params.IgnoreWater=false;params.RespectCanCollide=true
 local hit=workspace:Raycast(target+Vector3.new(0,2,0),Vector3.new(0,-5,0),params)
 if not hit or hit.Material~=Enum.Material.Water then return false end
 -- A dry wall or floor may not separate the player's straw from the water point.
 local origin=root.Position;local wall=workspace:Raycast(origin,target-origin,params)
 return wall==nil or wall.Material==Enum.Material.Water or (wall.Position-target).Magnitude<1.2
end
function Game:suctionPulse(player,point:any)
 if not self:allow(player,'suction',8,5) then return end
 if point==false then self:stopSuction(player);return end
 if not self.restroom:canSip(player) then self:stopSuction(player);self:notice(player,'Visit the beach restroom to feel fresh again.','warning');return end
 if not self:validTarget(player,point) then self:stopSuction(player);return end
 local first=self.active[player]==nil;self.active[player]={point=Vector3.new(point.X,self.ocean.applied,point.Z),expires=os.clock()+1.3}
 player.Character:SetAttribute('SuckingOcean',true)
 if first then self.remotes.FX:FireAllClients('SuctionStart',{player=player.UserId,point=self.active[player].point,straw=self.profiles:get(player).Equipped}) end
end
function Game:request(player,action:any,payload:any)
 if type(action)~='string' or #action>30 or not self:allow(player,'request',10,4) then return {ok=false,message='Please slow down.'} end
 local data=self.profiles:get(player);if not data then return {ok=false,message='Your backpack is loading.'} end
 if action=='State' then self.restroom:send(player);return {ok=true,state=self:snapshot(player)} end
 if self.restroom.using[player] then return {ok=false,message='Enjoy your shore break.'} end
 local success,message,amount=false,'Unknown action.',0
 if action=='PurchaseOffer' then
  if not self:allow(player,'purchase',1,.3) then return {ok=false,message='Please wait a moment.'} end
  success,message=self.commerce:prompt(player,payload)
 elseif action=='EquipSpecial' then
  local def=if type(payload)=='string' then Config.StrawById[payload] else nil
  if not def or not def.premium or not data.Owned[payload] then return {ok=false,message='You do not own this special straw.'} end
  success,message=Economy.equip(data,payload);if success then self:equipTool(player) end
 elseif action=='UseRestroom' then
  success,message=self.restroom:use(player)
 elseif action=='BuyStraw' or action=='EquipStraw' then
  if type(payload)~='string' or #payload>32 or not self:nearShop(player,'Straws') then return {ok=false,message='Visit Finn at STRAWS.'} end
  if action=='BuyStraw' then success,message,amount=Economy.buyStraw(data,payload) else success,message=Economy.equip(data,payload) end
  if success then self:equipTool(player) end
 elseif action=='Upgrade' then
  if type(payload)~='string' or #payload>24 or not self:nearShop(player,'Upgrades') then return {ok=false,message='Visit Maya at UPGRADES.'} end
  success,message,amount=Economy.upgrade(data,payload)
  if success then self:movement(player) end
 elseif action=='SellAll' then
  if not self:nearShop(player,'Sell') then return {ok=false,message='Visit Captain Shell at TREASURES.'} end
  success,message,amount=Economy.sell(data)
  if success then self.remotes.FX:FireClient(player,'Sale',{amount=amount}) end
 elseif action=='Collect' then
  if type(payload)~='string' or #payload>48 then return {ok=false,message='Invalid treasure.'} end
  success,message=self.loot:collect(player,payload)
 elseif action=='OpenChest' then
  if type(payload)~='string' or #payload>48 then return {ok=false,message='Invalid chest.'} end
  success,message,amount=self.wrecks:open(player,payload)
 elseif action=='ToggleHeld' or action=='EquipHeld' then
  if not self:allow(player,'equip',2,4) then return {ok=false,message='Please slow down.'} end
  local character=player.Character;local human=character and character:FindFirstChildOfClass('Humanoid');local backpack=player:FindFirstChildOfClass('Backpack')
  if not human or human.Health<=0 or not backpack then return {ok=false,message='Your straw is not ready.'} end
  self:stopSuction(player)
  local held=character:FindFirstChildOfClass('Tool')
  if held and held:GetAttribute('SeaStraw') then human:UnequipTools();success=true;message='Straw put away.'
  else for _,tool in backpack:GetChildren() do if tool:IsA('Tool') and tool:GetAttribute('SeaStraw')==data.Equipped then human:EquipTool(tool);success=true;message='Straw ready.';break end end end
 elseif action=='NewTide' then
  return {ok=false,message='The ocean is shared. Its progress is permanent.'}
 end
 if success then self:sendState(player);if action=='Upgrade' or action=='BuyStraw' then self.remotes.FX:FireClient(player,'Upgrade',{category=payload}) end end
 return {ok=success,message=message,amount=amount or 0,state=self:snapshot(player)}
end
function Game:characterAdded(player,character)
 if character:GetAttribute('SeaInitialized') then return end;character:SetAttribute('SeaInitialized',true)
 local humanoid=character:WaitForChild('Humanoid',10);if not humanoid then return end
 humanoid.Died:Connect(function() self:stopSuction(player);self.restroom:finish(player,false) end)
 local deadline=os.clock()+25;while not self.profiles:get(player) and player.Parent and os.clock()<deadline do task.wait(.1) end
 if player.Parent and self.profiles:get(player) then self:equipTool(player);self:sendState(player) end
end
function Game:playerAdded(player)
 player.CharacterAdded:Connect(function(character) self:characterAdded(player,character) end)
 local data=self.profiles:load(player);if not data then return end
 if player.Character then self:characterAdded(player,player.Character) end
 self:sendState(player)
 self.commerce:joined(player)
end
function Game:start()
 Game.current=self
 self.ocean.progress:start()
 self.restroom:start()
 self.commerce:start()
 for shop,npcName in Config.ShopNames do
  local npc=workspace.NPCs:FindFirstChild(npcName);local attachment=Instance.new('Attachment');attachment.Name='ShopInteraction';attachment.Position=Vector3.new(0,1,0);attachment.Parent=npc.HumanoidRootPart
  local prompt=Instance.new('ProximityPrompt');prompt.Name='Shop_'..shop;prompt.ActionText=if shop=='Sell' then 'Sell treasure' elseif shop=='Straws' then 'Browse straws' else 'Upgrade';prompt.ObjectText=npcName;prompt.MaxActivationDistance=18;prompt.HoldDuration=0;prompt.RequiresLineOfSight=false;prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt:SetAttribute('Shop',shop);prompt.Parent=attachment
  prompt.Triggered:Connect(function(player) if self:nearShop(player,shop) then self:stopSuction(player);self.remotes.FX:FireClient(player,'OpenShop',{shop=shop}) end end)
 end
 self.remotes.Request.OnServerInvoke=function(player,action,payload) return self:request(player,action,payload) end
 self.remotes.Suction.OnServerEvent:Connect(function(player,point) self:suctionPulse(player,point) end)
 Players.PlayerAdded:Connect(function(player) task.spawn(function() self:playerAdded(player) end) end)
 Players.PlayerRemoving:Connect(function(player) self:stopSuction(player);self.restroom:finish(player,false);self.restroom.dirty[player]=nil;task.spawn(function() self.ocean.progress:flush() end);self.profiles:release(player);self.buckets[player]=nil;self.noticeTimes[player]=nil end)
 for _,player in Players:GetPlayers() do task.spawn(function() self:playerAdded(player) end) end
 RunService.Heartbeat:Connect(function(dt)
  if self.dead then return end
  local power=0;local contributions={}
  for player,active in self.active do
   active.validationClock=(active.validationClock or 0)+dt
   local valid=true
   if active.validationClock>=.15 then active.validationClock=0;valid=self:validTarget(player,active.point) end
   if os.clock()>active.expires or not valid then self:stopSuction(player)
   else local data=self.profiles:get(player);if data then local stats=Economy.stats(data);local contribution=Needs.availablePower(data.NeedsWater,stats.power*stats.speed,dt);power+=contribution;contributions[player]=contribution;active.point=Vector3.new(active.point.X,self.ocean.applied,active.point.Z) end end
  end
  local consumed=self.ocean:step(dt,power)
  for player,contribution in contributions do self.restroom:credit(player,Needs.share(consumed,contribution,power)) end
  self.restroom:step(dt);if self.ocean.ready then self.loot:step(dt) end;self.clock+=dt;self.worldClock+=dt;self.fxClock+=dt
  if self.clock>=1 then self.clock=0;self.profiles:tick() end
  if self.worldClock>=.3 then self.worldClock=0;local world=self.ocean:snapshot();world.activeLoot=self.loot.count;self.remotes.World:FireAllClients(world) end
  if self.fxClock>=.25 then self.fxClock=0;for player,a in self.active do self.remotes.FX:FireAllClients('SuctionAim',{player=player.UserId,point=a.point}) end end
 end)
 game:BindToClose(function()
  self.dead=true;local remaining=2
  task.spawn(function() self.profiles:close();remaining-=1 end)
  task.spawn(function() self.ocean.progress:close();remaining-=1 end)
  local deadline=os.clock()+26;while remaining>0 and os.clock()<deadline do task.wait(.1) end
 end)
 print('[SeaGame] Server ready')
end
return Game
