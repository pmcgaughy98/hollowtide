extends SceneTree
## Route 1 capture (needs a window). Usage:
##   Godot.exe --path . --script res://tools/debug/route_capture.gd -- <name> [cols] [rows]
## Loads the first route, waits for it to build, then saves:
##   <name>_overview.png  the whole map, from the bounds of its tile layers
##   <name>_rc.png        a grid of normal-scale views (cols x rows), r and c from 0
## to user://route_captures/. A review camera only; the game is not changed.
var OUT := ProjectSettings.globalize_path("user://route_captures/")


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	_run()


func _layers(n: Node, out: Array) -> void:
	if n is TileMapLayer:
		out.append(n)
	for c in n.get_children():
		_layers(c, out)


func _snap(n: String) -> void:
	for i in 3:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + n + ".png")


func _run() -> void:
	var a := OS.get_cmdline_user_args()
	var name: String = a[0]
	var cols: int = int(a[1]) if a.size() > 1 else 3
	var rows: int = int(a[2]) if a.size() > 2 else 2
	var route: Node = load("res://scenes/first_route_prototype.tscn").instantiate()
	root.add_child(route)
	await create_timer(4.0, true).timeout
	await _snap(name + "_start")
	var layers: Array = []
	_layers(route, layers)
	var bounds := Rect2()
	for l in layers:
		var used: Rect2i = l.get_used_rect()
		if used.size == Vector2i.ZERO:
			continue
		var ts: Vector2 = Vector2(l.tile_set.tile_size)
		var r := Rect2(l.to_global(Vector2(used.position) * ts), Vector2(used.size) * ts)
		bounds = r if bounds.size == Vector2.ZERO else bounds.merge(r)
	print("bounds ", bounds)
	var cam := Camera2D.new()
	route.add_child(cam)
	cam.make_current()
	var view := Vector2(root.get_visible_rect().size)
	var fit: float = minf(view.x / bounds.size.x, view.y / bounds.size.y)
	cam.zoom = Vector2.ONE * fit
	cam.global_position = bounds.get_center()
	await _snap(name + "_overview")
	# Normal-scale views use the zoom the player's camera had.
	var play_zoom := 2.0
	var cell := Vector2(bounds.size.x / cols, bounds.size.y / rows)
	cam.zoom = Vector2.ONE * play_zoom
	for r in rows:
		for c in cols:
			cam.global_position = bounds.position + cell * Vector2(c + 0.5, r + 0.5)
			await _snap("%s_%d%d" % [name, r, c])
	quit()
