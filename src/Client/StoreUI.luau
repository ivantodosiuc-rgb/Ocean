--!nonstrict
local RunService=game:GetService('RunService');local Marketplace=game:GetService('MarketplaceService')
local Package=game.ReplicatedStorage.SeaGame;local Offers=require(Package.Shared.Offers);local Config=require(Package.Shared.Config)
local C=require(script.Parent.Components);local T=require(script.Parent.Theme)
local Store={};Store.__index=Store
local rainbow=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,137,167)),ColorSequenceKeypoint.new(.2,Color3.fromRGB(255,214,104)),ColorSequenceKeypoint.new(.4,Color3.fromRGB(109,228,173)),ColorSequenceKeypoint.new(.6,Color3.fromRGB(91,203,255)),ColorSequenceKeypoint.new(.8,Color3.fromRGB(182,142,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,137,167))})
function Store.rainbow(parent)
 local stroke=parent:FindFirstChildOfClass('UIStroke') or C.stroke(parent,T.White,3);stroke.Color=T.White;stroke.Thickness=3
 return C.new('UIGradient',{Color=rainbow,Rotation=20},stroke)
end
function Store.new(ui)
 local self=setmetatable({ui=ui,prices={},offers={},clock=0,phase=0,animated={}},Store)
 for _,offer in Offers do self.offers[offer.id]=offer end
 self.holder,self.button=C.button(ui.coins,'BuyCoins','+',UDim2.fromOffset(44,44),UDim2.new(1,-49,.5,-22),T.Gold,function() ui:open('Coins') end)
 self.button.TextSize=26
 self.shopIcon,self.shopButton=C.button(ui.root,'CoinShopOffer','',UDim2.fromOffset(88,78),UDim2.fromOffset(12,92),T.PaleGold,function() ui:open('Coins') end)
 C.viewport(self.shopButton,'Icons','CoinStack',UDim2.fromOffset(66,49),UDim2.fromOffset(11,-2))
 local title=C.label(self.shopButton,'COINS +',UDim2.new(1,0,0,24),UDim2.new(0,0,1,-27),13,T.Ink,T.Bold);title.TextXAlignment=Enum.TextXAlignment.Center
 task.spawn(function()
  for _,offer in Offers do
   if offer.assetId>0 then
    local ok,info=pcall(function() return Marketplace:GetProductInfoAsync(offer.assetId,if offer.kind=='Pass' then Enum.InfoType.GamePass else Enum.InfoType.Product) end)
    self.prices[offer.id]=if ok and info.IsForSale and type(info.PriceInRobux)=='number' then info.PriceInRobux else false
   end
  end
  if ui.shop=='Coins' or ui.shop=='Premium' or ui.shop=='Admin' then ui:refreshShop() end
 end)
 self.connection=RunService.Heartbeat:Connect(function(dt)
  self.clock+=dt;if self.clock<.05 then return end;self.phase+=self.clock;self.clock=0
  if not ui.gui.Parent then self.connection:Disconnect();return end
  local reduced=C.reducedMotion()
  for i=#self.animated,1,-1 do
   local entry=self.animated[i]
   if not entry.gradient.Parent then table.remove(self.animated,i) else
    entry.gradient.Rotation=if reduced then 20 else (self.phase*18)%360
    if entry.model and entry.model.Parent and ui.window.Visible then entry.model:PivotTo(entry.base*CFrame.Angles(0,if reduced then 0 else math.sin(self.phase*.8)*.22,0)) end
   end
  end
 end)
 return self
end
function Store:animate(parent,art)
 local world=art and art:FindFirstChildOfClass('WorldModel');local model=world and world:FindFirstChildOfClass('Model')
 table.insert(self.animated,{gradient=Store.rainbow(parent),model=model,base=model and model:GetPivot()})
end
function Store:price(offer)
 local value=self.prices[offer.id]
 return if value==false then 'UNAVAILABLE' else C.number(value or offer.robux)..' R$'
end
function Store:purchase(offer)
 if offer.straw and self.ui.state.owned[offer.straw] then self.ui.callbacks.action('EquipSpecial',offer.straw);return end
 if offer.assetId<=0 then self.ui:toastMessage('Coming soon · Robux purchases are not available yet.','info');return end
 if not self.prices[offer.id] then self.ui:toastMessage('Checking the Roblox price. Please try again shortly.','info');return end
 self.ui.callbacks.action('PurchaseOffer',offer.id)
