extends SceneTree
const BASE := "C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/hometown-homes-2026-10-04/"
func _initialize() -> void:
    call_deferred("_run")
func frames(n:int) -> void:
    for i in n:await process_frame
func key(code:Key) -> void:
    for pressed in [true,false]:
        var event:=InputEventKey.new()
        event.keycode=code;event.physical_keycode=code;event.pressed=pressed
        Input.parse_input_event(event);await frames(3)
func _run() -> void:
    var temporary:Node=load("res://scenes/courtyard_home.tscn").instantiate()
    root.add_child(temporary);current_scene=temporary
    await frames(45)
    var journey:=current_scene as Node2D
    if journey==null or not journey.has_method("travel"):
        print("HOME_DIRECT_ENTRY_FAILED missing connected journey");quit(1);return
    var area_id:String=journey.get("active_id")
    var okay:bool=area_id=="courtyard_home" and not journey.get("transitioning") and not is_instance_valid(temporary)
    var route:Node2D=journey.get("route")
    var player:CharacterBody2D=journey.get("active_area").get_node("Player")
    var party_id:int=root.get_node("PlayerParty").active_member().get_instance_id()
    var player_id:int=player.get_instance_id()
    var before:Dictionary={}
    for flag in ["pouch_accepted","levee_entrance_read","city_arrival_registered","city_directions_read","delivered","water_mark_observed","heard_calls","marker_restored","report_done","reported_calls","reported_water_mark"]:before[flag]=route.get(flag)
    okay=okay and route.get("player")==player and player.position==Vector2(128,208) and player.get_node("Camera2D").zoom==Vector2(2,2)
    Input.action_press("move_up");await frames(18);Input.action_release("move_up")
    var moved:bool=player.position.y<195 and player.position.x==128
    await key(KEY_J)
    var position_before:=player.position
    Input.action_press("move_right");await frames(12);Input.action_release("move_right")
    var frozen:bool=route.get("_notes_panel").visible and player.position==position_before
    await key(KEY_E)
    var after:Dictionary={}
    for flag in before:after[flag]=route.get(flag)
    var state_exact:bool=before==after and player.get_instance_id()==player_id and root.get_node("PlayerParty").active_member().get_instance_id()==party_id
    var resumed:bool=player.is_physics_processing() and not route.get("_notes_panel").visible
    await RenderingServer.frame_post_draw
    var save_error:=root.get_texture().get_image().save_png(BASE+"render/home-direct-play.png")
    okay=okay and moved and frozen and resumed and state_exact and save_error==OK
    var output:Dictionary={"passed":okay,"completed":true,"direct_scene":"res://scenes/courtyard_home.tscn","active_area":area_id,"temporary_scene_freed":not is_instance_valid(temporary),"ordinary_movement":moved,"notes_freeze_and_resume":frozen and resumed,"original_flags_party_player_exact":state_exact,"screenshot_save_error":save_error,"test_teleports":0}
    var file:=FileAccess.open(BASE+"proof/direct-entry.json",FileAccess.WRITE)
    file.store_string(JSON.stringify(output,"  "))
    print("HOME_DIRECT_COMPLETE ",okay)
    quit(0 if okay else 1)
