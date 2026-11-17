local g=require(game.ServerScriptService.SeaGame.Game).current;local p=game.Players:GetPlayers()[1]
g:stopSuction(p);g.loot:restart();g.wrecks:restart();g.ocean.level=-34
local deadline=os.clock()+10;while math.abs(g.ocean.applied+34)>.001 and os.clock()<deadline do task.wait(.1) end
assert(g.ocean.applied==-34)
p.Character:PivotTo(workspace.UnderwaterTerrain.PointsOfInterest.TheMarigoldWreck:GetPivot()*CFrame.new(-4,3,0))
print('DEPTH_PREVIEW_READY')
