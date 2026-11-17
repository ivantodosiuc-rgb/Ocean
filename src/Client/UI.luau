--!nonstrict
local Players=game:GetService('Players');local UserInputService=game:GetService('UserInputService');local RunService=game:GetService('RunService');local GuiService=game:GetService('GuiService')
local Package=game:GetService('ReplicatedStorage').SeaGame;local Config=require(Package.Shared.Config);local Economy=require(Package.Shared.Economy)
local T=require(script.Parent.Theme);local C=require(script.Parent.Components)
local ComfortUI=require(script.Parent.ComfortUI)
local StoreUI=require(script.Parent.StoreUI)
local DepthZones=require(Package.Shared.DepthZones)
local UI={};UI.__index=UI
function UI.new(callbacks)
 local self=setmetatable({callbacks=callbacks,shop=nil,state=nil,world={},cards={},toastId=0,closing=0,busy=false},UI)
 local old=Players.LocalPlayer.PlayerGui:FindFirstChild('SeaGameUI');if old then old:Destroy() end
 self.gui=C.new('ScreenGui',{Name='SeaGameUI',ResetOnSpawn=false,DisplayOrder=20,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets},Players.LocalPlayer.PlayerGui)
 self.root=C.frame(self.gui,'SafeArea');self.root.BackgroundTransparency=1
 self.coins=C.panel(self.root,'Coins',UDim2.fromOffset(202,62),UDim2.fromOffset(16,12),T.Cream,16)
 C.viewport(self.coins,'Icons','Coin',UDim2.fromOffset(46,52),UDim2.fromOffset(0,5))
 C.label(self.coins,'COINS',UDim2.fromOffset(130,16),UDim2.fromOffset(52,8),11,T.Muted,T.Bold)
 self.coinLabel=C.label(self.coins,'0',UDim2.new(1,-68,0,30),UDim2.fromOffset(60,24),26,T.Ink,T.Font)
 self.coinValue=C.new('NumberValue',{Value=0},self.gui);self.coinValue.Changed:Connect(function(n) self.coinLabel.Text=C.number(n) end)
 self.coinScale=C.new('UIScale',{Scale=1},self.coins)
 self.bag=C.panel(self.root,'Backpack',UDim2.fromOffset(202,62),UDim2.fromOffset(230,12),T.Cream,16)
 C.viewport(self.bag,'Icons','Backpack',UDim2.fromOffset(54,54),UDim2.fromOffset(2,1))
 C.label(self.bag,'BACKPACK',UDim2.fromOffset(140,16),UDim2.fromOffset(59,7),11,T.Muted,T.Bold)
 self.bagLabel=C.label(self.bag,'0 / 5',UDim2.fromOffset(125,24),UDim2.fromOffset(59,21),22,T.Ink,T.Font)
 local bagTrack=C.frame(self.bag,'Track',UDim2.new(1,-70,0,6),UDim2.fromOffset(59,49),T.Sand);C.corner(bagTrack,3)
 self.bagFill=C.frame(bagTrack,'Fill',UDim2.fromScale(0,1),nil,T.Teal);C.corner(self.bagFill,3)
 self.bagScale=C.new('UIScale',{Scale=1},self.bag)
 self.bagValue=C.new('NumberValue',{Value=0},self.gui);self.bagValue.Changed:Connect(function(n) self.bagLabel.Text=string.format('%d / %d',math.floor(n+.5),if self.state then self.state.capacity else 5) end)
 self.sea=C.frame(self.root,'OceanProgress',UDim2.fromOffset(320,70),UDim2.new(.5,0,0,10));self.sea.BackgroundTransparency=1;self.sea.AnchorPoint=Vector2.new(.5,0)
 local seaShadow=C.frame(self.sea,'Shadow',UDim2.fromScale(1,1),UDim2.fromOffset(0,3),T.DeepTeal);C.corner(seaShadow,16)
 local seaBody=C.panel(self.sea,'Body',UDim2.fromScale(1,1),nil,T.Paper,16)
 seaBody.SandInlay:Destroy();C.skin(seaBody,.14)
 self.wave=C.viewport(seaBody,'Icons','Ocean',UDim2.fromOffset(47,47),UDim2.fromOffset(6,5));self.waveScale=C.new('UIScale',{Scale=1},self.wave)
 C.label(seaBody,'OCEAN REMAINING',UDim2.new(1,-74,0,17),UDim2.fromOffset(61,8),12,T.Muted,T.Bold)
 self.seaLabel=C.label(seaBody,'--.--%',UDim2.new(1,-74,0,30),UDim2.fromOffset(60,23),27,T.Ink,T.Bold);self.seaLabel.Name='Percent'
 local seaTrack=C.frame(seaBody,'Track',UDim2.new(1,-28,0,7),UDim2.fromOffset(14,56),T.Aqua);C.corner(seaTrack,4)
 self.seaFill=C.frame(seaTrack,'Fill',UDim2.fromScale(1,1),nil,T.Teal);C.corner(self.seaFill,4)
 self.seaNumber=C.new('NumberValue',{Name='DisplayedOceanPercent',Value=100},self.gui)
 self.seaNumber.Changed:Connect(function(value)
  local text=string.format('%.2f%%',math.clamp(value,0,100));if self.seaLabel.Text~=text then self.seaLabel.Text=text end
  self.seaFill.Size=UDim2.fromScale(math.clamp(value/100,0,1),1)
 end)
 self.slot=C.panel(self.root,'EquippedStraw',UDim2.fromOffset(254,66),UDim2.new(.5,-127,1,-82),T.Cream,17)
 self.toolArt=C.viewport(self.slot,'Tools','BasicStraw',UDim2.fromOffset(58,61),UDim2.fromOffset(1,2))
 self.slotCaption=C.label(self.slot,'EQUIPPED',UDim2.fromOffset(180,16),UDim2.fromOffset(62,10),11,T.Muted,T.Bold)
 self.toolLabel=C.label(self.slot,'Basic Straw',UDim2.fromOffset(183,28),UDim2.fromOffset(62,25),20,T.Ink,T.Font)
 local slotButton=C.new('TextButton',{Name='Equip',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text='',AutoButtonColor=false},self.slot)
 slotButton.Activated:Connect(function() callbacks.stop();callbacks.action('ToggleHeld') end)
 self.hint=C.panel(self.root,'ActionHint',UDim2.fromOffset(360,34),UDim2.new(.5,-180,1,-130),T.Ink,12)
 self.hintLabel=C.label(self.hint,'Find the shore. Hold right mouse to sip.',UDim2.new(1,-16,1,0),UDim2.fromOffset(8,0),14,T.Cream,T.Body);self.hintLabel.TextXAlignment=Enum.TextXAlignment.Center
 self.touchHolder,self.touchButton,self.touchScale=C.button(self.root,'HoldToSip','HOLD\nTO SIP',UDim2.fromOffset(92,92),UDim2.new(1,-118,1,-227),T.Teal,nil)
 self.touchButton.TextSize=19;self.touchHolder.Visible=UserInputService.TouchEnabled;C.new('UIAspectRatioConstraint',{AspectRatio=1},self.touchHolder)
 self.toast=C.panel(self.root,'Toast',UDim2.fromOffset(370,58),UDim2.new(.5,-185,0,88),T.Cream,16);self.toast.Visible=false
 self.toastLabel=C.label(self.toast,'',UDim2.new(1,-28,1,-12),UDim2.fromOffset(14,6),17,T.Ink,T.Bold);self.toastLabel.TextWrapped=true;self.toastLabel.TextXAlignment=Enum.TextXAlignment.Center
 self.toastScale=C.new('UIScale',{Scale=1},self.toast)
 self.dim=C.new('TextButton',{Name='Dim',Size=UDim2.fromScale(1,1),BackgroundColor3=T.Ink,BackgroundTransparency=1,BorderSizePixel=0,Text='',AutoButtonColor=false,Visible=false,ZIndex=5},self.root);self.dim.Activated:Connect(function() self:close() end)
 self.window=C.new('CanvasGroup',{Name='ShopWindow',Size=UDim2.fromOffset(780,600),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),BackgroundColor3=T.Cream,BorderSizePixel=0,Visible=false,ZIndex=6,GroupTransparency=0},self.root);C.corner(self.window,22);C.stroke(self.window,T.Ink,3)
 self.windowScale=C.new('UIScale',{Scale=1},self.window)
 C.skin(self.window,true)
 self.accent=C.frame(self.window,'Header',UDim2.new(1,0,0,91),nil,T.Aqua);C.corner(self.accent,22)
 C.frame(self.accent,'SquareBottom',UDim2.new(1,0,0,22),UDim2.new(0,0,1,-22),T.Aqua)
 self.accent.Position=UDim2.fromOffset(12,12);self.accent.Size=UDim2.new(1,-24,0,79);self.accent.BackgroundTransparency=.42;self.accent.SquareBottom.BackgroundTransparency=.42
 self.headerTitle=C.label(self.window,'STRAWS',UDim2.new(1,-160,0,34),UDim2.fromOffset(87,14),30,T.Ink,T.Font)
 self.headerSubtitle=C.label(self.window,'Finn\'s collection',UDim2.new(1,-160,0,25),UDim2.fromOffset(88,49),15,T.Muted,T.Body)
 self.headerArt=C.viewport(self.window,'Tools','ColorfulStraw',UDim2.fromOffset(70,78),UDim2.fromOffset(9,4))
 local _,close=C.button(self.window,'Close','',UDim2.fromOffset(44,42),UDim2.new(1,-59,0,20),T.Paper,function() self:close() end)
 for _,a in {45,-45} do local slash=C.frame(close,'Cross',UDim2.fromOffset(18,3),UDim2.fromScale(.5,.5),T.Ink);slash.AnchorPoint=Vector2.new(.5,.5);slash.Rotation=a;C.corner(slash,2) end
 self.scroll=C.new('ScrollingFrame',{Name='Items',Size=UDim2.new(1,-30,1,-114),Position=UDim2.fromOffset(15,101),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,ScrollBarImageColor3=T.DeepTeal,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ElasticBehavior=Enum.ElasticBehavior.WhenScrollable},self.window)
 C.new('UIPadding',{PaddingLeft=UDim.new(0,3),PaddingRight=UDim.new(0,9),PaddingTop=UDim.new(0,3),PaddingBottom=UDim.new(0,8)},self.scroll)
 self.grid=C.new('UIGridLayout',{CellPadding=UDim2.fromOffset(12,12),CellSize=UDim2.fromOffset(230,240),SortOrder=Enum.SortOrder.LayoutOrder},self.scroll)
 self.footer=C.frame(self.window,'SellFooter',UDim2.new(1,-36,0,79),UDim2.new(0,18,1,-92),T.Cream);self.footer.Visible=false
 self.footer.BackgroundTransparency=1
 self.sellTotal=C.label(self.footer,'TOTAL  0',UDim2.new(.45,0,0,34),UDim2.new(),23,T.Ink,T.Font)
 self.sellHint=C.label(self.footer,'Every little find adds up.',UDim2.new(.5,0,0,24),UDim2.fromOffset(0,36),13,T.Muted,T.Body)
 self.sellHolder,self.sellButton=C.button(self.footer,'SellAll','SELL ALL',UDim2.new(.48,0,0,51),UDim2.new(.52,0,0,9),T.Gold,function() callbacks.action('SellAll') end)
 self.store=StoreUI.new(self)
 self.comfort=ComfortUI.new(self)
 self.depthBadge=C.panel(self.root,'DepthZone',UDim2.fromOffset(306,30),UDim2.new(.5,-153,1,-168),T.Cream,10)
 C.viewport(self.depthBadge,'Icons','Shell',UDim2.fromOffset(32,28),UDim2.fromOffset(3,1))
 self.depthLabel=C.label(self.depthBadge,'SHALLOW SHORES  ·  0.0 m',UDim2.new(1,-42,1,0),UDim2.fromOffset(38,0),12,T.Ink,T.Bold)
 local depthClock=0
 self.depthConnection=RunService.Heartbeat:Connect(function(dt)
  depthClock+=dt;if depthClock<.4 then return end;depthClock=0
  if not self.gui.Parent then self.depthConnection:Disconnect();return end
  local root=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
  if not root then return end
  local depth=math.max(0,3-root.Position.Y);local zone=DepthZones.index(depth)
  self.depthLabel.Text=string.upper(DepthZones.List[zone].name)..string.format('  ·  %.1f m',depth/DepthZones.StudsPerMetre)
  self.depthBadge:SetAttribute('Zone',zone);self.depthBadge:SetAttribute('DepthStuds',depth)
 end)
 UserInputService:GetPropertyChangedSignal('TouchEnabled'):Connect(function() self.touchHolder.Visible=UserInputService.TouchEnabled;self:resize() end)
 self.root:GetPropertyChangedSignal('AbsoluteSize'):Connect(function() self:resize() end)
 self:resize();return self
