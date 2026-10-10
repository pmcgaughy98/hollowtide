extends SceneTree
const OUT = "D:/dev/hollowtide-selout-scroll-20261010/review/"
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
	var before: Image = load("D:/dev/hollowtide-selout-scroll-20261010/baseline_hub.gd").paint()
	var after: Image = load("res://scripts/town/hub_town.gd").paint()
	var allowed := Rect2i(742, 264, 148, 146)
	var outside := 0
	for y in after.get_height():
		for x in after.get_width():
			if not allowed.has_point(Vector2i(x, y)) and after.get_pixel(x, y) != before.get_pixel(x, y): outside += 1
	check(outside == 0, "all ground outside Scroll Keeper / shadow / apron exact")
	var Old = load("D:/dev/hollowtide-selout-scroll-20261010/originals/scripts/town/building_exteriors.gd")
	var New = load("res://scripts/town/building_exteriors.gd")
	for id in ["home", "shop", "hall", "storage"]:
		var p: Dictionary = Layout.PLACES.filter(func(v: Dictionary) -> bool: return v["id"] == id)[0]
		var first: Vector2i = p["door"]
		for tile in Layout.door_tiles(p): first.x = mini(first.x, tile.x)
		var d: Vector2i = (first - p["rect"].position) * 24
		var w: int = Layout.door_tiles(p).size() * 24
		check(New._details(p["rect"].size * 24, d, id, w).get_data() == Old._details(p["rect"].size * 24, d, id, w).get_data(), id + " foundation / sign textures exact")
		var art: Image = load(New.SOURCES[id]).get_image()
		var same := true
		for k in 3: same = same and New._door_frame(k, art, d, id).get_data() == Old._door_frame(k, art, d, id).get_data()
		check(same, id + " three door textures exact")
	Old = null
	New = null
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	root.add_child(town)
	await frames(10)
	var view: Node2D = town._building_exteriors
	check(view.buildings.size() == 6, "Scroll Keeper joins Home / shop / Hall")
	var b: Dictionary = view.buildings["scrolls"]
	check(b["base"].position == Vector2(744, 288) and b["sprite"].texture.get_size() == Vector2(144, 120), "original Scroll Keeper footprint / position")
	check(b["sprite"].material.shader == preload("res://scripts/arena/creature_finish.gdshader") and b["sprite"].material.get_shader_parameter("detail_ink") == 1.0, "installed interior / silhouette house finish")
	var img: Image = b["frames"][0].get_image()
	var count := 0
	var minx := 28
	var maxx := 0
	for y in img.get_height():
		for x in img.get_width():
			if img.get_pixel(x, y).a > 0.5:
				count += 1
				minx = mini(minx, x)
				maxx = maxi(maxx, x)
	check(count > 100, "door mask has actual visible opening pixels")
	var centre := 46.0 + (minx + maxx) * 0.5
	print("Door mask extent ", minx, "..", maxx, "; source centre ", centre)
	img.save_png(OUT + "scrolls_door_closed.png")
	check(absf(centre - 60.0) <= 2.0 and 46 + minx >= 48 and 46 + maxx <= 72, "original complete facade places its door on the existing tile")
	check(b["frames"][0].get_image().get_data() != b["frames"][1].get_image().get_data() and b["frames"][1].get_image().get_data() != b["frames"][2].get_image().get_data(), "three distinct source-masked door drawings")
	var source: Image = b["sprite"].texture.get_image()
	check(source.get_pixel(0, 0).a < 0.1 and source.get_pixel(143, 0).a < 0.1, "transparent corners show the actual ground")
	# Measure native interior ink; source art already has some dark outlines.
	var proof := SubViewport.new()
	proof.size = Vector2i(288, 120)
	proof.transparent_bg = true
	proof.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	proof.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(proof)
	for k in 2:
		var s := Sprite2D.new()
		s.centered = false
		s.position.x = k * 144
		s.texture = b["sprite"].texture
		preload("res://scripts/arena/creature_finish.gd").apply(s)
		if k == 1: s.material.set_shader_parameter("detail_ink", 1.0)
		proof.add_child(s)
	await frames(3)
	await RenderingServer.frame_post_draw
	var rendered := proof.get_texture().get_image()
	var dark := [0, 0]
	for k in 2:
		for y in range(45, 113):
			for x in range(15, 133):
				var c := rendered.get_pixel(x + k * 144, y)
				if c.a > 0.9 and maxf(c.r, maxf(c.g, c.b)) < 0.12: dark[k] += 1
	check(dark[1] > dark[0] + 20, "native render adds near-black internal structure outlines")
	proof.queue_free()
	town.team[0]["pos"] = Vector2i(33, 11)
	town.team[0]["facing"] = "s"
	town._place(town.team[0])
	await frames(3)
	await town.act_move(Vector2i(0, 1))
	check(town.team[0]["pos"] == Vector2i(33, 12), "walk onto unchanged Scroll Keeper doorway")
	await key(KEY_E)
	check(town.panel.get("id", "") == "scrolls" and town.last_sfx == "door", "native E keeps service and door sound")
	await frames(3)
	check(b["frame"] == 1, "door passes through ajar")
	await frames(8)
	check(b["frame"] == 2, "door opens to warm interior")
	town.team[0]["pos"] = Vector2i(33, 11)
	town._place(town.team[0])
	await frames(2)
	await snap("scrolls_service")
	await key(KEY_ESCAPE)
	await frames(12)
	check(b["frame"] == 0 and town.panel.is_empty(), "Esc closes service and animated door")
	await key(KEY_E)
	check(town.panel.get("id", "") == "scrolls", "native E from the worn approach")
	await key(KEY_ESCAPE)
	await frames(12)
	town.set_process(false)
	town._world.position = Vector2(-696, -240)
	await frames(2)
	await snap("scrolls_exterior")
	town.queue_free()
	await frames(4)
	print("RESULT ", checks, " checks, ", bad, " failures")
	quit(0 if bad == 0 else 1)
