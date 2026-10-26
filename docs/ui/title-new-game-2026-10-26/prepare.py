from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not (W/'protected-before.json').exists()
paths=set()
for folder in ('scripts','scenes','data','dialogue','tools'):
    paths.update(p for p in (L/folder).rglob('*') if p.is_file() and '__pycache__' not in p.parts)
paths.update(L/p for p in ('project.godot','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'))
base={p.relative_to(L).as_posix():sha(p) for p in sorted(paths)}
(W/'protected-before.json').write_text(json.dumps(base,indent=2))
for rel in ('scripts/main_menu.gd','scripts/creature_opening.gd','scripts/town/team_state.gd','tools/debug/ui_fit_check.gd','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'):
    dest=W/'originals'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,dest)
def write(rel,s):
    raw=(L/rel).read_bytes();nl=b'\r\n' if b'\r\n' in raw else b'\n';p=W/'prepared'/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(s.encode().replace(b'\n',nl))
main=(L/'scripts/main_menu.gd').read_text(encoding='utf-8')
main=main.replace('# New Game stays as it was and only overwrites the save when the new team first reaches Highbank.','# New Game keeps the existing file until the new journey next saves.',1)
main=main.replace('var _continue_button: Button','var _continue_details: Label\n# C6 proposal wording: leave this default off until Preston chooses the words.\n@export var new_game_confirm_enabled := false\nvar _new_game_panel: PanelContainer\nvar _new_game_controls: Array[Control] = []\nvar _new_game_return_page := "main"\nvar _new_game_return_focus: Control\nvar _new_game_confirmed := false\nvar _continue_button: Button',1)
needle='\t\tif entry[0] == "Continue":\n\t\t\t_continue_button = b'
assert main.count(needle)==1
main=main.replace(needle,needle+'''
			_continue_details = _label(_continue_text(),18)
			_continue_details.name = "ContinueDetails"
			_continue_details.custom_minimum_size.y = 24
			_continue_details.add_theme_color_override("font_color",UI.INK)
			var details_row := PanelContainer.new()
			details_row.name = "ContinueSummary"
			var details_box := UI.frame("nameplate").duplicate()
			details_box.set_content_margin_all(6)
			details_row.add_theme_stylebox_override("panel",details_box)
			details_row.add_child(_continue_details)
			list.add_child(details_row)''')
main=main.replace('\t_build_quit_panel()\n\t_cursor = Polygon2D.new()','\t_build_quit_panel()\n\t_build_new_game_panel()\n\t_cursor = Polygon2D.new()',1)
at=main.index('func _build_options_panel() -> void:')
extra='''## A read-only preview of the record Continue uses, including a recovered backup.
func _continue_text() -> String:
	var record: Dictionary = TeamState._read().get("data", {})
	var place := "Highbank"
	var run: Variant = record.get("suspend", {})
	if run is Dictionary and not run.is_empty():
		var definitions: Dictionary = load("res://scripts/dungeon/dungeon.gd").get_script_constant_map()["DUNGEONS"]
		place = "%s B%dF" % [definitions.get(String(run.get("dungeon","first")),{}).get("name","A Hollow"),maxi(1,int(run.get("floor_n",1)))]
	var level := "?"
	var party: Variant = record.get("party",[])
	var levels: Variant = record.get("levels",{})
	if party is Array and not party.is_empty() and party[0] is Array and not party[0].is_empty() and levels is Dictionary:
		var entry: Variant = levels.get(int(party[0][0]),{})
		if entry is Dictionary: level = str(maxi(1,int(entry.get("lv",1))))
	return "%s   Lv %s" % [place,level]


func _build_new_game_panel() -> void:
	_new_game_panel = _panel("NewGameConfirmation",Vector2(296,216),560)
	var list := _list(_new_game_panel)
	list.add_child(_label("Start a new journey?",32))
	var words := _label("Saving the new journey will replace your current save.",18)
	words.name = "Consequences"
	words.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	words.custom_minimum_size.x = 512
	list.add_child(words)
	for item in [["No",_cancel_new_game],["Yes",_confirm_new_game]]:
		var button := _button(item[0])
		button.name = item[0]
		button.pressed.connect(item[1])
		list.add_child(button)
		_new_game_controls.append(button)


func _ask_new_game() -> bool:
	if _new_game_confirmed:
		_new_game_confirmed = false
		return false
	if not new_game_confirm_enabled or not TeamState.has_save(): return false
	if _page == "new_game": return true
	_new_game_return_page = _page
	_new_game_return_focus = get_viewport().gui_get_focus_owner()
	_quiet_focus = true
	_sound(CONFIRM_SOUND)
	_show_page("new_game",_new_game_controls[0])
	set_deferred("_quiet_focus",false)
	return true


func _cancel_new_game() -> void:
	if _page != "new_game" or _leaving: return
	_new_game_confirmed = false
	var first: Control = _new_game_return_focus if is_instance_valid(_new_game_return_focus) else _buttons[0]
	_sound(CANCEL_SOUND)
	_show_page(_new_game_return_page,first)


func _confirm_new_game() -> void:
	if _page != "new_game" or _leaving: return
	_new_game_confirmed = true
	_on_new_game()   # one-use consent, then the existing campaign/legacy entry point


'''
main=main[:at]+extra+main[at:]
main=main.replace('\t_quit_panel.visible = page == "quit"','\t_quit_panel.visible = page == "quit"\n\t_new_game_panel.visible = page == "new_game"',1)
main=main.replace('\t\t"quit":\n\t\t\t_focus_controls.assign(_quit_controls)','\t\t"quit":\n\t\t\t_focus_controls.assign(_quit_controls)\n\t\t"new_game":\n\t\t\t_focus_controls.assign(_new_game_controls)',1)
main=main.replace('func _unhandled_input(event: InputEvent) -> void:\n','func _unhandled_input(event: InputEvent) -> void:\n\tif _page == "new_game" and (UI.pressed(event,"cancel") or UI.pressed(event,"ui_cancel")):\n\t\t_cancel_new_game()\n\t\tget_viewport().set_input_as_handled()\n\t\treturn\n',1)
needle='func _on_new_game() -> void:\n\tif _leaving:\n\t\treturn\n\t_sound(CONFIRM_SOUND)'
assert main.count(needle)==1
main=main.replace(needle,'func _on_new_game() -> void:\n\tif _leaving:\n\t\treturn\n\tif _ask_new_game(): return\n\t_sound(CONFIRM_SOUND)')
main=main.replace('func _close_panel() -> void:\n\tif _leaving:','func _close_panel() -> void:\n\tif _page == "new_game":\n\t\t_cancel_new_game()\n\t\treturn\n\tif _leaving:',1)
write('scripts/main_menu.gd',main)
c=(L/'scripts/creature_opening.gd').read_text(encoding='utf-8')
needle='\t_main_panel.position.y=menu_top(_buttons.size() + (1 if _save_note != null else 0))   # the save note counts as a row'
assert c.count(needle)==1
c=c.replace(needle,needle+'''
	if _continue_details != null:
		var details_row := _continue_details.get_parent() as Control
		_main_panel.position.y -= details_row.get_combined_minimum_size().y + choices.get_theme_constant("separation")''')
c=c.replace('if _boot_done and not _leaving:_begin_journey()','if _boot_done and not _leaving and not _ask_new_game():_begin_journey()',1)
write('scripts/creature_opening.gd',c)
print('Preserved',len(base),'current files; prepared summary + default-off confirmation in two owned scripts.')