end
function UI:resize()
 local v=self.root.AbsoluteSize;if v.X<1 then return end
 local compact=v.X<650;self.compact=compact
 local seaWidth=if compact then math.min(320,v.X-24) elseif v.X<850 then 280 else 320
 local chipWidth=if compact then math.floor((v.X-36)/2) else math.min(202,math.floor((v.X-seaWidth-60)/2))
 self.coins.Size=UDim2.fromOffset(chipWidth,62);self.coins.Position=UDim2.fromOffset(12,if compact then 92 else 10)
 self.bag.Size=UDim2.fromOffset(chipWidth,62);self.bag.Position=UDim2.new(1,-12-chipWidth,0,if compact then 92 else 10)
 self.coinLabel.TextSize=if chipWidth<180 then 22 else 26
 self.bagLabel.Size=UDim2.new(1,-66,0,24);self.bagLabel.TextSize=if chipWidth<180 then 20 else 22
 self.sea.Size=UDim2.fromOffset(seaWidth,70);self.sea.Position=UDim2.new(.5,0,0,10)
 self.toast.Size=UDim2.fromOffset(math.min(v.X-30,390),58);self.toast.AnchorPoint=Vector2.new(.5,0);self.toast.Position=UDim2.new(.5,0,0,if compact then 266 else 148);self.toast.ZIndex=12
 self.hint.Size=UDim2.fromOffset(math.min(v.X-32,360),34);self.hint.AnchorPoint=Vector2.new(.5,0);self.hint.Position=UDim2.new(.5,0,1,if compact then -125 else -130)
 local w=math.min(800,v.X-28);local h=math.min(if self.shop=='Straws' or self.shop=='Premium' or self.shop=='Admin' or self.shop=='Coins' or w<530 then 615 elseif self.shop=='Upgrades' then 580 else 520,v.Y-28)
 self.window.Size=UDim2.fromOffset(w,h)
 local columns=if self.shop=='Upgrades' then (if w<530 then 1 else 2) elseif self.shop=='Sell' then (if w<570 then 1 else 2) else math.clamp(math.floor((w-30)/214),1,3)
 local short=v.Y<450
 local usable=w-42;self.grid.CellSize=UDim2.fromOffset(math.floor((usable-12*(columns-1))/columns),if self.shop=='Sell' then 89 elseif self.shop=='Upgrades' then 214 elseif short then 170 else 238)
 for _,card in self.cards do if card:GetAttribute('StrawCard') then
  local art=card.Art;art.Size=if short then UDim2.fromOffset(58,100) else UDim2.new(1,-28,0,93);art.Position=if short then UDim2.fromOffset(7,10) else UDim2.fromOffset(14,29)
  card.Pill.Visible=not short
  for _,name in {'Title','Power','Price'} do local label=card[name];label.TextXAlignment=if short then Enum.TextXAlignment.Left else Enum.TextXAlignment.Center;label.Size=UDim2.new(1,if short then -86 else -20,0,24) end
  card.Title.Position=if short then UDim2.fromOffset(75,12) else UDim2.fromOffset(10,117);card.Title.TextSize=if short then 17 else 19
  card.Power.Position=if short then UDim2.fromOffset(75,42) else UDim2.fromOffset(10,141);card.Power.TextSize=if short then 12 else 13
  card.Price.Position=if short then UDim2.fromOffset(75,72) else UDim2.fromOffset(10,161);card.Price.TextSize=if short then 16 else 17
  card.Purchase.Position=UDim2.fromOffset(11,if short then 116 else 187);card.Purchase.Size=UDim2.new(1,-22,0,44)
 end end
 self.headerTitle.TextSize=if w<420 then 23 else 30
 if self.shop=='Premium' then self.headerTitle.Text=if w<530 then 'PRISM STRAW' else 'A SPLASH OF COLOUR' end
 self.headerSubtitle.TextSize=if w<420 then 13 else 15
 if w<420 then
  if self.shop=='Coins' then self.headerSubtitle.Text='Coins for your next adventure.'
  elseif self.shop=='Admin' then self.headerSubtitle.Text='5,000 coins + super straw'
  elseif self.shop=='Premium' then self.headerSubtitle.Text='The rainbow collection' end
 end
 self.sellTotal.TextSize=if w<420 then 19 else 23
 self.sellHint.Visible=w>=420
 local portrait=v.X<530;self.slot.Size=UDim2.fromOffset(if portrait then 190 else 254,if portrait then 60 else 66);self.slot.Position=UDim2.new(.5,if portrait then -95 else -127,1,if portrait then -78 else -82)
 self.toolArt.Size=UDim2.fromOffset(if portrait then 44 else 58,if portrait then 56 else 61)
 self.toolLabel.Position=UDim2.fromOffset(if portrait then 50 else 62,25);self.toolLabel.Size=UDim2.new(1,if portrait then -56 else -71,0,28);self.toolLabel.TextSize=if portrait then 17 else 20
 self.slotCaption.Position=UDim2.fromOffset(if portrait then 50 else 62,10)
 if w<530 and self.shop and Config.ShopNames[self.shop] then self.headerTitle.Text=if self.shop=='Straws' then 'STRAWS' elseif self.shop=='Upgrades' then 'UPGRADES' else 'TREASURES';self.headerSubtitle.Text=Config.ShopNames[self.shop]..'\'s shop' end
 if UserInputService.TouchEnabled then self.touchHolder.Position=UDim2.new(1,-112,1,if v.Y<450 then -206 else -230) end
 if self.comfort then self.comfort:resize(v) end
 if self.store then self.store:resize(v) end
