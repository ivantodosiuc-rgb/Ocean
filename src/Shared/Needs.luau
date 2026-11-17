--!strict
local Config=require(script.Parent.Config)
local Needs={}
Needs.Capacity=Config.Ocean.TotalOceanVolume*Config.Restroom.PersonalOceanFraction
function Needs.percent(volume:number):number return math.clamp(volume/Needs.Capacity*100,0,100) end
function Needs.availablePower(volume:number,desired:number,dt:number):number
 return math.min(desired,math.max(0,Needs.Capacity-volume)/(Config.Ocean.BaseRemovalRate*math.max(.000001,math.min(dt,.25))))
end
-- Attribute only locally accepted water, including the shared rate/remaining-volume caps.
function Needs.share(consumed:number,contribution:number,totalPower:number):number
 if totalPower<=0 then return 0 end
 return math.max(0,consumed)*contribution/totalPower
end
return table.freeze(Needs)