end
function Store:resize(v)
 self.shopIcon.Visible=v.X>=650
 self.ui.coinLabel.Size=UDim2.new(1,-108,0,30);self.ui.coinLabel.Position=UDim2.fromOffset(52,24)
 self.ui.coinLabel.TextSize=if v.X<650 then 20 else 23
 local shop=self.ui.shop
 if shop~='Coins' and shop~='Premium' and shop~='Admin' then return end
 local w=self.ui.window.Size.X.Offset;local h=self.ui.window.Size.Y.Offset
 if shop=='Coins' then
  local columns=if w<540 then 1 else 2
  self.ui.grid.CellSize=UDim2.fromOffset(math.floor((w-42-12*(columns-1))/columns),236)
 else
  local narrow=w<530
  local cardHeight=if narrow then math.max(480,h-128) else math.max(360,h-128)
  local infoY=cardHeight-363
  self.ui.grid.CellSize=UDim2.fromOffset(w-42,cardHeight)
  if self.hero then
   self.hero.Size=if narrow then UDim2.new(1,-32,0,infoY-10) else UDim2.new(.36,-12,1,-60)
   self.hero.Position=UDim2.fromOffset(16,if narrow then 8 else 28)
   self.info.Position=if narrow then UDim2.fromOffset(18,infoY) else UDim2.new(.38,0,0,25)
   self.info.Size=if narrow then UDim2.new(1,-36,0,280) else UDim2.new(.62,-20,1,-110)
   self.buyHolder.Size=UDim2.new(1,-36,0,48);self.buyHolder.Position=UDim2.new(0,18,1,-78)
   local short=h<450 and not narrow
   self.specialPill.Visible=not short;self.specialNote.Visible=not short;self.detail.Visible=not short
   self.title.Position=UDim2.fromOffset(0,if short then 0 else 32);self.title.Size=UDim2.new(1,0,0,if short then 28 else 36)
   self.intro.Position=UDim2.fromOffset(0,if short then 28 else 72);self.intro.TextSize=if short then 12 else 13
   self.buyButton.TextSize=if short then 16 else 19
   for i,tile in self.statTiles do
    local x=(i-1)%2;local y=math.floor((i-1)/2)
    tile.Size=UDim2.new(.5,-5,0,if short then 44 else 58);tile.Position=UDim2.new(x*.5,x*5,0,(if short then 54 else 108)+y*(if short then 49 else 66))
    tile.Caption.Position=UDim2.fromOffset(8,if short then 2 else 6);tile.Value.Position=UDim2.fromOffset(8,if short then 16 else 23);tile.Value.TextSize=if short then 17 else 19
   end
   if short then
    self.ui.grid.CellSize=UDim2.fromOffset(w-42,math.max(180,h-126))
    self.hero.Size=UDim2.new(.34,-12,1,-53);self.hero.Position=UDim2.fromOffset(16,2)
    self.info.Position=UDim2.new(.36,0,0,0);self.info.Size=UDim2.new(.64,-20,1,0)
    self.buyHolder.Size=UDim2.new(.34,-18,0,44);self.buyHolder.Position=UDim2.new(0,18,1,-48)
   end
  end
 end
end
function Store:renderCoins()
 local ui=self.ui
 for i=1,4 do
  local offer=Offers[i];local bundle=offer.id=='AdminBundle';local card=ui:card(offer.id,i)
  local top=C.frame(card,'Accent',UDim2.new(1,-12,0,79),UDim2.fromOffset(6,6),offer.color:Lerp(T.White,.76));C.corner(top,12)
  local art=C.viewport(top,if bundle then 'Tools' else 'Icons',offer.art,UDim2.fromScale(1,1))
  if bundle then self:animate(card,art) end
  local amount=C.label(card,if bundle then '5,000 + ADMIN STRAW' else C.number(offer.coins)..' COINS',UDim2.new(1,-24,0,33),UDim2.fromOffset(12,90),if bundle then 21 else 27,T.Ink,T.Font);amount.TextXAlignment=Enum.TextXAlignment.Center
  local description=C.label(card,if bundle then 'Strongest suction · Super run & jump' else offer.name,UDim2.new(1,-24,0,24),UDim2.fromOffset(12,122),13,T.Muted,T.Body);description.TextXAlignment=Enum.TextXAlignment.Center;description.TextWrapped=true
  local note=C.label(card,if bundle then 'Permanent straw · Coins granted once' else 'Added directly to your coin balance',UDim2.new(1,-24,0,23),UDim2.fromOffset(12,146),11,T.Muted,T.Body);note.TextXAlignment=Enum.TextXAlignment.Center
  C.button(card,'Purchase',if bundle then 'VIEW  ·  '..self:price(offer) else 'BUY  ·  '..self:price(offer),UDim2.new(1,-28,0,44),UDim2.fromOffset(14,174),offer.color,function() if bundle then ui:open('Admin') else self:purchase(offer) end end)
  local status=C.label(card,if offer.assetId<=0 then 'COMING SOON' else 'SECURE ROBLOX CHECKOUT',UDim2.new(1,-24,0,14),UDim2.fromOffset(12,222),9,T.Muted,T.Bold);status.TextXAlignment=Enum.TextXAlignment.Center
 end