end
function UI:toastMessage(message,kind)
 if self.rarityRim then self.rarityRim:Destroy();self.rarityRim=nil end
 if self.toastArt then self.toastArt:Destroy();self.toastArt=nil end
 self.toastLabel.Position=UDim2.fromOffset(14,6);self.toastLabel.Size=UDim2.new(1,-28,1,-12);self.toastLabel.TextXAlignment=Enum.TextXAlignment.Center
 self.toastId+=1;local id=self.toastId;self.toast.Visible=true;self.toast.BackgroundColor3=if kind=='warning' then T.PaleGold elseif kind=='success' then T.Aqua else T.Cream
 self.toastLabel.Text=message;self.toastLabel.TextSize=17;self.toastScale.Scale=if C.reducedMotion() then 1 else .88;C.tween(self.toastScale,.3,{Scale=1},Enum.EasingStyle.Back)
 task.delay(3,function() if self.toastId==id then C.tween(self.toastScale,.15,{Scale=.92});task.wait(.15);if self.toastId==id then self.toast.Visible=false end end end)
end
function UI:burst(origin,color,count)
 local reduced=C.reducedMotion();count=if reduced then 4 else count or 14
 self.confettiCount=self.confettiCount or 0
 for i=1,count do
  if self.confettiCount>=44 then break end;self.confettiCount+=1
  local angle=i*2.399;local distance=if reduced then 12 else 34+(i%4)*16
  local chip=C.frame(self.root,'CelebrationSpark',UDim2.fromOffset(if i%3==0 then 10 else 5,if i%3==0 then 10 else 11),UDim2.fromOffset(origin.X,origin.Y),if i%3==0 then T.Gold else color)
  chip.AnchorPoint=Vector2.new(.5,.5);chip.Rotation=45+i*24;chip.ZIndex=35;C.corner(chip,2)
  C.tween(chip,if reduced then .18 else .55,{Position=UDim2.fromOffset(origin.X+math.cos(angle)*distance,origin.Y+math.sin(angle)*distance+12),Rotation=if reduced then chip.Rotation else chip.Rotation+110,BackgroundTransparency=1,Size=UDim2.fromOffset(2,2)},Enum.EasingStyle.Quart)
  task.delay(.6,function() chip:Destroy();self.confettiCount-=1 end)
 end
