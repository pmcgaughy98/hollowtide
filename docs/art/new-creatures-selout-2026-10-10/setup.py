from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import hashlib,json,shutil,re
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
files=[p for folder in ['scripts','data','scenes','assets','tools','docs/creatures/arena-starters-2026-10-07/forms'] for p in (L/folder).rglob('*') if p.is_file() and p.suffix not in ['.import','.uid']]
files += [L/'project.godot',L/'docs/AI_COLLABORATION.md',L/'docs/team/CODEX_HANDOFF_2026-10-10.md']
def sync(p):
    r=p.relative_to(L).as_posix();raw=p.read_bytes();h=hashlib.sha256(raw).hexdigest()
    if r.startswith(('scripts/','data/','scenes/','tools/')) or r=='project.godot' or any(r.startswith('assets/sprites/arena/'+f+'/') or r.startswith('assets/sprites/ui/dialogue/'+f) for f in ['skimlet','ozbender','valvekin']):
        q=C/r
        if not q.exists() or sha(q)!=h:q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(raw)
    return r,h
with ThreadPoolExecutor(max_workers=12) as pool:baseline=dict(pool.map(sync,files))
(W/'baseline.json').write_text(json.dumps(baseline,indent=2))
for r in ['scripts/arena/creature_finish.gd','scripts/ui/party_screen.gd','docs/AI_COLLABORATION.md']:
    q=W/'originals'/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,q)
def imports(p):
    r=p.relative_to(L);q=C/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
    for ref in re.findall(r'"res://(\.godot/imported/[^\"]+)"',p.read_text()):
        src=L/ref;dst=C/ref
        if src.is_file():dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
paths=[p for f in ['skimlet','ozbender','valvekin'] for p in (L/'assets/sprites/arena'/f).rglob('*.import')]
paths += list((L/'assets/sprites/ui/dialogue').glob('*.import'))
with ThreadPoolExecutor(max_workers=12) as pool:list(pool.map(imports,paths))
shutil.copy2(Path('D:/dev/hollowtide-new-scene-selout-20261010/run.py'),W/'run.py')
print('Snapshotted',len(baseline),'protected files; synced current code and three new creature sets.')
