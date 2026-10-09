extends SceneTree
const OUTPUT := "D:/dev/hollowtide-texture-consistency-20261008/relay/"
const FLAGS := ["pouch_accepted","levee_entrance_read","city_arrival_registered","city_directions_read","delivered","water_mark_observed","heard_calls","marker_restored","report_done"]
var journey: Node2D
var failures: Array[String] = []
var checks: Array[Dictionary] = []
var model := "Male"

func _initialize() -> void:
    _run()

func frames(count: int) -> void:
    for i in count: await physics_frame

func verify(label: String, okay: bool) -> void:
    checks.append({"check":label,"passed":okay})
    if not okay: failures.append(label)
    print(label, ": ", "PASS" if okay else "FAIL")

func player() -> CharacterBody2D:
    return journey.active_area.get_node("Player")

func snapshot_flags() -> Dictionary:
    var flags := {}
    for name in FLAGS: flags[name] = journey.route.get(name)
    return flags

func release() -> void:
    for action in ["move_left","move_right","move_up","move_down"]: Input.action_release(action)

func walk(to: Vector2) -> bool:
    var origin: String = journey.active_id
    var stuck := 0
    for i in 2000:
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
    print("BLOCKED at ",player().position," for ",to)
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
    root.get_texture().get_image().save_png(OUTPUT+model.to_lower()+"-"+label+".png")

func inspect(at: Vector2) -> bool:
    if not await walk(at): return false
    await key(KEY_E)
    var shown: bool = journey.route.get("_panel").visible
    await key(KEY_E)
    return shown

func _run() -> void:
    DirAccess.make_dir_recursive_absolute(OUTPUT)
    root.size = Vector2i(1152,648)
    if "female" in OS.get_cmdline_user_args(): model = "Female"
    journey = load("res://scenes/world_journey.tscn").instantiate()
    journey.initial_area = "riverfront"
    journey.courier_model = model
    root.add_child(journey)
    current_scene = journey
    await frames(30)
    var route_identity: Node2D = journey.route
    var party_identity: Object = root.get_node("PlayerParty").active_member()
    var before := snapshot_flags()
    verify("Walk riverfront east lane",await walk(Vector2(988,512)))
    await capture("entrance")
    verify("Real gate to relay yard",await gate("move_right","relay_yard"))
    verify("Selected courier retained",player().chibi_model == model)
    var yard: Node2D = journey.active_area
    var camera: Camera2D = player().get_node("Camera2D")
    camera.zoom = Vector2.ONE
    root.size = Vector2i(768,640)
    root.content_scale_size = Vector2i(768,640)
    journey.get_node("RouteHUD").hide()
    camera.reset_smoothing()
    await frames(5)
    await capture("yard-overview")
    camera.zoom = Vector2(3,3)
    root.size = Vector2i(1152,648)
    root.content_scale_size = Vector2i(1152,648)
    journey.get_node("RouteHUD").show()
    camera.reset_smoothing()
    await frames(5)
    verify("Inspect assignment",await inspect(Vector2(208,496)))
    verify("Inspect works bay",await inspect(Vector2(256,288)))
    verify("Walk upper court",await walk(Vector2(400,288)))
    verify("Inspect garden bay",await inspect(Vector2(560,288)))
    await capture("garden-bay")
    verify("Clear loading court",await walk(Vector2(448,288)) and await walk(Vector2(448,496)))
    verify("Inspect bridge bay",await inspect(Vector2(400,496)))
    verify("All three clues recorded",yard.bay_checks.size() == 3)
    verify("Return to relay board",await walk(Vector2(208,496)))
    await key(KEY_E)
    await capture("routing-choice")
    await key(KEY_ENTER)
    verify("Wrong bay keeps handoff open",not yard.sorted and journey.route.get("_panel").visible)
    await key(KEY_E)
    await key(KEY_E)
    await key(KEY_DOWN)
    await key(KEY_ENTER)
    verify("Correct bay completes handoff",yard.sorted)
    await capture("handoff")
    await key(KEY_E)
    verify("Walk quieter loop",await walk(Vector2(208,560)) and await walk(Vector2(640,560)) and await walk(Vector2(640,288)))
    verify("Loop returns to court",await walk(Vector2(448,288)) and await walk(Vector2(208,352)) and await walk(Vector2(176,352)))
    await key(KEY_E)
    await key(KEY_ENTER)
    await frames(8)
    verify("Practice opens above world",journey.has_node("RelayPractice") and journey.process_mode == Node.PROCESS_MODE_DISABLED)
    if journey.has_node("RelayPractice"):
        var picker: Node2D = journey.get_node("RelayPractice").get_child(0)
        var buttons: Array = picker._ui.find_children("*","Button",true,false)
        for button in buttons:
            if "CINDERHIDE" in button.text: await click(button); break
        buttons = picker._ui.find_children("*","Button",true,false)
        for button in buttons:
            if "FUSERN" in button.text: await click(button); break
        buttons = picker._ui.find_children("*","Button",true,false)
        for button in buttons:
            if button.text == "FIGHT": await click(button); break
        await frames(150)
        verify("Current arena runs from yard",picker._arena != null and picker._arena._fighters.size() == 2)
        if picker._arena != null:
            verify("Arena HUD draws above the practice map",picker._arena._hud.get_parent().layer > journey.get_node("RelayPractice").layer)
        await capture("practice-battle")
        await key(KEY_ESCAPE)
        verify("Escape returns to picker",picker._arena == null)
        await key(KEY_ESCAPE)
        verify("Escape returns to same yard",not journey.has_node("RelayPractice") and journey.active_area == yard and yard.sorted)
    verify("Run flags and party preserved",before == snapshot_flags() and root.get_node("PlayerParty").active_member() == party_identity and journey.route == route_identity)
    verify("Return lane walk",await walk(Vector2(176,488)) and await walk(Vector2(28,488)))
    verify("Real gate to branch",await gate("move_left","riverfront"))
    verify("Reenter preserved yard",await gate("move_right","relay_yard"))
    verify("Cached clues and completion retained",journey.active_area == yard and yard.sorted and yard.bay_checks.size() == 3)
    await capture("return")
    var output := FileAccess.open(OUTPUT+model.to_lower()+"-checks.json",FileAccess.WRITE)
    output.store_string(JSON.stringify({"model":model,"checks":checks,"failures":failures},"  "))
    output.close()
    journey.queue_free()
    await frames(5)
    quit(0 if failures.is_empty() else 1)
