from pathlib import Path
import shutil
W=Path(__file__).parent; C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
previous=Path('D:/dev/hollowtide-menu-hookup-20261009')
for name in ['menu_check.gd','quit_title.gd','quit_pause.gd','live_check.py']:
    text=(previous/name).read_text().replace('D:/dev/hollowtide-menu-hookup-20261009','D:/dev/hollowtide-hall-door-20261010')
    if name=='menu_check.gd':
        text=text.replace('await pad(JOY_BUTTON_DPAD_DOWN); await pad(JOY_BUTTON_A)','await pad(JOY_BUTTON_DPAD_DOWN); await pad(JOY_BUTTON_DPAD_DOWN); await pad(JOY_BUTTON_DPAD_DOWN); await pad(JOY_BUTTON_A)')
        text=text.replace('verify("Controller D-pad and A open Options"','verify("Controller D-pad traverses Team/Bag and A opens Options"')
        text=text.replace('var dungeon: Node=current_scene\n\tp=dungeon.get_node','var dungeon: Node=current_scene\n\tverify("Dungeon defaults to turn-based combat",not dungeon.real_time_battles)\n\tp=dungeon.get_node')
        text=text.replace('\tverify("Music remains available in paused Options",music.process_mode==Node.PROCESS_MODE_ALWAYS)','\tverify("Music remains available in paused Options",music.process_mode==Node.PROCESS_MODE_ALWAYS)\n\tverify("All dungeon main buttons fit viewport",p.content.get_parent().get_global_rect().end.y<=648)\n\tawait choose(p,"Team"); verify("Claude Team page retained",p.page=="team" and p.content.get_children().any(func(n:Node)->bool:return n is Label and n.text.contains("KITHFLARE")))\n\tawait key(KEY_ESCAPE); await choose(p,"Bag"); verify("Claude Bag page retained",p.content.has_node("Use_reedberry"))\n\tawait key(KEY_ESCAPE); await choose(p,"Floor"); verify("Claude Floor page retained",p.page=="floor")\n\tawait key(KEY_ESCAPE); await choose(p,"Log"); verify("Claude Log page retained",p.page=="log")\n\tawait key(KEY_ESCAPE)')
        text=text.replace('dungeon.in_battle=true; dungeon._start_battle()','dungeon.real_time_battles=true; dungeon.in_battle=true; dungeon._start_battle()')
        text=text.replace('# Deterministically enter the existing hybrid fight, without changing any production rules.','# Review-only optional-mode fixture; production still defaults to turn based.')
    (W/name).write_text(text)
text=(W/'originals/scripts/town/highbank_ground_painter.gd').read_text().replace('res://scripts/town/wayline_hall_painter.gd','res://tools/debug/hall_original_art.gd')
(C/'tools/debug/hall_ground_before.gd').write_text(text)
shutil.copy2(W/'originals/scripts/town/wayline_hall_painter.gd',C/'tools/debug/hall_original_art.gd')
shutil.copy2(W/'originals/scripts/town/highbank_ground_painter.gd',W/'hall_ground_before.gd')
shutil.copy2(W/'originals/scripts/town/wayline_hall_painter.gd',W/'hall_original_art.gd')
print('Prepared updated native regression and original exterior baseline.')
