local RunService=game:GetService('RunService')
local chest=workspace.UnderwaterTerrain.PointsOfInterest.TidekeepersCache
local cf=chest:GetPivot();local camera=workspace.CurrentCamera
camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=52
camera.CFrame=CFrame.lookAt(chest.ChestRoot.Position+Vector3.new(12,13,17),chest.ChestRoot.Position+Vector3.new(0,1,0))
game.Players.LocalPlayer.Character:PivotTo(CFrame.new(chest.ChestRoot.Position+Vector3.new(3,3,4)))
task.wait(2)
local result=game.ReplicatedStorage.SeaGame.Remotes.Request:InvokeServer('OpenChest','TidekeepersCache');assert(result.ok,'Rare chest failed to open')
task.wait(.75)
local effect=assert(workspace.LocalSeaEffects:FindFirstChild('ChestRewardLight'),'Rare chest reward effect missing')
local beams=0;for _,o in effect:GetChildren() do if o:IsA('Beam') then beams+=1 end end
assert(beams==5,'Rare chest should have five reward rays')
assert(effect.PointLight.Range==12,'Rare glow missing')
task.wait(2.4)
assert(not effect.Parent,'Rare effects leaked')
print('POLISH_RARE_CHEST_PASS',beams,'rays, rare glow, cleanup')
