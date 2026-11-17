assert(game:GetService('RunService'):IsClient())
local p=game.Players.LocalPlayer;local char=p.Character;local human=char.Humanoid;local ctl=require(game.ReplicatedStorage.SeaGame.Client.Controller).current;assert(ctl)
local remotes=game.ReplicatedStorage.SeaGame.Remotes;local controls=require(p.PlayerScripts.PlayerModule):GetControls();controls:Disable()
local function pause(t) task.wait(t or .4) end
local function request(action,data) pause(.4);return remotes.Request:InvokeServer(action,data) end
local function state() return request('State').state end
local function move(position,look) char:PivotTo(CFrame.lookAt(position,look or position+Vector3.new(0,0,-1)));char.HumanoidRootPart.AssemblyLinearVelocity=Vector3.zero;pause(.3) end
local report={};local function check(ok,name) assert(ok,name);table.insert(report,name);print('STEP3_LOOP_PASS',name) end
ctl:stop();ctl.ui:close();move(Vector3.new(10,8,126),Vector3.new(22,3,126));pause(1)
local before=workspace.Ocean:GetAttribute('WaterLevel');local start=os.clock();local samples={}
while os.clock()-start<22 do
 local point=ctl:waterPoint();assert(point,'No reachable ocean from dock');remotes.Suction:FireServer(point);pause(.35);table.insert(samples,workspace.Ocean:GetAttribute('WaterLevel'))
end
remotes.Suction:FireServer(false);pause(.6)
local after=workspace.Ocean:GetAttribute('WaterLevel');check(after<before-1,'Basic Straw lowers actual ocean')
local voxel=workspace.Terrain:ReadVoxelChannels(Region3.new(Vector3.new(300,-4,300),Vector3.new(304,0,304)),4,{'LiquidOccupancy'}).LiquidOccupancy[1][1][1]
check(voxel<.8 and voxel>0,'Terrain water occupancy really decreased')
local stopped=workspace.Ocean:GetAttribute('WaterLevel');pause(1.5);check(math.abs(workspace.Ocean:GetAttribute('WaterLevel')-stopped)<.02,'Release stops draining')
pause(1);check(#workspace.LiveLoot:GetChildren()>0,'Physical treasure appears on exposed shore')
local function fillBag()
 local current=state()
 while current.count<current.capacity do
  local chosen
  for _,item in workspace.LiveLoot:GetChildren() do if item:GetAttribute('GroundPosition') and item:GetAttribute('GroundPosition').Y>=workspace.Ocean:GetAttribute('WaterLevel') then chosen=item;break end end
  if not chosen then pause(1);continue end
  move(chosen:GetAttribute('GroundPosition')+Vector3.new(0,3.5,0));local r=request('Collect',chosen:GetAttribute('Token'));assert(r.ok,r.message);current=r.state
 end
 return current
end
local full=fillBag();check(full.count==5 and full.capacity==5,'Five real pickups fill starting backpack')
local extra=workspace.LiveLoot:GetChildren()[1];assert(extra);move(extra:GetAttribute('GroundPosition')+Vector3.new(0,3.5,0));local blocked=request('Collect',extra:GetAttribute('Token'))
check(not blocked.ok and extra.Parent==workspace.LiveLoot and state().count==5,'Full bag leaves world treasure untouched')
local totalSold=0
for trip=1,10 do
 local fullState=state();local expected=fullState.value;local beforeCoins=fullState.coins
 move(Vector3.new(36,10,11),Vector3.new(49,10,17));local sold=request('SellAll');assert(sold.ok,sold.message)
 check(sold.state.coins==beforeCoins+expected and sold.state.count==0,'Sale pays exact bag value trip '..trip);totalSold+=expected
 local double=request('SellAll');check(not double.ok and double.state.coins==sold.state.coins,'Repeated sale gives no duplicate coins')
 if sold.state.coins>=350 then break end
 fillBag()
end
local saved=state();check(saved.coins>=250,'Earned enough coins through actual treasure sales')
move(Vector3.new(-38.4,11,-7.8),Vector3.new(-40,10,-19));local bought=request('BuyStraw','ColorfulStraw');check(bought.ok and bought.state.equipped=='ColorfulStraw' and bought.state.coins==saved.coins-150,'Buy Colorful Straw with earned coins')
local duplicate=request('BuyStraw','ColorfulStraw');check(not duplicate.ok and duplicate.state.coins==bought.state.coins,'Duplicate purchase does not charge twice')
move(Vector3.new(21,11,-29),Vector3.new(26,10,-41));local upgrade=request('Upgrade','Power');check(upgrade.ok and math.abs(upgrade.state.stats.power-2.4)<.001,'Power upgrade changes server suction rate')
move(Vector3.new(10,8,126),Vector3.new(22,3,126));local initial=workspace.Ocean:GetAttribute('WaterLevel');local begun=os.clock()
while os.clock()-begun<8 do local point=ctl:waterPoint();assert(point);remotes.Suction:FireServer(point);pause(.35) end
remotes.Suction:FireServer(false);pause(.6);local delta=initial-workspace.Ocean:GetAttribute('WaterLevel');check(delta>1.2,'Upgraded straw drains faster')
check(human.Health==100,'Player survives every collection and shop visit')
controls:Enable();print('STEP3_LOOP_COMPLETE',#report,totalSold,after,voxel,delta)
ctl.ui:toastMessage('Playtest complete: collect → sell → upgrade works.','success')
