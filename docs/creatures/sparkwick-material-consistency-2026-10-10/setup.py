from pathlib import Path
import shutil,hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
owned=['scripts/arena/sel_out.gdshaderinc','scripts/arena/creature_finish.gd','scripts/ui/party_screen.gd','scripts/ui/evolution_scene.gd']
for r in owned:
 p=W/'originals'/r;p.parent.mkdir(parents=True,exist_ok=True);assert not p.exists();shutil.copy2(L/r,p)
 p=W/'candidate'/r;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,p)
 # Sync only current scripts needed by this fixture; never write review code back to live.
for folder in ['scripts','data','scenes']:
 for p in (L/folder).rglob('*'):
  if p.is_file():
   q=C/p.relative_to(L)
   if not q.exists() or p.read_bytes()!=q.read_bytes():q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
(W/'review').mkdir(exist_ok=True)
print('Saved four exact originals; current review code synced.')
