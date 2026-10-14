from pathlib import Path
from http.server import SimpleHTTPRequestHandler,ThreadingHTTPServer
from functools import partial
root=Path('C:/Users/pmcga/dev/hollowtide/docs')
server=ThreadingHTTPServer(('127.0.0.1',8766),partial(SimpleHTTPRequestHandler,directory=str(root)))
print('Local review: http://127.0.0.1:8766/pitch/feedback-post-2026-10-14/index.html',flush=True)
server.serve_forever()
