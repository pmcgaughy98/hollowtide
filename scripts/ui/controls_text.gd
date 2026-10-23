extends RefCounted
## The controls as the player reads them (Claude, 2026-10-22, the factory contract): one copy for the pause
## menu's Controls page and the opening's help, so the two never drift. The three headed groups are the
## opening's help page (creature_opening.gd) plus the run and message keys added on 2026-10-14.
##   const ControlsText := preload("res://scripts/ui/controls_text.gd")
##   for g in ControlsText.groups(): UI.say(self, pos, g["head"], "label", UI.EDGE_LIGHT) ...
## No class_name on purpose: a new global class needs the editor's class cache rebuilt, and the checks run
## headless without it.
## Live keys (Claude, 2026-10-23, factory pass 2: controller support and rebinding). groups(device) and
## note(device) print every key or button as the Input Map holds it now (UI.binding_text), for the device in
## use ("keyboard" or "pad"; the last one used when ""), so a rebound key reads true on every page. The
## consts below are the keyboard defaults as text, kept for any screen that still draws them.

const UI := preload("res://scripts/ui/ui_style.gd")

const TOWN := {
	"head": "IN HIGHBANK",
	"lines": [
		"WASD / arrows: move. E / J / Enter: use a place.",
	],
}
const HOLLOW := {
	"head": "IN A HOLLOW",
	"lines": [
		"WASD / arrows: step. Shift: turn. J / Space: attack. 1-3: moves. I: bag. Z: rest. E: stairs.",
		"Ctrl + direction: run. L: messages.",
		"T: team orders. Tab: autopilot. Y / N: answer a recruit.",
	],
}
const MENUS := {
	"head": "YOUR MENUS",
	"lines": [
		"P: pause. Arrows: move focus. Enter: choose. Esc: back. F11: full screen.",
	],
}
const GROUPS := [TOWN, HOLLOW, MENUS]
## The line over the groups and the rule under IN A HOLLOW (Claude, 2026-10-22, LP-03: GS-05, W07). The pads
## work everywhere since 2026-10-23, so the old "A controller works in the menus only for now" went (proposal).
## The pause menu's Controls page draws note() and TURNS; the opening's help can draw them the same way.
const NOTE := "A keyboard or a controller works everywhere. Change any key or button under Options, Controls."
const TURNS := "Fights in a Hollow are turn-based."
const MOVE_ACTIONS := ["move_up", "move_left", "move_down", "move_right"]   # in WASD order
const FOCUS_ACTIONS := ["ui_up", "ui_left", "ui_down", "ui_right"]          # Godot's own, for the menus


## The line over the groups, for the device shown (proposal lines).
static func note(device := "") -> String:
	if _device(device) == "pad":
		return "Showing the controller. The keyboard works everywhere too. Change any button under Options, Controls."
	return "Showing the keyboard. A controller works everywhere too. Change any key under Options, Controls."


## The three groups with the keys as they are now: [{"head": ..., "lines": [...]}, ...]. A key the device has
## no binding for leaves its sentence out (full screen on a pad).
static func groups(device := "") -> Array:
	var d := _device(device)
	var walk := _dirs(MOVE_ACTIONS, d)
	var town := [_line([[walk, "move"], [_every(["interact", "confirm"], d), "use a place"]])]
	var hollow := [
		_line([[walk, "step"], [key("turn", d), "turn"], [_every(["attack"], d), "attack"], [_moves(d), "moves"],
			[key("bag", d), "bag"], [key("rest", d), "rest"], [key("interact", d), "stairs"]]),
		_line([[_plus(key("run", d), "direction"), "run"], [key("log", d), "messages"]]),
		_line([[key("tactics", d), "team orders"], [key("autopilot", d), "autopilot"], [_join([key("yes", d), key("no", d)]), "answer a recruit"]]),
	]
	var menus := [_line([[key("pause", d), "pause"], [_dirs(FOCUS_ACTIONS, d), "move focus"], [key("ui_accept", d), "choose"],
		[key("ui_cancel", d), "back"], [key("fullscreen", d), "full screen"]])]
	return [{"head": TOWN["head"], "lines": town}, {"head": HOLLOW["head"], "lines": hollow}, {"head": MENUS["head"], "lines": menus}]


## The first binding `action` has on the device ("J", "A", "RB+A"); "" when it has none.
static func key(action: StringName, device := "") -> String:
	return UI.binding_text(action, _device(device))


