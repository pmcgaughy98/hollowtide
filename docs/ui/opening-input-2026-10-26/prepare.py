from pathlib import Path
import hashlib,json,shutil
W=Path(__file__).parent;L=Path('C:/Users/pmcga/dev/hollowtide')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not (W/'protected-before.json').exists()
paths=set()
for folder in ('scripts','scenes','data','dialogue','tools'):
    paths.update(p for p in (L/folder).rglob('*') if p.is_file() and '__pycache__' not in p.parts)
paths.update(L/p for p in ('project.godot','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md'))
base={p.relative_to(L).as_posix():sha(p) for p in sorted(paths)}
(W/'protected-before.json').write_text(json.dumps(base,indent=2))
owned=['scripts/storm_open.gd','scripts/soul_prologue.gd','scripts/main_menu.gd','scripts/opening_flow.gd']
for rel in owned+['scripts/ui/ui_style.gd','scripts/ui/input_prefs.gd','tools/debug/opening_flow_check.gd','docs/AI_COLLABORATION.md','docs/team/CODEX_TASKS_2026-10-26.md']:
    p=W/'originals'/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(L/rel,p)
def write(rel,s):
    raw=(L/rel).read_bytes();nl=b'\r\n' if b'\r\n' in raw else b'\n';p=W/'prepared'/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(s.encode().replace(b'\n',nl))
