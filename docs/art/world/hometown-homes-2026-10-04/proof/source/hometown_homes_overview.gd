extends SceneTree
const OUT := "C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/hometown-homes-2026-10-04/render/"
var records: Array = []
var failed := false
func _initialize() -> void:
    call_deferred("_run")
func frames(n: int) -> void:
    for i in n: await process_frame
func save(view: SubViewport,label: String) -> void:
    await frames(12)
    await RenderingServer.frame_post_draw
    var img: Image = view.get_texture().get_image()
    var error := img.save_png(OUT+label+".png")
    if error != OK: failed=true
    records.append({"capture":label,"save_error":error,"size":str(img.get_size())})
func _run() -> void:
    var view := SubViewport.new()
    view.size=Vector2i(1024,768)
    view.world_2d=World2D.new()
    view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(view)
    var journey: Node2D=load("res://scenes/world_journey.tscn").instantiate()
    journey.initial_area="hometown"
    view.add_child(journey)
    await frames(45)
    journey.get_node("RouteHUD").hide()
    journey.active_area.get_node("Player/Camera2D").enabled=false
    var camera:=Camera2D.new()
    camera.position=Vector2(512,384)
    camera.zoom=Vector2.ONE
    view.add_child(camera)
    camera.make_current()
    await save(view,"homes-hometown-native")
    for name in ["CourtyardHome","NeighborHome","GardenHome"]:
        var sprite:Sprite2D=journey.active_area.get_node("RouteDecor/"+name)
        var used:Rect2i=sprite.texture.get_image().get_used_rect()
        var corner:=sprite.get_rect().position+Vector2(used.position)
        var bounds:=Rect2(sprite.position+corner*sprite.scale,Vector2(used.size)*sprite.scale)
        var okay:=Rect2(0,0,1024,768).encloses(bounds)
        records.append({"house":name,"visible_world_bounds":str(bounds),"full_alpha_fits_map":okay,"scale":str(sprite.scale)})
        if not okay:failed=true
    camera.position=Vector2(392,236);camera.zoom=Vector2(3,3);view.size=Vector2i(1024,560)
    await save(view,"homes-north-detail")
    camera.position=Vector2(370,562);view.size=Vector2i(900,600)
    await save(view,"homes-garden-detail")
    view.queue_free()
    await frames(8)
    view=SubViewport.new()
    view.size=Vector2i(512,512)
    view.world_2d=World2D.new()
    view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(view)
    journey=load("res://scenes/world_journey.tscn").instantiate()
    journey.initial_area="courtyard_home"
    view.add_child(journey)
    await frames(45)
    journey.get_node("RouteHUD").hide()
    journey.active_area.get_node("Player/Camera2D").enabled=false
    camera=Camera2D.new();camera.position=Vector2(128,128);camera.zoom=Vector2(2,2)
    view.add_child(camera);camera.make_current()
    await save(view,"home-room-native")
    view.queue_free()
    await frames(8)
    var file:=FileAccess.open(OUT+"overview.json",FileAccess.WRITE)
    file.store_string(JSON.stringify({"passed":not failed,"completed":true,"diagnostic_camera_only":true,"records":records}, "  "))
    print("HOMES_OVERVIEW_COMPLETE ",not failed)
    quit(1 if failed else 0)
