--!nonstrict
local DataStoreService=game:GetService('DataStoreService')
local MessagingService=game:GetService('MessagingService')
local HttpService=game:GetService('HttpService')
local RunService=game:GetService('RunService')
local Config=require(game.ReplicatedStorage.SeaGame.Shared.Config).Ocean
local V=require(game.ReplicatedStorage.SeaGame.Shared.OceanVolume)
local Ledger=require(script.Parent.OceanLedger)
local Progress={};Progress.__index=Progress
local function memoryStore()
 local store={values={}}
 function store:GetAsync(key) return self.values[key] end
 function store:UpdateAsync(key,transform) local result=transform(self.values[key]);if result~=nil then self.values[key]=result end;return result end
 return store
end
function Progress.new(options)
 options=options or {}
 local persistent=options.store~=nil or game.GameId~=0
 local store=options.store or (if persistent then DataStoreService:GetDataStore(Config.ProgressStore..(if RunService:IsStudio() then '_Studio' else '')) else memoryStore())
 local id=options.id or HttpService:GenerateGUID(false)
 local hash=0;for i=1,#id do hash=(hash*31+string.byte(id,i))%65521 end
 return setmetatable({store=store,persistent=persistent,now=options.now or os.time,id=id,shard=options.shard or hash%Config.ShardCount+1,sequence=0,totals=table.create(Config.ShardCount,0),total=Config.TotalOceanVolume,remaining=Config.TotalOceanVolume,pending=0,batch=nil,ready=false,status='Loading',busy=false,blocked=false,closing=false,clock=0,pollClock=0,pollIndex=1,leaseUntil=0,retryAt=0,failures=0,noMessaging=options.noMessaging or not persistent,topic=Config.WorldKey..(if RunService:IsStudio() then '_Studio' else '')},Progress)
end
function Progress:key(index) return Config.WorldKey..'_s'..index end
function Progress:absorb(index,record)
 if record==nil then return end
 assert(Ledger.valid(record),'Invalid saved ocean shard')
 self.totals[index]=math.max(self.totals[index],record.removed)
 local sum=0;for _,amount in self.totals do sum+=amount end
 self.remaining=V.remaining(self.total,sum)
end
function Progress:claim()
 local result=self.store:UpdateAsync(self:key(self.shard),function(old) return Ledger.claim(old,self.id,self.now(),Config.LeaseSeconds) end)
 self:absorb(self.shard,result)
 local session=result.sessions[self.id];assert(session,'Ocean writer registration failed')
 self.sequence=session.sequence;self.leaseUntil=session.expires
end
function Progress:load()
 local metadata=self.store:GetAsync(Config.WorldKey..'_meta')
 if metadata==nil then metadata=self.store:UpdateAsync(Config.WorldKey..'_meta',function(old)
  return old or {version=1,total=Config.TotalOceanVolume,shards=Config.ShardCount,initial=Config.initial,minimum=Config.minimum,halfSize=Config.halfSize}
 end) end
 assert(type(metadata)=='table' and metadata.version==1 and V.finite(metadata.total) and metadata.total>0 and metadata.shards==Config.ShardCount,'Invalid ocean metadata; existing progress is protected')
 assert(metadata.initial==Config.initial and metadata.minimum==Config.minimum and metadata.halfSize==Config.halfSize,'Ocean geometry differs from the saved world')
 self.total=metadata.total
 for index=1,Config.ShardCount do self:absorb(index,self.store:GetAsync(self:key(index))) end
 self:claim();self.ready=true;self.status=if self.persistent then 'Saved' else 'Session'
 return true
