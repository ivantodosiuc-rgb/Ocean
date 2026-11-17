local ctl=require(game.ReplicatedStorage.SeaGame.Client.Controller).current;local ui=ctl.ui
local function overlap(a,b)
 local ap,az,bp,bz=a.AbsolutePosition,a.AbsoluteSize,b.AbsolutePosition,b.AbsoluteSize
 return ap.X<bp.X+bz.X-1 and bp.X<ap.X+az.X-1 and ap.Y<bp.Y+bz.Y-1 and bp.Y<ap.Y+az.Y-1
end
local hud={ui.coins,ui.bag,ui.sea,ui.slot,ui.hint,ui.comfort.bar,ui.comfort.offer}
if ui.touchHolder.Visible then table.insert(hud,ui.touchHolder) end
local issues={};local origin,size=ui.root.AbsolutePosition,ui.root.AbsoluteSize
for i,a in hud do
 local p,s=a.AbsolutePosition-origin,a.AbsoluteSize
 if p.X<0 or p.Y<0 or p.X+s.X>size.X+1 or p.Y+s.Y>size.Y+1 then table.insert(issues,'outside safe area: '..a.Name) end
 for j=i+1,#hud do if overlap(a,hud[j]) then table.insert(issues,a.Name..' overlaps '..hud[j].Name) end end
end
ui:open('Premium');task.wait(.5)
for _,line in ui.comfort.statFrames do if overlap(line,ui.comfort.buyHolder) or (ui.comfort.note.Visible and overlap(line,ui.comfort.note)) then table.insert(issues,'premium specifications overlap footer') end end
for _,v in ui.window:GetDescendants() do if v:IsA('TextLabel') and v.Visible and not v.TextWrapped and v.TextBounds.X>v.AbsoluteSize.X+1 then table.insert(issues,'clipped: '..v.Text) end end
local result={ok=#issues==0,issues=issues,viewport=tostring(workspace.CurrentCamera.ViewportSize),safeArea=tostring(size),premiumCard=tostring(ui.window.Items.PrismShowcase.AbsoluteSize),touch=game.UserInputService.TouchEnabled}
workspace:SetAttribute('ComfortUILayout',game.HttpService:JSONEncode(result))
task.defer(function() script:Destroy() end)
