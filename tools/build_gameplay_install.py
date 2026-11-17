from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
for group in ['Shared','Server','Client','Tests']:
    files=[]
    for f in sorted((ROOT/'src'/group).glob('*.luau')):
        name=f.name.replace('.server.luau','').replace('.client.luau','').replace('.luau','')
        kind='Script' if '.server.' in f.name else 'LocalScript' if '.client.' in f.name else 'ModuleScript'
        files.append({'name':name,'class':kind,'source':f.read_text(encoding='utf-8')})
    payload=json.dumps(files,ensure_ascii=True,separators=(',',':'))
    code="""assert(not game:GetService('RunService'):IsRunning(),'Install in Edit mode only');local function folder(parent,name) local f=parent:FindFirstChild(name);if not f then f=Instance.new('Folder');f.Name=name;f.Parent=parent end;return f end;local package=folder(game:GetService('ReplicatedStorage'),'SeaGame');local remotes=folder(package,'Remotes');for _,name in {'Request','State','World','FX','Suction'} do if not remotes:FindFirstChild(name) then local r=Instance.new(if name=='Request' then 'RemoteFunction' else 'RemoteEvent');r.Name=name;r.Parent=remotes end end;local group=GROUP;local parent;if group=='Server' then parent=folder(game:GetService('ServerScriptService'),'SeaGame') elseif group=='Tests' then parent=folder(game:GetService('ServerStorage'),'SeaGameTests') else parent=folder(package,group) end;local sources=game:GetService('HttpService'):JSONDecode([====[PAYLOAD]====]);for _,entry in sources do local targetParent=if entry.class=='LocalScript' then game:GetService('StarterPlayer').StarterPlayerScripts else parent;local name=if entry.class=='LocalScript' then 'SeaGameClient' else entry.name;local existing=targetParent:FindFirstChild(name);if existing and existing.ClassName~=entry.class then existing:Destroy();existing=nil end;local object=existing or Instance.new(entry.class);object.Name=name;object.Source=entry.source;object.Parent=targetParent end;print('GAMEPLAY_CODE_INSTALLED',group,#sources)""".replace('GROUP',json.dumps(group)).replace('PAYLOAD',payload)
    (ROOT/'build'/('install-'+group.lower()+'.luau')).write_text(code,encoding='utf-8')
    print(group,len(files),len(code))
