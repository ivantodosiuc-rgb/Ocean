local ui=require(game.ReplicatedStorage.SeaGame.Client.Controller).current.ui
task.wait(.4)
local function overlap(a,b)
 local ap,az,bp,bz=a.AbsolutePosition,a.AbsoluteSize,b.AbsolutePosition,b.AbsoluteSize
 return ap.X<bp.X+bz.X and bp.X<ap.X+az.X and ap.Y<bp.Y+bz.Y and bp.Y<ap.Y+az.Y
end
for _,pair in {{ui.coins,ui.bag},{ui.coins,ui.sea},{ui.bag,ui.sea},{ui.slot,ui.touchHolder}} do
 if pair[1].Visible and pair[2].Visible then assert(not overlap(pair[1],pair[2]),'HUD overlap: '..pair[1].Name..'/'..pair[2].Name) end
end
local origin,size=ui.root.AbsolutePosition,ui.root.AbsoluteSize
for _,object in {ui.coins,ui.bag,ui.sea,ui.slot} do
 local p,s=object.AbsolutePosition-origin,object.AbsoluteSize
 assert(p.X>=-.1 and p.Y>=-.1 and p.X+s.X<=size.X+.1 and p.Y+s.Y<=size.Y+.1,'HUD exceeds safe area: '..object.Name)
end
assert(math.abs(ui.sea.AbsolutePosition.X+ui.sea.AbsoluteSize.X/2-origin.X-size.X/2)<1,'Ocean bar not centered')
assert(ui.seaLabel.TextBounds.X<=ui.seaLabel.AbsoluteSize.X,'Percent text clipped')
print('OCEAN_UI_LAYOUT_PASS',game.HttpService:JSONEncode({viewport=tostring(workspace.CurrentCamera.ViewportSize),safeArea=tostring(size),barSize=tostring(ui.sea.AbsoluteSize),touch=game.UserInputService.TouchEnabled,display=ui.seaLabel.Text}))
