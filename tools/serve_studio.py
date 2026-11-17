"""Workspace-only local file transport for Studio authoring; no game runtime dependency."""
from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
from pathlib import Path
import json
from urllib.parse import unquote, urlparse

ROOT=Path(__file__).resolve().parents[1]
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        path=(ROOT/unquote(urlparse(self.path).path).lstrip('/')).resolve()
        if not path.is_relative_to(ROOT) or not path.is_file():
            self.send_error(404); return
        raw=path.read_bytes()
        self.send_response(200);self.send_header('Content-Type','text/plain');self.end_headers();self.wfile.write(raw)
    def do_POST(self):
        name=Path(urlparse(self.path).path).name
        if not name.endswith('.json') or len(name)>100:
            self.send_error(400);return
        data=self.rfile.read(int(self.headers.get('Content-Length',0)))
        json.loads(data)
        folder=ROOT/'build/reports';folder.mkdir(parents=True,exist_ok=True)
        (folder/name).write_bytes(data)
        self.send_response(200);self.end_headers();self.wfile.write(b'ok')
    def log_message(self,*args):
        pass
print('Studio authoring transport on 127.0.0.1:8766',flush=True)
ThreadingHTTPServer(('127.0.0.1',8766),Handler).serve_forever()
