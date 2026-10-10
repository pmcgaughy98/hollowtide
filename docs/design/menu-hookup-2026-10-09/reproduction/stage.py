from pathlib import Path
import shutil
W=Path(__file__).parent
L=Path('C:/Users/pmcga/dev/hollowtide')
for rel in ['scripts/town/hub_town.gd','scripts/dungeon/dungeon.gd','scripts/creature_opening.gd','scripts/creature_prologue.gd']:
    src=L/rel
    backup=W/'originals'/rel
    backup.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(src,backup)
    text=src.read_text()
    if rel.endswith(('hub_town.gd','dungeon.gd')):
        text=text.replace('\t_music_update()','\t_music_update()\n\tpreload("res://scripts/ui/game_pause_menu.gd").attach(self)',1)
    elif rel.endswith('creature_opening.gd'):
        text=text.replace('\tsuper._ready()','\t# Fade the shared town/dungeon player when returning to this local title theme.\n\tpreload("res://scripts/audio/music.gd").play(get_tree(), "")\n\tsuper._ready()',1)
        text=text.replace('\tawait create_tween().tween_property(_fade,"color:a",1.0,0.2 if _reduce_motion else 0.6).finished','\tvar fade := create_tween().set_parallel(true)\n\tvar seconds := 0.2 if _reduce_motion else 0.6\n\tfade.tween_property(_fade,"color:a",1.0,seconds)\n\tif _music != null: fade.tween_property(_music,"volume_db",-80.0,seconds)\n\tawait fade.finished',1)
        text=text.replace('\t\t_leaving=false','\t\t_leaving=false\n\t\tif _music != null: _music.volume_db = 0.0',1)
    else:
        text=text.replace('## Playable opening proposal: awakening, another survivor, then the first Hollow.','## Playable opening proposal: awakening, another survivor, then Highbank.')
        text=text.replace('## Identity and party are passed into the existing dungeon; no save/state rewrite.','## Identity and party are passed into the existing town; no save/state rewrite.')
        text=text.replace('A worn stair leads deeper beneath the bank.\\nTake one step at a time. Watch each other as you go.','A break in the clay opens onto the path to Highbank.\\nFollow the village lights. Watch each other as you go.')
        text=text.replace('Enter the Hollow together','Reach Highbank together').replace('The Hollow could not open.','Highbank could not open.')
    target=W/'candidate'/rel
    target.parent.mkdir(parents=True,exist_ok=True)
    target.write_text(text)
ground=W/'candidate/scripts/town/highbank_ground_painter.gd'
if ground.exists(): ground.unlink()
print('Staged four bounded hooks; protected their current source originals.')
