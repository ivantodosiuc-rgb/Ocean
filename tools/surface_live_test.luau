task.wait()
local checks={};local metrics={};local g=require(game.ServerScriptService.SeaGame.Game).current
local p=game.Players:GetPlayers()[1];local E=require(game.ReplicatedStorage.SeaGame.Shared.Economy);local C=require(game.ReplicatedStorage.SeaGame.Shared.Config)
local function check(ok,name) assert(ok,name);table.insert(checks,name) end
local ok,err=xpcall(function()
 check(game.GameId==0 and game:GetService('RunService'):IsStudio(),'Session-only verification')
 check(p.Character.Humanoid.Health>0 and p.Character.HumanoidRootPart.Position.Y>7,'Player spawns on the island')
 check(g.loot.ready and #g.loot.nodes>5800,'Visible-ground sites load successfully')
 metrics.lootSites=#g.loot.nodes
 local last=math.huge
 for _,n in g.loot.nodes do check(n.position.Y<=last+.0001,'sorted site');last=n.position.Y end
 -- Keep the report compact; the per-node assertions above still run.
 while #checks>4 do table.remove(checks)end
 for _,m in game.ReplicatedStorage.SeaGame.Assets.Loot:GetChildren()do local a=m:FindFirstChildWhichIsA('SurfaceAppearance',true);check(a~=nil,'Textured resource '..m.Name)end
 local d=g.profiles:get(p);d.Bag={};d.NeedsWater=0;g:stopSuction(p)
 p.Character:PivotTo(CFrame.new(7,7,118));task.wait(1.5)
 check(p.Character.Humanoid.Health>0 and p.Character.HumanoidRootPart.Position.Y>4,'Pier supports the player')
 workspace:SetAttribute('SurfacePerfPhase','Idle');task.wait(5)
 local before=g.ocean.progress.remaining-g.ocean.progress.pending;local need=d.NeedsWater
 check(g:validTarget(p,Vector3.new(10,g.ocean.applied,112.8)),'Real water target remains usable')
 workspace:SetAttribute('SurfacePerfPhase','Sipping')
 for _=1,32 do g:suctionPulse(p,Vector3.new(10,g.ocean.applied,112.8));task.wait(.25)end
 g:stopSuction(p);workspace:SetAttribute('SurfacePerfPhase','After');task.wait(.3)
 local removed=before-(g.ocean.progress.remaining-g.ocean.progress.pending);metrics.removedVolume=removed;metrics.personalNeed=d.NeedsWater-need
 check(removed>1000,'Real server water removal works')
 check(math.abs(removed-(d.NeedsWater-need))<.03,'Personal WC volume still matches actual removal')
 local token,record
 for t,r in g.loot.active do if r.id=='StarterMussel' then token=t;record=r;break end end
 check(record~=nil,'Starter mussels spawn')
 p.Character:PivotTo(CFrame.new(record.position+Vector3.new(0,3,0)));task.wait(.4)
 check(g.loot:collect(p,token),'Grounded mussel can be collected')
 check(not g.loot:collect(p,token),'Duplicate pickup remains blocked')
 p.Character:PivotTo(CFrame.new(40,11,26));task.wait(.5);local coins=d.Coins;local sold=g:request(p,'SellAll')
 check(sold.ok and d.Coins-coins==1,'Starter mussel still sells for exactly 1 coin')
 g:sendState(p)
end,debug.traceback)
workspace:SetAttribute('SurfaceLiveTest',game.HttpService:JSONEncode({pass=ok,error=if ok then nil else tostring(err),checks=checks,metrics=metrics}))
workspace:SetAttribute('SurfacePerfPhase','Done');task.defer(function()script:Destroy()end)
