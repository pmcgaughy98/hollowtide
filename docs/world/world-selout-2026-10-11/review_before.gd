extends SceneTree
const OUT := "D:/dev/hollowtide-world-selout-20261011/"
func _initialize() -> void: _run.call_deferred()
func _frames(n: int) -> void:
	for k in n:await process_frame
func _run() -> void:
	var Town := load("res://scripts/town/hub_town.gd")
	Town.paint().save_png(OUT+"before.png")
	load("res://scripts/town/team_state.gd").start([[0,0],[1,0]])
	var town: Node2D=load("res://scenes/hub_town.tscn").instantiate();town.poll_input=false
	root.size=Vector2i(1152,648);root.add_child(town);await _frames(8)
	for entry in [["lane",Vector2i(13,10)],["switchback",Vector2i(23,20)],["landing",Vector2i(28,28)]]:
		town.team[0]["pos"]=entry[1];town._place(town.team[0]);await _frames(8)
		await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(OUT+"before_"+entry[0]+".png")
	for child in root.get_children():child.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await _frames(16);print("WORLD before captures saved");quit()
