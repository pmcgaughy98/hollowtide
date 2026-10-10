extends SceneTree
const W := "D:/dev/hollowtide-town-structures-20261010/"
const State := preload("res://scripts/town/team_state.gd")
func _initialize() -> void: _run.call_deferred()
func frames(n: int) -> void:
	for k in n:await process_frame
func _run() -> void:
	var tag := "after" if FileAccess.file_exists(W+"after.flag") else "before"
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"):tag="live"
	DirAccess.make_dir_recursive_absolute(W+"review/"+tag)
	State.start([[0,0],[1,0]])
	var town: Node2D=load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input=false
	root.add_child(town)
	await frames(8)
	for spot in [["board",Vector2i(26,8)],["hall",Vector2i(24,7)],["lookout",Vector2i(13,5)],["landing",Vector2i(28,27)],["dock",Vector2i(39,28)],["gate",Vector2i(32,28)]]:
		town.team[0]["pos"]=spot[1]
		town._place(town.team[0])
		await frames(12)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(W+"review/"+tag+"/"+spot[0]+".png")
	print("Captured ",tag," six town structure views")
	town.queue_free()
	await frames(4)
	quit()
