from pathlib import Path
import hashlib,json,shutil
root=Path(__file__).parent; live=Path('C:/Users/pmcga/dev/hollowtide'); stage=root/'project'
owned={'scripts/world_journey.gd','scripts/world_area.gd','scripts/area_landscape.gd','scripts/opening_flow.gd'}
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
baseline=json.loads((root/'baseline.json').read_text())
for name in owned: assert sha(live/name)==baseline[name], 'Owned file changed: '+name
changes=[]
for folder in ['assets','data','scripts','scenes','tools']:
    for p in (live/folder).rglob('*'):
        if not p.is_file() or '__pycache__' in p.parts:continue
        rel=p.relative_to(live); name=rel.as_posix()
        if name in owned or name.startswith('assets/sprites/arena/galeshear/'): continue
        dst=stage/rel
        if dst.exists() and sha(dst)==sha(p):continue
        dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst)
        changes.append(name)
config=(live/'project.godot').read_text()
config=config.replace('config/name="Hollowtide"','config/name="Hollowtide World Review"').replace('_mcp_game_helper="*res://addons/godot_ai/runtime/game_helper.gd"\n','').replace('enabled=PackedStringArray("res://addons/godot_ai/plugin.cfg")','enabled=PackedStringArray()')
(stage/'project.godot').write_text(config)
(root/'latest-concurrent-refresh.json').write_text(json.dumps({'copied':changes,'live_main_scene':[s for s in config.splitlines() if s.startswith('run/main_scene')],'arena_sha256':sha(stage/'scripts/arena/arena_prototype.gd')},indent=2))
print('Refreshed',len(changes),'concurrent dependency files')
print('Code changes:',[x for x in changes if x.endswith(('.gd','.py','.tscn'))])
