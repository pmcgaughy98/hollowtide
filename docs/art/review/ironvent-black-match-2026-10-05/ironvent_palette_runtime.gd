extends SceneTree
const OUT := "C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/ironvent-black-match-review-2026-10-05/proof/"
const FRONT := "res://assets/sprites/creatures/ironvent_black_match_2026_10_05/ironvent_front.png"
const TITLE := "res://assets/sprites/creatures/ironvent_black_match_2026_10_05/furnace_roar_title.png"
var fixture: Node
var battle: Node
var observing := false
var tag := ""
var seen := {}
var captures: Array = []
var checks: Array = []
var failed := false
func _initialize() -> void: call_deferred("_run")
func frames(n: int) -> void:
    for i in n: await process_frame
func capture(label: String) -> void:
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(OUT+label+".png")
func watch() -> void:
    while observing:
        await process_frame
        if not is_instance_valid(battle): continue
        for band in battle.get_children():
            if not band is ColorRect: continue
            for child in band.get_children():
                if not child is Sprite2D: continue
                var art: Sprite2D=child
                if art.texture==null or art.texture.resource_path!=TITLE: continue
                if seen.has(tag+"held"): continue
                if absf(art.modulate.r-1.0)+absf(art.modulate.g-1.0)+absf(art.modulate.b-1.0)+absf(art.modulate.a-1.0)>0.03: continue
                seen[tag+"held"]=true
                await capture(tag+"-title-held")
                var shader_ok: bool=art.material is ShaderMaterial and bool(art.material.get_shader_parameter("charcoal_head"))
                captures.append({"name":tag+"-title-held","texture":art.texture.resource_path,"modulate":str(art.modulate),"scale":str(art.scale),"charcoal_head":shader_ok,"head_region":str(art.material.get_shader_parameter("head_uv_box")) if art.material else "", "frame":Engine.get_process_frames()})
                failed=failed or not shader_ok
func _run() -> void:
    root.size=Vector2i(1152,648)
    fixture=Node.new();fixture.process_mode=Node.PROCESS_MODE_ALWAYS;root.add_child(fixture);current_scene=fixture
    var iron: CreatureData=load("res://data/creatures/102_ironvent.tres")
    var cinder: CreatureData=load("res://data/creatures/002_cinderhide.tres")
    var move: MoveData=load("res://data/moves/ironvent_furnace_roar.tres")
    var binding_ok: bool=iron.sprite.resource_path==FRONT and move.attack_cut_in.resource_path==TITLE
    var rear_ok: bool=iron.back_sprite is AtlasTexture and iron.back_sprite.region==Rect2(0,0,100,96) and iron.back_sprite.margin==Rect2(0,0,0,4)
    checks.append({"name":"bindings","front":iron.sprite.resource_path,"title":move.attack_cut_in.resource_path,"rear_region_margin_preserved":rear_ok,"passed":binding_ok and rear_ok})
    failed=not binding_ok or not rear_ok
    for near in [false,true]:
        if is_instance_valid(battle):
            battle.queue_free();paused=false;await frames(5)
        battle=CanvasLayer.new();battle.set_script(load("res://scripts/battle_screen.gd"));fixture.add_child(battle)
        root.get_node("PlayerParty").caught.clear();root.get_node("PlayerParty").active_slot=-1
        battle.player_creature=iron if near else cinder
        await battle.start(cinder if near else iron)
        tag="rear" if near else "front"
        var sprite: Sprite2D=battle.get("_player_sprite" if near else "_foe_sprite")
        var expected: Texture2D=iron.back_sprite if near else iron.sprite
        var texture_ok: bool=sprite.texture==expected
        await frames(45);await capture(tag+"-idle")
        var original: Texture2D=sprite.texture
        var home: Vector2=sprite.position
        var scale: Vector2=sprite.scale
        observing=true;watch()
        paused=true
        await battle.call("_attack",iron,near,move)
        observing=false
        await frames(45);await capture(tag+"-after")
        var restored: bool=sprite.texture==original and sprite.position.distance_to(home)<0.1 and sprite.scale.is_equal_approx(scale) and not battle.get("_reversed")
        var held: bool=seen.has(tag+"held")
        checks.append({"name":tag+"-Furnace-Roar","installed_texture":texture_ok,"texture_restored":sprite.texture==original,"position_restored":sprite.position.distance_to(home)<0.1,"scale_restored":sprite.scale.is_equal_approx(scale),"reverse_released":not battle.get("_reversed"),"settled_portrait_captured":held,"passed":texture_ok and restored and held})
        failed=failed or not texture_ok or not restored or not held
        paused=false
    var f:=FileAccess.open(OUT+"runtime-checks.json",FileAccess.WRITE)
    f.store_string(JSON.stringify({"checks":checks,"captures":captures,"passed":not failed},"\t"));f.close()
    print("IRONVENT_PALETTE_NATIVE ",not failed)
    battle.queue_free();battle=null;await frames(5)
    fixture.queue_free();fixture=null;current_scene=null;await frames(5)
    call_deferred("quit",1 if failed else 0)
