--!nonstrict
local Players=game:GetService('Players');local RunService=game:GetService('RunService');local Debris=game:GetService('Debris');local SoundService=game:GetService('SoundService')
local Package=game:GetService('ReplicatedStorage').SeaGame;local Config=require(Package.Shared.Config);local C=require(script.Parent.Components);local T=require(script.Parent.Theme)
local Effects={};Effects.__index=Effects
local function part(parent,name,size,color)
 return C.new('Part',{Name=name,Size=size,Color=color,Material=Enum.Material.SmoothPlastic,Anchored=true,CanCollide=false,CanQuery=false,CanTouch=false,CastShadow=false},parent)
end
function Effects.new(ui)
 local self=setmetatable({ui=ui,streams={},loot={},flights={},rings={},clock=0,lootClock=0},Effects)
 self.folder=C.new('Folder',{Name='LocalSeaEffects'},workspace)
 -- Preload two reusable voices: the first pickup is audible, and rapid pickups
 -- cannot accumulate dozens of sounds. The sparkle follows a soft rising fifth.
 self.pickupAudio=C.new('Folder',{Name='SeaPickupAudio'},SoundService)
 self.pickupNotes={};self.pickupFades={};self.pickupSequence=0
 for _,name in {'SoftNote','SparkleNote'} do
  local note=C.new('Sound',{Name=name,SoundId=Config.Audio.Collect,Volume=0},self.pickupAudio)
  C.new('EqualizerSoundEffect',{LowGain=-5,MidGain=0,HighGain=-8},note);table.insert(self.pickupNotes,note)
 end
 task.spawn(function() pcall(function() game:GetService('ContentProvider'):PreloadAsync(self.pickupNotes) end) end)
 self.folder.Destroying:Connect(function() self.pickupSequence+=1;self.pickupAudio:Destroy() end)
 self.worldPolish=require(script.Parent.WorldPolish).new()
 self.rainbowTools=require(script.Parent.RainbowTools).new()
 self.chestPresentation=require(script.Parent.ChestPresentation).new(self.folder,function(...) return self:sound(...) end)
 local horizon=workspace.Ocean:WaitForChild('DistantSea',20)
 if horizon then
  local function levelChanged() local level=workspace.Ocean:GetAttribute('WaterLevel') or 0;for _,p in horizon:GetChildren() do if p:IsA('BasePart') then p.Position=Vector3.new(p.Position.X,level-.08,p.Position.Z) end end end
  workspace.Ocean:GetAttributeChangedSignal('WaterLevel'):Connect(levelChanged);levelChanged()
 end
 local boatRig=workspace.Ocean:WaitForChild('BoatPresentation',20);local boat=boatRig and boatRig:FindFirstChild('LittleBoat')
 if boat and boat:IsA('BasePart') then
  local original=boat.CFrame;local lowest=boat.Position.Y-boat.Size.Y/2
  local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={workspace.UnderwaterTerrain.Seafloor};params.IgnoreWater=true;params.RespectCanCollide=true
  local hit=workspace:Raycast(Vector3.new(original.X,10,original.Z),Vector3.new(0,-190,0),params)
  local floorDelta=if hit then hit.Position.Y-lowest else Config.Ocean.minimum
  local function floatBoat() local level=workspace.Ocean:GetAttribute('WaterLevel') or 0;C.tween(boat,.45,{CFrame=original+Vector3.new(0,math.max(level,floorDelta),0)}) end
  workspace.Ocean:GetAttributeChangedSignal('WaterLevel'):Connect(floatBoat);floatBoat()
 end
 local folder=workspace:WaitForChild('LiveLoot')
 local function watch(model) if not model:IsA('Model') then return end;task.defer(function()
  if not model.Parent then return end
  local ground=model:GetAttribute('GroundPosition');if not ground then return end
  local visuals={};for _,p in model:GetDescendants() do if p:IsA('BasePart') and p.Name~='PickupRoot' then table.insert(visuals,{part=p,offset=p.CFrame-model:GetPivot().Position}) end end
  local rarity=model:GetAttribute('Rarity');local definition=Config.LootById[model:GetAttribute('LootId')]
  if definition and (rarity=='RARE' or rarity=='EPIC' or rarity=='LEGENDARY') and visuals[1] then
   C.new('Highlight',{Name='TreasureGleam',Adornee=model,FillColor=definition.color,OutlineColor=definition.color,FillTransparency=.9,OutlineTransparency=.55,DepthMode=Enum.HighlightDepthMode.Occluded},model)
   local a=C.new('Attachment',{Name='TreasureSparkles'},visuals[1].part)
   C.new('ParticleEmitter',{Name='GentleSparkles',Texture='rbxasset://textures/particles/sparkles_main.dds',Color=ColorSequence.new(definition.color),LightEmission=.85,Rate=4,Lifetime=NumberRange.new(.65,1.15),Speed=NumberRange.new(.25,.65),SpreadAngle=Vector2.new(180,180),Acceleration=Vector3.new(0,.3,0),Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.25,.16),NumberSequenceKeypoint.new(1,0)}),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.2),NumberSequenceKeypoint.new(1,1)})},a)
  end
  local elapsed=math.max(0,workspace:GetServerTimeNow()-(model:GetAttribute('BornAt') or workspace:GetServerTimeNow()))
  local burst=model:GetAttribute('BurstOrigin')
  if burst and elapsed<.58 then for _,v in visuals do v.part.LocalTransparencyModifier=1 end end
  self.loot[model]={ground=ground,base=model:GetPivot(),born=os.clock()-elapsed,visuals=visuals,burst=burst}
 end) end
 folder.ChildAdded:Connect(watch);folder.ChildRemoved:Connect(function(model) self.loot[model]=nil end);for _,m in folder:GetChildren() do watch(m) end
 self.connection=RunService.RenderStepped:Connect(function(dt) self:step(math.min(dt,.1)) end)
 return self
