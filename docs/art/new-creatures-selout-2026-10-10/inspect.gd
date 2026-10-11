extends SceneTree
const W := "D:/dev/hollowtide-wilds-selout-20261010/"
func _initialize() -> void:run.call_deferred()
func run() -> void:
	var v:=SubViewport.new();v.size=Vector2i(1152,960);v.transparent_bg=false;v.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(v)
	var row:=0
	for form in ["skimlet","ozbender","valvekin"]:
		var col:=0
		for file in ["s.png","sw.png","town/s.png","dungeon/walk_s_f0.png"]:
			var path:String="res://assets/sprites/arena/"+form+"/"+file
			if not ResourceLoader.exists(path):continue
			var s:=Sprite2D.new();s.centered=false;s.texture=load(path);s.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
			s.position=Vector2(col*288, row*320);s.scale=Vector2.ONE*(2 if col<2 else 4)
			v.add_child(s);col+=1
		row+=1
	for k in 8:await process_frame
	await RenderingServer.frame_post_draw
	v.get_texture().get_image().save_png(W+"raw-inspection.png")
	v.queue_free()
	for k in 8:await process_frame
	quit()
