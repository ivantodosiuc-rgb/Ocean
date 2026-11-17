--!nonstrict
local RunService=game:GetService('RunService')
local Players=game:GetService('Players')
local TweenService=game:GetService('TweenService')
local Debris=game:GetService('Debris')
local Config=require(game:GetService('ReplicatedStorage').SeaGame.Shared.Config)
local C=require(script.Parent.Components)
local ChestPresentation={};ChestPresentation.__index=ChestPresentation
local DURATION=1.65
function ChestPresentation.new(folder,sound)
 local self=setmetatable({folder=folder,sound=sound,records={},connections={}},ChestPresentation)
 local points=workspace.UnderwaterTerrain:FindFirstChild('PointsOfInterest')
 if points then for _,model in points:GetDescendants() do if model:IsA('Model') and model:GetAttribute('ExpeditionChest') then
  local lid=model:FindFirstChild('Lid');local base=model:FindFirstChild('Base');local root=model:FindFirstChild('ChestRoot')
  if not lid or not base or not root then continue end
  local record={model=model,lid=lid,base=base,root=root,hinge=model:GetAttribute('LidHinge'),closed=model:GetAttribute('LidClosedCFrame') or lid.CFrame,baseCF=base.CFrame,rare=(model:GetAttribute('MinimumValue') or 0)>=1000}
  self.records[model.Name]=record
  local function start()
   local at=model:GetAttribute('OpenedAt');if type(at)~='number' or at<=0 or record.at==at then return end
   record.at=at;record.active=true;record.burst=false
  end
  table.insert(self.connections,model:GetAttributeChangedSignal('OpenedAt'):Connect(start));start()
 end end end
 table.insert(self.connections,RunService.RenderStepped:Connect(function() self:step() end))
 return self
end
function ChestPresentation:burst(record)
 local pos=record.root.Position+Vector3.new(0,1.2,0)
 local pivot=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
 if not pivot or (pivot.Position-pos).Magnitude>140 then return end
 local color=if record.rare then Color3.fromRGB(116,235,223) else Color3.fromRGB(255,204,103)
 local anchor=C.new('Part',{Name='ChestRewardLight',Size=Vector3.one*.1,Position=pos,Transparency=1,Anchored=true,CanCollide=false,CanQuery=false,CanTouch=false,CastShadow=false},self.folder)
 local light=C.new('PointLight',{Color=color,Brightness=0,Range=if record.rare then 12 else 8,Shadows=false},anchor)
 C.tween(light,.16,{Brightness=if record.rare then 2.2 else 1.4})
 task.delay(.28,function() if light.Parent then C.tween(light,1,{Brightness=0}) end end)
 local spark=C.new('ParticleEmitter',{Name='RewardStarburst',Texture='rbxasset://textures/particles/sparkles_main.dds',Color=ColorSequence.new(color,Color3.fromRGB(255,244,218)),Rate=0,Lifetime=NumberRange.new(.75,1.4),Speed=NumberRange.new(2.5,5.5),SpreadAngle=Vector2.new(75,75),Acceleration=Vector3.new(0,-3,0),Drag=2,LightEmission=.8,Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.15,.23),NumberSequenceKeypoint.new(.6,.13),NumberSequenceKeypoint.new(1,0)}),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.05),NumberSequenceKeypoint.new(.5,.2),NumberSequenceKeypoint.new(1,1)})},anchor)
 spark:Emit(if record.rare then 30 else 18)
 for i=1,(if record.rare then 5 else 3) do
  local a=i*math.tau/5
  local bottom=C.new('Attachment',{Position=Vector3.new(math.cos(a)*.35,0,math.sin(a)*.35)},anchor)
  local top=C.new('Attachment',{Position=Vector3.new(math.cos(a)*1.6,4.2+math.sin(i)*.5,math.sin(a)*1.6)},anchor)
  local beam=C.new('Beam',{Name='RewardRay',Attachment0=bottom,Attachment1=top,FaceCamera=true,Width0=.42,Width1=.04,Segments=6,LightEmission=.8,Color=ColorSequence.new(color),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.65),NumberSequenceKeypoint.new(1,1)})},anchor)
  C.tween(beam,1.05,{Width0=0,Width1=0})
 end
 for i,pitch in {1.05,1.32,1.65,2.05} do task.delay((i-1)*.105,function() if anchor.Parent then self.sound(Config.Audio.Collect,pitch,if record.rare then .2 else .15,anchor) end end) end
 Debris:AddItem(anchor,2.3)
end
function ChestPresentation:step()
 local now=workspace:GetServerTimeNow()
 for _,record in self.records do if record.active then
  local age=math.max(0,now-record.at);local angle=0
  if age<.2 then
   local pulse=math.sin(age/.2*math.pi);local shake=math.sin(age*85)*pulse
   record.base.CFrame=record.baseCF*CFrame.new(shake*.045,0,0)*CFrame.Angles(0,0,shake*.012)
   angle=math.rad(-3)*pulse
  else
   record.base.CFrame=record.baseCF
   local t=math.clamp((age-.2)/1.1,0,1)
   -- One continuous damped spring, with an exact resting pose.
   local spring=if t>=1 then 1 else 1-math.exp(-7*t)*(math.cos(8.8*t)+.79545*math.sin(8.8*t))
   angle=math.rad(-106)*spring
  end
  record.lid.CFrame=record.hinge*CFrame.Angles(angle,0,0)*record.hinge:Inverse()*record.closed
  if age>=.52 and not record.burst then record.burst=true;if age<1.2 then self:burst(record) end end
  if age>=DURATION then record.base.CFrame=record.baseCF;record.active=false end
 end end
end
function ChestPresentation:destroy()
 for _,connection in self.connections do connection:Disconnect() end
 for _,record in self.records do if record.base.Parent then record.base.CFrame=record.baseCF end end
end
return ChestPresentation
