local g=require(game.ServerScriptService.SeaGame.Game).current
local region=Region3.new(Vector3.new(300,-4,300),Vector3.new(304,0,304))
local water=workspace.Terrain:ReadVoxelChannels(region,4,{'LiquidOccupancy'}).LiquidOccupancy[1][1][1]
local s=g.ocean:snapshot()
print('OCEAN_PHYSICAL_PROBE',game.HttpService:JSONEncode(s),'occupancy',water,'voxelLevel',(water-1)*4)
