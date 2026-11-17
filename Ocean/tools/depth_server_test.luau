local RunService=game:GetService('RunService')
local g=require(game.ServerScriptService.SeaGame.Game).current
local E=require(game.ReplicatedStorage.SeaGame.Shared.Economy)
local C=require(game.ReplicatedStorage.SeaGame.Shared.Config)
local p=game.Players:GetPlayers()[1];assert(p)
while not g.profiles:get(p) or not g.loot.ready do task.wait(.1) end
local data=g.profiles:get(p);local checks=0
local function check(ok,name) assert(ok,name);checks+=1;print('DEPTH_TEST_PASS',name) end
check(#C.Loot==50 and #game.ReplicatedStorage.SeaGame.Assets.Loot:GetChildren()==50,'All 50 Blender resources installed')
for _,item in C.Loot do local d=E.new();assert(E.addLoot(d,item.id));local ok,_,value=E.sell(d);assert(ok and value==item.value and d.Coins==value) end
check(true,'All 50 resources collect and sell for exact values')
check(g.loot.ready and #g.loot.nodes>3000,'Depth sites measured on the real new seabed')
g:stopSuction(p)
local first=g:snapshot(p).held;local r=g:request(p,'ToggleHeld');check(r.ok and r.state.held~=first,'ToggleHeld changes real Tool parent')
task.wait(.4);r=g:request(p,'ToggleHeld');check(r.ok and r.state.held==first,'ToggleHeld restores same straw')
local strawCount=0;for _,where in {p.Backpack,p.Character} do for _,o in where:GetChildren() do if o:IsA('Tool') and o:GetAttribute('SeaStraw') then strawCount+=1 end end end
check(strawCount==1,'Toggling does not duplicate Tools')
check(not g.wrecks:open(p,'CaptainsCache'),'Distant chest opening rejected')
local chest=g.wrecks.chests.CaptainsCache;assert(chest)
p.Character:PivotTo(CFrame.new(chest.root.Position+Vector3.new(3,2,0)));task.wait(.5)
check(not g.wrecks:open(p,'CaptainsCache'),'Submerged chest opening rejected')
g:stopSuction(p);g.ocean.level=-34
local deadline=os.clock()+10;while math.abs(g.ocean.applied+34)>.01 and os.clock()<deadline do task.wait(.1) end
check(math.abs(g.ocean.applied+34)<.01,'Real water lowered to the wreck')
local ship=workspace.UnderwaterTerrain.PointsOfInterest.TheMarigoldWreck;local cf=ship:GetPivot()
p.Character:PivotTo(cf*CFrame.new(11,3,0));task.wait(.8);local human=p.Character.Humanoid
human:MoveTo((cf*CFrame.new(2,2.8,0)).Position);task.wait(3.5)
check((p.Character.HumanoidRootPart.Position-chest.root.Position).Magnitude<8.5 and human.Health>0,'Walk through broken hull into cargo hold')
data.Bag={CommonShell=E.capacity(data)};g:sendState(p)
local existing={};for token in g.loot.active do existing[token]=true end
local ok,_,amount=g.wrecks:open(p,'CaptainsCache')
check(ok and (amount==nil or amount==4),'Ship chest opens and drops four valuable resources')
check(not g.wrecks:open(p,'CaptainsCache'),'Same chest cannot be opened twice')
local records={};for token,record in g.loot.active do if not existing[token] and record.model:GetAttribute('BurstOrigin') then table.insert(records,{token=token,record=record}) end end
check(#records==4,'Chest rewards exist physically on the cargo floor')
local firstDrop=records[1];p.Character:PivotTo(CFrame.new(firstDrop.record.position+Vector3.new(0,3,0)));task.wait(.3)
check(not g.loot:collect(p,firstDrop.token) and g.loot.active[firstDrop.token]~=nil,'Full backpack leaves chest reward on the ground')
data.Bag={};local total=0
for _,drop in records do
 local value=C.LootById[drop.record.id].value;check(value>=600,'Chest loot is valuable: '..drop.record.id)
 p.Character:PivotTo(CFrame.new(drop.record.position+Vector3.new(0,3,0)));task.wait(.2)
 check(g.loot:collect(p,drop.token),'Collect chest reward once');total+=value
 check(not g.loot:collect(p,drop.token),'Duplicate chest pickup rejected')
end
p.Character:PivotTo(CFrame.new(40,11,26));task.wait(.5)
local coins=data.Coins;r=g:request(p,'SellAll')
check(r.ok and data.Coins-coins==total and total>=2400,'Sell actual wreck loot for a high exact value')
check(not g:request(p,'SellAll').ok,'Duplicate sale still rejected')
print('DEPTH_SERVER_COMPLETE',checks,'wreckValue',total,'nodes',#g.loot.nodes)
require(game.ServerStorage.SeaGameTests.EconomyProfiles)()
