"""Small stdio client for the official, locally installed Roblox Studio MCP."""
import argparse
import base64
import json
import os
from pathlib import Path
import queue
import subprocess
import threading
import time

ROOT = Path(__file__).resolve().parents[1]
MCP = Path(r'C:/Users/Administrator/AppData/Local/Roblox/Versions/version-63eb6055af4e4688/StudioMCP.exe')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('tool', nargs='?', default='tools/list')
    parser.add_argument('--args', default='{}')
    parser.add_argument('--args-file')
    parser.add_argument('--code-file')
    parser.add_argument('--studio')
    parser.add_argument('--context', default='Edit')
    parser.add_argument('--out')
    parser.add_argument('--timeout', type=float, default=120)
    a = parser.parse_args()
    proc = subprocess.Popen([str(MCP)], cwd=str(MCP.parent), stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                            text=True, encoding='utf-8', creationflags=subprocess.CREATE_NO_WINDOW)
    messages = queue.Queue()
    def reader():
        for line in proc.stdout:
            try:
                messages.put(json.loads(line))
            except ValueError:
                pass
    threading.Thread(target=reader, daemon=True).start()
    def request(id_, method, params):
        proc.stdin.write(json.dumps({'jsonrpc':'2.0','id':id_,'method':method,'params':params})+'\n')
        proc.stdin.flush()
        deadline = time.monotonic() + a.timeout
        while time.monotonic() < deadline:
            try:
                msg = messages.get(timeout=min(1, max(.01, deadline-time.monotonic())))
            except queue.Empty:
                if proc.poll() is not None:
                    raise RuntimeError(proc.stderr.read()[-2000:])
                continue
            if msg.get('id') == id_:
                return msg
        raise TimeoutError(method)
    try:
        request(1,'initialize',{'protocolVersion':'2024-11-05','capabilities':{},
                              'clientInfo':{'name':'ocean-map-build','version':'1.0'}})
        proc.stdin.write(json.dumps({'jsonrpc':'2.0','method':'notifications/initialized'})+'\n')
        proc.stdin.flush()
        if a.tool == 'tools/list':
            result = request(2,'tools/list',{})
        else:
            args = json.loads(Path(a.args_file).read_text(encoding='utf-8')) if a.args_file else json.loads(a.args)
            if a.studio:
                args['studio_id'] = a.studio
            if a.code_file:
                args['code'] = Path(a.code_file).read_text(encoding='utf-8')
                args['datamodel_type'] = a.context
            result = request(2,'tools/call',{'name':a.tool,'arguments':args})
        for i, item in enumerate(result.get('result',{}).get('content',[])):
            if item.get('type') == 'image':
                folder = ROOT/'build/screenshots'
                folder.mkdir(parents=True,exist_ok=True)
                path = folder/(Path(a.out).stem+f'-{i}.png' if a.out else f'capture-{int(time.time())}-{i}.png')
                path.write_bytes(base64.b64decode(item.pop('data')))
                item['saved_path'] = str(path)
        payload = json.dumps(result, ensure_ascii=False, indent=2)
        if a.out:
            Path(a.out).parent.mkdir(parents=True, exist_ok=True)
            Path(a.out).write_text(payload, encoding='utf-8')
        print(payload)
    finally:
        proc.terminate()


if __name__ == '__main__':
    main()
