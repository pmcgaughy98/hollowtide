extends SceneTree
## The Input Map against the input contract (Claude, 2026-10-23, factory pass 2: controller support and rebinding).
## Reads project.godot's [input] section and the game's scripts, and judges four things:
##   1. Every action the game uses (a script reads it, or a UI.INPUT_CONTEXTS context lists it) has a key and a pad
##      binding, except the three that are one device by design (ONE_DEVICE below).
##   2. The defaults are the contract's, key for key and button for button in the same order (the first one is what a
##      hint prints), so a keyboard player notices no change; and every game key is a physical key, since the checks
##      press physical_keycode (Godot's own ui_accept and ui_cancel stay logical).
##   3. No input serves two actions that share a context, except two INPUT_ADVANCE actions (the clash rule), with a
##      chord's pad button counted as its own input (RB then A is not A). UI.binding_clashes must agree.
##   4. Every action a script under res://scripts reads is in the map.
## Uses project.godot's map, never saved rebinds (InputPrefs skips a check). Headless, a second or two.
##   Godot --headless --path . --script res://tools/debug/input_map_check.gd

const UI := preload("res://scripts/ui/ui_style.gd")
const SCAN := "res://scripts"
# One device by design: the keyboard has 1, 2 and 3 for the moves, so it needs no hold key; a pad has no button to
# spare for full screen; the dex overlay is a debug key.
const ONE_DEVICE := {"moves_hold": "pad", "fullscreen": "keyboard", "toggle_dex": "keyboard"}
const AXES := {JOY_AXIS_LEFT_X: "Left stick X", JOY_AXIS_LEFT_Y: "Left stick Y", JOY_AXIS_RIGHT_X: "Right stick X",
	JOY_AXIS_RIGHT_Y: "Right stick Y", JOY_AXIS_TRIGGER_LEFT: "LT", JOY_AXIS_TRIGGER_RIGHT: "RT"}
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


static func _k(code: int) -> String:
	return "k%d" % code


static func _l(code: int) -> String:
	return "l%d" % code


static func _b(idx: int) -> String:
	return "b%d" % idx


static func _a(axis: int, s: int) -> String:
	return "a%d%s" % [axis, "+" if s > 0 else "-"]


## The contract's defaults: [keys, pad] per action, in order. A key is physical (_k) unless it is Godot's own
## logical one (_l). From the INPUT CONTRACT in scripts/ui/ui_style.gd and project.godot, 2026-10-23.
func _defaults() -> Dictionary:
	return {
		"move_left": [[_k(KEY_LEFT), _k(KEY_A)], [_b(JOY_BUTTON_DPAD_LEFT), _a(JOY_AXIS_LEFT_X, -1)]],
		"move_right": [[_k(KEY_RIGHT), _k(KEY_D)], [_b(JOY_BUTTON_DPAD_RIGHT), _a(JOY_AXIS_LEFT_X, 1)]],
		"move_up": [[_k(KEY_UP), _k(KEY_W)], [_b(JOY_BUTTON_DPAD_UP), _a(JOY_AXIS_LEFT_Y, -1)]],
		"move_down": [[_k(KEY_DOWN), _k(KEY_S)], [_b(JOY_BUTTON_DPAD_DOWN), _a(JOY_AXIS_LEFT_Y, 1)]],
		"interact": [[_k(KEY_E)], [_b(JOY_BUTTON_X)]],
		"confirm": [[_k(KEY_J), _k(KEY_ENTER)], [_b(JOY_BUTTON_A)]],
		"cancel": [[_k(KEY_ESCAPE)], [_b(JOY_BUTTON_B)]],
		"yes": [[_k(KEY_Y), _k(KEY_ENTER)], [_b(JOY_BUTTON_A)]],
		"no": [[_k(KEY_N), _k(KEY_ESCAPE)], [_b(JOY_BUTTON_B)]],
		"attack": [[_k(KEY_J), _k(KEY_SPACE)], [_b(JOY_BUTTON_A)]],
		"move_slot_1": [[_k(KEY_1)], [_b(JOY_BUTTON_A)]],
		"move_slot_2": [[_k(KEY_2)], [_b(JOY_BUTTON_X)]],
		"move_slot_3": [[_k(KEY_3)], [_b(JOY_BUTTON_Y)]],
		"moves_hold": [[], [_b(JOY_BUTTON_RIGHT_SHOULDER)]],
		"rest": [[_k(KEY_Z), _k(KEY_PERIOD)], [_b(JOY_BUTTON_B)]],
		"bag": [[_k(KEY_I)], [_b(JOY_BUTTON_Y)]],
		"tactics": [[_k(KEY_T)], [_b(JOY_BUTTON_LEFT_SHOULDER)]],
		"log": [[_k(KEY_L)], [_b(JOY_BUTTON_RIGHT_STICK)]],
		"autopilot": [[_k(KEY_TAB)], [_b(JOY_BUTTON_BACK)]],
		"run": [[_k(KEY_CTRL)], [_a(JOY_AXIS_TRIGGER_RIGHT, 1)]],
		"turn": [[_k(KEY_SHIFT)], [_a(JOY_AXIS_TRIGGER_LEFT, 1)]],
		"pause": [[_k(KEY_P)], [_b(JOY_BUTTON_START)]],
		"take_out": [[_k(KEY_R)], [_b(JOY_BUTTON_Y)]],
		"page_up": [[_k(KEY_PAGEUP)], [_a(JOY_AXIS_RIGHT_Y, -1)]],
		"page_down": [[_k(KEY_PAGEDOWN)], [_a(JOY_AXIS_RIGHT_Y, 1)]],
		"fullscreen": [[_k(KEY_F11)], []],
		"toggle_dex": [[_k(KEY_F1)], []],
		"ui_accept": [[_l(KEY_ENTER), _l(KEY_KP_ENTER), _l(KEY_SPACE)], [_b(JOY_BUTTON_A)]],
		"ui_cancel": [[_l(KEY_ESCAPE)], [_b(JOY_BUTTON_B)]],
	}


