task.spawn(function()
 local Players=game:GetService('Players')
 local player=Players.LocalPlayer or Players:GetPlayers()[1]
 assert(player,'No player: start Studio Play first')
 local character=player.Character or player.CharacterAdded:Wait()
 local humanoid=character:WaitForChild('Humanoid');local root=character:WaitForChild('HumanoidRootPart')
 local controls
 if Players.LocalPlayer then
  local ok,module=pcall(function() return require(player.PlayerScripts:WaitForChild('PlayerModule')) end)
  if ok then controls=module:GetControls();controls:Disable() end
 end
 task.wait(2)
 print('PLAYTEST_SPAWN',root.Position,humanoid.Health,humanoid:GetState().Name)
 local route={{'Square',0,0},{'Straws path',-16,-3},{'Finn',-32,-7},{'Return square',-14,-3},{'Square',0,0},{'Upgrades path',8,-15},{'Maya',18,-27},{'Return square',8,-15},{'Square',0,0},{'Treasures path',16,5},{'Captain Shell',34,18},{'Return square',16,5},{'Square',0,0},{'Dock path',0,20},{'Dock path',-2,36},{'Beach path',0,54},{'Pier entrance',0,68},{'Pier',0,86},{'Pier',0,108},{'Pier end',0,126}}
 local failures=0
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={character,workspace.NPCs};params.IgnoreWater=true;params.RespectCanCollide=true
 for i,step in route do
  local hit=workspace:Raycast(Vector3.new(step[2],40,step[3]),Vector3.new(0,-70,0),params)
  local target=Vector3.new(step[2],hit and hit.Position.Y or 6,step[3])
  humanoid:MoveTo(target)
  local started=os.clock();local distance=999
  repeat
   task.wait(.1);distance=(Vector3.new(root.Position.X,0,root.Position.Z)-Vector3.new(target.X,0,target.Z)).Magnitude
  until distance<2 or os.clock()-started>7 or humanoid.Health<=0
  local ok=distance<2 and root.Position.Y>2 and humanoid.Health>0
  if not ok then failures+=1 end
  print('PLAYTEST_WALK',i,step[1],ok and 'PASS' or 'FAIL',math.round(distance*100)/100,root.Position)
 end
 if controls then controls:Enable() end
 print('PLAYTEST_DONE',#route,'waypoints',failures,'failures',humanoid.Health)
end)
