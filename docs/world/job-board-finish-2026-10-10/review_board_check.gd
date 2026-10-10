extends SceneTree
const OUT := "D:/dev/hollowtide-job-board-20261010/review/"
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
	var before: Image = load("D:/dev/hollowtide-job-board-20261010/baseline_hub.gd").paint()
	var after: Image = load("res://scripts/town/hub_town.gd").paint()
	var outside := 0
	var inside := 0
	var allowed := Rect2i(624, 168, 50, 48)
	for y in after.get_height():
		for x in after.get_width():
			if after.get_pixel(x, y) != before.get_pixel(x, y):
				if allowed.has_point(Vector2i(x, y)): inside += 1
				else: outside += 1
	check(outside == 0 and inside > 100, "ground changes are visible and confined to Board / reading spot")
	var Old = load("D:/dev/hollowtide-job-board-20261010/originals/scripts/town/building_exteriors.gd")
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
	check(view.buildings.size() == 8 and view.buildings.has("shrine"), "Board joins all seven finished services")
	var b: Dictionary = view.buildings["board"]
	check(b["base"].position == Vector2(624, 168) and b["sprite"].texture.get_size() == Vector2(48, 24), "original Board position and 48x24 footprint")
	check(b["base"].z_index == 191 and b["pad"].z_index == 0 and not b.has("door"), "board foot sorts behind south reader; reading feedback is ground-level")
	check(b["sprite"].material.shader == preload("res://scripts/arena/creature_finish.gdshader") and b["sprite"].material.get_shader_parameter("detail_ink") == 1.0, "purposeful shared sel-out detail preset")
	check(town.open_at(Vector2i(26, 7)) and town.open_at(Vector2i(27, 7)) and town.open_at(Vector2i(26, 8)), "all original Board / reading tiles stay walkable")
	check(b["pad"].position == Vector2(624, 192), "response corners frame the exact reading tile")
	var src: Image = b["sprite"].texture.get_image()
	check(src.get_pixel(0, 0).a < 0.1 and src.get_pixel(47, 23).a < 0.1, "transparent corners show real town ground")
	check(b["frames"][0].get_image().get_data() != b["frames"][1].get_image().get_data() and b["frames"][1].get_image().get_data() != b["frames"][2].get_image().get_data(), "reading-pad corners has three distinct response states")
	# Compare the actual native shader output, not a shader-name-only assertion.
	var proof := SubViewport.new()
	proof.size = Vector2i(96, 24)
	proof.transparent_bg = true
	proof.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(proof)
	for k in 2:
		var s := Sprite2D.new()
		s.centered = false
		s.position.x = k * 48
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.texture = b["sprite"].texture
		preload("res://scripts/arena/creature_finish.gd").apply(s, k == 1)
		proof.add_child(s)
	await frames(3)
	await RenderingServer.frame_post_draw
	var rendered := proof.get_texture().get_image()
	var dark := [0, 0]
	for k in 2:
		for y in range(3, 22):
			for x in range(3, 45):
				var c := rendered.get_pixel(x + k * 48, y)
				if c.a > 0.9 and maxf(c.r, maxf(c.g, c.b)) < 0.12: dark[k] += 1
	check(dark[1] > dark[0] + 5, "native render adds black internal timber / paper / moss contours")
	print("Native detail ink pixels ", dark)
	proof.queue_free()
	town.team[0]["pos"] = Vector2i(26, 9)
	town.team[0]["facing"] = "n"
	town._place(town.team[0])
	await frames(2)
	await town.act_move(Vector2i.UP)
	check(town.team[0]["pos"] == Vector2i(26, 8), "walk reaches unchanged south Board reading tile")
	await key(KEY_E)
	check(town.panel.get("id", "") == "board" and town.panel.get("service", "") == "jobs" and town.last_sfx == "board_paper", "native E retains jobs description / paper-rustle sound")
	await frames(3)
	check(b["frame"] == 1, "reading-pad corners transitions through its middle state")
	await frames(8)
	check(b["frame"] == 2, "reading-pad corners brightens with open service")
	await snap("board_service")
	await key(KEY_ESCAPE)
	await frames(12)
	check(town.panel.is_empty() and b["frame"] == 0, "Esc closes service and settles reading-pad corners")
	town.team[0]["pos"] = Vector2i(26, 9)
	town._place(town.team[0])
	await key(KEY_E)
	check(town.panel.get("id", "") == "board", "native E works from the south approach")
	await key(KEY_ESCAPE)
	await frames(12)
	town.team[0]["pos"] = Vector2i(26, 8)
	town._place(town.team[0])
	await town.act_move(Vector2i.RIGHT)
	await town.act_move(Vector2i.LEFT)
	check(town.team[0]["pos"] == Vector2i(26, 8), "leader walks across the original reading approach")
	town.set_process(false)
	town._world.position = Vector2(-432, -24)
	await frames(3)
	await snap("board_exterior")
	view.set_process(false)
	b["focus"].texture = b["frames"][2]
	await frames(3)
	await snap("board_reading_active")
	town.queue_free()
	await frames(4)
	print("RESULT ", checks, " checks, ", bad, " failures")
	quit(0 if bad == 0 else 1)
