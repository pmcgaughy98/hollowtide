from pathlib import Path
import shutil,json,hashlib
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
guard={}
for r in json.loads((W/'concurrent-changes.json').read_text()):
    if (L/r).exists():
        shutil.copy2(L/r,C/r)
        guard[r]=hashlib.sha256((L/r).read_bytes()).hexdigest()
    else:
        guard[r]=None  # Removed debug probe; no production dependency.
(W/'concurrent-refresh.json').write_text(json.dumps(guard,indent=2))
test=(L/'tools/debug/dungeon_check.gd').read_text().replace('res://docs/design/dungeon-slice-2026-10-09/',str(W.as_posix())+'/turn-regression/')
(W/'turn_check.gd').write_text(test)
print('Refreshed concurrent dependencies; prepared current turn-based regression')
