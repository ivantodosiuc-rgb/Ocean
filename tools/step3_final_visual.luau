local ctl=require(game.ReplicatedStorage.SeaGame.Client.Controller).current;ctl:stop();ctl.ui:close();local rare=0
for _,m in workspace.LiveLoot:GetChildren() do if m:FindFirstChild('TreasureGleam') then rare+=1;assert(m:FindFirstChild('GentleSparkles',true),'Rare treasure missing particle effect') end end
print('STEP3_RARE_EFFECTS',rare)
local p=game.Players.LocalPlayer;p.Character:PivotTo(CFrame.lookAt(Vector3.new(-38.4,11,-7.8),Vector3.new(-40,11,-19)));task.wait(.6)
local prompt=workspace.NPCs.Finn.HumanoidRootPart.ShopInteraction.Shop_Straws;prompt:InputHoldBegin();task.wait(.1);prompt:InputHoldEnd();task.wait(.5)
print('STEP3_FINAL_UI',ctl.ui.shop,ctl.ui.window.AbsoluteSize,#ctl.ui.cards)
