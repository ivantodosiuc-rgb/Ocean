assert(not game:GetService('RunService'):IsRunning(),'Edit mode only')
workspace:SetAttribute('PolishPreviewLevel',nil)
workspace:SetAttribute('PolishTestChest',nil)
local lighting=game:GetService('Lighting')
lighting.ClockTime=10
lighting.EnvironmentSpecularScale=.15
workspace.Terrain.WaterReflectance=0
workspace.Terrain.WaterWaveSize=.025
workspace.Terrain.WaterTransparency=.12
workspace.Terrain.WaterColor=Color3.fromRGB(8,108,125)
local wet=workspace.Ocean.WetShoreRig:FindFirstChild('WetShore',true)
wet.Transparency=.02
print('POLISH_FINAL_LIGHTING',lighting.ClockTime,lighting.EnvironmentSpecularScale,wet.Transparency)
