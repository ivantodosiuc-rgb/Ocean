--!strict
-- Pure conversions. Only the UI is allowed to round a percentage for display.
local Volume={}
function Volume.finite(value:any):boolean
 return type(value)=='number' and value==value and math.abs(value)<math.huge
end
function Volume.remaining(total:number,removed:number):number return math.clamp(total-removed,0,total) end
function Volume.percent(remaining:number,total:number):number return math.clamp(remaining/total*100,0,100) end
function Volume.level(remaining:number,total:number,initial:number,minimum:number):number
 return minimum+(initial-minimum)*math.clamp(remaining/total,0,1)
end
function Volume.atLevel(level:number,total:number,initial:number,minimum:number):number
 return math.clamp((level-minimum)/(initial-minimum),0,1)*total
end
function Volume.flow(power:number,base:number,maximum:number):number
 if not Volume.finite(power) or power<=0 then return 0 end
 return math.min(base*power,maximum)
end
return table.freeze(Volume)
