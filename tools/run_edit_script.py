from pathlib import Path
import sys,json
ROOT=Path(__file__).resolve().parents[1]
source=Path(sys.argv[1]).read_text(encoding='utf-8')+'\nreturn true\n'
payload=json.dumps(source,ensure_ascii=True)
code="assert(not game:GetService('RunService'):IsRunning(),'Edit only');local m=Instance.new('ModuleScript');m.Name='TemporarySceneEdit';m.Source=game.HttpService:JSONDecode([====["+payload+"]====]);m.Parent=game.ServerStorage;local ok,result=pcall(require,m);m:Destroy();assert(ok,result)"
(ROOT/'build/run-edit-script.luau').write_text(code,encoding='utf-8')
