extends SceneTree
## The road up to Highbank (Claude, 2026-10-26, placeholder factory lane S; scripts/story/route_scene.gd,
## scenes/road_to_highbank.tscn). Judges: the scene loads and every slot it draws resolves at its size; the strip is
## about 60 to 90 s at the walking pace; the player walks it on the keyboard (the right arrow) and on the pad (the left
## stick) and reads a line with the pad's A; walking back over a beat does not play it again; Esc asks "Back to the
## title?" and Esc again takes it down; every beat plays once, in order; it ends in Highbank, on the street with the
## arrival panel and the team; and no frame of the road takes over 250 ms. After the pad part the rest walks itself
## (the autopilot pilot_chain_check uses). Writes nothing but the town's own save, in the runner's own folder.
## 2026-10-27, the approved Wayline Tower far off (TOWER_DESIGN.md section 9): the far view's and the vista's beacon
## anchors sit on their painted Waiting Lamps, the far glint's path runs on a painted cable, no lamp or chimney anchor
## of the vista lands on the tower, and on the trail the far Tower is in sight: every half second of the walk the
## Waiting Lamp is checked against the nearer layers (hills, river, willows, trail, ferns) and so is the tower's body.
## 2026-10-28, the vast-scale far view (VAST_SCALE_DESIGN.md): the tower's body is RouteScene.FAR_BODY (the 70 px
## Tower above the forest band), the beacon at its top, the wayline from its Low Reel down and west to the roofs.
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/road_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const SceneKit := preload("res://scripts/town/scene_kit.gd")
const ROAD := "res://scenes/road_to_highbank.tscn"
const ORDER := ["bluff", "tower", "parcel", "crew", "rise"]
const FRAME_MS := 250.0
const FAR := "road.backdrop.highbank_far"
const VISTA := "road.backdrop.vista"
const VISTA_CLEAR := 30   # px either side of the Tower that no house lamp may stand in
const SAMPLE_EVERY := 15     # frames between looks at the far Tower on the trail (half a second at 30 fps)
var fails := 0
var scene: Node
var worst := 0.0
var worst_at := ""
var fired_seen: Array = []
var far_looks: Array = []    # each half second on the trail: {lamp (the Waiting Lamp shows), body (share of the tower in sight), x, glint}
var _last := 0
var _frame_no := 0


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
		_frame_no += 1
		if scene.started and not scene.in_vista and not scene.leaving and _frame_no % SAMPLE_EVERY == 0:
			far_looks.append(_far_seen())
			now = Time.get_ticks_usec()   # the look is the check's own work, not the road's frame
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
	_far_art()
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
	# A as a player presses it: the first press shows the rest of the page, the next turns it or moves on, and a fresh
	# answer list waits CHOICE_ARM (0.3 s) before A takes an answer. Pressed until the line moves on, at most 5 times.
	var before: String = scene.line.text if scene.line != null else ""
	var presses := 0
	while presses < 5 and scene.line != null and scene.line.text == before:
		_button(JOY_BUTTON_A, true)
		await _frames(3)
		_button(JOY_BUTTON_A, false)
		presses += 1
		await _frames(14)
	var after: String = scene.line.text if scene.line != null else ""
	_ok("Pad: A read on from '%s...' to '%s...' (%d presses)" % [before.left(24), after.left(24), presses], before != "" and after != before)
	var tower_lines := await _read()
	_ok("The rest of the Tower beat's lines read (%d more)" % tower_lines, tower_lines >= 4)
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
	_far_trail()
	_ok("No frame of the road over %.0f ms (the longest %.1f ms, at %s)" % [FRAME_MS, worst, worst_at], worst <= FRAME_MS)
	print("ROAD: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)


# ---------------------------------------------------------------------------------------------- the far Tower

## The far view and the held view as painted: the beacon anchors on their Waiting Lamps, the far glint's path on a
## painted cable, the vista's lamp and chimney anchors off the tower.
func _far_art() -> void:
	var far := ArtSlots.image(FAR)
	var fa: Dictionary = ArtSlots.spec(FAR).get("anchors", {})
	var b: Vector2i = fa.get("beacon", Vector2i(-1, -1))
	_ok("Far view: the beacon anchor %s is on the Waiting Lamp (%s), at the Tower's top (FAR_BODY %s)" % [str(b),
		far.get_pixelv(b).to_html(false) if _in(far, b) else "outside", str(RouteScene.FAR_BODY)],
		RouteScene.FAR_BODY.grow(1).has_point(b) and b.y < RouteScene.FAR_BODY.position.y + 6 and _in(far, b) and _lamp_px(far.get_pixelv(b)))
	var top: Vector2 = Vector2(fa.get("wayline_top", Vector2i(-1, -1)))
	var end: Vector2 = Vector2(fa.get("wayline_end", Vector2i(-1, -1)))
	var on := 0
	var n := 40
	for i in n + 1:
		if _near_paint(far, Vector2i(RouteScene.far_wayline_at(top, end, float(i) / n).round())):
			on += 1
	# The wayline leaves the Tower low down (the Low Reel, at the foot of FAR_BODY) and runs down and west to the roofs.
	var from_tower := RouteScene.FAR_BODY.grow(2).has_point(Vector2i(top)) and top.y >= RouteScene.FAR_BODY.end.y - 3
	_ok("Far view: the glint runs down a painted cable from %s (the Tower's Low Reel) down and west to %s (%d of %d points on it)" % [str(top), str(end), on, n + 1],
		top.x >= 0 and end.x >= 0 and from_tower and end.y > top.y and end.x < top.x and on >= int((n + 1) * 0.7))
	var vista := ArtSlots.image(VISTA)
	var va: Dictionary = ArtSlots.spec(VISTA).get("anchors", {})
	var vb: Vector2i = va.get("beacon", Vector2i(-1, -1))
	_ok("Vista: the beacon anchor %s is on the Waiting Lamp (%s)" % [str(vb), vista.get_pixelv(vb).to_html(false) if _in(vista, vb) else "outside"],
		_in(vista, vb) and _lamp_px(vista.get_pixelv(vb)))
	# Nothing built beside the Tower (Preston, 2026-10-28): every house lamp the game lights stands well clear of its axis.
	var lamps := 0
	var near: Array = []
	for key: String in va:
		if key.begins_with("lamp_"):
			lamps += 1
			if absi(int(va[key].x) - vb.x) < VISTA_CLEAR:
				near.append(key)
	_ok("Vista: %d house lamps, none within %d px of the Tower (x %d) %s" % [lamps, VISTA_CLEAR, vb.x, str(near)],
		lamps > 0 and near.is_empty())


## The looks taken on the trail: the Waiting Lamp in sight every time; the tower mostly in sight (a willow may pass in
## front of it for a moment, as trees do, but not while the two talk about it); the glint moving down its wayline.
func _far_trail() -> void:
	var n := far_looks.size()
	var hidden: Array = []
	var avg := 0.0
	var low := 1.0
	var low_at := 0
	var talk_low := 1.0
	var talk_n := 0
	var glints := {}
	for l: Dictionary in far_looks:
		if not l["lamp"]:
			hidden.append(l["x"])
		avg += float(l["body"])
		if float(l["body"]) < low:
			low = float(l["body"])
			low_at = int(l["x"])
		if String(l["beat"]) == "tower":
			talk_low = minf(talk_low, float(l["body"]))
			talk_n += 1
		if float(l["glint"]) <= 1.0:
			glints[snappedf(float(l["glint"]), 0.01)] = true
	avg /= maxf(1.0, n)
	_ok("On the trail the far Tower's Waiting Lamp shows at %d of %d looks (hidden at x %s)" % [n - hidden.size(), n, str(hidden.slice(0, 8))],
		n >= 20 and hidden.is_empty())
	_ok("And the tower itself is in sight: %.0f%% of it on average (the least %.0f%%, at x %d, a willow passing)" % [avg * 100.0, low * 100.0, low_at],
		avg >= 0.6)
	_ok("While the two talk about the Tower it is in sight: at least %.0f%% of it at %d looks" % [talk_low * 100.0, talk_n],
		talk_n >= 3 and talk_low >= 0.75)
	_ok("The glint runs down its wayline (seen at %d places along it)" % glints.size(), glints.size() >= 3)


## The far Tower as the player sees it now: whether its Waiting Lamp shows (inside the view, under no nearer layer)
## and what share of the tower's own pixels do. The nearer layers are those drawn after it, the ferns included; one
## faded below half (the river dropping back, the trees opening) hides nothing.
func _far_seen() -> Dictionary:
	var far: Array = []
	var nearer: Array = []
	for entry: Array in scene._layers:
		if not far.is_empty():
			nearer.append(entry)
		elif entry[0].get("far", false):
			far = entry
	if far.is_empty():
		return {"lamp": false, "body": 0.0, "x": 0, "glint": 2.0}
	var s: Sprite2D = far[1]
	var img := ArtSlots.image(FAR)
	var b: Vector2i = ArtSlots.spec(FAR).get("anchors", {}).get("beacon", Vector2i.ZERO)
	var box := RouteScene.FAR_BODY.intersection(Rect2i(Vector2i.ZERO, img.get_size()))   # the Tower above the forest band
	var shown := 0
	var counted := {}
	for y in range(box.position.y, box.end.y):
		for x in range(box.position.x, box.end.x):
			if img.get_pixel(x, y).a <= 0.0:
				continue
			var at := Vector2i(RouteScene.far_at(s, Vector2(x, y)))
			if counted.has(at):
				continue
			counted[at] = true
			if _shows(at, nearer):
				shown += 1
	var lamp: Rect2 = RouteScene.far_lamp_rect(s, b)
	var lit := true
	for y in range(int(lamp.position.y), int(lamp.end.y)):
		for x in range(int(lamp.position.x), int(lamp.end.x)):
			lit = lit and _shows(Vector2i(x, y), nearer)
	return {"lamp": lit, "body": float(shown) / maxf(1.0, counted.size()), "x": int(scene.xs[0]), "glint": scene.glint_t(),
		"beat": String(scene.beat_now)}


## Whether screen pixel `at` is inside the view and under none of the nearer layers.
func _shows(at: Vector2i, nearer: Array) -> bool:
	if at.x < 0 or at.y < 0 or at.x >= scene.VIEW.x or at.y >= scene.VIEW.y:
		return false
	for entry: Array in nearer:
		var s: Sprite2D = entry[1]
		var faded: Variant = (entry[2] as ShaderMaterial).get_shader_parameter("alpha")
		if faded != null and float(faded) < 0.5:
			continue
		var img := ArtSlots.image(String(entry[0]["slot"]))
		var ty := at.y - int(s.position.y)
		if ty < 0 or ty >= img.get_height():
			continue
		var tx := posmod(int(s.region_rect.position.x) + at.x - int(s.position.x), img.get_width())
		if img.get_pixel(tx, ty).a > 0.5:
			return false
	return true


## The Waiting Lamp's amber: bright, warm and saturated (the stone round it is bright and warm but paler).
func _lamp_px(c: Color) -> bool:
	return c.a > 0.5 and c.get_luminance() > 0.55 and c.s > 0.4 and c.h > 0.05 and c.h < 0.17


func _in(img: Image, p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < img.get_width() and p.y < img.get_height()


## Whether there is paint at `p` or one pixel round it.
func _near_paint(img: Image, p: Vector2i) -> bool:
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var q := p + Vector2i(dx, dy)
			if _in(img, q) and img.get_pixelv(q).a > 0.0:
				return true
	return false


func route_id_of() -> String:
	return String(scene.route_id) if is_instance_valid(scene) else "?"
