extends SceneTree
const OUT:="C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/historic-frontage-2026-10-04/render/"
var journey:Node2D
func _initialize() -> void:
    call_deferred("_run")
func frames(n:int) -> void:
    for i in n:await process_frame
func _run() -> void:
    var view:=SubViewport.new()
    view.size=Vector2i(768,896)
    view.world_2d=World2D.new()
    view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(view)
    journey=load("res://scenes/world_journey.tscn").instantiate()
    journey.initial_area="historic_street"
    view.add_child(journey)
    await frames(45)
    journey.get_node("RouteHUD").hide()
    var courier:CharacterBody2D=journey.active_area.get_node("Player")
    courier.get_node("Camera2D").enabled=false
    var camera:=Camera2D.new()
    camera.position=Vector2(384,448);camera.zoom=Vector2.ONE
    view.add_child(camera);camera.make_current()
    await frames(15);await RenderingServer.frame_post_draw
    view.get_texture().get_image().save_png(OUT+"native-block-overview.png")
    var checks:Array=[]
    for tree in journey.active_area.get("_trees"):
        var bounds:Rect2=tree.get_rect()
        bounds.position=tree.to_global(bounds.position)
        checks.append({"tree":tree.name,"bounds":str(bounds),"within_level":Rect2(0,0,768,896).encloses(bounds)})
    var props:Array=[]
    var workshop_top:=0.0
    var area:Node2D=journey.active_area
    for label in ["RemodelledBrickShop","PublicLedgerHouse","OccupiedRepairWorkshop","UpperFloorRowhomes","WorkshopKeeper"]:
        var sprite:Sprite2D=area.get_node("RouteDecor/"+label)
        var local:Rect2=sprite.get_rect()
        var bounds:=Rect2(sprite.to_global(local.position),local.size*sprite.scale)
        var used:=sprite.texture.get_image().get_used_rect()
        var native_height:float=used.size.y*sprite.scale.y
        var opaque_bounds:=Rect2(sprite.to_global(local.position+Vector2(used.position)),Vector2(used.size)*sprite.scale)
        if label=="OccupiedRepairWorkshop":workshop_top=opaque_bounds.position.y
        props.append({"name":label,"bounds":str(bounds),"entire_canvas_within_level":Rect2(0,0,768,896).encloses(bounds),"visible_height":native_height,"opaque_bounds":str(opaque_bounds),"foot_anchor_y":sprite.position.y})
    var props_file:=FileAccess.open(OUT+"native-frontage-bounds.json",FileAccess.WRITE)
    props_file.store_string(JSON.stringify({"props":props,"workshop_rear_roof_y":workshop_top,"rear_lane_south_edge":258,"minimum_clearance_to_rear_roof":workshop_top-258.0,"keeper_height":28.0},"\t"));props_file.close()
    var f:=FileAccess.open(OUT+"native-bounds.json",FileAccess.WRITE)
    f.store_string(JSON.stringify({"canopies":checks,"native_subviewport":[768,896],"visual_camera_only_changed":true,"ordinary_traversal_checked_separately":true},"\t"));f.close()
    view.queue_free();journey=null
    await frames(10);quit()
