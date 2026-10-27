from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');rel='scripts/storm_open.gd'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text());assert sha(L/rel)==base[rel]
assert json.loads((W/'before-result.json').read_text())['failed']==0
(L/rel).write_bytes((W/'prepared'/rel).read_bytes())
(W/'installed-files.json').write_text(json.dumps({rel:sha(L/rel)},indent=2));print('Installed storm_open.gd only.')
