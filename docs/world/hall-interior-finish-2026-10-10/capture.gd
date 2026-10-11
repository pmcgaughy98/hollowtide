extends SceneTree
const W := "D:/dev/hollowtide-hall-interior-20261010/"
const State := preload("res://scripts/town/team_state.gd")
func _initialize() -> void: _run.call_deferred()
func frames(n: int) -> void:
	for k in n: await process_frame
func _run() -> void:
	var tag := "after" if FileAccess.file_exists(W+"after.flag") else "before"
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"): tag="live"
	DirAccess.make_dir_recursive_absolute(W+"review/"+tag)
	State.start([[0,0],[1,0]])
	var room: Node2D=load("res://scenes/town_room.tscn").instantiate()
	room.room_id="hall"
	room.poll_input=false
	root.add_child(room)
	await frames(10)
	for spot in [["entry",Vector2i(11,12)],["middle",Vector2i(11,9)],["counter",Vector2i(11,4)],["chart",Vector2i(6,9)],["roster",Vector2i(18,3)]]:
		room.team[0].pos=spot[1]
		room._place(room.team[0])
		await frames(10)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(W+"review/"+tag+"/"+spot[0]+".png")
	room.queue_free()
	await frames(12)
	print("Captured ",tag," five Hall views")
	quit()
