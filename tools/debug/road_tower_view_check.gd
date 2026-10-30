extends SceneTree
## Road: the far Tower against the willows (Claude, pass 9 W3, H9-04). The mid layer (road.backdrop.mid) tiles and
## scrolls at 0.45 while the far Tower barely moves (x 300 to 236 over the whole trail), so willows cross it now and
## then; the four trail talks are where it must stand clear, because that is where the player stops and looks.
##
## Two looks, both measured on the far Tower's own pixels the way road_check does (inside the view, under no nearer
## layer that is drawn at half or more):
##   1. The walk: the checks' autopilot from the start to the rise; one sample when each trail beat's first line comes
##      up (bluff, tower, parcel, crew). "Clear" is the Waiting Lamp showing and at least CLEAR of the body.
##   2. The sweep: the leader set at every SWEEP px with the camera settled, so the whole trail is on record, and the
##      first READ_SPAN px after each beat (a player reading at the stroll) reported on its own.
## Run: python tools/debug/run_checks.py road_tower_view (the runner adds --fixed-fps 30).

const TeamState := preload("res://scripts/town/team_state.gd")
const RouteScene := preload("res://scripts/story/route_scene.gd")
const ROAD := "res://scenes/road_to_highbank.tscn"
const FAR := "road.backdrop.highbank_far"
const TALKS := ["bluff", "tower", "parcel", "crew"]
const CLEAR := 0.95
const SWEEP := 8
const READ_SPAN := 120.0   # about three seconds of the stroll (38 px/s) after a beat's first line

var scene: Node
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _run() -> void:
	TeamState.start([[0, 0], [1, 0]], {})
	TeamState.data["story"] = {"parcel": "saved", "road_talk": true}
	TeamState.data["beaten"] = ["mouth"]
	TeamState.data["news"] = "cleared"
	scene = (load(ROAD) as PackedScene).instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	var mid := ArtSlots.image("road.backdrop.mid")
	print("The willow layer: %s, %d x %d" % [ArtSlots.spec("road.backdrop.mid").get("status", "?"), mid.get_width(), mid.get_height()])
	# 1. The walk.
	for k in 300:
		if scene.started:
			break
		await process_frame
	scene.autopilot = true
	var samples := {}
	for k in 3000:
		await process_frame
		if not is_instance_valid(scene) or current_scene != scene or scene.in_vista:
			break
		var b := String(scene.beat_now)
		if TALKS.has(b) and not samples.has(b) and scene.line != null:
			samples[b] = _far_seen()
		if samples.size() == TALKS.size():
			break
	var clear := 0
	for b: String in TALKS:
		var s: Dictionary = samples.get(b, {})
		var good: bool = not s.is_empty() and s["lamp"] and float(s["body"]) >= CLEAR
		clear += 1 if good else 0
		print("  %s: leader x %d, camera x %d, %s of the far Tower shows, lamp %s (screen columns %s, rows %s, willow-layer columns %s)" % [b,
			int(s.get("x", -1)), int(s.get("cam", -1)), "%.0f%%" % (float(s.get("body", 0.0)) * 100.0), str(s.get("lamp", false)),
			str(s.get("cols", "")), str(s.get("rows", "")), str(s.get("on_mid", ""))])
	_ok("The far Tower stands clear of the willows at each trail talk: %d of %d (lamp lit and %.0f%% of it or more)" % [clear, TALKS.size(), CLEAR * 100.0],
		clear == TALKS.size())
	# 2. The sweep, the camera settled. The scene's own frame is held still while it runs (nothing awaits).
	scene.autopilot = false
	scene.set_process(false)
	var beats: Array = scene.route["beats"]
	var end := float(beats[beats.size() - 1]["x"])
	var x := float(scene.route["start_x"])
	var all: Array = []
	var after := {}
	while x < end:
		var s := _look_at(x)
		all.append(s)
		for bd: Dictionary in beats:
			var bx := float(bd["x"])
			if TALKS.has(String(bd["id"])) and x >= bx and x < bx + READ_SPAN:
				var id := String(bd["id"])
				var kept: Array = after.get(id, [])
				kept.append(s)
				after[id] = kept
		x += SWEEP
	var sum := 0.0
	var low := 2.0
	var low_x := 0
	var lit := 0
	for s: Dictionary in all:
		sum += float(s["body"])
		lit += 1 if s["lamp"] else 0
		if float(s["body"]) < low:
			low = float(s["body"])
			low_x = int(s["x"])
	print("The whole trail, settled, every %d px (%d looks): %.0f%% of the far Tower on average, the least %.0f%% at x %d, the lamp lit at %d" % [SWEEP,
		all.size(), sum / maxf(1.0, all.size()) * 100.0, low * 100.0, low_x, lit])
	for id: String in TALKS:
		var kept: Array = after.get(id, [])
		var lo := 2.0
		var n_clear := 0
		for s: Dictionary in kept:
			lo = minf(lo, float(s["body"]))
			n_clear += 1 if (s["lamp"] and float(s["body"]) >= CLEAR) else 0
		print("  the first %d px after %s: %d of %d looks clear, the least %.0f%%" % [int(READ_SPAN), id, n_clear, kept.size(), lo * 100.0])
	scene.set_process(true)
	scene.queue_free()
	await process_frame
	print("ROAD TOWER VIEW CHECK: %s" % ("PASS" if fails == 0 else "FAIL (%d)" % fails))
	quit(0 if fails == 0 else 1)


