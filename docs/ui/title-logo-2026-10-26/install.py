from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');rel='scripts/opening_flow.gd'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text())
assert sha(L/rel)==base[rel], 'Owned file changed; rebase before installing.'
assert json.loads((W/'before-result.json').read_text())['failed']==0
concurrent=[p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h]
(W/'concurrent-at-install.json').write_text(json.dumps(concurrent,indent=2))
(L/rel).write_bytes((W/'prepared'/rel).read_bytes())
(W/'installed-files.json').write_text(json.dumps({rel:sha(L/rel)},indent=2))
print('Installed only',rel,'with fresh hash guard. Concurrent paths:',concurrent)
