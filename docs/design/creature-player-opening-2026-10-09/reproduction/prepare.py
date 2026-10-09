from pathlib import Path
import shutil,hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
guard={}
for folder in ['assets','scripts','scenes','data','tools']:
 for p in (L/folder).rglob('*'):
  if not p.is_file() or p.suffix in ['.pyc'] or '__pycache__' in p.parts:continue
  r=p.relative_to(L);d=C/r
  if not d.exists() or p.read_bytes()!=d.read_bytes():d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,d)
  if p.suffix not in ['.import','.uid']:guard[r.as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
for r in ['project.godot','scripts/dungeon/floor_painter.gd']:
 p=W/'originals'/r;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/r,p)
 guard[r]=hashlib.sha256((L/r).read_bytes()).hexdigest()
cfg=(L/'project.godot').read_text().replace('_mcp_game_helper="*res://addons/godot_ai/runtime/game_helper.gd"','').replace('enabled=PackedStringArray("res://addons/godot_ai/plugin.cfg")','enabled=PackedStringArray()')
(C/'project.godot').write_text(cfg)
(W/'baseline.json').write_text(json.dumps(guard,indent=2))
print('Refreshed isolated project and backed up painter/settings')
