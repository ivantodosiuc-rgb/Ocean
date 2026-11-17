local p=game.Players.LocalPlayer;local ctl=require(game.ReplicatedStorage.SeaGame.Client.Controller).current;ctl:stop();ctl.ui:close();local char=p.Character
char:PivotTo(CFrame.lookAt(Vector3.new(21,11,-29),Vector3.new(26,10,-41)));task.wait(.6)
local r=game.ReplicatedStorage.SeaGame.Remotes.Request
local walk=r:InvokeServer('Upgrade','Walk');assert(walk.ok and walk.state.stats.walk==18 and char.Humanoid.WalkSpeed==18);task.wait(.4)
local bag=r:InvokeServer('Upgrade','Backpack');assert(bag.ok and bag.state.capacity==7);print('STEP3_LOOP_PASS','Live walk speed and backpack upgrades apply')
local prompt=workspace.NPCs.Maya.HumanoidRootPart.ShopInteraction.Shop_Upgrades;prompt:InputHoldBegin();task.wait(.1);prompt:InputHoldEnd()
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(7,18,-14),Vector3.new(26,9,-39));print('STEP3_VISUAL_UPGRADES_READY')
