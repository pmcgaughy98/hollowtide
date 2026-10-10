extends SceneTree
const OUT="D:/dev/hollowtide-wordmark-20261009/"
func _initialize() -> void:call_deferred("run")
func frames(n:int) -> void:
	for i in n:await process_frame
func shot(name:String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+name+".png")
func run() -> void:
	var menu:Node2D=load("res://scenes/creature_opening.tscn").instantiate()
	root.add_child(menu);current_scene=menu
	await frames(10);await shot("prelude")
	menu._finish_boot();await frames(160);await shot("title")
	menu._wordmark.texture.get_image().save_png(OUT+"wordmark-native.png")
	menu._on_options();await frames(3);await shot("options")
	menu.queue_free();await frames(3);quit()
