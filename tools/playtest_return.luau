task.spawn(function()
 local p=game.Players.LocalPlayer;local c=p.Character;local h=c.Humanoid;local r=c.HumanoidRootPart
 local controls=require(p.PlayerScripts.PlayerModule):GetControls();controls:Disable()
 local failures=0
 for _,z in {108,86,77,73,68,60,48,30,15,0} do
  h:MoveTo(Vector3.new(0,6,z));local start=os.clock()
  repeat task.wait(.1) until math.abs(r.Position.Z-z)<1.8 or os.clock()-start>7
  local ok=math.abs(r.Position.Z-z)<1.8 and h.Health>0;if not ok then failures+=1 end
  print('PLAYTEST_RETURN',z,ok and 'PASS' or 'FAIL',r.Position)
 end
 controls:Enable();print('PLAYTEST_RETURN_DONE',failures)
end)
