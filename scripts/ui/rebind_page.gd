extends VBoxContainer
## The pause menu's key and button page, under Options as "Rebind keys" (Preston, 2026-10-23) (Claude, 2026-10-23, factory pass 2: GS-04).
## Every action a player can change (UI.INPUT_NAMES) is a row: its name, its keyboard keys and its controller
## buttons as the Input Map holds them now. Choose a row, then press a key or a button:
##   a key takes the place of the row's first key that is not an arrow (the arrows also move every menu's
##   cursor, so they stay); a button takes the place of the row's first button, a stick push its first stick.
##   For a move on the pad (Move 1 to 3, Rest) the button is the one pressed with RB, so RB alone is skipped.
##   Esc or B stops listening (B counts as a move's button while RB is held, as in a Hollow).
## A key another action already uses where both are live (UI.binding_clashes, the clash rule beside
## UI.INPUT_CONTEXTS) is refused with a line naming that action, and the page keeps listening. It never swaps
## behind the player's back: a swap could leave the other action clashing somewhere else. Saved at once through
## InputPrefs.save_binding; "Reset to defaults" asks for a second press, then puts every action back.
##   var page = load("res://scripts/ui/rebind_page.gd").new()
##   menu.content.add_child(page)
##   page.setup(menu)          # rows join menu.controls, so the pause menu's focus, sounds and packing apply
##   page.listen("attack")     # what choosing the Attack row does; the next key or button is the binding
## The checks read `listening`, `message`, row_text(action) and take(event) (a press while listening).

const UI := preload("res://scripts/ui/ui_style.gd")
## The rows in reading order, in three headed groups (the Controls page's order). An action in UI.INPUT_NAMES
## that no group names joins a last group, so a new action is never left off the page.
const GROUPS := [
	["WALKING", ["move_up", "move_down", "move_left", "move_right", "run", "turn"]],
	["IN A HOLLOW", ["attack", "move_slot_1", "move_slot_2", "move_slot_3", "moves_hold", "rest", "bag", "interact",
		"tactics", "log", "autopilot"]],
	["MENUS AND QUESTIONS", ["confirm", "cancel", "yes", "no", "take_out", "page_up", "page_down", "pause", "fullscreen"]],
]
## Names for the engine's two menu actions, which the clash rule can name but the page does not list.
const OTHER_NAMES := {"ui_accept": "Menu choose", "ui_cancel": "Menu back"}
const ARROWS := [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]
const ROW_W := 664.0
const KEY_X := 262.0      # the keyboard column's left edge in a row
const PAD_X := 466.0      # the controller column's
const COL_W := 192.0
const VISIBLE_ROWS := 7   # rows the list shows at once; it scrolls to the chosen one

var menu: CanvasLayer
var prefs: Node
var scroll: ScrollContainer
var list: VBoxContainer
var rows := {}            # action -> its row Button
var heads := {}           # action -> the group heading just above its row, for the first row of a group
var reset_row: Button
var note: Label
var hint: Label
var listening := ""       # the action waiting for a key or button; "" when none
var message := ""
var reset_armed := false
var _axis_on := {}        # while listening: "axis+sign" -> that stick direction was already pushed


