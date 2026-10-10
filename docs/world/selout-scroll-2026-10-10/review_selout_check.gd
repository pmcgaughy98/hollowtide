extends SceneTree
const OUT := "D:/dev/hollowtide-selout-scroll-20261010/review/"
const Finish = preload("res://scripts/arena/creature_finish.gd")
var bad := 0
var checks := 0
func _initialize() -> void: _run.call_deferred()
func check(ok: bool, name: String) -> void:
	checks += 1
	if not ok: bad += 1
	print("PASS " if ok else "FAIL ", name)
func frames(n: int) -> void:
	for k in n: await process_frame
func _run() -> void:
	var proof := SubViewport.new()
	proof.transparent_bg = true
	proof.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	proof.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(proof)
	var sprites: Array[Sprite2D] = []
	for k in 2:
		var s := Sprite2D.new()
		s.centered = false
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		proof.add_child(s)
		sprites.append(s)
	var old_shader: Shader = load("D:/dev/hollowtide-selout-scroll-20261010/originals/scripts/arena/creature_finish.gdshader")
	var old_mat := ShaderMaterial.new()
	old_mat.shader = old_shader
	sprites[0].material = old_mat
	Finish.apply(sprites[1])
	var arena = load("res://scripts/arena/arena_prototype.gd")
	var tested := 0
	var differences := []
	for line in arena.LINES:
		for form in line["forms"]:
			var set := "dungeon" if ResourceLoader.exists("res://assets/sprites/arena/%s/dungeon/s.png" % form[0]) else "small"
			var texture: Texture2D = load("res://assets/sprites/arena/%s/%s/s.png" % [form[0], set])
			var cell := Vector2i(texture.get_size()) + Vector2i(4, 4)
			proof.size = Vector2i(cell.x * 2, cell.y)
			for k in 2:
				sprites[k].texture = texture
				sprites[k].position = Vector2(k * cell.x + 2, 2)
			await frames(2)
			await RenderingServer.frame_post_draw
			var render := proof.get_texture().get_image()
			if render.get_region(Rect2i(Vector2i.ZERO, cell)).get_data() != render.get_region(Rect2i(Vector2i(cell.x, 0), cell)).get_data(): differences.append(form[0])
			tested += 1
	check(tested >= 30 and differences.is_empty(), "default creature render exact across %d forms; differences %s" % [tested, str(differences)])
	var art: Texture2D = load("res://assets/sprites/world/growth_shrine_2026_10_10/shrine_native.png")
	proof.size = Vector2i(296, 124)
	for k in 2:
		sprites[k].texture = art
		sprites[k].position = Vector2(k * 148 + 2, 2)
	var old_building := ShaderMaterial.new()
	old_building.shader = load("D:/dev/hollowtide-selout-scroll-20261010/originals/scripts/town/building_detail_finish.gdshader")
	sprites[0].material = old_building
	Finish.apply(sprites[1], true)
	await frames(3)
	await RenderingServer.frame_post_draw
	var rendered := proof.get_texture().get_image()
	var dark := [0, 0]
	for k in 2:
		for y in range(32, 106):
			for x in range(22, 122):
				var c := rendered.get_pixel(x + k * 148 + 2, y + 2)
				if c.a > 0.9 and maxf(c.r, maxf(c.g, c.b)) < 0.12: dark[k] += 1
	check(dark[1] > dark[0] + 20, "shrine gains actual internal ink pixels: %s" % str(dark))
	rendered.save_png(OUT + "selout_shrine_comparison.png")
	# Legacy building entry point and direct shared detail preset must draw identically.
	old_building.shader = load("res://scripts/town/building_detail_finish.gdshader")
	await frames(3)
	await RenderingServer.frame_post_draw
	rendered = proof.get_texture().get_image()
	check(rendered.get_region(Rect2i(0, 0, 148, 124)).get_data() == rendered.get_region(Rect2i(148, 0, 148, 124)).get_data(), "legacy building shader draws same shared detail preset")
	proof.queue_free()
	await frames(3)
	old_mat = null
	old_shader = null
	old_building = null
	arena = null
	print("RESULT ", checks, " checks, ", bad, " failures")
	quit(0 if bad == 0 else 1)