end
function Effects:sound(id,pitch,volume,parent,looped)
 local sound=C.new('Sound',{SoundId=id,Volume=volume or .18,PlaybackSpeed=pitch or 1,Looped=looped or false,RollOffMaxDistance=65},parent or SoundService);sound:Play();if not looped then Debris:AddItem(sound,3) end;return sound
end
function Effects:click() self:sound(Config.Audio.Click,1.35,.14) end
function Effects:pickupChime(rare)
 self.pickupSequence+=1;local sequence=self.pickupSequence
 for i,note in self.pickupNotes do
  if self.pickupFades[i] then self.pickupFades[i]:Cancel() end
  note:Stop()
  local function play()
   if self.pickupSequence~=sequence or not note.Parent then return end
   note.TimePosition=0;note.PlaybackSpeed=(if i==1 then 1.12 else 1.68)*(if rare then 1.08 else 1)
   note.Volume=if i==1 then .22 else .11;note:Play()
   self.pickupFades[i]=C.tween(note,if i==1 then .36 else .42,{Volume=0},Enum.EasingStyle.Sine,Enum.EasingDirection.In)
  end
  if i==1 then play() else task.delay(.065,play) end
 end
end
function Effects:burst(position,color,rare)
 if (self.burstCount or 0)>=8 then return end;self.burstCount=(self.burstCount or 0)+1
 local anchor=part(self.folder,'DiscoveryBurst',Vector3.one*.1,color);anchor.Transparency=1;anchor.Position=position
 local emitter=C.new('ParticleEmitter',{Texture='rbxasset://textures/particles/sparkles_main.dds',Color=ColorSequence.new(color,T.Gold),LightEmission=.65,Rate=0,Lifetime=NumberRange.new(.35,.8),Speed=NumberRange.new(2,if rare then 6 else 4),SpreadAngle=Vector2.new(150,150),Acceleration=Vector3.new(0,-4,0),Drag=3,Rotation=NumberRange.new(-180,180),RotSpeed=NumberRange.new(-100,100),Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.22,if rare then .24 else .15),NumberSequenceKeypoint.new(1,0)}),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.08),NumberSequenceKeypoint.new(.65,.25),NumberSequenceKeypoint.new(1,1)})},anchor)
 emitter:Emit(if C.reducedMotion() then 4 elseif rare then 22 else 12)
 Debris:AddItem(anchor,1.1);task.delay(1.1,function() self.burstCount-=1 end)
end
function Effects:upgrade(payload)
 for i,pitch in {1,1.25,1.5} do task.delay((i-1)*.1,function() self:sound(Config.Audio.Collect,pitch,.2) end) end
 self.ui:upgradeCelebration(payload and payload.category)
 local character=Players.LocalPlayer.Character;local root=character and character:FindFirstChild('HumanoidRootPart')
 if root then self:burst(root.Position,T.Gold,true) end
