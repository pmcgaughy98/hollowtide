extends SceneTree
const Layout = preload("res://scripts/town/town_layout.gd")
const Town = preload("res://scripts/town/hub_town.gd")
const OUT = "D:/dev/hollowtide-highbank-ground-20261009/review/"
var passes := 0
var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, description: String) -> void:
	if ok: passes += 1; print("PASS ", description)
	else: failures += 1; push_error(description)

func frames(n: int) -> void:
	for k in n: await process_frame

func save(name: String) -> void:
	await frames(4)
	root.get_texture().get_image().save_png(OUT + name + ".png")

func _run() -> void:
	var grid_before = Layout.grid()
	var old = Town.paint_blockout()
	var img = Town.paint()
	check(img.get_size() == Vector2i(1152,768), "Native map dimensions")
	check(img.get_format() == Image.FORMAT_RGBA8, "Native opaque RGBA surface")
	check(Layout.grid() == grid_before, "Painter leaves the walkable grid exact")
	var identical = true
	for p in Layout.PLACES:
		if p.kind == "area": continue
		var px = Rect2i(p.rect.position * 24, p.rect.size * 24)
		if old.get_region(px).get_data() != img.get_region(px).get_data(): identical = false
	check(identical, "All existing building and spot pixels preserved")
	check(Town.paint().get_data() == img.get_data(), "Repeatable native texture without flicker")
	check(img.get_region(Rect2i(96,216,240,48)).get_data() != old.get_region(Rect2i(96,216,240,48)).get_data(), "Market Street has replaced flat paving")
	img.save_png(OUT + "ground_full.png")
	old.save_png(OUT + "blockout_full.png")
	var town = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await save("home_native")
	check(town.team[0].sprite.material != null, "Town creatures keep shared finish")
	# Actual native key state goes through Claude's existing polling path.
	var at: Vector2i = town.team[0].pos
	var key = InputEventKey.new()
	key.keycode = KEY_D; key.physical_keycode = KEY_D; key.pressed = true
	Input.parse_input_event(key)
	await frames(1)
	town._poll()
	key.pressed = false; Input.parse_input_event(key)
	await frames(8)
	check(town.team[0].pos == at + Vector2i(1,0), "Native D input walks the existing town")
	for target in [Vector2i(24,8),Vector2i(24,17),Vector2i(14,23),Vector2i(30,28)]:
		town.team[0].pos = target; town._place(town.team[0])
		town.team[1].pos = target + Vector2i(-1,0); town._place(town.team[1])
		await save("view_%d_%d" % [target.x,target.y])
	# Walk both crossings with the real movement routine, so painted stairs cannot mask a block.
	for pair in [[Vector2i(24,17),Vector2i(0,1)],[Vector2i(14,23),Vector2i(0,1)]]:
		town.team[0].pos = pair[0]; town._place(town.team[0])
		await town.act_move(pair[1])
		check(town.team[0].pos == pair[0] + pair[1], "Cliff crossing at " + str(pair[0]))
	# Walls and water remain walls. Every original service door remains open.
	check(not town.open_at(Vector2i(22,18)) and not town.open_at(Vector2i(13,24)), "Cliff faces still block")
	check(not town.open_at(Vector2i(25,30)), "River still blocks")
	var doors = true
	for p in Layout.PLACES: doors = doors and town.open_at(p.door)
	check(doors, "All 13 doors remain open")
	print("GROUND_RESULT passes=%d failures=%d" % [passes,failures])
	quit(1 if failures > 0 else 0)
