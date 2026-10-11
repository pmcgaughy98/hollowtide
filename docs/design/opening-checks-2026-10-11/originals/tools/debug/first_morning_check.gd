extends SceneTree
const OUTPUT := "D:/dev/hollowtide-world-refinement-20261008/review/"
var journey: Node2D
var checks: Array[Dictionary] = []
var failures: Array[String] = []
var model := "Male"
var choice := 0
var tag := ""

func _initialize() -> void: _run.call_deferred()
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
    var args := OS.get_cmdline_user_args()
    if "female" in args: model = "Female"
    if "tallowroot" in args: choice = 1
    if "rimefin" in args: choice = 2
    tag = model.to_lower()+"-"+str(choice)
    DirAccess.make_dir_recursive_absolute(OUTPUT)
    root.size = Vector2i(1152,648)
    root.content_scale_size = Vector2i(1152,648)
    var menu: Node2D = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
    root.add_child(menu)
    current_scene = menu
    await frames(100)
    await key(KEY_ENTER)
    await frames(45)
    verify("Boot reaches approved menu",menu._boot_done and menu._page == "main")
    await click(menu._buttons[0])
    verify("New Game selects appearance only",menu._page == "journey")
    # Finish the menu's background world load before loading a resource it owns.
    for i in 1200:
        if menu._route_scene != null: break
        await frames(1)
    verify("World destination finished loading",menu._route_scene != null)
    var party: Node = root.get_node("PlayerParty")
    party.add(load("res://data/creatures/103_kithflare.tres"))
    var previous: Object = party.active_member()
    await key(KEY_ESCAPE)
    verify("Cancel keeps existing party",party.active_member() == previous and menu._page == "main")
    await click(menu._buttons[0])
    await click(menu._courier_buttons[0 if model == "Male" else 1])
    await click(menu._begin_button)
    for i in 200:
        await frames(1)
        if current_scene != menu and is_instance_valid(current_scene): break
    journey = current_scene
    await frames(50)
    verify("New Game enters hometown before partner selection",journey.active_id == "hometown" and journey.first_morning)
    verify("No fallback or old party before meeting",party.caught.is_empty() and party.active_slot == -1)
    verify("Courier appearance retained",player().chibi_model == model)
    var story: Node = journey.partner_story
    var atlas: CanvasLayer = journey.atlas
    await capture("first-morning")
    await key(KEY_M)
    verify("Map opens and suspends walking",atlas.opened and not player().is_physics_processing())
    var position_before := player().position
    Input.action_press("move_right")
    await frames(20)
    release()
    verify("Held movement does not move under map",player().position == position_before)
    await key(KEY_P)
    await key(KEY_E)
    verify("Map blocks underlying party and dialogue",not journey.route.get("_panel").visible and not journey.route.get("_party_panel").visible)
    verify("Discovery excludes instantiated but unvisited Route 1",journey.visited_areas.size() == 1 and not journey.visited_areas.has("route1"))
    verify("Map reveals adjacent roads without revealing the city",atlas.known("route1") and not atlas.known("riverfront") and atlas._buttons["riverfront"].disabled)
    await click(atlas._buttons["courier_hall"])
    await click(atlas._pin_button)
    verify("Pin points to real hall connection",atlas.pinned == "courier_hall" and atlas.first_hop("courier_hall") == "courier_hall")
    await capture("route-map")
    await key(KEY_ESCAPE)
    verify("Closing map restores walking",not atlas.opened and player().is_physics_processing())
    verify("Walk home lane",await walk(Vector2(224,336)))
    verify("Walk across hometown",await walk(Vector2(560,336)))
    verify("Walk into courier square",await walk(Vector2(560,512)))
    await key(KEY_E)
    verify("Physical map board opens atlas",atlas.opened)
    await key(KEY_M)
    verify("Cross planted square",await walk(Vector2(768,512)))
    await capture("courier-square")
    verify("Hall approach remains clear",await walk(Vector2(768,448)))
    verify("Walk through real hall door",await gate("move_up","courier_hall"))
    verify("Hall adds three original front idles",story._sprites.size() == 3 and story._sprites[choice].texture in story.STARTERS[choice].idle_frames)
    await capture("hall-partners")
    verify("Meet dispatcher in person",await inspect(Vector2(132,148)) and story.introduced)
    verify("No assignment before partnership",not journey.route.pouch_accepted and party.caught.is_empty())
    verify("Collect straps from shelves",await inspect(Vector2(180,182)) and story.straps_collected)
    verify("Reach western aisle",await walk(Vector2(84,182)))
    verify("Meet Kithflare by western shelves",await inspect(Vector2(82,134)))
    verify("Meet Tallowroot by mail bags",await inspect(Vector2(88,178)))
    verify("Reach Rimefin by outgoing mail",await walk(Vector2(154,174)))
    await key(KEY_E)
    verify("All three met before final invitation",story.met.size() == 3 and journey.route.get("_choices").visible)
    await capture("meeting")
    await key(KEY_ESCAPE)
    verify("Keep looking is reversible",not story.completed and party.caught.is_empty() and player().is_physics_processing())
    var spots := [Vector2(82,134),Vector2(88,178),Vector2(154,174)]
    verify("Return to chosen partner",await walk(spots[choice]))
    await key(KEY_E)
    await key(KEY_M)
    verify("Map cannot cover partner invitation",not atlas.opened)
    await key(KEY_ENTER)
    verify("Invitation adds exactly chosen partner",story.completed and party.caught.size() == 1 and party.active_creature() == story.STARTERS[choice])
    await capture("partnership")
    await key(KEY_E)
    verify("Collect existing first delivery",await inspect(Vector2(132,148)) and journey.route.pouch_accepted)
    await key(KEY_P)
    verify("Party panel shows story partner",journey.route.get("_party_panel").visible and story.STARTERS[choice].creature_name in journey.route.get("_party_buttons")[0].text)
    await key(KEY_P)
    verify("Leave hall floor",await walk(Vector2(128,214)))
    verify("Hall exit returns to hometown",await gate("move_down","hometown"))
    verify("Story and discovery persist on return",journey.visited_areas.size() == 2 and story.completed)
    verify("Return to main street",await walk(Vector2(768,512)))
    verify("Clear east departure",await walk(Vector2(988,512)))
    verify("Partner unlocks real levee entrance",await gate("move_right","route1"))
    await key(KEY_M)
    verify("Route 1 supports same atlas",atlas.opened and journey.visited_areas.has("route1") and atlas.known("riverfront"))
    await click(atlas._buttons["riverfront"])
    await click(atlas._pin_button)
    verify("Route guidance names bridge",atlas.first_hop("riverfront") == "riverfront" and "bridge" in atlas.guidance("riverfront"))
    await capture("levee-discovery")
    await key(KEY_M)
    verify("Map preserves first delivery and chosen ownership",journey.route.pouch_accepted and party.caught.size() == 1 and party.active_creature() == story.STARTERS[choice])
    journey.travel("hometown",Vector2(560,512),Vector2.LEFT)
    await frames(60)
    var camera: Camera2D = player().get_node("Camera2D")
    camera.zoom = Vector2.ONE
    root.size = Vector2i(1152,864)
    root.content_scale_size = Vector2i(1152,864)
    journey.get_node("RouteHUD").hide()
    atlas.hide()
    camera.reset_smoothing()
    await frames(5)
    await capture("hometown-overview")
    FileAccess.open(OUTPUT+tag+"-checks.json",FileAccess.WRITE).store_string(JSON.stringify({"model":model,"choice":choice,"checks":checks,"failures":failures},"  "))
    print("RESULT ",checks.size()," checks / ",failures.size()," failures")
    quit(0 if failures.is_empty() else 1)
