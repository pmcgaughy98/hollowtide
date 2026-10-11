extends SceneTree
## The guild morning in Wayline Hall (Claude, 2026-10-10), built on scripts/town/scene_kit.gd: on the first
## visit Starward and Wayling are in the Hall; the scene plays (the team walks up, Wayling calls the line-up,
## Starward comes round the counter, grants the trial, Wayling hands over the parcel); afterwards the story
## records the trial and the parcel, the two are back at their posts, and the scene does not play again.
## Windowed it saves a still at each line.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/guild_scene_check.gd
## With --write-movie docs/design/guild-morning-2026-10-10/raw.avi it also records the scene.

const TeamState := preload("res://scripts/town/team_state.gd")
const OUT := "res://docs/design/guild-morning-2026-10-10/"
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
	await process_frame   # the new line is drawn once, then shown whole for the still
	preload("res://scripts/ui/ui_style.gd").finish_line()   # stills show the whole line, not its first letters
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["story"] = {"met_crew": true, "parcel": "stolen"}   # the story now: the crew took the parcel at the board
	var room: Node2D = load("res://scenes/town_room.tscn").instantiate()
	room.room_id = "hall"
	room.poll_input = false
	room.force_scenes = true
	root.add_child(room)
	for k in 4:
		await process_frame
	_ok("First visit: Starward and Wayling in the Hall (%d)" % room.npcs.size(), room.npcs.size() == 2)
	var frames := 0
	var read := 0
	var n := 0
	var parcel_seen := false
	while (room.cutscene or frames < 10) and frames < 30 * 120:
		await process_frame
		frames += 1
		parcel_seen = parcel_seen or room.scene_fx.has("parcel")
		if not room.talk.is_empty():
			await _snap("%02d_%s" % [n, String(room.talk[0][0]).to_lower()])
			read += 1
			if read >= 45 * _pace:
				read = 0
				n += 1
				room.talk.pop_front()
	await _snap("99_after")
	var story: Dictionary = TeamState.data.get("story", {})
	var star: Dictionary = room.npcs.filter(func(e: Dictionary) -> bool: return e["form"] == "starward")[0]
	_ok("After: %d lines, trial %s, parcel %s (handed over %s), Starward back behind the counter %s, scene over %s" % [n, story.get("guild_trial", false), story.get("parcel", ""), parcel_seen, star["pos"] == Vector2i(11, 2), not room.cutscene],
		n >= 10 and story.get("guild_trial", false) and story.get("parcel", "") == "stolen" and not parcel_seen and star["pos"] == Vector2i(11, 2) and not room.cutscene)
	room.queue_free()
	for k in 2:
		await process_frame
	var again: Node2D = load("res://scenes/town_room.tscn").instantiate()
	again.room_id = "hall"
	again.poll_input = false
	again.force_scenes = true
	root.add_child(again)
	for k in 6:
		await process_frame
	# Since 2026-10-11 the crew stand at their posts once the trial is set (scripts/town/guild_crew.gd); no guild scene.
	var forms: Array = again.npcs.map(func(e: Dictionary) -> String: return e["form"])
	_ok("Next visit: no scene (%s), only the crew at their posts %s" % [str(again.cutscene), str(forms)], not again.cutscene and not forms.has("starward"))
	again.queue_free()
	for k in 2:
		await process_frame
	# Back from Rootbank Warren with the parcel: Starward names them runners.
	TeamState.data["story"]["parcel"] = "recovered"
	var back: Node2D = load("res://scenes/town_room.tscn").instantiate()
	back.room_id = "hall"
	back.poll_input = false
	back.force_scenes = true
	root.add_child(back)
	for k in 6:
		await process_frame
	var started: bool = back.cutscene
	var said := 0
	var guard := 0
	while back.cutscene and guard < 30 * 60:
		await process_frame
		guard += 1
		if not back.talk.is_empty() and guard % (20 * _pace) == 0:
			if said == 4:
				await _snap("30_named")
			back.talk.pop_front()
			said += 1
	var st: Dictionary = TeamState.data.get("story", {})
	_ok("Back with the parcel: the scene plays (%s), %d lines, runners %s, parcel %s" % [started, said, st.get("runner", false), st.get("parcel", "")],
		started and said >= 7 and st.get("runner", false) and st.get("parcel", "") == "delivered")
	back.queue_free()
	print("GUILD SCENE: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit()
