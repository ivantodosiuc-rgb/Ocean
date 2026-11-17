from pathlib import Path
R=Path(__file__).resolve().parents[1]
p=R/'src/Client/UI.luau';s=p.read_text(encoding='utf-8')
def swap(a,b):
 global s
 assert a in s,a[:100]
 s=s.replace(a,b)
swap("local ComfortUI=require(script.Parent.ComfortUI)","local ComfortUI=require(script.Parent.ComfortUI)\nlocal StoreUI=require(script.Parent.StoreUI)")
swap("UDim2.fromOffset(55,55),UDim2.fromOffset(2,3)","UDim2.fromOffset(46,52),UDim2.fromOffset(0,5)")
swap("UDim2.fromOffset(60,8)","UDim2.fromOffset(52,8)")
swap("self.wave=C.waveIcon(seaBody,UDim2.fromOffset(12,9))","self.wave=C.viewport(seaBody,'Icons','Ocean',UDim2.fromOffset(47,47),UDim2.fromOffset(6,5))")
swap(" self.comfort=ComfortUI.new(self)"," self.store=StoreUI.new(self)\n self.comfort=ComfortUI.new(self)")
swap("if self.shop=='Straws' or self.shop=='Premium' or w<530", "if self.shop=='Straws' or self.shop=='Premium' or self.shop=='Admin' or self.shop=='Coins' or w<530")
swap("elseif self.shop=='Upgrades' then 185", "elseif self.shop=='Upgrades' then 214")
swap("if w<530 and self.shop and self.shop~='Premium' then", "if w<530 and self.shop and Config.ShopNames[self.shop] then")
swap(" if self.comfort then self.comfort:resize(v) end", " if self.comfort then self.comfort:resize(v) end\n if self.store then self.store:resize(v) end")
swap("(not Config.ShopNames[shop] and shop~='Premium')", "(not Config.ShopNames[shop] and shop~='Premium' and shop~='Coins' and shop~='Admin')")
swap("if shop=='Premium' then\n  self.headerTitle", "if shop=='Premium' or shop=='Coins' or shop=='Admin' then\n  self.headerTitle")
start=s.index("  self.headerTitle.Text='A SPLASH OF COLOUR'")
end=s.index("\n end",start)
s=s[:start]+'''  self.headerTitle.Text=if shop=='Coins' then 'COIN BOUTIQUE' elseif shop=='Admin' then 'ROYAL AURORA' else 'PRISM STRAW'
  self.headerSubtitle.Text=if shop=='Coins' then 'A little gold for your next adventure.' elseif shop=='Admin' then '5,000 coins + our strongest straw' else 'A special straw. A spectrum of colour.'
  self.accent.BackgroundColor3=if shop=='Coins' then T.PaleGold else Color3.fromRGB(231,217,252);self.accent.SquareBottom.BackgroundColor3=self.accent.BackgroundColor3
  self.headerArt:Destroy();self.headerArt=C.viewport(self.window,if shop=='Coins' then 'Icons' else 'Tools',if shop=='Coins' then 'CoinStack' elseif shop=='Admin' then 'AdminStraw' else 'PrismStraw',UDim2.fromOffset(70,78),UDim2.fromOffset(9,4))
  self.footer.Visible=false;self.scroll.Size=UDim2.new(1,-30,1,-114)
  if shop=='Coins' then self.store:renderCoins() else self.store:renderSpecial(if shop=='Admin' then 'AdminBundle' else 'Prism') end
  self:resize();self.scroll.CanvasPosition=scrollPosition;return'''+s[end:]
swap("  for i,item in Config.Straws do", "  local catalogue=table.clone(Config.Straws);for _,special in {Config.PremiumStraw,Config.AdminStraw} do if s.owned[special.id] then table.insert(catalogue,special) end end\n  for i,item in catalogue do")
# Keep the established responsive straw-card layout, adding a quiet coloured stage.
swap("local card=self:card(item.id,i);card:SetAttribute('StrawCard',true);C.pill", "local card=self:card(item.id,i);card:SetAttribute('StrawCard',true);C.pill")
swap("   C.viewport(card,'Tools',item.id,UDim2.new(1,-28,0,93),UDim2.fromOffset(14,29)).Name='Art'", "   local art=C.viewport(card,'Tools',item.id,UDim2.new(1,-28,0,93),UDim2.fromOffset(14,29));art.Name='Art';art.BackgroundTransparency=0;art.BackgroundColor3=item.color:Lerp(T.White,.86);C.corner(art,12)\n   if item.premium then self.store:animate(card,art) end")
start=s.index("   C.viewport(card,'Icons',item.icon")
end=s.index("\n  end\n else",start)
s=s[:start]+'''   local accent=({Power=T.Coral,Speed=Color3.fromRGB(111,186,247),Walk=T.Gold,Backpack=T.Teal})[item.id]
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
   local _,button=C.button(card,'Upgrade',if price then 'UPGRADE  ·  '..C.number(price) else 'MAX LEVEL',UDim2.new(1,-26,0,44),UDim2.fromOffset(13,156),if price then accent else T.Aqua,function() if price then self.callbacks.action('Upgrade',item.id) end end);button.TextSize=16;button.Active=price~=nil;button.Selectable=price~=nil'''+s[end:]
p.write_text(s,encoding='utf-8')
# WC is unchanged; the old preview-only shop is replaced by the shared commerce view.
p=R/'src/Client/ComfortUI.luau';s=p.read_text(encoding='utf-8')
s=s[:s.index(" local clock=0")]+''' self.rainbow=require(script.Parent.StoreUI).rainbow(self.button)
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
'''+s[s.index('function ComfortUI:update'):s.index('function ComfortUI:resize')]+'''function ComfortUI:resize(v)
 local compact=v.X<650;local width=if compact then math.min(260,v.X-126) else 240
 self.bar.Size=UDim2.fromOffset(width,46);self.bar.Position=if compact then UDim2.fromOffset(12,166) else UDim2.new(.5,-120,0,92)
 local landscape=v.Y<450 and not compact
 self.offer.Size=UDim2.fromOffset(if landscape then 64 else 80,if landscape then 74 else 90)
 self.offer.Position=UDim2.new(1,if landscape then -184 else -94,0,if compact then 166 else 92)
end
return ComfortUI
'''
p.write_text(s,encoding='utf-8')
print('Integrated store, icons, upgrade cards, rainbow offer.')
