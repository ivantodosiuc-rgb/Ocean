assert(not game:GetService('RunService'):IsRunning())
local light=game:GetService('Lighting');light.Brightness=1.8;light.ExposureCompensation=-.08
for _,p in light:GetChildren() do if p:IsA('ColorCorrectionEffect') then p.Saturation=.08;p.Contrast=.055;p.Brightness=0 end end
workspace.StarterIsland.Meadow.Color=Color3.fromRGB(101,203,68)
workspace.Terrain.WaterColor=Color3.fromRGB(25,147,164);workspace.Terrain.WaterReflectance=.06
local old=workspace.Ocean:FindFirstChild('DistantSea');if old then old:Destroy() end
local f=Instance.new('Folder');f.Name='DistantSea';f.Parent=workspace.Ocean
-- Far scenery outside the collision boundary is four cheap visual surfaces, not simulated terrain.
for i,s in {{0,960,3072,1152},{0,-960,3072,1152},{960,0,1152,768},{-960,0,1152,768}} do
 local p=Instance.new('Part');p.Name='Horizon'..i;p.Size=Vector3.new(s[3],.1,s[4]);p.Position=Vector3.new(s[1],-.08,s[2]);p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Color=Color3.fromRGB(25,147,164);p.Material=Enum.Material.SmoothPlastic;p.Reflectance=.03;p.Parent=f
end
print('DEPTH_VISUAL_POLISH_DONE')
