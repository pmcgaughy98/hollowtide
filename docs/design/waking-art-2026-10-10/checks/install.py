from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');P=L/'docs/design/waking-art-2026-10-10'
d=json.loads((W/'install-manifest.json').read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for r,m in d['files'].items():
 if m['before'] is None:assert not (L/r).exists(),f'New concurrent path: {r}'
 else:assert sha(L/r)==m['before'],f'Concurrent owned edit: {r}'
 assert sha(W/'package/candidate'/r)==m['candidate'],r
assert not P.exists(),'Archive already exists; do not overwrite it.'
assert sha(L/'scripts/town/hub_town.gd')==d['preserved_claude_town'],'Concurrent town changed; reread before install.'
shutil.copytree(W/'package',P)
for r in d['files']:
 p=L/r;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(W/'package/candidate'/r,p)
print('Installed',len(d['files']),'scoped files, original backups and source/prompt/check archive. Claude town retained.')
