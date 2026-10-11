from pathlib import Path
import shutil,hashlib,json
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
owned=['scripts/town/room_painter.gd','scripts/town/town_room.gd']
protected=['scripts/town/hall_room_art.gd','scripts/town/home_room_art.gd','scripts/town/town_layout.gd','scripts/town/guild_scene.gd','scripts/town/scene_kit.gd','scripts/town/hub_town.gd','scripts/town/team_state.gd','scripts/town/evolution.gd','scripts/dungeon/dungeon.gd','scripts/ui/game_pause_menu.gd','scripts/ui/bag_page.gd','scripts/arena/creature_finish.gd','scripts/arena/creature_finish.gdshader','scripts/arena/starward_finish.gdshader','assets/sprites/world/guild_desk/desk_detail_2026_10_10.png','assets/sprites/world/waking_bank_2026_10_10/waking_native.png','assets/sprites/arena/starward/portrait.png','assets/sprites/arena/oxbowarchon/sw.png']
protected += [str(p.relative_to(L)).replace('\\','/') for folder in ['hall_interior_2026_10_10','home_interior_2026_10_10'] for p in (L/'assets/sprites/world'/folder).glob('*.png')]
hashes={rel:hashlib.sha256((L/rel).read_bytes()).hexdigest() for rel in owned+protected if (L/rel).exists()}
(W/'before-hashes.json').write_text(json.dumps(hashes,indent=2),encoding='utf-8')
for rel in owned:
    dst=W/'originals'/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dst)
for folder in ['scripts','scenes']:shutil.copytree(L/folder,C/folder,dirs_exist_ok=True)
for name in ['whole_hall.png','whole_hall_low.png','whole_chamber.png']:
    shutil.copy2(L/'docs/design/hall-floors-2026-10-10'/name,W/name)
shutil.copy2(Path('D:/dev/hollowtide-bag-finish-20261010/run.py'),W/'run.py')
for name in ['hall_floors_check.gd','town_room_check.gd','guild_scene_check.gd']:
    t=(L/'tools/debug'/name).read_text(encoding='utf-8')
    if 'const OUT :=' in t:
        a=t.index('const OUT :=');b=t.index('\n',a)
        t=t[:a]+'const OUT := "D:/dev/hollowtide-hall-floors-finish-20261011/"'+t[b:]
    t=t.replace('\tquit(', '\tfor child in root.get_children(): child.queue_free()\n\tload("res://scripts/audio/music.gd")._inst = null\n\tawait _frames(16)\n\tquit(')
    (W/name.replace('_check','')).write_text(t,encoding='utf-8')
print('Current two-floor controller/painter archived and staged; original art and selected protected sources hashed.')
