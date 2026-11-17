--!strict
-- 3.2 studs = one gameplay metre. All depth gates are absolute below the initial sea.
local Zones={Seed=573215,StudsPerMetre=3.2,ZoneHeight=32}
Zones.Rarities={'COMMON','UNCOMMON','RARE','EPIC','LEGENDARY'}
Zones.List={
 {name='Shallow Shores',minimum=0,weights={COMMON=78,UNCOMMON=22,RARE=0,EPIC=0,LEGENDARY=0},color=Color3.fromRGB(238,208,149)},
 {name='Coral Gardens',minimum=32,weights={COMMON=55,UNCOMMON=32,RARE=13,EPIC=0,LEGENDARY=0},color=Color3.fromRGB(248,149,161)},
 {name='Sunken Treasures',minimum=64,weights={COMMON=48,UNCOMMON=32,RARE=16,EPIC=4,LEGENDARY=0},color=Color3.fromRGB(237,194,99)},
 {name='Ancient Reef',minimum=96,weights={COMMON=42,UNCOMMON=31,RARE=20,EPIC=7,LEGENDARY=0},color=Color3.fromRGB(165,163,226)},
 {name='Abyssal Treasures',minimum=128,weights={COMMON=36,UNCOMMON=30,RARE=23,EPIC=9.5,LEGENDARY=1.5},color=Color3.fromRGB(86,208,214)},
}
function Zones.index(depth:number):number return math.clamp(math.floor(math.max(0,depth)/Zones.ZoneHeight)+1,1,5) end
function Zones.roll(catalog,random,depth:number,minimumValue:number?):string?
 local zone=Zones.index(depth);local definition=Zones.List[zone];local minimum=minimumValue or 0
 local groups={};local totalRarity=0;local lastRarity=nil
 for _,rarity in Zones.Rarities do
  local items={};local weight=0
  for _,item in catalog do
   if item.weight>0 and item.rarity==rarity and (item.minZone or 1)<=zone and item.value>=minimum then
    -- Favour the zone's own finds without removing inexpensive earlier discoveries.
    local w=item.weight*(if item.minZone==zone then 2.5 else 1)
    weight+=w;table.insert(items,{item=item,weight=w})
   end
  end
  local chance=definition.weights[rarity]
  if weight>0 and chance>0 then groups[rarity]={items=items,total=weight};totalRarity+=chance;lastRarity=rarity end
 end
 if totalRarity<=0 then return nil end
 local pick=random:NextNumber()*totalRarity;local chosen=lastRarity
 for _,rarity in Zones.Rarities do if groups[rarity] then pick-=definition.weights[rarity];if pick<=0 then chosen=rarity;break end end end
 local group=groups[chosen];local roll=random:NextNumber()*group.total
 for _,entry in group.items do roll-=entry.weight;if roll<=0 then return entry.item.id end end
 return group.items[#group.items].item.id
end
return table.freeze(Zones)
