from pathlib import Path
import hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((W/'protected-before.json').read_text());owned=[p.relative_to(W/'prepared').as_posix() for p in (W/'prepared').rglob('*.gd')]
for p in owned:assert sha(L/p)==base[p],('Owned source changed; rebase first',p)
assert json.loads((W/'before-result.json').read_text())['failed']==0
(W/'concurrent-at-install.json').write_text(json.dumps([p for p,h in base.items() if not (L/p).is_file() or sha(L/p)!=h],indent=2))
for p in owned:(L/p).write_bytes((W/'prepared'/p).read_bytes())
(W/'installed-files.json').write_text(json.dumps({p:sha(L/p) for p in owned},indent=2));print('Installed only',owned)