end
function UI:pickupNotice(item)
 self:toastMessage('+1 '..item.name..'\n'..item.rarity..'  ·  '..item.value..(if item.value==1 then ' Coin' else ' Coins'),'success')
 self.toastArt=C.viewport(self.toast,'Loot',item.id,UDim2.fromOffset(52,48),UDim2.fromOffset(7,5))
 self.toastLabel.Position=UDim2.fromOffset(68,6);self.toastLabel.Size=UDim2.new(1,-81,1,-12);self.toastLabel.TextXAlignment=Enum.TextXAlignment.Left;self.toastLabel.TextSize=15
 self.toast.BackgroundColor3=item.color:Lerp(T.Paper,.80)
 if self.rarityRim then self.rarityRim:Destroy() end
 self.rarityRim=C.stroke(self.toast,item.color,if item.rarity=='LEGENDARY' then 3 else 2)
 if item.rarity=='EPIC' or item.rarity=='LEGENDARY' then C.purchaseGlint(self.toast) end
end
function UI:pickupArrival(item)
 self.bagScale.Scale=1.07;C.tween(self.bagScale,.32,{Scale=1},Enum.EasingStyle.Back)
 local origin=self.bag.AbsolutePosition-self.root.AbsolutePosition+Vector2.new(28,30)
 self:burst(origin,item.color,9)
