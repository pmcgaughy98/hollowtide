extends Node
## Saved key and button choices (Claude, 2026-10-23, factory pass 2: controller support and rebinding). An
## autoload: project.godot names it InputPrefs. At launch it lays the player's saved bindings, the [input] section
## of user://game_prefs.cfg (UI.GAME_PREFS_PATH; until pass 3 they sat in the title's menu_preferences.cfg, which a
## title save wiped, and UI moves them over once), over the Input Map, and puts the window back in full screen when
## that was the last choice. A rebinding page saves one binding with save_binding and puts actions back with
## reset_defaults. It also watches every input event for the device in use, so a hint can say "J" on a keyboard and
## "A" on a pad (UI.last_device, and device_changed).
##   InputPrefs.save_binding("attack", event)        # a key, a pad button or a stick push; saved at once
##   InputPrefs.reset_defaults()                     # every action back to project.godot's map ("bag": just one)
##   InputPrefs.device_changed.connect(_on_device)   # "keyboard" or "pad", when the player switches
## A check (the main loop has a script) keeps project.godot's map and a window, so a stray save cannot fail it. A
## check that tests saved bindings opts in: get_tree().set_meta("apply_input_prefs", true) in its _init, or
## apply_saved(true).
## Saved form, one key per action, the action's whole list: attack=[{"key": 74}, {"key": 32}, {"button": 0}] (a
## physical key code, a pad button index, or {"axis": 5, "value": 1.0} for a stick or trigger direction).

signal device_changed(device: String)
signal bindings_changed

const UI := preload("res://scripts/ui/ui_style.gd")
const SECTION := "input"
const OPT_IN := &"apply_input_prefs"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# The window's own signal sees every event before any node can mark it handled (the pause menu does).
	get_tree().root.window_input.connect(_on_window_input)
	Input.joy_connection_changed.connect(_on_joy_connection)
	apply_saved()
	# The saved screen mode at launch (Claude, 2026-10-23, U2 for LO-02): before this only the pause menu and F11
	# set it. Behind the same guard as the bindings, so a check run stays in its window.
	if _applies(false) and UI.screen_full():
		UI.apply_screen_mode(true, false)


func _on_window_input(event: InputEvent) -> void:
	if UI.note_input(event):
		device_changed.emit(UI.last_device())


## The last pad unplugged: the hints go back to the keyboard.
func _on_joy_connection(_device: int, connected: bool) -> void:
	if not connected and Input.get_connected_joypads().is_empty() and UI.set_device("keyboard"):
		device_changed.emit("keyboard")


## Lay the saved bindings over the Input Map; returns how many actions were set. A check is skipped unless it
## opted in or passes `force`.
func apply_saved(force := false) -> int:
	if not _applies(force):
		return 0
	var cfg := UI.load_game_prefs()
	if not cfg.has_section(SECTION):
		return 0
	var n := 0
	for action in cfg.get_section_keys(SECTION):
		if not InputMap.has_action(action):
			continue   # an action this version no longer has
		var events := _decode(cfg.get_value(SECTION, action, []))
		if events.is_empty():
			continue   # nothing readable: the default stays
		InputMap.action_erase_events(action)
		for ev in events:
			InputMap.action_add_event(action, ev)
		n += 1
	if n > 0:
		bindings_changed.emit()
	return n


## Saved prefs apply to the game itself, a check that opted in, or when `force`d; never to other checks.
func _applies(force: bool) -> bool:
	var tree := get_tree()
	return force or tree == null or tree.get_script() == null or tree.has_meta(OPT_IN)