end
function Effects:stop(userId)
 local stream=self.streams[userId];if not stream then return end;self.streams[userId]=nil
 for _,ik in stream.iks do C.tween(ik,.22,{Weight=0});Debris:AddItem(ik,.25) end
 for _,target in stream.targets do Debris:AddItem(target,.3) end
 if stream.sound then C.tween(stream.sound,.25,{Volume=0});Debris:AddItem(stream.sound,.3) end
 if stream.tool and stream.tool.Parent then C.tween(stream.tool,.25,{Grip=stream.grip}) end
 for _,joint in stream.pose or {} do if joint.motor.Parent then C.tween(joint.motor,.25,{C0=joint.base}) end end
 C.tween(stream.beam,.2,{Width0=0,Width1=0});Debris:AddItem(stream.anchor,.23)
 if stream.core then C.tween(stream.core,.16,{Width0=0,Width1=0}) end
 for _,bubble in stream.bubbles do C.tween(bubble.part,.16,{Transparency=1,Size=Vector3.one*.03});Debris:AddItem(bubble.part,.2) end
 if userId==Players.LocalPlayer.UserId and stream.camera then C.tween(stream.camera,.35,{FieldOfView=stream.fov}) end
end
function Effects:start(payload)
 self:stop(payload.player)
 local player=Players:GetPlayerByUserId(payload.player);local character=player and player.Character
 if player~=Players.LocalPlayer then
  local root=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild('HumanoidRootPart');local count=0;for _ in self.streams do count+=1 end
  if not root or (root.Position-payload.point).Magnitude>110 or count>=5 then return end
 end
 local tool=character and character:FindFirstChildOfClass('Tool');local handle=tool and tool:FindFirstChild('Handle');local tip=handle and handle:FindFirstChild('SuctionTip');local human=character and character:FindFirstChildOfClass('Humanoid');local head=character and character:FindFirstChild('Head')
 if not tip or not human or not head then return end
 local anchor=part(self.folder,'WaterIntake',Vector3.one*.1,T.Teal);anchor.Transparency=1;anchor.CFrame=CFrame.new(payload.point)
 local from=C.new('Attachment',{CFrame=CFrame.Angles(0,0,math.pi/2)},anchor)
 tip.Orientation=Vector3.new(0,0,-90)
 local beam=C.new('Beam',{Name='SuctionStream',Attachment0=from,Attachment1=tip,Width0=0,Width1=0,Segments=16,FaceCamera=true,LightEmission=.35,Color=ColorSequence.new(T.Teal,T.Aqua),Transparency=NumberSequence.new(.24)},anchor)
 C.tween(beam,.3,{Width0=.25,Width1=.10})
 local core=beam:Clone();core.Name='StreamFoam';core.Color=ColorSequence.new(Color3.fromRGB(225,255,247));core.Transparency=NumberSequence.new(.35);core.Parent=anchor;C.tween(core,.32,{Width0=.075,Width1=.035})
 local stream={player=player,character=character,tool=tool,grip=tool.Grip,tip=tip,anchor=anchor,beam=beam,core=core,point=payload.point,targetPoint=payload.point,bubbles={},iks={},targets={},phase=0,ripple=0,special=payload.straw=='AdminStraw' or payload.straw=='PrismStraw'}
 stream.pose={}
 for _,name in {'Waist','Neck'} do local motor=character:FindFirstChild(name,true);if motor and motor:IsA('Motor6D') then table.insert(stream.pose,{motor=motor,base=motor.C0,tilt=if name=='Waist' then -.07 else .045}) end end
 for _,side in {'Right','Left'} do
  local upper=character:FindFirstChild(side..'UpperArm');local hand=character:FindFirstChild(side..'Hand')
  if upper and hand then
   local target=C.new('Attachment',{Name='SipPoseTarget',CFrame=CFrame.new(if side=='Right' then .66 else -.18,-1.1,if side=='Right' then -.8 else -1.08)*CFrame.Angles(0,0,if side=='Right' then math.rad(9) else math.rad(-18))},head)
   local ik=C.new('IKControl',{Name='Sip'..side,Type=Enum.IKControlType.Transform,ChainRoot=upper,EndEffector=hand,Target=target,Weight=0,SmoothTime=.16,Priority=2},human)
   table.insert(stream.iks,ik);table.insert(stream.targets,target);C.tween(ik,.32,{Weight=if side=='Right' then 1 else .8})
  end
 end
 local count=if player==Players.LocalPlayer then 22 else 10
 for i=1,count do local b=part(self.folder,'WaterBubble',Vector3.one*.13,if i%4==0 then T.White else T.Aqua);b.Shape=Enum.PartType.Ball;b.Transparency=.22;table.insert(stream.bubbles,{part=b,t=(i-1)/count,phase=i*2.4}) end
 stream.sound=self:sound(Config.Audio.Water,1.25,.08,anchor,true)
 if player==Players.LocalPlayer and not C.reducedMotion() then stream.camera=workspace.CurrentCamera;stream.fov=stream.camera.FieldOfView;C.tween(stream.camera,.5,{FieldOfView=stream.fov+2}) end
 self.streams[payload.player]=stream
