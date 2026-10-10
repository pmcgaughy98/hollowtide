extends SceneTree
const Layout = preload("res://scripts/town/town_layout.gd")
const Ground = preload("res://scripts/town/highbank_ground_painter.gd")
const Town = preload("res://scripts/town/hub_town.gd")
const OUT = "D:/dev/hollowtide-shop-20261009/review/"
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
	var before = load("res://tools/debug/shop_ground_before.gd").paint(Town.paint_blockout())
	var after = Town.paint()
	var art: Image = load("res://assets/sprites/world/item_shop_2026_10_09/item_shop_native.png").get_image()
	var shop: Rect2i = Rect2i(744,72,144,120)
	check(art.get_size() == shop.size, "Art matches the 144x120 layout footprint")
	check(after.get_size() == Vector2i(1152,768), "Complete native map dimensions retained")
	check(before.get_region(shop).get_data() != after.get_region(shop).get_data(), "Actual shop rectangle replaced")
	var outside_exact = true
	for r in [Rect2i(0,0,1152,72),Rect2i(0,72,744,96),Rect2i(888,72,264,96),Rect2i(0,168,552,24),Rect2i(624,168,120,24),Rect2i(888,168,264,24),Rect2i(0,192,552,26),Rect2i(624,192,528,26),Rect2i(0,218,1152,550)]:
		outside_exact = outside_exact and before.get_region(r).get_data() == after.get_region(r).get_data()
	check(outside_exact, "Every pixel outside Shop and the widened Hall approach remains byte-exact")
	check(Layout.grid() == grid, "No collision, path, door or layout mutation")
	check(art.get_pixel(60,108).a > 0.9, "Walkable door centre lands inside the solid entrance art")
	check(art.get_pixel(60,108).r < 0.5, "Walkable door centre is the dark recess")
	check(Town.paint().get_data() == after.get_data(), "Repeatable rendering")
	before.save_png(OUT + "town_before.png")
	after.save_png(OUT + "town_after.png")
	after.get_region(Rect2i(648,24,384,216)).save_png(OUT + "shop_surroundings_native.png")
	var town = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await frames(5)
	town.team[0].pos = Vector2i(33,9); town._place(town.team[0])
	town.team[1].pos = Vector2i(32,9); town._place(town.team[1])
	await capture("shop_approach")
	await town.act_move(Vector2i(0,-1))
	check(town.team[0].pos == Vector2i(33,8), "Actual movement reaches the shop approach")
	var key = InputEventKey.new()
	key.keycode = KEY_E; key.physical_keycode = KEY_E; key.pressed = true
	Input.parse_input_event(key)
	await frames(1); town._poll()
	key.pressed = false; Input.parse_input_event(key)
	check(town.panel.get("id","") == "shop", "Native E input facing the doorway opens the existing shop service")
	await capture("shop_service")
	town.panel = {}
	await town.act_move(Vector2i(0,-1))
	check(town.team[0].pos == Vector2i(33,7), "Actual movement enters the exact door tile")
	check(not town.open_at(Vector2i(32,7)) and not town.open_at(Vector2i(34,7)), "Adjacent facade tiles remain solid")
	check(town.team[0].sprite.material != null, "Existing creature finish remains applied")
	# Review composition only: show the full exterior; normal camera screenshots are above.
	town.set_process(false)
	town._world.position = Vector2(-648,-24)
	town._labels.hide()
	town._hud.hide()
	await capture("shop_overview")
	print("SHOP_RESULT passes=%d failures=%d" % [passes,failures])
	quit(1 if failures else 0)
