from pathlib import Path
import hashlib, json, shutil

W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()

baseline=json.loads((W/'protected-before.json').read_text(encoding='utf-8'))
changed=[p for p,h in baseline.items() if not (L/p).is_file() or sha(L/p)!=h]
assert not changed, f'Protected files changed; reconcile before install: {changed}'
installed={}
for src in (W/'prepared').rglob('*'):
    if not src.is_file() or '__pycache__' in src.parts: continue
    rel=src.relative_to(W/'prepared').as_posix()
    assert rel=='tools/arena/build_portraits.py' or rel in [f'assets/sprites/arena/{f}/portrait.png' for f in ('skimlet','ozbender','valvekin')]
    dest=L/rel
    if 'portrait.png' in rel: assert not dest.exists()
    dest.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(src,dest)
    assert sha(src)==sha(dest)
    installed[rel]=sha(dest)
assert len(installed)==4
(W/'installed-files.json').write_text(json.dumps(installed,indent=2),encoding='utf-8')
print('Installed only three portraits and their three reproducible HEAD crop entries; all baseline files guarded.')
