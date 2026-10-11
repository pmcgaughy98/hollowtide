extends SceneTree
## The Job Board meeting (Claude, 2026-10-10): on the first walk through Highbank the Shortcut Crew are at
## the board; walking up to it plays the scene (Gruntle shoves the partner down, the crew leave); after
## it, the story records the meeting, the partner is up, and the crew are not there next time.
## Windowed it saves a still at each beat.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/board_scene_check.gd
## With --write-movie docs/design/board-scene-2026-10-10/raw.avi it also records the scene.

const TeamState := preload("res://scripts/town/team_state.gd")
var OUT := "D:/dev/hollowtide-new-scene-selout-20261010/review/scene/"
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
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


func _run() -> void:
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"):OUT="D:/dev/hollowtide-new-scene-selout-20261010/review/live-board/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	TeamState.start([[0, 0], [1, 0]])
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	town.force_scenes = true
	root.add_child(town)
	for k in 6:
		await process_frame
	_ok("First visit: the crew at the board (%d)" % town.npcs.size(), town.npcs.size() == 3)
	# Walk up the street to the board from below.
	var door: Vector2i = town.BoardScene.board_door()
	town.team[0]["pos"] = door + Vector2i(0, 6)
	town.team[1]["pos"] = door + Vector2i(0, 7)
	for e in town.team:
		town._place(e)
	await _snap("00_crew_at_board")
	var steps := 0
	while not town.cutscene and steps < 8:
		await town.act_move(Vector2i(0, -1))
		steps += 1
	_ok("Walking up: the scene started after %d steps" % steps, town.cutscene)
	var frames := 0
	var read := 0
	var n := 0
	var partner: Dictionary = town.team[1]
	var was_down := false
	while town.cutscene and frames < 30 * 90:
		await process_frame
		frames += 1
		was_down = was_down or partner.get("down", false)
		if partner.get("down", false):
			await _snap("03_shoved")
		if not town.talk.is_empty():
			await _snap("%02d_%s" % [10 + n, String(town.talk[0][0]).to_lower()])
			read += 1
			if read >= 45:
				read = 0
				n += 1
				town.talk.pop_front()
	await _snap("20_after")
	var met: bool = TeamState.data.get("story", {}).get("met_crew", false)
	_ok("After: met %s, partner knocked down %s and up again %s, crew gone %s, scene over %s" % [met, was_down, not partner.get("down", false), town.npcs.is_empty(), not town.cutscene],
		met and was_down and not partner.get("down", false) and town.npcs.is_empty() and not town.cutscene)
	town.queue_free()
	for k in 2:
		await process_frame
	var again: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	again.poll_input = false
	root.add_child(again)
	for k in 4:
		await process_frame
	_ok("Next visit: no crew at the board (%d)" % again.npcs.size(), again.npcs.is_empty())
	again.queue_free()
	print("BOARD SCENE: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	for child in root.get_children(): child.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	for k in 12: await process_frame
	quit(0 if fails==0 else 1)
