--!nonstrict
return function()
 local V=require(game.ReplicatedStorage.SeaGame.Shared.OceanVolume)
 local C=require(game.ReplicatedStorage.SeaGame.Shared.Config).Ocean
 local L=require(game.ServerScriptService.SeaGame.OceanLedger)
 local P=require(game.ServerScriptService.SeaGame.OceanProgress)
 local http=game.HttpService;local passed=0
 local function copy(value) return if value==nil then nil else http:JSONDecode(http:JSONEncode(value)) end
 local function check(ok,name) assert(ok,'FAILED: '..name);passed+=1;print('OCEAN_TEST_PASS',name) end
 local function near(a,b) return math.abs(a-b)<.0000001 end
 local total=C.TotalOceanVolume
 local fractional=total*.000004
 check(near(V.percent(total-fractional,total),99.9996),'100.0000 to 99.9996 is preserved internally')
 check(string.format('%.2f',V.percent(total-fractional,total))=='100.00','Two-decimal formatting does not alter the source value')
 check(near(V.atLevel(V.level(total-fractional,total,0,-68),total,0,-68),total-fractional),'Precise volume and physical height round trip')
 check(V.percent(0,total)==0 and V.percent(total,total)==100,'Exact endpoints')
 check(V.flow(0/0,200,80000)==0 and V.flow(math.huge,200,80000)==0,'Invalid flow rejected')
 check(V.flow(350,C.BaseRemovalRate,C.MaxRemovalRate)==70000,'Strongest single-player upgrades are preserved')
 check(near(total*.0001/C.BaseRemovalRate,20.054016),'Basic straw takes about twenty seconds per 0.01 percent')
 local now=1000
 local store={values={},failBefore=false,failAfter=false,conflict=nil}
 function store:GetAsync(key)
  if self.failReads then error('Injected read outage') end
  return copy(self.values[key])
 end
 function store:UpdateAsync(key,transform)
  if self.failBefore then self.failBefore=false;error('Injected outage before commit') end
  local result=transform(copy(self.values[key]))
  if self.conflict then local inject=self.conflict;self.conflict=nil;inject();result=transform(copy(self.values[key])) end
  if result~=nil then self.values[key]=copy(result) end
  if self.failAfter then self.failAfter=false;error('Injected lost response after successful commit') end
  return copy(result)
 end
 local function server(id,shard) local p=P.new({store=store,id=id,shard=shard,now=function() return now end,noMessaging=true});p:load();return p end
 local a=server('ServerA',1);local b=server('ServerB',1)
 check(a.ready and b.ready and a.remaining==total,'Two servers load one shared ocean')
 a:consume(200.125);b:consume(300.25)
 store.conflict=function() assert(b:flush()) end
 check(a:flush(),'Conflicting UpdateAsync callback retries successfully')
 check(near(store.values[a:key(1)].removed,500.375),'Concurrent servers add deltas without overwriting')
 a:poll(1);b:poll(1)
 check(a.remaining==b.remaining,'Servers reconcile to the same volume')
 local prior=a.remaining;a:consume(.00004);store.failAfter=true
 check(not a:flush() and a.blocked,'Ambiguous commit pauses further draining')
 check(a.remaining==prior,'Unacknowledged progress is not displayed optimistically')
 check(a:consume(100)==0,'No unsaved removal during an outage')
 local committed=store.values[a:key(1)].removed
 check(a:flush() and store.values[a:key(1)].removed==committed,'Retry after lost acknowledgement does not double count')
 check(near(a.remaining,total-500.37504),'Sub-centesimal delta survives serialization and retry')
 local c=server('ServerC',2);c:consume(1234.56789);check(c:flush(),'Independent shard commits')
 a:poll(2);local merged=a.remaining
 check(near(merged,total-1734.94293),'Shard contributions merge without losing fractional volume')
 a:absorb(2,{version=1,removed=1,sessions={}})
 check(a.remaining==merged,'Old or out-of-order message cannot refill the ocean')
 local rejoined=server('RejoinedServer',3)
 check(near(rejoined.remaining,merged),'A new server restores all existing contributions')
 a:consume(11.75);store.failBefore=true
 check(not a:flush(),'Failure before commit is retained for retry')
 check(a:flush() and near(store.values[a:key(1)].removed,512.12504),'Pending batch is saved exactly once after recovery')
 local stale=L.claim(nil,'expired',now,120);stale=L.commit(stale,'expired',1,77.25,now,120,total)
 local unchanged=L.commit(stale,'expired',1,77.25,now+121,120,total)
 check(unchanged.removed==77.25 and unchanged.sessions.expired==nil,'Expired lease cannot replay an old delta')
 local duplicate=L.commit(stale,'expired',1,77.25,now+2,120,total)
 check(duplicate.removed==stale.removed and stale.sessions.expired.expires==now+120,'Retry transform is idempotent and does not mutate input')
 local outOfOrder=L.commit(stale,'expired',4,1000,now+3,120,total)
 check(outOfOrder.removed==77.25,'Skipped sequence is rejected')
 local finish=L.commit(stale,'expired',2,total*3,now+3,120,total)
 check(finish.removed==total and V.remaining(total,finish.removed)==0,'Global completion clamps exactly at zero')
 local disconnected=server('Disconnected',4);disconnected:consume(22.5);disconnected:close()
 local last=server('AfterShutdown',5)
 check(near(last.remaining,total-1769.19293),'Shutdown flush survives a later server load')
 store.failReads=true;local unavailable=P.new({store=store,id='ReadFailure',noMessaging=true})
 check(not pcall(function() unavailable:load() end) and not unavailable.ready,'Read error never falls back to a new full ocean')
 store.failReads=false
 check(not pcall(function() L.commit({removed='bad'},'x',1,5,now,120,total) end),'Corrupt stored data is never silently overwritten')
 store.values[a:key(15)]={version=1,removed='corrupt',sessions={}}
 local corrupt=P.new({store=store,id='CorruptReader',noMessaging=true})
 check(not pcall(function() corrupt:load() end) and not corrupt.ready and store.values[a:key(15)].removed=='corrupt','Invalid saved shard cannot be replaced with zero progress')
 print('OCEAN_UNIT_COMPLETE',passed)
 return passed
end
