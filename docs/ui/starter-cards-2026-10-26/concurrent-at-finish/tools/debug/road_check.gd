extends SceneTree
## The road up to Highbank (Claude, 2026-10-26, placeholder factory lane S; scripts/story/route_scene.gd,
## scenes/road_to_highbank.tscn). Judges: the scene loads and every slot it draws resolves at its size; the strip is
## about 60 to 90 s at the walking pace; the player walks it on the keyboard (the right arrow) and on the pad (the left
## stick) and reads a line with the pad's A; walking back over a beat does not play it again; Esc asks "Back to the
## title?" and Esc again takes it down; every beat plays once, in order; it ends in Highbank, on the street with the
## arrival panel and the team; and no frame of the road takes over 250 ms. After the pad part the rest walks itself
## (the autopilot pilot_chain_check uses). Writes nothing but the town's own save, in the runner's own folder.
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/road_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const SceneKit := preload("res://scripts/town/scene_kit.gd")
const ROAD := "res://scenes/road_to_highbank.tscn"
const ORDER := ["bluff", "tower", "parcel", "crew", "rise"]
const FRAME_MS := 250.0
var fails := 0
var scene: Node
var worst := 0.0
var worst_at := ""
var fired_seen: Array = []
var _last := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


## One frame. While the road is the scene, the longest frame is kept and the beats it has played are copied.
func _frame() -> void:
	await process_frame
	var now := Time.get_ticks_usec()
	var on_road := scene != null and is_instance_valid(scene) and current_scene == scene
	if on_road:
		if _last > 0:
			var ms := (now - _last) / 1000.0
			if ms > worst:
				worst = ms
				worst_at = "x %d, beats %s" % [int(scene.xs[0]), str(scene.fired)]
		fired_seen = scene.fired.duplicate()
	_last = now


func _frames(n: int) -> void:
	for k in n:
		await _frame()


func _until(done: Callable, budget: int) -> bool:
	for k in budget:
		if done.call():
			return true
		await _frame()
	return done.call()


func _key(code: Key, down: bool) -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = code
	ev.keycode = code
	ev.pressed = down
	Input.parse_input_event(ev)


func _tap_key(code: Key) -> void:
	_key(code, true)
	await _frames(3)
	_key(code, false)
	await _frames(3)


func _axis(a: JoyAxis, v: float) -> void:
	var ev := InputEventJoypadMotion.new()
	ev.device = 0
	ev.axis = a
	ev.axis_value = v
	Input.parse_input_event(ev)


func _button(b: JoyButton, down: bool) -> void:
	var ev := InputEventJoypadButton.new()
	ev.device = 0
	ev.button_index = b
	ev.pressed = down
	Input.parse_input_event(ev)


## Read every line up now as a player would, a press every three frames; the first answer each time.
func _read() -> int:
	var n := 0
	for k in 400:
		if not is_instance_valid(scene) or current_scene != scene:
			break
		if scene.line == null and not scene._fetching:
			break
		await _frames(3)
		if scene.line != null:
			UI.finish_line()
			await scene.advance()
			n += 1
	return n


