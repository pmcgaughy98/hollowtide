from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');rel='export_presets.cfg'
owned=json.loads((W/'installed-files.json').read_text());assert hashlib.sha256((L/rel).read_bytes()).hexdigest()==owned[rel]
s=(L/rel).read_text().replace('builds/*,icon.svg','builds/*,icon.svg,docs/*.gd,docs/*.tscn,docs/*.tres,docs/*.gdshader')
(L/rel).write_text(s,encoding='utf-8');(W/'prepared'/rel).write_text(s,encoding='utf-8');owned[rel]=hashlib.sha256((L/rel).read_bytes()).hexdigest();(W/'installed-files.json').write_text(json.dumps(owned,indent=2))