## One id per input, in the _k/_l/_b/_a form above.
func _id(ev: InputEvent) -> String:
	if ev is InputEventKey:
		if ev.physical_keycode != KEY_NONE:
			return _k(ev.physical_keycode)
		return _l(ev.keycode) if ev.keycode != KEY_NONE else "?key"
	if ev is InputEventJoypadButton:
		return _b(ev.button_index)
	if ev is InputEventJoypadMotion:
		return _a(ev.axis, 1 if ev.axis_value > 0.0 else -1)
	return "?" + ev.get_class()


## The id the clash rule compares: a key is its code whether physical or logical (they are the same key on the
## layouts the defaults are for), and a chord's pad button is the hold button plus it.
func _clash_id(action: String, ev: InputEvent) -> String:
	var id := _id(ev)
	if id.begins_with("k") or id.begins_with("l"):
		return "key" + id.substr(1)
	if ev is InputEventJoypadButton and UI.INPUT_CHORDS.has(action):
		var hold_id := "?"
		if InputMap.has_action(UI.INPUT_CHORDS[action]) and not InputMap.action_get_events(UI.INPUT_CHORDS[action]).is_empty():
			hold_id = _id(InputMap.action_get_events(UI.INPUT_CHORDS[action])[0])
		return "%s+%s" % [hold_id, id]
	return id


## An id as words, for the lines: "J", "Enter (logical)", "RB", "Left stick X-".
func _word(id: String) -> String:
	if id.begins_with("k"):
		return OS.get_keycode_string(int(id.substr(1)))
	if id.begins_with("l"):
		return OS.get_keycode_string(int(id.substr(1))) + " (logical)"
	if id.begins_with("b"):
		return String(UI.PAD_WORDS.get(int(id.substr(1)), "button " + id.substr(1)))
	if id.begins_with("a"):
		return "%s%s" % [AXES.get(int(id.substr(1, id.length() - 2)), "axis " + id.substr(1, id.length() - 2)), id.right(1)]
	return id


func _words(ids: Array) -> String:
	return "none" if ids.is_empty() else ", ".join(ids.map(func(i: String) -> String: return _word(i)))


## The action names in project.godot's [input] section, read from the file.
func _project_actions() -> Array:
	var out: Array = []
	var f := FileAccess.open("res://project.godot", FileAccess.READ)
	if f == null:
		return out
	var inside := false
	var name_re := RegEx.create_from_string("^([A-Za-z_][A-Za-z0-9_]*)=\\{")
	for line in f.get_as_text().split("\n"):
		var s := line.strip_edges()
		if s.begins_with("["):
			inside = s == "[input]"
			continue
		if inside:
			var m := name_re.search(s)
			if m != null:
				out.append(m.get_string(1))
	return out


