extends SceneTree
const OUT := "D:/dev/hollowtide-selout-scroll-20261010/review/"
const Layout = preload("res://scripts/town/town_layout.gd")
const State = preload("res://scripts/town/team_state.gd")
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
	Input.parse_input_event(e)
	await frames(1)
func snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + name + ".png")
func _run() -> void:
	var before: Image = load("D:/dev/hollowtide-selout-scroll-20261010/baseline_hub.gd").paint()
	var after: Image = load("res://scripts/town/hub_town.gd").paint()
	var outside := 0
	for y in after.get_height():
		for x in after.get_width():
			if not Rect2i(742, 264, 148, 146).has_point(Vector2i(x, y)) and before.get_pixel(x, y) != after.get_pixel(x, y): outside += 1
	check(outside == 0, "all ground outside new Scroll Keeper exact (shrine ground retained)")
	var Old = load("D:/dev/hollowtide-selout-scroll-20261010/originals/scripts/town/building_exteriors.gd")
	var New = load("res://scripts/town/building_exteriors.gd")
	for id in ["home", "shop", "hall", "storage"]:
		var p: Dictionary = Layout.PLACES.filter(func(v: Dictionary) -> bool: return v["id"] == id)[0]
		var first: Vector2i = p["door"]
		for tile in Layout.door_tiles(p): first.x = mini(first.x, tile.x)
		var d: Vector2i = (first - p["rect"].position) * 24
		var w: int = Layout.door_tiles(p).size() * 24
		check(New._details(p["rect"].size * 24, d, id, w).get_data() == Old._details(p["rect"].size * 24, d, id, w).get_data(), id + " foundation / sign exact")
		var art: Image = load(New.SOURCES[id]).get_image()
		var same := true
		for k in 3: same = same and New._door_frame(k, art, d, id).get_data() == Old._door_frame(k, art, d, id).get_data()
		check(same, id + " three door textures exact")
	Old = null
	New = null
	State.start([[0, 0], [1, 0]])
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	root.add_child(town)
	await frames(8)
	var b: Dictionary = town._building_exteriors.buildings["shrine"]
	check(town._building_exteriors.buildings.size() == 6, "shrine joins the finished four")
	check(b["base"].position == Vector2(96, 288) and b["sprite"].texture.get_size() == Vector2(144, 120), "original open area footprint retained")
	check(b["base"].z_index == 0 and not b.has("door"), "walkable clearing stays beneath creatures with no fake door")
	check(b["sprite"].material.shader == preload("res://scripts/arena/creature_finish.gdshader") and b["sprite"].material.get_shader_parameter("detail_ink") == 1.0, "same purposeful silhouette / internal ink finish")
	var open := true
	for y in range(12, 17):
		for x in range(4, 10): open = open and town.open_at(Vector2i(x, y))
	check(open, "all thirty shrine tiles remain walkable")
	var src: Image = b["sprite"].texture.get_image()
	check(src.get_pixel(0, 0).a < 0.1 and src.get_pixel(143, 119).a < 0.1, "transparent corners expose actual ground")
	town.team[0]["pos"] = Vector2i(7, 11)
	town.team[0]["facing"] = "s"
	town._place(town.team[0])
	await frames(2)
	await town.act_move(Vector2i.DOWN)
	check(town.team[0]["pos"] == Vector2i(7, 12), "walking from Market Street reaches original activation tile")
	await key(KEY_E)
	await frames(10)
	check(town.panel.get("service", "") == "growth" and String(town.panel.get("what", "")).contains("No one is ready"), "native E uses Claude's not-ready response")
	check(b["frame"] == 2, "inlay activates despite shrine panel having no place ID")
	await snap("shrine_not_ready")
	await key(KEY_ESCAPE)
	await frames(10)
	check(town.panel.is_empty() and b["frame"] == 0, "Esc clears service and settles inlay")
	var c: Dictionary = load("res://scripts/dungeon/dungeon.gd").get_script_constant_map()
	var rule: Dictionary = c["EVO"][0]
	State.data["levels"] = {0: {"lv": c["EVO_LEVEL"][0], "exp": 0}}
	State.data["growth"] = {"0:0": {"kos": rule["kos"][0], "floors": rule["floors"][0], "flank": rule["need"][0]}}
	await key(KEY_E)
	await frames(10)
	check(town.panel.get("service", "") == "evolve_ask" and String(town.panel.get("what", "")).contains("Kithflare is ready"), "actual readiness reads existing rules and native E confirmation")
	await snap("shrine_ready")
	await key(KEY_ESCAPE)
	await frames(10)
	check(State.data["party"][0] == [0, 0] and not town.evolving_now, "cancel keeps original creature and record")
	town.team[0]["pos"] = Vector2i(7, 11)
	town._place(town.team[0])
	await key(KEY_E)
	check(town.panel.get("service", "") == "evolve_ask", "north approach also answers native E")
	await key(KEY_ESCAPE)
	town.set_process(false)
	town._world.position = Vector2(0, -216)
	await frames(2)
	await snap("shrine_exterior")
	town.queue_free()
	await frames(4)
	print("RESULT ", checks, " checks, ", bad, " failures")
	quit(0 if bad == 0 else 1)
