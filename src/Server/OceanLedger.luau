--!strict
-- Pure DataStore transforms. Callbacks may run repeatedly and never mutate input.
local V=require(game.ReplicatedStorage.SeaGame.Shared.OceanVolume)
local Ledger={}
function Ledger.valid(record:any):boolean
 return type(record)=='table' and record.version==1 and V.finite(record.removed) and record.removed>=0 and type(record.sessions)=='table'
end
function Ledger.copy(old:any,now:number)
 if old~=nil then assert(Ledger.valid(old),'Invalid ocean shard; refusing to replace saved progress') end
 local result={version=1,removed=if old then old.removed else 0,sessions={}}
 if old then for id,session in old.sessions do
  assert(type(id)=='string' and type(session)=='table' and V.finite(session.sequence) and V.finite(session.expires),'Invalid ocean session')
  if session.expires>now then result.sessions[id]={sequence=session.sequence,expires=session.expires} end
 end end
 return result
end
function Ledger.claim(old:any,id:string,now:number,ttl:number)
 local result=Ledger.copy(old,now)
 if not result.sessions[id] then result.sessions[id]={sequence=0,expires=now+ttl} end
 return result
end
function Ledger.commit(old:any,id:string,sequence:number,amount:number,now:number,ttl:number,total:number)
 assert(V.finite(amount) and amount>=0 and V.finite(sequence) and sequence%1==0 and sequence>=1,'Invalid ocean delta')
 local result=Ledger.copy(old,now);local session=result.sessions[id]
 -- Missing/expired writer leases can never recreate themselves through a retry.
 if not session then return result end
 if sequence==session.sequence+1 then
  result.removed=math.min(total,result.removed+amount);session.sequence=sequence
 elseif sequence~=session.sequence then return result end
 session.expires=now+ttl
 return result
end
return table.freeze(Ledger)
