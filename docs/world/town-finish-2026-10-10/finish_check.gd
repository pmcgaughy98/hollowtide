extends SceneTree
const OUT = "D:/dev/hollowtide-town-finish-20261010/review/"
const Layout = preload("res://scripts/town/town_layout.gd")
var bad := 0
var checks := 0
func _initialize() -> void:
	_run.call_deferred()
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: bad += 1
	print("PASS " if ok else "FAIL ", label)
func frames(n: int) -> void:
	for k in n: await process_frame
func key(k: int) -> void:
	var e := InputEventKey.new()
	e.keycode = k
	e.pressed = true
	Input.parse_input_event(e)
	await frames(1)
	e = InputEventKey.new()
	e.keycode = k
	e.pressed = false
	Input.parse_input_event(e)
	await frames(1)
func snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + name + ".png")
func _run() -> void:
	var Town = load("res://scripts/town/hub_town.gd")
	var before: Image = load("D:/dev/hollowtide-town-finish-20261010/baseline_hub.gd").paint()
	var after: Image = Town.paint()
	var allowed := [Rect2i(70, 70, 124, 147), Rect2i(742, 70, 148, 147)]
	var outside := 0
	for y in after.get_height():
		for x in after.get_width():
			var p := Vector2i(x, y)
			if not allowed[0].has_point(p) and not allowed[1].has_point(p) and after.get_pixelv(p) != before.get_pixelv(p): outside += 1
	check(outside == 0, "all ground pixels outside Home / shop and their bounded aprons unchanged")
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	root.add_child(town)
	await frames(10)
	var view: Node2D = town._building_exteriors
	check(view.buildings.size() == 2, "exactly Home and Item Shop installed as separate sprites")
	for id in ["home", "shop"]:
		var b: Dictionary = view.buildings[id]
		var p: Dictionary = Layout.PLACES.filter(func(v: Dictionary) -> bool: return v["id"] == id)[0]
		check(b["sprite"].material.shader == preload("res://scripts/town/building_detail_finish.gdshader"), id + " uses the house finish plus internal detail outlines")
		# Measure the rendered interiors, not just the assigned shader or outer silhouette.
		var proof := SubViewport.new()
		var size: Vector2i = b["sprite"].texture.get_size()
		proof.size = Vector2i(size.x * 2, size.y)
		proof.transparent_bg = true
		proof.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		proof.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		root.add_child(proof)
		for k in 2:
			var compare := Sprite2D.new()
			compare.centered = false
			compare.position.x = size.x * k
			compare.texture = b["sprite"].texture
			preload("res://scripts/arena/creature_finish.gd").apply(compare)
			if k == 1: compare.material.shader = preload("res://scripts/town/building_detail_finish.gdshader")
			proof.add_child(compare)
		await frames(3)
		await RenderingServer.frame_post_draw
		var rendered := proof.get_texture().get_image()
		var dark := [0, 0]
		for k in 2:
			for y in range(8, size.y - 8):
				for x in range(8, size.x - 8):
					var c := rendered.get_pixel(x + k * size.x, y)
					if c.a > 0.9 and maxf(c.r, maxf(c.g, c.b)) < 0.12: dark[k] += 1
		check(dark[1] > dark[0] + 100, id + " native render adds near-black outlines inside the building")
		proof.queue_free()
		check(b["base"].position == Vector2(p["rect"].position * 24), id + " original position")
		check(b["sprite"].texture.get_size() == Vector2(p["rect"].size * 24), id + " original footprint")
		check(b["frame"] == 0, id + " door starts closed")
		var door_image: Image = b["frames"][0].get_image()
		var visible_pixels := 0
		for y in door_image.get_height():
			for x in door_image.get_width():
				if door_image.get_pixel(x, y).a > 0.5: visible_pixels += 1
		check(visible_pixels > 200, id + " painted door mask has visible pixels")
		check(b["frames"][0].get_image().get_data() != b["frames"][1].get_image().get_data() and b["frames"][1].get_image().get_data() != b["frames"][2].get_image().get_data(), id + " three actual distinct door drawings")
		town.team[0]["pos"] = p["door"] + Vector2i(0, 1)
		town.team[0]["facing"] = "n"
		town._place(town.team[0])
		await frames(3)
		await town.act_move(Vector2i(0, -1))
		check(town.team[0]["pos"] == p["door"], id + " actual walking onto authored door tile")
		await key(KEY_E)
		check(town.panel.get("id", "") == id and town.last_sfx == "door", id + " native E retains service and sound")
		await frames(3)
		check(b["frame"] == 1, id + " door passes through ajar frame")
		await frames(8)
		check(b["frame"] == 2, id + " door opens to warm interior")
		town.team[0]["pos"] = p["door"] + Vector2i(0, 1)
		town._place(town.team[0])
		await frames(2)
		await snap(id + "_service")
		await key(KEY_ESCAPE)
		await frames(12)
		check(b["frame"] == 0 and town.panel.is_empty(), id + " escape closes service and door")
		# Frame the entire exterior for art review without changing the production camera.
		town.set_process(false)
		town._world.position = Vector2(0 if id == "home" else -624, -24)
		await frames(2)
		await snap(id + "_exterior")
		town.set_process(true)
		# Face the threshold from the approach; E still answers without entering.
		town.team[0]["pos"] = p["door"] + Vector2i(0, 1)
		town.team[0]["facing"] = "n"
		town._place(town.team[0])
		await key(KEY_E)
		check(town.panel.get("id", "") == id, id + " native E from approach")
		await key(KEY_ESCAPE)
		await frames(12)
	town.queue_free()
	await frames(4)
	print("RESULT ", checks, " checks, ", bad, " failures")
	quit(0 if bad == 0 else 1)
