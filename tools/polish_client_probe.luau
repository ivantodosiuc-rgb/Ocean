local Players=game:GetService('Players');local RunService=game:GetService('RunService')
local ctl=require(game.ReplicatedStorage.SeaGame.Client.Controller).current
local wet=workspace.Ocean.WetShoreRig:FindFirstChild('WetShore',true)
local timeout=os.clock()+8;while not wet:GetAttribute('ShoreBoneCount') and os.clock()<timeout do task.wait(.1) end
assert(wet:GetAttribute('ShoreBoneCount')==240,'Wet ribbon deformation did not initialize')
local level=workspace.Ocean:GetAttribute('WaterLevel');local maximum=0;local range={math.huge,-math.huge};local points={};local count=0
for _,bone in wet:GetDescendants() do if bone:IsA('Bone') and bone.Name~='Root' then
 local pos=bone.TransformedWorldCFrame.Position
 local expected=level+(if bone.Name:find('Inner') then 1.1 else .10)+.075
 maximum=math.max(maximum,math.abs(pos.Y-expected));assert(pos.Y>level,'Wet band intersects water')
 table.insert(points,{pos.X,pos.Y,pos.Z});count+=1
 if #points==8 then print('POLISH_CONTOUR_POINTS',game.HttpService:JSONEncode({level=level,points=points}));table.clear(points) end
 range[1]=math.min(range[1],Vector2.new(pos.X,pos.Z).Magnitude);range[2]=math.max(range[2],Vector2.new(pos.X,pos.Z).Magnitude)
end end
assert(count==240 and maximum<.001,'Skinned contour did not reach its target')
print('POLISH_WET_BAKED_PASS',game.HttpService:JSONEncode({level=level,bones=count,maximumError=maximum,radius=range,updateSeconds=wet:GetAttribute('ContourUpdateSeconds')}))
local frames={};local connection=RunService.RenderStepped:Connect(function(dt)table.insert(frames,dt) end)
task.wait(8);connection:Disconnect();table.sort(frames);local sum=0;for _,dt in frames do sum+=dt end
print('POLISH_CLIENT_PERFORMANCE',game.HttpService:JSONEncode({frames=#frames,averageMs=sum/#frames*1000,p95Ms=frames[math.ceil(#frames*.95)]*1000,water=workspace.Ocean:GetAttribute('WaterLevel')}))
