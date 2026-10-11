extends SceneTree
const U="D:/dev/hollowtide-dungeon-tiles-20261010/"
func _initialize()->void:run.call_deferred()
func frames(n:int)->void:
	for k in n:await process_frame
func run()->void:
	var dir:=U+"review/"+("after/" if FileAccess.file_exists("res://scripts/dungeon/dungeon_tile_art.gd") else "before/")
	DirAccess.make_dir_recursive_absolute(dir)
	root.size=Vector2i(1152,648)
	for entry in [["hollow-mouth","mouth",1],["rootbank","first",1],["hollow-valley","hollow",1],["hollow-ruin","hollow",2]]:
		var dg:Node=load("res://scenes/dungeon.tscn").instantiate();dg.dungeon=entry[1];dg.floor_n=entry[2];dg.floor_seed=4242;dg.poll_input=false;dg.party=[[0,0],[1,0],[10,0]]
		root.add_child(dg);await frames(10);dg._banner.at=-100000;await frames(2)
		dg._map.texture.get_image().save_png(dir+entry[0]+"-map.png")
		await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(dir+entry[0]+".png")
		dg.queue_free();load("res://scripts/audio/music.gd")._inst=null;await frames(12)
	print("DUNGEON native review captured ",dir);quit()
