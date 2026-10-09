extends SceneTree
func _initialize() -> void: _run.call_deferred()
func frames(n: int) -> void:
    for i in n: await process_frame
func _run() -> void:
    var args := OS.get_cmdline_user_args()
    var out: String = args[0]
    DirAccess.make_dir_recursive_absolute(out)
    root.size = Vector2i(1152,864)
    root.content_scale_size = Vector2i(1152,864)
    var journey: Node2D
    if "direct" in args:
        var direct: Node2D = load("res://scenes/city_riverfront.tscn").instantiate()
        root.add_child(direct)
        current_scene = direct
        await frames(35)
        journey = current_scene
        assert(journey.active_id == "riverfront")
        assert(journey.active_area.quay_activity != null)
        assert(journey.active_area.get_node("Player").is_physics_processing())
        print("Direct F6 preview: 3 assertions passed")
    else:
        journey = load("res://scenes/world_journey.tscn").instantiate()
        journey.initial_area = "riverfront"
        root.add_child(journey)
        current_scene = journey
        await frames(35)
    var player: CharacterBody2D = journey.active_area.get_node("Player")
    var camera: Camera2D = player.get_node("Camera2D")
    player.position = Vector2(512,384)
    camera.position = Vector2.ZERO
    camera.zoom = Vector2(1.125,1.125)
    journey.get_node("RouteHUD").hide()
    await frames(5)
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(out+"/overview.png")
    root.size = Vector2i(1152,648)
    root.content_scale_size = Vector2i(1152,648)
    camera.zoom = Vector2(3,3)
    camera.position = Vector2(0,-24)
    journey.get_node("RouteHUD").show()
    for spot in [["arrival",Vector2(324,512)],["landing",Vector2(192,336)],["branch",Vector2(512,428)],["garden",Vector2(632,684)],["workshop",Vector2(768,320)]]:
        player.position = spot[1]
        camera.reset_smoothing()
        await frames(5)
        await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png(out+"/"+spot[0]+".png")
    journey.queue_free()
    await frames(4)
    quit()