## The leader at `x` facing east, the camera where it settles, every layer laid out for that place.
func _look_at(x: float) -> Dictionary:
	scene.xs[0] = x
	scene.faces[0] = "e"
	scene.cam_x = clampf(x - RouteScene.CAM_LEAD, 0.0, float(scene.route["length"]) - RouteScene.VIEW.x)
	scene._layout(scene._progress())
	return _far_seen()


## The far Tower as the player sees it now (road_check's measure): whether its Waiting Lamp shows and what share of
## the tower's own pixels do, under the layers drawn after it.
func _far_seen() -> Dictionary:
	var far: Array = []
	var nearer: Array = []
	for entry: Array in scene._layers:
		if not far.is_empty():
			nearer.append(entry)
		elif entry[0].get("far", false):
			far = entry
	if far.is_empty():
		return {"lamp": false, "body": 0.0, "x": 0, "cam": 0}
	var s: Sprite2D = far[1]
	var img := ArtSlots.image(FAR)
	var b: Vector2i = ArtSlots.spec(FAR).get("anchors", {}).get("beacon", Vector2i.ZERO)
	var box := RouteScene.FAR_BODY.intersection(Rect2i(Vector2i.ZERO, img.get_size()))   # the Tower above the forest band
	var shown := 0
	var counted := {}
	var cols := Vector2i(9999, -9999)
	var rows := Vector2i(9999, -9999)
	for y in range(box.position.y, box.end.y):
		for x in range(box.position.x, box.end.x):
			if img.get_pixel(x, y).a <= 0.0:
				continue
			var at := Vector2i(RouteScene.far_at(s, Vector2(x, y)))
			if counted.has(at):
				continue
			counted[at] = true
			cols = Vector2i(mini(cols.x, at.x), maxi(cols.y, at.x))
			rows = Vector2i(mini(rows.x, at.y), maxi(rows.y, at.y))
			if _shows(at, nearer):
				shown += 1
	# Where the tower falls on the willow layer's own picture (its columns there), for whoever moves a willow.
	var on_mid := Vector2i(-1, -1)
	for entry: Array in nearer:
		if String(entry[0]["slot"]) == "road.backdrop.mid":
			var ms: Sprite2D = entry[1]
			var w := ArtSlots.image("road.backdrop.mid").get_width()
			on_mid = Vector2i(posmod(int(ms.region_rect.position.x) + cols.x, w), posmod(int(ms.region_rect.position.x) + cols.y, w))
	var lamp: Rect2 = RouteScene.far_lamp_rect(s, b)
	var lit := true
	for y in range(int(lamp.position.y), int(lamp.end.y)):
		for x in range(int(lamp.position.x), int(lamp.end.x)):
			lit = lit and _shows(Vector2i(x, y), nearer)
	return {"lamp": lit, "body": float(shown) / maxf(1.0, counted.size()), "x": int(scene.xs[0]), "cam": int(scene.cam_x),
		"cols": cols, "rows": rows, "on_mid": on_mid}


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
