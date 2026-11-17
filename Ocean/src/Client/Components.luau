--!nonstrict
local TweenService=game:GetService('TweenService')
local T=require(script.Parent.Theme)
local Skin=require(script.Parent.UISkin)
local C={}
function C.reducedMotion()
 local enabled=false;pcall(function() enabled=game:GetService('GuiService').ReducedMotionEnabled end);return enabled
end
function C.new(class,properties,parent)
 local object=Instance.new(class);for k,v in properties do object[k]=v end;object.Parent=parent;return object
end
function C.corner(parent,radius) return C.new('UICorner',{CornerRadius=UDim.new(0,radius or 16)},parent) end
function C.stroke(parent,color,width) return C.new('UIStroke',{Color=color or T.Ink,Thickness=width or 2,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},parent) end
function C.tween(object,time,properties,style,direction)
 local tween=TweenService:Create(object,TweenInfo.new(time or .2,style or Enum.EasingStyle.Quart,direction or Enum.EasingDirection.Out),properties);tween:Play();return tween
end
function C.frame(parent,name,size,pos,color)
 return C.new('Frame',{Name=name,Size=size or UDim2.fromScale(1,1),Position=pos or UDim2.new(),BackgroundColor3=color or T.Paper,BorderSizePixel=0},parent)
end
function C.panel(parent,name,size,pos,color,radius)
 local p=C.frame(parent,name,size,pos,color);C.corner(p,radius);C.stroke(p,T.Ink,1.5)
 if color==T.Cream or color==T.Paper or color==T.Sand then C.skin(p,false) end
 return p
end
function C.skin(parent,wood)
 for _,child in parent:GetChildren() do if child:IsA('UIStroke') then child:Destroy() end end
 parent.BackgroundTransparency=1
 local sand=C.new('ImageLabel',{Name='SandInlay',BackgroundTransparency=1,Size=UDim2.new(1,if wood then -12 else 8,1,if wood then -12 else 8),Position=UDim2.fromOffset(if wood then 6 else -4,if wood then 6 else -4),Image=Skin.Sand,ImageColor3=Color3.fromRGB(255,244,221),ScaleType=Enum.ScaleType.Slice,SliceCenter=Skin.Slice,SliceScale=if wood then .65 else .35,ZIndex=0},parent)
 if wood then C.new('ImageLabel',{Name='CarvedWoodFrame',BackgroundTransparency=1,Size=UDim2.new(1,12,1,12),Position=UDim2.fromOffset(-6,-6),Image=Skin.Wood,ScaleType=Enum.ScaleType.Slice,SliceCenter=Skin.WoodSlice,SliceScale=tonumber(wood) or .45,ZIndex=1},parent) end
 return sand
end
function C.label(parent,text,size,pos,fontSize,color,font)
 return C.new('TextLabel',{Name='Label',BackgroundTransparency=1,Size=size,Position=pos or UDim2.new(),Text=text,Font=font or T.Body,TextSize=fontSize or 16,TextColor3=color or T.Ink,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,ZIndex=2},parent)
end
function C.button(parent,name,text,size,pos,color,callback)
 local holder=C.frame(parent,name,size,pos);holder.BackgroundTransparency=1
 local shadow=C.frame(holder,'Shadow',UDim2.fromScale(1,1),UDim2.fromOffset(0,4),T.Ink);C.corner(shadow,12)
 local button=C.new('TextButton',{Name='Button',Size=UDim2.fromScale(1,1),BackgroundColor3=color or T.Teal,Text=text,TextColor3=T.Ink,Font=T.Font,TextSize=19,AutoButtonColor=false,BorderSizePixel=0,Selectable=true,ZIndex=2},holder)
 button.BackgroundTransparency=1
 C.corner(button,12);C.stroke(button,T.Ink,1.5)
 local face=C.new('ImageLabel',{Name='RaisedFace',BackgroundTransparency=1,Size=UDim2.new(1,10,1,10),Position=UDim2.fromOffset(-5,-5),Image=Skin.Button,ImageColor3=button.BackgroundColor3,ScaleType=Enum.ScaleType.Slice,SliceCenter=Skin.Slice,SliceScale=.4,ZIndex=1},holder)
 button:GetPropertyChangedSignal('Position'):Connect(function() face.Position=button.Position-UDim2.fromOffset(5,5) end)
 button:GetPropertyChangedSignal('BackgroundColor3'):Connect(function() face.ImageColor3=button.BackgroundColor3 end)
 shadow.BackgroundColor3=Color3.fromRGB(72,82,68);shadow.BackgroundTransparency=.15
 local scale=C.new('UIScale',{Scale=1},holder)
 button.MouseEnter:Connect(function() C.tween(scale,.14,{Scale=1.025}) end)
 button.MouseLeave:Connect(function() C.tween(scale,.16,{Scale=1});C.tween(button,.16,{Position=UDim2.new()}) end)
 button.SelectionGained:Connect(function() C.tween(scale,.14,{Scale=1.025}) end)
 button.SelectionLost:Connect(function() C.tween(scale,.16,{Scale=1}) end)
 button.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then C.tween(scale,.09,{Scale=.96});C.tween(button,.09,{Position=UDim2.fromOffset(0,2)}) end end)
 button.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then C.tween(scale,.22,{Scale=1},Enum.EasingStyle.Back);C.tween(button,.12,{Position=UDim2.new()}) end end)
 if callback then button.Activated:Connect(callback) end
 return holder,button,scale
