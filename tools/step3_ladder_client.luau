local p=game.Players.LocalPlayer;local char=p.Character;local h=char.Humanoid;local controls=require(p.PlayerScripts.PlayerModule):GetControls();controls:Disable()
local deadline=os.clock()+18;while not workspace.Ocean:GetAttribute('DeepTestReady') and os.clock()<deadline do task.wait(.1) end;assert(workspace.Ocean:GetAttribute('DeepTestReady'))
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={workspace.UnderwaterTerrain};params.IgnoreWater=true
local hit=workspace:Raycast(Vector3.new(17.5,5,125),Vector3.new(0,-50,0),params);assert(hit,'No ground beside return ladder')
char:PivotTo(CFrame.lookAt(hit.Position+Vector3.new(0,3.5,0),Vector3.new(14.1,hit.Position.Y+3.5,125)));task.wait(.6)
local lowest=char.HumanoidRootPart.Position.Y;h:MoveTo(Vector3.new(14.1,7,125));local began=os.clock();local climbed=false
while os.clock()-began<12 do task.wait(.15);if char.HumanoidRootPart.Position.Y>6 then climbed=true;break end end
print('STEP3_LADDER_RESULT',climbed,lowest,char.HumanoidRootPart.Position.Y,h:GetState().Name,h.Health)
if not climbed then h:MoveTo(char.HumanoidRootPart.Position) end
controls:Enable();assert(climbed and h.Health==100,'Pier ladder cannot be climbed from exposed seabed')
print('STEP3_LADDER_PASS')
