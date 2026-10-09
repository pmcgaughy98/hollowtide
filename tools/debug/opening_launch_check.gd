extends SceneTree
const OUTPUT := "D:/dev/hollowtide-opening-20261008/review/"

func _initialize() -> void:
	_run()

func _run() -> void:
	root.content_scale_size = Vector2i(1152,648)
	root.size = Vector2i(960,720)
	var reduced := OS.get_cmdline_user_args().has("reduced")
	var config := ConfigFile.new()
	config.load("user://menu_preferences.cfg")
	config.set_value("menu","reduce_motion",reduced)
	config.save("user://menu_preferences.cfg")
	var menu: Node2D = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	root.add_child.call_deferred(menu)
	for i in 180: await process_frame
	var results := {
		"automatic_menu_reveal":menu._boot_done and menu._page == "main",
		"saved_reduce_motion":menu._reduce_motion == reduced,
		"fixed_menu_composition":root.content_scale_aspect == Window.CONTENT_SCALE_ASPECT_KEEP,
		"single_menu_music_player":menu._music.playing,
	}
	await RenderingServer.frame_post_draw
	var tag := "launch-reduced" if reduced else "launch-automatic"
	root.get_texture().get_image().save_png(OUTPUT + tag + ".png")
	var output := FileAccess.open(OUTPUT+tag+"-checks.json",FileAccess.WRITE)
	output.store_string(JSON.stringify(results,"  "))
	var passed := true
	for key in results:
		print(key, ": ", results[key])
		passed = passed and results[key]
	menu.queue_free()
	await process_frame
	quit(0 if passed else 1)
