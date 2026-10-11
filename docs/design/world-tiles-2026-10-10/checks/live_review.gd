extends SceneTree
const U="D:/dev/hollowtide-world-tiles-20261010/"
func _initialize()->void:run.call_deferred()
func frames(n:int)->void:
	for k in n:await process_frame
func run()->void:
	var folder:=U+"review/live/"
	DirAccess.make_dir_recursive_absolute(folder)
	var map:Image=load("res://scripts/town/hub_town.gd").paint();map.save_png(folder+"map-native.png")
	load("res://scripts/town/team_state.gd").start([[0,0],[1,0]])
	var town:Node=load("res://scenes/hub_town.tscn").instantiate();town.poll_input=false
	root.size=Vector2i(1152,648);root.add_child(town);await frames(8)
	for entry in [["home",Vector2i(5,8)],["hall",Vector2i(24,8)],["east",Vector2i(40,10)],["switchback",Vector2i(23,20)],["landing",Vector2i(28,28)]]:
		town.team[0]["pos"]=entry[1];town._place(town.team[0]);await frames(8)
		await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(folder+entry[0]+".png")
	for child in root.get_children():child.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await frames(12);print("WORLD TILES native review captured: ",folder);quit()

