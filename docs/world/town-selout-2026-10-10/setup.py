from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import hashlib,json,shutil,re,os
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
paths=[p for folder in ['scripts','data','scenes','assets','tools'] for p in (L/folder).rglob('*') if p.is_file() and p.suffix not in ['.import','.uid']]
paths += [L/'project.godot',L/'docs/AI_COLLABORATION.md',L/'docs/team/CODEX_HANDOFF_2026-10-10.md']
def sync(p):
 raw=p.read_bytes();r=p.relative_to(L).as_posix();h=hashlib.sha256(raw).hexdigest()
 if r.startswith(('scripts/','data/','scenes/','assets/')) or r=='project.godot':
  q=C/r
  if not q.exists() or hashlib.sha256(q.read_bytes()).hexdigest()!=h:
   q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(raw)
 return r,h
with ThreadPoolExecutor(max_workers=12) as pool: baseline=dict(pool.map(sync,paths))
(W/'baseline.json').write_text(json.dumps(baseline,indent=2),encoding='utf-8')
owned=['scripts/arena/sel_out.gdshaderinc','scripts/town/building_exteriors.gd','scripts/town/growth_shrine_painter.gd','scripts/town/training_yard_painter.gd','scripts/town/job_board_painter.gd','scripts/town/hollow_mouth_painter.gd','docs/AI_COLLABORATION.md']
for r in owned:
 q=W/'originals'/r;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,q)
def cache(p):
 q=C/p.relative_to(L);q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
 for ref in re.findall(r'"res://(\.godot/imported/[^\"]+)"',p.read_text(encoding='utf-8')):
  src=L/ref;dst=C/ref
  if src.exists() and (not dst.exists() or src.stat().st_mtime_ns!=dst.stat().st_mtime_ns or src.stat().st_size!=dst.stat().st_size):
   dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
 source=Path(str(p)[:-7]);target=Path(str(q)[:-7])
 if source.exists() and target.exists(): os.utime(target,ns=(source.stat().st_atime_ns,source.stat().st_mtime_ns))
with ThreadPoolExecutor(max_workers=12) as pool:list(pool.map(cache,(L/'assets').rglob('*.import')))
print('Guarded and synced',len(baseline),'active sources; original owned files saved.')