func setup(owner_menu: CanvasLayer) -> void:
	name = "RebindPage"
	menu = owner_menu
	prefs = get_node_or_null("/root/InputPrefs")
	add_theme_constant_override("separation", 4)
	var header := Control.new()
	header.custom_minimum_size = Vector2(ROW_W, 22)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(header)
	for col in [[KEY_X, "KEYBOARD"], [PAD_X, "CONTROLLER"]]:
		var h := _text(String(col[1]), "label", UI.MUTED)
		h.position = Vector2(float(col[0]), 0)
		h.size = Vector2(COL_W, 22)
		header.add_child(h)
	scroll = ScrollContainer.new()
	scroll.name = "RebindScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	scroll.custom_minimum_size = Vector2(ROW_W + 16, VISIBLE_ROWS * 44 - 4)
	var bar := scroll.get_v_scroll_bar()
	bar.custom_minimum_size.x = 12
	for state in ["scroll", "grabber", "grabber_highlight", "grabber_pressed"]:   # bag_page.gd's thumb
		var style := StyleBoxFlat.new()
		style.bg_color = UI.PANEL if state == "scroll" else UI.EDGE_LIGHT if state != "grabber" else UI.EDGE
		style.set_content_margin_all(4)
		bar.add_theme_stylebox_override(state, style)
	add_child(scroll)
	list = VBoxContainer.new()
	list.name = "RebindRows"
	list.add_theme_constant_override("separation", 4)
	scroll.add_child(list)
	var seen: Array = []
	var groups: Array = GROUPS.duplicate(true)
	var rest: Array = UI.INPUT_NAMES.keys().filter(func(a: String) -> bool: return not GROUPS.any(func(g: Array) -> bool: return g[1].has(a)))
	if not rest.is_empty():
		groups.append(["OTHER", rest])
	for g in groups:
		var head := _text(String(g[0]), "label", UI.EDGE_LIGHT)
		head.custom_minimum_size = Vector2(ROW_W, 24)
		head.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		list.add_child(head)
		var first := true
		for a in g[1]:
			if seen.has(a) or not InputMap.has_action(a):
				continue
			seen.append(a)
			var row := _row(a)
			if first:
				heads[a] = head
				first = false
			list.add_child(row)
			rows[a] = row
			menu.controls.append(row)
	reset_row = menu._button("Reset to defaults")
	reset_row.name = "ResetDefaults"
	reset_row.pressed.connect(_reset_pressed)
	reset_row.focus_exited.connect(_disarm)
	add_child(reset_row)
	menu.controls.append(reset_row)
	note = _text("", "body", UI.EDGE_LIGHT)
	note.name = "RebindNote"
	note.custom_minimum_size = Vector2(ROW_W, 26)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(note)
	hint = _text("", "label", UI.MUTED)
	hint.custom_minimum_size = Vector2(ROW_W, 20)
	add_child(hint)
	if prefs != null:
		prefs.device_changed.connect(_on_device)
		prefs.bindings_changed.connect(refresh)
	refresh()
	_say("Choose a row, then press the new key or button.")


func _exit_tree() -> void:
	if prefs != null:
		if prefs.device_changed.is_connected(_on_device):
			prefs.device_changed.disconnect(_on_device)
		if prefs.bindings_changed.is_connected(refresh):
			prefs.bindings_changed.disconnect(refresh)


func _text(s: String, role: String, col: Color) -> Label:
	var l := Label.new()
	l.text = s
	l.add_theme_font_override("font", UI.font(role))
	l.add_theme_font_size_override("font_size", UI.type_size(role))
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_shadow_color", UI.SHADOW)
	l.add_theme_constant_override("shadow_offset_x", int(UI.TYPE[role]["px"]))
	l.add_theme_constant_override("shadow_offset_y", int(UI.TYPE[role]["px"]))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


## A row: the pause menu's framed button with the action's name as its text (gold when chosen), and the two
## binding columns as labels laid over it.
func _row(action: String) -> Button:
	var b: Button = menu._button(_name(action))
	b.name = "Row_" + action
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(ROW_W, 40)
	b.add_theme_font_override("font", UI.font("label"))   # the button face is too wide for "Hold for moves"
	b.add_theme_font_size_override("font_size", UI.type_size("label"))
	for col in [["Keys", KEY_X], ["Pad", PAD_X]]:
		var l := _text("", "body", UI.TEXT)
		l.name = String(col[0])
		l.position = Vector2(float(col[1]), 0)
		l.size = Vector2(COL_W, 40)
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.clip_text = true
		b.add_child(l)
	b.pressed.connect(listen.bind(action))
	b.focus_entered.connect(_show_head.bind(action))
	return b


