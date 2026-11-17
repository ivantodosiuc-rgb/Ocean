print('REFRESH_CONTEXT',game:GetService('RunService'):IsEdit(),game:GetService('RunService'):IsRunning())
for _,m in workspace.NPCs:GetChildren() do print('REFRESH_NPC',m.Name,m:GetPivot().Position) end
local p=workspace.StarterIsland.Meadow;print('REFRESH_GRASS',p.Color,p.Material,p.TextureID,p.Position)
local l=game:GetService('Lighting');print('REFRESH_LIGHT',l.GlobalShadows,l.ShadowSoftness,l.Brightness,l.ClockTime,l.LightingStyle)
