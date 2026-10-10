extends SceneTree
const OUT = "D:/dev/hollowtide-hall-finish-20261010/review/"
const Layout = preload("res://scripts/town/town_layout.gd")
var bad := 0
var checks := 0
func _initialize() -> void: _run.call_deferred()
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
	var before: Image = load("D:/dev/hollowtide-hall-finish-20261010/baseline_hub.gd").paint()
	var after: Image = load("res://scripts/town/hub_town.gd").paint()
	var allowed := Rect2i(454, 22, 244, 148)
	var outside := 0
	for y in after.get_height():
		for x in after.get_width():
			if not allowed.has_point(Vector2i(x, y)) and after.get_pixel(x, y) != before.get_pixel(x, y): outside += 1
	check(outside == 0, "all ground outside Hall plus two-pixel contact band unchanged")
	var steps := Rect2i(552, 170, 48, 46)
	check(after.get_region(steps).get_data() == before.get_region(steps).get_data(), "existing two-tile steps retain their pixels below the contact band")
	var Old = load("D:/dev/hollowtide-hall-finish-20261010/originals/scripts/town/building_exteriors.gd")
	var New = load("res://scripts/town/building_exteriors.gd")
	for id in ["home", "shop"]:
		var place: Dictionary = Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == id)[0]
		var d: Vector2i = (place["door"] - place["rect"].position) * 24
		check(New._details(place["rect"].size * 24, d, id).get_data() == Old._details(place["rect"].size * 24, d, id).get_data(), id + " foundation / sign textures exact")
		var art: Image = load(New.SOURCES[id]).get_image()
		var same := true
		for k in 3: same = same and New._door_frame(k, art, d, id).get_data() == Old._door_frame(k, art, d, id).get_data()
		check(same, id + " all three door drawings exact")
	Old = null
	New = null
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	root.add_child(town)
	await frames(8)
	var b: Dictionary = town._building_exteriors.buildings["hall"]
	check(town._building_exteriors.buildings.size() == 3, "Hall joins the finished Home and shop")
	check(b["base"].position == Vector2(456, 24) and b["sprite"].texture.get_size() == Vector2(240, 144), "original Hall position / footprint")
	check(b["door"].position == Vector2(94, 72) and b["frames"][0].get_size() == Vector2(52, 68), "one centered mask spans both door tiles")
	var counts := []
	for k in 3:
		var img: Image = b["frames"][k].get_image()
		var count := 0
		for y in img.get_height():
			for x in img.get_width():
				if img.get_pixel(x, y).a > 0.5: count += 1
		counts.append(count)
	check(counts[0] > 600 and counts[0] == counts[1] and counts[1] == counts[2], "three nonempty frames keep the same source arch mask")
	check(b["frames"][0].get_image().get_data() != b["frames"][1].get_image().get_data() and b["frames"][1].get_image().get_data() != b["frames"][2].get_image().get_data(), "closed / ajar / open are distinct drawings")
	# Compare actual shader output, including both windows, against the prior house finish.
	var proof := SubViewport.new()
	proof.size = Vector2i(480, 144)
	proof.transparent_bg = true
	proof.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	proof.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(proof)
	for k in 2:
		var s := Sprite2D.new()
		s.centered = false
		s.position.x = k * 240
		s.texture = b["sprite"].texture
		preload("res://scripts/arena/creature_finish.gd").apply(s)
		if k == 1: s.material.shader = preload("res://scripts/town/building_detail_finish.gdshader")
		proof.add_child(s)
	await frames(3)
	await RenderingServer.frame_post_draw
	var rendered := proof.get_texture().get_image()
	for rect in [Rect2i(8, 8, 224, 128), Rect2i(33, 89, 38, 31), Rect2i(169, 89, 38, 31)]:
		var dark := [0, 0]
		for k in 2:
			for y in range(rect.position.y, rect.end.y):
				for x in range(rect.position.x, rect.end.x):
					var c := rendered.get_pixel(x + 240 * k, y)
					if c.a > 0.9 and maxf(c.r, maxf(c.g, c.b)) < 0.12: dark[k] += 1
		check(dark[1] > dark[0] + 10, "native interior ink increases in " + str(rect))
	proof.queue_free()
	for x in [23, 24]:
		town.team[0]["pos"] = Vector2i(x, 7)
		town.team[0]["facing"] = "n"
		town._place(town.team[0])
		await frames(2)
		await town.act_move(Vector2i(0, -1))
		check(town.team[0]["pos"] == Vector2i(x, 6), "walk through Hall tile " + str(x))
		await key(KEY_E)
		check(town.panel.get("id", "") == "hall" and town.last_sfx == "door", "native E / guild / sound on tile " + str(x))
		await frames(3)
		check(b["frame"] == 1, "paired leaves pass through ajar from tile " + str(x))
		await frames(8)
		check(b["frame"] == 2, "both tiles open the same complete door")
		town.team[0]["pos"] = Vector2i(x, 7)
		town._place(town.team[0])
		await frames(2)
		await snap("hall_service_" + str(x))
		await key(KEY_ESCAPE)
		await frames(12)
		check(b["frame"] == 0 and town.panel.is_empty(), "Esc closes the Hall and paired leaves")
		await key(KEY_E)
		check(town.panel.get("id", "") == "hall", "native E from step " + str(x))
		await key(KEY_ESCAPE)
		await frames(12)
	town.set_process(false)
	town._world.position = Vector2(-384, 0)
	await frames(2)
	await snap("hall_exterior")
	town.queue_free()
	await frames(4)
	print("RESULT ", checks, " checks, ", bad, " failures")
	quit(0 if bad == 0 else 1)
