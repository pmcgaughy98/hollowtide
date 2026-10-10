extends SceneTree
const Layout = preload("res://scripts/town/town_layout.gd")
const Ground = preload("res://scripts/town/highbank_ground_painter.gd")
const Town = preload("res://scripts/town/hub_town.gd")
const OUT = "D:/dev/hollowtide-wayline-hall-20261009/review/"
var passes = 0
var failures = 0

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, text: String) -> void:
	if ok: passes += 1; print("PASS ",text)
	else: failures += 1; push_error(text)

func frames(n: int) -> void:
	for k in n: await process_frame

func capture(name: String) -> void:
	await frames(4)
	root.get_texture().get_image().save_png(OUT + name + ".png")

func _run() -> void:
	var grid = Layout.grid()
	var before = load("res://tools/debug/hall_ground_before.gd").paint(Town.paint_blockout())
	var after = Town.paint()
	var art: Image = load("res://assets/sprites/world/wayline_hall_2026_10_09/wayline_hall_native.png").get_image()
	var hall: Rect2i = Rect2i(456,24,240,144)
	check(art.get_size() == hall.size, "Art matches the 240x144 layout footprint")
	check(after.get_size() == Vector2i(1152,768), "Complete native map dimensions retained")
	check(before.get_region(hall).get_data() != after.get_region(hall).get_data(), "Actual hall rectangle replaced")
	var outside_exact = true
	for r in [Rect2i(0,0,1152,24),Rect2i(0,168,1152,600),Rect2i(0,24,456,144),Rect2i(696,24,456,144)]:
		outside_exact = outside_exact and before.get_region(r).get_data() == after.get_region(r).get_data()
	check(outside_exact, "Every town pixel outside the hall remains byte-exact")
	check(Layout.grid() == grid, "No collision, path, door or layout mutation")
	check(art.get_pixel(132,126).a > 0.9, "Walkable door centre lands inside the solid entrance art")
	check(art.get_pixel(132,126).r < 0.5, "Walkable door centre is the dark recess")
	check(Town.paint().get_data() == after.get_data(), "Repeatable rendering")
	before.save_png(OUT + "town_before.png")
	after.save_png(OUT + "town_after.png")
	after.get_region(Rect2i(384,0,384,216)).save_png(OUT + "hall_surroundings_native.png")
	var town = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await frames(5)
	town.team[0].pos = Vector2i(24,8); town._place(town.team[0])
	town.team[1].pos = Vector2i(23,8); town._place(town.team[1])
	await capture("hall_approach")
	await town.act_move(Vector2i(0,-1))
	check(town.team[0].pos == Vector2i(24,7), "Actual movement reaches the hall approach")
	var key = InputEventKey.new()
	key.keycode = KEY_E; key.physical_keycode = KEY_E; key.pressed = true
	Input.parse_input_event(key)
	await frames(1); town._poll()
	key.pressed = false; Input.parse_input_event(key)
	check(town.panel.get("id","") == "hall", "Native E input facing the doorway opens the existing guild service")
	await capture("hall_service")
	town.panel = {}
	await town.act_move(Vector2i(0,-1))
	check(town.team[0].pos == Vector2i(24,6), "Actual movement enters the exact door tile")
	check(not town.open_at(Vector2i(23,6)) and not town.open_at(Vector2i(25,6)), "Adjacent facade tiles remain solid")
	check(town.team[0].sprite.material != null, "Existing creature finish remains applied")
	# Review composition only: show the full exterior; normal camera screenshots are above.
	town.set_process(false)
	town._world.position = Vector2(-384,0)
	town._labels.hide()
	town._hud.hide()
	await capture("hall_overview")
	print("HALL_RESULT passes=%d failures=%d" % [passes,failures])
	quit(1 if failures else 0)
