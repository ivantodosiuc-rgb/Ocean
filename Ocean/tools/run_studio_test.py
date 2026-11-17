from pathlib import Path
import sys,json
ROOT=Path(__file__).resolve().parents[1]
test=Path(sys.argv[1]);context=sys.argv[2] if len(sys.argv)>2 else 'client'
source=test.read_text(encoding='utf-8')
kind='Script' if context=='server' else 'LocalScript'
parent="game:GetService('ServerScriptService')" if context=='server' else "game.Players.LocalPlayer.PlayerGui"
encoded=json.dumps(source,ensure_ascii=True)
testside='IsServer' if context=='server' else 'IsClient'
test_name='TemporaryStep3Test_'+test.stem
code=f"assert(game:GetService('RunService'):IsRunning(),'Play only');assert(game:GetService('RunService'):{testside}(),'{context} context required');local old={parent}:FindFirstChild('{test_name}');if old then old:Destroy() end;local t=Instance.new('{kind}');t.Name='{test_name}';t.Source=game.HttpService:JSONDecode([====[{encoded}]====]);t.Parent={parent}"
(ROOT/'build/run-step3-test.luau').write_text(code,encoding='utf-8')
