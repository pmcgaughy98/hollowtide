extends SceneTree
const OUT := "D:/dev/hollowtide-rootbank-finish-20261011/after-live/"
func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
	for k in n: await process_frame
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	root.size=Vector2i(1152,648)
	var dg:Node=load("res://scenes/dungeon.tscn").instantiate()
	dg.dungeon="first";dg.floor_seed=4242;dg.poll_input=false;dg.party=[[0,0],[1,0]];dg.boss_intro=false
	root.add_child(dg);current_scene=dg
	await frames(5)
	for f in [1,2,3,4]:
		dg.floor_n=f;dg._build_floor(true);await frames(5)
		var img:Image=dg._map.texture.get_image()
		img.save_png(OUT+"floor%d-raw.png"%f)
		var view:=SubViewport.new()
		view.size=img.get_size();view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var map:=Sprite2D.new();map.centered=false;map.texture=dg._map.texture;map.material=dg._map.material;map.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		view.add_child(map);await frames(3);await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png(OUT+"floor%d-native.png"%f)
		view.queue_free();await frames(2)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OUT+"floor%d-game.png"%f)
		FileAccess.open(OUT+"floor%d-data.json"%f,FileAccess.WRITE).store_string(JSON.stringify(dg.data,"  "))
	var music:=root.get_node_or_null("HollowtideMusic")
	if music!=null:music.queue_free()
	dg.queue_free();await frames(3)
	print("ROOTBANK LIVE: four floors captured, current layouts unchanged.")
	quit()

