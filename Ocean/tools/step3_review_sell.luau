local p=game.Players.LocalPlayer;local ctl=require(game.ReplicatedStorage.SeaGame.Client.Controller).current;ctl:stop();ctl.ui:close();local char=p.Character;local r=game.ReplicatedStorage.SeaGame.Remotes.Request
local added=0;for _,loot in workspace.LiveLoot:GetChildren() do if added>=4 then break end;local ground=loot:GetAttribute('GroundPosition');if ground then char:PivotTo(CFrame.new(ground+Vector3.new(0,3.5,0)));task.wait(.4);local result=r:InvokeServer('Collect',loot:GetAttribute('Token'));if result.ok then added+=1 end end end
char:PivotTo(CFrame.lookAt(Vector3.new(36,10,11),Vector3.new(49,10,17)));task.wait(.7)
local prompt=workspace.NPCs['Captain Shell'].HumanoidRootPart.ShopInteraction.Shop_Sell;prompt:InputHoldBegin();task.wait(.1);prompt:InputHoldEnd()
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(15,17,4),Vector3.new(46,9,16));print('STEP3_VISUAL_SELL_READY',added)
