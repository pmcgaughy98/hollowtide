extends SceneTree
# Diagnostic native renders only. Area selection occurs before normal scene startup;
# this fixture is separate from the ordinary-input walking proof.
const WORKSPACE := "C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an"
const OUT := WORKSPACE+"/room-coalcrest-detail-2026-10-05/proof/overview/"
const COAT_SHADER := "res://assets/sprites/world/route1_landing_loop_2026_10_03/canopy_visibility.gdshader"
const EXPECTED_AREAS := 4
const EXPECTED_CAPTURES := 14
const EXPECTED_SPRITE_CHECKS := 11
const FLAGS := ["pouch_accepted","levee_entrance_read","city_arrival_registered","city_directions_read","delivered","water_mark_observed","heard_calls","marker_restored","report_done","reported_calls","reported_water_mark"]
const CASES := [
    {"id":"courtyard_home","native_zoom":Vector2(2,2),"bounds":Rect2(0,0,256,256),"full":"home-room-native-2x","full_zoom":Vector2(2,2),"targets":[
        {"node":"RoomArt","position":Vector2.ZERO,"scale":Vector2.ONE,"size":Vector2(256,256),"offset":Vector2.ZERO},
        {"node":"RouteDecor/RoomStoveFront","position":Vector2(33,177),"scale":Vector2.ONE,"size":Vector2(28,69),"offset":Vector2(0,-67)},
        {"node":"RouteDecor/RoomCoatFront","position":Vector2(182,176),"scale":Vector2.ONE,"size":Vector2(40,64),"offset":Vector2(0,-62)},
        {"node":"RouteDecor/RoomThresholdFront","position":Vector2(24,233),"scale":Vector2.ONE,"size":Vector2(209,26),"offset":Vector2(0,-24)},
    ],"details":[
        {"label":"home-bed-quilt-native-2x","region":Rect2(32,52,92,76)},
        {"label":"home-stove-woodpile-native-2x","region":Rect2(28,104,52,80)},
        {"label":"home-cupboard-coat-native-2x","region":Rect2(176,106,52,84)},
        {"label":"home-shelf-worktable-native-2x","region":Rect2(144,28,80,88)},
    ]},
    {"id":"hometown","native_zoom":Vector2(3,3),"bounds":Rect2(0,0,1024,768),"full":"hometown-overview-native-1x","full_zoom":Vector2.ONE,"targets":[
        {"node":"RouteDecor/CourtyardHome","position":Vector2(224,256),"scale":Vector2(0.75,0.75)},
        {"node":"RouteDecor/DispatcherHall","position":Vector2(768,418),"scale":Vector2(0.75,0.75)},
    ],"details":[
        {"label":"hometown-courtyard-native-3x","nodes":["RouteDecor/CourtyardHome"]},
        {"label":"hometown-hall-native-3x","nodes":["RouteDecor/DispatcherHall"]},
    ]},
    {"id":"riverfront","native_zoom":Vector2(3,3),"bounds":Rect2(0,0,1024,768),"full":"riverfront-overview-native-1x","full_zoom":Vector2.ONE,"targets":[
        {"node":"RouteDecor/CityCourierBranch","position":Vector2(512,362),"scale":Vector2(0.75,0.75)},
        {"node":"RouteDecor/ReusedBrickShop","position":Vector2(768,264),"scale":Vector2(0.75,0.75)},
        {"node":"RouteDecor/StreetLedgerHouse","position":Vector2(336,640),"scale":Vector2(0.75,0.75)},
    ],"details":[
        {"label":"riverfront-hall-native-3x","nodes":["RouteDecor/CityCourierBranch"]},
        {"label":"riverfront-shop-native-3x","nodes":["RouteDecor/ReusedBrickShop"]},
        {"label":"riverfront-ledger-native-3x","nodes":["RouteDecor/StreetLedgerHouse"]},
    ]},
    {"id":"historic_street","native_zoom":Vector2(3,3),"bounds":Rect2(0,0,768,896),"full":"historic-street-overview-native-1x","full_zoom":Vector2.ONE,"targets":[
        {"node":"RouteDecor/RemodelledBrickShop","position":Vector2(544,400),"scale":Vector2(0.85,0.85)},
        {"node":"RouteDecor/PublicLedgerHouse","position":Vector2(224,400),"scale":Vector2(0.85,0.85)},
    ],"details":[
        {"label":"historic-shop-ledger-native-3x","nodes":["RouteDecor/RemodelledBrickShop","RouteDecor/PublicLedgerHouse"]},
    ]},
]
var records: Array = []
var captures: Array = []
var completed_area_ids: Array = []
var checked_sprite_keys: Array = []
var expected_capture_labels: Array = []
var saved_captures := 0
var failed := false
var completed_overview := false
var finished := false
var output_ready := false
var model := "Male"
var run_id := ""
var phase := "starting"
var initial_party: Dictionary = {}
var current_view: SubViewport
var current_journey: Node2D
func _initialize() -> void:
    if "--female" in OS.get_cmdline_user_args():model="Female"
    run_id=str(OS.get_process_id())+"-"+str(Time.get_unix_time_from_system())
    if not OUT.begins_with(WORKSPACE+"/"):
        push_error("SHARPER_WORLD_OVERVIEW invalid output root")
        quit(1);return
    var error:int=DirAccess.make_dir_recursive_absolute(OUT)
    output_ready=(error==OK or error==ERR_ALREADY_EXISTS) and DirAccess.dir_exists_absolute(OUT)
    if not output_ready:
        push_error("SHARPER_WORLD_OVERVIEW could not create output directory: "+str(error))
        quit(1);return
    for spec in CASES:
        expected_capture_labels.append(spec["full"])
        for detail in spec["details"]:expected_capture_labels.append(detail["label"])
    var unique_labels:Dictionary={}
    for label in expected_capture_labels:unique_labels[label]=true
    if CASES.size()!=EXPECTED_AREAS or expected_capture_labels.size()!=EXPECTED_CAPTURES or unique_labels.size()!=EXPECTED_CAPTURES:
        failed=true;records.append({"fixture_contract_counts_and_unique_labels":false});finish();return
    if not write_report():failed=true;finish();return
    call_deferred("_watchdog")
    call_deferred("_run")
