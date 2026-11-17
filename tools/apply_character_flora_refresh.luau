assert(game:GetService('RunService'):IsEdit(),'Run in Edit mode')
assert(not workspace:GetAttribute('CharacterFloraRefresh'),'Refresh already applied')
local imported=assert(workspace:FindFirstChild('SuckTheSea_Refresh'),'Import refresh FBX first')
local meshes={}
for _,p in imported:GetDescendants() do if p:IsA('MeshPart') then meshes[p.Name]=p end end
local function source(name)
 for key,p in meshes do if key==name or key:sub(1,#name)==name then return p end end
 error('Missing import mesh '..name)
end
for _,name in {'RefreshNPC__Finn','RefreshNPC__Maya','RefreshNPC__CaptainShell','RefreshFlora__Coral','RefreshFlora__Cream','RefreshFlora__Lilac'} do source(name) end
local _,size=imported:GetBoundingBox();assert(size.X>100 and size.X<160,'Unexpected import scale: '..tostring(size))
game:GetService('ChangeHistoryService'):SetWaypoint('Before character and planting refresh')
imported:PivotTo(CFrame.Angles(0,math.pi,0)*imported:GetPivot())
local function setVisual(p)
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=true;p.Color=Color3.new(1,1,1);p.Material=Enum.Material.SmoothPlastic;p.RenderFidelity=Enum.RenderFidelity.Automatic
end
for _,p in meshes do setVisual(p) end
local ground=RaycastParams.new();ground.FilterType=Enum.RaycastFilterType.Include;ground.FilterDescendantsInstances={workspace.StarterIsland.Meadow,workspace.StarterIsland.GoldenShore};ground.IgnoreWater=true
local function height(x,z)
 local hit=workspace:Raycast(Vector3.new(x,40,z),Vector3.new(0,-70,0),ground)
 assert(hit,'No land at '..x..','..z);return hit.Position.Y
end
local storage=Instance.new('Folder');storage.Name='SuckTheSeaArt';storage.Parent=game:GetService('ServerStorage')
local prefabs={}
for _,kind in {'Coral','Cream','Lilac'} do local p=source('RefreshFlora__'..kind);p.Name=kind;p.Parent=storage;prefabs[kind]=p end
local flowers=Instance.new('Folder');flowers.Name='TropicalFlowers';flowers.Parent=workspace.Decorations
local oldFlowers={}
for _,p in workspace.Decorations:GetChildren() do if p:IsA('MeshPart') and p.Name:match('^FlowerBed_') then table.insert(oldFlowers,p) end end
table.sort(oldFlowers,function(a,b) return a.Name<b.Name end)
for i,old in oldFlowers do
 local kind=({'Coral','Cream','Lilac'})[(i-1)%3+1];local p=prefabs[kind]:Clone();p.Name=string.format('%s_Bed_%02d',kind,i)
 local x,z=old.Position.X,old.Position.Z
 p.CFrame=CFrame.new(x,height(x,z)-.03,z)*CFrame.Angles(0,math.rad(i*47),0)*p.CFrame;p.Parent=flowers
 old:Destroy()
end
local grass=Instance.new('Folder');grass.Name='LushGrass';grass:SetAttribute('Clumps',943);grass.Parent=workspace.Decorations
local grassCount=0
for name,p in meshes do if name:sub(1,14)=='RefreshGrass__' then p.Name=name:sub(15);p.Parent=grass;grassCount+=1 end end
assert(grassCount==32,'Expected 32 grass patches')
local oldGrass=workspace.Decorations:FindFirstChild('GrassTuft');if oldGrass then oldGrass:Destroy() end
for _,spec in {{'Finn','Finn',-5.5},{'Maya','Maya',0},{'Captain Shell','CaptainShell',5.5}} do
 local model=assert(workspace.NPCs:FindFirstChild(spec[1]));local oldPos=model:GetPivot().Position
 local foot=Vector3.new(oldPos.X,height(oldPos.X,oldPos.Z),oldPos.Z)
 local facing=CFrame.lookAt(foot,Vector3.new(0,foot.Y,0))*CFrame.Angles(0,math.pi,0)
 local visual=source('RefreshNPC__'..spec[2]);visual.Name='CharacterMesh';visual.CFrame=facing*CFrame.new(-spec[3],0,0)*visual.CFrame
 local humanoid=model:FindFirstChildOfClass('Humanoid');if humanoid then humanoid.RequiresNeck=false;humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end
 local root=model:FindFirstChild('HumanoidRootPart');local head=model:FindFirstChild('Head')
 for _,p in model:GetChildren() do if p:IsA('BasePart') and p~=root and p~=head then p:Destroy() end end
 root.Size=Vector3.new(1.65,4.4,1.35);root.CFrame=CFrame.new(foot+Vector3.new(0,2.2,0));root.Transparency=1;root.Anchored=true;root.CanCollide=true;root.CanTouch=false;root.CastShadow=false
 if head then head.Transparency=1;head.CanCollide=false;head.CanTouch=false;head.CastShadow=false;head.CFrame=CFrame.new(foot+Vector3.new(0,5.2,0));for _,c in head:GetChildren() do c:Destroy() end end
 visual.Parent=model;model.PrimaryPart=root;model:SetAttribute('ArtSource','Blender original character');model:SetAttribute('StaticNPC',true)
 print('REFRESH_NPC_PLACED',model.Name,foot,visual.Size,visual.TextureID)
end
local meadow=workspace.StarterIsland.Meadow;meadow.TextureID='';for _,p in meadow:GetChildren() do if p:IsA('SurfaceAppearance') then p:Destroy() end end
meadow.Color=Color3.fromRGB(98,205,48);meadow.Material=Enum.Material.SmoothPlastic;meadow.CastShadow=true
local light=game:GetService('Lighting');light.GlobalShadows=true;light.ShadowSoftness=.42;light.Brightness=2.25;light.ClockTime=14.15;light.ExposureCompensation=0
light.Ambient=Color3.fromRGB(104,121,112);light.OutdoorAmbient=Color3.fromRGB(140,157,140);light.EnvironmentDiffuseScale=.3;light.EnvironmentSpecularScale=.35
local atmosphere=light:FindFirstChildOfClass('Atmosphere');if atmosphere then atmosphere.Density=.19;atmosphere.Offset=.2;atmosphere.Haze=.7;atmosphere.Glare=.08 end
local grade=light:FindFirstChildOfClass('ColorCorrectionEffect');if grade then grade.Saturation=.11;grade.Contrast=.04;grade.Brightness=.01;grade.TintColor=Color3.fromRGB(255,252,244) end
local bloom=light:FindFirstChildOfClass('BloomEffect');if bloom then bloom.Intensity=.07;bloom.Size=20;bloom.Threshold=1.5 end
imported:Destroy();workspace:SetAttribute('CharacterFloraRefresh','2026-11-16-v1')
game:GetService('Selection'):Set({});game:GetService('ChangeHistoryService'):SetWaypoint('Sculpted villagers, tropical flowers and bright grass')
print('REFRESH_APPLIED',grassCount,#oldFlowers,'3 sculpted NPCs')
