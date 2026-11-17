local s=require(game.ServerScriptService.SeaGame.Game).current;local p=game.Players:GetPlayers()[1];assert(s.ocean:isComplete());p.Character:PivotTo(CFrame.new(36,11,11));task.wait(.5)
local timings={};local original=s.ocean.writeTile;s.ocean.writeTile=function(self,tile,target) local started=os.clock();original(self,tile,target);table.insert(timings,(os.clock()-started)*1000) end
s.loot:restart();local tide=s:request(p,'NewTide');assert(tide.ok,tide.message)
local deadline=os.clock()+22;while s.ocean.refilling and os.clock()<deadline do task.wait(.1) end;task.wait(.6)
assert(s.ocean.applied==0 and not s.ocean.refilling,'Refill did not finish exactly');assert(s.loot.count==0,'Loot spawned while water returned')
local full=workspace.Terrain:ReadVoxelChannels(Region3.new(Vector3.new(300,-4,300),Vector3.new(304,0,304)),4,{'LiquidOccupancy'}).LiquidOccupancy[1][1][1];assert(full==1)
table.sort(timings);print('STEP3_DEEP_PASS','New tide restores real water and clean loot state');print('STEP3_WATER_PERF',#timings,timings[math.ceil(#timings*.5)],timings[math.ceil(#timings*.95)],timings[#timings]);s.ocean.writeTile=original;print('STEP3_DEEP_COMPLETE')
