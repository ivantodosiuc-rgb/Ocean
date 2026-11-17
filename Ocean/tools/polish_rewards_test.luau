local g=require(game.ServerScriptService.SeaGame.Game).current;local p=game.Players:GetPlayers()[1]
local E=require(game.ReplicatedStorage.SeaGame.Shared.Economy);local C=require(game.ReplicatedStorage.SeaGame.Shared.Config)
local id=workspace:GetAttribute('PolishTestChest') or 'CaptainsCache'
local data=g.profiles:get(p);local ch=g.wrecks.chests[id];local rewards={};local expected=0
assert(ch.opened and not ch.prompt.Enabled,'Opened chest state not authoritative')
assert(not g.wrecks:open(p,id),'Duplicate opening granted loot')
for token,record in g.loot.active do if record.model:GetAttribute('BurstOrigin') then
 assert(C.LootById[record.id].value>=ch.model:GetAttribute('MinimumValue'),'Chest granted low-value loot');table.insert(rewards,{token=token,record=record});expected+=C.LootById[record.id].value
end end
assert(#rewards==ch.model:GetAttribute('DropCount'),'Physical reward count mismatch')
local first=rewards[1];p.Character:PivotTo(CFrame.new(first.record.position+Vector3.new(0,3,0)));task.wait(.3)
data.Bag={CommonShell=E.capacity(data)};assert(not g.loot:collect(p,first.token) and g.loot.active[first.token],'Full bag destroyed chest reward')
data.Bag={}
for _,drop in rewards do p.Character:PivotTo(CFrame.new(drop.record.position+Vector3.new(0,3,0)));task.wait(.18);assert(g.loot:collect(p,drop.token));assert(not g.loot:collect(p,drop.token),'Duplicate pickup') end
p.Character:PivotTo(CFrame.new(40,11,26));task.wait(.5);local before=data.Coins;local result=g:request(p,'SellAll')
assert(result.ok and data.Coins-before==expected,'Chest sale value mismatch')
print('POLISH_REWARDS_PASS',id,#rewards,expected,'duplicate and full-bag guards retained')
