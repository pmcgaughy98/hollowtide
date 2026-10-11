extends SceneTree
const W := "D:/dev/hollowtide-board-home-20261010/"
const State := preload("res://scripts/town/team_state.gd")
func _initialize() -> void: _run.call_deferred()
func frames(n: int) -> void:
	for k in n: await process_frame
func snap(tag: String, name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(W+"review/"+tag+"/"+name+".png")
func _run() -> void:
	var tag := "after" if FileAccess.file_exists(W+"after.flag") else "before"
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"): tag="live"
	DirAccess.make_dir_recursive_absolute(W+"review/"+tag)
	State.start([[0,0],[1,0]])
	var town: Node2D=load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input=false
	root.add_child(town)
	await frames(8)
	town.team[0]["pos"]=Vector2i(26,8)
	town._place(town.team[0])
	await frames(12)
	await snap(tag,"board")
	town.queue_free()
	await frames(4)
	for id in ["home","hall"]:
		var room: Node2D=load("res://scenes/town_room.tscn").instantiate()
		room.room_id=id
		room.poll_input=false
		root.add_child(room)
		await frames(12)
		await snap(tag,id)
		if id=="home":
			room.team[0]["pos"]=Vector2i(7,3)
			room._place(room.team[0])
			await frames(10)
			await snap(tag,"home-north")
		room.queue_free()
		await frames(4)
	print("Captured ",tag)
	quit()
