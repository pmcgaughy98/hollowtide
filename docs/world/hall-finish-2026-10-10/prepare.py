from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
baseline={}
for folder in ['scripts','scenes','assets','data','tools']:
    for p in (L/folder).rglob('*'):
        if p.is_file() and p.suffix not in ['.uid','.import','.pyc']:baseline[p.relative_to(L).as_posix()]=sha(p)
for rel in ['project.godot','docs/AI_COLLABORATION.md','docs/team/CODEX_TOWN_FINISH_BRIEF_2026-10-10.md']:baseline[rel]=sha(L/rel)
(W/'baseline.json').write_text(json.dumps(baseline,indent=2))
for rel in ['scripts/town/building_exteriors.gd','scripts/town/wayline_hall_painter.gd','scripts/town/highbank_ground_painter.gd','scripts/town/hub_town.gd','scripts/town/town_layout.gd','assets/sprites/world/wayline_hall_2026_10_10/wayline_hall_native.png','assets/sprites/world/wayline_hall_2026_10_09/wayline_hall_native.png','docs/AI_COLLABORATION.md']:
    dest=W/'originals'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dest)
for folder in ['scripts','scenes','data','tools']:shutil.copytree(L/folder,C/folder,dirs_exist_ok=True)
for r,h in baseline.items():
    if r.startswith('assets/'):
        dest=C/r
        if not dest.exists() or sha(dest)!=h:dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,dest)
shutil.copy2(L/'project.godot',C/'project.godot')
(W/'candidate/scripts/town').mkdir(parents=True,exist_ok=True)
(W/'review').mkdir(exist_ok=True)
print('Protected',len(baseline),'files; synced current review dependencies.')
