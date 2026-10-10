extends SceneTree
const OUT = "D:/dev/hollowtide-shop-20261009/review/"
var passes = 0
var failures = 0
func _initialize() -> void:
    _run.call_deferred()
func check(ok: bool, label: String) -> void:
    if ok: passes += 1; print("PASS ",label)
    else: failures += 1; push_error(label)
func frames(n: int) -> void:
    for k in n: await process_frame
func _run() -> void:
    var town_script = load("res://scripts/town/hub_town.gd")
    var old: Image = load("res://tools/debug/shop_ground_before.gd").paint(town_script.paint_blockout())
    var current: Image = town_script.paint()
    check(current.get_region(Rect2i(456,24,240,144)).get_data() == old.get_region(Rect2i(456,24,240,144)).get_data(), "Hall exterior remains byte-exact")
    check(current.get_region(Rect2i(600,168,24,48)).get_data() != old.get_region(Rect2i(600,168,24,48)).get_data(), "East strip is visibly paved beside the door")
    var town = load("res://scenes/hub_town.tscn").instantiate()
    town.poll_input = false; root.add_child(town)
    await frames(5)
    check(town.open_at(Vector2i(25,7)) and town.open_at(Vector2i(25,8)), "Widened strip was already walkable")
    town.team[0].pos = Vector2i(25,8); town._place(town.team[0])
    town.team[1].pos = Vector2i(25,9); town._place(town.team[1])
    await town.act_move(Vector2i(-1,0))
    await town.act_move(Vector2i(0,-1))
    check(town.team[0].pos == Vector2i(24,7), "Real movement from wider apron reaches doorway approach")
    var key = InputEventKey.new()
    key.keycode = KEY_E; key.physical_keycode = KEY_E; key.pressed = true
    Input.parse_input_event(key); await frames(1); town._poll()
    key.pressed = false; Input.parse_input_event(key)
    check(town.panel.get("id","") == "hall", "Native E still opens Hall from centred approach")
    await frames(4)
    root.get_texture().get_image().save_png(OUT+"hall_widened_service.png")
    town.panel = {}; await town.act_move(Vector2i(0,-1))
    check(town.team[0].pos == Vector2i(24,6), "Unchanged Hall door remains enterable")
    town.set_process(false); town._world.position = Vector2(-384,0)
    town._labels.hide(); town._hud.hide(); await frames(4)
    root.get_texture().get_image().save_png(OUT+"hall_widened_overview.png")
    print("HALL_APPROACH_RESULT passes=%d failures=%d" % [passes,failures])
    quit(1 if failures else 0)
