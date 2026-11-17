--!nonstrict
local Players=game:GetService('Players');local UserInputService=game:GetService('UserInputService');local ContextActionService=game:GetService('ContextActionService');local RunService=game:GetService('RunService');local ProximityPromptService=game:GetService('ProximityPromptService');local StarterGui=game:GetService('StarterGui')
local Package=game:GetService('ReplicatedStorage').SeaGame;local Config=require(Package.Shared.Config)
local UI=require(script.Parent.UI);local Effects=require(script.Parent.Effects)
local RestroomEffects=require(script.Parent.RestroomEffects)
local Controller={};Controller.__index=Controller
function Controller.new()
 local self=setmetatable({holding=false,near=false,point=nil,pulse=0,scan=0,busy=false,prompts={},world={level=0},state=nil},Controller)
 self.player=Players.LocalPlayer;self.remotes=Package.Remotes
 self.ui=UI.new({action=function(action,payload) self:action(action,payload) end,stop=function() self:stop() end})
 self.fx=Effects.new(self.ui)
 self.restroom=RestroomEffects.new(self)
 return self
end
function Controller:stop()
 if self.holding then self.holding=false;self.remotes.Suction:FireServer(false);self.fx:stop(self.player.UserId) end
 self.ui:hintState(self.near,false)
end
function Controller:begin()
 if self.ui.shop or self.ui.comfort.using or self.ui.comfort.percent>=100 or UserInputService:GetFocusedTextBox() or not self.point then return false end
 local character=self.player.Character;local human=character and character:FindFirstChildOfClass('Humanoid');local tool=character and character:FindFirstChildOfClass('Tool')
 if not human or human.Health<=0 or not tool or not tool:GetAttribute('SeaStraw') then return false end
 if self.world.ready==false or self.world.saveStatus=='Retrying' or self.world.refilling or self.world.complete then return false end
 self.holding=true;self.pulse=0;self.remotes.Suction:FireServer(self.point);self.ui:hintState(true,true);return true
end
function Controller:waterPoint()
 local reach=if self.state then self.state.stats.reach else Config.SuctionReach
 local character=self.player.Character;local root=character and character:FindFirstChild('HumanoidRootPart');if not root then return nil end
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={character,workspace.NPCs,workspace:FindFirstChild('LiveLoot'),self.fx.folder};params.IgnoreWater=false;params.RespectCanCollide=true
 local camera=workspace.CurrentCamera;local cursor=UserInputService:GetMouseLocation();local ray=camera:ViewportPointToRay(cursor.X,cursor.Y)
 local target=workspace:Raycast(ray.Origin,ray.Direction*300,params)
 if target and target.Material==Enum.Material.Water and (target.Position-root.Position).Magnitude<reach-1 then return Vector3.new(target.Position.X,self.world.level,target.Position.Z) end
 -- Touch and gamepad aim at the closest visible water; the same check also makes shore aiming forgiving.
 local best,bestDistance=nil,reach-1
 for radius=6,reach-1,6 do
  for i=0,11 do
   local angle=i*math.pi/6;local p=Vector3.new(root.Position.X+math.sin(angle)*radius,self.world.level,root.Position.Z+math.cos(angle)*radius)
   local distance=(root.Position-p).Magnitude
   if distance<bestDistance then
    local hit=workspace:Raycast(p+Vector3.new(0,2,0),Vector3.new(0,-5,0),params)
    if hit and hit.Material==Enum.Material.Water then
     local wall=workspace:Raycast(root.Position,p-root.Position,params)
     if not wall or wall.Material==Enum.Material.Water or (wall.Position-p).Magnitude<1.2 then best=p;bestDistance=distance end
    end
   end
  end
 end
 return best
end
function Controller:stateChanged(state)
 if not state or (self.state and state.revision<self.state.revision) then return end
 self.state=state;self.ui:update(state)
end
function Controller:action(action,payload)
 if self.busy then return end;self.busy=true;self.fx:click()
 task.spawn(function()
  local ok,result=pcall(function() return self.remotes.Request:InvokeServer(action,payload) end)
  self.busy=false
  if not ok then self.ui:toastMessage('Connection interrupted. Please try again.','warning');return end
  if result.state then self:stateChanged(result.state) end
  if not result.ok then self.ui:toastMessage(result.message or 'Try again.','warning') elseif action~='SellAll' and action~='Upgrade' and action~='BuyStraw' and action~='ToggleHeld' then self.ui:toastMessage(result.message or 'Ready!','success') end
 end)
