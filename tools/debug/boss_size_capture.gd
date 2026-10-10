extends SceneTree
## A still of the boss floor (Claude, 2026-10-10): the Warden in its boss set, the Listeners in their
## escort set, the team at normal size. Windowed only.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/boss_size_capture.gd

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 7
	dg.poll_input = false
	dg.dungeon = "hollow"   # the Warden is the Hollow's boss (2026-10-10)
	dg.party = [[0, 1], [1, 0], [10, 0]]
	root.add_child(dg)
	for k in 10:
		await process_frame
	dg.floor_n = dg.floors() + 1
	dg._build_floor(true)
	for k in 6:
		await process_frame
		if not dg.talk.is_empty():
			dg.act_talk()
	var b: Dictionary = dg.ents[dg.boss]
	# Walk the leader up toward the Warden so the camera frames it, then let the banner fade.
	var lead: Dictionary = dg.ents[0]
	lead["pos"] = b["pos"] + Vector2i(3, 1)
	dg._place(lead)
	for k in 150:
		await process_frame
	print("boss %s set size %s; escort %s" % [b["name"], str(b["art"]["still"]["s"].get_size()), str(dg.ents[dg.boss + 1]["art"]["still"]["s"].get_size())])
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://docs/design/dungeon-vfx-2026-10-10/boss_size.png"))
	quit()