end
function UI:upgradeCelebration(category)
 local item=Config.UpgradeById[category];local straw=Config.StrawById[category]
 local message=if item then item.name..' · LEVEL '..tostring(self.state.upgrades[category]) elseif straw then straw.name..' unlocked!' else 'Upgrade complete!'
 if self.shop=='Upgrades' and item then
  self.headerSubtitle.Text=message;self.headerSubtitle.TextColor3=T.DeepTeal
  task.delay(2.3,function() if self.shop=='Upgrades' and self.headerSubtitle.Text==message then self.headerSubtitle.Text='Maya  /  Make your next trip count.';self.headerSubtitle.TextColor3=T.Muted end end)
 else self:toastMessage(message,'success') end
 local card=category and self.scroll:FindFirstChild(category)
 local origin=if card then card.AbsolutePosition-self.root.AbsolutePosition+card.AbsoluteSize/2 else self.root.AbsoluteSize*.5
 self:burst(origin,if straw then straw.color else T.Teal,20)
 if card then C.purchaseGlint(card);local scale=card:FindFirstChildOfClass('UIScale') or C.new('UIScale',{Scale=1},card);scale.Scale=if C.reducedMotion() then 1 else 1.025;C.tween(scale,.35,{Scale=1},Enum.EasingStyle.Back) end
end
function UI:update(state)
 if self.state and state.revision<self.state.revision then return end
 local previous=self.state;self.state=state;C.tween(self.coinValue,.5,{Value=state.coins})
 self.bagLabel.Text=string.format('%d / %d',math.floor(self.bagValue.Value+.5),state.capacity);C.tween(self.bagValue,.22,{Value=state.count});C.tween(self.bagFill,.3,{Size=UDim2.fromScale(state.count/state.capacity,1),BackgroundColor3=if state.count>=state.capacity then T.Coral else T.Teal})
 if previous and previous.count<state.count then self.bagScale.Scale=1.09;C.tween(self.bagScale,.3,{Scale=1},Enum.EasingStyle.Back) end
 self.toolLabel.Text=Config.StrawById[state.equipped].name
 if not previous or previous.equipped~=state.equipped then self.toolArt:Destroy();self.toolArt=C.viewport(self.slot,'Tools',state.equipped,UDim2.fromOffset(58,61),UDim2.fromOffset(1,2));self:resize() end
 if self.shop then self:refreshShop() end
end
function UI:updateWorld(world)
 self.world=world
 if world.ready==false then self.seaLabel.Text='--.--%';return end
 local percent=world.OceanRemainingPercent
 if type(percent)~='number' or percent~=percent then return end
 self.sea:SetAttribute('ServerRemainingPercent',percent)
 if self.seaTarget==nil then self.seaNumber.Value=percent;self.seaLabel.Text=string.format('%.2f%%',percent)
 elseif math.abs(self.seaTarget-percent)>.000000001 then
  if self.seaTween then self.seaTween:Cancel() end
  self.seaTween=C.tween(self.seaNumber,.65,{Value=percent},Enum.EasingStyle.Quad)
 end
 self.seaTarget=percent
end
function UI:setHeld(held)
 if self.held==held then return end;self.held=held
 local key=if UserInputService.PreferredInput==Enum.PreferredInput.Touch then 'TAP' elseif UserInputService.PreferredInput==Enum.PreferredInput.Gamepad then 'Y' else '1'
 self.slotCaption.Text=key..(if held then '  /  PUT AWAY' else '  /  TAKE OUT')
 self.slot.BackgroundColor3=if held then T.Cream else T.Sand
