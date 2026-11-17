assert(game:GetService('RunService'):IsServer())
require(game.ServerStorage.SeaGameTests.EconomyProfiles)()
local s=require(game.ServerScriptService.SeaGame.Game).current;assert(s,'Active game session missing')
local p=game.Players:GetPlayers()[1];local E=require(game.ReplicatedStorage.SeaGame.Shared.Economy)
local old=s:snapshot(p);assert(old and old.coins==0 and old.count==0)
local invalid={s:request(p,'BuyStraw','OceanVacuum'),s:request(p,'Upgrade','Backpack'),s:request(p,'SellAll'),s:request(p,{},'Bad'),s:request(p,'Collect',{})}
for i,result in invalid do assert(not result.ok,'Untrusted request accepted '..i) end
assert(s:snapshot(p).coins==0 and s:snapshot(p).count==0);print('STEP3_TEST_PASS','Distance and payload checks reject five invalid requests')
local blocked=0;for _=1,25 do if not s:request(p,'State').ok then blocked+=1 end end;assert(blocked>10);print('STEP3_TEST_PASS','Request flood throttled',blocked)
local root=p.Character.HumanoidRootPart;local noWater=s:validTarget(p,root.Position);assert(not noWater and not s:validTarget(p,Vector3.new(0/0,0,0)));print('STEP3_TEST_PASS','Dry land and NaN suction rejected')
local snapshots={};local previous=s.ocean.applied
for _=1,60 do local dt=game:GetService('RunService').Heartbeat:Wait();table.insert(snapshots,dt) end
assert(s.ocean.applied==previous,'Ocean drained without input')
print('STEP3_TEST_PASS','Ocean stays still without suction')
print('STEP3_SERVER_COMPLETE',s.loot.ready,#s.loot.nodes,s.loot.count)
