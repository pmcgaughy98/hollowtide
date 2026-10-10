from pathlib import Path
import shutil, hashlib, json
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
owned=['scripts/arena/sel_out.gdshaderinc','scripts/arena/creature_finish.gd','scripts/dungeon/dungeon.gd','scripts/ui/ui_style.gd']
for r in owned:
 p=W/'originals'/r;p.parent.mkdir(parents=True,exist_ok=True);assert not p.exists();shutil.copy2(L/r,p)
 p=W/'candidate'/r;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,p)
baseline={}
for folder in ['scripts','data','scenes','assets','tools','docs']:
 for p in (L/folder).rglob('*'):
  if not p.is_file() or '.git' in p.parts:continue
  r=p.relative_to(L).as_posix();baseline[r]=hashlib.sha256(p.read_bytes()).hexdigest()
  if folder in ['scripts','data','scenes','assets']:
   q=C/r
   if not q.exists() or p.read_bytes()!=q.read_bytes():q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
(W/'baseline.json').write_text(json.dumps(baseline,indent=2))
(W/'review').mkdir(exist_ok=True)
s=(L/'tools/debug/crew_capture.gd').read_text().replace('res://docs/design/rival-crew-2026-10-10/',W.as_posix()+'/review/before-')
# The capture's directory creation expects a directory; use separate before/after folders.
s=s.replace(W.as_posix()+'/review/before-',W.as_posix()+'/review/before/')
(W/'before_capture.gd').write_text(s)
print('Saved current originals, source hashes, and synced live code/art to review only.')
