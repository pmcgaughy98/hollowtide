extends SceneTree
const W := "D:/dev/hollowtide-town-selout-20261010/"
const TeamState := preload("res://scripts/town/team_state.gd")
const Layout := preload("res://scripts/town/town_layout.gd")
const Finish := preload("res://scripts/arena/creature_finish.gd")
var tag := "before"
func _initialize() -> void: _run.call_deferred()
func frames(n: int) -> void:
	for k in n: await process_frame
func _run() -> void:
	if FileAccess.file_exists(W + "after.flag"): tag = "after"
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"): tag = "live"
	DirAccess.make_dir_recursive_absolute(W + "review/" + tag)
	TeamState.start([[0, 0], [1, 0]])
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await frames(8)
	for spot in [["home",Vector2i(5,8)],["hall",Vector2i(24,7)],["shop",Vector2i(33,8)],["storage",Vector2i(40,8)],["scrolls",Vector2i(33,13)],["yard",Vector2i(41,13)],["shrine",Vector2i(7,13)],["gate",Vector2i(32,28)]]:
		town.team[0]["pos"] = spot[1]
		town._place(town.team[0])
		await frames(12)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(W + "review/" + tag + "/" + spot[0] + ".png")
	print("Captured ", tag, " eight native Highbank views")
	town.queue_free()
	await frames(4)
	quit()