func frames(count: int) -> void:
    for i in count:await process_frame
func report_path() -> String:
    return OUT+model.to_lower()+"-overview.json"
func write_report() -> bool:
    if not output_ready:return false
    var file:FileAccess=FileAccess.open(report_path(),FileAccess.WRITE)
    if file==null:
        push_error("SHARPER_WORLD_OVERVIEW report open failed: "+str(FileAccess.get_open_error()))
        return false
    var data:Dictionary={"run_id":run_id,"pid":OS.get_process_id(),"model":model,"phase":phase,"passed":completed_overview and not failed,"completed":completed_overview,"diagnostic_cameras_only":true,"separate_initial_area_views":true,"quest_overrides":0,"player_repositions":0,"art_or_material_overrides":0,"external_runtime_stderr_must_be_empty":true,"expected_area_count":EXPECTED_AREAS,"completed_area_count":completed_area_ids.size(),"completed_areas":completed_area_ids,"expected_capture_count":EXPECTED_CAPTURES,"attempted_capture_count":captures.size(),"saved_capture_count":saved_captures,"expected_capture_labels":expected_capture_labels,"expected_target_sprite_count":EXPECTED_SPRITE_CHECKS,"checked_target_sprite_count":checked_sprite_keys.size(),"party":initial_party,"captures":captures,"records":records}
    file.store_string(JSON.stringify(data,"\t"));file.flush()
    var error:int=file.get_error()
    file.close()
    if error!=OK:push_error("SHARPER_WORLD_OVERVIEW report write failed: "+str(error))
    return error==OK
func party_state() -> Dictionary:
    var party:Node=root.get_node_or_null("PlayerParty")
    if party==null:return {}
    var members:Array=[]
    for member in party.get("caught"):
        var known:Array=[]
        for move in member.known:known.append(move.get_instance_id())
        members.append({"member":member.get_instance_id(),"species":member.species.get_instance_id(),"known":known})
    return {"id":party.get_instance_id(),"active_slot":party.get("active_slot"),"members":members}
func flags_state(journey: Node2D) -> Dictionary:
    var state:Dictionary={}
    for name in FLAGS:state[name]=journey.get("route").get(name)
    return state
func local_state(area: Node2D, area_id: String) -> Dictionary:
    var state:Dictionary={}
    if area_id=="hometown":
        var garden:Node=area.get("garden_activity")
        if garden==null:return {"missing_garden":true}
        var rows:Array=[]
        for row in garden.get("planted_sprites"):rows.append(row.get_instance_id())
        state={"garden":garden.get_instance_id(),"offered":garden.get("cuttings_offered"),"planted":garden.get("cuttings_planted"),"rows":rows}
    elif area_id=="historic_street":
        for name in ["started","lintel_checked","ledger_checked","handoff_verified","last_submitted_number"]:state[name]=area.get(name)
    return state
