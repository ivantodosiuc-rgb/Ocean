local Players=game:GetService('Players');local RunService=game:GetService('RunService')
assert(RunService:IsRunning(),'Play required')
local player=assert(Players.LocalPlayer);local character=assert(player.Character);local humanoid=character.Humanoid;local root=character.HumanoidRootPart
local controls=require(player.PlayerScripts.PlayerModule):GetControls();controls:Disable()
print('SHOP_WALK_SPAWN',root.Position,humanoid.Health)
local route={{'Square',0,0},{'Straws path',-16,-3},{'Finn counter approach',-32,-7},{'Return',-14,-3},{'Square',0,0},{'Upgrades path',8,-15},{'Maya counter approach',18,-27},{'Return',8,-15},{'Square',0,0},{'Treasures path',16,5},{'Captain counter approach',34,18},{'Return',16,5},{'Square',0,0},{'Dock path',0,20},{'Dock path',-2,36},{'Beach',0,54},{'Pier entrance',0,68},{'Pier',0,86},{'Pier',0,108},{'Pier end',0,126}}
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={character,workspace.NPCs};params.IgnoreWater=true;params.RespectCanCollide=true
local failures=0
for i,step in route do
 local hit=workspace:Raycast(Vector3.new(step[2],40,step[3]),Vector3.new(0,-70,0),params);local target=Vector3.new(step[2],hit and hit.Position.Y or 6,step[3]);humanoid:MoveTo(target)
 local elapsed,distance=0,999
 repeat elapsed+=RunService.Heartbeat:Wait();distance=(Vector3.new(root.Position.X,0,root.Position.Z)-Vector3.new(target.X,0,target.Z)).Magnitude until distance<2 or elapsed>7 or humanoid.Health<=0
 local ok=distance<2 and root.Position.Y>2 and humanoid.Health>0;if not ok then failures+=1 end
 print('SHOP_WALK_STEP',i,step[1],ok and 'PASS' or 'FAIL',math.round(distance*100)/100,root.Position)
end
controls:Enable();print('SHOP_WALK_DONE',#route,failures,humanoid.Health)
