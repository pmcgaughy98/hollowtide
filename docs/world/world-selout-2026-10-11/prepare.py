from pathlib import Path
import shutil,hashlib,json
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide');C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
owned=['scripts/town/highbank_painter.gd','scripts/town/hub_town.gd']
protected=['scripts/town/town_layout.gd','scripts/town/world_tile_art.gd','scripts/town/town_detail_art.gd','scripts/town/building_exteriors.gd','scripts/town/landmark_exteriors.gd','scripts/town/exterior_finish.gd','scripts/town/town_room.gd','scripts/town/room_painter.gd','scripts/town/hall_floors_art.gd','scripts/town/team_state.gd','scripts/town/jobs.gd','scripts/dungeon/dungeon_finish.gd','scripts/art/selout.gd','scripts/arena/creature_finish.gd','scripts/arena/starward_finish.gdshader']
protected += [str(p.relative_to(L)).replace('\\','/') for folder in ['world_tiles_2026_10_10','town_detail_2026_10_10','hall_floors_2026_10_11','guild_desk'] for p in (L/'assets/sprites/world'/folder).glob('*.png')]
hashes={rel:hashlib.sha256((L/rel).read_bytes()).hexdigest() for rel in owned+protected}
(W/'before-hashes.json').write_text(json.dumps(hashes,indent=2),encoding='utf-8')
for rel in owned:
    dst=W/'originals'/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dst)
for folder in ['scripts','scenes']:shutil.copytree(L/folder,C/folder,dirs_exist_ok=True)
shutil.copy2(L/'project.godot',C/'project.godot')
shutil.copy2(Path('D:/dev/hollowtide-hall-floors-finish-20261011/run.py'),W/'run.py')
for name in ['hub_town_check','town_walk_check','hall_door_check','dungeons_check']:
    t=(L/'tools/debug'/(name+'.gd')).read_text(encoding='utf-8')
    if 'const OUT :=' in t:
        a=t.index('const OUT :=');b=t.index('\n',a)
        t=t[:a]+'const OUT := "D:/dev/hollowtide-world-selout-20261011/"'+t[b:]
    if 'func _frames(' not in t:t+='\nfunc _frames(n: int) -> void:\n\tfor k in n:\n\t\tawait process_frame\n'
    t=t.replace('\tquit(', '\tfor child in root.get_children(): child.queue_free()\n\tload("res://scripts/audio/music.gd")._inst = null\n\tawait _frames(16)\n\tquit(')
    (W/(name+'.gd')).write_text(t,encoding='utf-8')
print('Current sources staged; 2 owned originals and protected terrain/Hall art hashed.')
