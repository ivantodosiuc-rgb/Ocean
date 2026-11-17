--!nonstrict
local Players=game:GetService('Players');local RunService=game:GetService('RunService')
local C=require(script.Parent.Components)
local Rainbow={};Rainbow.__index=Rainbow
function Rainbow.new()
 local self=setmetatable({records={},clock=0,scan=0,phase=0},Rainbow)
 self.connection=RunService.Heartbeat:Connect(function(dt) self:step(dt) end)
 return self
end
function Rainbow:watch(tool)
 if self.records[tool] then return end
 local id=tool:GetAttribute('SeaStraw');if id~='PrismStraw' and id~='AdminStraw' then return end
 local handle=tool:FindFirstChild('Handle');if not handle then return end
 local root=C.new('Attachment',{Name='LocalAurora',Position=Vector3.new(0,-.2,0)},handle)
 local light=C.new('PointLight',{Brightness=if id=='AdminStraw' then .65 else .25,Range=if id=='AdminStraw' then 6 else 3,Shadows=false},root)
 local shine=C.new('Highlight',{Name='AuroraRim',Adornee=tool,FillTransparency=.96,OutlineTransparency=.38,DepthMode=Enum.HighlightDepthMode.Occluded},root)
 local sparks=C.new('ParticleEmitter',{Texture='rbxasset://textures/particles/sparkles_main.dds',Rate=if id=='AdminStraw' then 5 else 2,Speed=NumberRange.new(.1,.35),Lifetime=NumberRange.new(.45,.8),LightEmission=.85,SpreadAngle=Vector2.new(180,180),Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.3,.12),NumberSequenceKeypoint.new(1,0)}),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.15),NumberSequenceKeypoint.new(1,1)})},root)
 self.records[tool]={root=root,light=light,shine=shine,sparks=sparks}
end
function Rainbow:step(dt)
 self.clock+=dt;self.scan+=dt;if self.clock<.06 then return end;self.phase+=self.clock;self.clock=0
 if self.scan>.4 then
  self.scan=0;local localRoot=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
  for _,player in Players:GetPlayers() do
   local char=player.Character;local root=char and char:FindFirstChild('HumanoidRootPart')
   if root and localRoot and (root.Position-localRoot.Position).Magnitude<100 then
    local tool=char:FindFirstChildOfClass('Tool');if tool then self:watch(tool) end
   end
  end
 end
 local reduced=C.reducedMotion();local color=Color3.fromHSV(if reduced then .66 else (self.phase/7)%1,.6,1)
 for tool,r in self.records do
  if not tool:IsDescendantOf(workspace) or not r.root.Parent then r.root:Destroy();self.records[tool]=nil
  else r.light.Color=color;r.shine.FillColor=color;r.shine.OutlineColor=color;r.sparks.Color=ColorSequence.new(color,Color3.new(1,1,1));r.sparks.Enabled=not reduced end
 end
end
return Rainbow