end
function Progress:start()
 task.spawn(function()
  while not self.closing and not self.ready do
   local ok,err=pcall(function() self:load() end)
   if not ok then self.status='Unavailable';warn('[SeaGame] Ocean loading will retry: '..tostring(err));task.wait(8) end
  end
  if self.closing or self.noMessaging then return end
  local ok,connection=pcall(function() return MessagingService:SubscribeAsync(self.topic,function(message)
   local data=message.Data
   if type(data)=='table' and V.finite(data.shard) and data.shard%1==0 and data.shard>=1 and data.shard<=Config.ShardCount and V.finite(data.removed) and data.removed>=0 and data.removed<=self.total then
    self:absorb(data.shard,{version=1,removed=data.removed,sessions={}})
   end
  end) end)
  if ok then self.subscription=connection else warn('[SeaGame] Ocean messages unavailable; periodic DataStore reconciliation remains active') end
 end)
end
function Progress:canDrain() return self.ready and not self.blocked and not self.closing and self.remaining>0 end
function Progress:consume(volume)
 if not self:canDrain() or not V.finite(volume) or volume<=0 then return 0 end
 local amount=math.min(volume,math.max(0,self.remaining-self.pending));self.pending+=amount;return amount
end
function Progress:flush()
 if self.busy or not self.ready then return false end
 self.busy=true
 if not self.batch then self.batch={sequence=self.sequence+1,amount=self.pending} end
 local batch=self.batch
 local ok,result=pcall(function() return self.store:UpdateAsync(self:key(self.shard),function(old)
  return Ledger.commit(old,self.id,batch.sequence,batch.amount,self.now(),Config.LeaseSeconds,self.total)
 end) end)
 if ok and result then
  self:absorb(self.shard,result)
  local session=result.sessions[self.id]
  if session and session.sequence==batch.sequence then
   self.pending=math.max(0,self.pending-batch.amount);self.sequence=batch.sequence;self.leaseUntil=session.expires;self.batch=nil
   self.blocked=false;self.failures=0;self.status=if self.persistent then 'Saved' else 'Session';self.clock=0
   if not self.noMessaging and batch.amount>0 then task.spawn(function() pcall(function() MessagingService:PublishAsync(self.topic,{shard=self.shard,removed=result.removed}) end) end) end
  else
   -- An expired, uncertain batch is never replayed under a new writer identity.
   -- Its canonical saved total was absorbed above; displayed progress never rewinds.
   self.pending=0;self.batch=nil;self.id=HttpService:GenerateGUID(false);self.sequence=0;self.blocked=true
   local claimed=pcall(function() self:claim() end);self.blocked=not claimed;self.status=if claimed then (if self.persistent then 'Saved' else 'Session') else 'Retrying'
   if claimed then self.failures=0;self.clock=0 else self.failures+=1;self.retryAt=os.clock()+math.min(20,2^math.min(self.failures,4)) end
  end
 else
  self.blocked=true;self.status='Retrying';self.failures+=1;self.retryAt=os.clock()+math.min(20,2^math.min(self.failures,4))
  warn('[SeaGame] Ocean commit will retry without double counting')
 end
 self.busy=false;return ok and not self.blocked
end
function Progress:poll(index)
 local options=Instance.new('DataStoreGetOptions');options.UseCache=false
 local result=self.store:GetAsync(self:key(index),options)
 self:absorb(index,result)
end
function Progress:step(dt)
 if not self.ready or self.closing then return end
 self.clock+=dt;self.pollClock+=dt
 if not self.busy and os.clock()>=self.retryAt and (self.batch or (self.pending>0 and self.clock>=Config.CommitInterval) or self.now()>self.leaseUntil-30) then
  task.spawn(function() self:flush() end)
 end
 if self.pollClock>=Config.PollInterval and not self.polling then
  self.pollClock=0;local index=self.pollIndex;self.pollIndex=index%Config.ShardCount+1;self.polling=true
  task.spawn(function() local ok=pcall(function() self:poll(index) end);self.polling=false;if not ok then self.pollClock=-4 end end)
 end
end
function Progress:close()
 self.closing=true;local deadline=os.clock()+22
 repeat
  if not self.busy and self.ready and (self.pending>0 or self.batch) then self:flush() end
  if not self.busy and self.pending<=0 and not self.batch then break end
  task.wait(.2)
 until os.clock()>deadline
 if self.subscription then self.subscription:Disconnect() end
end
return Progress
