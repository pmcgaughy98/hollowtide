from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');rel='scripts/soul_prologue.gd'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
installed=json.loads((W/'installed-files.json').read_text());assert sha(L/rel)==installed[rel]
s=(L/rel).read_text(encoding='utf-8');needle='\tget_tree().root.content_scale_aspect = _previous_aspect';assert s.count(needle)==1
s=s.replace(needle,'\t# A destination added before this node is freed may already have chosen its own policy.\n\tif get_tree().root.content_scale_aspect == Window.CONTENT_SCALE_ASPECT_EXPAND:\n\t\tget_tree().root.content_scale_aspect = _previous_aspect',1)
raw=(L/rel).read_bytes();nl=b'\r\n' if b'\r\n' in raw else b'\n';payload=s.encode().replace(b'\n',nl)
(W/'prepared'/rel).write_bytes(payload);(L/rel).write_bytes(payload);installed[rel]=sha(L/rel);(W/'installed-files.json').write_text(json.dumps(installed,indent=2));print('Scoped stretch restore guard installed.')
