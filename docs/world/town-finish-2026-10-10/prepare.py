from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
files={}
for folder in ['scripts','scenes','assets','data','tools']:
    for p in (L/folder).rglob('*'):
        if p.is_file() and p.suffix not in ['.uid','.import','.pyc']:
            files[p.relative_to(L).as_posix()]=sha(p)
for rel in ['project.godot','docs/AI_COLLABORATION.md','docs/team/CODEX_HANDOFF_2026-10-10.md','docs/team/CODEX_TOWN_FINISH_BRIEF_2026-10-10.md']:
    files[rel]=sha(L/rel)
(W/'baseline.json').write_text(json.dumps(files,indent=2))
for rel in ['scripts/town/hub_town.gd','scripts/town/home_painter.gd','scripts/town/item_shop_painter.gd','scripts/town/highbank_ground_painter.gd','scripts/town/town_layout.gd','docs/AI_COLLABORATION.md','docs/team/CODEX_TOWN_FINISH_BRIEF_2026-10-10.md']:
    p=W/'originals'/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,p)
for folder in ['scripts','scenes','data','tools']:
    shutil.copytree(L/folder,C/folder,dirs_exist_ok=True)
# Review copy assets only flow from the live project. Never back to it.
for rel in files:
    if rel.startswith('assets/'):
        target=C/rel
        if not target.exists() or sha(target)!=files[rel]:
            target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,target)
shutil.copy2(L/'project.godot',C/'project.godot')
(W/'candidate/scripts/town').mkdir(parents=True,exist_ok=True)
(W/'review').mkdir(exist_ok=True)
print('Protected',len(files),'live files; synced latest review dependencies.')
