task.wait()
local g=require(game.ServerScriptService.SeaGame.Game).current;local p=game.Players:GetPlayers()[1]
local C=require(game.ReplicatedStorage.SeaGame.Shared.Config);local E=require(game.ReplicatedStorage.SeaGame.Shared.Economy)
local id=workspace:GetAttribute('SurfaceTestChest') or 'CaptainsCache';local ch=g.wrecks.chests[id];local result={id=id}
local ok,err=xpcall(function()
 g:stopSuction(p);g.profiles:get(p).Bag={}
 p.Character:PivotTo(CFrame.new(ch.root.Position+Vector3.new(3,3,0)));task.wait(.4)
 local opened,message,count=g.wrecks:open(p,id);assert(opened,message);assert(count==ch.model:GetAttribute('DropCount'),'Missing rewards')
 assert(not g.wrecks:open(p,id),'Duplicate chest opening')
 local rewards={};local value=0
 for token,r in g.loot.active do if r.model:GetAttribute('BurstOrigin') then
  assert(C.LootById[r.id].value>=ch.model:GetAttribute('MinimumValue'),'Low value reward')
  local near=false;for _,site in ch.model.DropSites:GetChildren()do if (r.position-site.Position).Magnitude<.01 then near=true;break end end
  assert(near,'Reward is not on its baked visible surface');table.insert(rewards,token);value+=C.LootById[r.id].value
 end end
 assert(#rewards==count,'Reward count differs')
 result.count=count;result.value=value;result.tokens=rewards
end,debug.traceback)
result.pass=ok;if not ok then result.error=tostring(err)end
workspace:SetAttribute('SurfaceChestTest',game.HttpService:JSONEncode(result));task.defer(function()script:Destroy()end)
