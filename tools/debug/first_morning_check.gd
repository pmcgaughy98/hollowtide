extends SceneTree
## Retired entry point; helpers remain for retained courier-world checks.
const OUTPUT := "user://legacy-world-check/"
var journey: Node2D
var checks: Array[Dictionary] = []
var failures: Array[String] = []
var model := "Male"
var choice := 0
var tag := ""

func _initialize() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
    _run.call_deferred()
func frames(count: int) -> void:
    for i in count: await physics_frame
func verify(label: String, passed: bool) -> void:
    checks.append({"check":label,"passed":passed})
    if not passed: failures.append(label)
    print(label,": ","PASS" if passed else "FAIL")
func player() -> CharacterBody2D: return journey.active_area.get_node("Player")
func release() -> void:
    for action in ["move_left","move_right","move_up","move_down"]: Input.action_release(action)
func walk(to: Vector2) -> bool:
    var origin: String = journey.active_id
    var stuck := 0
    for i in 1600:
        if journey.active_id != origin: release(); return false
        var gap := to-player().position
        if gap.length() < 3: release(); await frames(3); return true
        var before := player().position
        for pair in [["move_left",gap.x < -1.4],["move_right",gap.x > 1.4],["move_up",gap.y < -1.4],["move_down",gap.y > 1.4]]:
            if pair[1]: Input.action_press(pair[0])
            else: Input.action_release(pair[0])
        await physics_frame
        stuck = stuck+1 if before.distance_to(player().position) < 0.02 else 0
        if stuck > 40: break
    release()
    print("BLOCKED ",player().position," -> ",to)
    return false
func gate(action: String, destination: String) -> bool:
    Input.action_press(action)
    for i in 160:
        await physics_frame
        if journey.active_id == destination:
            release()
            for j in 80:
                if not journey.transitioning: return true
                await physics_frame
    release()
    return false
func key(code: Key) -> void:
    for down in [true,false]:
        var event := InputEventKey.new()
        event.keycode = code
        event.physical_keycode = code
        event.pressed = down
        Input.parse_input_event(event)
        await frames(3)
func click(button: Button) -> void:
    for down in [true,false]:
        var event := InputEventMouseButton.new()
        event.position = button.get_global_rect().get_center()
        event.global_position = event.position
        event.button_index = MOUSE_BUTTON_LEFT
        event.pressed = down
        Input.parse_input_event(event)
        await frames(3)
func capture(label: String) -> void:
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(OUTPUT+tag+"-"+label+".png")
func inspect(at: Vector2) -> bool:
    if not await walk(at): return false
    await key(KEY_E)
    var shown: bool = journey.route.get("_panel").visible
    await key(KEY_E)
    return shown
func _run() -> void:
    print("RETIRED: first_morning_check tested the pre-pivot human-courier opening; no gameplay assertions ran.")
    print("Use res://tools/debug/opening_flow_check.gd for title -> storm -> soul -> flood talk -> riverbank.")
    print("For later campaign handoffs use flood_talk_check.gd or pilot_chain_check.gd.")
    quit(2) # Distinct non-success status: retirement is never a green gameplay check.
