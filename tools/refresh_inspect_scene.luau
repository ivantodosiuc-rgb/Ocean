assert(game:GetService('RunService'):IsEdit(),'Edit mode required')
for _,p in workspace.Decorations:GetChildren() do if p.Name:find('Flower') or p.Name:find('Grass') then print('REFRESH_OLD_FLORA',p.Name,p.ClassName,p:IsA('BasePart') and tostring(p.Position) or '') end end
for _,m in workspace.NPCs:GetChildren() do for _,p in m:GetChildren() do print('REFRESH_OLD_NPC',m.Name,p.Name,p.ClassName,p:IsA('BasePart') and tostring(p.Transparency) or '') end end
for _,p in game:GetService('Lighting'):GetChildren() do print('REFRESH_OLD_FX',p.Name,p.ClassName) end
workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable;workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(80,80,115),Vector3.new(0,5,0));workspace.CurrentCamera.FieldOfView=55;game:GetService('Selection'):Set({})
