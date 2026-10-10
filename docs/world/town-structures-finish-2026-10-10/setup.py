from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
files=[p for folder in ['scripts','data','scenes','assets','tools'] for p in (L/folder).rglob('*') if p.is_file() and p.suffix not in ['.import','.uid']]
files += [L/'project.godot',L/'docs/AI_COLLABORATION.md',L/'docs/team/CODEX_HANDOFF_2026-10-10.md']
def save(p):
 raw=p.read_bytes();r=p.relative_to(L).as_posix();h=hashlib.sha256(raw).hexdigest()
 if r.startswith(('scripts/','data/','scenes/','assets/')) or r=='project.godot':
  q=C/r
  if not q.exists() or hashlib.sha256(q.read_bytes()).hexdigest()!=h:q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(raw)
 return r,h
with ThreadPoolExecutor(max_workers=12) as pool:baseline=dict(pool.map(save,files))
(W/'baseline.json').write_text(json.dumps(baseline,indent=2),encoding='utf-8')
for r in ['scripts/town/building_exteriors.gd','scripts/town/job_board_painter.gd','docs/AI_COLLABORATION.md']:
 q=W/'originals'/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,q)
shutil.copy2(Path('D:/dev/hollowtide-town-selout-20261010/run.py'),W/'run.py')
source=(W/'run.py').read_text(encoding='utf-8')
# Existing valid imported resources stay in the review project; no full asset reimport.
(W/'run.py').write_text(source,encoding='utf-8')
print('Synced current review source and guarded',len(baseline),'files.')
