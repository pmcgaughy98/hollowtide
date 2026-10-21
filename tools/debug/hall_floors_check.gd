extends SceneTree
## The Wayline Hall on two floors (Claude, 2026-10-10; Preston: "need more space, should be like the guild
## hall in Sky", two floors chosen). Checks:
##   1. the work floor's stairs take the team down to the lower floor, landing beside the stairs up;
##   2. the lower floor's back door opens Starward's chamber, and its stairs lead back up;
##   3. in the chamber, once the trial is set, Starward is there and talks (the team cannot walk through);
##   4. the chamber's door leads back down.
## Windowed it saves each room whole and a still from inside each, to docs/design/hall-floors-2026-10-10/.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/hall_floors_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const Room := preload("res://scripts/town/town_room.gd")
const OUT := "res://docs/design/hall-floors-2026-10-10/"
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _snap(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _open_room(id: String, at := Vector2i(-1, -1), facing := "s") -> Node2D:
	var r: Node2D = load("res://scenes/town_room.tscn").instantiate()
	r.room_id = id
	r.arrive = at
	r.arrive_facing = facing
	r.poll_input = false
	root.add_child(r)
	await _frames(4)
	return r


## Put the leader at `from` and step it `d`; returns the link it walked onto, or {}.
func _step(r: Node2D, from: Vector2i, d: Vector2i) -> Dictionary:
	r.team[0]["pos"] = from
	r._place(r.team[0])
	r.act_move(d)
	while r.busy:   # a step takes STEP_TIME of real time; a frame count alone is too short when frames run fast
		await process_frame
	await _frames(2)
	return r.get_meta("went", {})


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["story"] = {"met_crew": true, "parcel": "stolen", "guild_trial": true}
	if DisplayServer.get_name() != "headless":
		for id in ["hall", "hall_low", "chamber", "runners"]:   # each room whole, as painted
			preload("res://scripts/town/room_painter.gd").paint(id, Room.ROOMS[id]).save_png(ProjectSettings.globalize_path(OUT + "whole_" + id + ".png"))

	# 1. Down the stairs.
	var up := await _open_room("hall")
	var went := await _step(up, Vector2i(14, 9), Vector2i(0, 1))
	_ok("Work floor: the stairs lead down (%s)" % went.get("to", "nowhere"), went.get("to", "") == "hall_low")
	up.queue_free()
	await _frames(2)
	var low := await _open_room("hall_low", went.get("at", Vector2i(24, 14)), went.get("facing", "w"))
	var landed: Vector2i = low.team[0]["pos"]
	var apart: bool = low.team.size() < 2 or low.team[1]["pos"] != landed
	_ok("Lower floor: the team lands at %s, side by side (%s), off the stairs" % [landed, apart], landed == Vector2i(24, 14) and apart and low._link_at(landed).is_empty())
	await _frames(4)
	await _snap("1_lower_landing")
	low.team[0]["pos"] = Vector2i(15, 10)
	low._place(low.team[0])
	await _frames(4)
	await _snap("2_lower_rollcall")
	var spot: Dictionary = low.act_use()
	_ok("The roll-call floor answers E (%s)" % spot.get("name", "nothing"), spot.get("id", "") == "rollcall")
	low.panel = {}

	# The runners' room: locked until Starward names them runners, then theirs.
	var locked: Dictionary = await _step(low, Vector2i(28, 6), Vector2i(1, 0))
	_ok("Lower floor: the runners' room is locked before they are runners (%s)" % locked.is_empty(), locked.is_empty())
	TeamState.data["story"]["runner"] = true
	var low2 := await _open_room("hall_low", Vector2i(24, 14), "w")
	low.queue_free()
	low = low2
	var rr: Dictionary = await _step(low, Vector2i(28, 6), Vector2i(1, 0))
	_ok("Lower floor: once runners, the door opens their room (%s)" % rr.get("to", "nowhere"), rr.get("to", "") == "runners")
	low.remove_meta("went")
	var rroom := await _open_room("runners", rr.get("at", Vector2i(1, 5)), "e")
	rroom.team[0]["pos"] = Vector2i(4, 4)
	rroom.team[0]["facing"] = "n"
	rroom._place(rroom.team[0])
	var bunk: Dictionary = rroom.act_use()
	_ok("Runners' room: the bunk answers E (%s)" % bunk.get("name", "nothing"), bunk.get("id", "") == "bed")
	rroom.panel = {}
	rroom.team[0]["pos"] = Vector2i(5, 6)
	rroom._place(rroom.team[0])
	await _frames(4)
	await _snap("4_runners_room")
	var out: Dictionary = await _step(rroom, Vector2i(1, 6), Vector2i(-1, 0))
	_ok("Runners' room: the door leads back to the Hall floor (%s)" % out.get("to", "nowhere"), out.get("to", "") == "hall_low")
	rroom.queue_free()
	TeamState.data["story"].erase("runner")

	# 2. Into the chamber, and the stairs back up.
	went = await _step(low, Vector2i(14, 2), Vector2i(0, -1))
	_ok("Lower floor: the back door opens the chamber (%s)" % went.get("to", "nowhere"), went.get("to", "") == "chamber")
	low.remove_meta("went")
	var back := await _step(low, Vector2i(24, 14), Vector2i(1, 0))
	_ok("Lower floor: the stairs lead back up (%s)" % back.get("to", "nowhere"), back.get("to", "") == "hall")
	low.queue_free()
	await _frames(2)

	# 3. Starward in the chamber.
	var ch := await _open_room("chamber", went.get("at", Vector2i(8, 8)), "n")
	var star: Array = ch.npcs.filter(func(e: Dictionary) -> bool: return e["form"] == "starward")
	_ok("Chamber: Starward is there (%d)" % star.size(), star.size() == 1)
	ch.team[0]["pos"] = Vector2i(8, 5)
	ch.team[0]["facing"] = "n"
	ch._place(ch.team[0])
	var blocked: bool = not ch._open(Vector2i(8, 4)) and not ch._open(Vector2i(8, 3))
	ch.act_use()
	await _frames(3)
	_ok("Chamber: Starward stands solid (%s) and talks (%s)" % [blocked, ch.talk.size()], blocked and ch.cutscene and not ch.talk.is_empty())
	await _frames(20)
	preload("res://scripts/ui/ui_style.gd").finish_line()
	await _frames(2)
	await _snap("3_chamber_talk")
	ch.talk.clear()
	await _frames(3)
	_ok("Chamber: the talk ends (%s)" % (not ch.cutscene), not ch.cutscene)

	# 4. The door back down.
	went = await _step(ch, Vector2i(8, 9), Vector2i(0, 1))
	_ok("Chamber: the door leads back down (%s)" % went.get("to", "nowhere"), went.get("to", "") == "hall_low")
	ch.queue_free()
	print("HALL FLOORS: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
