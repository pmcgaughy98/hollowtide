extends SceneTree
## Rooms inside Highbank (Claude, 2026-10-10): the Home's door leads in; the team walks to the bed and
## uses it; the door leads back out to the Home's door; the Wayline Hall's counter answers. Windowed, it
## also saves stills of both rooms.
## Pass 3 (Claude, 2026-10-23): on every step in the Home and the Hall the team's line is judged (R3): each
## follower one tile back of the one ahead, never on furniture, the leader's tile or a teammate's, and every
## creature drawn at its feet's depth, mid-step too, so a lower one draws over a higher one and over the
## furniture it stands in front of. The leader walks back into its own line once in each room. The key-hint
## strip (R1) and the spot panels (R2) are measured by the room's own layout: every row's ink inside its frame.
## Pass 8 (Claude, 2026-10-26): a team of four, Sparkwick in it, in every room on arrival, after the bed's night, after
## the runners scene and at the Hall's door: no two on one tile and nobody inside a wall or a piece of furniture (R1, R5);
## the runners' line-up is one row (R4); the Hall's way out is both tiles at the carpet's end (R3); the Roster Board
## swaps a waiting creature in and a member out, the leader never moves, and a save and reload keep the change (R6).
## Placeholder factory lane R (Claude, 2026-10-26): the rooms' art slots resolve and fit, Codex's four unused fixtures
## stay off, and the new Item Shop room and Scroll Keeper's cellar build while Highbank keeps their doors shut (_slots).
##   Godot --path . --fixed-fps 30 --script res://tools/debug/town_room_check.gd
## Stills go to the runner's logs folder (HT_CHECK_LOGS) when run_checks.py runs it, else to OUT.

