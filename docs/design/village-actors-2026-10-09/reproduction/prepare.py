from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
baseline={}
for folder in ['scripts','scenes','data','assets','tools']:
    for p in (L/folder).rglob('*'):
        if not p.is_file() or p.suffix in ['.pyc'] or '__pycache__' in p.parts:continue
        r=p.relative_to(L)
        dst=C/r
        if not dst.is_file() or p.read_bytes()!=dst.read_bytes():
            dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst)
        if p.suffix not in ['.uid','.import']:baseline[r.as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
cfg=(L/'project.godot').read_text().replace('_mcp_game_helper="*res://addons/godot_ai/runtime/game_helper.gd"','').replace('enabled=PackedStringArray("res://addons/godot_ai/plugin.cfg")','enabled=PackedStringArray()')
(C/'project.godot').write_text(cfg)
for r in ['scripts/creature_opening.gd','project.godot']:
    dst=W/'originals'/r;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,dst)
    baseline[r]=hashlib.sha256((L/r).read_bytes()).hexdigest()
(W/'baseline.json').write_text(json.dumps(baseline,indent=2))
print('Review copy refreshed; menu/settings originals preserved')
