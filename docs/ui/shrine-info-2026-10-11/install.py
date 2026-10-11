from pathlib import Path
import hashlib,json,difflib
W=Path(__file__).parent
C=Path('C:/Users/pmcga/dev/hollowtide')
dest=C/'scripts/town/hub_town.gd'
old=dest.read_bytes()
text=old.decode('utf-8').replace('\r\n','\n')
assert 'ShrineInfo' not in text and 'shrine_info.gd' not in text, 'A live Shrine screen appeared; inspect it before installing.'
hooks=[
 ('\tpreload("res://scripts/ui/game_pause_menu.gd").attach(self)', '\tpreload("res://scripts/ui/game_pause_menu.gd").attach(self)\n\tpreload("res://scripts/ui/shrine_info.gd").attach(self)'),
 ('func _poll() -> void:\n', 'func _poll() -> void:\n\tif get_node("ShrineInfo").poll():\n\t\treturn\n'),
 ('\tUI.panel(h, Rect2(6, 6, 330, 54))', '\tif panel.get("service", "") in ["growth", "stone_ask", "evolve_ask"]:\n\t\treturn # The browsable ShrineInfo panel owns this presentation.\n\tUI.panel(h, Rect2(6, 6, 330, 54))')]
result=text
for anchor,replacement in hooks:
    assert result.count(anchor)==1, f'Changed live anchor: {anchor}'
    result=result.replace(anchor,replacement)
reverse=result
for anchor,replacement in reversed(hooks): reverse=reverse.replace(replacement,anchor)
assert reverse==text
newline='\r\n' if b'\r\n' in old else '\n'
new=result.replace('\n',newline).encode('utf-8')
assert dest.read_bytes()==old,'Live file changed during preparation.'
helper=C/'scripts/ui/shrine_info.gd'
assert not helper.exists(), 'Live helper already exists.'
(W/'originals/live-before-install-hub_town.gd').write_bytes(old)
(W/'presentation.diff').write_text(''.join(difflib.unified_diff(text.splitlines(True),result.splitlines(True),fromfile='live-before/scripts/town/hub_town.gd',tofile='installed/scripts/town/hub_town.gd')),encoding='utf-8')
protect=['project.godot','scripts/dungeon/dungeon.gd','scripts/dungeon/boss_intro.gd','scripts/town/evolution.gd','scripts/town/team_state.gd','scripts/town/town_layout.gd','scripts/town/highbank_painter.gd','scripts/town/room_painter.gd','scripts/town/town_room.gd','scripts/ui/game_pause_menu.gd','scripts/ui/evolution_scene.gd','scripts/arena/creature_finish.gd','scripts/arena/creature_finish.gdshader','scripts/ui/ui_style.gd','assets/sprites/world/growth_shrine_2026_10_10/shrine_native.png']
hashes={p:hashlib.sha256((C/p).read_bytes()).hexdigest() for p in protect}
(W/'protected-before-install.json').write_text(json.dumps(hashes,indent=2),encoding='utf-8')
helper.write_bytes((W/'shrine_info.gd').read_bytes())
assert dest.read_bytes()==old,'Live file changed; helper installed but town hook pending.'
dest.write_bytes(new)
assert all(hashlib.sha256((C/p).read_bytes()).hexdigest()==h for p,h in hashes.items())
(W/'installed-hashes.json').write_text(json.dumps({p:hashlib.sha256((C/p).read_bytes()).hexdigest() for p in ['scripts/town/hub_town.gd','scripts/ui/shrine_info.gd']},indent=2),encoding='utf-8')
print('Installed ShrineInfo and three hooks into current live hub_town; all protected hashes unchanged.')