func _gd_files(dir: String, into: Array) -> void:
	var d := DirAccess.open(dir)
	if d == null:
		return
	for sub in d.get_directories():
		_gd_files(dir.path_join(sub), into)
	for f in d.get_files():
		if f.ends_with(".gd"):
			into.append(dir.path_join(f))


## The text with every comment blanked and the line breaks kept, so a match's line number is still right.
func _strip_comments(text: String) -> String:
	var out := PackedStringArray()
	for line in text.split("\n"):
		var quote := ""
		var cut := line.length()
		var i := 0
		while i < line.length():
			var c := line[i]
			if quote != "":
				if c == "\\":
					i += 1
				elif c == quote:
					quote = ""
			elif c == "\"" or c == "'":
				quote = c
			elif c == "#":
				cut = i
				break
			i += 1
		out.append(line.left(cut))
	return "\n".join(out)


## What follows text[open_at] up to its matching close bracket, strings skipped.
func _span(text: String, open_at: int) -> String:
	var open := text[open_at]
	var close := ")" if open == "(" else "]"
	var depth := 0
	var quote := ""
	var i := open_at
	while i < text.length():
		var c := text[i]
		if quote != "":
			if c == "\\":
				i += 1
			elif c == quote:
				quote = ""
		elif c == "\"" or c == "'":
			quote = c
		elif c == open:
			depth += 1
		elif c == close:
			depth -= 1
			if depth == 0:
				return text.substr(open_at + 1, i - open_at - 1)
		i += 1
	return text.substr(open_at + 1)


## Every action name the scripts read: name -> ["file:line", ...]. Finds literal names in the engine's action calls
## (is_action_*, get_vector, get_axis, action_press), the contract's helpers (UI.tapped, held, pressed, tapped_any,
## sync_taps, binding_text, binding_clashes, InputPrefs.save_binding, reset_defaults), a list added to one of UI's
## INPUT_ lists, and const lists whose names end in _ACTIONS (the dungeon's BUFFER_ACTIONS, RUN_STOP_ACTIONS).
func _reads() -> Dictionary:
	var found := {}
	var files: Array = []
	_gd_files(SCAN, files)
	var one := RegEx.create_from_string("\\b(?:is_action_pressed|is_action_just_pressed|is_action_just_released|is_action_released|is_action|get_action_strength|get_action_raw_strength|action_press|action_release|tapped|held|binding_text|binding_clashes|save_binding|reset_defaults)\\s*\\(\\s*&?\"([A-Za-z_][A-Za-z0-9_]*)\"")
	var second := RegEx.create_from_string("\\bpressed\\s*\\(\\s*[A-Za-z_][A-Za-z0-9_.]*\\s*,\\s*&?\"([A-Za-z_][A-Za-z0-9_]*)\"")
	var lists := RegEx.create_from_string("\\b(?:get_vector|get_axis|tapped_any|sync_taps)\\s*(\\()")
	var added := RegEx.create_from_string("\\bINPUT_[A-Z_]+\\s*\\+\\s*(\\[)")
	var consts := RegEx.create_from_string("\\bconst\\s+[A-Z0-9_]*ACTIONS\\s*(?::=|=|:[^=\\n]*=)\\s*(\\[)")
	var names := RegEx.create_from_string("&?\"([A-Za-z_][A-Za-z0-9_]*)\"")
	for path: String in files:
		var text := _strip_comments(FileAccess.get_file_as_string(path))
		var hits: Array = []   # [name, offset]
		for re in [one, second]:
			for m in re.search_all(text):
				hits.append([m.get_string(1), m.get_start(1)])
		for re in [lists, added, consts]:
			for m in re.search_all(text):
				var at: int = m.get_start(1)
				for n in names.search_all(_span(text, at)):
					hits.append([n.get_string(1), at])
		for h in hits:
			var where := "%s:%d" % [path.trim_prefix("res://"), text.substr(0, h[1]).count("\n") + 1]
			if not found.has(h[0]):
				found[h[0]] = []
			if not found[h[0]].has(where):
				found[h[0]].append(where)
	return found


