assert(game:GetService('RunService'):IsRunning(),'Only benchmark in temporary Play')
local terrain=workspace.Terrain;local region=Region3.new(Vector3.new(300,-4,300),Vector3.new(304,0,304))
for _,level in {-.25,-.5,-.75,-1} do
 local start=DateTime.now().UnixTimestampMillis
 terrain:FillBlock(CFrame.new(0,-2,0),Vector3.new(3072,4,3072),Enum.Material.Air)
 terrain:FillBlock(CFrame.new(0,(-4+level)/2,0),Vector3.new(3072,level+4,3072),Enum.Material.Water)
 local output=terrain:ReadVoxelChannels(region,4,{'LiquidOccupancy'})
 print('WATER_BENCHMARK',level,DateTime.now().UnixTimestampMillis-start,output.LiquidOccupancy[1][1][1])
 for i=1,12 do game:GetService('RunService').Heartbeat:Wait() end
end
print('WATER_BENCHMARK_DONE')
