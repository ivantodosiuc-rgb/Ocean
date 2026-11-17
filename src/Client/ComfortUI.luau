--!nonstrict
local RunService=game:GetService('RunService');local GuiService=game:GetService('GuiService')
local Config=require(game.ReplicatedStorage.SeaGame.Shared.Config)
local C=require(script.Parent.Components);local T=require(script.Parent.Theme)
local ComfortUI={};ComfortUI.__index=ComfortUI
function ComfortUI.new(ui)
 local self=setmetatable({ui=ui,percent=0,using=false,phase=0},ComfortUI)
 self.bar=C.panel(ui.root,'RestroomMeter',UDim2.fromOffset(240,46),UDim2.new(.5,-120,0,92),T.Cream,13)
 local badge=C.frame(self.bar,'WC',UDim2.fromOffset(32,32),UDim2.fromOffset(7,7),T.Gold);C.corner(badge,10)
 local label=C.label(badge,'WC',UDim2.fromScale(1,1),nil,13,T.Ink,T.Bold);label.TextXAlignment=Enum.TextXAlignment.Center
 self.label=C.label(self.bar,'RESTROOM',UDim2.new(1,-105,0,19),UDim2.fromOffset(47,5),10,T.Muted,T.Bold)
 self.value=C.label(self.bar,'0%',UDim2.fromOffset(48,20),UDim2.new(1,-57,0,3),14,T.Ink,T.Bold);self.value.TextXAlignment=Enum.TextXAlignment.Right
 local track=C.frame(self.bar,'Track',UDim2.new(1,-58,0,8),UDim2.fromOffset(47,29),T.Sand);C.corner(track,4)
 self.fill=C.frame(track,'Fill',UDim2.fromScale(0,1),nil,T.Gold);C.corner(self.fill,4)
 self.number=C.new('NumberValue',{Value=0},self.bar);self.number.Changed:Connect(function(value) self.value.Text=string.format('%.0f%%',value);self.fill.Size=UDim2.fromScale(value/100,1) end)
 local hint=C.new('TextButton',{Name='Help',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text='',AutoButtonColor=false},self.bar)
 hint.Activated:Connect(function() ui:toastMessage('Fills from your own 5% of the ocean. Visit WC to empty it.','info') end)
 self.offer,self.button,self.scale=C.button(ui.root,'PrismOffer','',UDim2.fromOffset(80,90),UDim2.new(1,-94,0,92),Color3.fromRGB(240,220,255),function() if not self.using then ui:open('Premium') end end)
 self.art=C.viewport(self.button,'Tools','PrismStraw',UDim2.new(1,0,1,-20),UDim2.fromOffset(0,-2));self.art.Rotation=-15
 local price=C.label(self.button,'79 R$',UDim2.new(1,0,0,22),UDim2.new(0,0,1,-24),13,T.Ink,T.Bold);price.TextXAlignment=Enum.TextXAlignment.Center
 self.rim=self.button:FindFirstChildOfClass('UIStroke');self.rim.Thickness=2.5
 self.button.MouseEnter:Connect(function() C.tween(self.art,.25,{Rotation=0},Enum.EasingStyle.Back) end)
 self.button.MouseLeave:Connect(function() C.tween(self.art,.25,{Rotation=-15}) end)
 self.button.SelectionGained:Connect(function() C.tween(self.scale,.2,{Scale=1.06});C.tween(self.art,.25,{Rotation=0}) end)
 self.button.SelectionLost:Connect(function() C.tween(self.scale,.2,{Scale=1});C.tween(self.art,.25,{Rotation=-15}) end)
 self.rainbow=require(script.Parent.StoreUI).rainbow(self.button)
 local clock=0
 self.connection=RunService.Heartbeat:Connect(function(dt)
  clock+=dt;if clock<.06 then return end;self.phase+=clock;clock=0
  if not ui.gui.Parent then self.connection:Disconnect();return end
  local reduced=C.reducedMotion()
  self.rainbow.Rotation=if reduced then 20 else (self.phase*20)%360
  self.button.BackgroundColor3=Color3.fromHSV(if reduced then .76 else (self.phase/12)%1,.24,1)
 end)
 return self
end
function ComfortUI:update(payload)
 self.percent=math.clamp(payload.percent or 0,0,100);self.using=payload.using==true
 self.bar:SetAttribute('ServerPercent',self.percent);self.bar:SetAttribute('UsingRestroom',self.using)
 if self.tween then self.tween:Cancel() end
 self.tween=C.tween(self.number,if self.using then Config.Restroom.UseSeconds elseif self.percent==0 then .8 else .45,{Value=if self.using then 0 else self.percent},if self.using then Enum.EasingStyle.Sine else Enum.EasingStyle.Quart)
 self.label.Text=if self.using then 'TAKING A BREAK' elseif self.percent>=100 then 'VISIT THE WC' else 'RESTROOM'
 self.bar.BackgroundColor3=if self.percent>=100 then T.PaleGold else T.Cream
end
function ComfortUI:resize(v)
 local compact=v.X<650;local width=if compact then math.min(260,v.X-126) else 240
 self.bar.Size=UDim2.fromOffset(width,46);self.bar.Position=if compact then UDim2.fromOffset(12,166) else UDim2.new(.5,-120,0,92)
 local landscape=v.Y<450 and not compact
 self.offer.Size=UDim2.fromOffset(if landscape then 64 else 80,if landscape then 74 else 90)
 self.offer.Position=UDim2.new(1,if landscape then -184 else -94,0,if compact then 166 else 92)
end
return ComfortUI