## One context's clash judgement: [clashes, allowed shares], each a list of "actions on input" words.
func _context_clashes(ctx: String) -> Array:
	var by_input := {}   # clash id -> actions
	for a: String in UI.INPUT_CONTEXTS[ctx]:
		if not InputMap.has_action(a):
			continue
		for ev: InputEvent in InputMap.action_get_events(a):
			var cid := _clash_id(a, ev)
			if not by_input.has(cid):
				by_input[cid] = []
			if not by_input[cid].has(a):
				by_input[cid].append(a)
	var clashes: Array = []
	var shared: Array = []
	for cid in by_input:
		var acts: Array = by_input[cid]
		if acts.size() < 2:
			continue
		if acts.all(func(x: String) -> bool: return UI.INPUT_ADVANCE.has(x)):
			shared.append("%s on %s" % ["/".join(acts), _clash_word(cid)])
		else:
			clashes.append("%s on %s" % ["/".join(acts), _clash_word(cid)])
	return [clashes, shared]


## A clash id as words: "J", "A", "RB+A".
func _clash_word(cid: String) -> String:
	if cid.begins_with("key"):
		return OS.get_keycode_string(int(cid.substr(3)))
	return "+".join(Array(cid.split("+")).map(func(p: String) -> String: return _word(p)))


