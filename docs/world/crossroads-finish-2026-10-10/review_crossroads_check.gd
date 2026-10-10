extends SceneTree
const OUT := "D:/dev/hollowtide-crossroads-20261010/review/"
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
	var before: Image = load("D:/dev/hollowtide-crossroads-20261010/baseline_hub.gd").paint()
	var after: Image = load("res://scripts/town/hub_town.gd").paint()
	var outside := 0
	var inside := 0
	var allowed := Rect2i(432, 264, 288, 144)
	for y in after.get_height():
		for x in after.get_width():
			if after.get_pixel(x, y) != before.get_pixel(x, y):
				if allowed.has_point(Vector2i(x, y)): inside += 1
				else: outside += 1
	check(outside == 0 and inside > 100, "ground changes are visible and confined to Crossroads footprint")
	var Old = load("D:/dev/hollowtide-crossroads-20261010/originals/scripts/town/building_exteriors.gd")
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
	var lane: Image = load("D:/dev/hollowtide-crossroads-20261010/lane_hub.gd").paint()
	var path_same := true
	for y in range(264, 408):
		for x in range(552, 600):
			path_same = path_same and after.get_pixel(x, y) == lane.get_pixel(x, y)
	check(path_same, "all 6912 authored ferry-lane ground pixels exact, including street / south joins")
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	root.add_child(town)
	await frames(10)
	var view: Node2D = town._building_exteriors
	check(view.buildings.size() == 9 and view.buildings.has("board") and view.buildings.has("shrine") and view.buildings.has("yard"), "Crossroads joins all eight previous finished services")
	var b: Dictionary = view.buildings["plaza"]
	check(b["base"].position == Vector2(576, 336) and b["sprite"].texture.get_size() == Vector2(24, 24), "waymark on exact activation tile (24,14), native 24x24")
	check(b["base"].z_index == 0 and not b.has("door"), "flat floor inlay stays below creatures, no false upright door")
	check(b["sprite"].material.shader == preload("res://scripts/arena/creature_finish.gdshader") and b["sprite"].material.get_shader_parameter("detail_ink") == 1.0, "shared purposeful sel-out detail preset")
	var open := true
	for y in range(11,17):
		for x in range(18,30): open = open and town.open_at(Vector2i(x,y))
	check(open, "all 72 plaza tiles remain walkable")
	var src: Image = b["sprite"].texture.get_image()
	check(src.get_pixel(0,0).a == 0.0 and src.get_pixel(23,23).a == 0.0, "inlay transparent corners show authored lane")
	check(b["frames"][0].get_image().get_data() != b["frames"][1].get_image().get_data() and b["frames"][1].get_image().get_data() != b["frames"][2].get_image().get_data(), "three distinct quiet carved-inlay response states")
	var proof := SubViewport.new()
	proof.size = Vector2i(48,24)
	proof.transparent_bg = true
	proof.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(proof)
	for k in 2:
		var s := Sprite2D.new()
		s.centered = false
		s.position.x = k * 24
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.texture = b["sprite"].texture
		preload("res://scripts/arena/creature_finish.gd").apply(s,k == 1)
		proof.add_child(s)
	await frames(3)
	await RenderingServer.frame_post_draw
	var rendered := proof.get_texture().get_image()
	rendered.save_png(OUT + "waymark_native_finish.png")
	var dark := [0,0]
	for k in 2:
		for y in range(5,20):
			for x in range(3,21):
				var c := rendered.get_pixel(x + k * 24,y)
				if c.a > 0.9 and maxf(c.r,maxf(c.g,c.b)) < 0.12: dark[k] += 1
	check(dark[1] > dark[0], "actual native sel-out strengthens interior limestone joints")
	print("Native detail ink pixels ",dark)
	proof.queue_free()
	for k in 3: b["frames"][k].get_image().save_png(OUT + "waymark_frame_" + str(k) + ".png")
	town.team[0]["pos"] = Vector2i(24,13)
	town.team[0]["facing"] = "s"
	town._place(town.team[0])
	await frames(2)
	await town.act_move(Vector2i.DOWN)
	check(town.team[0]["pos"] == Vector2i(24,14), "native walk reaches exact Crossroads activation tile")
	var sound_before: String = town.last_sfx
	await key(KEY_E)
	check(town.panel.get("id", "") == "plaza" and town.panel.get("service", "") == "waymark", "native E opens original Crossroads waymark description")
	check(town.last_sfx == sound_before, "waymark retains original quiet service, no added door sound")
	await frames(3)
	check(b["frame"] == 1, "carved inlay transitions through middle state")
	await frames(8)
	check(b["frame"] == 2, "carved glyph brightens with existing open waymark panel")
	await snap("crossroads_service")
	await key(KEY_ESCAPE)
	await frames(12)
	check(town.panel.is_empty() and b["frame"] == 0, "Esc closes service and settles carved waymark")
	town.team[0]["pos"] = Vector2i(24,13)
	town._place(town.team[0])
	await key(KEY_E)
	check(town.panel.get("id", "") == "plaza", "native E works facing waymark from north approach")
	await key(KEY_ESCAPE)
	await frames(12)
	town.team[0]["pos"] = Vector2i(24,14)
	town._place(town.team[0])
	await town.act_move(Vector2i.LEFT)
	await town.act_move(Vector2i.RIGHT)
	check(town.team[0]["pos"] == Vector2i(24,14), "leader crosses unchanged two-tile ferry lane")
	# Exercise Claude's current Board service, whose panel has a service but no place id.
	town.team[0]["pos"] = Vector2i(26,8)
	town.team[0]["facing"] = "n"
	town._place(town.team[0])
	await key(KEY_E)
	check(town.panel.get("service", "") == "board" and town.last_sfx == "board_paper", "current working jobs panel retains paper sound and controller")
	await frames(12)
	check(view.buildings["board"]["frame"] == 2, "Board reading feedback responds to Claude's panel without place id")
	await key(KEY_ESCAPE)
	await frames(12)
	check(town.panel.is_empty() and view.buildings["board"]["frame"] == 0, "current jobs panel closes and previous Board feedback settles")
	town.set_process(false)
	town.team[0]["pos"] = Vector2i(23,16)
	town.team[1]["pos"] = Vector2i(23,15)
	town._place(town.team[0])
	town._place(town.team[1])
	town._world.position = Vector2(-384,-216)
	await frames(3)
	await snap("crossroads_exterior")
	view.set_process(false)
	b["sprite"].texture = b["frames"][2]
	await frames(3)
	await snap("crossroads_inlay_active")
	town.queue_free()
	await frames(4)
	print("RESULT ",checks," checks, ",bad," failures")
	quit(0 if bad == 0 else 1)
