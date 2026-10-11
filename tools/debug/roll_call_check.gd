extends SceneTree
## The Wayline Hall crew and the morning roll call (Claude, 2026-10-11; scripts/town/guild_crew.gd). Checks:
##   1. on the lower floor, once the guild has taken the team on, the roll call plays: Wayling calls everyone,
##      Muskin comes in late, Starward gives the word of the day, and the crew go back to their posts;
##   2. it does not play again until the team has been on another run;
##   3. a crew member at their post talks when spoken to, and stands solid;
##   4. upstairs, Wayling and Grubbit are at their posts.
## Windowed it saves stills to docs/design/roll-call-2026-10-11/.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/roll_call_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const OUT := "res://docs/design/roll-call-2026-10-11/"
const REC_PACE := 3   # with HT_RECORD set (video takes), each line stays this many times longer
var _pace := REC_PACE if OS.get_environment("HT_RECORD") != "" else 1
var fails := 0
var shot := {}


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _snap(name: String) -> void:
	if shot.has(name) or DisplayServer.get_name() == "headless":
		return
	shot[name] = true
	UI.finish_line()
	for k in 3:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


func _room(id: String, scenes: bool) -> Node2D:
	var r: Node2D = load("res://scenes/town_room.tscn").instantiate()
	r.room_id = id
	r.poll_input = false
	r.force_scenes = scenes
	root.add_child(r)
	for k in 4:
		await process_frame
	return r


func _forms(r: Node2D) -> Array:
	var out: Array = r.npcs.map(func(e: Dictionary) -> String: return e["form"])
	out.sort()
	return out


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["story"] = {"met_crew": true, "parcel": "stolen", "guild_trial": true}
	# 1. The roll call.
	var low := await _room("hall_low", true)
	var guard := 0
	var said := []
	while (low.cutscene or guard < 8) and guard < 30 * 90:
		await process_frame
		guard += 1
		if not low.talk.is_empty() and guard % (18 * _pace) == 0:
			var who := String(low.talk[0][0])
			said.append(who)
			if who == "Muskin" and not shot.has("2_late"):
				await _snap("2_late")
			if who == "Starward" and not shot.has("3_word"):
				await _snap("3_word")
			if said.size() == 2:
				await _snap("1_line_up")
			if said.size() == 12 and not shot.has("team_at_mark"):
				shot["team_at_mark"] = true
				var at: Array = low.team.map(func(e: Dictionary) -> Vector2i: return e["pos"])
				_ok("The team stands at the mark for the roll (%s)" % str(at), at[0] == Vector2i(14, 10))
			low.talk.pop_front()
	_ok("The roll call plays: %d lines, Wayling %s, Muskin %s, Starward %s" % [said.size(), said.has("Wayling"), said.has("Muskin"), said.has("Starward")],
		said.size() >= 15 and said.has("Wayling") and said.has("Muskin") and said.has("Starward"))
	await process_frame
	var posts: Array = _forms(low)
	_ok("After: the crew at their posts %s, the scene over (%s)" % [str(posts), not low.cutscene], posts == ["muskin", "rinsepaw", "slipjaw", "stillwade", "wickglow"] and not low.cutscene)
	await _snap("4_after")
	_ok("It is marked done for this run (%s)" % TeamState.data.get("rollcall_runs", -1), int(TeamState.data.get("rollcall_runs", -1)) == 0)
	# 3. Talk to Stillwade at the window.
	low.team[0]["pos"] = Vector2i(4, 4)
	low.team[0]["facing"] = "n"
	low._place(low.team[0])
	low.act_use()
	await process_frame
	_ok("Stillwade talks at its post (%s)" % (low.talk[0][0] if not low.talk.is_empty() else "nothing"), not low.talk.is_empty() and low.talk[0][0] == "Stillwade")
	await _snap("5_stillwade")
	low.talk.clear()
	for k in 3:
		await process_frame
	low.team[0]["pos"] = Vector2i(4, 4)
	low._place(low.team[0])
	low.act_move(Vector2i(0, -1))
	await process_frame
	_ok("Stillwade stands solid (leader still at %s)" % low.team[0]["pos"], low.team[0]["pos"] == Vector2i(4, 4))
	low.queue_free()
	for k in 2:
		await process_frame
	# 2. Not again until another run.
	var again := await _room("hall_low", true)
	_ok("Next visit: no roll call (%s), crew at posts %s" % [not again.cutscene, str(_forms(again))], not again.cutscene and _forms(again).size() == 5)
	again.queue_free()
	for k in 2:
		await process_frame
	TeamState.data["cleared"] = 1
	var after_run := await _room("hall_low", true)
	_ok("After another run it plays again (%s)" % after_run.cutscene, after_run.cutscene)
	var g2 := 0
	while after_run.cutscene and g2 < 30 * 90:   # let it finish before the room closes
		await process_frame
		g2 += 1
		if not after_run.talk.is_empty() and g2 % 6 == 0:
			after_run.talk.pop_front()
	after_run.queue_free()
	for k in 2:
		await process_frame
	# 4. Upstairs.
	var up := await _room("hall", false)
	_ok("Upstairs: %s at their posts" % str(_forms(up)), _forms(up) == ["grubbit", "wayling"])
	await _snap("6_upstairs")
	up.queue_free()
	print("ROLL CALL: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