func core_state(journey: Node2D) -> Dictionary:
    var area:Node2D=journey.get("active_area")
    var player:CharacterBody2D=area.get_node("Player")
    var route:Node2D=journey.get("route")
    var cache:Dictionary={}
    var cached:Dictionary=journey.get("cached")
    for area_id in cached:
        var cached_area:Node=cached[area_id]
        cache[area_id]={"area":cached_area.get_instance_id(),"player":cached_area.get_node("Player").get_instance_id()}
    return {"journey":journey.get_instance_id(),"area_id":journey.get("active_id"),"active_area":area.get_instance_id(),"player":player.get_instance_id(),"bound_player":route.get("player").get_instance_id(),"position":str(player.position),"velocity":str(player.velocity),"model":player.get("chibi_model"),"speed":player.get("speed"),"physics_processing":player.is_physics_processing(),"controller":route.get_instance_id(),"flags":flags_state(journey),"party":party_state(),"objective":route.get("_objective").text,"board":route.get("_board").text,"notes":route.get("_notes_body").text,"local_state":local_state(area,journey.get("active_id")),"cache":cache,"transitions":journey.get("transitions").duplicate(true),"transitioning":journey.get("transitioning")}
func visible_bounds(sprite: Sprite2D) -> Rect2:
    var used:Rect2i=sprite.texture.get_image().get_used_rect()
    var top:Vector2=Vector2(used.position)+sprite.offset
    if sprite.centered:top-=sprite.texture.get_size()*0.5
    var bounds:Rect2=Rect2(sprite.to_global(top),Vector2.ZERO)
    for corner in [Vector2.ZERO,Vector2(used.size.x,0),Vector2(0,used.size.y),Vector2(used.size)]:bounds=bounds.expand(sprite.to_global(top+corner))
    return bounds
func material_state(sprite: Sprite2D) -> Dictionary:
    var material:Material=sprite.material
    if material==null:return {"id":0,"class":"","shader_id":0,"shader_path":""}
    var state:Dictionary={"id":material.get_instance_id(),"class":material.get_class(),"shader_id":0,"shader_path":""}
    if material is ShaderMaterial:
        var shader_material:ShaderMaterial=material
        if shader_material.shader!=null:
            state["shader_id"]=shader_material.shader.get_instance_id()
            state["shader_path"]=shader_material.shader.resource_path
        if shader_material.shader!=null and shader_material.shader.resource_path==COAT_SHADER:state["canopy_opacity"]=shader_material.get_shader_parameter("canopy_opacity")
    return state
func sprite_state(sprite: Sprite2D) -> Dictionary:
    return {"id":sprite.get_instance_id(),"texture_id":sprite.texture.get_instance_id(),"texture_path":sprite.texture.resource_path,"texture_size":str(sprite.texture.get_size()),"position":str(sprite.global_position),"offset":str(sprite.offset),"scale":str(sprite.global_scale),"centered":sprite.centered,"filter":sprite.texture_filter,"z_index":sprite.z_index,"visible":sprite.visible,"modulate":str(sprite.modulate),"material":material_state(sprite),"visible_world_bounds":str(visible_bounds(sprite))}
func target_snapshot(area: Node2D, spec: Dictionary) -> Dictionary:
    var state:Dictionary={}
    for target in spec["targets"]:
        var node:Node=area.get_node_or_null(target["node"])
        if node==null or not (node is Sprite2D):return {}
        var sprite:Sprite2D=node
        if sprite.texture==null or sprite.texture.get_image()==null:return {}
        state[target["node"]]=sprite_state(sprite)
    return state
func target_contract(area: Node2D, spec: Dictionary) -> bool:
    for target in spec["targets"]:
        var node:Node=area.get_node_or_null(target["node"])
        if node==null or not (node is Sprite2D):
            records.append({"target_contract":false,"area":spec["id"],"node":target["node"],"reason":"missing expected sprite"})
            failed=true;return false
        var sprite:Sprite2D=node
        if sprite.texture==null or sprite.texture.get_image()==null:
            records.append({"target_contract":false,"area":spec["id"],"node":target["node"],"reason":"missing texture image"})
            failed=true;return false
        var bounds:Rect2=visible_bounds(sprite)
        var okay:bool=sprite.visible and sprite.is_visible_in_tree() and sprite.is_inside_tree() and sprite.global_position==target["position"] and sprite.global_scale==target["scale"] and sprite.texture_filter==CanvasItem.TEXTURE_FILTER_NEAREST and bounds.has_area() and spec["bounds"].encloses(bounds)
        if target.has("size"):okay=okay and not sprite.centered and sprite.texture.get_size()==target["size"] and sprite.offset==target["offset"]
        if target["node"]=="RouteDecor/RoomCoatFront":
            var material:Dictionary=material_state(sprite)
            okay=okay and sprite.material!=null and sprite.material==area.get("_coat_material") and material.get("shader_path","")==COAT_SHADER and material.get("canopy_opacity",-1.0)>=0.999
        var key:String=spec["id"]+"/"+target["node"]
        records.append({"target_contract":okay,"key":key,"state":sprite_state(sprite)})
        if not okay:failed=true;return false
        if checked_sprite_keys.has(key):failed=true;return false
        checked_sprite_keys.append(key)
    return true
