--!nonstrict
local Players=game:GetService('Players');local TweenService=game:GetService('TweenService');local GuiService=game:GetService('GuiService')
local Config=require(game.ReplicatedStorage.SeaGame.Shared.Config)
local RestroomEffects={};RestroomEffects.__index=RestroomEffects
function RestroomEffects.new(controller)
 local self=setmetatable({controller=controller,generation=0},RestroomEffects)
 self.booth=workspace.Buildings:WaitForChild('BeachRestroom')
 self.door=self.booth:WaitForChild('Door');self.closed=self.door.CFrame;self.open=self.booth.DoorHinge.CFrame*CFrame.Angles(0,math.rad(-92),0)*self.booth.DoorHinge.CFrame:ToObjectSpace(self.closed)
 local function doorChanged()
  if self.doorTween then self.doorTween:Cancel() end
  self.doorTween=TweenService:Create(self.door,TweenInfo.new(.55,Enum.EasingStyle.Cubic),{CFrame=if self.booth:GetAttribute('Occupied') then self.closed else self.open});self.doorTween:Play()
 end
 self.booth:GetAttributeChangedSignal('Occupied'):Connect(doorChanged);doorChanged()
 local function character(character)
  self:finish(false)
  local human=character:WaitForChild('Humanoid',10);if human then human.Died:Connect(function() self:finish(false) end) end
 end
 Players.LocalPlayer.CharacterAdded:Connect(character)
 if Players.LocalPlayer.Character then task.spawn(character,Players.LocalPlayer.Character) end
 return self
end
function RestroomEffects:start(payload)
 self:finish(false);self.generation+=1;local token=self.generation
 self.controller:stop();self.controller.ui:close()
 local camera=workspace.CurrentCamera
 self.saved={camera=camera,kind=camera.CameraType,subject=camera.CameraSubject,fov=camera.FieldOfView,frame=camera.CFrame,token=token}
 camera:SetAttribute('SeaRestroomCamera',token);camera.CameraType=Enum.CameraType.Scriptable
 local reduced=false;pcall(function() reduced=GuiService.ReducedMotionEnabled end)
 self.cameraTween=TweenService:Create(camera,TweenInfo.new(if reduced then .05 else .85,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{CFrame=payload.camera,FieldOfView=math.min(85,camera.FieldOfView+6)});self.cameraTween:Play()
 local sound=Instance.new('Sound');sound.Name='RestroomWater';sound.SoundId=Config.Restroom.Sound;sound.Volume=.42;sound.RollOffMinDistance=6;sound.RollOffMaxDistance=25;sound.Parent=self.booth.Inside;self.sound=sound
 task.delay(.65,function() if self.generation==token and sound.Parent then sound:Play() end end)
 self.controller.ui:toastMessage('A little shore break...','info')
 task.delay(payload.duration+3,function() if self.generation==token then self:finish(false) end end)
end
function RestroomEffects:finish(completed)
 self.generation+=1
 if self.cameraTween then self.cameraTween:Cancel();self.cameraTween=nil end
 if self.sound then self.sound:Destroy();self.sound=nil end
 local saved=self.saved;self.saved=nil
 if saved and saved.camera.Parent and saved.camera:GetAttribute('SeaRestroomCamera')==saved.token then
  local human=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
  local function restore()
   if saved.camera:GetAttribute('SeaRestroomCamera')~=saved.token then return end
   saved.camera:SetAttribute('SeaRestroomCamera',nil);saved.camera.CameraType=saved.kind;saved.camera.FieldOfView=saved.fov
   saved.camera.CameraSubject=if saved.subject and saved.subject.Parent then saved.subject else human
   if saved.kind==Enum.CameraType.Scriptable then saved.camera.CFrame=saved.frame end
  end
  local root=human and human.Parent:FindFirstChild('HumanoidRootPart');local reduced=false;pcall(function() reduced=GuiService.ReducedMotionEnabled end)
  if completed and root and human.Health>0 and not reduced then
   local focus=root.Position+Vector3.new(0,1,0)
   local target=CFrame.lookAt(focus-saved.frame.LookVector*12+Vector3.new(0,2,0),focus)
   self.cameraTween=TweenService:Create(saved.camera,TweenInfo.new(.65,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{CFrame=target,FieldOfView=saved.fov});self.cameraTween:Play();task.delay(.66,restore)
  else restore() end
 end
 if completed then self.controller.ui:toastMessage('All fresh! Back to the sea.','success') end
end
return RestroomEffects