rel=owned[0];s=(L/rel).read_text(encoding='utf-8')
s=s.replace('## Enter or Space skips. Sounds load when present','## Two released advance presses skip. Sounds load when present',1)
s=s.replace('var soul: Node2D','var soul: Node2D\nvar _skip_armed := false\nvar _skip_released := false\nvar _skip_hint: Label',1)
s=s.replace('\t_rain_player = _sfx("storm_rain", -6.0, true)','''\tvar hint_layer := CanvasLayer.new()
\thint_layer.layer = 2
\tadd_child(hint_layer)
\t_skip_hint = Label.new()
\t_skip_hint.name = "SkipHint"
\t_skip_hint.position = Vector2(24, 600)
\t_skip_hint.size = Vector2(1104, 30)
\t_skip_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
\t_skip_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
\t_skip_hint.add_theme_font_override("font", UI.font("label"))
\t_skip_hint.add_theme_font_size_override("font_size", UI.type_size("label"))
\t_skip_hint.add_theme_color_override("font_color", Color(UI.TEXT, 0.8))
\t_skip_hint.add_theme_color_override("font_shadow_color", Color.BLACK)
\t_skip_hint.add_theme_constant_override("shadow_offset_x", 2)
\t_skip_hint.add_theme_constant_override("shadow_offset_y", 2)
\thint_layer.add_child(_skip_hint)
\t_rain_player = _sfx("storm_rain", -6.0, true)''',1)
s=s.replace('\t_t += delta\n','''\t_t += delta
\t_skip_hint.visible = not leaving and (_skip_armed or _t >= 4.0)
\tif _skip_hint.visible:
\t\tvar keys := PackedStringArray()
\t\tfor action in UI.INPUT_ADVANCE:
\t\t\tvar binding := UI.binding_text(action)
\t\t\tif binding != "" and not keys.has(binding): keys.append(binding)
\t\t_skip_hint.text = "%s  %s" % [" / ".join(keys), "Press again to skip" if _skip_armed else "Skip"]
''',1)
a=s.index('func _unhandled_input(');b=s.index('\n\nfunc _next()',a)
s=s[:a]+'''func _unhandled_input(event: InputEvent) -> void:
\tif leaving: return
\t# Centre events match no pressed action, but must reset the shared stick-edge state.
\tif event is InputEventJoypadMotion: UI._motion_edge(event)
\tvar advance := false
\tfor action in UI.INPUT_ADVANCE:
\t\tif UI.pressed(event, action): advance = true
\tif advance:
\t\tif _skip_armed and _skip_released:
\t\t\t_next()
\t\telse:
\t\t\t_skip_armed = true
\t\t\t_skip_released = false
\t\tget_viewport().set_input_as_handled()
\telif _skip_armed:
\t\tfor action in UI.INPUT_ADVANCE:
\t\t\tif event.is_action_released(action):
\t\t\t\t_skip_released = true
\t\t\t\tget_viewport().set_input_as_handled()
''' +s[b:]
write(rel,s)
rel=owned[1];s=(L/rel).read_text(encoding='utf-8')
a=s.index('func _input(');b=s.index('\n\nfunc _card_rect(',a)
s=s[:a]+'''func _input(event: InputEvent) -> void:
\t# UI.pressed ignores centre events; feed them to its shared edge tracker too.
\tif event is InputEventJoypadMotion: UI._motion_edge(event)
\tif auto or stage in ["fly", "done"]: return
\tif stage == "choose" and UI.pressed(event, "move_left"):
\t\t_move_pick(-1)
\telif stage == "choose" and UI.pressed(event, "move_right"):
\t\t_move_pick(1)
\telse:
\t\tvar next := false
\t\tfor action in UI.INPUT_ADVANCE:
\t\t\tif UI.pressed(event, action): next = true
\t\tif not next: return
\t\tadvance()   # one event, even when J/A belongs to more than one advance action
\tget_viewport().set_input_as_handled()
''' +s[b:]
s=s.replace('"A / D  choose      J  this shape"','"%s / %s  choose      %s  this shape" % [UI.binding_text("move_left"), UI.binding_text("move_right"), UI.binding_text("confirm")]',1)
write(rel,s)
rel=owned[2];s=(L/rel).read_text(encoding='utf-8');a=s.index('func _ensure_menu_inputs()');b=s.index('func _ready()',a);s=s[:a]+s[b:];s=s.replace('\t_ensure_menu_inputs()\n','',1)
s=s.replace('if event.is_action_pressed("ui_cancel") and _page != "main" and not _leaving:','if (UI.pressed(event,"cancel") or UI.pressed(event,"ui_cancel")) and _page != "main" and not _leaving:',1)
needle='\t\t_close_panel()\n\t\tget_viewport().set_input_as_handled()\n\n\nfunc _place_cursor()'
assert s.count(needle)==1
s=s.replace(needle,'''\t\t_close_panel()
\t\tget_viewport().set_input_as_handled()
\t\treturn
\tif _leaving or ("_boot_done" in self and not get("_boot_done")): return
\t# GUI keeps its normal focus/accept keys; story bindings can also choose a focused title button.
\tvar focused := get_viewport().gui_get_focus_owner()
\tif focused is Button and _focus_controls.has(focused) and not focused.disabled:
\t\tfor action in UI.INPUT_ADVANCE:
\t\t\tif UI.pressed(event, action):
\t\t\t\tfocused.pressed.emit()
\t\t\t\tget_viewport().set_input_as_handled()
\t\t\t\treturn


func _place_cursor()''',1)
write(rel,s)
rel=owned[3];s=(L/rel).read_text(encoding='utf-8')
s=s.replace('func _input(event: InputEvent) -> void:\n','func _input(event: InputEvent) -> void:\n\tif event is InputEventJoypadMotion: UI._motion_edge(event)\n',1)
s=s.replace('if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel") or (event is InputEventMouseButton and event.pressed):','''var advance := false
\tfor action in UI.INPUT_ADVANCE:
\t\tif UI.pressed(event, action): advance = true
\tif advance or UI.pressed(event,"ui_accept") or UI.pressed(event,"ui_cancel") or UI.pressed(event,"cancel") or (event is InputEventMouseButton and event.pressed):''',1)
write(rel,s)
# Candidate check update only: the public file belongs to Claude's active pass 8 lane.
s=(L/'tools/debug/opening_flow_check.gd').read_text(encoding='utf-8')
needle='\telse:\n\t\tawait key(KEY_ENTER)\n\tif not verify("Storm enters actual soul scene"'
assert s.count(needle)==1
s=s.replace(needle,'\telse:\n\t\tawait key(KEY_ENTER)\n\t\tverify("One Enter only arms storm skip", scene_name() == "storm_open.tscn" and storm._skip_armed)\n\t\tawait key(KEY_ENTER)\n\tif not verify("Storm enters actual soul scene"',1)
s=s.replace('const OUT := "user://opening-flow-check/"','const OUT := "user://opening-input-flow-check/"',1)
(W/'opening_flow_private.gd').write_text(s,encoding='utf-8')
print('Prepared C7/input slice in four owned files; protected',len(base),'existing files.')
