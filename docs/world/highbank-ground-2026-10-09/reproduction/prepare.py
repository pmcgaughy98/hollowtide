from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def cp(s,d):d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(s,d)
baseline={}
for folder in ['scripts','scenes','assets','data']:
    for p in (L/folder).rglob('*'):
        if p.is_file() and p.suffix not in ['.import','.uid','.pyc']:
            baseline[p.relative_to(L).as_posix()]=sha(p)
for r in ['docs/AI_COLLABORATION.md','docs/team/CODEX_HANDOFF_2026-10-10.md','project.godot']:
    baseline[r]=sha(L/r);cp(L/r,W/'originals'/r)
for folder in ['scripts','scenes','data','tools']:
    for p in (L/folder).rglob('*'):
        if p.is_file() and p.suffix!='.pyc' and '__pycache__' not in p.parts:
            d=C/p.relative_to(L)
            if not d.exists() or sha(p)!=sha(d):cp(p,d)
for r in ['scripts/town/hub_town.gd','scripts/town/town_layout.gd','scripts/town/team_state.gd','scripts/creature_prologue.gd','scripts/dungeon/dungeon.gd']:
    cp(L/r,W/'originals'/r)
cp(L/'scripts/town/hub_town.gd',W/'candidate/scripts/town/hub_town.gd')
(W/'baseline.json').write_text(json.dumps(baseline,indent=2))
print('Protected',len(baseline),'existing files; review dependencies synced')
