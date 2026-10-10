from pathlib import Path
from PIL import Image
from collections import Counter
import json,hashlib
L=Path('C:/Users/pmcga/dev/hollowtide');W=Path(__file__).parent
assert not (W/'baseline.json').exists(),'Preserve the original baseline; do not recapture it after installation.'
paths=['assets/sprites/creatures/idle_2026_10_10/sparkwick_palette_locked/f0.png','assets/sprites/creatures/idle_2026_10_10/sparkwick_palette_locked/f3.png','assets/sprites/creatures/kithflare_line_2026_10_05/kithflare2_front.png','docs/creatures/arena-starters-2026-10-07/forms/sparkwick.png','assets/sprites/arena/sparkwick/s.png','assets/sprites/arena/sparkwick/w.png']
for r in paths:
 im=Image.open(L/r).convert('RGBA');c=Counter(tuple(p[:3]) for p in im.getdata() if p[3]>0)
 print(r,im.size,len(c),'colours',c.most_common(22))
base={}
for folder in ['assets','scripts','data','scenes','tools','docs']:
 for p in (L/folder).rglob('*'):
  if p.is_file() and p.suffix not in ['.uid','.import','.pyc']:
   base[p.relative_to(L).as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
(W/'baseline.json').write_text(json.dumps(base,indent=2))
