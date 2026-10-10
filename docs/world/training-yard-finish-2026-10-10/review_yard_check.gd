extends SceneTree
const OUT := "D:/dev/hollowtide-training-yard-20261010/review/"
const Layout = preload("res://scripts/town/town_layout.gd")
var checks := 0
var bad := 0
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
	Input.parse_input_event(e)
	await frames(1)
func snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + name + ".png")
func _run() -> void:
	var before: Image = load("D:/dev/hollowtide-training-yard-20261010/baseline_hub.gd").paint()
	var after: Image = load("res://scripts/town/hub_town.gd").paint()
	var outside := 0
	var inside := 0
	var allowed := Rect2i(912, 264, 168, 144)
	for y in after.get_height():
		for x in after.get_width():
			if after.get_pixel(x, y) != before.get_pixel(x, y):
				if allowed.has_point(Vector2i(x, y)): inside += 1
				else: outside += 1
	check(outside == 0 and inside > 100, "ground changes are visible and confined to Yard / north approach")
	var Old = load("D:/dev/hollowtide-training-yard-20261010/originals/scripts/town/building_exteriors.gd")
	var New = load("res://scripts/town/building_exteriors.gd")
	for id in ["home", "shop", "hall", "storage", "scrolls"]:
		var p: Dictionary = Layout.PLACES.filter(func(v: Dictionary) -> bool: return v["id"] == id)[0]
		var first: Vector2i = p["door"]
		for tile in Layout.door_tiles(p): first.x = mini(first.x, tile.x)
		var d: Vector2i = (first - p["rect"].position) * 24
		var w: int = Layout.door_tiles(p).size() * 24
		check(New._details(p["rect"].size * 24, d, id, w).get_data() == Old._details(p["rect"].size * 24, d, id, w).get_data(), id + " foundation / sign exact")
		var art: Image = load(New.SOURCES[id]).get_image()
		var same := true
		for k in 3: same = same and New._door_frame(k, art, d, id).get_data() == Old._door_frame(k, art, d, id).get_data()
		check(same, id + " all three entrance frames exact")
	Old = null
	New = null
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	root.add_child(town)
	await frames(10)
	var view: Node2D = town._building_exteriors
	check(view.buildings.size() == 7 and view.buildings.has("shrine"), "Yard joins all six finished services")
	var b: Dictionary = view.buildings["yard"]
	check(b["base"].position == Vector2(912, 288) and b["sprite"].texture.get_size() == Vector2(168, 120), "original Yard position and 168x120 footprint")
	check(b["base"].z_index == 0 and not b.has("door"), "open-air ring remains under creatures")
	check(b["sprite"].material.shader == preload("res://scripts/arena/creature_finish.gdshader") and b["sprite"].material.get_shader_parameter("detail_ink") == 1.0, "purposeful shared sel-out detail preset")
	var open := true
	for y in range(12, 17):
		for x in range(38, 45): open = open and town.open_at(Vector2i(x, y))
	check(open, "all 35 original Yard tiles stay walkable")
	check(b["focus"].position.x + 19 < 72, "target sign sits beside the north activation tile")
	var src: Image = b["sprite"].texture.get_image()
	check(src.get_pixel(0, 0).a < 0.1 and src.get_pixel(167, 119).a < 0.1, "transparent corners show real town ground")
	check(b["frames"][0].get_image().get_data() != b["frames"][1].get_image().get_data() and b["frames"][1].get_image().get_data() != b["frames"][2].get_image().get_data(), "target sign has three distinct response states")
	# Compare the actual native shader output, not a shader-name-only assertion.
	var proof := SubViewport.new()
	proof.size = Vector2i(336, 120)
	proof.transparent_bg = true
	proof.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(proof)
	for k in 2:
		var s := Sprite2D.new()
		s.centered = false
		s.position.x = k * 168
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.texture = b["sprite"].texture
		preload("res://scripts/arena/creature_finish.gd").apply(s, k == 1)
		proof.add_child(s)
	await frames(3)
	await RenderingServer.frame_post_draw
	var rendered := proof.get_texture().get_image()
	var dark := [0, 0]
	for k in 2:
		for y in range(8, 112):
			for x in range(8, 160):
				var c := rendered.get_pixel(x + k * 168, y)
				if c.a > 0.9 and maxf(c.r, maxf(c.g, c.b)) < 0.12: dark[k] += 1
	check(dark[1] > dark[0] + 20, "native render adds black internal stone / root / ring detail")
	print("Native detail ink pixels ", dark)
	proof.queue_free()
	town.team[0]["pos"] = Vector2i(41, 11)
	town.team[0]["facing"] = "s"
	town._place(town.team[0])
	await frames(2)
	await town.act_move(Vector2i.DOWN)
	check(town.team[0]["pos"] == Vector2i(41, 12), "walk reaches unchanged north Yard activation tile")
	await key(KEY_E)
	check(town.panel.get("id", "") == "yard" and town.panel.get("service", "") == "arena" and town.last_sfx == "door", "native E retains arena description / service sound")
	await frames(3)
	check(b["frame"] == 1, "target sign transitions through its middle state")
	await frames(8)
	check(b["frame"] == 2, "target sign brightens with open service")
	await snap("yard_service")
	await key(KEY_ESCAPE)
	await frames(12)
	check(town.panel.is_empty() and b["frame"] == 0, "Esc closes service and settles target sign")
	town.team[0]["pos"] = Vector2i(41, 11)
	town._place(town.team[0])
	await key(KEY_E)
	check(town.panel.get("id", "") == "yard", "native E works from the north approach")
	await key(KEY_ESCAPE)
	await frames(12)
	town.team[0]["pos"] = Vector2i(41, 14)
	town._place(town.team[0])
	await town.act_move(Vector2i.RIGHT)
	await town.act_move(Vector2i.LEFT)
	check(town.team[0]["pos"] == Vector2i(41, 14), "leader actually walks across the practice ring")
	town.set_process(false)
	town._world.position = Vector2(-768, -240)
	await frames(3)
	await snap("yard_exterior")
	view.set_process(false)
	b["focus"].texture = b["frames"][2]
	await frames(3)
	await snap("yard_active_sign")
	town.queue_free()
	await frames(4)
	print("RESULT ", checks, " checks, ", bad, " failures")
	quit(0 if bad == 0 else 1)