end
function UI:hintState(near,sucking)
 if self.comfort and (self.comfort.using or self.comfort.percent>=100) then self.hintLabel.Text=if self.comfort.using then 'A little shore break...' else 'Restroom full! Visit the wooden WC cabin.';self.touchButton.Text='VISIT\nTHE WC';return end
 self.hintLabel.Text=if self.world.ready==false or self.world.saveStatus=='Retrying' then 'The ocean is syncing. One moment...' elseif self.world.complete then 'Ocean uncovered! Explore every last treasure.' elseif sucking then 'Sipping the sea... uncovering treasure!' elseif self.state and self.state.count>=self.state.capacity then 'Backpack full! Visit Captain Shell.' elseif near then (if UserInputService.TouchEnabled then 'Hold SIP to uncover the shore.' elseif UserInputService.GamepadEnabled then 'Hold RT to sip the sea.' else 'Hold RIGHT MOUSE to sip the sea.') else 'Find the shore. Uncover what lies below.'
 if self.waveActive~=sucking then self.waveActive=sucking;C.tween(self.waveScale,.2,{Scale=if sucking then 1.035 else 1}) end
 self.touchButton.BackgroundColor3=if sucking then T.Gold elseif near then T.Teal else T.Sand
 self.touchButton.Text=if sucking then 'SIPPING...' else 'HOLD\nTO SIP'
end
function UI:open(shop)
 if (not Config.ShopNames[shop] and shop~='Premium' and shop~='Coins' and shop~='Admin') or not self.state or self.comfort.using then return end
 if self.shop~=shop then self.scroll.CanvasPosition=Vector2.zero end
 if not self.shop then self.returnFocus=GuiService.SelectedObject end
 local reduced=C.reducedMotion()
 self.callbacks.stop();self.closing+=1;self.shop=shop;self.dim.Visible=true;self.window.Visible=true;self.window.GroupTransparency=1;self.windowScale.Scale=if reduced then 1 else .94;self.window.Position=UDim2.new(.5,0,.5,if reduced then 0 else 22)
 self:refreshShop();self:resize();C.tween(self.dim,.2,{BackgroundTransparency=.68});C.tween(self.window,.24,{Position=UDim2.fromScale(.5,.5),GroupTransparency=0});C.tween(self.windowScale,.28,{Scale=1},Enum.EasingStyle.Back)
 if UserInputService.GamepadEnabled then GuiService.SelectedObject=self.window.Close.Button end
end
function UI:close()
 if not self.shop then return end;self.shop=nil;self.closing+=1;local id=self.closing
 local reduced=C.reducedMotion()
 C.tween(self.dim,.16,{BackgroundTransparency=1});C.tween(self.window,.16,{GroupTransparency=1,Position=UDim2.new(.5,0,.5,if reduced then 0 else 14)});C.tween(self.windowScale,.16,{Scale=if reduced then 1 else .96});GuiService.SelectedObject=if self.returnFocus and self.returnFocus.Parent then self.returnFocus else nil
 task.delay(.17,function() if id==self.closing then self.window.Visible=false;self.dim.Visible=false end end)
end
function UI:clearCards()
 for _,card in self.cards do card:Destroy() end;self.cards={}
end
function UI:card(name,index)
 local card=C.panel(self.scroll,name,UDim2.new(),nil,T.Paper,15);card.LayoutOrder=index;table.insert(self.cards,card);return card
