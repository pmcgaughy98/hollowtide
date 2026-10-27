from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for rel,h in json.loads((W/'installed-files.json').read_text()).items():
 assert sha(L/rel)==sha(W/'originals'/rel),rel+' changed since snapshot'
 assert sha(W/'prepared'/rel)==h
for rel in json.loads((W/'installed-files.json').read_text()):shutil.copy2(W/'prepared'/rel,L/rel)
print('Installed only six guarded PNGs and their cutter.')
