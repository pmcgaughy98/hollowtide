extends SceneTree
## The first dungeon's river-bank look in play (Claude, 2026-10-10). Windowed only.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/bank_floor_capture.gd

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.dungeon = "first"
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0], [10, 0]]
	root.add_child(dg)
	for k in 40:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://docs/design/rival-crew-2026-10-10/first_dungeon_bank.png"))
	print("saved")
	quit()
