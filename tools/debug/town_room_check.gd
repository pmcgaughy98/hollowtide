extends SceneTree
## Rooms inside Highbank (Claude, 2026-10-10): the Home's door leads in; the team walks to the bed and
## uses it; the door leads back out to the Home's door; the Wayline Hall's counter answers. Windowed, it
## also saves stills of both rooms.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/town_room_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const OUT := "res://docs/world/highbank-rooms-2026-10-10/"
var fails := 0


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
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


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
		await room.act_move(step - room.team[0]["pos"])
		await _frames(1)


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
	# 2. Inside: walk to the bed and rest; then back out.
	var room: Node2D = load("res://scenes/town_room.tscn").instantiate()
	room.room_id = "home"
	room.poll_input = false
	root.add_child(room)
	await _frames(10)
	await _snap("home")
	await _walk(room, Vector2i(2, 4))
	room.team[0]["facing"] = "n"
	room.act_use()
	await _frames(6)
	await _snap("home_bed")
	_ok("Home: %dx%d tiles; the bed answers: %s" % [room.room()["w"], room.room()["h"], str(room.panel.get("name", ""))], room.panel.get("id", "") == "bed")
	room.act_use()
	await _walk(room, room.room()["door"])
	await _frames(2)
	_ok("Out of the door: left %s, back at %s" % [str(room.get_meta("left", false)), str(TeamState.data.get("arrive_at", ""))], room.get_meta("left", false) and TeamState.data.get("arrive_at", "") == "home")
	room.queue_free()
	await _frames(2)
	# 3. The Wayline Hall and its counter.
	var hall: Node2D = load("res://scenes/town_room.tscn").instantiate()
	hall.room_id = "hall"
	hall.poll_input = false
	root.add_child(hall)
	await _frames(10)
	await _snap("hall")
	await _walk(hall, Vector2i(11, 9))
	await _frames(4)
	await _snap("hall_middle")
	await _walk(hall, Vector2i(11, 5))   # the desk is solid on rows 3 and 4 since 2026-10-10
	hall.team[0]["facing"] = "n"
	hall.act_use()
	await _frames(6)
	await _snap("hall_counter")
	_ok("Hall: %dx%d tiles; the counter answers: %s" % [hall.room()["w"], hall.room()["h"], str(hall.panel.get("name", ""))], hall.panel.get("id", "") == "counter")
	hall.queue_free()
	print("ROOMS: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit()
