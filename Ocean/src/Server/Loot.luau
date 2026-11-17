--!strict
local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local ReplicatedStorage=game:GetService('ReplicatedStorage')
local Shared=ReplicatedStorage.SeaGame.Shared
local Config=require(Shared.Config);local Economy=require(Shared.Economy)
local GroundSites=require(script.Parent.GroundSites)
local DepthZones=require(Shared.DepthZones)
local Loot={};Loot.__index=Loot
function Loot.new(ocean,profiles,onChanged,onFX,onNotice)
 local folder=Instance.new('Folder');folder.Name='LiveLoot';folder.Parent=workspace
 local self=setmetatable({ocean=ocean,profiles=profiles,onChanged=onChanged,onFX=onFX,onNotice=onNotice,folder=folder,nodes={},pending={},active={},count=0,rng=Random.new(),clock=0,ready=false,nextNode=1,serial=0,searchIndex=1},Loot)
 task.spawn(function() self:measureShore() end)
 self.starterNodes={};self.starterClock=0
 local sites=workspace.StarterIsland:FindFirstChild('StarterMusselSites')
 if sites then for _,site in sites:GetChildren() do table.insert(self.starterNodes,{position=site.Position,normal=site:GetAttribute('SurfaceNormal') or Vector3.yAxis,used=false,respawnAt=0,starter=true}) end end
 return self
