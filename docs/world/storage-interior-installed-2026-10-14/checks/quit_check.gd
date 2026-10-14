extends SceneTree
const TeamState = preload("res://scripts/town/team_state.gd")
var OUT="D:/dev/hollowtide-storage-integration-20261014/"+OS.get_cmdline_user_args()[0]+"/quit_check/"
var fails=0
func _initialize():run.call_deferred()
func frames(n):
	for k in n:await process_frame
func ok(label,value):
	print(label," -> ","ok" if value else "FAIL")
	if not value:fails+=1
func run():
	root.size=Vector2i(1152,648);DirAccess.make_dir_recursive_absolute(OUT)
	TeamState.save_path="user://storage_quit.save";TeamState.erase_save()
	TeamState.start([[0,0],[1,0],[2,0]])
	TeamState.data.bag={"reedberry":2};TeamState.data.beaten=["mouth","first"]
	var room=load("res://scenes/town_room.tscn").instantiate();room.room_id="storage";room.poll_input=false
	root.add_child(room);current_scene=room;await frames(6)
	# Private placement isolates quitting from path tests; integration.gd walks the actual route.
	room.team[0].pos=Vector2i(8,7);room.team[0].facing="n";room._place(room.team[0])
	room.act_use();room.act_store(1)
	ok("Deposit changes the same bag/store record",TeamState.data.bag.reedberry==1 and TeamState.data.stored.reedberry==1)
	var menu=room.get_node("GamePauseMenu")
	menu.open();menu.show_page("title");menu.leave();await frames(10)
	ok("Actual pause Return to title leaves Storage",current_scene.scene_file_path.ends_with("creature_opening.tscn") and not paused)
	var title=current_scene
	ok("Pause save exists at private test path",TeamState.has_save())
	var boot_guard=0
	while "_boot_done" in title and not title.get("_boot_done") and boot_guard<600:
		await frames(1);boot_guard+=1
	TeamState.data={}
	title._on_continue()
	var guard=0
	while current_scene==title and guard<180:
		await frames(1);guard+=1
	await frames(6)
	var town=current_scene;town.poll_input=false
	ok("Actual Continue opens Highbank",town.scene_file_path.ends_with("hub_town.tscn"))
	ok("Continue restores exact deposited and bag counts",TeamState.data.bag.reedberry==1 and TeamState.data.stored.reedberry==1 and TeamState.data.party==[[0,0],[1,0],[2,0]])
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"continued.png")
	town.queue_free();await frames(4);TeamState.erase_save()
	var music=root.get_node_or_null("HollowtideMusic")
	if music!=null:music.queue_free()
	await frames(4)
	print("STORAGE QUIT/CONTINUE: ",5-fails,"/5")
	quit(1 if fails else 0)