func detail_bounds(area: Node2D, paths: Array) -> Rect2:
    var bounds:Rect2=Rect2()
    var first:bool=true
    for path_name in paths:
        var sprite:Sprite2D=area.get_node(path_name)
        bounds=visible_bounds(sprite) if first else bounds.merge(visible_bounds(sprite))
        first=false
    var top:Vector2=bounds.position.floor()-Vector2(16,16)
    var end:Vector2=bounds.end.ceil()+Vector2(16,16)
    return Rect2(top,end-top)
func capture(view: SubViewport, camera: Camera2D, journey: Node2D, spec: Dictionary, label: String, region: Rect2, zoom: Vector2, baseline: Dictionary, art: Dictionary) -> bool:
    phase=label
    var size:Vector2i=Vector2i(region.size*zoom)
    if not region.has_area() or size.x<1 or size.y<1 or size.x>4096 or size.y>4096:
        failed=true;records.append({"capture_geometry":label,"passed":false});return false
    view.size=size
    camera.position=region.get_center();camera.zoom=zoom
    camera.reset_smoothing();camera.force_update_scroll()
    await frames(22)
    await RenderingServer.frame_post_draw
    var image:Image=view.get_texture().get_image()
    var path:String=OUT+model.to_lower()+"-"+label+".png"
    var error:int=ERR_INVALID_DATA
    var readback_error:int=ERR_INVALID_DATA
    var saved:bool=false
    if image!=null and not image.is_empty() and image.get_size()==size:
        error=image.save_png(path)
        if error==OK and FileAccess.file_exists(path):
            var readback:Image=Image.new()
            readback_error=readback.load(path)
            saved=readback_error==OK and not readback.is_empty() and readback.get_size()==size
    var after:Dictionary=core_state(journey)
    var art_after:Dictionary=target_snapshot(journey.get("active_area"),spec)
    var same:bool=baseline==after and art==art_after and initial_party==party_state()
    if not same:records.append({"capture_state_mismatch":label,"core_before":baseline,"core_after":after,"native_art_before":art,"native_art_after":art_after})
    var okay:bool=saved and same
    captures.append({"label":label,"area":spec["id"],"primary_full_area_view":label==spec["full"],"detail_at_actual_gameplay_camera_zoom":label!=spec["full"] and zoom==spec["native_zoom"],"path":path,"pixel_size":str(size),"world_region":str(region),"camera_zoom":str(zoom),"save_error":error,"readback_error":readback_error,"saved_and_read_back":saved,"core_party_local_state_art_material_and_cache_exact":same,"passed":okay})
    if saved:saved_captures+=1
    if not okay:failed=true
    if not write_report():failed=true;return false
    return okay