## Give `action` the input in `event` and save it at once. It takes the place of the action's `slot`-th binding of
## the same kind (keyboard or pad; slot 0 is the one hints print), or joins the end when there is no such slot.
## Modifiers are dropped: a binding is one key. False for an unknown action or an event that is no binding (a
## stick push under UI.TAP_DEAD, a mouse move). Ask UI.binding_clashes(action, event) first.
func save_binding(action: StringName, event: InputEvent, slot := 0) -> bool:
	if not InputMap.has_action(action):
		return false
	var ev := _clean(event)
	if ev == null:
		return false
	var pad := UI._is_pad(ev)
	var kept: Array = []
	var k := 0
	var placed := false
	for old: InputEvent in InputMap.action_get_events(action):
		if UI._is_pad(old) != pad:
			kept.append(old)
			continue
		if k == slot:
			kept.append(ev)
			placed = true
		elif UI._input_id(old) != UI._input_id(ev):
			kept.append(old)   # the same input twice is dropped
		k += 1
	if not placed:
		kept = kept.filter(func(e: InputEvent) -> bool: return UI._input_id(e) != UI._input_id(ev))
		kept.append(ev)
	InputMap.action_erase_events(action)
	for e: InputEvent in kept:
		InputMap.action_add_event(action, e)
	var cfg := UI.load_game_prefs()   # no file yet is an empty one; the other prefs are kept
	cfg.set_value(SECTION, String(action), _encode(kept))
	var ok := UI.write_prefs(cfg)
	bindings_changed.emit()
	return ok


## Put `action` (every rebindable action and every saved one when empty) back to project.godot's map, and forget
## what was saved for it.
func reset_defaults(action: StringName = &"") -> void:
	var cfg := UI.load_game_prefs()
	var names: Array = []
	if action != &"":
		names.append(String(action))
	else:
		names.append_array(UI.INPUT_NAMES.keys())
		if cfg.has_section(SECTION):
			for a in cfg.get_section_keys(SECTION):
				if not names.has(a):
					names.append(a)
	for a: String in names:
		var setting: Variant = ProjectSettings.get_setting("input/" + a)
		if setting is Dictionary and InputMap.has_action(a):
			InputMap.action_erase_events(a)
			for ev in setting.get("events", []):
				if ev is InputEvent:
					InputMap.action_add_event(a, ev.duplicate())
		if cfg.has_section_key(SECTION, a):
			cfg.erase_section_key(SECTION, a)
	UI.write_prefs(cfg)
	bindings_changed.emit()


## A copy of `event` fit to keep: all devices, no modifiers, a stick push as a full direction.
func _clean(event: InputEvent) -> InputEvent:
	if event is InputEventKey:
		var code: int = event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
		if code == KEY_NONE:
			return null
		var k := InputEventKey.new()
		k.device = -1
		k.physical_keycode = code
		return k
	if event is InputEventJoypadButton:
		var b := InputEventJoypadButton.new()
		b.device = -1
		b.button_index = event.button_index
		return b
	if event is InputEventJoypadMotion and absf(event.axis_value) >= UI.TAP_DEAD:
		var m := InputEventJoypadMotion.new()
		m.device = -1
		m.axis = event.axis
		m.axis_value = signf(event.axis_value)
		return m
	return null


func _encode(events: Array) -> Array:
	var out := []
	for ev in events:
		if ev is InputEventKey:
			out.append({"key": int(ev.physical_keycode if ev.physical_keycode != KEY_NONE else ev.keycode)})
		elif ev is InputEventJoypadButton:
			out.append({"button": int(ev.button_index)})
		elif ev is InputEventJoypadMotion:
			out.append({"axis": int(ev.axis), "value": signf(ev.axis_value)})
	return out


## The saved list back as events; anything unreadable (a hand-edited file) is left out.
func _decode(list: Variant) -> Array:
	var out := []
	if not (list is Array):
		return out
	for d in list:
		if not (d is Dictionary):
			continue
		var e := {}
		if d.has("key") and (d["key"] is int) and int(d["key"]) > 0:
			e = {"key": int(d["key"])}
		elif d.has("button") and (d["button"] is int) and int(d["button"]) >= 0 and int(d["button"]) < JOY_BUTTON_MAX:
			e = {"button": int(d["button"])}
		elif d.has("axis") and (d["axis"] is int) and int(d["axis"]) >= 0 and int(d["axis"]) < JOY_AXIS_MAX and (d.get("value") is float or d.get("value") is int) and float(d["value"]) != 0.0:
			e = {"axis": int(d["axis"]), "value": signf(float(d["value"]))}
		if e.has("key"):
			var k := InputEventKey.new()
			k.device = -1
			k.physical_keycode = e["key"]
			out.append(k)
		elif e.has("button"):
			var b := InputEventJoypadButton.new()
			b.device = -1
			b.button_index = e["button"]
			out.append(b)
		elif e.has("axis"):
			var m := InputEventJoypadMotion.new()
			m.device = -1
			m.axis = e["axis"]
			m.axis_value = e["value"]
			out.append(m)
	return out
