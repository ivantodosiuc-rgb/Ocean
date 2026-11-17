assert(game:GetService('RunService'):IsStudio() and game.GameId==0,'Session-only test')
local g=require(game.ServerScriptService.SeaGame.Game).current
local S=game.ReplicatedStorage.SeaGame.Shared;local C=require(S.Config);local E=require(S.Economy);local N=require(S.Needs)
local p=game.Players:GetPlayers()[1];local d=g.profiles:get(p);local saved=E.copy(d);local oldCF=p.Character:GetPivot();local checks={}
local function check(ok,name) assert(ok,name);table.insert(checks,name) end
local ok,err=xpcall(function()
 g:stopSuction(p);d.NeedsWater=0;d.Coins=5000000;d.Owned={BasicStraw=true};d.Equipped='BasicStraw';d.Upgrades={Power=0,Speed=0,Walk=0,Backpack=0}
 p.Character:PivotTo(CFrame.new(-39,10,-9));task.wait(.3)
 for i,item in C.Straws do
  if i>1 then
   task.wait(.3);local before=d.Coins;local result=g:request(p,'BuyStraw',item.id)
   check(result.ok and before-d.Coins==item.price and d.Equipped==item.id,'Buy and equip '..item.id)
   check(p.Character:FindFirstChildOfClass('Tool'):GetAttribute('SeaStraw')==item.id,'Physical model '..item.id)
  end
 end
 task.wait(.3);local balance=d.Coins;check(not g:request(p,'BuyStraw','PrismStraw').ok and d.Coins==balance,'Premium preview remote cannot grant ownership')
 p.Character:PivotTo(CFrame.new(7,7,118));task.wait(.3);check(not g:request(p,'BuyStraw','GoldenStraw').ok,'Shop requires actual proximity')
 d.NeedsWater=N.Capacity;g.restroom:send(p)
 check(not g:validTarget(p,Vector3.new(10,g.ocean.applied,112.8)),'Full need blocks real suction')
 local used=g:request(p,'UseRestroom');check(not used.ok and d.NeedsWater==N.Capacity,'Remote restroom use from ocean rejected')
 p.Character:PivotTo(workspace.Buildings.BeachRestroom.Exit.CFrame);task.wait(.3)
 local before=d.NeedsWater;local result=g:request(p,'UseRestroom');check(result.ok and p.Character.HumanoidRootPart.Anchored,'Toilet begins with movement locked')
 check(not g:request(p,'ToggleHeld').ok,'Tool switch cannot interrupt restroom state')
 task.wait(.6);g.restroom:finish(p,false)
 check(d.NeedsWater==before and not p.Character.HumanoidRootPart.Anchored and not g.restroom.occupant,'Interrupted use retains need and releases occupant')
 task.wait(.3);p.Character:PivotTo(workspace.Buildings.BeachRestroom.Exit.CFrame)
 check(g:request(p,'UseRestroom').ok,'Restroom can be used after interruption')
 task.wait(C.Restroom.UseSeconds+.3)
 check(d.NeedsWater==0 and not g.restroom.occupant and not p.Character.HumanoidRootPart.Anchored,'Completed use resets need and restores movement')
 check(p.Character:FindFirstChildOfClass('Tool')~=nil,'Equipped tool restored after restroom')
end,debug.traceback)
g.restroom:finish(p,false);g:stopSuction(p)
for k in d do d[k]=nil end;for k,v in saved do d[k]=v end;d.Revision+=100
if p.Character then p.Character:PivotTo(oldCF);g:equipTool(p) end;g:sendState(p)
workspace:SetAttribute('ComfortLiveTests',game.HttpService:JSONEncode({ok=ok,error=if ok then nil else err,checks=checks,count=#checks}))
script:Destroy()
