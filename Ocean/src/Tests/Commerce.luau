--!nonstrict
return function()
 local Shared=game.ReplicatedStorage.SeaGame.Shared;local Config=require(Shared.Config);local E=require(Shared.Economy);local Offers=require(Shared.Offers)
 local Profiles=require(game.ServerScriptService.SeaGame.Profiles);local Commerce=require(game.ServerScriptService.SeaGame.Commerce)
 local passed=0;local function check(ok,name) assert(ok,name);passed+=1;print('COMMERCE_PASS',name) end
 check(Offers[1].coins==500 and Offers[1].robux==39,'500 / 39 offer')
 check(Offers[2].coins==1000 and Offers[2].robux==89,'1000 / 89 offer')
 check(Offers[3].coins==1500 and Offers[3].robux==149,'1500 / 149 offer')
 check(Offers[4].coins==5000 and Offers[4].robux==1999 and Offers[4].straw=='AdminStraw','Admin bundle / 1999')
 local data=E.new();data.Coins=1e9
 check(not E.buyStraw(data,'AdminStraw') and not data.Owned.AdminStraw,'Coins cannot buy Admin')
 check(not E.buyStraw(data,'PrismStraw') and not data.Owned.PrismStraw,'Coins cannot buy Prism')
 check(not E.equip(data,'AdminStraw'),'Unowned special cannot equip')
 data.Owned.AdminStraw=true;check(E.equip(data,'AdminStraw'),'Owned special can equip')
 data.Upgrades.Power=15;data.Upgrades.Speed=15;local a=E.stats(data);data.Equipped='Leviathan';local b=E.stats(data)
 check(a.power*a.speed>b.power*b.speed,'Admin stronger at max upgrades')
 check(a.power*a.speed*Config.Ocean.BaseRemovalRate<Config.Ocean.MaxRemovalRate,'Admin upgrades remain below cap')
 local store={values={},fail=false}
 local function copy(v) return game.HttpService:JSONDecode(game.HttpService:JSONEncode(v)) end
 function store:UpdateAsync(key,fn)
  if self.fail then error('Intentional offline fixture') end
  local value=fn(copy(self.values[key] or {}));if value==nil then return nil end
  self.values[key]=copy(value);return copy(value)
 end
 local player=game.Players:GetPlayers()[1];assert(player,'Run commerce tests in Play')
 local profiles=Profiles.new(nil,store);profiles:load(player)
 local fake={profiles=profiles,remotes={FX={FireClient=function() end}},sendState=function() end}
 local market={owns=false,prompts=0}
 function market:UserOwnsGamePassAsync() return self.owns end
 function market:PromptProductPurchase() self.prompts+=1 end
 function market:PromptGamePassPurchase() self.prompts+=1 end
 local c=Commerce.new(fake,market);c.products[90901]=Offers[1]
 local receipt={ProductId=90901,PlayerId=player.UserId,PurchaseId='test-one'}
 check(c:receipt(receipt)==Enum.ProductPurchaseDecision.PurchaseGranted,'Persisted receipt acknowledged')
 check(profiles:get(player).Coins==500 and store.values['u_'..player.UserId].Data.Coins==500,'Coins durable before acknowledgement')
 check(c:receipt(receipt)==Enum.ProductPurchaseDecision.PurchaseGranted and profiles:get(player).Coins==500,'Duplicate receipt gives no extra coins')
 check(c:receipt({ProductId=99999,PlayerId=player.UserId,PurchaseId='unknown'})==Enum.ProductPurchaseDecision.NotProcessedYet,'Unknown product remains pending')
 check(c:receipt({ProductId=90901,PlayerId=-999,PurchaseId='absent'})==Enum.ProductPurchaseDecision.NotProcessedYet,'Absent player remains pending')
 local ok=c:prompt(player,'Coins500');check(not ok and market.prompts==0,'Unconfigured checkout cannot charge')
 check(not c:prompt(player,{}),'Invalid offer payload rejected')
 local pass={assetId=90902,coins=5000,straw='AdminStraw',name='Admin'}
 check(not c:reconcilePass(player,pass) and not profiles:get(player).Owned.AdminStraw,'Unverified pass grants nothing')
 market.owns=true;check(c:reconcilePass(player,pass),'Verified pass grants bundle')
 check(profiles:get(player).Coins==5500 and profiles:get(player).Owned.AdminStraw,'Bundle includes exact coins and entitlement')
 check(c:reconcilePass(player,pass) and profiles:get(player).Coins==5500,'Pass bonus awarded once')
 profiles:release(player);local resumed=Profiles.new(nil,store);resumed:load(player)
 check(resumed:get(player).Owned.AdminStraw and resumed:get(player).Coins==5500,'Bundle survives mock rejoin')
 c.game.profiles=resumed
 check(c:receipt(receipt)==Enum.ProductPurchaseDecision.PurchaseGranted and resumed:get(player).Coins==5500,'Receipt stays idempotent after rejoin')
 local normalized=E.normalize(E.copy(resumed:get(player)));check(normalized.Receipts['product:test-one'] and normalized.Owned.AdminStraw,'Receipt and entitlement survive normalization')
 local clone=E.copy(normalized);clone.Receipts['product:test-one']=nil;check(normalized.Receipts['product:test-one'],'Receipt snapshot is independent')
 -- Failed and ambiguous saves never acknowledge or double-credit on retry.
 store.fail=true;receipt.PurchaseId='test-offline'
 check(c:receipt(receipt)==Enum.ProductPurchaseDecision.NotProcessedYet,'Offline store leaves receipt pending')
 local pending=resumed:get(player).Coins;check(pending==6000,'Pending award applied once in current session')
 store.fail=false
 check(c:receipt(receipt)==Enum.ProductPurchaseDecision.PurchaseGranted and resumed:get(player).Coins==pending,'Retry persists without duplicate award')
 check(store.values['u_'..player.UserId].Data.Receipts['product:test-offline'],'Retry commits receipt marker with coins')
 resumed:release(player)
 local ephemeral=Profiles.new();ephemeral.store=nil;ephemeral:load(player)
 check(not ephemeral:grantPurchase(player,'no-save',500,nil),'Ephemeral profile cannot acknowledge purchases')
 check(ephemeral:get(player).Coins==0,'No unsaved coin award in unpublished experience')
 return passed
end
