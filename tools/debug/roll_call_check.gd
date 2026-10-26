extends SceneTree
## The Wayline Hall crew and the morning mail call (Claude, 2026-10-11; scripts/town/guild_crew.gd; rewritten as
## parcel sorting on 2026-10-12, R3 of the genre synthesis; the file keeps its old name). Checks:
##   1. on the lower floor, once the Wayline has taken the team on, the mail call plays: Wayling calls routes,
##      the crew claim them, Muskin comes in late, Starward gives the morning's note, and the crew go back to
##      their posts;
##   2. it plays once in each stage of the story (Claude, 2026-10-26, pass 8 R7 / L-09): not again on the next visit,
##      not after another run in the same stage, and once more when the story moves on (here: the team named runners);
##   3. a crew member at their post talks when spoken to, and stands solid;
##   4. upstairs, Wayling and Grubbit are at their posts.
##   5. with a team of four, Sparkwick in it, the others close up behind the leader after the call, each on its own
##      tile, off the crew and the furniture (pass 8 R1).
## Windowed it saves stills to docs/design/roll-call-2026-10-11/.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/roll_call_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const GuildCrew := preload("res://scripts/town/guild_crew.gd")
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
	TeamState.start([[0, 1], [1, 0], [10, 0], [2, 0]])   # a team of four, Sparkwick leading (pass 8)
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
	_ok("The mail call plays: %d lines, Wayling %s, Muskin %s, Starward %s, every crew member claims a route %s" % [said.size(), said.has("Wayling"), said.has("Muskin"), said.has("Starward"),
			["Grubbit", "Stillwade", "Wickglow", "Rinsepaw", "Slipjaw"].all(func(n: String) -> bool: return said.has(n))],
		said.size() >= 15 and said.has("Wayling") and said.has("Muskin") and said.has("Starward")
		and ["Grubbit", "Stillwade", "Wickglow", "Rinsepaw", "Slipjaw"].all(func(n: String) -> bool: return said.has(n)))
	await process_frame
	var posts: Array = _forms(low)
	_ok("After: the crew at their posts %s, the scene over (%s)" % [str(posts), not low.cutscene], posts == ["muskin", "rinsepaw", "slipjaw", "stillwade", "wickglow"] and not low.cutscene)
	await _snap("4_after")
	# Standing south at their posts, the crew keep their job objects: Codex's town/idle_s.png (task 2), wired in
	# scene_kit.spawn (2026-10-11). Slipjaw faces east and keeps the plain east still.
	var standing: Array = []
	for e in low.npcs:
		if String(e["facing"]) == "s":
			standing.append("%s:%s" % [e["form"], e["sprite"].texture.resource_path.get_file()])
	_ok("Crew standing south show their job-object stills %s" % str(standing),
		standing.size() == 4 and standing.all(func(s: String) -> bool: return s.ends_with(":idle_s.png")))
	var stage := GuildCrew.stage_of(TeamState.data)
	_ok("It is marked done for this stage of the story (%s)" % str(TeamState.data["story"].get("mail_call", "")), String(TeamState.data["story"].get("mail_call", "")) == stage)
	# 5. The team after the call: each on its own tile behind the leader, nobody on the crew, a wall or the furniture.
	var tiles: Array = low.team.map(func(e: Dictionary) -> Vector2i: return e["pos"])
	var want: Array = low.trail_tiles(String(low.team[0]["facing"]))
	var bad := ""
	var seen := {}
	for e in low.team:
		var t: Vector2i = e["pos"]
		if seen.has(t) or not low._open(t) or low.npcs.any(func(n: Dictionary) -> bool: return n["pos"] == t):
			bad = "%s at %s" % [e["form"], t]
		seen[t] = true
		if (e["node"] as Node2D).position.distance_to(low._px(t)) > 0.5:
			bad = "%s drawn off its tile %s" % [e["form"], t]
	_ok("After the call the team of four stands behind the leader %s (the arrival rule gives %s)%s" % [str(tiles), str(want), "" if bad == "" else "; wrong: " + bad], bad == "" and tiles == want)
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
	# 2. Once a stage (R7): not on the next visit, not after another run in the same stage, once more when the story
	# moves on, and then not again in that stage.
	var again := await _room("hall_low", true)
	_ok("Next visit: no mail call (%s), crew at posts %s" % [not again.cutscene, str(_forms(again))], not again.cutscene and _forms(again).size() == 5)
	again.queue_free()
	for k in 2:
		await process_frame
	TeamState.data["cleared"] = 1
	var same_stage := await _room("hall_low", true)
	_ok("After another run in the same stage: still no mail call (%s)" % [not same_stage.cutscene], not same_stage.cutscene)
	same_stage.queue_free()
	for k in 2:
		await process_frame
	TeamState.data["story"]["parcel"] = "delivered"
	TeamState.data["story"]["runner"] = true
	var plays := 0
	for visit in 2:
		var next_stage := await _room("hall_low", true)
		if next_stage.cutscene:
			plays += 1
		var g2 := 0
		while next_stage.cutscene and g2 < 30 * 90:   # let it finish before the room closes
			await process_frame
			g2 += 1
			if not next_stage.talk.is_empty() and g2 % 6 == 0:
				next_stage.talk.pop_front()
		next_stage.queue_free()
		for k in 2:
			await process_frame
	_ok("The story moves on (the team named runners): two visits, the mail call plays %d time(s)" % plays, plays == 1)
	# 4. Upstairs.
	var up := await _room("hall", false)
	_ok("Upstairs: %s at their posts" % str(_forms(up)), _forms(up) == ["grubbit", "wayling"])
	await _snap("6_upstairs")
	up.queue_free()
	print("MAIL CALL: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
