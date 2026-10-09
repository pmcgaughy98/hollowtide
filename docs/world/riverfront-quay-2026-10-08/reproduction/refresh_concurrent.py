from pathlib import Path
import shutil,hashlib
W=Path(__file__).parent; L=Path('C:/Users/pmcga/dev/hollowtide'); C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
keep={'scripts/area_landscape.gd','scripts/world_area.gd','scripts/riverfront_quay.gd','tools/debug/riverfront_quay_check.gd'}
count=0
for folder in ['assets','scripts','scenes','data','tools']:
 for p in (L/folder).rglob('*'):
  if not p.is_file() or '__pycache__' in p.parts:continue
  rel=p.relative_to(L)
  if rel.as_posix() in keep:continue
  dst=C/rel
  if not dst.exists() or p.read_bytes()!=dst.read_bytes():
   dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst);count+=1
print('Refreshed',count,'concurrent files; kept staged quay edits and live originals')
