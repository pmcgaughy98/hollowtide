extends SceneTree
const OUT:="C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/hometown-neighborhood-2026-10-04/render/"
func _initialize()->void:call_deferred("_run")
func frames(n:int)->void:
    for i in n:await process_frame
func _run()->void:
    for entry in [["hometown",Vector2i(1024,768),Vector2(512,384)],["riverfront",Vector2i(1024,768),Vector2(512,384)],["historic_street",Vector2i(768,896),Vector2(384,448)],["route1",Vector2i(1472,640),Vector2(-32,320)]]:
        var view:=SubViewport.new()
        view.size=entry[1];view.world_2d=World2D.new();view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
        root.add_child(view)
        var journey:Node2D=load("res://scenes/world_journey.tscn").instantiate()
        journey.initial_area=entry[0];view.add_child(journey)
        await frames(45)
        journey.get_node("RouteHUD").hide()
        var courier:CharacterBody2D=journey.active_area.get_node("Player")
        courier.get_node("Camera2D").enabled=false
        var cam:=Camera2D.new();cam.position=entry[2];cam.zoom=Vector2.ONE
        view.add_child(cam);cam.make_current()
        await frames(12);await RenderingServer.frame_post_draw
        view.get_texture().get_image().save_png(OUT+"final-"+entry[0]+"-native.png")
        print("GRASS_NATIVE_RENDER ",entry[0])
        view.queue_free();journey=null
        await frames(10)
    quit()
