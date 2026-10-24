extends SceneTree
## Rooms inside Highbank (Claude, 2026-10-10): the Home's door leads in; the team walks to the bed and
## uses it; the door leads back out to the Home's door; the Wayline Hall's counter answers. Windowed, it
## also saves stills of both rooms.
## Pass 3 (Claude, 2026-10-23): on every step in the Home and the Hall the team's line is judged (R3): each
## follower one tile back of the one ahead, never on furniture, the leader's tile or a teammate's, and every
## creature drawn at its feet's depth, mid-step too, so a lower one draws over a higher one and over the
## furniture it stands in front of. The leader walks back into its own line once in each room. The key-hint
## strip (R1) and the spot panels (R2) are measured by the room's own layout: every row's ink inside its frame.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/town_room_check.gd
## Stills go to the runner's logs folder (HT_CHECK_LOGS) when run_checks.py runs it, else to OUT.

const TeamState := preload("res://scripts/town/team_state.gd")
const Room := preload("res://scripts/town/town_room.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const OUT := "res://docs/world/highbank-rooms-2026-10-10/"
var fails := 0
var steps := 0
var line_bad: Array = []   # the first thing wrong with the line, as "when in room: what"


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _snap(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var logs := OS.get_environment("HT_CHECK_LOGS")
	var path := logs.path_join(name + ".png") if logs != "" else ProjectSettings.globalize_path(OUT + name + ".png")
	root.get_texture().get_image().save_png(path)


func _walk(room: Node, to: Vector2i) -> void:
	# Breadth-first over the room's open tiles, then step along the path.
	var start: Vector2i = room.team[0]["pos"]
	var came := {start: start}
	var q: Array = [start]
	while not q.is_empty():
		var c: Vector2i = q.pop_front()
		if c == to:
			break
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = c + d
			if not came.has(n) and room._open(n):
				came[n] = c
				q.append(n)
	if not came.has(to):
		return
	var path: Array = []
	var at := to
	while at != start:
		path.push_front(at)
		at = came[at]
	for step in path:
		await _step(room, step - room.team[0]["pos"])


## One leader step, judged two frames in (mid-step: depth at the feet) and once it has landed (the line).
func _step(room: Node, d: Vector2i) -> void:
	room.act_move(d)
	await _frames(2)
	_judge(room, "mid-step %d" % (steps + 1), true)
	while room.busy:
		await _frames(1)
	await _frames(1)
	steps += 1
	_judge(room, "after step %d" % steps, false)


func _judge(room: Node, when: String, moving: bool) -> void:
	if not line_bad.is_empty():
		return   # the first problem is the one to read
	var wrong := _line_wrong(room, moving)
	if wrong != "":
		line_bad.append("%s in %s: %s" % [when, room.room_id, wrong])


## What is wrong with the team's line now, or "" (R3).
func _line_wrong(room: Node, moving: bool) -> String:
	var at := {}
	for k in room.team.size():
		var e: Dictionary = room.team[k]
		var node: Node2D = e["node"]
		if node.z_index != int(node.position.y):
			return "%s drawn at depth %d with its feet at %.1f" % [e["form"], node.z_index, node.position.y]
		if moving:
			continue
		var t: Vector2i = e["pos"]
		if at.has(t):
			return "%s on %s with %s" % [e["form"], t, at[t]]
		at[t] = e["form"]
		var on_solid: bool = room.room()["solid"].any(func(r: Rect2i) -> bool: return r.has_point(t))
		if not room._open(t) or on_solid:
			return "%s on furniture at %s" % [e["form"], t]
		if k > 0:
			var a: Vector2i = room.team[k - 1]["pos"]
			if maxi(absi(t.x - a.x), absi(t.y - a.y)) != 1:
				return "%s at %s is not one tile back of %s at %s" % [e["form"], t, room.team[k - 1]["form"], a]
		for l in room.lifts:
			var base: int = (l["rect"] as Rect2i).end.y - 1
			if (t.y < base) != (node.z_index < int(l["z"])):
				return "%s at %s sorts on the wrong side of the furniture at %s" % [e["form"], t, l["rect"]]
	if moving:
		return ""
	for a in room.team:
		for b in room.team:
			if a["node"].position.y < b["node"].position.y and a["node"].z_index >= b["node"].z_index:
				return "%s (feet %.0f) drawn over %s (feet %.0f)" % [a["form"], a["node"].position.y, b["form"], b["node"].position.y]
	return ""


## The leader steps onto the tile of the one behind it (the line must make way, not stack).
func _back_into_line(room: Node) -> void:
	var d: Vector2i = room.team[1]["pos"] - room.team[0]["pos"]
	if d.x != 0 and d.y != 0:
		var o: Vector2i = room.team[0]["pos"]
		if not room._open(o + Vector2i(d.x, 0)) or not room._open(o + Vector2i(0, d.y)):
			d = Vector2i(d.x, 0) if room._open(o + Vector2i(d.x, 0)) else Vector2i(0, d.y)
	await _step(room, d)


## The ink of `s` drawn in `role` at baseline `pos`, from its glyphs (TextServer), right-aligned in `width`
## when `width` > 0, else from `pos` rightward.
func _ink(s: String, role: String, pos: Vector2, width := -1.0) -> Rect2:
	var ts := TextServerManager.get_primary_interface()
	var line := TextLine.new()
	line.add_string(s, UI.font(role), UI.type_size(role))
	var top := 0.0
	var bottom := 0.0
	for g in ts.shaped_text_get_glyphs(line.get_rid()):
		var rid: RID = g["font_rid"]
		if not rid.is_valid():
			continue
		var size := Vector2i(int(g["font_size"]), 0)
		var gs: Vector2 = ts.font_get_glyph_size(rid, size, int(g["index"]))
		if gs.y <= 0.0:
			continue
		var off: Vector2 = ts.font_get_glyph_offset(rid, size, int(g["index"]))
		top = minf(top, off.y)
		bottom = maxf(bottom, off.y + gs.y)
	var w := UI.width_in(s, role)
	var left := pos.x + width - w if width > 0.0 else pos.x
	return Rect2(left, pos.y + top, w, bottom - top)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	TeamState.start([[0, 0], [1, 0], [10, 0]])
	# 1. The Home's door leads in.
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await _frames(4)
	var home: Dictionary = town.Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "home")[0]
	town.team[0]["pos"] = home["door"]
	town._place(town.team[0])
	town.act_use()
	_ok("The Home's door: %s" % str(town.get_meta("entered_room", "")), town.get_meta("entered_room", "") == "home")
	town.queue_free()
	await _frames(2)
	TeamState.data["party"] = [[0, 0], [1, 0], [10, 0]]   # three, as a recruited team walks (Highbank keeps two)
	# 2. Inside: the leader in front, its line behind it; walk to the bed and rest; round the table, back into
	# the line once; then back out.
	var room: Node2D = load("res://scenes/town_room.tscn").instantiate()
	room.room_id = "home"
	room.poll_input = false
	root.add_child(room)
	await _frames(10)
	await _snap("home")
	var lead_y: int = room.team[0]["pos"].y
	var behind: bool = room.team.slice(1).all(func(e: Dictionary) -> bool: return e["pos"].y > lead_y)
	_judge(room, "arrival", false)
	_ok("Home arrival: the leader in front at %s, the line behind it at %s" % [room.team[0]["pos"], str(room.team.slice(1).map(func(e: Dictionary) -> Vector2i: return e["pos"]))], behind and line_bad.is_empty())
	await _walk(room, Vector2i(2, 4))
	room.team[0]["facing"] = "n"
	room.act_use()
	var rest_wait := 0
	while room._resting and rest_wait < 90:
		await _frames(1)
		rest_wait += 1
	await _frames(15)   # the fade back up
	await _snap("home_bed")
	_ok("Home: %dx%d tiles; the bed answers: %s" % [room.room()["w"], room.room()["h"], str(room.panel.get("name", ""))], room.panel.get("id", "") == "bed")
	room.act_use()
	await _walk(room, Vector2i(7, 3))   # round the table to its far side
	await _back_into_line(room)
	await _walk(room, room.room()["door"])
	await _frames(2)
	_ok("Out of the door: left %s, back at %s" % [str(room.get_meta("left", false)), str(TeamState.data.get("arrive_at", ""))], room.get_meta("left", false) and TeamState.data.get("arrive_at", "") == "home")
	_ok("Home: %d steps, the line held (one tile back, off the furniture and the leader, drawn by its feet)%s" % [steps, "" if line_bad.is_empty() else ": " + String(line_bad[0])], line_bad.is_empty() and steps > 10)
	room.queue_free()
	await _frames(2)
	# 3. The Wayline Hall and its counter.
	var home_steps := steps
	line_bad.clear()   # the Hall's verdict is its own
	var hall: Node2D = load("res://scenes/town_room.tscn").instantiate()
	hall.room_id = "hall"
	hall.poll_input = false
	root.add_child(hall)
	await _frames(10)
	await _snap("hall")
	_judge(hall, "arrival", false)
	await _walk(hall, Vector2i(11, 9))
	await _back_into_line(hall)
	await _frames(4)
	await _snap("hall_middle")
	await _walk(hall, Vector2i(11, 5))   # the desk is solid on rows 3 and 4 since 2026-10-10
	hall.team[0]["facing"] = "n"
	hall.act_use()
	await _frames(6)
	await _snap("hall_counter")
	_ok("Hall: %dx%d tiles; the counter answers: %s" % [hall.room()["w"], hall.room()["h"], str(hall.panel.get("name", ""))], hall.panel.get("id", "") == "counter")
	hall.act_use()
	await _walk(hall, Vector2i(7, 8))   # beside the Chart Table, whose words run to three rows
	hall.team[0]["facing"] = "w"
	hall.act_use()
	await _frames(6)
	await _snap("hall_chart")
	_ok("Hall: the Chart Table answers (%s) in %d rows" % [str(hall.panel.get("name", "")), Room.spot_layout(String(hall.panel.get("what", ""))).get("rows", []).size()], hall.panel.get("id", "") == "chart")
	_ok("Hall: %d steps, the line held%s" % [steps - home_steps, "" if line_bad.is_empty() else ": " + String(line_bad[0])], line_bad.is_empty() and steps - home_steps > 6)
	hall.queue_free()
	await _frames(2)
	# 4. The key-hint strip (R1), for each room's way-out line and both devices' key lines: both rows' ink
	# inside the strip's brass edge, their right ends 12 px in from it, the strip on screen.
	var device := UI.last_device()
	var key_lines: Array = []
	for dev in ["keyboard", "pad"]:
		UI.set_device(dev)
		key_lines.append(Room.keys_hint())
	UI.set_device(device)
	var wheres: Array = ["The door leads back out"]
	for r in Room.ROOMS:
		if Room.ROOMS[r].has("hint"):
			wheres.append(String(Room.ROOMS[r]["hint"]))
	var hint_bad: Array = []
	var strips := 0
	for keys in key_lines:
		for where in wheres:
			strips += 1
			var lay: Dictionary = Room.hint_layout(where, keys)
			var strip: Rect2 = lay["strip"]
			var inner := strip.grow(-Room.HINT_EDGE)
			var right_end := strip.end.x - Room.HINT_IN
			for row in [[keys, "label", lay["keys"]], [where, lay["where_role"], lay["where"]]]:
				var ink := _ink(row[0], row[1], row[2], lay["width"])
				if not inner.encloses(ink) or ink.end.x > right_end + 0.5 or strip.position.x < 0.0 or strip.end.x > 1152.0:
					hint_bad.append("'%s' ink %s in strip %s" % [row[0], ink, strip])
	_ok("Hint strip: %d strips (%s), each line inside the frame%s" % [strips, " / ".join(key_lines), "" if hint_bad.is_empty() else "; " + ", ".join(hint_bad)], hint_bad.is_empty())
	# 5. The spot panels (R2): every spot's words, its later words and the bed's morning line, wrapped in the
	# story face; every row's ink inside the panel's frame and clear of its right edge; the name tab below the
	# Next strip (it ends at y 98); and no panel left in the old heading face.
	var spot_bad: Array = []
	var texts := 0
	var most := 0
	for r in Room.ROOMS:
		for s in Room.ROOMS[r]["spots"]:
			var says: Array = [String(s.get("what", ""))]
			if s.get("what_if", []).size() == 2:
				says.append(String(s["what_if"][1]))
			if s["id"] == "bed":
				says.append(Room.REST_LINE)
			for what in says:
				if what == "":
					continue
				texts += 1
				var lay: Dictionary = Room.spot_layout(what)
				var box: Rect2 = lay["box"]
				var inner := box.grow(-Room.HINT_EDGE)
				var rows: PackedStringArray = lay["rows"]
				most = maxi(most, rows.size())
				for k in rows.size():
					var ink := _ink(rows[k], "story", lay["at"] + Vector2(0, k * float(lay["row_h"])))
					if not inner.encloses(ink) or ink.end.x > box.end.x - 24.0:
						spot_bad.append("%s in %s row %d: ink %s, box %s" % [s["name"], r, k + 1, ink, box])
				if box.position.y - 22.0 < 104.0:
					spot_bad.append("%s in %s: the name tab at %.0f meets the Next strip" % [s["name"], r, box.position.y - 22.0])
	_ok("Spot panels: %d texts in the story face (at most %d rows), each row inside its frame%s" % [texts, most, "" if spot_bad.is_empty() else "; " + ", ".join(spot_bad)], spot_bad.is_empty() and texts > 30)
	var src := FileAccess.get_file_as_string("res://scripts/town/town_room.gd")
	_ok("Spot panels: town_room.gd draws nothing in the old heading face (UI.HEAD)", src != "" and not src.contains("UI.HEAD"))
	# 6. Room exits go black before the next scene is built (R4): a room made the current scene takes the stairs
	# (go_room), then the next one takes the door out (leave). The fade is read the moment each old scene leaves
	# the tree (it is fully black, so the next scene's load and painting sit on black), and some frames after the
	# new scene arrives (the fade has lifted off it).
	var r1: Node2D = load("res://scenes/town_room.tscn").instantiate()
	r1.room_id = "hall"
	r1.poll_input = false
	root.add_child(r1)
	current_scene = r1
	await _frames(6)
	var stairs_a := await _exit_alpha(r1, func() -> void: r1.go_room({"to": "hall_low", "at": Vector2i(24, 14), "facing": "w", "sfx": "stairs"}))
	await _frames(15)
	var low_lifted := _fade_alpha() == 0.0
	var low: Node = current_scene
	_ok("Stairs: black when the Hall leaves (%.2f), the lower floor arrives (%s) and the fade lifts (%s)" % [stairs_a, str(low.get("room_id")) if low != null else "none", low_lifted], stairs_a >= 0.99 and low != null and low.get("room_id") == "hall_low" and low_lifted)
	if low != null and low.has_method("go_room"):
		var up_a := await _exit_alpha(low, func() -> void: low.go_room({"to": "hall", "at": Vector2i(13, 10), "facing": "w", "sfx": "stairs"}))
		await _frames(15)
		var up: Node = current_scene
		_ok("Stairs up: black when the lower floor leaves (%.2f), the Hall arrives (%s)" % [up_a, str(up.get("room_id")) if up != null else "none"], up_a >= 0.99 and up != null and up.get("room_id") == "hall" and _fade_alpha() == 0.0)
		var door_a := await _exit_alpha(up, func() -> void: up.leave())
		await _frames(15)
		var town_now: Node = current_scene
		var town_ok: bool = town_now != null and town_now.scene_file_path.ends_with("hub_town.tscn")
		_ok("Door out: black when the room leaves (%.2f), Highbank arrives (%s) and lifts the fade (%s)" % [door_a, town_ok, _fade_alpha() == 0.0], door_a >= 0.99 and town_ok and _fade_alpha() == 0.0)
		if town_now != null:
			town_now.queue_free()
			await _frames(2)
	print("ROOMS: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit()


## The fade's black (0 when there is no fade) at the moment `scene` leaves the tree after `go` is called; -1 when it
## never left within five seconds.
func _exit_alpha(scene: Node, go: Callable) -> float:
	var seen := {"a": -1.0}
	scene.tree_exiting.connect(func() -> void: seen["a"] = _fade_alpha(), CONNECT_ONE_SHOT)
	go.call()
	var waited := 0
	while float(seen["a"]) < 0.0 and waited < 150:
		await _frames(1)
		waited += 1
	await _frames(1)   # the new scene lands at the end of the frame it was changed in
	return float(seen["a"])


func _fade_alpha() -> float:
	var layer := root.get_node_or_null(UI.FADE_NAME)
	if layer == null or layer.is_queued_for_deletion():
		return 0.0
	return (layer.get_node("Rect") as ColorRect).color.a