end
function UI:refreshShop()
 if not self.shop or not self.state then return end
 local scrollPosition=self.scroll.CanvasPosition;self:clearCards();local s=self.state;local shop=self.shop
 if shop=='Premium' or shop=='Coins' or shop=='Admin' then
  self.headerTitle.Text=if shop=='Coins' then 'COIN BOUTIQUE' elseif shop=='Admin' then 'ROYAL AURORA' else 'PRISM STRAW'
  self.headerSubtitle.Text=if shop=='Coins' then 'A little gold for your next adventure.' elseif shop=='Admin' then '5,000 coins + our strongest straw' else 'A special straw. A spectrum of colour.'
  self.accent.BackgroundColor3=if shop=='Coins' then T.PaleGold else Color3.fromRGB(231,217,252);self.accent.SquareBottom.BackgroundColor3=self.accent.BackgroundColor3
  self.headerArt:Destroy();self.headerArt=C.viewport(self.window,if shop=='Coins' then 'Icons' else 'Tools',if shop=='Coins' then 'CoinStack' elseif shop=='Admin' then 'AdminStraw' else 'PrismStraw',UDim2.fromOffset(70,78),UDim2.fromOffset(9,4))
  self.footer.Visible=false;self.scroll.Size=UDim2.new(1,-30,1,-114)
  if shop=='Coins' then self.store:renderCoins() else self.store:renderSpecial(if shop=='Admin' then 'AdminBundle' else 'Prism') end
  self:resize();self.scroll.CanvasPosition=scrollPosition;return
 end
 self.headerTitle.Text=if shop=='Straws' then 'THE STRAW SHACK' elseif shop=='Upgrades' then 'A LITTLE MORE POWER' else 'TREASURE TRADER'
 self.headerSubtitle.Text=if shop=='Straws' then 'Finn  /  Small straw. Big adventures.' elseif shop=='Upgrades' then 'Maya  /  Make your next trip count.' else 'Captain Shell  /  Turn finds into fortune.'
 local color=if shop=='Straws' then T.Aqua elseif shop=='Upgrades' then Color3.fromRGB(255,206,183) else T.PaleGold
 self.accent.BackgroundColor3=color;self.accent.SquareBottom.BackgroundColor3=color
 self.headerArt:Destroy();self.headerArt=C.viewport(self.window,if shop=='Straws' then 'Tools' elseif shop=='Upgrades' then 'Icons' else 'Loot',if shop=='Straws' then 'ColorfulStraw' elseif shop=='Upgrades' then 'Power' else 'TreasureChest',UDim2.fromOffset(70,78),UDim2.fromOffset(9,4))
 self.footer.Visible=shop=='Sell';self.scroll.Size=UDim2.new(1,-30,1,if shop=='Sell' then -205 else -114)
 if shop=='Straws' then
  local catalogue=table.clone(Config.Straws);for _,special in {Config.PremiumStraw,Config.AdminStraw} do if s.owned[special.id] then table.insert(catalogue,special) end end
  for i,item in catalogue do
   local card=self:card(item.id,i);card:SetAttribute('StrawCard',true);C.pill(card,item.tag,item.color:Lerp(T.Paper,.45),UDim2.fromOffset(88,21),UDim2.fromOffset(10,9))
   local art=C.viewport(card,'Tools',item.id,UDim2.new(1,-28,0,93),UDim2.fromOffset(14,29));art.Name='Art';art.BackgroundTransparency=0;art.BackgroundColor3=item.color:Lerp(T.White,.86);C.corner(art,12)
   if item.premium then self.store:animate(card,art) end
   local title=C.label(card,item.name,UDim2.new(1,-20,0,26),UDim2.fromOffset(10,117),19,T.Ink,T.Font);title.Name='Title';title.TextXAlignment=Enum.TextXAlignment.Center
   local power=C.label(card,string.format('%gx · %gx speed · %d studs',item.power,item.speed,item.reach),UDim2.new(1,-20,0,20),UDim2.fromOffset(10,143),12,T.Muted,T.Body);power.Name='Power';power.TextXAlignment=Enum.TextXAlignment.Center
   local owned=s.owned[item.id];local equipped=s.equipped==item.id
   local price=C.label(card,if owned then 'OWNED' else C.number(item.price)..' Coins',UDim2.new(1,-20,0,24),UDim2.fromOffset(10,163),17,T.Ink,T.Bold);price.Name='Price';price.TextXAlignment=Enum.TextXAlignment.Center
   local _,button=C.button(card,'Purchase',if equipped then 'EQUIPPED' elseif owned then 'EQUIP' else 'BUY',UDim2.new(1,-22,0,37),UDim2.fromOffset(11,191),if equipped then T.Aqua elseif owned then T.Teal else T.Gold,function() if not equipped then self.callbacks.action(if owned then 'EquipStraw' else 'BuyStraw',item.id) end end)
   button.Active=not equipped;button.Selectable=not equipped;button.TextSize=17
  end
 elseif shop=='Upgrades' then
  local profile={Upgrades=s.upgrades}
  for i,item in Config.Upgrades do
   local card=self:card(item.id,i);local level=s.upgrades[item.id];local price=Economy.upgradeCost(profile,item.id)
   local accent=({Power=T.Coral,Speed=Color3.fromRGB(111,186,247),Walk=T.Gold,Backpack=T.Teal})[item.id]
   local stage=C.frame(card,'IconStage',UDim2.fromOffset(62,62),UDim2.fromOffset(10,10),accent:Lerp(T.White,.7));C.corner(stage,16)
   C.viewport(stage,'Icons',item.icon,UDim2.fromScale(1,1))
   C.label(card,item.name,UDim2.new(1,-93,0,27),UDim2.fromOffset(82,12),20,T.Ink,T.Font)
   C.label(card,'LEVEL '..level..' / '..item.max,UDim2.new(1,-93,0,22),UDim2.fromOffset(83,40),12,T.Muted,T.Bold)
   local track=C.frame(card,'Progress',UDim2.new(1,-96,0,7),UDim2.fromOffset(82,67),accent:Lerp(T.White,.76));C.corner(track,4)
   local fill=C.frame(track,'Fill',UDim2.fromScale(level/item.max,1),nil,accent);C.corner(fill,4)
   local current,nextValue
   if item.id=='Backpack' then current=s.capacity;nextValue=Config.Capacities[math.min(level+2,#Config.Capacities)]
   elseif item.id=='Walk' then current=s.stats.walk;nextValue=Config.WalkSpeeds[math.min(level+2,#Config.WalkSpeeds)]
   elseif item.id=='Power' then current=string.format('%.1fx',1+level*.2);nextValue=string.format('%.1fx',1+math.min(level+1,item.max)*.2)
   else current=string.format('%.1fx',1+level*.1);nextValue=string.format('%.1fx',1+math.min(level+1,item.max)*.1) end
   local values=C.frame(card,'Comparison',UDim2.new(1,-26,0,37),UDim2.fromOffset(13,87),accent:Lerp(T.White,.86));C.corner(values,9)
   local line=C.label(values,tostring(current)..'   →   '..tostring(nextValue),UDim2.new(1,-16,1,0),UDim2.fromOffset(8,0),23,T.DeepTeal,T.Font);line.TextXAlignment=Enum.TextXAlignment.Center
   local desc=C.label(card,item.description,UDim2.new(1,-26,0,23),UDim2.fromOffset(13,128),13,T.Muted,T.Body);desc.TextXAlignment=Enum.TextXAlignment.Center
   local _,button=C.button(card,'Upgrade',if price then 'UPGRADE  ·  '..C.number(price) else 'MAX LEVEL',UDim2.new(1,-26,0,44),UDim2.fromOffset(13,156),if price then accent else T.Aqua,function() if price then self.callbacks.action('Upgrade',item.id) end end);button.TextSize=16;button.Active=price~=nil;button.Selectable=price~=nil
  end
 else
  for i,item in Config.Loot do
   local count=s.bag[item.id] or 0
   if count==0 then continue end
   local card=self:card(item.id,i)
   C.viewport(card,'Loot',item.id,UDim2.fromOffset(66,70),UDim2.fromOffset(3,7))
   C.label(card,item.name,UDim2.new(1,-92,0,25),UDim2.fromOffset(76,11),17,T.Ink,T.Font)
   C.label(card,string.format('%d found  ·  %d each',count,item.value),UDim2.new(1,-92,0,22),UDim2.fromOffset(76,35),12,T.Muted,T.Body)
   C.label(card,C.number(count*item.value)..' Coins',UDim2.new(1,-92,0,24),UDim2.fromOffset(76,55),17,T.DeepTeal,T.Bold)
   if count==0 then card.BackgroundColor3=Color3.fromRGB(247,241,222) end
  end
  if s.count==0 then
   local card=self:card('EmptyBackpack',1)
   C.viewport(card,'Icons','Backpack',UDim2.fromOffset(66,70),UDim2.fromOffset(3,7))
   C.label(card,'Your next discovery awaits',UDim2.new(1,-90,0,27),UDim2.fromOffset(76,12),16,T.Ink,T.Font)
   local hint=C.label(card,'Uncover the seabed to find treasure.',UDim2.new(1,-90,0,38),UDim2.fromOffset(76,39),13,T.Muted,T.Body);hint.TextWrapped=true
  end
  self.sellTotal.Text='TOTAL  '..C.number(s.value)
  self.sellButton.Text='SELL ALL'
 end
 self:resize();self.scroll.CanvasPosition=scrollPosition
end
function UI:sale(amount)
 self:toastMessage('Treasure sold!  +'..C.number(amount)..' Coins','success')
 local target=self.coins.AbsolutePosition+Vector2.new(28,30)-self.root.AbsolutePosition
 local origin=self.root.AbsoluteSize*Vector2.new(.65,.75)
 for i=1,9 do task.delay(i*.045,function()
  local icon=C.viewport(self.root,'Icons','Coin',UDim2.fromOffset(37,37),UDim2.fromOffset(origin.X,origin.Y));icon.ZIndex=30
  local outward=origin+Vector2.new(math.cos(i*2.4)*60,math.sin(i*2.4)*45-35)
  C.tween(icon,.16,{Position=UDim2.fromOffset(outward.X,outward.Y)},Enum.EasingStyle.Back);task.wait(.17)
  C.tween(icon,.5,{Position=UDim2.fromOffset(target.X-18,target.Y-18),Size=UDim2.fromOffset(24,24)},Enum.EasingStyle.Quart,Enum.EasingDirection.In);task.wait(.5);icon:Destroy()
  self.coinScale.Scale=1.055;C.tween(self.coinScale,.16,{Scale=1})
 end) end
end
function UI:prompt(prompt,inputType)
 -- Keep a prompt that appeared while a menu was open, so it can reappear on close.
 local gui=C.new('BillboardGui',{Name='SeaPrompt',Adornee=prompt.Parent,Size=UDim2.fromOffset(214,62),StudsOffsetWorldSpace=Vector3.new(0,2.1,0),AlwaysOnTop=true,MaxDistance=35,Active=true,Enabled=self.shop==nil},Players.LocalPlayer.PlayerGui)
 local p=C.panel(gui,'Prompt',UDim2.new(1,-6,1,-6),UDim2.fromOffset(3,3),T.Cream,15)
 local key=if inputType==Enum.ProximityPromptInputType.Touch then 'TAP' elseif inputType==Enum.ProximityPromptInputType.Gamepad then 'X' else 'E'
 local button=C.new('TextButton',{Name='Interact',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text='',AutoButtonColor=false},p)
 local k=C.panel(button,'Key',UDim2.fromOffset(42,40),UDim2.fromOffset(8,8),T.Teal,10);local label=C.label(k,key,UDim2.fromScale(1,1),nil,17,T.Ink,T.Font);label.TextXAlignment=Enum.TextXAlignment.Center
 C.label(button,prompt.ObjectText,UDim2.new(1,-63,0,24),UDim2.fromOffset(59,6),17,T.Ink,T.Font)
 C.label(button,prompt.ActionText,UDim2.new(1,-63,0,20),UDim2.fromOffset(59,30),12,T.Muted,T.Body)
 button.Activated:Connect(function() if gui.Enabled and prompt.Enabled and prompt.Parent then prompt:InputHoldBegin();task.delay(prompt.HoldDuration+.05,function() if prompt.Parent then prompt:InputHoldEnd() end end) end end)
 local scale=C.new('UIScale',{Scale=.8},p);C.tween(scale,.25,{Scale=1},Enum.EasingStyle.Back)
 return gui
end
return UI
