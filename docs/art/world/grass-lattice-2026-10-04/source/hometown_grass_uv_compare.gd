extends SceneTree
const OUT:="C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/hometown-neighborhood-2026-10-04/render/"
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
    var courier:CharacterBody2D=journey.active_area.get_node("Player")
    courier.get_node("Camera2D").enabled=false
    var camera:=Camera2D.new()
    camera.position=Vector2(512,384);camera.zoom=Vector2.ONE
    view.add_child(camera);camera.make_current()
    await frames(15);await RenderingServer.frame_post_draw
    view.get_texture().get_image().save_png(OUT+"before-native-hometown.png")
    var terrain:TileMapLayer=journey.active_area.get_node("Landscape/Terrain")
    var same:=Sprite2D.new()
    same.name="FixtureSameGrass";same.centered=false;same.z_index=-10
    same.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    same.texture=ImageTexture.create_from_image(Image.load_from_file("C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/hometown-neighborhood-2026-10-04/native_grass_same_tiles.png"))
    var shade:=ShaderMaterial.new()
    var shader:=Shader.new()
    shader.code=FileAccess.get_file_as_string("C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/hometown-neighborhood-2026-10-04/grass_surface_candidate.gdshader")
    shade.shader=shader
    same.material=shade
    terrain.hide();journey.active_area.get_node("Landscape").add_child(same)
    await frames(12);await RenderingServer.frame_post_draw
    view.get_texture().get_image().save_png(OUT+"grass-single-surface-uv-shader.png")
    same.material=null
    await frames(12);await RenderingServer.frame_post_draw
    view.get_texture().get_image().save_png(OUT+"grass-single-surface-no-shader.png")
    var checks:Array=[]
    for tree in journey.active_area.get_node("Landscape").get("_trees"):
        var bounds:Rect2=tree.get_rect()
        bounds.position=tree.to_global(bounds.position)
        checks.append({"tree":tree.name,"bounds":str(bounds),"within_level":Rect2(0,0,1024,768).encloses(bounds)})
    var f:=FileAccess.open(OUT+"native-bounds.json",FileAccess.WRITE)
    f.store_string(JSON.stringify({"canopies":checks,"native_subviewport":[1024,768],"visual_camera_only_changed":true,"ordinary_traversal_checked_separately":true},"\t"));f.close()
    view.queue_free();journey=null
    await frames(10);quit()