func _run() -> void:
	TeamState.start([[0, 0], [1, 0]], {})
	TeamState.data["story"] = {"parcel": "saved", "road_talk": true}
	TeamState.data["beaten"] = ["mouth"]
	TeamState.data["news"] = "cleared"   # as the Mouth's first clear leaves it (dungeon.gd _go_to_town)
	# What the dawn bank (mouth_escape.gd) has loaded when it hands over: the town's script (its street bake), the
	# party's names (SceneKit's kept names) and the road scene (read on a thread while the bank plays). Timed apart:
	# in a fresh process these are the scripts' first compile, which the player pays on the bank, not here.
	var tw := Time.get_ticks_usec()
	load("res://scripts/town/hub_town.gd")
	for m: Array in TeamState.data["party"]:
		SceneKit.name_of(int(m[0]), int(m[1]))
	var packed: PackedScene = load(ROAD)
	print("The dawn bank's loads, before the road: %.0f ms" % ((Time.get_ticks_usec() - tw) / 1000.0))
	var t0 := Time.get_ticks_usec()
	scene = packed.instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	var build := (Time.get_ticks_usec() - t0) / 1000.0
	_last = Time.get_ticks_usec()
	worst = build
	worst_at = "the build"
	# 1. The scene and its art.
	var route: Dictionary = scene.route
	var slots: Array = []
	for layer: Dictionary in route.get("layers", []):
		slots.append(String(layer["slot"]))
	for prop: Dictionary in route.get("props", []):
		slots.append(String(prop["slot"]))
	for b: Dictionary in route.get("beats", []):
		if b.has("vista"):
			slots.append(String(b["vista"]))
	var bad: Array = []
	for id: String in slots:
		if not ArtSlots.has(id) or Vector2i(ArtSlots.texture(id).get_size()) != ArtSlots.sheet_size(id):
			bad.append(id)
	print("The road's build steps (ms): %s" % str(scene.laps))
	_ok("The road loads (%s, built in %.0f ms): %d in the party, %d slots, all at their size %s" % [route_id_of(), build, scene.actors.size(), slots.size(), str(bad)],
		not route.is_empty() and scene.actors.size() >= 2 and bad.is_empty() and slots.size() >= 10)
	var beats: Array = route.get("beats", [])
	var walk_secs: float = (float(beats[beats.size() - 1]["x"]) - float(route["start_x"])) / float(scene.WALK_SPEED)
	_ok("The trail is %.0f s at a walk (about 60 to 90)" % walk_secs, walk_secs >= 55.0 and walk_secs <= 95.0)
	await _until(func() -> bool: return scene.started, 150)
	_ok("The black lifts and the party walks on (started %s, leader at x %d)" % [scene.started, int(scene.xs[0])], scene.started)
	# 2. The keyboard: hold the right arrow until the first beat plays.
	var x0: float = scene.xs[0]
	_key(KEY_RIGHT, true)
	await _until(func() -> bool: return scene.fired.has("bluff"), 400)
	_key(KEY_RIGHT, false)
	_ok("Keyboard: the right arrow walked the party from x %d to %d and the first beat played (%s)" % [int(x0), int(scene.xs[0]), str(scene.fired)],
		scene.fired.has("bluff") and scene.xs[0] > x0 + 100.0)
	await _until(func() -> bool: return scene.line != null, 60)
	var bluff_lines := await _read()
	_ok("The first beat's lines read (%d), the party strolling on (x %d)" % [bluff_lines, int(scene.xs[0])], bluff_lines >= 6)
	# 3. The pad: the left stick to the next beat, then A reads a line.
	var x1: float = scene.xs[0]
	_axis(JOY_AXIS_LEFT_X, 1.0)
	await _until(func() -> bool: return scene.fired.has("tower"), 900)
	_axis(JOY_AXIS_LEFT_X, 0.0)
	_ok("Pad: the left stick walked the party from x %d to %d and the next beat played (%s)" % [int(x1), int(scene.xs[0]), str(scene.fired)],
		scene.fired.has("tower") and scene.xs[0] > x1 + 100.0)
	await _until(func() -> bool: return scene.line != null and not scene._fetching, 60)
	await _frames(6)
	UI.finish_line()   # the line typed out; its answers come up with it
	await _frames(12)   # accept waits CHOICE_ARM (0.3 s) on a fresh answer list before it takes one
	var before: String = scene.line.text if scene.line != null else ""
	print("DBG before A: done %s age %s up %s armed %s fetch %s resp %d" % [UI.line_done(scene.line.text), scene._list_age, scene._choices_up(), scene._choices_armed(), scene._fetching, scene.line.responses.size()])
	_button(JOY_BUTTON_A, true)
	for d in 3:
		await _frames(1)
		print("DBG down %d: line '%s' done %s age %s held %s" % [d, scene.line.text.left(20) if scene.line != null else "null", UI.line_done(scene.line.text) if scene.line != null else false, scene._list_age, UI.held("attack")])
	_button(JOY_BUTTON_A, false)
	await _until(func() -> bool: return scene.line != null and scene.line.text != before, 30)
	var after: String = scene.line.text if scene.line != null else ""
	_ok("Pad: A read on from '%s...' to '%s...'" % [before.left(24), after.left(24)], before != "" and after != before)
	var tower_lines := await _read()
	_ok("The Tower beat's lines read, an answer taken (%d more)" % tower_lines, tower_lines >= 6)
	# 4. Back over a beat that has played: it stays played.
	var played: int = scene.fired.size()
	_key(KEY_LEFT, true)
	await _until(func() -> bool: return scene.xs[0] < 1100.0, 150)
	_key(KEY_LEFT, false)
	var back_x: float = scene.xs[0]
	_key(KEY_RIGHT, true)
	await _until(func() -> bool: return scene.xs[0] > 1300.0, 200)
	_key(KEY_RIGHT, false)
	_ok("Walked back to x %d and on to %d: no beat played again (%s)" % [int(back_x), int(scene.xs[0]), str(scene.fired)],
		back_x < 1150.0 and scene.fired.size() == played and scene.fired.count("tower") == 1 and scene.line == null)
	# 5. Esc asks about the title; Esc again takes it down.
	await _tap_key(KEY_ESCAPE)
	var asked: bool = scene.asking
	await _tap_key(KEY_ESCAPE)
	_ok("Esc asks 'Back to the title?' (%s), Esc again resumes (%s)" % [asked, not scene.asking], asked and not scene.asking)
	# 6. The rest walks itself, as the pilot chain's does, to the rise and on down to Highbank.
	scene.autopilot = true
	await _until(func() -> bool: return current_scene != scene, 30 * 120)
	var landed := await _until(func() -> bool:
		return current_scene != null and current_scene.scene_file_path.ends_with("hub_town.tscn") and not current_scene.team.is_empty(), 30 * 30)
	_ok("Every beat played once, in order: %s" % str(fired_seen), fired_seen == ORDER)
	var town: Node = current_scene
	var panel: String = String(town.panel.get("name", "")) if landed and town.panel is Dictionary else ""
	_ok("Ends in Highbank on the street (%s): team %d, the arrival panel '%s', the parcel %s" % [town.scene_file_path.get_file() if town != null else "none",
		town.team.size() if landed else 0, panel, String(TeamState.data.get("story", {}).get("parcel", ""))],
		landed and town.team.size() >= 2 and panel == "Highbank")
	_ok("No frame of the road over %.0f ms (the longest %.1f ms, at %s)" % [FRAME_MS, worst, worst_at], worst <= FRAME_MS)
	print("ROAD: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)


func route_id_of() -> String:
	return String(scene.route_id) if is_instance_valid(scene) else "?"
