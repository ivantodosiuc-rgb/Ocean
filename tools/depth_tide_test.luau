local g=require(game.ServerScriptService.SeaGame.Game).current;local p=game.Players:GetPlayers()[1];g:stopSuction(p)
g.ocean.level=-68
local deadline=os.clock()+10;while math.abs(g.ocean.applied+68)>.001 and os.clock()<deadline do task.wait(.1) end
assert(g.ocean.applied==-68,'Exact final water level')
local water=workspace.Terrain:ReadVoxelChannels(Region3.new(Vector3.new(300,-68,300),Vector3.new(304,-64,304)),4,{'LiquidOccupancy'}).LiquidOccupancy[1][1][1]
assert(water==0,'Deep water was not physically removed')
p.Character:PivotTo(CFrame.new(40,11,26));task.wait(.4)
-- Clear the test fixture immediately before requesting a new tide. Waiting after
-- restart would allow the ordinary loot spawner to populate this exposed ground.
g.loot:restart()
local result=g:request(p,'NewTide');assert(result.ok,'Could not begin a new tide: '..tostring(result.message))
assert(not workspace.UnderwaterTerrain.PointsOfInterest.CaptainsCache:GetAttribute('Opened'))
deadline=os.clock()+30;while g.ocean.refilling and os.clock()<deadline do task.wait(.2) end
assert(g.ocean.applied==0 and not g.ocean.refilling,'Tide did not return exactly to zero')
assert(g.loot.count==0,'Loot appeared before the land was exposed')
water=workspace.Terrain:ReadVoxelChannels(Region3.new(Vector3.new(300,-4,300),Vector3.new(304,0,304)),4,{'LiquidOccupancy'}).LiquidOccupancy[1][1][1]
assert(water==1,'Physical water did not return')
print('DEPTH_TIDE_PASS','-68 to 0; real water; chests reset; no premature loot')