## The key a "next" hint names: the town's E on a keyboard, A (confirm) on a pad. Either reads as the next
## line, since every INPUT_ADVANCE action does (the faint screen, the evolution scene, the shrine's rows).
static func advance_text(device := "") -> String:
	var d := _device(device)
	var first: String = key("confirm" if d == "pad" else "interact", d)
	return first if first != "" else key("interact" if d == "pad" else "confirm", d)


## Two actions as one hint: "W/S", "D-pad Up/Down", "PgUp/PgDn". On a keyboard a letter key is preferred
## over an arrow, as the town's hints always named W and S.
static func pair(a: StringName, b: StringName, device := "") -> String:
	var d := _device(device)
	var ta := _letter_first(a, d)
	var tb := _letter_first(b, d)
	var cut := ta.rfind(" ")
	if cut > 0 and tb.begins_with(ta.substr(0, cut + 1)):
		return ta + "/" + tb.substr(cut + 1)   # "D-pad Up" and "D-pad Down" -> "D-pad Up/Down"
	return ta + "/" + tb


static func _device(device: String) -> String:
	return device if device in ["keyboard", "pad"] else UI.last_device()


## "Key: what it does." for each pair whose key is set, each sentence starting with a capital.
static func _line(parts: Array) -> String:
	var out := PackedStringArray()
	for p in parts:
		var k := String(p[0])
		if k != "":
			out.append("%s: %s." % [k.left(1).to_upper() + k.substr(1), p[1]])
	return " ".join(out)


static func _texts(action: StringName, d: String) -> PackedStringArray:
	var all := UI.binding_text(action, d, true)
	return all.split(" / ") if all != "" else PackedStringArray()


## Every binding of `actions` on the device, each once: "E / J / Enter".
static func _every(actions: Array, d: String) -> String:
	var out := PackedStringArray()
	for a in actions:
		for t in _texts(a, d):
			if not out.has(t):
				out.append(t)
	return " / ".join(out)


static func _join(keys: Array) -> String:
	var out := PackedStringArray()
	for k in keys:
		if String(k) != "":
			out.append(String(k))
	return " / ".join(out)


static func _plus(k: String, what: String) -> String:
	return "" if k == "" else "%s + %s" % [k, what]


static func _letter_first(action: StringName, d: String) -> String:
	var all := _texts(action, d)
	if d == "keyboard":
		for t in all:
			if t.length() == 1:
				return t
	return all[0] if not all.is_empty() else ""


## The four directions by binding slot: "WASD / arrows" on the default keyboard, "D-pad / left stick" on a pad.
## Four letters print as one word, the arrows as "arrows", a shared prefix once; anything else lists the four.
static func _dirs(actions: Array, d: String) -> String:
	var lists: Array = []
	var n := 0
	for a in actions:
		var t := _texts(a, d)
		lists.append(t)
		n = maxi(n, t.size())
	var out := PackedStringArray()
	var arrows := false
	for i in n:
		var words := PackedStringArray()
		for t: PackedStringArray in lists:
			if i < t.size():
				words.append(t[i])
		if words.size() < lists.size():
			continue   # not a full set of four in this slot
		if Array(words) == ["Up", "Left", "Down", "Right"]:
			arrows = true
			continue
		var single := true
		for w in words:
			single = single and w.length() == 1
		var shared := ""
		for p in ["D-pad ", "Left stick ", "Right stick "]:
			if Array(words).all(func(w: String) -> bool: return w.begins_with(p)):
				shared = p.strip_edges()
		var word := "".join(words) if single else (shared if shared != "" else "/".join(words))
		if shared == "Left stick" or shared == "Right stick":
			word = word.to_lower()
		if not out.has(word):
			out.append(word)
	if arrows:
		out.append("arrows")   # last, as the help always read: "WASD / arrows"
	return " / ".join(out)


## The three move keys: "1-3" for a run of digits, "RB + A / X / Y" for chords that share their hold.
static func _moves(d: String) -> String:
	var t := PackedStringArray()
	for a in ["move_slot_1", "move_slot_2", "move_slot_3"]:
		t.append(key(a, d))
	if t.has(""):
		return _join(Array(t))
	if Array(t).all(func(s: String) -> bool: return s.length() == 1 and s.is_valid_int()) and int(t[1]) == int(t[0]) + 1 and int(t[2]) == int(t[1]) + 1:
		return "%s-%s" % [t[0], t[2]]
	var cut := t[0].find("+")
	if cut > 0 and Array(t).all(func(s: String) -> bool: return s.begins_with(t[0].left(cut + 1))):
		return "%s + %s" % [t[0].left(cut), " / ".join(Array(t).map(func(s: String) -> String: return s.substr(cut + 1)))]
	return " / ".join(t)