func _name(action: String) -> String:
	return String(UI.INPUT_NAMES.get(action, OTHER_NAMES.get(action, action.capitalize())))


## Every row's two columns from the Input Map; "none" where a device has nothing (full screen on a pad).
func refresh() -> void:
	for a in rows:
		var row: Button = rows[a]
		var keys := row.get_node("Keys") as Label
		var pad := row.get_node("Pad") as Label
		if a == listening:
			keys.text = "Press a key"
			pad.text = "or a button"
			keys.add_theme_color_override("font_color", UI.LIGHT)
			pad.add_theme_color_override("font_color", UI.LIGHT)
			continue
		for pair in [[keys, "keyboard"], [pad, "pad"]]:
			var l: Label = pair[0]
			var s := _short(UI.binding_text(a, pair[1], true))
			l.text = UI.clip(s, "body", COL_W - 8.0) if s != "" else "none"
			l.add_theme_color_override("font_color", UI.TEXT if s != "" else UI.MUTED)
	_hint()


## A direction said once: "D-pad Down / Left stick Down" reads "D-pad / Left stick Down".
func _short(s: String) -> String:
	var parts := s.split(" / ")
	if parts.size() < 2:
		return s
	var last := parts[0].get_slice(" ", parts[0].get_slice_count(" ") - 1)
	for p in parts:
		if p.get_slice_count(" ") < 2 or p.get_slice(" ", p.get_slice_count(" ") - 1) != last:
			return s
	var heads := PackedStringArray()
	for p in parts:
		heads.append(p.substr(0, p.length() - last.length() - 1))
	return " / ".join(heads) + " " + last


## Both columns of a row as one string, "J / Space | A" (the checks read it).
func row_text(action: String) -> String:
	if not rows.has(action):
		return ""
	return "%s | %s" % [(rows[action].get_node("Keys") as Label).text, (rows[action].get_node("Pad") as Label).text]


func _hint() -> void:
	if hint == null:
		return
	if listening != "":
		hint.text = "Esc / B  stop listening"
	else:
		hint.text = "%s  change     %s  back" % [UI.binding_text("ui_accept"), UI.binding_text("ui_cancel")]


func _on_device(_device: String) -> void:
	_hint()


func _say(s: String) -> void:
	message = s
	if note != null:
		note.text = s


## The first row of a group shows its heading as well when the list scrolls up to it.
func _show_head(action: String) -> void:
	if heads.has(action) and is_instance_valid(scroll):
		scroll.ensure_control_visible.call_deferred(heads[action])


## Wait for the next key or button for `action`. Choosing the row already listening stops it.
func listen(action: String) -> void:
	_disarm()
	if listening == action:
		_stop("Left as it was.")
		return
	listening = action
	_axis_on.clear()
	for d in Input.get_connected_joypads():
		for ax in JOY_AXIS_MAX:
			var v := Input.get_joy_axis(d, ax)
			if absf(v) >= UI.TAP_DEAD:
				_axis_on["%d%s" % [ax, "+" if v > 0.0 else "-"]] = true   # a stick already pushed is not the answer
	menu._tick("confirm")
	refresh()
	_say("%s: press the new key or button." % _name(action))


func _stop(said: String) -> void:
	listening = ""
	refresh()
	_say(said)


func _input(event: InputEvent) -> void:
	if listening == "" or not is_visible_in_tree():
		return
	if event is InputEventMouseMotion or event is InputEventJoypadMotion and not _axis_edge(event):
		if event is InputEventJoypadMotion:
			get_viewport().set_input_as_handled()   # a stick settling must not move the menu's cursor
		return
	if not event.is_pressed() or event.is_echo():
		return
	get_viewport().set_input_as_handled()   # the press is the answer: the pause menu and the cursor never see it
	take(event)


