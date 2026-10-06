extends SceneTree
## Menu capture (needs a window). Usage:
##   Godot.exe --path . --script res://tools/debug/menu_capture.gd -- <ms,ms,...> <name>
## Opens the Courier Lookout menu and saves a screenshot at each millisecond
## mark to user://menu_captures/<name>_<ms>.png.
var OUT := ProjectSettings.globalize_path("user://menu_captures/")
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	_run()
func _run() -> void:
	var a := OS.get_cmdline_user_args()
	var shots: Array = Array(a[0].split(",")).map(func(x): return int(x))
	var menu: Node = load("res://scenes/main_menu_art_preview.tscn").instantiate()
	root.add_child(menu)
	var t0 := Time.get_ticks_msec()
	while not shots.is_empty():
		await process_frame
		if Time.get_ticks_msec() - t0 >= shots[0]:
			var n: int = shots.pop_front()
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OUT + "%s_%05d.png" % [a[1], n])
	quit()
