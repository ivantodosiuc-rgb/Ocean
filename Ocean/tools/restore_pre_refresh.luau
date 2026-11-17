assert(game:GetService('RunService'):IsEdit(),'Edit mode required')
local history=game:GetService('ChangeHistoryService');local canUndo,label=history:GetCanUndo()
assert(canUndo and label=='Sculpted villagers, tropical flowers and bright grass','Unexpected undo point: '..tostring(label))
history:Undo()
assert(not workspace:GetAttribute('CharacterFloraRefresh'),'Refresh was not undone')
assert(workspace.Decorations:FindFirstChild('FlowerBed_00'),'Original flowers were not restored')
assert(not workspace.Decorations:FindFirstChild('LushGrass'),'Grass still present')
local imported=workspace:FindFirstChild('SuckTheSea_Refresh');if imported then imported:Destroy() end
local extra=game:GetService('ServerStorage'):FindFirstChild('SuckTheSeaArt');if extra then extra:Destroy() end
history:SetWaypoint('Restore original island appearance')
print('RESTORE_ORIGINAL_DONE',workspace.StarterIsland.Meadow.TextureID,#workspace.NPCs:GetChildren())
