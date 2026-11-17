task.wait()
assert(game:GetService('RunService'):IsStudio() and game.GameId==0,'Local Play only')
local g=require(game.ServerScriptService.SeaGame.Game).current
local p=game.Players:GetPlayers()[1]
local E=require(game.ReplicatedStorage.SeaGame.Shared.Economy)
local C=require(game.ReplicatedStorage.SeaGame.Shared.Config)
local data=g.profiles:get(p);local original=E.copy(data)
local root=p.Character.HumanoidRootPart;local originalCFrame=root.CFrame;local anchored=root.Anchored
local checks={};local count=0
local function check(ok,label)assert(ok,label);table.insert(checks,label)end
local position=Vector3.new(-18,5.2634983,65)
local function spawn(id,pos)
 check(g.loot:spawnReward(pos or position,id,Vector3.yAxis),'spawn '..id)
 return tostring(g.ocean.cycle)..':'..g.loot.serial
end
local ok,err=xpcall(function()
 data.Bag={};root.Anchored=true;root.CFrame=CFrame.new(position+Vector3.new(0,3.5,0))
 for _,item in C.Loot do
  data.Bag={};local token=spawn(item.id)
  local prompt=g.loot.active[token].model.PickupRoot.Collect
  check(prompt.HoldDuration==0 and prompt.KeyboardKeyCode==Enum.KeyCode.E,'instant E '..item.id)
  check(g.loot:collect(p,token) and data.Bag[item.id]==1,'grant '..item.id)
  check(not g.loot:collect(p,token) and data.Bag[item.id]==1,'no duplicate '..item.id)
  count+=1;task.wait(.025)
 end
 data.Bag={StarterMussel=E.capacity(data)};local fullToken=spawn('StarterMussel')
 check(not g.loot:collect(p,fullToken) and g.loot.active[fullToken]~=nil,'Full bag keeps treasure')
 data.Bag={};root.CFrame=CFrame.new(position+Vector3.new(0,3,20))
 check(not g.loot:collect(p,fullToken),'Distance still checked')
 root.CFrame=CFrame.new(position+Vector3.new(0,3.5,0))
 check(g.loot:collect(p,fullToken),'Retry succeeds after room is available')
 check(not g.loot:collect(p,'missing-token'),'Unknown token rejected')
end,debug.traceback)
for key,value in original do data[key]=value end
root.Anchored=anchored;root.CFrame=originalCFrame;g:sendState(p)
workspace:SetAttribute('InstantPickupServerQA',game.HttpService:JSONEncode({passed=ok,error=if ok then nil else tostring(err),resources=count,checks=checks}))
task.defer(function()script:Destroy()end)
