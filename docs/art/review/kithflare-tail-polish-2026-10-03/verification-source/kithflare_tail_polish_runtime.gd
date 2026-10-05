extends SceneTree
const OUT := "C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/kithflare-tail-polish/runtime/"
const SPECS := [
    [103,"kithflare","res://assets/sprites/creatures/rd_material_match_2026_10_01/kithflare_front.png"],
    [104,"wayburn","res://assets/sprites/creatures/rd_material_match_2026_10_01/wayburn_front.png"],
    [105,"coalcrest","res://assets/sprites/creatures/coalcrest_front_fin_complete_2026_10_03.png"],
]
var fixture: Node
var battle: Node
var checks: Array = []
var failed := false
var watching := false
var mismatch := false
var seen := false
var tag := ""
func _initialize() -> void:
    call_deferred("_run")
func frames(n: int) -> void:
    for i in n: await process_frame
func capture(label: String) -> void:
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(OUT+label+".png")
func watch(sprite: Sprite2D, expected: Texture2D) -> void:
    while watching:
        await process_frame
        if sprite.texture != expected: mismatch=true
        if not seen:
            seen=true
            await capture(tag+"-during")
func _run() -> void:
    root.size=Vector2i(1152,648)
    fixture=Node.new();fixture.process_mode=Node.PROCESS_MODE_ALWAYS
    root.add_child(fixture);current_scene=fixture
    var cinder: CreatureData=load("res://data/creatures/002_cinderhide.tres")
    for spec in SPECS:
        var subject: CreatureData=load("res://data/creatures/%03d_%s.tres"%[spec[0],spec[1]]).duplicate()
        var current_front: Texture2D=subject.sprite
        var old_front: Texture2D=load(spec[2])
        for near in [false,true]:
            if is_instance_valid(battle):
                battle.queue_free();paused=false;await frames(5)
            battle=CanvasLayer.new();battle.set_script(load("res://scripts/battle_screen.gd"));fixture.add_child(battle)
            root.get_node("PlayerParty").caught.clear();root.get_node("PlayerParty").active_slot=-1
            battle.player_creature=subject if near else cinder
            await battle.start(cinder if near else subject)
            var sprite: Sprite2D=battle.get("_player_sprite" if near else "_foe_sprite")
            var updated_zoom: float=battle.call("_zoom",sprite)
            subject.sprite=old_front
            var original_zoom: float=battle.call("_zoom",sprite)
            subject.sprite=current_front
            var scale_ok: bool=is_equal_approx(original_zoom,updated_zoom)
            var expected: Texture2D=subject.back_sprite if near else current_front
            var correct: bool=sprite.texture==expected
            failed=failed or not scale_ok or not correct
            var side: String="back" if near else "front"
            tag=spec[1]+"-"+side
            await frames(90);await capture(tag+"-idle")
            checks.append({"species":spec[1],"view":side,"native_texture":sprite.texture.resource_path,"original_zoom":original_zoom,"updated_zoom":updated_zoom,"scale_preserved":scale_ok,"installed_texture":correct})
            for index in subject.moves.size():
                if spec[0]==105 and index==2:continue # Plate Rake remains excluded by the existing body gate.
                var move: MoveData=subject.moves[index]
                var home: Vector2=sprite.position
                var tex: Texture2D=sprite.texture
                tag=spec[1]+"-"+side+"-"+move.move_name.to_snake_case()
                mismatch=false;seen=false;watching=true
                watch(sprite,expected)
                paused=true
                await battle.call("_attack",subject,near,move)
                watching=false
                await frames(90);await capture(tag+"-after")
                var okay: bool=sprite.texture==tex and sprite.position.distance_to(home)<0.1 and not battle.get("_reversed") and not mismatch
                failed=failed or not okay
                checks.append({"move":tag,"texture_restored":sprite.texture==tex,"position_restored":sprite.position.distance_to(home)<0.1,"reverse_released":not battle.get("_reversed"),"unrepaired_texture_seen":mismatch,"passed":okay})
                paused=false
    var f:=FileAccess.open(OUT+"runtime-checks.json",FileAccess.WRITE)
    f.store_string(JSON.stringify({"checks":checks,"passed":not failed},"\t"));f.close()
    print("TAIL_POLISH_RUNTIME ",not failed)
    battle.queue_free();paused=false;await frames(5)
    quit(1 if failed else 0)
