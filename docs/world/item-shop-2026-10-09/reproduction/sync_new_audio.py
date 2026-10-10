from pathlib import Path
import shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def cp(s,d):d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(s,d)
for p in (L/'scripts/audio').rglob('*'):
    if p.is_file():cp(p,C/p.relative_to(L))
for name in ['highbank','wayline_hall','ferry_landing']:
    r='assets/audio/music/'+name+'.mp3';cp(L/r,C/r)
print('Synced new Claude music helper and three town tracks to isolated review only')
