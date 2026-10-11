from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
files=[p for folder in ['scripts','data','scenes','assets','tools'] for p in (L/folder).rglob('*') if p.is_file() and p.suffix not in ['.import','.uid']]
files += [L/'project.godot',L/'docs/AI_COLLABORATION.md',L/'docs/team/CODEX_HANDOFF_2026-10-10.md']
def sync(p):
    raw=p.read_bytes();r=p.relative_to(L).as_posix();h=hashlib.sha256(raw).hexdigest()
    if r!='docs/AI_COLLABORATION.md' and not r.startswith('docs/team/'):
        q=C/r
        if not q.exists() or hashlib.sha256(q.read_bytes()).hexdigest()!=h:q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(raw)
    return r,h
with ThreadPoolExecutor(max_workers=12) as pool:baseline=dict(pool.map(sync,files))
(W/'baseline.json').write_text(json.dumps(baseline,indent=2),encoding='utf-8')
for r in ['scripts/main_menu.gd','scripts/creature_opening.gd','scripts/creature_prologue.gd','scripts/first_partner_arrival.gd','docs/AI_COLLABORATION.md','docs/team/CODEX_HANDOFF_2026-10-10.md']:
    q=W/'originals'/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,q)
shutil.copy2(Path('D:/dev/hollowtide-hall-interior-20261010/run.py'),W/'run.py')
print('Synced current project;',len(baseline),'protected hashes.')
