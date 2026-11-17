--!nonstrict
local TweenService=game:GetService('TweenService')
local T=require(script.Parent.Theme)
local C={}
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
 local p=C.frame(parent,name,size,pos,color);C.corner(p,radius);C.stroke(p,T.Ink,2);return p
end
function C.label(parent,text,size,pos,fontSize,color,font)
 return C.new('TextLabel',{Name='Label',BackgroundTransparency=1,Size=size,Position=pos or UDim2.new(),Text=text,Font=font or T.Body,TextSize=fontSize or 16,TextColor3=color or T.Ink,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center},parent)
end
function C.button(parent,name,text,size,pos,color,callback)
 local holder=C.frame(parent,name,size,pos);holder.BackgroundTransparency=1
 local shadow=C.frame(holder,'Shadow',UDim2.fromScale(1,1),UDim2.fromOffset(0,4),T.Ink);C.corner(shadow,12)
 local button=C.new('TextButton',{Name='Button',Size=UDim2.fromScale(1,1),BackgroundColor3=color or T.Teal,Text=text,TextColor3=T.Ink,Font=T.Font,TextSize=19,AutoButtonColor=false,BorderSizePixel=0,Selectable=true},holder)
 C.corner(button,12);C.stroke(button,T.Ink,2)
 C.new('UIGradient',{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromRGB(227,239,231))}),Rotation=90},button)
 local scale=C.new('UIScale',{Scale=1},holder)
 button.MouseEnter:Connect(function() C.tween(scale,.14,{Scale=1.025}) end)
 button.MouseLeave:Connect(function() C.tween(scale,.16,{Scale=1});C.tween(button,.16,{Position=UDim2.new()}) end)
 button.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then C.tween(scale,.09,{Scale=.96});C.tween(button,.09,{Position=UDim2.fromOffset(0,2)}) end end)
 button.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then C.tween(scale,.22,{Scale=1},Enum.EasingStyle.Back);C.tween(button,.12,{Position=UDim2.new()}) end end)
 if callback then button.Activated:Connect(callback) end
 return holder,button,scale
end
function C.viewport(parent,category,id,size,pos)
 local frame=C.new('ViewportFrame',{Name='Art_'..id,BackgroundTransparency=1,Size=size,Position=pos or UDim2.new(),Ambient=Color3.fromRGB(222,230,235),LightColor=Color3.fromRGB(255,250,234),LightDirection=Vector3.new(-1,-1,-1)},parent)
 local prefab=game:GetService('ReplicatedStorage').SeaGame.Assets[category]:FindFirstChild(id)
 if prefab then
  local world=C.new('WorldModel',{},frame);local model=prefab:Clone();model.Parent=world
  local cf,bounds=model:GetBoundingBox();local camera=C.new('Camera',{FieldOfView=30},frame);frame.CurrentCamera=camera
  local radius=math.max(bounds.X,bounds.Y,bounds.Z);local distance=radius*2.15
  camera.CFrame=CFrame.lookAt(cf.Position+Vector3.new(distance*.28,distance*.2,distance),cf.Position)
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