end
function Effects:aim(payload) local s=self.streams[payload.player];if s then s.targetPoint=payload.point elseif payload.player~=Players.LocalPlayer.UserId then self:start(payload) end end
function Effects:ripple(position)
 if #self.rings>=12 then return end
 local root=part(self.folder,'SipRipple',Vector3.one*.1,T.Aqua);root.Transparency=1;root.CFrame=CFrame.new(position+Vector3.new(0,.065,0))
 local attachments={};local beams={}
 for i=0,3 do
  local a=i*math.pi/2;local tangent=Vector3.new(-math.sin(a),0,math.cos(a));local cf=CFrame.fromMatrix(Vector3.new(math.cos(a),0,math.sin(a)),tangent,Vector3.yAxis)
  attachments[i+1]=C.new('Attachment',{CFrame=cf},root)
 end
 for i=1,4 do beams[i]=C.new('Beam',{Attachment0=attachments[i],Attachment1=attachments[i%4+1],Width0=.055,Width1=.055,CurveSize0=.5523,CurveSize1=.5523,Segments=8,FaceCamera=true,Color=ColorSequence.new(T.Aqua),Transparency=NumberSequence.new(.1)},root) end
 table.insert(self.rings,{root=root,attachments=attachments,beams=beams,age=0})
end
function Effects:pickup(payload)
 local item=Config.LootById[payload.loot];local player=Players:GetPlayerByUserId(payload.player);local root=player and player.Character and player.Character:FindFirstChild('HumanoidRootPart')
 if not item then return end
 -- Confirmed inventory feedback must not depend on a mesh or the flight budget.
 if player==Players.LocalPlayer then
  self:pickupChime(item.rarity=='LEGENDARY' or item.rarity=='EPIC' or item.rarity=='RARE');self.ui:pickupNotice(item)
 end
 if not root then return end
 local prefab=Package.Assets.Loot:FindFirstChild(payload.loot);if not prefab then return end
 if #self.flights>=12 then return end
 local model=prefab:Clone();model.Name='CollectedTreasure';model.Parent=self.folder;model:PivotTo(CFrame.new(payload.position))
 self:burst(payload.position+Vector3.new(0,.3,0),item.color,item.rarity=='RARE' or item.rarity=='EPIC' or item.rarity=='LEGENDARY')
 local visual=model:FindFirstChildWhichIsA('BasePart',true)
 if visual then
  local a=C.new('Attachment',{Position=Vector3.new(-.1,0,0)},visual);local b=C.new('Attachment',{Position=Vector3.new(.1,0,0)},visual)
  C.new('Trail',{Attachment0=a,Attachment1=b,Lifetime=.2,MinLength=.04,FaceCamera=true,LightEmission=.6,Color=ColorSequence.new(item.color,T.PaleGold),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.25),NumberSequenceKeypoint.new(1,1)}),WidthScale=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})},visual)
 end
 table.insert(self.flights,{model=model,origin=payload.position,target=root,age=0,duration=if C.reducedMotion() then .22 else .85,scale=model:GetScale(),item=item,localPlayer=player==Players.LocalPlayer})
end
function Effects:chestOpened(payload)
 -- Replicated OpenedAt drives one synchronized presentation, including late joiners.
 -- Keep this event handler for compatibility with the established FX dispatcher.
