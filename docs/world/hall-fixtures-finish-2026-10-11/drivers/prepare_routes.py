from pathlib import Path
W=Path(__file__).parent;C=Path('C:/Users/pmcga/dev/hollowtide')
t=(C/'tools/debug/hall_floors_check.gd').read_text()
t=t.replace('const OUT := "res://docs/design/hall-floors-2026-10-10/"','const OUT := "D:/dev/hollowtide-hall-fixtures-20261011/review/routes/"')
t=t.replace('\tquit(1 if fails else 0)','\tfor child in root.get_children():child.queue_free()\n\tload("res://scripts/audio/music.gd")._inst=null\n\tawait _frames(16)\n\tquit(1 if fails else 0)')
(W/'review/routes').mkdir(parents=True,exist_ok=True)
(W/'hall_floors.gd').write_text(t)
print('Current 13-assertion Hall route check isolated; assertions unchanged.')
