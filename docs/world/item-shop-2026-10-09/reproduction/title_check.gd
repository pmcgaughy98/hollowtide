extends SceneTree
const OUT = "D:/dev/hollowtide-shop-20261009/review/"
func _initialize() -> void:
	_run.call_deferred()
func frames(n: int) -> void:
	for k in n: await process_frame
func _run() -> void:
	var menu = load("res://scenes/creature_opening.tscn").instantiate()
	root.add_child(menu); current_scene = menu
	await frames(5)
	root.get_texture().get_image().save_png(OUT + "title_boot.png")
	await frames(75)
	root.get_texture().get_image().save_png(OUT + "title_without_creatures.png")
	var actors = 0
	for n in menu.get_children():
		if n.get_script() and n.get_script().resource_path.ends_with("village_menu_actor.gd"): actors += 1
		if str(n.name).ends_with("VillageShadow"): actors += 1
	var title_ok = menu._boot_done and menu._page == "main" and menu._wordmark.visible and menu._buttons[0].visible and actors == 0
	var music_ok = menu._music.stream.resource_path == "res://assets/audio/music/title.mp3"
	menu._buttons[0].emit_signal("pressed")
	await frames(40)
	var flow_ok = is_instance_valid(current_scene) and current_scene.get_script().resource_path == "res://scripts/creature_prologue.gd"
	print("TITLE_RESULT foreground_actors_and_shadows=",actors," title_ready=",title_ok," new_game_opens_prologue=",flow_ok," claude_title_theme=",music_ok)
	quit(0 if title_ok and flow_ok and music_ok else 1)
