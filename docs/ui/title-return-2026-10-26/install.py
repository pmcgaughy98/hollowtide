from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text());owned=['scripts/opening_flow.gd','scripts/creature_opening.gd']
for rel in owned:assert sha(L/rel)==base[rel],rel
assert json.loads((W/'before-result.json').read_text())['failed']==0
for rel in owned:(L/rel).write_bytes((W/'prepared'/rel).read_bytes())
(W/'installed-files.json').write_text(json.dumps({rel:sha(L/rel) for rel in owned},indent=2));print('Installed two hash-guarded title files.')
