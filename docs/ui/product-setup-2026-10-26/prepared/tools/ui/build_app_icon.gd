extends SceneTree
## Native crop of the existing title's original burrow/root ornament, enlarged without filtering.
## Godot --path . --rendering-method gl_compatibility --script res://tools/ui/build_app_icon.gd
## Optional output directory after --; default is the project root.
func _initialize() -> void:_run.call_deferred()
func _run() -> void:
	var args:=OS.get_cmdline_user_args()
	var out: String=args[0] if not args.is_empty() else "res://"
	DirAccess.make_dir_recursive_absolute(out)
	var vp:=SubViewport.new();vp.size=Vector2i(32,32);vp.transparent_bg=true
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	vp.canvas_item_default_texture_filter=Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST;root.add_child(vp)
	var bg:=ColorRect.new();bg.size=Vector2(32,32);bg.color=Color("#161f1b");vp.add_child(bg)
	var mark: Node2D=load("res://scripts/ui/hollowtide_wordmark.gd").new()
	mark.position=Vector2(-176,-53);vp.add_child(mark)
	for frame in 5:await process_frame
	await RenderingServer.frame_post_draw
	var im:=vp.get_texture().get_image();im.convert(Image.FORMAT_RGBA8)
	var native_path:=out.path_join("icon-native.png")
	if not args.is_empty():im.save_png(native_path)
	im.resize(256,256,Image.INTERPOLATE_NEAREST)
	var result:=im.save_png(out.path_join("icon.png"))
	vp.queue_free()
	for frame in 3:await process_frame
	print("APP ICON: ","PASS" if result==OK else "FAIL");quit(0 if result==OK else 1)
