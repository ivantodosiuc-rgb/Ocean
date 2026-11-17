local list={}
for _,v in workspace:GetDescendants() do
 if v:IsA('MeshPart') then table.insert(list,{name=v.Name,size=tostring(v.Size),position=tostring(v.Position),mesh=v.MeshId,texture=v.TextureID,anchored=v.Anchored}) end
end
print('OCEAN_IMPORTED '..game:GetService('HttpService'):JSONEncode(list))
print('OCEAN_ROOTS')
for _,v in workspace:GetChildren() do print(v.Name,v.ClassName) end