end
function Store:renderSpecial(id)
 local ui=self.ui;local offer=self.offers[id];local admin=id=='AdminBundle';local def=Config.StrawById[offer.straw]
 local card=ui:card('SpecialShowcase',1)
 self.hero=C.viewport(card,'Tools',offer.straw,UDim2.new(.36,-12,1,-60),UDim2.fromOffset(16,28));self.hero.Name='Hero'
 self:animate(card,self.hero)
 self.info=C.frame(card,'Details',UDim2.new(.62,-20,1,-110),UDim2.new(.38,0,0,25));self.info.BackgroundTransparency=1
 self.specialPill=C.pill(self.info,if admin then 'ROYAL AURORA' else 'RAINBOW EDITION',offer.color:Lerp(T.White,.5),UDim2.fromOffset(155,24),UDim2.new())
 self.title=C.label(self.info,offer.name,UDim2.new(1,0,0,36),UDim2.fromOffset(0,32),27,T.Ink,T.Font);self.title.TextScaled=true;C.new('UITextSizeConstraint',{MinTextSize=20,MaxTextSize=27},self.title)
 self.intro=C.label(self.info,if admin then '+5,000 coins · Permanent straw' else 'A rainbow finish for every adventure.',UDim2.new(1,0,0,24),UDim2.fromOffset(0,72),13,T.Muted,T.Body)
 local stats=if admin then {{'SUCTION',C.number(def.power*def.speed*Config.Ocean.BaseRemovalRate)..'/s'},{'REACH',def.reach..' studs'},{'SUPER RUN',def.walk..' studs/s'},{'SUPER JUMP',def.jumpHeight..' studs'}} else {{'SUCTION',C.number(def.power*def.speed*Config.Ocean.BaseRemovalRate)..'/s'},{'REACH',def.reach..' studs'},{'POWER',def.power..'x'},{'SPEED',def.speed..'x'}}
 self.statTiles={}
 for i,stat in stats do
  local x=(i-1)%2;local y=math.floor((i-1)/2)
  local tile=C.frame(self.info,'Stat'..i,UDim2.new(.5,-5,0,58),UDim2.new(x*.5,x*5,0,108+y*66),if i%2==1 then T.Aqua:Lerp(T.White,.4) else offer.color:Lerp(T.White,.76));C.corner(tile,10)
  C.label(tile,stat[1],UDim2.new(1,-16,0,17),UDim2.fromOffset(8,6),10,T.Muted,T.Bold).Name='Caption'
  C.label(tile,stat[2],UDim2.new(1,-16,0,27),UDim2.fromOffset(8,23),19,T.Ink,T.Font).Name='Value';table.insert(self.statTiles,tile)
 end
 self.detail=C.label(self.info,if admin then 'Fastest straw, even with max upgrades.\nMovement boosts while held. Coins awarded once.' else 'Same base performance as Ocean Vacuum (tier 6).\nWorks with your existing upgrades.',UDim2.new(1,0,0,42),UDim2.fromOffset(0,241),12,T.Muted,T.Body);self.detail.TextWrapped=true;self.detail.TextYAlignment=Enum.TextYAlignment.Top
 local owned=ui.state.owned[offer.straw];local equipped=ui.state.equipped==offer.straw
 self.buyHolder,self.buyButton=C.button(card,'BuySpecial',if equipped then 'EQUIPPED' elseif owned then 'EQUIP STRAW' else 'BUY  ·  '..self:price(offer),UDim2.new(1,-36,0,48),UDim2.new(0,18,1,-78),if admin then Color3.fromRGB(208,170,255) else T.Gold,function() if not equipped then self:purchase(offer) end end)
 self.buyButton.Active=not equipped;self.buyButton.Selectable=not equipped
 self.specialNote=C.label(card,if offer.assetId<=0 then 'COMING SOON · CHECKOUT NOT AVAILABLE YET' else 'ONE-TIME PURCHASE · YOURS TO KEEP',UDim2.new(1,-20,0,17),UDim2.new(0,10,1,-23),10,T.Muted,T.Bold);self.specialNote.TextXAlignment=Enum.TextXAlignment.Center
end
return Store
