local H=game:GetService('HttpService');local result={folders={},meshes=0,parts=0,npcs={},scripts=0,waterLevel=workspace.Ocean:GetAttribute('WaterLevel'),editMode=game:GetService('RunService'):IsEdit()}
for _,name in {'StarterIsland','Buildings','Decorations','NPCs','Ocean','UnderwaterTerrain'} do result.folders[name]=workspace:FindFirstChild(name)~=nil end
for _,p in workspace:GetDescendants() do if p:IsA('MeshPart') then result.meshes+=1 end;if p:IsA('BasePart') then result.parts+=1 end end
for _,m in workspace.NPCs:GetChildren() do table.insert(result.npcs,m.Name) end
for _,s in {game.ServerScriptService,game.ReplicatedStorage,game.StarterPlayer,game.StarterGui} do for _,p in s:GetDescendants() do if p:IsA('LuaSourceContainer') then result.scripts+=1 end end end
local mats=workspace.Terrain:ReadVoxels(Region3.new(Vector3.new(300,-4,300),Vector3.new(304,0,304)),4);result.waterRestored=mats[1][1][1]==Enum.Material.Water
print('FINAL_VERIFICATION '..H:JSONEncode(result))
workspace.CurrentCamera.CameraType=Enum.CameraType.Custom;workspace.CurrentCamera.Focus=CFrame.new(0,1,36);workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(145,145,215),Vector3.new(0,1,36));workspace.CurrentCamera.FieldOfView=50;game:GetService('Selection'):Set({})
