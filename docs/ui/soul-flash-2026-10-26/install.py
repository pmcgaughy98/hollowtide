from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');rel='scripts/soul_prologue.gd'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text());assert sha(L/rel)==base[rel], 'Owned source changed; rebase first.'
assert json.loads((W/'before-result.json').read_text())['failed']==0
(W/'concurrent-at-install.json').write_text(json.dumps([p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h],indent=2))
(L/rel).write_bytes((W/'prepared'/rel).read_bytes());(W/'installed-files.json').write_text(json.dumps({rel:sha(L/rel)},indent=2));print('Installed only',rel)
