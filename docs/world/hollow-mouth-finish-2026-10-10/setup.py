from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent; L=Path('C:/Users/pmcga/dev/hollowtide'); C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not (W/'baseline.json').exists(),'Already prepared; retain original baseline.'
baseline={}
for folder in ['scripts','scenes','assets','data','tools']:
 for p in (L/folder).rglob('*'):
  if p.is_file() and p.suffix not in ['.uid','.import','.pyc']:baseline[p.relative_to(L).as_posix()]=sha(p)
for r in ['project.godot','.gitignore','THE_CONCEPT.md','docs/AI_COLLABORATION.md','docs/team/CODEX_TOWN_FINISH_BRIEF_2026-10-10.md','docs/art/art-direction.md']:baseline[r]=sha(L/r)
(W/'baseline.json').write_text(json.dumps(baseline,indent=2))
for r in ['scripts/town/building_exteriors.gd','scripts/town/highbank_ground_painter.gd','scripts/town/hub_town.gd','scripts/town/town_layout.gd','docs/AI_COLLABORATION.md']:
 dest=W/'originals'/r;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,dest)
copied=0
for r,h in baseline.items():
 if r.startswith(('scripts/','scenes/','assets/','data/','tools/')) or r=='project.godot':
  dest=C/r
  if not dest.exists() or sha(dest)!=h:dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,dest);copied+=1
for r in ['candidate/scripts/town','review']:(W/r).mkdir(parents=True,exist_ok=True)
for r in ['scripts/town/building_exteriors.gd','scripts/town/highbank_ground_painter.gd']:shutil.copy2(W/'originals'/r,W/'candidate'/r)

old=Path('D:/dev/hollowtide-crossroads-20261010')
for name in ['run.py','live_check.py','install.ps1','audit.py','finalize.ps1']:
 t=(old/name).read_text().replace('hollowtide-crossroads-20261010','hollowtide-hollow-mouth-20261010').replace('crossroads-finish-2026-10-10','hollow-mouth-finish-2026-10-10').replace('Crossroads finish','Hollow entrance finish').replace('Crossroads archive','Hollow entrance archive')
 if name=='run.py':t=t.replace('crossroads_painter.gd','hollow_mouth_painter.gd')
 (W/name).write_text(t)
text=(W/'originals/scripts/town/hub_town.gd').read_text().replace('res://scripts/town/highbank_ground_painter.gd',(W/'originals/scripts/town/highbank_ground_painter.gd').as_posix())
(W/'baseline_hub.gd').write_text(text)
print('Baseline',len(baseline),'files, synced',copied)
