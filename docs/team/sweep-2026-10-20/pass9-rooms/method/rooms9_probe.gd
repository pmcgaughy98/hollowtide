extends "res://docs/team/sweep-2026-10-20/pass9-audit/method/audit9_probe.gd"
## Pass 9 rooms lane probe (Claude, 2026-10-27, scratch). Extends the pass 9 audit probe (its walker keeps off stairs and
## doors unless they are the target, its timed presses and its TEAM lines). Phases:
##   rooms9  v1 Highbank on a save: straight into the Wayline Tower (the warm-up may still run), its rooms' build times
##           (ready_ms), down the stairs and back up, a word with Grubbit from beside him (each line shot), out, then
##           the Storage and the Home for their key strips. Every room change logs its worst frame and its build steps.
##   late9   the same Hall door and stairs after 25 s in the street (the warm-up done).
## Same flags as the parent (--phase, --save, --out).

var worst_ms := 0
var _last_w := 0


const TownRoom9 := preload("res://scripts/town/town_room.gd")


func _run() -> void:
	if not phase in ["rooms9", "late9", "cold9"]:
		await super._run()
		return
	prefix = {"rooms9": "R", "late9": "L", "cold9": "K"}[phase]
	L("phase %s, %s, window %s, out %s" % [phase, "pad" if pad_mode else "keyboard", str(root.size), OUT])
	L("CLOCK %s, max fps %d" % ["real time" if real_time else "fixed (--fixed-fps)", Engine.max_fps])
	use_save()
	await phase_rooms(phase != "rooms9", phase == "cold9")
	L("DONE phase %s in %.1f s game, %.1f s wall" % [phase, frame / 30.0, Time.get_ticks_msec() / 1000.0])
	quit(0)


## Frames from now until `done` and 20 more: the worst one, and the new room's build steps.
func through_change(label: String, done: Callable, budget := 30 * 8) -> void:
	var w0 := Time.get_ticks_msec()
	var last := w0
	var worst := 0
	var times: Array = []
	var got := false
	var after := 0
	for k in budget:
		await F()
		var now := Time.get_ticks_msec()
		worst = maxi(worst, now - last)
		times.append(now - last)
		last = now
		if not got and done.call():
			got = true
		elif got:
			after += 1
			if after >= 20:
				break
	L("CHANGE %s: reached %s in %d ms, worst frame %d ms, frames %s" % [label, str(got), Time.get_ticks_msec() - w0, worst, str(times.slice(0, 40))])
	var s := current_scene
	if s != null and "ready_ms" in s:
		L("READY %s %s" % [label, str(s.ready_ms)])


func _in_room(id: String) -> bool:
	return _scene() == "town_room.tscn" and current_scene.room_id == id and current_scene.is_node_ready() \
		and not current_scene.team.is_empty() and current_scene.get("curtain") == null


func phase_rooms(late: bool, cold := false) -> void:
	await title_continue()
	var town := await wait_town()
	if town == null:
		L("no town")
		return
	mark("highbank arrival")
	if late:
		await F(30 * 25)
		L("WAITED 25 s in the street")
	if cold:   # the state a player meets walking in before the street's warm-up reached the rooms
		L("COLD: kept pictures %s, shapes %s, desk %s; cleared" % [str(TownRoom9._pictures.keys()), str(TownRoom9._lift_shapes.keys()), str(not TownRoom9._desk_art.is_empty())])
		TownRoom9._pictures.clear()
		TownRoom9._lift_shapes.clear()
		TownRoom9._desk_art = []
	# the Hall's door
	await walk_to(Vector2i(24, 6))
	await face(Vector2i(0, -1))
	var ev := _bind(&"interact", pad_mode)
	action = "hall door"
	_send(ev, true)
	await F(3)
	_send(ev, false)
	await through_change("hall door", func() -> bool: return _in_room("hall"))
	await F(20)
	await snap("hall")
	await _read_scenes()
	if not _in_room("hall"):
		L("NOT IN THE HALL")
		return
	L("HALL npcs " + str(current_scene.npcs.map(func(n: Dictionary) -> String: return "%s@%s" % [str(n.get("form", "")), str(n["pos"])])))
	# down the stairs: walk onto the link
	L("PAINT before the stairs: painting %s, kept hall_low %s" % [str(TownRoom9._painting.keys()), str(TownRoom9._pictures.has("hall_low"))])
	if OS.get_environment("P9_WAIT") == "1":
		var w := Time.get_ticks_msec()
		var k := 0
		while TownRoom9.painting() and k < 300:
			await F()
			k += 1
		L("PAINT AHEAD done after %d frames, %d ms; kept hall_low %s" % [k, Time.get_ticks_msec() - w, str(TownRoom9._pictures.has("hall_low"))])
		await F(10)
	action = "stairs down"
	await walk_to(Vector2i(14, 11))
	L("PAINT at the stairs: painting %s, kept hall_low %s" % [str(TownRoom9._painting.keys()), str(TownRoom9._pictures.has("hall_low"))])
	await through_change("stairs down", func() -> bool: return _in_room("hall_low"))
	await F(10)
	await snap("hall_low")
	var guard := 0
	while _scene() == "town_room.tscn" and current_scene.cutscene and guard < 40:   # the whole mail call, line by line
		await read_all()
		await F(10)
		guard += 1
	await snap("hall_low_after_call")
	# back up: the link at (25, 13)
	action = "stairs up"
	await walk_to(Vector2i(25, 13))
	await through_change("stairs up", func() -> bool: return _in_room("hall"))
	await F(20)
	await snap("hall_again")
	# a word with Grubbit, from beside him
	var mole: Dictionary = {}
	for n in current_scene.npcs:
		if String(n.get("form", "")) == "grubbit":
			mole = n
	if mole.is_empty():
		L("MOLE not in the Hall")
	else:
		L("MOLE at %s" % str(mole["pos"]))
		for off in [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, -1)]:
			var t: Vector2i = mole["pos"] + off
			if _walkable(t) and await walk_to(t):
				await face(-off)
				await snap("mole_before")
				await press(&"interact")
				await F(25)
				L("TALK BOX %s, leader %s, mole %s" % [str(current_scene.talk_box), str(current_scene.screen_box(current_scene.team[0])), str(current_scene.screen_box(mole))])
				await snap("mole_talk")
				var k := 0
				while _talking() and k < 8:
					await read_line()
					await F(8)
					await snap("mole_line%d" % k)
					k += 1
				break
	# out of the door
	action = "hall out"
	await walk_to(current_scene.room()["door"])
	await wait_town()
	await F(10)
	# Storage and Home: the key strips (R3)
	await walk_to(Vector2i(40, 7))
	await face(Vector2i(0, -1))
	action = "storage door"
	await press(&"interact")
	await through_change("storage door", func() -> bool: return _in_room("storage"))
	await F(30)
	await snap("storage_strip")
	if _scene() == "town_room.tscn":
		await walk_to(current_scene.room()["door"])
		await wait_town()
	await walk_to(Vector2i(5, 7))
	await face(Vector2i(0, -1))
	action = "home door"
	await press(&"interact")
	await through_change("home door", func() -> bool: return _in_room("home"))
	await F(30)
	await snap("home_strip")
	if _scene() == "town_room.tscn":
		await walk_to(current_scene.room()["door"])
		await wait_town()
	await snap("street_end")
