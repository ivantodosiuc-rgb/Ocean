--!strict
local Config=require(game:GetService('ReplicatedStorage').SeaGame.Shared.Config)
local Volume=require(game.ReplicatedStorage.SeaGame.Shared.OceanVolume)
local Progress=require(script.Parent.OceanProgress)
local Ocean={};Ocean.__index=Ocean
function Ocean.new()
 local self=setmetatable({level=Config.Ocean.initial,applied=Config.Ocean.initial,tiles={},queue={},grids={},clock=0,index=1,cycleLevel=0,cycle=1,refilling=false,onApplied=nil,progress=Progress.new(),ready=false},Ocean)
 local half=Config.Ocean.halfSize;local span=half
 for x=0,1 do for z=0,1 do table.insert(self.tiles,{x=-half+(x+.5)*span,z=-half+(z+.5)*span,width=span,level=Config.Ocean.initial}) end end
 workspace.Ocean:SetAttribute('WaterLevel',self.applied);workspace.Ocean:SetAttribute('MinimumWaterLevel',Config.Ocean.minimum);workspace.Ocean:SetAttribute('Expedition',self.cycle)
 return self
end
function Ocean:writeTile(tile,target:number)
 local bottom=math.floor(math.min(target,tile.level)/4)*4;local top=math.ceil(math.max(target,tile.level)/4)*4
 if top<=bottom then tile.level=target;return end
 local count=tile.width/4;local height=(top-bottom)/4;local cached=self.grids[height]
 if not cached then
  local layers=table.create(height);for y=1,height do layers[y]=table.create(count,0) end
  -- Every horizontal row has the same water level. Shared immutable-during-write rows
  -- avoid allocating hundreds of thousands of Lua values on each update.
  cached={layers=layers,grid=table.create(count,layers)};self.grids[height]=cached
 end
 for y=1,height do local value=math.clamp((target-(bottom+(y-1)*4))/4,0,1);for z=1,count do cached.layers[y][z]=value end end
 local half=tile.width/2
 local region=Region3.new(Vector3.new(tile.x-half,bottom,tile.z-half),Vector3.new(tile.x+half,top,tile.z+half))
 workspace.Terrain:WriteVoxelChannels(region,4,{LiquidOccupancy=cached.grid})
 tile.level=target
end
function Ocean:step(dt:number,power:number)
 dt=math.min(dt,.25);self.clock+=dt
 if self.ready then self.progress:consume(Volume.flow(power,Config.Ocean.BaseRemovalRate,Config.Ocean.MaxRemovalRate)*dt) end
 self.progress:step(dt)
 if self.progress.ready then self.level=Volume.level(self.progress.remaining,self.progress.total,Config.Ocean.initial,Config.Ocean.minimum) end
 local difference=math.abs(self.level-self.applied)
 local endpoint=(self.level==0 or self.level==Config.Ocean.minimum) and difference>.00001
 if #self.queue==0 and self.clock>=Config.Ocean.updatePeriod and (difference>=Config.Ocean.updateDistance or endpoint) then
  self.clock=0;self.queue=table.clone(self.tiles);self.index=1;self.cycleLevel=self.level
 end
 if #self.queue>0 then
  debug.profilebegin('SeaGame water tiles')
  for _=1,1 do
   local tile=self.queue[self.index];if not tile then break end
   self:writeTile(tile,self.cycleLevel);self.index+=1
  end
  debug.profileend()
  if self.index>#self.queue then
   table.clear(self.queue);self.applied=self.cycleLevel;workspace.Ocean:SetAttribute('WaterLevel',self.applied)
   local remaining=Volume.atLevel(self.applied,self.progress.total,Config.Ocean.initial,Config.Ocean.minimum)
   workspace.Ocean:SetAttribute('RemainingWaterVolume',remaining)
   workspace.Ocean:SetAttribute('TotalOceanVolume',self.progress.total)
   if self.onApplied then self.onApplied(self.applied) end
  end
 end
 if self.progress.ready and #self.queue==0 and math.abs(self.applied-self.level)<=Config.Ocean.updateDistance then self.ready=true end
end
function Ocean:canDrain():boolean return self.ready and self.progress:canDrain() end
function Ocean:isComplete():boolean return self.ready and self.progress.remaining==0 and self.applied<=Config.Ocean.minimum+.000001 end
function Ocean:snapshot()
 local total=self.progress.total
 local remaining=Volume.atLevel(self.applied,total,Config.Ocean.initial,Config.Ocean.minimum)
 return {level=self.applied,target=self.level,minimum=Config.Ocean.minimum,complete=self:isComplete(),refilling=false,cycle=1,ready=self.ready,saveStatus=self.progress.status,TotalOceanVolume=total,RemainingWaterVolume=remaining,OceanRemainingPercent=Volume.percent(remaining,total)}
end
return Ocean
