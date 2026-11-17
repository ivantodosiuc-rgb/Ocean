assert(not game:GetService('RunService'):IsRunning(),'Edit only')
local ReplicatedStorage=game:GetService('ReplicatedStorage')
local function folder(parent,name) local f=parent:FindFirstChild(name);if not f then f=Instance.new('Folder');f.Name=name;f.Parent=parent end;return f end
local package=folder(ReplicatedStorage,'SeaGame');local assets=folder(package,'Assets')
local categories={Tool=folder(assets,'Tools'),Loot=folder(assets,'Loot'),Icon=folder(assets,'Icons')}
local imported=assert(workspace:FindFirstChild('SuckTheSea_Gameplay'),'Missing native FBX import')
imported:PivotTo(CFrame.Angles(0,math.pi,0)*imported:GetPivot())
local count=0
for _,p in imported:GetDescendants() do if p:IsA('MeshPart') then
 local category,id=p.Name:match('^(%a+)__(.+)$');assert(categories[category],p.Name)
 local previous=categories[category]:FindFirstChild(id);if previous then previous:Destroy() end
 local model=Instance.new('Model');model.Name=id;p.Name='Visual';p.Color=Color3.new(1,1,1);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=true;p.RenderFidelity=Enum.RenderFidelity.Automatic;p.Parent=model;model.WorldPivot=CFrame.new();model.Parent=categories[category];count+=1
end end
assert(count==18,'Expected 18 assets, got '..count);imported:Destroy()
-- This single pier ladder makes the exposed sea floor accessible at every tide level.
local old=workspace.Ocean:FindFirstChild('ReturnLadder');if old then old:Destroy() end
local ladder=Instance.new('TrussPart');ladder.Name='ReturnLadder';ladder.Size=Vector3.new(2,42,2);ladder.CFrame=CFrame.new(14.1,-17,125);ladder.Color=Color3.fromRGB(171,113,64);ladder.Material=Enum.Material.Wood;ladder.Anchored=true;ladder.Style=Enum.Style.BridgeStyleSupports;ladder.Parent=workspace.Ocean
game:GetService('Selection'):Set({});print('GAMEPLAY_ASSETS_INSTALLED',count)
