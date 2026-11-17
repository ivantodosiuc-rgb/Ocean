local p=game.Players.LocalPlayer
local initial=p.Character:FindFirstChildOfClass('Tool')~=nil;local deadline=os.clock()+8
repeat task.wait(.05) until (p.Character:FindFirstChildOfClass('Tool')~=nil)~=initial or os.clock()>deadline
assert((p.Character:FindFirstChildOfClass('Tool')~=nil)~=initial,'Touch slot did not toggle straw')
deadline=os.clock()+8
repeat task.wait(.05) until (p.Character:FindFirstChildOfClass('Tool')~=nil)==initial or os.clock()>deadline
assert((p.Character:FindFirstChildOfClass('Tool')~=nil)==initial,'Touch slot did not restore straw')
print('OCEAN_TOUCH_SLOT_PASS')
