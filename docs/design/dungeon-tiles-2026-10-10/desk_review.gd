extends SceneTree
func _initialize()->void:run.call_deferred()
func frames(n:int)->void:
	for k in n:await process_frame
func run()->void:
	root.size=Vector2i(1152,648)
	var room:Node=load("res://scenes/town_room.tscn").instantiate();room.room_id="hall";room.poll_input=false
	root.add_child(room);await frames(5)
	room.cam_focus=Vector2(264,92)
	await frames(8);await RenderingServer.frame_post_draw
	var folder:="D:/dev/hollowtide-dungeon-tiles-20261010/review/after/"
	DirAccess.make_dir_recursive_absolute(folder)
	root.get_texture().get_image().save_png(folder+"guild-desk.png")
	var desk:Sprite2D
	for child in room._world.get_children():
		if child is Sprite2D and child.position==Vector2(room.DESK_AT):desk=child
	assert(desk!=null and desk.texture.get_size()==Vector2(192,52))
	assert(desk.position==Vector2(168,70) and desk.z_index==116)
	assert(desk.material is ShaderMaterial)
	assert(room.grid[3*22+7]==0 and room.grid[4*22+14]==0 and room.grid[2*22+7]==1)
	print("DESK native finish, placement, depth and obstacle grid: all ok")
	room.queue_free();load("res://scripts/audio/music.gd")._inst=null;await frames(12);quit()