end
function Loot:measureShore()
 -- These positions come from the rendered ground mesh. Convex collision hulls
 -- can sit several studs above it, so they must not be used to seat artwork.
 local radius=math.min(Config.Ocean.lootRadius,GroundSites.radius)
 for i=1,GroundSites.count do
  local position,normal=GroundSites.get(i)
  if position.X*position.X+position.Z*position.Z<=radius*radius and position.Y>Config.Ocean.minimum+.5 then
   table.insert(self.nodes,{id=tostring(i),position=position,normal=normal,used=false})
  end
  if i%300==0 then RunService.Heartbeat:Wait() end
 end
 self.ready=true
 print('[SeaGame] Loaded visible-ground loot sites',#self.nodes)
end
function Loot:spawnNode(node)
 if node.used or self.count>=Config.Ocean.maxActiveLoot then return false end
 local id=Economy.rollLoot(Random.new(DepthZones.Seed+tonumber(node.id)*7919),math.max(0,-node.position.Y))
 if not id then return false end
 return self:spawnReward(node.position,id,node.normal,nil,node)
end
function Loot:spawnReward(position:Vector3,id:string,normal:Vector3?,burstOrigin:Vector3?,sourceNode)
 if self.count>=Config.Ocean.maxActiveLoot+8 then return false end
 local node=sourceNode or {position=position,normal=normal or Vector3.yAxis,used=false}
 local definition=Config.LootById[id];local prefab=ReplicatedStorage.SeaGame.Assets.Loot:FindFirstChild(id)
 if not prefab then warn('[SeaGame] Missing loot asset '..id);return false end
 self.serial+=1;local token=tostring(self.ocean.cycle)..':'..self.serial
 local model=prefab:Clone();model.Name=token;model:SetAttribute('LootId',id);model:SetAttribute('Token',token);model:SetAttribute('GroundPosition',position);model:SetAttribute('BornAt',workspace:GetServerTimeNow());model:SetAttribute('Rarity',definition.rarity)
 if burstOrigin then model:SetAttribute('BurstOrigin',burstOrigin) end
 local up=normal or Vector3.yAxis;local right=Vector3.xAxis-up*up.X
 if right.Magnitude<.1 then right=Vector3.zAxis-up*up.Z end
 right=right.Unit;local aligned=CFrame.fromMatrix(position-up*.025,right,up,right:Cross(up))
 local yaw=if node.id then Random.new(DepthZones.Seed+tonumber(node.id)*104729):NextNumber(0,math.pi*2) else self.rng:NextNumber(0,math.pi*2)
 model:PivotTo(aligned*CFrame.Angles(0,yaw,0))
 local anchor=Instance.new('Part');anchor.Name='PickupRoot';anchor.Size=Vector3.new(.2,.2,.2);anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false;anchor.CFrame=CFrame.new(node.position+Vector3.new(0,.6,0));anchor.Parent=model
 -- A quick press must collect, including keyboard taps shorter than one tenth of a second.
 local prompt=Instance.new('ProximityPrompt');prompt.Name='Collect';prompt.ActionText='Pick up';prompt.ObjectText=definition.name;prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.MaxActivationDistance=Config.PickupDistance-1;prompt.HoldDuration=0;prompt.RequiresLineOfSight=false;prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.Parent=anchor
 local record={node=node,model=model,id=id,position=node.position,taken=false,connection=nil}
 record.connection=prompt.Triggered:Connect(function(player) self:collect(player,token) end)
 node.used=true;self.active[token]=record;self.count+=1;model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;model.Parent=self.folder
 return true
end
function Loot:collect(player,token:string)
 local record=self.active[token];local data=self.profiles:get(player)
 if not record or record.taken or not data then return false,'This treasure is already gone.' end
 local character=player.Character;local root=character and character:FindFirstChild('HumanoidRootPart');local humanoid=character and character:FindFirstChildOfClass('Humanoid')
 if not root or not humanoid or humanoid.Health<=0 or (root.Position-record.position).Magnitude>Config.PickupDistance then return false,'Move closer to the treasure.' end
 if record.position.Y<self.ocean.applied-.05 or self.ocean.refilling then return false,'This treasure is still underwater.' end
 local ok,message=Economy.addLoot(data,record.id)
 if not ok then self.onNotice(player,message,'warning');return false,message end
 -- No yielding between claiming the world ID and granting inventory. Second calls fail.
 record.taken=true;self.active[token]=nil;self.count-=1
 if record.node.starter then record.node.respawnAt=os.clock()+Config.Restroom.StarterMusselRespawn;record.node.used=false end
 if record.connection then record.connection:Disconnect() end
 self.onFX('Pickup',{player=player.UserId,loot=record.id,position=record.position,token=token})
 record.model:Destroy();self.onChanged(player)
 if Economy.count(data)==Economy.capacity(data) then self.onNotice(player,'BACKPACK FULL!','warning') end
 return true,'Treasure collected!'
end
function Loot:step(dt:number)
 self.starterClock+=dt
 if self.starterClock>=1 then
  self.starterClock=0
  for _,node in self.starterNodes do if not node.used and os.clock()>=node.respawnAt and self.count<Config.Ocean.maxActiveLoot then self:spawnReward(node.position,'StarterMussel',node.normal,nil,node) end end
 end
 if not self.ready or self.ocean.refilling then return end
 self.clock+=dt
 while self.nextNode<=#self.nodes do
  local node=self.nodes[self.nextNode]
  if node.position.Y-Config.Ocean.lootMargin<self.ocean.applied then break end
  table.insert(self.pending,node);self.nextNode+=1
 end
 if self.clock<.45 then return end
 self.clock=0
 -- Bound the work even after thousands of sites are exposed. Cache player positions once.
 local positions={}
 for _,player in Players:GetPlayers() do local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart');if root then table.insert(positions,root.Position) end end
 -- Reuse the finite active budget as explorers move deeper. Collected sites stay
 -- consumed; unopened site contents remain deterministic. Chest rewards persist.
 for token,record in self.active do if record.node.id and not record.taken then
  local near=false;for _,position in positions do if (position-record.position).Magnitude<150 then near=true;break end end
  if not near then
   if record.connection then record.connection:Disconnect() end
   record.model:Destroy();self.active[token]=nil;self.count-=1;record.node.used=false;table.insert(self.pending,record.node)
  end
 end end
 if self.count>=Config.Ocean.maxActiveLoot or #self.pending==0 then return end
 local chosen,distance=nil,math.huge
 for _=1,math.min(180,#self.pending) do
  if self.searchIndex>#self.pending then self.searchIndex=1 end
  local i=self.searchIndex;self.searchIndex+=1;local node=self.pending[i]
  for _,p in positions do local d=(p-node.position).Magnitude;if d<distance then chosen=i;distance=d end end
 end
 if chosen and distance<90 then local node=self.pending[chosen];self.pending[chosen]=self.pending[#self.pending];self.pending[#self.pending]=nil;self:spawnNode(node) end
end
function Loot:restart()
 for _,record in self.active do if record.connection then record.connection:Disconnect() end;record.model:Destroy() end
 self.active={};self.count=0;self.pending={};self.nextNode=1;self.searchIndex=1
 for _,node in self.nodes do node.used=false end
end
return Loot