func render_area(spec: Dictionary) -> bool:
    phase="startup-"+spec["id"]
    current_view=SubViewport.new()
    current_view.size=Vector2i(1024,768)
    current_view.world_2d=World2D.new()
    current_view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    current_view.canvas_item_default_texture_filter=Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
    current_view.gui_disable_input=true
    root.add_child(current_view)
    var packed:PackedScene=load("res://scenes/world_journey.tscn")
    if packed==null:failed=true;return false
    current_journey=packed.instantiate()
    current_journey.set("initial_area",spec["id"])
    current_journey.call("set_courier_model",model)
    current_view.add_child(current_journey)
    await frames(45)
    if current_journey.get("active_id")!=spec["id"] or current_journey.get("transitioning"):
        failed=true;records.append({"area_startup":spec["id"],"passed":false});return false
    var area:Node2D=current_journey.get("active_area")
    var original_camera:Camera2D=area.get_node_or_null("Player/Camera2D")
    var hud:CanvasLayer=current_journey.get_node_or_null("RouteHUD")
    if original_camera==null or hud==null:failed=true;return false
    var flags:Dictionary=flags_state(current_journey)
    var clear:bool=true
    for name in FLAGS:clear=clear and flags[name]==false
    var native:bool=original_camera.zoom==spec["native_zoom"]
    var no_transitions:bool=current_journey.get("transitions").is_empty()
    if initial_party.is_empty():initial_party=party_state()
    var same_party:bool=not initial_party.is_empty() and initial_party==party_state()
    records.append({"area_startup":spec["id"],"all_eleven_original_flags_false":clear,"native_player_camera_zoom":str(original_camera.zoom),"expected_zoom":str(spec["native_zoom"]),"party_exact":same_party,"no_entrance_travel_in_diagnostic_startup":no_transitions,"passed":clear and native and same_party and no_transitions})
    if not clear or not native or not same_party or not no_transitions:failed=true;return false
    if not target_contract(area,spec):return false
    var baseline:Dictionary=core_state(current_journey)
    var art:Dictionary=target_snapshot(area,spec)
    var camera_enabled:bool=original_camera.enabled
    var hud_visible:bool=hud.visible
    original_camera.enabled=false;hud.hide()
    var camera:Camera2D=Camera2D.new()
    camera.position_smoothing_enabled=false
    camera.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    current_view.add_child(camera);camera.make_current()
    if not await capture(current_view,camera,current_journey,spec,spec["full"],spec["bounds"],spec["full_zoom"],baseline,art):return false
    for detail in spec["details"]:
        var region:Rect2=detail["region"] if detail.has("region") else detail_bounds(area,detail["nodes"])
        if not spec["bounds"].encloses(region):
            failed=true;records.append({"detail_region_outside_area":detail["label"],"passed":false});return false
        if not await capture(current_view,camera,current_journey,spec,detail["label"],region,original_camera.zoom,baseline,art):return false
    camera.enabled=false
    original_camera.enabled=camera_enabled
    if camera_enabled:original_camera.make_current()
    hud.visible=hud_visible
    var preserved:bool=baseline==core_state(current_journey) and art==target_snapshot(area,spec) and initial_party==party_state()
    var restored:bool=original_camera.enabled==camera_enabled and hud.visible==hud_visible
    records.append({"area_complete":spec["id"],"core_flags_player_controller_notes_objective_board_party_local_state_cache_and_material_exact":preserved,"original_camera_and_hud_visibility_restored":restored,"original_core":baseline,"final_core":core_state(current_journey),"passed":preserved and restored})
    if not preserved or not restored:failed=true;return false
    current_view.queue_free();current_view=null;current_journey=null
    await frames(8)
    if initial_party!=party_state():failed=true;return false
    completed_area_ids.append(spec["id"])
    return true
func _run() -> void:
    for spec in CASES:
        if finished:return
        if not await render_area(spec):finish();return
    var labels:Array=[]
    for record in captures:labels.append(record["label"])
    var counts:bool=completed_area_ids.size()==EXPECTED_AREAS and captures.size()==EXPECTED_CAPTURES and saved_captures==EXPECTED_CAPTURES and checked_sprite_keys.size()==EXPECTED_SPRITE_CHECKS and labels==expected_capture_labels
    var state:bool=initial_party==party_state()
    records.append({"final_exact_counts":counts,"party_preserved_after_all_viewports_freed":state,"passed":counts and state})
    completed_overview=counts and state and not failed
    if not completed_overview:failed=true
    phase="complete" if completed_overview else "incomplete"
    finish()
func _watchdog() -> void:
    await create_timer(120.0,true,false,true).timeout
    if finished:return
    failed=true
    records.append({"watchdog_timeout":true,"last_phase":phase,"completed":false})
    phase="watchdog-timeout"
    finish()
func finish() -> void:
    if finished:return
    finished=true
    failed=failed or not completed_overview
    if not write_report():failed=true
    print("SHARPER_WORLD_OVERVIEW ",run_id," ",model," ",not failed," captures=",saved_captures,"/",EXPECTED_CAPTURES," areas=",completed_area_ids.size(),"/",EXPECTED_AREAS," sprites=",checked_sprite_keys.size(),"/",EXPECTED_SPRITE_CHECKS)
    call_deferred("_exit",1 if failed else 0)
func _exit(code: int) -> void:
    if current_view!=null and is_instance_valid(current_view):current_view.queue_free()
    current_view=null;current_journey=null
    await frames(8)
    quit(code)