## A press while listening: Esc or B stop, anything else is the new binding if the clash rule allows it.
func take(event: InputEvent) -> void:
	if listening == "":
		return
	var a := listening
	var hold := String(UI.INPUT_CHORDS.get(a, ""))
	if event is InputEventMouseButton:
		menu._tick("cancel")
		_stop("Left as it was.")
		return
	if event is InputEventKey and (event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE):
		menu._tick("cancel")
		_stop("Left as it was.")
		return
	if event is InputEventJoypadButton:
		if hold != "" and _is_hold_button(hold, event.button_index):
			return   # RB on its way to the chord: wait for the button pressed with it
		if event.button_index == JOY_BUTTON_B and not (hold != "" and UI.held(hold)):
			menu._tick("cancel")
			_stop("Left as it was.")
			return
	var pad := event is InputEventJoypadButton or event is InputEventJoypadMotion
	if not pad and a == "moves_hold":
		_say("%s is a controller button: press one on the controller." % _name(a))
		return
	var words := _words(a, event)
	var clash := UI.binding_clashes(a, event)
	if not clash.is_empty():
		var who := _name(String(clash[0]))
		menu._tick("cancel")
		_say("%s is already %s. Choose another, or change %s first." % [words, who, who])
		return
	var slot := _pad_slot(a, event) if pad else _key_slot(a)
	if prefs == null or not prefs.save_binding(a, event, slot):
		_say("%s can't be used here. Choose another." % (words if words != "" else "That"))
		return
	listening = ""
	menu._tick("confirm")
	refresh()
	_say("%s now uses %s." % [_name(a), words])


## The row's first key that is not an arrow, or the end of its keys when it has only arrows.
func _key_slot(action: String) -> int:
	var k := 0
	for ev: InputEvent in InputMap.action_get_events(action):
		if ev is InputEventKey:
			var code: int = ev.physical_keycode if ev.physical_keycode != KEY_NONE else ev.keycode
			if not ARROWS.has(code):
				return k
			k += 1
	return k


## The row's first pad binding of the same sort (a button for a button, a stick for a stick), or the end.
func _pad_slot(action: String, event: InputEvent) -> int:
	var k := 0
	for ev: InputEvent in InputMap.action_get_events(action):
		if ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
			if (ev is InputEventJoypadButton) == (event is InputEventJoypadButton):
				return k
			k += 1
	return k


func _is_hold_button(hold: String, button: int) -> bool:
	for ev: InputEvent in InputMap.action_get_events(hold):
		if ev is InputEventJoypadButton and ev.button_index == button:
			return true
	return false


## What the player pressed, as a hint prints it ("K", "Y", "RB+X", "Left stick Up").
func _words(action: String, event: InputEvent) -> String:
	var s := UI._event_text(event)
	if s != "" and event is InputEventJoypadButton and UI.INPUT_CHORDS.has(action):
		s = UI.binding_text(UI.INPUT_CHORDS[action], "pad") + "+" + s
	return s


## A stick direction crossing UI.TAP_DEAD from rest, once per push.
func _axis_edge(event: InputEventJoypadMotion) -> bool:
	var fired := false
	for s in [-1.0, 1.0]:
		var id := "%d%s" % [event.axis, "+" if s > 0.0 else "-"]
		var on: bool = event.axis_value * s >= UI.TAP_DEAD
		if on and not bool(_axis_on.get(id, false)):
			fired = true
		_axis_on[id] = on
	return fired


func _reset_pressed() -> void:
	if listening != "":
		_stop("")
	if not reset_armed:
		reset_armed = true
		reset_row.text = "Reset to defaults? Press again"
		_say("Every key and button goes back to the start. Press again to do it.")
		return
	_disarm()
	if prefs != null:
		prefs.reset_defaults()
	refresh()
	_say("Every key and button is back to the start.")


func _disarm() -> void:
	reset_armed = false
	if reset_row != null:
		reset_row.text = "Reset to defaults"
