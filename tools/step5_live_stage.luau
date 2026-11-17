-- Temporary Studio Play diagnostic. Never installed into the saved game.
task.wait()
assert(game.GameId==0 and game:GetService('RunService'):IsStudio())
local g=require(game.ServerScriptService.SeaGame.Game).current
local Z=require(game.ReplicatedStorage.SeaGame.Shared.DepthZones)
local Sites=require(game.ServerScriptService.SeaGame.GroundSites)
local V=require(game.ReplicatedStorage.SeaGame.Shared.OceanVolume)
local p=game.Players:GetPlayers()[1];local stage=workspace:GetAttribute('Step5RequestedStage')or 1
local tests={{level=-28,x=122,z=15},{level=-60,x=15,z=169},{level=-94,x=166,z=136},{level=-126,x=-174,z=192},{level=-164,x=-293,z=-61}}
local target=tests[stage];local report={stage=stage}
local ok,err=xpcall(function()
 local deadline=os.clock()+20;while not g.ocean.ready and os.clock()<deadline do task.wait(.1)end;assert(g.ocean.ready)
 g:stopSuction(p)
 local desired=V.atLevel(target.level,g.ocean.progress.total,0,-168)
 local amount=g.ocean.progress.remaining-desired;assert(amount>=0,'Depth tests must progress outwards')
 g.ocean.progress:consume(amount);assert(g.ocean.progress:flush())
 deadline=os.clock()+20;while math.abs(g.ocean.applied-target.level)>.01 and os.clock()<deadline do task.wait(.1)end
 assert(math.abs(g.ocean.applied-target.level)<.01,'Physical water did not match server volume')
 local node,best=nil,math.huge
 for i=1,Sites.count do local q,n=Sites.get(i);local d=Vector2.new(q.X-target.x,q.Z-target.z).Magnitude
  if q.Y>target.level+.2 and Z.index(-q.Y)==stage and d<best then best=d;node=q end
 end;assert(node and best<32,'No reachable clear site near landmark')
 local root=p.Character.HumanoidRootPart;root.Anchored=true;p.Character:PivotTo(CFrame.new(node+Vector3.new(0,4,0)));pcall(function()p:RequestStreamAroundAsync(node,5)end);task.wait(1);root.Anchored=false;task.wait(2)
 local h=p.Character.Humanoid;assert(h.Health>0 and root.Position.Y>node.Y-1,'Character fell below visible ground')
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={workspace.UnderwaterTerrain.Seafloor};params.IgnoreWater=true;params.RespectCanCollide=true
 local hit=workspace:Raycast(root.Position,Vector3.new(0,-12,0),params);assert(hit,'No floor collision under player')
 report.position={root.Position.X,root.Position.Y,root.Position.Z};report.floor=hit.Instance:GetFullName();report.visibleFloor={node.X,node.Y,node.Z};report.collisionGap=hit.Position.Y-node.Y;report.water=g.ocean.applied;report.percent=g.ocean:snapshot().OceanRemainingPercent;report.loot=g.loot.count
 local water=workspace.Terrain:ReadVoxelChannels(Region3.new(Vector3.new(360,target.level-4,360),Vector3.new(364,target.level,364)):ExpandToGrid(4),4,{'LiquidOccupancy'}).LiquidOccupancy
 report.hasWaterBelow=water[1][1][1]>.95;assert(report.hasWaterBelow,'Water column is missing at new depth')
 report.passed=true
end,debug.traceback)
if not ok then report.passed=false;report.error=err end
workspace:SetAttribute('Step5Stage'..stage,game.HttpService:JSONEncode(report));task.defer(function()script:Destroy()end)