end
function C.purchaseGlint(parent)
 if C.reducedMotion() then return end
 local mask=C.frame(parent,'PurchaseGlint',UDim2.fromScale(1,1));mask.BackgroundTransparency=1;mask.ClipsDescendants=true;mask.ZIndex=9;C.corner(mask,14)
 local beam=C.frame(mask,'Light',UDim2.new(.12,0,2,0),UDim2.new(-.3,0,-.5,0),T.White);beam.BackgroundTransparency=.6;beam.Rotation=20;beam.ZIndex=10
 C.tween(beam,.42,{Position=UDim2.new(1.3,0,-.5,0)},Enum.EasingStyle.Sine)
 task.delay(.45,function() mask:Destroy() end)
end
function C.viewport(parent,category,id,size,pos)
 local frame=C.new('ViewportFrame',{Name='Art_'..id,BackgroundTransparency=1,Size=size,Position=pos or UDim2.new(),Ambient=Color3.fromRGB(222,230,235),LightColor=Color3.fromRGB(255,250,234),LightDirection=Vector3.new(-1,-1,-1),ZIndex=3},parent)
 local prefab=game:GetService('ReplicatedStorage').SeaGame.Assets[category]:FindFirstChild(id)
 if prefab then
  local world=C.new('WorldModel',{},frame);local model=prefab:Clone();model.Parent=world
  local cf,bounds=model:GetBoundingBox();local camera=C.new('Camera',{FieldOfView=30},frame);frame.CurrentCamera=camera
  local function fit()
   local size=frame.AbsoluteSize;local aspect=if size.Y>0 then math.max(.1,size.X/size.Y) else 1
   local projectedWidth=bounds.X*.97+bounds.Z*.28
   local projectedHeight=bounds.Y*.98+bounds.Z*.19+bounds.X*.05
   local distance=math.max(projectedHeight,projectedWidth/aspect)*2.15
   camera.CFrame=CFrame.lookAt(cf.Position+Vector3.new(distance*.28,distance*.2,distance),cf.Position)
  end
  frame:GetPropertyChangedSignal('AbsoluteSize'):Connect(fit);fit()
 end
 return frame
end
function C.number(value)
 local n=tostring(math.floor(value+.5));return n:reverse():gsub('(%d%d%d)','%1,'):reverse():gsub('^,','')
end
function C.waveIcon(parent,pos)
 local icon=C.frame(parent,'WaveIcon',UDim2.fromOffset(38,38),pos,T.DeepTeal);C.corner(icon,12)
 -- An original small vector wave, drawn from rounded strokes rather than emoji.
 local function line(points,width,color)
  for i=1,#points-1 do
   local a,b=points[i],points[i+1];local d=b-a
   local segment=C.frame(icon,'Foam',UDim2.fromOffset(d.Magnitude+width,width),UDim2.fromOffset((a.X+b.X)/2,(a.Y+b.Y)/2),color)
   segment.AnchorPoint=Vector2.new(.5,.5);segment.Rotation=math.deg(math.atan2(d.Y,d.X));C.corner(segment,width/2)
  end
 end
 line({Vector2.new(6,23),Vector2.new(11,23),Vector2.new(15,20),Vector2.new(17,13),Vector2.new(20,10),Vector2.new(24,10),Vector2.new(28,13),Vector2.new(28,17),Vector2.new(25,19),Vector2.new(22,18),Vector2.new(22,15),Vector2.new(24,14)},2.8,T.White)
 line({Vector2.new(6,29),Vector2.new(12,27),Vector2.new(18,29),Vector2.new(24,27),Vector2.new(31,29)},2.3,T.Aqua)
 return icon
end
function C.pill(parent,text,color,size,pos)
 local p=C.frame(parent,'Pill',size,pos,color);C.corner(p,8);local l=C.label(p,text,UDim2.fromScale(1,1),nil,12,T.Ink,T.Bold);l.TextXAlignment=Enum.TextXAlignment.Center;return p
end
return C
