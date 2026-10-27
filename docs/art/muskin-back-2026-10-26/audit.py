from pathlib import Path
from PIL import Image
import hashlib,json,shutil
import numpy as np
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
hashes={}
for p in (L/'assets/sprites/arena/muskin').rglob('*'):
 if p.is_file():
  rel=p.relative_to(L);hashes[rel.as_posix()]=sha(p);d=W/'originals'/rel;d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,d)
for p in (L/'docs/creatures/arena-starters-2026-10-07/walk').glob('muskin*'):
 if p.is_file():
  rel=p.relative_to(L);hashes[rel.as_posix()]=sha(p);d=W/'originals'/rel;d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,d)
protected={}
for folder in ('scripts','tools','scenes','data','dialogue'):
 for p in (L/folder).rglob('*'):
  if p.is_file() and p.suffix in ('.gd','.py','.tscn','.tres','.dialogue','.json'):protected[p.relative_to(L).as_posix()]=sha(p)
for name in ('project.godot','export_presets.cfg'):protected[name]=sha(L/name)
(W/'protected-before.json').write_text(json.dumps(protected,indent=2));(W/'muskin-before.json').write_text(json.dumps(hashes,indent=2))
stats=[]
for rel in hashes:
 p=L/rel
 if p.suffix!='.png':continue
 a=np.array(Image.open(p).convert('RGBA'));col=np.unique(a[a[:,:,3]>0][:,:3],axis=0)
 stats.append({'path':rel,'size':list(Image.open(p).size),'colours':len(col),'alpha_values':np.unique(a[:,:,3]).tolist()})
(W/'audit.json').write_text(json.dumps(stats,indent=2))
print(json.dumps([r for r in stats if r['path'].split('/')[-1] in ('n.png','s.png')],indent=2))
