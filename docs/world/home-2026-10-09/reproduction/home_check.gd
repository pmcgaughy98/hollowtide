extends SceneTree
const Layout = preload("res://scripts/town/town_layout.gd")
const Ground = preload("res://scripts/town/highbank_ground_painter.gd")
const Town = preload("res://scripts/town/hub_town.gd")
const OUT = "D:/dev/hollowtide-home-20261009/review/"
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
	var before = load("res://tools/debug/home_ground_before.gd").paint(Town.paint_blockout())
	var after = Town.paint()
	var art: Image = load("res://assets/sprites/world/home_2026_10_09/home_native.png").get_image()
	var home: Rect2i = Rect2i(72,72,120,120)
	check(art.get_size() == home.size, "Art matches the 120x120 layout footprint")
	check(after.get_size() == Vector2i(1152,768), "Complete native map dimensions retained")
	check(before.get_region(home).get_data() != after.get_region(home).get_data(), "Actual home rectangle replaced")
	var outside_exact = true
	for r in [Rect2i(0,0,1152,72),Rect2i(0,192,1152,576),Rect2i(0,72,72,120),Rect2i(192,72,960,120)]:
		outside_exact = outside_exact and before.get_region(r).get_data() == after.get_region(r).get_data()
	check(outside_exact, "Every town pixel outside the home remains byte-exact")
	check(Layout.grid() == grid, "No collision, path, door or layout mutation")
	check(art.get_pixel(60,108).a > 0.9, "Walkable door centre lands inside the solid entrance art")
	check(art.get_pixel(60,108).r < 0.5, "Walkable door centre is the dark recess")
	check(Town.paint().get_data() == after.get_data(), "Repeatable rendering")
	before.save_png(OUT + "town_before.png")
	after.save_png(OUT + "town_after.png")
	after.get_region(Rect2i(0,24,384,216)).save_png(OUT + "home_surroundings_native.png")
	var town = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await frames(5)
	town.team[0].pos = Vector2i(5,9); town._place(town.team[0])
	town.team[1].pos = Vector2i(4,9); town._place(town.team[1])
	await capture("home_approach")
	await town.act_move(Vector2i(0,-1))
	check(town.team[0].pos == Vector2i(5,8), "Actual movement reaches the home approach")
	var key = InputEventKey.new()
	key.keycode = KEY_E; key.physical_keycode = KEY_E; key.pressed = true
	Input.parse_input_event(key)
	await frames(1); town._poll()
	key.pressed = false; Input.parse_input_event(key)
	check(town.panel.get("id","") == "home", "Native E input facing the doorway opens the existing home service")
	await capture("home_service")
	town.panel = {}
	await town.act_move(Vector2i(0,-1))
	check(town.team[0].pos == Vector2i(5,7), "Actual movement enters the exact door tile")
	check(not town.open_at(Vector2i(4,7)) and not town.open_at(Vector2i(6,7)), "Adjacent facade tiles remain solid")
	check(town.team[0].sprite.material != null, "Existing creature finish remains applied")
	# Review composition only: show the full exterior; normal camera screenshots are above.
	town.set_process(false)
	town._world.position = Vector2(0,-24)
	town._labels.hide()
	town._hud.hide()
	await capture("home_overview")
	print("HOME_RESULT passes=%d failures=%d" % [passes,failures])
	quit(1 if failures else 0)
