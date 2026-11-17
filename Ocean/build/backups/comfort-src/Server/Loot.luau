--!strict
local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local ReplicatedStorage=game:GetService('ReplicatedStorage')
local Shared=ReplicatedStorage.SeaGame.Shared
local Config=require(Shared.Config);local Economy=require(Shared.Economy)
local Loot={};Loot.__index=Loot
function Loot.new(ocean,profiles,onChanged,onFX,onNotice)
 local folder=Instance.new('Folder');folder.Name='LiveLoot';folder.Parent=workspace
 local self=setmetatable({ocean=ocean,profiles=profiles,onChanged=onChanged,onFX=onFX,onNotice=onNotice,folder=folder,nodes={},pending={},active={},count=0,rng=Random.new(),clock=0,ready=false,nextNode=1,serial=0,searchIndex=1},Loot)
 task.spawn(function() self:measureShore() end)
 return self
end
function Loot:measureShore()
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={workspace.StarterIsland.GoldenShore,workspace.UnderwaterTerrain};params.IgnoreWater=true;params.RespectCanCollide=true
 local step=Config.Ocean.lootSpacing;local visited=0
 local radius=Config.Ocean.lootRadius
 for x=-radius,radius,step do for z=-radius,radius,step do
  if x*x+z*z>radius*radius then continue end
  local px=x+self.rng:NextNumber(-.6,.6);local pz=z+self.rng:NextNumber(-.6,.6)
  local hit=workspace:Raycast(Vector3.new(px,1,pz),Vector3.new(0,Config.Ocean.minimum-8,0),params)
  if hit and hit.Normal.Y>.76 and hit.Position.Y<-.03 and hit.Position.Y>Config.Ocean.minimum+.5 then
   table.insert(self.nodes,{id=tostring(x)..'_'..tostring(z),position=hit.Position,normal=hit.Normal,used=false})
  end
  visited+=1;if visited%220==0 then RunService.Heartbeat:Wait() end
 end end
 table.sort(self.nodes,function(a,b) return a.position.Y>b.position.Y end);self.ready=true
 print('[SeaGame] Measured loot sites',#self.nodes)
end
function Loot:spawnNode(node)
 if node.used or self.count>=Config.Ocean.maxActiveLoot then return false end
 local id=Economy.rollLoot(self.rng,math.max(0,-node.position.Y))
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
 model:PivotTo(aligned*CFrame.Angles(0,self.rng:NextNumber(0,math.pi*2),0))
 local anchor=Instance.new('Part');anchor.Name='PickupRoot';anchor.Size=Vector3.new(.2,.2,.2);anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false;anchor.CFrame=CFrame.new(node.position+Vector3.new(0,.6,0));anchor.Parent=model
 local prompt=Instance.new('ProximityPrompt');prompt.Name='Collect';prompt.ActionText='Collect';prompt.ObjectText=definition.name;prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.MaxActivationDistance=7;prompt.HoldDuration=.12;prompt.RequiresLineOfSight=false;prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.Parent=anchor
 local record={node=node,model=model,id=id,position=node.position,taken=false,connection=nil}
 record.connection=prompt.Triggered:Connect(function(player) self:collect(player,token) end)
 node.used=true;self.active[token]=record;self.count+=1;model.Parent=self.folder
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
 if record.connection then record.connection:Disconnect() end
 self.onFX('Pickup',{player=player.UserId,loot=record.id,position=record.position,token=token})
 record.model:Destroy();self.onChanged(player)
 if Economy.count(data)==Economy.capacity(data) then self.onNotice(player,'BACKPACK FULL!','warning') end
 return true,'Treasure collected!'
end
function Loot:step(dt:number)
 if not self.ready or self.ocean.refilling then return end
 self.clock+=dt
 while self.nextNode<=#self.nodes do
  local node=self.nodes[self.nextNode]
  if node.position.Y-Config.Ocean.lootMargin<self.ocean.applied then break end
  table.insert(self.pending,node);self.nextNode+=1
 end
 if self.clock<.45 or self.count>=Config.Ocean.maxActiveLoot or #self.pending==0 then return end
 self.clock=0
 -- Bound the work even after thousands of sites are exposed. Cache player positions once.
 local positions={}
 for _,player in Players:GetPlayers() do local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart');if root then table.insert(positions,root.Position) end end
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
