extends SceneTree
const Arena = preload("res://scripts/arena/arena_prototype.gd")
const Finish = preload("res://scripts/arena/creature_finish.gd")
const OUT = "D:/dev/hollowtide-texture-consistency-20261008/"

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(780, 780)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var background := ColorRect.new()
	background.size = Vector2(780,780)
	background.color = Color("#586863")
	viewport.add_child(background)
	for row in Arena.LINES.size():
		for stage in 3:
			var form: String = Arena.LINES[row]["forms"][stage][0]
			var x := 260 * stage
			var y := 78 * row
			var label := Label.new()
			label.text = form + "    SOURCE / FINISH"
			label.position = Vector2(x+5,y)
			label.add_theme_font_size_override("font_size",9)
			viewport.add_child(label)
			for j in 4:
				var sprite := Sprite2D.new()
				var facing: String = "se" if j < 2 else "walk_se_f3"
				sprite.texture = load("res://assets/sprites/arena/%s/small/%s.png" % [form,facing])
				sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				var used := sprite.texture.get_image().get_used_rect()
				sprite.offset.y = sprite.texture.get_height()*0.5-used.end.y
				sprite.position = Vector2(x+32+64*j, y+72)
				if j%2 == 1:Finish.apply(sprite)
				viewport.add_child(sprite)
	await process_frame
	await RenderingServer.frame_post_draw
	var shot := viewport.get_texture().get_image()
	shot.save_png(OUT+"gallery-native.png")
	shot.resize(1560,1560,Image.INTERPOLATE_NEAREST)
	shot.save_png(OUT+"gallery-2x.png")
	print("Texture gallery captured")
	viewport.queue_free()
	await process_frame
	quit()
