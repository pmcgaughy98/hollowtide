extends SceneTree
const W="D:/dev/hollowtide-town-detail-20261010/"
const Marks=preload("res://scripts/town/landmark_exteriors.gd")
func _initialize()->void:run.call_deferred()
func frames(n:int)->void:
	for k in n:await process_frame
func run()->void:
	DirAccess.make_dir_recursive_absolute(W+"review/live/")
	var atlas:=Image.create(384,288,false,Image.FORMAT_RGBA8)
	atlas.blit_rect(Marks.paint("lookout"),Rect2i(0,0,144,96),Vector2i(0,0))
	atlas.blit_rect(Marks.paint("dock"),Rect2i(0,0,144,72),Vector2i(240,0))
	atlas.blit_rect(Marks.paint("landing"),Rect2i(0,0,288,96),Vector2i(0,108))
	var map:Image=load("res://scripts/town/hub_town.gd").paint()
	atlas.blit_rect(map,Rect2i(0,696,384,72),Vector2i(0,216))
	atlas.save_png(W+"review/live/atlas-native.png")
	atlas.resize(1536,1152,Image.INTERPOLATE_NEAREST);atlas.save_png(W+"review/live/atlas-reference.png")
	load("res://scripts/town/team_state.gd").start([[0,0],[1,0]])
	var town:Node=load("res://scenes/hub_town.tscn").instantiate();town.poll_input=false
	root.size=Vector2i(1152,648);root.add_child(town);await frames(8)
	for entry in [["lookout",Vector2i(13,5)],["landing",Vector2i(28,28)],["dock",Vector2i(39,28)]]:
		town.team[0]["pos"]=entry[1];town._place(town.team[0]);await frames(8)
		await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(W+"review/live/"+entry[0]+".png")
	for child in root.get_children():child.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await frames(12);print("TOWN DETAIL AFTER native art captured.");quit()

