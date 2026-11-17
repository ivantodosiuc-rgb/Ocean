task.wait()
local rs=game:GetService('RunService');local samples={Idle={},Sipping={}};local start=os.clock()
local c=rs.RenderStepped:Connect(function(dt)
 local phase=workspace:GetAttribute('SurfacePerfPhase');local group=samples[phase]
 if group then table.insert(group,dt)end
end)
repeat task.wait(.3) until workspace:GetAttribute('SurfacePerfPhase')=='Done' or os.clock()-start>40
c:Disconnect();local result={}
for name,values in samples do
 table.sort(values);local total,stalls=0,0
 for _,v in values do total+=v;if v>.1 then stalls+=1 end end
 result[name]={frames=#values,averageMs=if #values>0 then total/#values*1000 else 0,p95Ms=values[math.max(1,math.ceil(#values*.95))] and values[math.max(1,math.ceil(#values*.95))]*1000 or 0,stallsOver100ms=stalls}
end
workspace:SetAttribute('SurfacePerformance',game.HttpService:JSONEncode(result));task.defer(function()script:Destroy()end)
