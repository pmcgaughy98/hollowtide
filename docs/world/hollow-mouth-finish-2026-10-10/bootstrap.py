from pathlib import Path
W=Path(__file__).parent;old=Path('D:/dev/hollowtide-crossroads-20261010')
t=(old/'setup.py').read_text()
t=t[:t.index("old=Path('D:/dev/hollowtide-job-board")]+'''
old=Path('D:/dev/hollowtide-crossroads-20261010')
for name in ['run.py','live_check.py','install.ps1','audit.py','finalize.ps1']:
 t=(old/name).read_text().replace('hollowtide-crossroads-20261010','hollowtide-hollow-mouth-20261010').replace('crossroads-finish-2026-10-10','hollow-mouth-finish-2026-10-10').replace('Crossroads finish','Hollow entrance finish').replace('Crossroads archive','Hollow entrance archive')
 if name=='run.py':t=t.replace('crossroads_painter.gd','hollow_mouth_painter.gd')
 (W/name).write_text(t)
text=(W/'originals/scripts/town/hub_town.gd').read_text().replace('res://scripts/town/highbank_ground_painter.gd',(W/'originals/scripts/town/highbank_ground_painter.gd').as_posix())
(W/'baseline_hub.gd').write_text(text)
print('Baseline',len(baseline),'files, synced',copied)
'''
(W/'setup.py').write_text(t)
