-- Play-only fixture; injects an in-memory store. No published/global progress is edited.
local g=require(game.ServerScriptService.SeaGame.Game).current
local C=require(game.ReplicatedStorage.SeaGame.Shared.Config).Ocean
local P=require(game.ServerScriptService.SeaGame.OceanProgress)
local player=game.Players:GetPlayers()[1]
for _,p in game.Players:GetPlayers() do g:stopSuction(p) end
g.ocean.progress:close()
local level=workspace:GetAttribute('PolishPreviewLevel') or -34
local remaining=C.TotalOceanVolume*(level-C.minimum)/(C.initial-C.minimum)
local values={[C.WorldKey..'_meta']={version=1,total=C.TotalOceanVolume,shards=C.ShardCount,initial=C.initial,minimum=C.minimum,halfSize=C.halfSize},[C.WorldKey..'_s14']={version=1,removed=C.TotalOceanVolume-remaining,sessions={}}}
local store={};function store:GetAsync(key)return values[key] end
function store:UpdateAsync(key,transform)local result=transform(values[key]);if result then values[key]=result end;return result end
local progress=P.new({store=store,id='PolishPreview_'..tostring(os.clock()),shard=3,noMessaging=true});progress:load();g.ocean.ready=false;g.ocean.progress=progress
local deadline=os.clock()+12;while (not g.ocean.ready or math.abs(g.ocean.applied-level)>.02) and os.clock()<deadline do task.wait(.1) end
assert(g.ocean.ready and math.abs(g.ocean.applied-level)<.02,'Physical water fixture failed')
if level<=-30 and level>-48 then player.Character:PivotTo(workspace.UnderwaterTerrain.PointsOfInterest.TheMarigoldWreck:GetPivot()*CFrame.new(11,3,0))
elseif level<=-48 then player.Character:PivotTo(CFrame.new(-124,-46,144))
else player.Character:PivotTo(CFrame.new(12,7,125)) end
print('POLISH_PREVIEW_READY',level,g.ocean:snapshot().OceanRemainingPercent)
