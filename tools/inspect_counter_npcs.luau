print('COUNTER_CONTEXT',game:GetService('RunService'):IsEdit(),workspace:GetAttribute('CharacterFloraRefresh'))
print('COUNTER_UNDO',game:GetService('ChangeHistoryService'):GetCanUndo())
for _,p in workspace.Buildings:GetDescendants() do if p.Name=='Counter' or p.Name=='Floor' then print('COUNTER_PART',p:GetFullName(),p.CFrame,p.Size) end end
for _,m in workspace.NPCs:GetChildren() do print('COUNTER_OLD_NPC',m.Name,m:GetPivot().Position) end