func _run() -> void:
	var defaults := _defaults()
	var project := _project_actions()
	_ok("project.godot's [input] section lists %d actions" % project.size(), project.size() > 0)

	# 4 first, since 1 needs it: every action a script reads is in the map.
	var reads := _reads()
	var missing: Array = []
	for n in reads:
		if not InputMap.has_action(n):
			missing.append(n)
			_ok("'%s' is read at %s but is not in the Input Map" % [n, ", ".join(reads[n])], false)
	var where_count := 0
	for n in reads:
		where_count += reads[n].size()
	var read_names: Array = reads.keys()
	read_names.sort()
	_ok("Scripts under %s read %d action names in %d places, every one in the map: %s" % [SCAN, read_names.size(), where_count, ", ".join(read_names)],
		missing.is_empty() and not read_names.is_empty())
	# The contract's own tables name actions too.
	var table_names := {}
	for ctx in UI.INPUT_CONTEXTS:
		for a in UI.INPUT_CONTEXTS[ctx]:
			table_names[a] = true
	for a in UI.INPUT_ADVANCE + UI.INPUT_CHORDS.keys() + UI.INPUT_CHORDS.values() + UI.INPUT_NAMES.keys():
		table_names[a] = true
	var table_missing: Array = table_names.keys().filter(func(a: String) -> bool: return not InputMap.has_action(a))
	_ok("Every action UI's contract tables name (contexts, advance, chords, names) is in the map%s" % ("" if table_missing.is_empty() else ": missing %s" % str(table_missing)),
		table_missing.is_empty())

	# 1. A key and a pad binding for every action the game uses.
	var uses := table_names.duplicate()
	for n in reads:
		uses[n] = true
	for a: String in project:
		if not uses.has(a):
			print("  note: %s is in project.godot but nothing reads it and no context lists it" % a)
			continue
		var keys: Array = []
		var pad: Array = []
		for ev: InputEvent in InputMap.action_get_events(a):
			if ev is InputEventKey:
				keys.append(_id(ev))
			elif ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
				pad.append(_id(ev))
		var label := "%s: keyboard %s; pad %s" % [a, _words(keys), _words(pad)]
		if ONE_DEVICE.has(a):
			var has_it: bool = (not pad.is_empty()) if ONE_DEVICE[a] == "pad" else (not keys.is_empty())
			_ok("%s (%s only, by design)" % [label, ONE_DEVICE[a]], has_it)
		else:
			_ok(label, not keys.is_empty() and not pad.is_empty())

	# 2. The contract's defaults, in order, and physical keys for the game's own actions.
	var unknown: Array = project.filter(func(a: String) -> bool: return not defaults.has(a))
	_ok("Every project.godot action is in the contract's table%s" % ("" if unknown.is_empty() else ": not in it %s" % str(unknown)), unknown.is_empty())
	var drift: Array = []
	var logical: Array = []
	for a: String in defaults:
		if not InputMap.has_action(a):
			_ok("%s is in the contract but not in the Input Map" % a, false)
			continue
		var keys: Array = []
		var pad: Array = []
		for ev: InputEvent in InputMap.action_get_events(a):
			if ev is InputEventKey:
				keys.append(_id(ev))
				if not a.begins_with("ui_") and ev.physical_keycode == KEY_NONE:
					logical.append(a)
			elif ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
				pad.append(_id(ev))
		var want: Array = defaults[a]
		if keys != want[0] or pad != want[1]:
			drift.append(a)
			_ok("%s: keyboard %s, pad %s; the contract says keyboard %s, pad %s" % [a, _words(keys), _words(pad), _words(want[0]), _words(want[1])], false)
	_ok("All %d actions keep the contract's defaults in order (the first key and button are what hints print)" % defaults.size(), drift.is_empty())
	_ok("Every game key is a physical key (checks press physical_keycode)%s" % ("" if logical.is_empty() else ": logical in %s" % str(logical)), logical.is_empty())

	# 3. The clash rule, context by context.
	var all_clear := true
	for ctx in UI.INPUT_CONTEXTS:
		var judged := _context_clashes(ctx)
		if not judged[0].is_empty():
			all_clear = false
		_ok("Context '%s' (%d actions): no input serves two of them%s%s" % [ctx, UI.INPUT_CONTEXTS[ctx].size(),
			"" if judged[1].is_empty() else "; the advance actions share %s, as allowed" % ", ".join(judged[1]),
			"" if judged[0].is_empty() else "; CLASH: %s" % "; ".join(judged[0])], judged[0].is_empty())
	# The judge can fail: a J planted on the bag for a moment must read as a clash with attack in a Hollow.
	var planted := InputEventKey.new()
	planted.physical_keycode = KEY_J
	InputMap.action_add_event(&"bag", planted)
	var caught: Array = _context_clashes("hollow")[0]
	InputMap.action_erase_event(&"bag", planted)
	_ok("The clash judge catches a planted clash (J on the bag): %s" % str(caught),
		caught.any(func(c: String) -> bool: return c.begins_with("attack/bag") or c.begins_with("bag/attack")) and _context_clashes("hollow")[0].is_empty())
	# UI.binding_clashes (what a rebinding page asks) says the same of every current binding.
	var helper_says: Array = []
	for ctx in UI.INPUT_CONTEXTS:
		for a: String in UI.INPUT_CONTEXTS[ctx]:
			if not InputMap.has_action(a):
				continue
			for ev: InputEvent in InputMap.action_get_events(a):
				var c := UI.binding_clashes(a, ev)
				if not c.is_empty():
					helper_says.append("%s %s with %s" % [a, _word(_id(ev)), ", ".join(c)])
	_ok("UI.binding_clashes agrees: %s" % ("no current binding clashes" if helper_says.is_empty() else "; ".join(helper_says)), helper_says.is_empty() == all_clear)
	# And it does find one: J for the bag would take attack's key in a Hollow and confirm's in the bag; A for the bag
	# would take attack's and confirm's button but not move 1's, whose A is RB then A (the chord rule).
	var j := InputEventKey.new()
	j.physical_keycode = KEY_J
	var a_button := InputEventJoypadButton.new()
	a_button.button_index = JOY_BUTTON_A
	var on_j := UI.binding_clashes(&"bag", j)
	var on_a := UI.binding_clashes(&"bag", a_button)
	_ok("UI.binding_clashes finds a real clash: J for the bag clashes with %s; A with %s" % [str(on_j), str(on_a)],
		on_j.has("attack") and on_j.has("confirm") and on_a.has("attack") and on_a.has("confirm") and not on_a.has("move_slot_1"))
	# What the hints print from the map (UI.binding_text), for the four a player sees first.
	var hints := {"attack": ["J", "A"], "move_slot_1": ["1", "RB+A"], "bag": ["I", "Y"], "interact": ["E", "X"]}
	var hint_bad: Array = []
	for a in hints:
		var kb := UI.binding_text(a, "keyboard")
		var pd := UI.binding_text(a, "pad")
		if kb != hints[a][0] or pd != hints[a][1]:
			hint_bad.append("%s says %s / %s, want %s / %s" % [a, kb, pd, hints[a][0], hints[a][1]])
	_ok("Hints read the map: attack J / A, move 1 1 / RB+A, bag I / Y, use E / X%s" % ("" if hint_bad.is_empty() else ": %s" % "; ".join(hint_bad)),
		hint_bad.is_empty() and UI.binding_text(&"fullscreen", "pad") == "")

	print("INPUT MAP: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
