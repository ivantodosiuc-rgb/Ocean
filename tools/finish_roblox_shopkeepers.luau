local specs={{'Finn','StrawShop',144075659,2.7},{'Maya','UpgradeShop',86487766,0},{'Captain Shell','TreasureShop',86487700,3.5}}
for _,spec in specs do
 local model=workspace.NPCs[spec[1]];local humanoid=model:FindFirstChildOfClass('Humanoid');local pivot=model:GetPivot();local desc=humanoid:GetAppliedDescription();desc.Face=spec[3]
 local ok,err=pcall(function() humanoid:ApplyDescriptionAsync(desc,Enum.AssetTypeVerification.Always) end);desc:Destroy();assert(ok,tostring(err))
 local counter=workspace.Buildings[spec[2]..'_Collisions'].Counter;local target=(counter.CFrame*CFrame.new(spec[4],0,-3.1)).Position
 model:PivotTo(CFrame.new(target.X,pivot.Position.Y,target.Z)*pivot.Rotation)
 for _,p in model:GetDescendants() do if p:IsA('LuaSourceContainer') then p:Destroy() elseif p:IsA('BasePart') then p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CastShadow=p.Name~='HumanoidRootPart' end end
 print('ROBLOX_NPC_FINAL',model.Name,model:GetPivot().Position,humanoid:GetAppliedDescription().Face)
end
game:GetService('ChangeHistoryService'):SetWaypoint('Friendly Roblox faces and clear counter positions');game:GetService('Selection'):Set({})
