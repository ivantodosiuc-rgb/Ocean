local package=game:GetService('ReplicatedStorage'):WaitForChild('SeaGame')
local Controller=require(package.Client.Controller)
local controller=Controller.new()
controller:start()
