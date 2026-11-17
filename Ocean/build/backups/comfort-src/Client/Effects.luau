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
 self.worldPolish=require(script.Parent.WorldPolish).new()
 self.chestPresentation=require(script.Parent.ChestPresentation).new(self.folder,function(...) return self:sound(...) end)
 local horizon=workspace.Ocean:FindFirstChild('DistantSea')
 if horizon then
  local function levelChanged() local level=workspace.Ocean:GetAttribute('WaterLevel') or 0;for _,p in horizon:GetChildren() do if p:IsA('BasePart') then p.Position=Vector3.new(p.Position.X,level-.08,p.Position.Z) end end end
  workspace.Ocean:GetAttributeChangedSignal('WaterLevel'):Connect(levelChanged);levelChanged()
 end
 local boat=workspace.Ocean:FindFirstChild('LittleBoat')
 if boat and boat:IsA('BasePart') then
  local original=boat.CFrame;local lowest=boat.Position.Y-boat.Size.Y/2
  local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={workspace.UnderwaterTerrain.Seafloor};params.IgnoreWater=true;params.RespectCanCollide=true
  local hit=workspace:Raycast(Vector3.new(original.X,10,original.Z),Vector3.new(0,-110,0),params)
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
  if definition and (rarity=='RARE' or rarity=='LEGENDARY') and visuals[1] then
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
function Effects:upgrade()
 for i,pitch in {1,1.25,1.5} do task.delay((i-1)*.1,function() self:sound(Config.Audio.Collect,pitch,.2) end) end
 self.ui:toastMessage('A little stronger. A little further!','success')
end
function Effects:stop(userId)
 local stream=self.streams[userId];if not stream then return end;self.streams[userId]=nil
 for _,ik in stream.iks do C.tween(ik,.22,{Weight=0});Debris:AddItem(ik,.25) end
 for _,target in stream.targets do Debris:AddItem(target,.3) end
 if stream.sound then C.tween(stream.sound,.25,{Volume=0});Debris:AddItem(stream.sound,.3) end
 if stream.tool and stream.tool.Parent then C.tween(stream.tool,.25,{Grip=stream.grip}) end
 C.tween(stream.beam,.2,{Width0=0,Width1=0});Debris:AddItem(stream.anchor,.23)
 for _,bubble in stream.bubbles do C.tween(bubble.part,.16,{Transparency=1,Size=Vector3.one*.03});Debris:AddItem(bubble.part,.2) end
 if userId==Players.LocalPlayer.UserId and stream.camera then C.tween(stream.camera,.35,{FieldOfView=stream.fov}) end
