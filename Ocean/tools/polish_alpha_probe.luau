local wet=workspace.Ocean.WetShoreRig:FindFirstChild('WetShore',true);wet.Transparency=.02
print('WET_ALPHA_SETTINGS',wet.SurfaceAppearance.AlphaMode,wet.Transparency)
local ok,result=pcall(function()
 local image=game:GetService('AssetService'):CreateEditableImageAsync(Content.fromUri('rbxassetid://128914855847123'))
 local size=image.Size;local samples={}
 for _,y in {0,32,64,128,200,255} do local pixels=image:ReadPixelsBuffer(Vector2.new(math.floor(size.X/2),math.min(size.Y-1,y)),Vector2.one);table.insert(samples,{y=y,r=buffer.readu8(pixels,0),g=buffer.readu8(pixels,1),b=buffer.readu8(pixels,2),a=buffer.readu8(pixels,3)}) end
 image:Destroy();return game.HttpService:JSONEncode(samples)
end)
print('WET_UPLOADED_ALPHA',ok,result)
