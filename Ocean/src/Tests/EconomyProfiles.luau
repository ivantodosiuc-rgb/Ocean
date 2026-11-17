--!nonstrict
return function()
 local Package=game.ReplicatedStorage.SeaGame;local E=require(Package.Shared.Economy);local C=require(Package.Shared.Config);local Profiles=require(game.ServerScriptService.SeaGame.Profiles)
 local passed=0
 local function check(condition,name) assert(condition,'FAILED: '..name);passed+=1;print('STEP3_TEST_PASS',name) end
 local d=E.new();check(d.Coins==0 and E.capacity(d)==5 and d.Owned.BasicStraw,'New player defaults')
 check(not E.buyStraw(d,'OceanVacuum') and d.Coins==0,'Insufficient funds never subtract')
 check(not E.buyStraw(d,'invalid') and not E.equip(d,'GoldenStraw'),'Unknown and unowned equipment rejected')
 for _=1,5 do check(E.addLoot(d,'CommonShell'),'Collect into free slot') end
 check(not E.addLoot(d,'AncientRelic') and E.count(d)==5,'Full backpack rejects extra loot')
 local ok,_,value=E.sell(d);check(ok and value==50 and d.Coins==50 and E.count(d)==0,'Sale has exact authoritative value')
 check(not E.sell(d) and d.Coins==50,'Duplicate sale awards zero')
 d.Coins=150;check(E.buyStraw(d,'ColorfulStraw') and d.Coins==0 and d.Equipped=='ColorfulStraw','Buy equips and charges once')
 check(not E.buyStraw(d,'ColorfulStraw') and d.Coins==0,'Duplicate purchase rejected')
 d.Coins=1e6
 for i,capacity in {7,10,15,20} do local before=d.Coins;check(E.upgrade(d,'Backpack') and E.capacity(d)==capacity and before-d.Coins==C.BackpackPrices[i],'Backpack tier '..i) end
 check(not E.upgrade(d,'Backpack'),'Backpack maximum enforced')
 for i,speed in {18,20,23,26,30} do check(E.upgrade(d,'Walk') and E.stats(d).walk==speed,'Walk tier '..i) end
 E.upgrade(d,'Power');E.upgrade(d,'Speed');check(math.abs(E.stats(d).power-2.4)<.0001 and math.abs(E.stats(d).speed-1.155)<.000001,'Power and speed modifiers')
 local strongest=C.Straws[#C.Straws]
 check(C.Ocean.MaxRemovalRate>strongest.power*strongest.speed*(1+.2*15)*(1+.1*15)*C.Ocean.BaseRemovalRate,'Strongest straw and all single-player upgrades retain their full effect')
 local bad=E.normalize({Coins=-900,Owned={Unknown=true},Equipped='Unknown',Upgrades={Walk=999,Backpack=-10},Bag={AncientRelic=3,CommonShell=-1,Invalid=500}})
 check(bad.Coins==0 and bad.Equipped=='BasicStraw' and bad.Upgrades.Walk==5 and E.count(bad)==3,'Corrupt profile normalized safely')
 local nan=E.normalize({Coins=0/0,Bag={CommonShell=math.huge},Upgrades={Power=0/0}});check(nan.Coins==0 and E.count(nan)==0 and nan.Upgrades.Power==0,'NaN and infinity rejected')
 local copy=E.copy(d);copy.Owned.Test=true;copy.Upgrades.Power=999;check(not d.Owned.Test and d.Upgrades.Power==1,'Save snapshot is independent')
 local rng=Random.new(128)
 check(#C.Loot==58,'Existing fifty-one resources plus seven expedition finds')
 for _=1,1000 do local id=E.rollLoot(rng,0);assert((C.LootById[id].minDepth or 0)==0,'Deep item appeared at the surface') end
 check(true,'Shallow loot respects depth gates')
 for _=1,1000 do local id=E.rollLoot(rng,80,600);assert(C.LootById[id].value>=600 and C.LootById[id].minDepth<=80,'Chest reward outside its pool') end
 check(true,'Wreck chest guarantees valuable loot')
 local http=game.HttpService;local store={values={},failures=0,calls=0}
 function store:UpdateAsync(key,transform)
  self.calls+=1;if self.failures>0 then self.failures-=1;error('Simulated temporary DataStore outage') end
  local old=self.values[key];if old then old=http:JSONDecode(http:JSONEncode(old)) end
  local value=transform(old);if value then self.values[key]=http:JSONDecode(http:JSONEncode(value));return self.values[key] end;return nil
 end
 local player={UserId=987654321,Parent=true};local a=Profiles.new(nil,store);local profile=a:load(player)
 profile.Coins=4321;profile.Owned.GoldenStraw=true;profile.Equipped='GoldenStraw';profile.Upgrades.Backpack=3;profile.Bag.PearlShell=2;profile.Revision+=1
 check(a:save(player,false),'DataStore save through UpdateAsync')
 check(store.values.u_987654321.Session.Token==a.session,'Session lock retained during save')
 a:release(player);check(store.values.u_987654321.Session==nil,'Leave releases session lock')
 local b=Profiles.new(nil,store);local restored=b:load(player)
 check(restored.Coins==4321 and restored.Equipped=='GoldenStraw' and restored.Owned.GoldenStraw and restored.Upgrades.Backpack==3 and restored.Bag.PearlShell==2,'Rejoin restores every requested field')
 store.failures=1;restored.Coins=4322;check(b:save(player,false) and store.values.u_987654321.Data.Coins==4322,'Transient save failure retries successfully')
 store.values.u_987654321.Session.Token='another-server';local before=store.values.u_987654321.Data.Coins;restored.Coins=9000
 check(not b:save(player,false) and store.values.u_987654321.Data.Coins==before,'Lost session ownership never overwrites another server')
 print('STEP3_UNIT_COMPLETE',passed)
 return passed
end
