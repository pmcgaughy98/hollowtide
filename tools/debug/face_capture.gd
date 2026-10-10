extends SceneTree
## A boss scene line with an expression portrait (Claude, 2026-10-10): Kithflare as the partner on the
## crew's boss floor; its first line is the angry face. Windowed only.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/face_capture.gd

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.dungeon = "first"
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[1, 0], [0, 0]]
	root.add_child(dg)
	for k in 10:
		await process_frame
	dg.floor_n = dg.floors() + 1
	dg._build_floor(true)
	for k in 30:
		await process_frame
	print("line: ", dg.talk[0])
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://docs/ui/expressions-2026-10-10/in_game_angry.png"))
	quit()
