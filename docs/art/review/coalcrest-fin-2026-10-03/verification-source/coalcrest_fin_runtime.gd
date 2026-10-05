extends SceneTree
const OUT := "C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/coalcrest-fin-review/"
const OLD := "res://assets/sprites/creatures/rd_material_match_2026_10_01/coalcrest_front.png"
var battle: Node
var fixture: Node
var checks: Array = []
var failed := false
var watching := false
var front_seen := false
var changed_front := false
var tag := ""
func _initialize() -> void:
    call_deferred("_run")
func frames(n: int) -> void:
    for i in n: await process_frame
func capture(label: String) -> void:
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(OUT+label+".png")
func watch(expected: Texture2D) -> void:
    while watching:
        await process_frame
        if not is_instance_valid(battle): continue
        var front: Sprite2D = battle.get("_foe_sprite")
        if front.texture == expected and not front_seen:
            front_seen = true
            await capture(tag+"-front-during")
        if battle.get("_foe").id == 105 and front.texture != expected: changed_front = true
func _run() -> void:
    root.size=Vector2i(1152,648)
    fixture=Node.new();fixture.process_mode=Node.PROCESS_MODE_ALWAYS
    root.add_child(fixture);current_scene=fixture
    var coal: CreatureData=load("res://data/creatures/105_coalcrest.tres").duplicate()
    var cinder: CreatureData=load("res://data/creatures/002_cinderhide.tres")
    var old: Texture2D=load(OLD)
    var repaired: Texture2D=coal.sprite
    for near in [false,true]:
        if is_instance_valid(battle): battle.queue_free();paused=false;await frames(5)
        battle=CanvasLayer.new();battle.set_script(load("res://scripts/battle_screen.gd"))
        fixture.add_child(battle)
        root.get_node("PlayerParty").caught.clear();root.get_node("PlayerParty").active_slot=-1
        battle.player_creature=coal if near else cinder
        await battle.start(cinder if near else coal)
        var sprite: Sprite2D=battle.get("_player_sprite" if near else "_foe_sprite")
        var new_zoom: float=battle.call("_zoom",sprite)
        var new_home: Vector2=sprite.position
        coal.sprite=old
        var old_zoom: float=battle.call("_zoom",sprite)
        coal.sprite=repaired
        var scale_ok: bool=is_equal_approx(old_zoom,new_zoom)
        if not scale_ok:failed=true
        checks.append({"side":"near_rear" if near else "far_front","original_zoom":old_zoom,"repaired_zoom":new_zoom,"scale_preserved":scale_ok,"texture":sprite.texture.resource_path,"home":str(new_home)})
        await frames(90);await capture("near-rear-idle" if near else "far-front-idle")
        for move_index in [0,3]:
            tag=("near" if near else "far")+"-"+coal.moves[move_index].move_name.to_snake_case()
            var home: Vector2=sprite.position
            var texture: Texture2D=sprite.texture
            front_seen=false;changed_front=false;watching=true
            watch(repaired)
            paused=true
            await battle.call("_attack",coal,near,coal.moves[move_index])
            watching=false
            await frames(90)
            await capture(tag+"-after")
            var okay: bool=sprite.texture==texture and sprite.position.distance_to(home)<0.1 and not battle.get("_reversed") and not changed_front
            if not okay:failed=true
            checks.append({"move":tag,"texture_restored":sprite.texture==texture,"home_restored":sprite.position.distance_to(home)<0.1,"reverse_released":not battle.get("_reversed"),"repaired_front_observed":front_seen,"unrepaired_front_observed":changed_front,"passed":okay})
            paused=false
    var f:=FileAccess.open(OUT+"runtime-checks.json",FileAccess.WRITE)
    f.store_string(JSON.stringify({"checks":checks,"passed":not failed},"\t"));f.close()
    print("COALCREST_FIN_RUNTIME ",not failed," ",checks)
    battle.queue_free();paused=false;await frames(5)
    quit(1 if failed else 0)
