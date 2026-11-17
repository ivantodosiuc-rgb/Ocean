local g=require(game.ServerScriptService.SeaGame.Game).current;local p=game.Players:GetPlayers()[1];g:stopSuction(p)
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={workspace.UnderwaterTerrain.Seafloor,workspace.StarterIsland.GoldenShore,workspace.StarterIsland.Meadow};params.IgnoreWater=true;params.RespectCanCollide=true
local samples=0;local maxSlope=0
for _,angle in {0,math.pi*.5,math.pi,math.pi*1.5} do
 local previous=nil
 for r=50,235,5 do
  local hit=workspace:Raycast(Vector3.new(math.cos(angle)*r,20,math.sin(angle)*r),Vector3.new(0,-110,0),params);assert(hit,'Hole in progressive seabed')
  if previous then maxSlope=math.max(maxSlope,math.abs(hit.Position.Y-previous)/5) end
  previous=hit.Position.Y;samples+=1
 end
end
print('DEPTH_SLOPES_PASS',samples,maxSlope)
g.ocean.level=-60;local deadline=os.clock()+10;while math.abs(g.ocean.applied+60)>.01 and os.clock()<deadline do task.wait(.1) end;assert(math.abs(g.ocean.applied+60)<.01)
local chest=g.wrecks.chests.TidekeepersCache
p.Character:PivotTo(CFrame.new(chest.root.Position+Vector3.new(3,2,0)));task.wait(.6)
local before={};for token in g.loot.active do before[token]=true end
assert(g.wrecks:open(p,'TidekeepersCache'))
local drops=0;for token,record in g.loot.active do if not before[token] and record.model:GetAttribute('BurstOrigin') then assert(require(game.ReplicatedStorage.SeaGame.Shared.Config).LootById[record.id].value>=1250);drops+=1 end end
assert(drops==5,'Ruins must drop five high-value resources');assert(not g.wrecks:open(p,'TidekeepersCache'))
print('DEPTH_RUINS_PASS',drops,'water',g.ocean.applied)
