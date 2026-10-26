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
for rel in ('scripts/main_menu.gd','scripts/creature_opening.gd','scripts/ui/ui_style.gd','scripts/ui/game_pause_menu.gd','scripts/ui/rebind_page.gd','scripts/ui/controls_text.gd','tools/debug/ui_fit_check.gd','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-22.md'):
    p=W/'originals'/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,p)
def read(rel):return (L/rel).read_text(encoding='utf-8')
def write(rel,s):
    raw=(L/rel).read_bytes() if (L/rel).exists() else b'';nl=b'\r\n' if b'\r\n' in raw else b'\n'
    p=W/'prepared'/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(s.encode().replace(b'\n',nl))
main=read('scripts/main_menu.gd')
main=main.replace('var _options_panel: PanelContainer','var _title_settings: CanvasLayer\nvar _options_panel: PanelContainer',1)
start=main.index('func _build_options_panel() -> void:');end=main.index('func _volume_control(',start)
main=main[:start]+'''func _build_options_panel() -> void:
	_title_settings = load("res://scripts/ui/title_settings.gd").new()
	add_child(_title_settings)
	_title_settings.closed.connect(_title_settings_closed)
	_title_settings.page_changed.connect(_title_settings_page)
	_title_settings.preferences_changed.connect(_refresh_title_preferences)
	_title_settings.show_page("options")
	_title_settings.overlay.hide()


func _title_settings_closed() -> void:
	_refresh_title_preferences()
	var return_to: Control = _buttons[0]
	for b in _buttons:
		if b.name == "Options": return_to = b
	_show_page("main", return_to)


func _title_settings_page() -> void:
	_options_panel = _title_settings.overlay.get_node("PausePanel")
	_options_controls.assign(_title_settings.controls)
	_options_status = _title_settings.status
	_motion_button = _title_settings.content.get_node_or_null("ReduceMotion")
	if _page == "options":
		_focus_controls.assign(_options_controls)


func _save_title_option(section: String, key: String, value: Variant) -> void:
	if section == "audio":
		set("_%s_volume" % key, float(value))
	elif key == "reduce_motion":
		_reduce_motion = bool(value)
	elif key == "courier":
		_selected_courier = String(value)
	_settings_dirty = true
	_save_preferences()


func _refresh_title_preferences() -> void:
	_load_preferences()
	_apply_motion_setting()


''' + main[end:]
needle='func _show_page(page: String, first: Control) -> void:\n\t_page = page'
assert main.count(needle)==1
main=main.replace(needle,'''func _show_page(page: String, first: Control) -> void:
	_page = page
	if _title_settings != null:
		if page == "options":
			_title_settings.show_page("options")
			first = _options_controls[0]
		_title_settings.overlay.visible = page == "options"''')
main=main.replace('\tfirst.grab_focus.call_deferred()\n\t_place_cursor.call_deferred()','\tif page != "options": first.grab_focus.call_deferred()\n\t_place_cursor.call_deferred()',1)
write('scripts/main_menu.gd',main)
c=read('scripts/creature_opening.gd')
c=c.replace('const LEGIBILITY =','const ControlsText := preload("res://scripts/ui/controls_text.gd")\nconst LEGIBILITY =',1)
c=c.replace('var _help_copy: VBoxContainer','var _help_scroll: ScrollContainer\nvar _help_copy: VBoxContainer',1)
needle='\t_set_input_device("keyboard")\n\t_cursor.color='
assert c.count(needle)==1
c=c.replace(needle,'''\t_set_input_device("keyboard")
	var prefs := get_node_or_null("/root/InputPrefs")
	if prefs != null:
		prefs.device_changed.connect(_refresh_help_controls)
		prefs.bindings_changed.connect(_refresh_help_bindings)
	_cursor.color=''')
