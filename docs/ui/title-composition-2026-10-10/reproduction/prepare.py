from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def cp(s,d):d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(s,d)
baseline={}
for folder in ['scripts','scenes','assets','data']:
    for p in (L/folder).rglob('*'):
        if p.is_file() and p.suffix not in ['.import','.uid','.pyc']:baseline[p.relative_to(L).as_posix()]=sha(p)
for r in ['docs/AI_COLLABORATION.md','docs/team/CODEX_HANDOFF_2026-10-10.md','project.godot','scripts/creature_opening.gd']:
    baseline[r]=sha(L/r);cp(L/r,W/'originals'/r)
for folder in ['scripts','scenes','data','tools']:
    for p in (L/folder).rglob('*'):
        if p.is_file() and p.suffix!='.pyc':
            dst=C/p.relative_to(L)
            if not dst.exists() or sha(dst)!=sha(p):cp(p,dst)
cp(L/'scripts/creature_opening.gd',W/'candidate/scripts/creature_opening.gd')
(W/'baseline.json').write_text(json.dumps(baseline,indent=2))
prior=Path('D:/dev/hollowtide-title-refinement-20261010')
for name in ['run.py','live_check.py','title_check.gd','menu_check.gd','quit_title.gd']:
    (W/name).write_text((prior/name).read_text().replace('hollowtide-title-refinement-20261010','hollowtide-title-composition-20261010'))
(W/'review').mkdir(exist_ok=True)
print('Protected',len(baseline),'existing files; visual work isolated')
