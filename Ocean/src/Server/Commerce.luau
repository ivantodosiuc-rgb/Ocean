--!strict
local Players=game:GetService('Players')
local Marketplace=game:GetService('MarketplaceService')
local Offers=require(game:GetService('ReplicatedStorage').SeaGame.Shared.Offers)
local Commerce={};Commerce.__index=Commerce
function Commerce.new(gameController,marketOverride)
 local self=setmetatable({game=gameController,market=marketOverride or Marketplace,offers={},products={},passes={},prompting={}},Commerce)
 for _,offer in Offers do
  self.offers[offer.id]=offer
  if offer.assetId>0 then
   local map=if offer.kind=='Pass' then self.passes else self.products
   assert(not map[offer.assetId],'Duplicate commerce asset ID');map[offer.assetId]=offer
  end
 end
 return self
end
function Commerce:award(player,key,offer)
 local ok,fresh=self.game.profiles:grantPurchase(player,key,offer.coins,offer.straw)
 if ok and player.Parent then
  self.game:sendState(player)
  if fresh then self.game.remotes.FX:FireClient(player,'PurchaseAward',{coins=offer.coins,straw=offer.straw,name=offer.name}) end
 end
 return ok
end
function Commerce:receipt(receipt)
 local offer=self.products[receipt.ProductId];local player=Players:GetPlayerByUserId(receipt.PlayerId)
 if not offer or not player or type(receipt.PurchaseId)~='string' then return Enum.ProductPurchaseDecision.NotProcessedYet end
 local ok,granted=pcall(function() return self:award(player,'product:'..receipt.PurchaseId,offer) end)
 return if ok and granted then Enum.ProductPurchaseDecision.PurchaseGranted else Enum.ProductPurchaseDecision.NotProcessedYet
end
function Commerce:reconcilePass(player,offer)
 if offer.assetId<=0 or not player.Parent then return false end
 local ok,owns=pcall(function() return self.market:UserOwnsGamePassAsync(player.UserId,offer.assetId) end)
 if not ok or not owns then return false end
 return self:award(player,'pass:'..offer.assetId,offer)
end
function Commerce:joined(player)
 for _,offer in self.passes do
  task.spawn(function()
   for attempt=1,4 do
    if not player.Parent then return end
    if self:reconcilePass(player,offer) then return end
    if attempt<4 then task.wait(attempt*3) end
   end
  end)
 end
end
function Commerce:prompt(player,id)
 local offer=if type(id)=='string' then self.offers[id] else nil
 if not offer then return false,'Unknown offer.' end
 if offer.assetId<=0 or game.GameId==0 then return false,'Purchases are not available yet.' end
 if not self.game.profiles:canPurchase(player) then return false,'Your progress is still syncing. Please try again shortly.' end
 if self.prompting[player] then return false,'Finish the current Roblox purchase first.' end
 local data=self.game.profiles:get(player)
 if offer.straw and data.Owned[offer.straw] then return false,'You already own this straw.' end
 self.prompting[player]={id=offer.assetId,kind=offer.kind}
 local ok=pcall(function()
  if offer.kind=='Pass' then self.market:PromptGamePassPurchase(player,offer.assetId)
  else self.market:PromptProductPurchase(player,offer.assetId) end
 end)
 if not ok then self.prompting[player]=nil;return false,'Roblox checkout is unavailable. Please try again.' end
 return true,'Check the Roblox purchase window.'
end
function Commerce:start()
 self.market.ProcessReceipt=function(receipt) return self:receipt(receipt) end
 self.market.PromptGamePassPurchaseFinished:Connect(function(player,id,purchased)
  local current=self.prompting[player];if current and current.kind=='Pass' and current.id==id then self.prompting[player]=nil end
  local offer=self.passes[id]
  if purchased and offer then task.spawn(function()
   for attempt=1,5 do if not player.Parent or self:reconcilePass(player,offer) then return end;task.wait(attempt*2) end
  end) end
 end)
 -- This signal unlocks the prompt only. It NEVER grants developer-product rewards.
 self.market.PromptProductPurchaseFinished:Connect(function(userId,id)
  local player=Players:GetPlayerByUserId(userId);local current=player and self.prompting[player]
  if current and current.kind=='Product' and current.id==id then self.prompting[player]=nil end
 end)
 Players.PlayerRemoving:Connect(function(player) self.prompting[player]=nil end)
end
return Commerce
