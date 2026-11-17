--!strict
local Config=require(script.Parent.Config)
local DepthZones=require(script.Parent.DepthZones)
local Economy={}
local function integer(value:any,default:number,maximum:number):number
 if type(value)~='number' or value~=value or value==math.huge or value==-math.huge then return default end
 return math.clamp(math.floor(value),0,maximum)
end
function Economy.new()
 return {Version=Config.Version,Coins=0,Owned={BasicStraw=true},Equipped='BasicStraw',Upgrades={Power=0,Speed=0,Walk=0,Backpack=0},Bag={},Revision=0,NeedsWater=0,Receipts={}}
end
function Economy.capacity(data):number return Config.Capacities[data.Upgrades.Backpack+1] end
function Economy.count(data):number local n=0;for id,count in data.Bag do if Config.LootById[id] then n+=count end end;return n end
function Economy.value(data):number local n=0;for id,count in data.Bag do local item=Config.LootById[id];if item then n+=item.value*count end end;return n end
function Economy.normalize(raw:any)
 local data=Economy.new();if type(raw)~='table' then return data end
 data.Coins=integer(raw.Coins,0,1e12);data.Revision=integer(raw.Revision,0,1e12)
 if type(raw.Receipts)=='table' then for id,paid in raw.Receipts do if type(id)=='string' and #id<=150 and paid==true then data.Receipts[id]=true end end end
 if type(raw.NeedsWater)=='number' and raw.NeedsWater==raw.NeedsWater and math.abs(raw.NeedsWater)<math.huge then data.NeedsWater=math.clamp(raw.NeedsWater,0,Config.Ocean.TotalOceanVolume*Config.Restroom.PersonalOceanFraction) end
 if type(raw.Owned)=='table' then for id,value in raw.Owned do if Config.StrawById[id] and value==true then data.Owned[id]=true end end end
 if type(raw.Equipped)=='string' and data.Owned[raw.Equipped] then data.Equipped=raw.Equipped end
 if type(raw.Upgrades)=='table' then for _,u in Config.Upgrades do data.Upgrades[u.id]=integer(raw.Upgrades[u.id],0,u.max) end end
 local remaining=20
 if type(raw.Bag)=='table' then for _,item in Config.Loot do local count=integer(raw.Bag[item.id],0,remaining);if count>0 then data.Bag[item.id]=count;remaining-=count end end end
 while Economy.count(data)>Economy.capacity(data) and data.Upgrades.Backpack<4 do data.Upgrades.Backpack+=1 end
 return data
end
function Economy.copy(data)
 return {Version=Config.Version,Coins=data.Coins,Owned=table.clone(data.Owned),Equipped=data.Equipped,Upgrades=table.clone(data.Upgrades),Bag=table.clone(data.Bag),Revision=data.Revision,NeedsWater=data.NeedsWater,Receipts=table.clone(data.Receipts or {})}
end
function Economy.stats(data)
 local straw=Config.StrawById[data.Equipped]
 return {power=straw.power*(1+data.Upgrades.Power*.2),speed=straw.speed*(1+data.Upgrades.Speed*.1),reach=straw.reach,walk=Config.WalkSpeeds[data.Upgrades.Walk+1],capacity=Economy.capacity(data)}
end
function Economy.upgradeCost(data,id:string):number?
 local def=Config.UpgradeById[id];if not def then return nil end
 local level=data.Upgrades[id];if level>=def.max then return nil end
 if id=='Backpack' then return Config.BackpackPrices[level+1] end
 if id=='Walk' then return Config.WalkPrices[level+1] end
 return math.floor((if id=='Power' then 100 else 125)*(if id=='Power' then 1.65 else 1.7)^level)
end
function Economy.buyStraw(data,id:string)
 local item=Config.StrawById[id];if not item then return false,'Unknown straw.' end
 if item.premium then return false,'This straw is a Robux pass.' end
 if data.Owned[id] then return false,'You already own this straw.' end
 if data.Coins<item.price then return false,'Not enough Coins.' end
 data.Coins-=item.price;data.Owned[id]=true;data.Equipped=id;data.Revision+=1
 return true,'New straw equipped!',item.price
end
function Economy.equip(data,id:string)
 if not Config.StrawById[id] or not data.Owned[id] then return false,'You do not own this straw.' end
 if data.Equipped==id then return false,'Already equipped.' end
 data.Equipped=id;data.Revision+=1;return true,'Straw equipped!'
end
function Economy.upgrade(data,id:string)
 if not Config.UpgradeById[id] then return false,'Unknown upgrade.' end
 local price=Economy.upgradeCost(data,id);if not price then return false,'Fully upgraded!' end
 if data.Coins<price then return false,'Not enough Coins.' end
 data.Coins-=price;data.Upgrades[id]+=1;data.Revision+=1;return true,'Upgrade complete!',price
end
function Economy.addLoot(data,id:string)
 if not Config.LootById[id] then return false,'Unknown treasure.' end
 if Economy.count(data)>=Economy.capacity(data) then return false,'BACKPACK FULL!' end
 data.Bag[id]=(data.Bag[id] or 0)+1;data.Revision+=1;return true
end
function Economy.sell(data)
 local total=Economy.value(data);if total<=0 then return false,'Your backpack is empty.',0 end
 data.Bag={};data.Coins+=total;data.Revision+=1;return true,'Treasure sold!',total
end
function Economy.rollLoot(random,depth:number?,minimumValue:number?)
 return DepthZones.roll(Config.Loot,random,depth or 168,minimumValue)
end
return Economy
