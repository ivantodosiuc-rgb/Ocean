--!strict
local DataStoreService=game:GetService('DataStoreService')
local HttpService=game:GetService('HttpService')
local RunService=game:GetService('RunService')
local Shared=game:GetService('ReplicatedStorage').SeaGame.Shared
local Config=require(Shared.Config);local Economy=require(Shared.Economy)
local Profiles={};Profiles.__index=Profiles
function Profiles.new(onStatus,storeOverride)
 local self=setmetatable({records={},onStatus=onStatus,session=game.JobId..HttpService:GenerateGUID(false),store=nil,closing=false},Profiles)
 if storeOverride then self.store=storeOverride
 elseif game.GameId~=0 then self.store=DataStoreService:GetDataStore(Config.DataStoreName..(if RunService:IsStudio() then '_Studio' else '')) end
 return self
end
function Profiles:get(player) local r=self.records[player];return r and r.data end
function Profiles:status(player) local r=self.records[player];return r and r.status or 'Loading' end
function Profiles:load(player)
 if self.records[player] then return self.records[player].data end
 local data=Economy.new();local persistent=self.store~=nil
 if persistent then
  local loaded=nil;local lastError='Session is still active on another server.'
  for attempt=1,4 do
   local ok,result=pcall(function()
    return self.store:UpdateAsync('u_'..player.UserId,function(old)
     old=if type(old)=='table' then old else {};local lock=old.Session
     if type(lock)=='table' and lock.Token~=self.session and type(lock.Expires)=='number' and lock.Expires>os.time() then return nil end
     return {Data=Economy.normalize(old.Data or old),Session={Token=self.session,Expires=os.time()+180}}
    end)
   end)
   if ok and result then loaded=result;break end
   if not ok then lastError=tostring(result) end
   if attempt<4 then task.wait(2^(attempt-1)) end
  end
  if loaded then data=Economy.normalize(loaded.Data)
  elseif RunService:IsStudio() then persistent=false;warn('[SeaGame] Studio save unavailable: '..lastError)
  else warn('[SeaGame] Profile load failed for '..player.UserId..': '..lastError);player:Kick('Your progress could not be loaded safely. Please rejoin in a moment.');return nil end
 end
 if not player.Parent then
  if persistent then pcall(function() self.store:UpdateAsync('u_'..player.UserId,function(old) if old and old.Session and old.Session.Token==self.session then old.Session=nil;return old end;return nil end) end) end
  return nil
 end
 self.records[player]={data=data,persistent=persistent,status=if persistent then 'Saved' else 'Session',saving=false,nextSave=os.clock()+45+(player.UserId%13),savedRevision=data.Revision}
 return data
end
function Profiles:save(player,release:boolean?)
 local r=self.records[player];if not r then return true end
 if not r.persistent then return true end
 if r.saving then return false end
 r.saving=true;local snapshot=Economy.copy(r.data);local success=false;local errorMessage='Session ownership changed.'
 for attempt=1,3 do
  local ok,result=pcall(function()
   return self.store:UpdateAsync('u_'..player.UserId,function(old)
    if type(old)~='table' or type(old.Session)~='table' or old.Session.Token~=self.session then return nil end
    return {Data=snapshot,Session=if release then nil else {Token=self.session,Expires=os.time()+180}}
   end)
  end)
  if ok and result then success=true;break end
  if not ok then errorMessage=tostring(result) end
  if attempt<3 then task.wait(attempt) end
 end
 r.saving=false;r.status=if success then 'Saved' else 'Retrying';r.nextSave=os.clock()+(if success then 45 else 12)
 if success then r.savedRevision=snapshot.Revision else warn('[SeaGame] Save retry required for '..player.UserId..': '..errorMessage) end
 if self.onStatus and player.Parent then self.onStatus(player,r.status) end
 return success
end
function Profiles:release(player)
 local r=self.records[player];if not r then return end
 local deadline=os.clock()+12;while r.saving and os.clock()<deadline do task.wait(.1) end
 self:save(player,true);self.records[player]=nil
end
function Profiles:tick()
 if self.closing then return end
 for player,r in self.records do
  if r.persistent and not r.saving and os.clock()>=r.nextSave then r.nextSave=os.clock()+45;task.spawn(function() self:save(player,false) end);break end
 end
end
function Profiles:close()
 self.closing=true;local remaining=0
 for player in self.records do remaining+=1;task.spawn(function() self:release(player);remaining-=1 end) end
 local deadline=os.clock()+25;while remaining>0 and os.clock()<deadline do task.wait(.1) end
end
return Profiles