end
function Controller:start()
 Controller.current=self
 pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false) end)
 pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false) end)
 task.spawn(function() pcall(function() game:GetService('ContentProvider'):PreloadAsync({Package.Assets.Tools,Package.Assets.Icons}) end) end)
 self.remotes.State.OnClientEvent:Connect(function(state) self:stateChanged(state) end)
 self.remotes.World.OnClientEvent:Connect(function(world) self.world=world;self.ui:updateWorld(world);if world.refilling or world.complete then self:stop() end end)
 self.remotes.FX.OnClientEvent:Connect(function(kind,payload)
  if kind=='OpenShop' then self:stop();for _,g in self.prompts do g.Enabled=false end;self.ui:open(payload.shop)
  elseif kind=='Needs' then self.ui.comfort:update(payload);if payload.using or payload.percent>=100 then self:stop() end
  elseif kind=='RestroomStart' then self.restroom:start(payload)
  elseif kind=='RestroomEnd' then self.restroom:finish(payload.completed)
  elseif kind=='Notice' then self.ui:toastMessage(payload.message,payload.kind)
  elseif kind=='SuctionStart' then self.fx:start(payload)
  elseif kind=='SuctionStop' then self.fx:stop(payload.player);if payload.player==self.player.UserId then self.holding=false end
  elseif kind=='SuctionAim' then self.fx:aim(payload)
  elseif kind=='Pickup' then self.fx:pickup(payload)
  elseif kind=='ChestOpened' then self.fx:chestOpened(payload)
  elseif kind=='Sale' then self.ui:sale(payload.amount);for i,pitch in {1,1.25,1.5,2} do task.delay((i-1)*.09,function() self.fx:sound(Config.Audio.Collect,pitch,.2) end) end
  elseif kind=='Upgrade' then self.fx:upgrade(payload)
  elseif kind=='PurchaseAward' then
   if payload.coins>0 then self.ui:sale(payload.coins) end
   if payload.straw then self.ui:toastMessage(payload.name..' unlocked! Equip it in the shop.','success');self.ui:burst(self.ui.root.AbsoluteSize*.5,Color3.fromRGB(255,205,83),18) end
  end
 end)
 ContextActionService:BindActionAtPriority('SeaSip',function(_,state,input)
  if state==Enum.UserInputState.Begin then if self:begin() then return Enum.ContextActionResult.Sink end
  elseif state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then if self.holding then self:stop();return Enum.ContextActionResult.Sink end end
  return Enum.ContextActionResult.Pass
 end,false,Enum.ContextActionPriority.High.Value+10,Enum.UserInputType.MouseButton2,Enum.KeyCode.ButtonR2)
 ContextActionService:BindActionAtPriority('ToggleSeaStraw',function(_,state)
  if UserInputService:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
  if state==Enum.UserInputState.Begin then self:stop();self:action('ToggleHeld') end
  return Enum.ContextActionResult.Sink
 end,false,Enum.ContextActionPriority.High.Value+12,Enum.KeyCode.One,Enum.KeyCode.ButtonY)
 ContextActionService:BindAction('CloseSeaShop',function(_,state) if state==Enum.UserInputState.Begin and self.ui.shop then self.ui:close();return Enum.ContextActionResult.Sink end;return Enum.ContextActionResult.Pass end,false,Enum.KeyCode.Escape,Enum.KeyCode.ButtonB)
 self.ui.touchButton.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then self.touchInput=input;self:begin() end end)
 UserInputService.InputEnded:Connect(function(input) if input==self.touchInput or input.UserInputType==Enum.UserInputType.MouseButton2 or input.KeyCode==Enum.KeyCode.ButtonR2 then self.touchInput=nil;self:stop() end end)
 UserInputService.WindowFocusReleased:Connect(function() self:stop() end);UserInputService.TextBoxFocused:Connect(function() self:stop() end)
 self.player.CharacterAdded:Connect(function(character) self:stop();self.ui:close();local humanoid=character:WaitForChild('Humanoid');humanoid.Died:Connect(function() self:stop();self.ui:close() end) end)
 ProximityPromptService.PromptShown:Connect(function(prompt,inputType) if prompt.Style~=Enum.ProximityPromptStyle.Custom then return end;local old=self.prompts[prompt];if old then old:Destroy() end;self.prompts[prompt]=self.ui:prompt(prompt,inputType) end)
 ProximityPromptService.PromptHidden:Connect(function(prompt) local g=self.prompts[prompt];if g then g:Destroy();self.prompts[prompt]=nil end end)
 RunService.Heartbeat:Connect(function(dt)
  self.scan+=dt;self.pulse+=dt
  if self.scan>=.12 then
   local character=self.player.Character;local tool=character and character:FindFirstChildOfClass('Tool')
   local held=tool~=nil and tool:GetAttribute('SeaStraw')~=nil
   self.ui:setHeld(held)
   self.scan=0;self.point=if held then self:waterPoint() else nil;self.near=self.point~=nil
   if self.holding and (not self.near or self.ui.shop) then self:stop() end
   self.ui:hintState(self.near,self.holding)
   local interactionsEnabled=self.ui.shop==nil and not self.ui.comfort.using and UserInputService:GetFocusedTextBox()==nil
   ProximityPromptService.Enabled=interactionsEnabled
   for prompt,g in self.prompts do if prompt.Parent then g.Enabled=interactionsEnabled end end
   if self.ui.shop and Config.ShopNames[self.ui.shop] then local root=self.player.Character and self.player.Character:FindFirstChild('HumanoidRootPart');local npc=workspace.NPCs:FindFirstChild(Config.ShopNames[self.ui.shop]);if not root or not npc or (root.Position-npc:GetPivot().Position).Magnitude>Config.ShopDistance+2 then self.ui:close() end end
  end
  if self.holding and self.pulse>=.35 then self.pulse=0;self.remotes.Suction:FireServer(self.point) end
 end)
 task.spawn(function()
  for _=1,20 do local ok,result=pcall(function() return self.remotes.Request:InvokeServer('State') end);if ok and result.state then self:stateChanged(result.state);break end;task.wait(.6) end
 end)
 print('[SeaGame] Client ready')
end
return Controller