const TeamState := preload("res://scripts/town/team_state.gd")
const Room := preload("res://scripts/town/town_room.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const OUT := "res://docs/world/highbank-rooms-2026-10-10/"
const GuildCrew := preload("res://scripts/town/guild_crew.gd")
const GuildScene := preload("res://scripts/town/guild_scene.gd")
const FOUR := [[0, 1], [1, 0], [10, 0], [2, 0]]   # Sparkwick leads, then Tallowroot, Troughspine and Rimefin
var fails := 0
var steps := 0
var line_bad: Array = []   # the first thing wrong with the line, as "when in room: what"
## Steps after the bed's night in which a member may still be two tiles back of the one ahead (pass 8 R5): the night sets
## the others on their own tiles round the leader by the arrival rule, and a member two back closes up as the line walks
## (town_room.gd _arrival_tiles, T8). The leader then walks back into its own line, so it can take two steps.
var grace := 0


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
	grace = maxi(0, grace - 1)


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
			var gap := maxi(absi(t.x - a.x), absi(t.y - a.y))
			if gap != 1 and not (grace > 0 and gap == 2):
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
	grace = room.team.size() - 1   # the night re-spaced the line (pass 8 R5)
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
	await _four()
	await _slots()
	print("ROOMS: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit()


## A room built by hand, `arrive` and `facing` for a stair or inner door (none: the town door), scenes on or off.
func _room(id: String, arrive := Vector2i(-1, -1), facing := "s", scenes := false) -> Node2D:
	var r: Node2D = load("res://scenes/town_room.tscn").instantiate()
	r.room_id = id
	r.poll_input = false
	r.force_scenes = scenes
	if arrive.x >= 0:
		r.arrive = arrive
		r.arrive_facing = facing
	root.add_child(r)
	await _frames(8)
	return r


func _free(r: Node) -> void:
	r.queue_free()
	await _frames(2)


## What is wrong with the team at rest (pass 8 R1): two members on one tile, one inside a wall or a piece of furniture,
## or one drawn off its own tile; "" when nothing is.
func _heap(room: Node) -> String:
	var at := {}
	for e in room.team:
		var t: Vector2i = e["pos"]
		if at.has(t):
			return "%s and %s share %s" % [at[t], e["form"], t]
		at[t] = e["form"]
		var on_solid: bool = room.room()["solid"].any(func(r: Rect2i) -> bool: return r.has_point(t))
		if on_solid or not room._open(t):
			return "%s stands inside a solid at %s" % [e["form"], t]
		var off: float = (e["node"] as Node2D).position.distance_to(room._px(t))
		if off > 0.5:
			return "%s drawn %.0f px off its tile %s" % [e["form"], off, t]
	return ""


func _tiles(room: Node) -> Array:
	return room.team.map(func(e: Dictionary) -> Vector2i: return e["pos"])


## The most two members' sprites cover of each other where they stand (town_room's own measure).
func _worst(room: Node) -> float:
	var worst := 0.0
	for a in room.team.size():
		for b in range(a + 1, room.team.size()):
			var ea: Dictionary = room.team[a]
			var eb: Dictionary = room.team[b]
			worst = maxf(worst, Room._overlap(Room._extent_of(ea["still"][ea["facing"]]), ea["pos"], Room._extent_of(eb["still"][eb["facing"]]), eb["pos"]))
	return worst


## Pass 8 (Claude, 2026-10-26): a team of four through the rooms (R1, R3, R4, R5, R6).
func _four() -> void:
	TeamState.start(FOUR.duplicate(true))
	TeamState.data["story"] = {"met_crew": true, "parcel": "stolen", "guild_trial": true}
	TeamState.data["story"]["mail_call"] = GuildCrew.stage_of(TeamState.data)   # the mail call is spent: no scene below
	# 1. Arrival in every room (R1): each member on its own open tile.
	var arrive_bad: Array = []
	for spec in [["home"], ["hall"], ["storage"], ["hall_low", Vector2i(24, 14), "w"], ["chamber", Vector2i(8, 8), "n"], ["runners", Vector2i(1, 5), "e"], ["hall", Vector2i(13, 10), "w"]]:
		var r := await _room(String(spec[0]), spec[1] if spec.size() > 1 else Vector2i(-1, -1), String(spec[2]) if spec.size() > 2 else "s")
		var bad := _heap(r)
		if bad != "":
			arrive_bad.append("%s: %s" % [spec[0], bad])
		if spec.size() == 1:
			await _snap(String(spec[0]) + "_four")
		await _free(r)
	_ok("Four on arrival in the Home, the Hall (door and stairs), the Storage, the lower floor, the chamber and the runners' room: each on its own open tile%s" % ("" if arrive_bad.is_empty() else "; " + ", ".join(arrive_bad)), arrive_bad.is_empty())
	# The talk box above every prop (R2): the HUD on its own canvas layer over the room, every lifted prop inside the
	# room's SubViewport, so no prop can draw over the box.
	var low := await _room("hall_low", Vector2i(24, 14), "w")
	var hud: Node = low.get_node_or_null("Hud")
	var props_in_view: bool = low.lifts.all(func(l: Dictionary) -> bool: return (l["node"] as Node).get_viewport() is SubViewport)
	_ok("Talk box: the HUD is on its own canvas layer (%s, layer %s) and the lower floor's %d lifted props are all inside the room's view (%s)" % [hud is CanvasLayer, str(hud.get("layer")) if hud != null else "none", low.lifts.size(), props_in_view],
		hud is CanvasLayer and int(hud.layer) >= 1 and low._hud.get_parent() == hud and props_in_view and low.lifts.size() > 0)
	await _free(low)
	# 2. The bed's night (R5): under the black the others take their own tiles round the leader.
	var home := await _room("home")
	await _walk(home, Vector2i(2, 4))
	home.team[0]["facing"] = "n"
	home.act_use()
	var rest_wait := 0
	while home._resting and rest_wait < 120:
		await _frames(1)
		rest_wait += 1
	await _frames(15)
	await _snap("home_bed_four")
	var want: Array = home.trail_tiles("s")
	_ok("The bed with four: the morning finds each on its own tile round the leader %s (the arrival rule gives %s)%s" % [str(_tiles(home)), str(want), "" if _heap(home) == "" else "; " + _heap(home)],
		_heap(home) == "" and _tiles(home) == want and home.panel.get("id", "") == "bed")
	home.act_use()
	await _free(home)
	# 3. The Hall's way out (R3): both tiles under the carpet's end open, the walls beside them shut; the leader walks
	# down the carpet's left half and steps out onto the threshold.
	line_bad.clear()
	var hall := await _room("hall")
	var exits: bool = hall._open(Vector2i(10, 13)) and hall._open(Vector2i(11, 13)) and not hall._open(Vector2i(9, 13)) and not hall._open(Vector2i(12, 13))
	await _walk(hall, Vector2i(10, 12))
	await _frames(4)
	await _snap("hall_door_four")
	var before_door := _heap(hall)
	await _step(hall, Vector2i(0, 1))
	await _frames(2)
	_ok("Hall door: tiles (10, 13) and (11, 13) are the way out, (9, 13) and (12, 13) wall (%s); from the carpet's left half the leader steps out (left %s, back at %s); the team at the door %s" % [exits, str(hall.get_meta("left", false)), str(TeamState.data.get("arrive_at", "")), "on its own tiles" if before_door == "" else before_door],
		exits and hall.get_meta("left", false) and TeamState.data.get("arrive_at", "") == "hall" and before_door == "")
	await _free(hall)
	line_bad.clear()
	# 4. The Roster Board (R6): a notice until the team are runners, then the panel.
	TeamState.data["party"] = FOUR.duplicate(true)
	TeamState.data["roster"] = [[3, 0], [103, 0]]
	var board := await _room("hall")
	board.team[0]["pos"] = Vector2i(18, 3)
	board.team[0]["facing"] = "n"
	board._place(board.team[0])
	board.respace("n")
	board.act_use()
	var notice: bool = board.panel.get("id", "") == "roster" and String(board.panel.get("service", "")) == ""
	board.act_use()   # closes the notice
	TeamState.data["story"]["runner"] = true
	TeamState.data["story"]["parcel"] = "delivered"
	board.act_use()
	var opened: bool = String(board.panel.get("service", "")) == "roster"
	await _frames(3)
	await _snap("roster_keyboard")
	var device := UI.last_device()
	UI.set_device("pad")
	await _frames(2)
	await _snap("roster_pad")
	UI.set_device(device)
	var leader: Array = TeamState.data["party"][0].duplicate()
	# Swap out: Rimefin, in slot 4, goes to wait.
	board.act_roster_side(1)
	board.act_roster_move(1)
	board.act_roster_move(1)   # slot 2 -> slot 4
	board.act_roster_pick()
	var party: Array = TeamState.data["party"]
	var waiting: Array = TeamState.data["roster"]
	var out_ok: bool = party.size() == 3 and waiting.has([2, 0]) and board.team.size() == 3
	# Swap in: the first waiting creature joins the open slot.
	board.act_roster_side(-1)
	var first_waiting: Array = waiting[0].duplicate()
	board.act_roster_pick()
	var in_ok: bool = party.size() == 4 and party[3] == first_waiting and not waiting.has(first_waiting) and board.team.size() == 4
	# A trade with the team full: pick a waiting creature, then the member in slot 2.
	board.act_roster_side(-1)
	var coming: Array = waiting[0].duplicate()
	var going: Array = party[1].duplicate()
	board.act_roster_pick()
	var held: bool = not (board.panel.get("held", {}) as Dictionary).is_empty()
	board.act_roster_pick()   # the cursor went to slot 2
	var trade_ok: bool = held and party[1] == coming and waiting.has(going) and party.size() == 4
	await _frames(3)
	await _snap("roster_after")
	var lead_ok: bool = party[0] == leader and board.team[0]["line"] == leader[0] and board.team[0]["stage"] == leader[1]
	var forms_ok: bool = board.team.size() == party.size() and range(party.size()).all(func(k: int) -> bool: return board.team[k]["line"] == party[k][0] and board.team[k]["stage"] == party[k][1])
	var board_heap := _heap(board)
	# Saved and read back: the change is in the save.
	var want_party: Array = party.duplicate(true)
	var want_roster: Array = waiting.duplicate(true)
	var was_path: String = TeamState.save_path
	TeamState.save_path = "user://town_room_check_roster.save"
	var saved := TeamState.save()
	TeamState.data = {}
	var loaded := TeamState.load_save()
	var kept: bool = saved and loaded and TeamState.data.get("party", []) == want_party and TeamState.data.get("roster", []) == want_roster
	TeamState.save_path = was_path
	_ok("Roster Board: a notice before the team are runners (%s), the panel after (%s); swap out %s, swap in %s, trade %s; the leader unchanged %s; the room's team matches the party %s%s; saved and read back %s" % [notice, opened, out_ok, in_ok, trade_ok, lead_ok, forms_ok, "" if board_heap == "" else " (" + board_heap + ")", kept],
		notice and opened and out_ok and in_ok and trade_ok and lead_ok and forms_ok and board_heap == "" and kept)
	# The panel's words fit their places (R6): the note and both devices' key lines, held or not, inside the frame; each
	# name in this check inside its column.
	var Roster: GDScript = load("res://scripts/town/roster_panel.gd")
	var inner: float = Roster.BOX.size.x - 60.0
	var fit_bad: Array = []
	if UI.width_of(Roster.NOTE, 16) > inner:
		fit_bad.append("the note")
	var dev_was := UI.last_device()
	for dev in ["keyboard", "pad"]:
		UI.set_device(dev)
		for holding in [false, true]:
			if UI.width_of(Roster.keys_line(holding), 15) > inner:
				fit_bad.append("'%s'" % Roster.keys_line(holding))
	UI.set_device(dev_was)
	for who in party + waiting:
		var nm: String = Roster._name(who)
		if UI.width_of(nm, 19) > Roster.NAME_W:
			fit_bad.append(nm)
	_ok("Roster Board: its words fit (the note, the key lines on both devices, %d names)%s" % [party.size() + waiting.size(), "" if fit_bad.is_empty() else "; too wide: " + ", ".join(fit_bad)], fit_bad.is_empty())
	board.panel = {}
	await _free(board)
	# 5. The runners scene with four (R4, R1): the line-up is one row, the pair in the middle; after the scene the others
	# close up behind the leader, each on its own tile.
	TeamState.start(FOUR.duplicate(true))
	TeamState.data["story"] = {"met_crew": true, "parcel": "recovered", "guild_trial": true}
	var scene := await _room("hall", Vector2i(-1, -1), "s", true)
	var lineup: Array = []
	var line_worst := 0.0
	var g := 0
	while (scene.cutscene or g < 10) and g < 30 * 90:
		await _frames(1)
		g += 1
		if not scene.talk.is_empty():
			if lineup.is_empty():
				lineup = _tiles(scene)
				line_worst = _worst(scene)
				await _snap("hall_lineup_four")
			if g % 6 == 0:
				scene.talk.pop_front()
	var after_want: Array = scene.trail_tiles(String(scene.team[0]["facing"]))
	_ok("Runners scene with four: the line-up %s is one row, leader and partner in the middle (worst cover %.2f)" % [str(lineup), line_worst], lineup == GuildScene.LINE and line_worst <= 0.25)
	_ok("Runners scene with four: after it the others stand behind the leader %s (the arrival rule gives %s)%s" % [str(_tiles(scene)), str(after_want), "" if _heap(scene) == "" else "; " + _heap(scene)],
		not scene.cutscene and _heap(scene) == "" and _tiles(scene) == after_want)
	await _free(scene)


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


## Placeholder factory lane R (Claude, 2026-10-26): the rooms' art through their slots. Every row of
## scripts/art/slots/town_rooms.gd resolves from the source its status expects (the 53 keep rows from today's files, the
## four props drawn at another size from today's resize, the new rooms' strips and furniture from their placeholders,
## everything from its placeholder when forcing); every prop, strip and piece of furniture is exactly its slot's size
## where the rooms draw it; Codex's four unused fixtures stay off, the code drawing on screen; no room script holds a
## world art path of its own; and the Item Shop's room and the Scroll Keeper's cellar build, their furniture solid and
## lifted, while Highbank keeps both doors shut.
func _slots() -> void:
	var Slots: GDScript = load("res://scripts/town/room_slots.gd")
	var Floors: GDScript = load("res://scripts/town/hall_floors_art.gd")
	var HallArt: GDScript = load("res://scripts/town/hall_room_art.gd")
	var Fixtures: GDScript = load("res://scripts/town/hall_fixtures_art.gd")
	var Painter: GDScript = load("res://scripts/town/room_painter.gd")
	var forced := ArtSlots.forcing()
	var drawn: Dictionary = Slots.get_script_constant_map()["DRAWN"]
	# 1. Sources.
	var rows := 0
	var keep := 0
	var wrong: Array = []
	for id in ArtSlots.ids():
		var s := ArtSlots.spec(id)
		if String(s.get("lane", "")) != "R":
			continue
		rows += 1
		if String(s["status"]) == "keep":
			keep += 1
		var want := "placeholder"
		if not forced:
			if FileAccess.file_exists(String(s.get("file", ""))):
				want = "file"
			elif drawn.has(id):
				want = "drawn"
			elif String(s["status"]) == "keep":
				want = "legacy"
		var got := String(Slots.call("source", id))
		var img: Image = Slots.call("image", id)
		if got != want or img.get_size() != Vector2i(s["sheet_size"]):
			wrong.append("%s %s (want %s) %s" % [id, got, want, str(img.get_size())])
	_ok("Room slots: %d rows, %d keep, every one from the source it should be%s%s" % [rows, keep, " (forcing placeholders)" if forced else "", "" if wrong.is_empty() else "; " + ", ".join(wrong)],
		wrong.is_empty() and rows == 71 and keep == 53)
	# 2. Sizes where the rooms draw them.
	var misfit: Array = []
	var props: Dictionary = Floors.get_script_constant_map()["PROPS"]
	for room in props:
		for p in props[room]:
			var slot := String(Floors.call("slot_id", room, p[0]))
			if ArtSlots.sheet_size(slot) != (p[1] as Rect2i).size:
				misfit.append("%s %s %s" % [room, slot, str((p[1] as Rect2i).size)])
		if room != "hall":
			for b in Floors.call("_bands", room):
				if ArtSlots.sheet_size(String(b[2])) != (b[1] as Rect2i).size:
					misfit.append("%s %s" % [room, b[2]])
	for p in HallArt.get_script_constant_map()["PROPS"]:
		if ArtSlots.sheet_size("town.prop.hall." + String(p[0])) != (p[1] as Rect2i).size:
			misfit.append("hall " + String(p[0]))
	var furniture: Dictionary = Painter.get_script_constant_map()["FURNITURE"]
	for room in furniture:
		var r: Dictionary = Room.ROOMS[room]
		var cut: Dictionary = Painter.call("_strips", Vector2i(r["w"], r["h"]) * 24)
		for part in cut:
			if ArtSlots.sheet_size("town.room.%s.%s" % [room, part]) != (cut[part] as Rect2i).size:
				misfit.append("%s strip %s" % [room, part])
		for f in Painter.call("furniture", room):
			var at: Rect2i = f[0]
			var foot := Vector2i(at.get_center().x / 24, (at.end.y - 1) / 24)
			if not r["solid"].any(func(sr: Rect2i) -> bool: return sr.has_point(foot)):
				misfit.append("%s furniture at %s stands on no solid tile" % [room, str(at)])
	_ok("Room slots: every prop, strip and piece of furniture is its slot's size where the rooms draw it%s" % ("" if misfit.is_empty() else "; " + ", ".join(misfit)), misfit.is_empty())
	# 3. Codex's four unused fixtures stay off (call 8 wires them behind SHOW_CODEX; Preston's edge-on doors stay).
	var show: Dictionary = Fixtures.get_script_constant_map()["SHOW_CODEX"]
	var lit: Array = show.keys().filter(func(n: String) -> bool: return bool(Fixtures.call("live", n)) or bool(show[n]))
	_ok("Codex's stairs, side door and hatch: wired, off, today's code drawing on screen (%d of %d live)" % [lit.size(), show.size()], lit.is_empty() and show.size() == 4)
	# 4. No room script keeps a world art path of its own: every picture comes through a slot.
	var held: Array = []
	for f in ["town_room", "room_painter", "hall_floors_art", "hall_fixtures_art", "hall_room_art", "home_room_art", "storage_room_art"]:
		if FileAccess.get_file_as_string("res://scripts/town/%s.gd" % f).contains("res://assets/sprites/world/"):
			held.append(f)
	_ok("Room scripts read their art through slots, no world art path left in them%s" % ("" if held.is_empty() else ": " + ", ".join(held)), held.is_empty())
	# 5. The shut rooms build; Highbank keeps their doors shut.
	var built: Array = []
	for id in ["shop", "scrolls_cellar"]:
		var r := await _room(id)
		var closed: bool = r.room()["solid"].all(func(sr: Rect2i) -> bool:
			for y in range(sr.position.y, sr.end.y):
				for x in range(sr.position.x, sr.end.x):
					if r._open(Vector2i(x, y)):
						return false
			return true)
		var bad := _heap(r)
		await _snap(id)
		if bad != "" or not closed or r.lifts.size() != 3:
			built.append("%s: %s, solid %s, %d lifted" % [id, bad, closed, r.lifts.size()])
		await _free(r)
	var shut: Dictionary = load("res://scripts/town/hub_town.gd").get_script_constant_map()["SHUT"]
	_ok("Item Shop and Scroll Keeper's cellar: each builds with its team on open tiles and its 3 pieces solid and lifted; Highbank keeps both doors shut (%s)%s" % [shut.has("shop") and shut.has("scrolls"), "" if built.is_empty() else "; " + ", ".join(built)],
		built.is_empty() and shut.has("shop") and shut.has("scrolls"))
