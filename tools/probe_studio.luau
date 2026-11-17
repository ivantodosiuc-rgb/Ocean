local H=game:GetService("HttpService")
H.HttpEnabled=true
local result={place=game.Name,children={}}
for _,v in workspace:GetChildren() do table.insert(result.children,{name=v.Name,class=v.ClassName}) end
result.editableMesh=pcall(function() local m=game:GetService("AssetService"):CreateEditableMesh(); assert(m); m:Destroy() end)
result.createAsset=pcall(function() return game:GetService("AssetService").CreateAssetAsync end)
H:PostAsync("http://127.0.0.1:8766/probe.json",H:JSONEncode(result))
print("OCEAN_AUTHORING_CONNECTED")
