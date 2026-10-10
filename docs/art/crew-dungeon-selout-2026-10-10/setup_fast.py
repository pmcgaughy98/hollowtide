from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import shutil,hashlib,json,re
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
files=[]
for folder in ['scripts','data','scenes','assets','tools']:
 files += [p for p in (L/folder).rglob('*') if p.is_file() and p.suffix not in ['.import','.uid']]
for folder in ['docs/creatures/arena-starters-2026-10-07/forms','docs/creatures/arena-starters-2026-10-07/walk','docs/creatures/actions-2026-10-09']:
 files += [p for p in (L/folder).rglob('*') if p.is_file() and p.suffix != '.import']
files.append(L/'docs/AI_COLLABORATION.md');files.append(L/'project.godot')
def save(p):
 raw=p.read_bytes();r=p.relative_to(L).as_posix();digest=hashlib.sha256(raw).hexdigest()
 if r.startswith(('scripts/','data/','scenes/','assets/')):
  q=C/r
  if not q.exists() or q.stat().st_size != len(raw) or hashlib.sha256(q.read_bytes()).hexdigest()!=digest:
   q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(raw)
 return r,digest
print('Hashing and syncing',len(files),'active files / crew source takes.',flush=True)
with ThreadPoolExecutor(max_workers=12) as pool:baseline=dict(pool.map(save,files))
(W/'baseline.json').write_text(json.dumps(baseline,indent=2))
# Review cache only: discard metadata pointing to an absent ctex, so the editor imports it.
missing=0
for p in (C/'assets').rglob('*.import'):
 m=re.search(r'^path="res://([^"]+)"',p.read_text(),re.M)
 if m and not (C/m.group(1)).exists():p.unlink();missing+=1
print('Guard complete; removed',missing,'invalid review import references.',flush=True)
