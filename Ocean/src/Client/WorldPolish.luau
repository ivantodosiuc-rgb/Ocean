--!nonstrict
-- Cosmetic only: follows the confirmed server WaterLevel, never writes ocean progress.
local RunService=game:GetService('RunService')
local TweenService=game:GetService('TweenService')
local Players=game:GetService('Players')
local CollectionService=game:GetService('CollectionService')
local Contours=require(script.Parent.ShoreContours)
local WorldPolish={};WorldPolish.__index=WorldPolish
local function smooth(t) t=math.clamp(t,0,1);return t*t*(3-2*t) end
function WorldPolish.new()
 local self=setmetatable({connections={},wetProps={},lastLevel=math.huge,pending=nil,busy=false,disposed=false},WorldPolish)
 self.ocean=workspace:WaitForChild('Ocean');local rig=self.ocean:WaitForChild('WetShoreRig',20);self.ribbon=rig and rig:FindFirstChild('WetShore',true)
 self.params=RaycastParams.new();self.params.FilterType=Enum.RaycastFilterType.Include
 self.params.FilterDescendantsInstances={workspace.StarterIsland:WaitForChild('GoldenShore'),workspace.UnderwaterTerrain:WaitForChild('Seafloor')}
 self.params.IgnoreWater=true;self.params.RespectCanCollide=true
 self.bones={}
 if self.ribbon then
  for _,bone in self.ribbon:GetDescendants() do if bone:IsA('Bone') and bone.Name~='Root' then
   local edge,index=bone.Name:match('^(%a+)_(%d+)$')
   if edge then
    local p=bone.WorldPosition;table.insert(self.bones,{bone=bone,edge=edge,index=tonumber(index),angle=math.atan2(p.Z,p.X),rest=bone.WorldCFrame})
   end
  end end
  table.sort(self.bones,function(a,b) if a.index==b.index then return a.edge<b.edge end;return a.index<b.index end)
 end
 local function register(p)
  if not p:IsA('MeshPart') or self.wetProps[p] then return end
  local appearance=p:FindFirstChildOfClass('SurfaceAppearance')
  self.wetProps[p]={part=p,appearance=appearance,color=if appearance then appearance.Color else p.Color,y=p:GetAttribute('ShoreBaseY')or p.Position.Y,reflectance=p.Reflectance,wet=0,wasSubmerged=nil,dryAt=nil}
 end
 for _,p in CollectionService:GetTagged('SeaWettable') do register(p) end
 table.insert(self.connections,CollectionService:GetInstanceAddedSignal('SeaWettable'):Connect(register))
 table.insert(self.connections,CollectionService:GetInstanceRemovedSignal('SeaWettable'):Connect(function(p) self.wetProps[p]=nil end))
 local clock=0
 table.insert(self.connections,RunService.Heartbeat:Connect(function(dt) clock+=dt;if clock<1 then return end;clock=0;self:updateWetness() end))
 local function changed()
  local level=self.ocean:GetAttribute('WaterLevel') or 0
  if math.abs(level-self.lastLevel)<.025 then return end
  self.pending=level
  if not self.busy then task.spawn(function() self:drainQueue() end) end
 end
 table.insert(self.connections,self.ocean:GetAttributeChangedSignal('WaterLevel'):Connect(changed));changed()
 return self
end
function WorldPolish:height(radius,angle)
 local x,z=math.cos(angle)*radius,math.sin(angle)*radius
 local hit=workspace:Raycast(Vector3.new(x,12,z),Vector3.new(0,-190,0),self.params)
 return if hit then hit.Position.Y else -172
end
function WorldPolish:contour(entry,level)
 -- Collision decomposition can sit above the visible seabed. These radii were
 -- baked against Blender's rendered triangles, so wet sand follows the art.
 local sample=math.clamp(-level/Contours.step,0,Contours.levels-1)
 local row=math.floor(sample)+1;local nextRow=math.min(row+1,Contours.levels)
 local column=entry.index*2+(if entry.edge=='Inner' then 1 else 2)
 local a=Contours.radius(row,column);local b=Contours.radius(nextRow,column)
 local radius=a+(b-a)*(sample-math.floor(sample))
 local height=level+(if entry.edge=='Inner' then 1.1 else .10)+.075
 return Vector3.new(math.cos(entry.angle)*radius,height,math.sin(entry.angle)*radius)
end
function WorldPolish:drainQueue()
 if self.busy then return end;self.busy=true
 while self.pending and not self.disposed do
  local level=self.pending;self.pending=nil;local immediate=self.lastLevel==math.huge
  local started=os.clock()
  for i,entry in self.bones do
   if self.disposed then break end
   local target=self:contour(entry,level)
   local transform=CFrame.new(entry.rest:VectorToObjectSpace(target-entry.rest.Position))
   if immediate then entry.bone.Transform=transform else TweenService:Create(entry.bone,TweenInfo.new(.65,Enum.EasingStyle.Sine),{Transform=transform}):Play() end
   if i%16==0 then RunService.Heartbeat:Wait() end
  end
  self.lastLevel=level
  if self.ribbon then self.ribbon:SetAttribute('VisualWaterLevel',level);self.ribbon:SetAttribute('ContourUpdateSeconds',os.clock()-started);self.ribbon:SetAttribute('ShoreBoneCount',#self.bones) end
 end
 self.busy=false
end
function WorldPolish:updateWetness()
 local root=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild('HumanoidRootPart');local level=self.ocean:GetAttribute('WaterLevel')or 0;local now=os.clock();local inspected=0
 for part,entry in self.wetProps do
  if not part.Parent then self.wetProps[part]=nil;continue end
  local submerged=level>=entry.y
  if entry.wasSubmerged==true and not submerged then entry.dryAt=now+28 end
  entry.wasSubmerged=submerged
  if not root or (part.Position-root.Position).Magnitude>220 then continue end
  local wet=if submerged then 1 elseif entry.dryAt then smooth((entry.dryAt-now)/28) else 1-smooth((entry.y-level)/1.7)
  if math.abs(entry.wet-wet)>.02 then
   entry.wet=wet;local c=entry.color;local target=entry.appearance or part
   TweenService:Create(target,TweenInfo.new(.85),{Color=c:Lerp(Color3.new(c.R*.78,c.G*.86,c.B*.88),wet*.65)}):Play()
   part.Reflectance=entry.reflectance+wet*.035
  end
  inspected+=1
 end
 self.ocean:SetAttribute('LocalWetProps',inspected)
end
function WorldPolish:destroy()
 self.disposed=true;for _,c in self.connections do c:Disconnect() end
end
return WorldPolish
