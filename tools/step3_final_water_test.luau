local s=require(game.ServerScriptService.SeaGame.Game).current;local p=game.Players:GetPlayers()[1];s:stopSuction(p);s.ocean.level=-36
local deadline=os.clock()+12;while s.ocean.applied~=-36 and os.clock()<deadline do task.wait(.1) end;assert(s.ocean.applied==-36)
local sample=workspace.Terrain:ReadVoxelChannels(Region3.new(Vector3.new(300,-36,300),Vector3.new(304,-32,304)),4,{'LiquidOccupancy'}).LiquidOccupancy[1][1][1];assert(sample==0)
for _,node in s.loot.nodes do if not node.used and node.position.Y>-35.5 then s.loot:spawnNode(node) end;if s.loot.count>=48 then break end end;assert(s.loot.count==48)
print('STEP3_FINAL_WATER_PASS','Exact minimum, dry upper layer and 48-loot cap')
p.Character:PivotTo(CFrame.new(36,11,11));task.wait(.5)
local timings={};local original=s.ocean.writeTile;s.ocean.writeTile=function(self,tile,target) local started=os.clock();original(self,tile,target);table.insert(timings,(os.clock()-started)*1000) end
s.loot:restart();assert(s:request(p,'NewTide').ok);deadline=os.clock()+22
while s.ocean.refilling and os.clock()<deadline do task.wait(.1) end;task.wait(.6)
assert(s.ocean.applied==0 and s.loot.count==0 and not s.ocean.refilling)
local full=workspace.Terrain:ReadVoxelChannels(Region3.new(Vector3.new(300,-4,300),Vector3.new(304,0,304)),4,{'LiquidOccupancy'}).LiquidOccupancy[1][1][1];assert(full==1)
table.sort(timings);print('STEP3_FINAL_WATER_PERF',#timings,timings[math.ceil(#timings*.5)],timings[math.ceil(#timings*.95)],timings[#timings]);s.ocean.writeTile=original;print('STEP3_FINAL_WATER_COMPLETE')