end
function Effects:start(payload)
 self:stop(payload.player)
 local player=Players:GetPlayerByUserId(payload.player);local character=player and player.Character
 if player~=Players.LocalPlayer then
  local root=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild('HumanoidRootPart');local count=0;for _ in self.streams do count+=1 end
  if not root or (root.Position-payload.point).Magnitude>150 or count>=8 then return end
 end
 local tool=character and character:FindFirstChildOfClass('Tool');local handle=tool and tool:FindFirstChild('Handle');local tip=handle and handle:FindFirstChild('SuctionTip');local human=character and character:FindFirstChildOfClass('Humanoid');local head=character and character:FindFirstChild('Head')
 if not tip or not human or not head then return end
 local anchor=part(self.folder,'WaterIntake',Vector3.one*.1,T.Teal);anchor.Transparency=1;anchor.CFrame=CFrame.new(payload.point)
 local from=C.new('Attachment',{CFrame=CFrame.Angles(0,0,math.pi/2)},anchor)
 tip.Orientation=Vector3.new(0,0,-90)
 local beam=C.new('Beam',{Name='SuctionStream',Attachment0=from,Attachment1=tip,Width0=0,Width1=0,Segments=16,FaceCamera=true,LightEmission=.3,Color=ColorSequence.new(T.Aqua,T.Teal),Transparency=NumberSequence.new(.18)},anchor)
 C.tween(beam,.25,{Width0=.16,Width1=.09})
 local stream={player=player,character=character,tool=tool,grip=tool.Grip,tip=tip,anchor=anchor,beam=beam,point=payload.point,targetPoint=payload.point,bubbles={},iks={},targets={},phase=0,ripple=0}
 for _,side in {'Right','Left'} do
  local upper=character:FindFirstChild(side..'UpperArm');local hand=character:FindFirstChild(side..'Hand')
  if upper and hand then
   local target=C.new('Attachment',{Name='SipPoseTarget',CFrame=CFrame.new(if side=='Right' then .66 else -.18,-1.1,if side=='Right' then -.8 else -1.08)*CFrame.Angles(0,0,if side=='Right' then math.rad(9) else math.rad(-18))},head)
   local ik=C.new('IKControl',{Name='Sip'..side,Type=Enum.IKControlType.Transform,ChainRoot=upper,EndEffector=hand,Target=target,Weight=0,SmoothTime=.16,Priority=2},human)
   table.insert(stream.iks,ik);table.insert(stream.targets,target);C.tween(ik,.32,{Weight=if side=='Right' then 1 else .8})
  end
 end
 for i=1,16 do local b=part(self.folder,'WaterBubble',Vector3.one*.13,T.Aqua);b.Shape=Enum.PartType.Ball;b.Transparency=.25;table.insert(stream.bubbles,{part=b,t=(i-1)/16,phase=i*2.4}) end
 stream.sound=self:sound(Config.Audio.Water,1.25,.08,anchor,true)
 if player==Players.LocalPlayer then stream.camera=workspace.CurrentCamera;stream.fov=stream.camera.FieldOfView;C.tween(stream.camera,.4,{FieldOfView=stream.fov+2}) end
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
 if not item or not root then return end
 local prefab=Package.Assets.Loot:FindFirstChild(payload.loot);if not prefab then return end
 local model=prefab:Clone();model.Name='CollectedTreasure';model.Parent=self.folder;model:PivotTo(CFrame.new(payload.position))
 table.insert(self.flights,{model=model,origin=payload.position,target=root,age=0,duration=.68,scale=model:GetScale()})
 if player==Players.LocalPlayer then
  self:sound(Config.Audio.Collect,1.3+math.random()*.3,.22);self.ui:toastMessage('+1 '..item.name,if item.rarity=='LEGENDARY' or item.rarity=='RARE' then 'success' else 'info')
  if item.rarity=='LEGENDARY' or item.rarity=='RARE' then for i,pitch in {1.6,2} do task.delay(i*.09,function() self:sound(Config.Audio.Collect,pitch,.18) end) end end
 end
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
  s.tool.Grip=s.grip*CFrame.Angles(math.sin(s.phase*3.8)*.018,0,math.sin(s.phase*4.5)*.014)
  for _,bubble in s.bubbles do
   bubble.t=(bubble.t+dt*.75)%1;local t=bubble.t;local bend=(origin+finish)*.5+Vector3.new(0,math.min(distance*.3,4),0)
   local pos=(1-t)^2*origin+2*(1-t)*t*bend+t*t*finish
   local swirl=Vector3.new(math.cos(bubble.phase+t*13),0,math.sin(bubble.phase+t*13))*.4*(1-t)
   bubble.part.Position=pos+swirl;local size=(.10+math.sin(math.pi*t)*.09)*(1-t*.45);bubble.part.Size=Vector3.one*size;bubble.part.Transparency=.15+math.abs(t-.5)*.45
  end
  s.ripple+=dt;if s.ripple>.48 then s.ripple=0;self:ripple(origin) end
 end
 for i=#self.rings,1,-1 do
  local r=self.rings[i];r.age+=dt;local t=r.age/.9
  if t>=1 then r.root:Destroy();table.remove(self.rings,i) else
   local radius=.25+t*1.4
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
  if t>=1 or not flight.target.Parent then flight.model:Destroy();table.remove(self.flights,i) else
   local finish=flight.target.Position+Vector3.new(0,.7,0);local bend=(flight.origin+finish)*.5+Vector3.new(0,3.5,0)
   local pos=(1-t)^2*flight.origin+2*(1-t)*t*bend+t*t*finish
   flight.model:PivotTo(CFrame.new(pos)*CFrame.Angles(0,t*math.pi*2,math.sin(t*math.pi)*.2));flight.model:ScaleTo(flight.scale*(1-t*.82))
  end
 end
end
return Effects
