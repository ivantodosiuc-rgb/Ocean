-- Play-only integration fixture: exercise actual water restoration through the
-- production progress loader, with a dependency-injected persisted store.
local g=require(game.ServerScriptService.SeaGame.Game).current
local C=require(game.ReplicatedStorage.SeaGame.Shared.Config).Ocean
local P=require(game.ServerScriptService.SeaGame.OceanProgress)
for _,player in game.Players:GetPlayers() do g:stopSuction(player) end
g.ocean.progress:close()
local remaining=C.TotalOceanVolume*.375-.123456
local values={
 [C.WorldKey..'_meta']={version=1,total=C.TotalOceanVolume,shards=C.ShardCount,initial=C.initial,minimum=C.minimum,halfSize=C.halfSize},
 [C.WorldKey..'_s14']={version=1,removed=C.TotalOceanVolume-remaining,sessions={}},
}
local store={}
function store:GetAsync(key) return values[key] end
function store:UpdateAsync(key,transform) local result=transform(values[key]);if result then values[key]=result end;return result end
local restored=P.new({store=store,id='RestorationFixture',shard=3,noMessaging=true});restored:load()
g.ocean.ready=false;g.ocean.progress=restored
local deadline=os.clock()+10;while not g.ocean.ready and os.clock()<deadline do task.wait(.1) end
assert(g.ocean.ready,'Restored physical ocean did not become ready')
local snapshot=g.ocean:snapshot()
assert(math.abs(snapshot.RemainingWaterVolume-remaining)<.000001,'Saved fractional volume was lost during restoration')
local bottom=math.floor(snapshot.level/4)*4
local region=Region3.new(Vector3.new(300,bottom,300),Vector3.new(304,bottom+4,304))
local occupancy=workspace.Terrain:ReadVoxelChannels(region,4,{'LiquidOccupancy'}).LiquidOccupancy[1][1][1]
assert(math.abs(bottom+occupancy*4-snapshot.level)<=4/255+.00001,'Restored percent did not restore physical water')
assert(snapshot.OceanRemainingPercent<37.5,'Fractional saved progress rounded up during restoration')
print('OCEAN_RESTORE_PASS',snapshot.RemainingWaterVolume,snapshot.OceanRemainingPercent,snapshot.level,occupancy)
