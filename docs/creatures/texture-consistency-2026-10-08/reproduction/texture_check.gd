extends SceneTree
const Arena = preload("res://scripts/arena/arena_prototype.gd")
const Finish = preload("res://scripts/arena/creature_finish.gd")
const OUT = "D:/dev/hollowtide-texture-consistency-20261008/"
var failed: Array[String] = []
var reports: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT+"frames")
	for line in Arena.LINES:
		for form in line["forms"]:
			var view := SubViewport.new()
			view.size = Vector2i(720,640)
			view.transparent_bg = true
			view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			root.add_child(view)
			var items: Array[Dictionary] = []
			for fi in 8:
				var facing: String = Arena.FACINGS[fi]
				for pose in 9:
					var frame: String = facing if pose == 0 else "walk_%s_f%d" % [facing,pose-1]
					var tex: Texture2D = load("res://assets/sprites/arena/%s/small/%s.png" % [form[0],frame])
					var sprite := Sprite2D.new()
					sprite.texture = tex
					sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
					sprite.centered = false
					sprite.position = Vector2(pose*80+4,fi*80+4)
					Finish.apply(sprite)
					view.add_child(sprite)
					items.append({"source":tex.get_image(),"at":Vector2i(sprite.position),"frame":frame})
			await process_frame
			await RenderingServer.frame_post_draw
			var after := view.get_texture().get_image()
			after.save_png(OUT+"frames/"+form[0]+".png")
			var erased := 0
			var outside := 0
			var original_solid := 0
			var changed_inside := 0
			var outline_added := 0
			for item in items:
				var src: Image = item.source
				for y in range(-2,src.get_height()+2):
					for x in range(-2,src.get_width()+2):
						var p := Vector2i(x,y)
						var c := pixel(src,p)
						var result := after.get_pixelv(item.at+p)
						if c.a > 0.5:
							original_solid += 1
							if result.a < 0.99:erased += 1
							var inner := true
							for step in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
								inner = inner and pixel(src,p+step).a > 0.5
							if inner and absf(c.r-result.r)+absf(c.g-result.g)+absf(c.b-result.b)>0.025:changed_inside += 1
						elif result.a > 0.5:
							outline_added += 1
							var beside := false
							for step in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
								beside = beside or pixel(src,p+step).a > 0.5
							if not beside:outside += 1
			var report := {"form":form[0],"textures":items.size(),"source_pixels":original_solid,"erased_pixels":erased,"beyond_one_pixel":outside,"cluster_pixels":changed_inside,"outline_pixels_added":outline_added}
			reports.append(report)
			if erased>0 or outside>0:failed.append(form[0]+" geometry")
			print(JSON.stringify(report))
			view.queue_free()
			await process_frame
	# Check the actual arena attachment, anchor and texture swaps, not just a gallery.
	var arena: Node2D = load("res://scenes/arena_prototype.tscn").instantiate()
	arena.poll_input = false
	arena.picker_redirect = false
	arena.match_horn = false
	root.add_child(arena)
	await process_frame
	arena.set_process(false)
	var swaps := 0
	for line in Arena.LINES.size():
		for stage in 3:
			arena._you = line;arena._you_stage = stage
			arena.team_size = 1
			arena._new_match()
			var f: Dictionary = arena._fighters[0]
			var sprite: Sprite2D = f.sprite
			if sprite.material == null or sprite.material.shader != Finish.SHADER:failed.append(f.name+" missing finish")
			for facing in Arena.FACINGS:
				for tex in [f.art.still[facing]] + Array(f.art.walk[facing]):
					arena._set_texture(f,tex)
					if absf(sprite.offset.y-tex.get_height()*0.5+f.art.foot[tex]) > 0.01:failed.append(f.name+" anchor")
					swaps += 1
	# Actual 3x battle views, with the original and new finish at identical positions.
	arena._you = 1;arena._you_stage = 2
	arena._rival = 6;arena._rival_stage = 2
	arena._new_match()
	for f in arena._fighters:
		f.body.position = arena._floor().get_center()+Vector2(-50 if f.team==0 else 50,0)
		arena._set_texture(f,f.art.still.se)
		f.sprite.material = null
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"arena-before.png")
	for f in arena._fighters:Finish.apply(f.sprite)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"arena-after.png")
	arena.queue_free()
	await process_frame
	var file := FileAccess.open(OUT+"checks.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"forms":reports,"texture_swaps":swaps,"failures":failed},"  "))
	file.close()
	print("RESULT ",reports.size()," forms / ",swaps," frame swaps / ",failed.size()," failures")
	quit(0 if failed.is_empty() else 1)

func pixel(img: Image,p: Vector2i) -> Color:
	if p.x < 0 or p.y < 0 or p.x >= img.get_width() or p.y >= img.get_height():return Color.TRANSPARENT
	return img.get_pixelv(p)
