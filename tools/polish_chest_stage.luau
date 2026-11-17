local g=require(game.ServerScriptService.SeaGame.Game).current;local p=game.Players:GetPlayers()[1]
local cf=workspace.UnderwaterTerrain.PointsOfInterest.TheMarigoldWreck:GetPivot()
p.Character:PivotTo(cf*CFrame.new(11,3,0));task.wait(.4)
p.Character.Humanoid:MoveTo((cf*CFrame.new(1.5,2.8,0)).Position);task.wait(3.4)
assert((p.Character.HumanoidRootPart.Position-g.wrecks.chests.CaptainsCache.root.Position).Magnitude<8.5,'Wreck cargo entry blocked')
p.Character:PivotTo(cf*CFrame.new(-4,3,0));g.profiles:get(p).Bag={};g:sendState(p)
print('POLISH_WRECK_WALK_PASS')
