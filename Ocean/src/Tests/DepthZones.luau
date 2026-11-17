--!nonstrict
return function()
 local P=game.ReplicatedStorage.SeaGame;local Z=require(P.Shared.DepthZones);local C=require(P.Shared.Config);local E=require(P.Shared.Economy)
 local passed=0;local function check(v,name) assert(v,'Depth system: '..name);passed+=1 end
 for i=1,5 do check(Z.index((i-1)*32)==i,'Exact zone boundary '..i);check(Z.index(i*32-.001)==i,'Fractional zone boundary '..i) end
 check(Z.index(999)==5 and Z.index(-1)==1,'Depth clamps')
 local expected={{'CommonShell','SpiralShell','Starfish','SmallCrabShell','OldBottle'},{'ColorfulShell','PearlShell','PinkPearl','CoralFragment','BlueStar'},{'GoldenCoinPile','CeramicJug','TreasureChest','Compass','BlackPearl'},{'GiantPearl','AncientRelic','CrystalCoral','RoyalCrown','AtlanteanTablet'},{'RoyalTreasureChest','AquamarineCluster','GoldenIdol','LegendaryPearl','CrystalHeart'}}
 for zone,ids in expected do for _,id in ids do check(C.LootById[id].minZone==zone,'Named resource gate '..id) end end
 local means={};local results={}
 for zone=1,5 do
  local counts={};local total=0;local highest=0;local random=Random.new(912+zone);local samples=8000
  for i=1,samples do
   local id=E.rollLoot(random,(zone-.5)*32);local item=C.LootById[id]
   assert(item and item.minZone<=zone and item.weight>0,'Forbidden zone loot')
   counts[item.rarity]=(counts[item.rarity]or 0)+1;total+=item.value;highest=math.max(highest,item.value)
  end
  for rarity,chance in Z.List[zone].weights do check(math.abs((counts[rarity]or 0)/samples-chance/100)<.022,'Rarity distribution '..zone..' '..rarity) end
  means[zone]=total/samples;results[zone]={mean=means[zone],highest=highest,counts=counts}
  check((counts.COMMON or 0)>samples*.3,'Cheap loot remains at depth '..zone)
  if zone>1 then check(means[zone]>means[zone-1],'Expected value rises at zone '..zone) end
  task.wait()
 end
 local a,b=Random.new(Z.Seed+7919),Random.new(Z.Seed+7919)
 for i=1,200 do assert(E.rollLoot(a,145)==E.rollLoot(b,145),'Seeded site reroll changed') end;check(true,'Deterministic site sequence')
 check(E.rollLoot(Random.new(1),0,99999)==nil,'Impossible pool never grants a cheap fallback')
 check(C.Capacities[1]==5 and C.Capacities[5]==20,'Bag compatibility')
 local sites=require(game.ServerScriptService.SeaGame.GroundSites);local last=math.huge;local distribution={0,0,0,0,0}
 for i=1,sites.count do local p,n=sites.get(i);assert(p.Y<=last+.001 and p.Y>C.Ocean.minimum and n.Y>.72,'Invalid ground site');last=p.Y;distribution[Z.index(-p.Y)]+=1 end
 for i=1,5 do check(distribution[i]>100,'Available unobstructed sites zone '..i) end
 check(C.Ocean.TotalOceanVolume==(C.Ocean.halfSize*2)^2*(C.Ocean.initial-C.Ocean.minimum),'Volume matches actual vertical ocean bounds')
 workspace:SetAttribute('DepthDistributionTest',game.HttpService:JSONEncode({results=results,sites=distribution}))
 return passed
end
