assert(game:GetService('RunService'):IsServer());local terrain=workspace.Terrain
local region=Region3.new(Vector3.new(-1536,-4,-1536),Vector3.new(0,0,0));local row=table.create(384,1);local grid=table.create(384,{row})
for _,value in {.9375,.875,.8125,1} do
 for i=1,384 do row[i]=value end
 local t=os.clock();terrain:WriteVoxelChannels(region,4,{LiquidOccupancy=grid});local elapsed=(os.clock()-t)*1000
 local sample=terrain:ReadVoxelChannels(Region3.new(Vector3.new(-304,-4,-304),Vector3.new(-300,0,-300)),4,{'LiquidOccupancy'}).LiquidOccupancy[1][1][1]
 print('STEP3_VOXEL_BENCH',value,elapsed,sample);assert(math.abs(sample-value)<.005);task.wait(.2)
end
print('STEP3_VOXEL_BENCH_COMPLETE')
