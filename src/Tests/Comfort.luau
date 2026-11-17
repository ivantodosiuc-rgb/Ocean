--!nonstrict
return function()
 local S=game.ReplicatedStorage.SeaGame.Shared;local C=require(S.Config);local E=require(S.Economy);local N=require(S.Needs)
 local passed=0;local function check(ok,name) assert(ok,name);passed+=1;print('COMFORT_PASS',name) end
 check(#C.Straws==10,'Ten ordinary straws')
 local data=E.new();check(E.stats(data).power*C.Ocean.BaseRemovalRate==250,'Starter is 25 percent faster')
 data.Coins=10000000
 for i,s in C.Straws do
  if i>1 then local before=data.Coins;check(E.buyStraw(data,s.id) and data.Coins==before-s.price,'Buy '..s.id) end
  check(E.stats(data).reach==s.reach and E.stats(data).speed==s.speed,'Real characteristics '..s.id)
 end
 local p=C.PremiumStraw;local sixth=C.Straws[6]
 check(p.robux==79 and p.power==sixth.power and p.speed==sixth.speed and p.reach==sixth.reach,'Prism matches tier six')
 check(not E.buyStraw(data,p.id) and not E.equip(data,p.id),'Preview cannot be acquired through coin remotes')
 check(N.percent(C.Ocean.TotalOceanVolume*.01)==20 and N.percent(C.Ocean.TotalOceanVolume*.05)==100,'Five personal percent fills the meter')
 local a,b=N.share(100,1,4),N.share(100,3,4)
 check(a==25 and b==75 and a+b==100,'Accepted water attributed once proportionally')
 check(N.share(0,100,100)==0,'No credit for rejected water or other servers')
 check(N.availablePower(N.Capacity,200,.1)==0,'Full meter blocks suction')
 check(math.abs(N.availablePower(N.Capacity-5,200,.1)*.1*C.Ocean.BaseRemovalRate-5)<.00001,'Threshold limits removal without overshoot')
 data.NeedsWater=12345.678901234;local saved=E.normalize(E.copy(data));check(saved.NeedsWater==data.NeedsWater,'Fractional need survives profile serialization')
 check(E.normalize({NeedsWater=0/0}).NeedsWater==0 and E.normalize({NeedsWater=math.huge}).NeedsWater==0,'Invalid need values rejected')
 local bag=E.new();check(E.addLoot(bag,'StarterMussel'),'Starter mussel collectible');local ok,_,amount=E.sell(bag);check(ok and amount==1 and bag.Coins==1,'Mussel sells for exactly one coin')
 local Profiles=require(game.ServerScriptService.SeaGame.Profiles);local store={values={}}
 function store:UpdateAsync(key,fn) local value=fn(self.values[key]);if value then self.values[key]=game.HttpService:JSONDecode(game.HttpService:JSONEncode(value)) end;return self.values[key] end
 local player={UserId=9876123,Parent=true};local first=Profiles.new(nil,store);first:load(player).NeedsWater=12345.678901234;first:release(player)
 local second=Profiles.new(nil,store);check(second:load(player).NeedsWater==12345.678901234,'Need survives mock leave and rejoin');second:release(player)
 return passed
end