end
function Effects:step(dt)
 self.clock+=dt;local now=os.clock()
 for userId,s in self.streams do
  if not s.tip.Parent or not s.character.Parent then self:stop(userId);continue end
  s.phase+=dt;s.point=s.point:Lerp(s.targetPoint,1-math.exp(-dt*14));s.anchor.Position=s.point
  local finish=s.tip.WorldPosition;local origin=s.point;local distance=(finish-origin).Magnitude
  s.beam.CurveSize0=math.min(distance*.28,5);s.beam.CurveSize1=math.min(distance*.15,2)
  s.core.CurveSize0=s.beam.CurveSize0;s.core.CurveSize1=s.beam.CurveSize1
  s.tool.Grip=s.grip*CFrame.Angles(math.sin(s.phase*3.8)*.018,0,math.sin(s.phase*4.5)*.014)
  if not C.reducedMotion() then for _,joint in s.pose do if joint.motor.Parent then joint.motor.C0=joint.base*CFrame.Angles(joint.tilt*math.min(s.phase/.35,1)+math.sin(s.phase*3.2)*.009,0,0) end end end
  for _,bubble in s.bubbles do
   bubble.t=(bubble.t+dt*.72)%1;local t=bubble.t;local travel=math.clamp((t-.18)/.82,0,1);local bend=(origin+finish)*.5+Vector3.new(0,math.min(distance*.3,4),0)
   local pos=(1-travel)^2*origin+2*(1-travel)*travel*bend+travel*travel*finish
   local radius=if t<.18 then (1-t/.18)*1.15+.26 else .26*(1-travel)
   local swirl=Vector3.new(math.cos(bubble.phase+t*19+s.phase*2),0,math.sin(bubble.phase+t*19+s.phase*2))*radius
   bubble.part.Position=pos+swirl;local size=(.10+math.sin(math.pi*t)*.09)*(1-t*.45);bubble.part.Size=Vector3.one*size;bubble.part.Transparency=.15+math.abs(t-.5)*.45
  end
  s.ripple+=dt;if s.ripple>.48 then s.ripple=0;self:ripple(origin) end
 end
 for i=#self.rings,1,-1 do
  local r=self.rings[i];r.age+=dt;local t=r.age/.9
  if t>=1 then r.root:Destroy();table.remove(self.rings,i) else
   local radius=.25+(1-t)*1.4
   for index,a in r.attachments do local angle=(index-1)*math.pi/2;a.Position=Vector3.new(math.cos(angle),0,math.sin(angle))*radius end
   for _,beam in r.beams do beam.CurveSize0=.5523*radius;beam.CurveSize1=.5523*radius;beam.Transparency=NumberSequence.new(.15+t*.85) end
  end
 end
 self.lootClock+=dt
 if self.lootClock>=1/30 then
  self.lootClock=0;local char=Players.LocalPlayer.Character;local root=char and char:FindFirstChild('HumanoidRootPart')
  for model,data in self.loot do
   if not model.Parent then self.loot[model]=nil;continue end
   if data.settled or (root and (data.ground-root.Position).Magnitude>125) then continue end
   local age=now-data.born;local rotation=0;local position=data.base.Position;local duration=if data.burst then 1.65 else .55
   if data.burst and age<duration then
    local t=math.clamp((age-.58)/1.07,0,1);local ease=t*t*(3-2*t)
    position=data.burst:Lerp(position,ease)+Vector3.new(0,math.sin(t*math.pi)*3.3,0);rotation=(1-ease)*math.pi*1.5
   elseif age<duration then position+=data.base.UpVector*math.sin(math.clamp(age/duration,0,1)*math.pi)*.32 end
   local cf=CFrame.new(position)*data.base.Rotation
   -- Only the artwork moves: the authoritative pickup position and prompt stay on the ground.
   for _,v in data.visuals do if v.part.Parent then v.part.LocalTransparencyModifier=if data.burst and age<.58 then 1 else 0;v.part.CFrame=CFrame.new(cf.Position)*CFrame.Angles(0,rotation,0)*v.offset end end
   if age>=duration then data.settled=true end
  end
 end
 for i=#self.flights,1,-1 do
  local flight=self.flights[i];flight.age+=dt;local t=math.clamp(flight.age/flight.duration,0,1)
  if t>=1 or not flight.target.Parent then
   if t>=1 and flight.localPlayer then self.ui:pickupArrival(flight.item) end
   flight.model:Destroy();table.remove(self.flights,i)
  else
   local finish=flight.target.Position+Vector3.new(0,.7,0);local bend=(flight.origin+finish)*.5+Vector3.new(0,3.5,0)
   local ease=t*t;local pos=(1-ease)^2*flight.origin+2*(1-ease)*ease*bend+ease*ease*finish
   local reduced=C.reducedMotion()
   flight.model:PivotTo(CFrame.new(pos)*CFrame.Angles(0,if reduced then 0 else t*math.pi*2,if reduced then 0 else math.sin(t*math.pi)*.2));flight.model:ScaleTo(flight.scale*((1+(if reduced then 0 else math.sin(math.min(t/.23,1)*math.pi)*.18))*(1-ease*.84)))
  end
 end
end
return Effects