start=c.index('\t_options_panel.position=Vector2(666,120)');end=c.index('\nfunc _selected_action',start)
c=c[:start]+'''\t_quit_panel.custom_minimum_size.x=442
	_quit_panel.position=Vector2(minf(666.0,1136.0-_quit_panel.get_combined_minimum_size().x),312)
	_quit_controls[0].text="Back to title"
''' +c[end:]
needle='\t_cursor.visible=focused is Button and _focus_controls.has(focused) and not _leaving'
assert c.count(needle)==1
c=c.replace(needle,'\t_cursor.visible=_page!="options" and focused is Button and _focus_controls.has(focused) and not _leaving')
needle='\t_help_copy=VBoxContainer.new()\n\t_help_copy.name="Guide"\n\t_help_copy.custom_minimum_size=Vector2(630,246)\n\t_help_copy.add_theme_constant_override("separation",8)\n\tlist.add_child(_help_copy)'
assert c.count(needle)==1
c=c.replace(needle,'''\t_help_scroll=ScrollContainer.new()
	_help_scroll.name="GuideScroll"
	_help_scroll.custom_minimum_size=Vector2(630,246)
	_help_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	_help_scroll.follow_focus=true
	_help_scroll.focus_mode=Control.FOCUS_ALL
	UI.style_scroll_bar(_help_scroll.get_v_scroll_bar())
	list.add_child(_help_scroll)
	_help_copy=VBoxContainer.new()
	_help_copy.name="Guide"
	_help_copy.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	_help_copy.add_theme_constant_override("separation",8)
	_help_scroll.add_child(_help_copy)''')
c=c.replace('\t_show_help_topic("journey")\n\t_help_panel.hide()','\t_help_controls.append(_help_scroll)\n\t_show_help_topic("journey")\n\t_help_panel.hide()',1)
c=c.replace('\t_help_topic=topic\n\tfor n in _help_copy.get_children():','\tvar scroll_y := _help_scroll.scroll_vertical if _help_topic==topic else 0\n\t_help_topic=topic\n\tfor n in _help_copy.get_children():',1)
needle='\tfor i in 2:(_help_controls[i] as Button).set_pressed_no_signal(topic==["journey","controls"][i])'
assert c.count(needle)==1
c=c.replace(needle,'''\tfor i in 2:
		var tab := _help_controls[i] as Button
		var active: bool = topic==["journey","controls"][i]
		tab.set_pressed_no_signal(active)
		var box := UI.frame("panel_focus" if active else "panel").duplicate()
		box.content_margin_top=8
		box.content_margin_bottom=8
		box.content_margin_left=40
		tab.add_theme_stylebox_override("normal",box)''')
start=c.index('\telse:\n\t\tlines=[',c.index('func _show_help_topic'))
end=c.index('\tfor entry in lines:',start)
c=c[:start]+'''\telse:
		lines=[[ControlsText.note(UI.last_device()),20]]
		for group in ControlsText.groups(UI.last_device()):
			lines.append([group["head"],23])
			for words in group["lines"]:lines.append([words,20])
			if group["head"]==ControlsText.HOLLOW["head"]:lines.append([ControlsText.TURNS,20])
''' +c[end:]
c=c.replace('\t\tl.custom_minimum_size.x=630','\t\tl.size_flags_horizontal=Control.SIZE_EXPAND_FILL',1)
needle='\t\t_help_copy.add_child(l)\n\nfunc _open_help()'
assert c.count(needle)==1
c=c.replace(needle,'''\t\t_help_copy.add_child(l)
	_help_scroll.set_deferred("scroll_vertical",scroll_y)
	_help_panel.reset_size.call_deferred()

func _refresh_help_controls(_device: String) -> void:
	if _page=="help" and _help_topic=="controls":_show_help_topic("controls")

func _refresh_help_bindings() -> void:
	_refresh_help_controls(UI.last_device())

func _unhandled_input(event: InputEvent) -> void:
	if _page=="help":
		var step := int(UI.pressed(event,"page_down"))-int(UI.pressed(event,"page_up"))
		if step!=0:
			_help_scroll.scroll_vertical+=step*int(_help_scroll.size.y*0.75)
			get_viewport().set_input_as_handled()
			return
	super._unhandled_input(event)

func _open_help()''')
write('scripts/creature_opening.gd',c)
write('scripts/ui/title_settings.gd',(W/'title_settings.gd').read_text())
print('Preserved',len(base),'files; prepared two menu hooks and a small host for existing pause settings pages.')
