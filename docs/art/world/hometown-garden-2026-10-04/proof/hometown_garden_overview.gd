extends SceneTree
const OUT:="C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/hometown-garden-2026-10-04/render/"
var journey:Node2D
func _initialize() -> void:
    call_deferred("_run")
func frames(n:int) -> void:
    for i in n:await process_frame
func _run() -> void:
    var view:=SubViewport.new()
    view.size=Vector2i(1024,768)
    view.world_2d=World2D.new()
    view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(view)
    journey=load("res://scenes/world_journey.tscn").instantiate()
    journey.initial_area="hometown"
    view.add_child(journey)
    await frames(45)
    journey.get_node("RouteHUD").hide()
    journey.active_area.get_node("Player/Camera2D").enabled=false
    var camera:=Camera2D.new()
    camera.position=Vector2(512,384)
    camera.zoom=Vector2.ONE
    view.add_child(camera);camera.make_current()
    await frames(15);await RenderingServer.frame_post_draw
    view.get_texture().get_image().save_png(OUT+"garden-initial-hometown-native.png")
    camera.position=Vector2(444,530);camera.zoom=Vector2(3,3)
    view.size=Vector2i(720,480)
    await frames(15);await RenderingServer.frame_post_draw
    view.get_texture().get_image().save_png(OUT+"garden-initial-detail.png")
    view.queue_free();journey=null
    await frames(10);quit()
