local s=require(game.ServerScriptService.SeaGame.Game).current;assert(s);local p=game.Players:GetPlayers()[1];s:stopSuction(p)
local timings={};local original=s.ocean.writeTile;s.ocean.writeTile=function(self,tile,target) local started=os.clock();original(self,tile,target);table.insert(timings,(os.clock()-started)*1000) end
s.ocean.level=-36
local deadline=os.clock()+12;while not s.ocean:isComplete() and os.clock()<deadline do task.wait(.1) end;assert(s.ocean.applied==-36,'Minimum water not applied exactly')
for _,node in s.loot.nodes do if not node.used and node.position.Y>-35.5 then s.loot:spawnNode(node) end;if s.loot.count>=48 then break end end
assert(s.loot.count==48 and #workspace.LiveLoot:GetChildren()==48,'Loot cap failed');print('STEP3_DEEP_PASS','Exact minimum and 48-loot cap')
local region=Region3.new(Vector3.new(300,-36,300),Vector3.new(304,-32,304));local sample=workspace.Terrain:ReadVoxelChannels(region,4,{'LiquidOccupancy'}).LiquidOccupancy[1][1][1];assert(sample==0,'Water remains above minimum')
workspace.Ocean:SetAttribute('DeepTestReady',true);print('STEP3_DEEP_READY')
task.wait(35)
p.Character:PivotTo(CFrame.new(36,11,11));task.wait(.5);s.loot:restart()
local tide=s:request(p,'NewTide');assert(tide.ok,tide.message)
deadline=os.clock()+20;while s.ocean.refilling and os.clock()<deadline do task.wait(.1) end;task.wait(.6)
assert(s.ocean.applied==0 and not s.ocean.refilling,'Refill did not finish at exactly zero')
assert(s.loot.count==0,'Treasure spawned before fresh land was exposed')
local full=workspace.Terrain:ReadVoxelChannels(Region3.new(Vector3.new(300,-4,300),Vector3.new(304,0,304)),4,{'LiquidOccupancy'}).LiquidOccupancy[1][1][1];assert(full==1)
table.sort(timings);print('STEP3_DEEP_PASS','New tide restores real water and clean loot state');print('STEP3_WATER_PERF',#timings,timings[math.ceil(#timings*.5)],timings[math.ceil(#timings*.95)],timings[#timings])
s.ocean.writeTile=original;print('STEP3_DEEP_COMPLETE')
