from pathlib import Path
import hashlib, json, shutil
LIVE = Path('C:/Users/pmcga/dev/hollowtide')
ROOT = Path('D:/dev/hollowtide-world-refinement-20261008')
STAGE = ROOT/'project'
ROOT.mkdir(parents=True,exist_ok=True)
owned = ['scripts/world_journey.gd','scripts/world_area.gd','scripts/area_landscape.gd']
guarded = owned + ['project.godot','scripts/arena/arena_prototype.gd','scripts/arena/arena_signature.gd','scripts/opening_flow.gd','scripts/first_route_prototype.gd','scripts/main_menu.gd','scripts/main_menu_art_preview.gd','tools/arena/build_small.py','tools/arena/slice_rotations.py']
baseline = {}
for name in guarded:
    data=(LIVE/name).read_bytes()
    baseline[name]=hashlib.sha256(data).hexdigest()
    out=ROOT/'originals'/name
    out.parent.mkdir(parents=True,exist_ok=True)
    out.write_bytes(data)
(ROOT/'baseline.json').write_text(json.dumps(baseline,indent=2))
for name in ['assets','data','scenes','scripts','addons','tools']:
    shutil.copytree(LIVE/name,STAGE/name,dirs_exist_ok=True,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
for name in ['project.godot','icon.svg','default_bus_layout.tres']:
    shutil.copy2(LIVE/name,STAGE/name)
shutil.copytree(Path('D:/dev/hollowtide-opening-20261008/project/.godot'),STAGE/'.godot',dirs_exist_ok=True)
config=(STAGE/'project.godot').read_text()
config=config.replace('config/name="Hollowtide"','config/name="Hollowtide World Review"')
config=config.replace('_mcp_game_helper="*res://addons/godot_ai/runtime/game_helper.gd"\n','')
config=config.replace('enabled=PackedStringArray("res://addons/godot_ai/plugin.cfg")','enabled=PackedStringArray()')
(STAGE/'project.godot').write_text(config)
(ROOT/'review').mkdir(exist_ok=True)
print('Prepared world review',STAGE)
