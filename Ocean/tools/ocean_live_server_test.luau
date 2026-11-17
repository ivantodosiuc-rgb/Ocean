local g=require(game.ServerScriptService.SeaGame.Game).current
local deadline=os.clock()+15;while not g.ocean.ready and os.clock()<deadline do task.wait(.1) end;assert(g.ocean.ready)
local before=g.ocean:snapshot()
local region=Region3.new(Vector3.new(300,-4,300),Vector3.new(304,0,304))
local oldWater=workspace.Terrain:ReadVoxelChannels(region,4,{'LiquidOccupancy'}).LiquidOccupancy[1][1][1]
print('OCEAN_LIVE_READY',before.RemainingWaterVolume,before.OceanRemainingPercent,oldWater)
task.wait(38)
g:stopSuction(game.Players:GetPlayers()[1]);g.ocean.progress:flush();task.wait(1)
local after=g.ocean:snapshot()
local water=workspace.Terrain:ReadVoxelChannels(region,4,{'LiquidOccupancy'}).LiquidOccupancy[1][1][1]
local removed=before.RemainingWaterVolume-after.RemainingWaterVolume
assert(removed>2000 and removed<10000,'Basic straw rate is outside expected range')
assert(math.abs(after.OceanRemainingPercent-after.RemainingWaterVolume/after.TotalOceanVolume*100)<1e-10)
assert(water<oldWater and after.level<before.level,'The percentage changed without physical water removal')
-- Observed Terrain liquid occupancy is stored in 1/255 increments. This is an
-- engine rendering/physics quantization; never feed it back into saved volume.
assert(math.abs((oldWater-water)*4-(before.level-after.level))<=4/255+.00001,'Voxel water exceeds the engine quantization tolerance')
local p=game.Players:GetPlayers()[1];assert(not g:request(p,'NewTide').ok,'Players can reset the shared ocean')
print('OCEAN_LIVE_PASS',game.HttpService:JSONEncode({removed=removed,remaining=after.RemainingWaterVolume,percent=after.OceanRemainingPercent,level=after.level,voxelBefore=oldWater,voxelAfter=water}))
