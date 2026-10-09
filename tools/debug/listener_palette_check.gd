extends SceneTree
var OUT := "res://docs/creatures/listener-palette-refinement-2026-10-08/rerun/"
var BEFORE := "res://docs/creatures/listener-palette-refinement-2026-10-08/originals/assets/sprites/arena/"
const FORMS := ["listener","caller","warden"]
const NAMES := ["Cutbank Listener","Bend Caller","Quietwater Warden"]
const FACINGS := ["s","se","e","ne","n","nw","w","sw"]
var checks: Array[Dictionary] = []
var failures: Array[String] = []
func _initialize() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() >= 2:
        OUT = args[0].trim_suffix("/")+"/"
        BEFORE = args[1].trim_suffix("/")+"/"
    _run.call_deferred()
func frames(n: int) -> void:
    for i in n: await process_frame
func verify(label: String, passed: bool) -> void:
    checks.append({"check":label,"passed":passed})
    if not passed: failures.append(label)
func capture(name: String) -> void:
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(OUT+name+".png")
func caption(parent: Node, copy: String, at: Vector2, pixels: int) -> void:
    var label := Label.new()
    label.text = copy
    label.position = at
    label.add_theme_font_override("font",load("res://assets/fonts/AlegreyaSansSC-Bold.ttf"))
    label.add_theme_font_size_override("font_size",pixels)
    parent.add_child(label)
func same_alpha(a: Image,b: Image) -> bool:
    if a.get_size() != b.get_size(): return false
    for y in a.get_height():
        for x in a.get_width():
            if a.get_pixel(x,y).a != b.get_pixel(x,y).a:return false
    return true
func _run() -> void:
    DirAccess.make_dir_recursive_absolute(OUT)
    root.size = Vector2i(1152,648)
    root.content_scale_size = Vector2i(1152,648)
    for stage in FORMS.size():
        var form: String = FORMS[stage]
        var review := Node2D.new()
        root.add_child(review)
        var background := ColorRect.new()
        background.size = Vector2(1152,648)
        background.color = Color("#18292e")
        review.add_child(background)
        caption(review,NAMES[stage].to_upper()+" / ORIGINAL PALETTE",Vector2(28,12),30)
        caption(review,"Before left · refined right / native game textures at 2x",Vector2(28,50),20)
        var pairs: Array = []
        for i in FACINGS.size():
            var x := 18+(i%4)*284
            var y := 92+(i/4)*262
            caption(review,FACINGS[i].to_upper(),Vector2(x,y),22)
            var pair: Array = []
            for side in 2:
                var sprite := Sprite2D.new()
                sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
                sprite.scale = Vector2(2,2)
                sprite.position = Vector2(x+66+side*134,y+166)
                review.add_child(sprite)
                pair.append(sprite)
            pairs.append(pair)
        for frame in range(-1,8):
            for i in FACINGS.size():
                var filename: String = FACINGS[i]+".png" if frame < 0 else "walk_"+FACINGS[i]+"_f%d.png"%frame
                var old := Image.load_from_file(BEFORE+form+"/small/"+filename)
                var current: Texture2D = load("res://assets/sprites/arena/"+form+"/small/"+filename)
                pairs[i][0].texture = ImageTexture.create_from_image(old)
                pairs[i][1].texture = current
                for sprite in pairs[i]:
                    var bounds: Rect2i = sprite.texture.get_image().get_used_rect()
                    sprite.offset = Vector2(0,sprite.texture.get_height()*0.5-bounds.end.y)
                verify(form+"/"+filename+" unchanged alpha and size",same_alpha(old,current.get_image()))
            await frames(2)
            await capture(form+"-"+("stills" if frame < 0 else "walk-frame-%d"%frame))
        review.queue_free()
        await frames(2)
    var arena: Node2D = load("res://scenes/arena_prototype.tscn").instantiate()
    root.add_child(arena)
    current_scene = arena
    await frames(3)
    arena._you = 7
    arena._rival = 0
    arena._rival_stage = 2
    arena.team_size = 1
    for stage in 3:
        arena._you_stage = stage
        arena.set_process(true)
        arena._new_match()
        await frames(3)
        arena.set_process(false)
        var fighter: Dictionary = arena._fighters[0]
        fighter["target"] = -1
        verify("Arena loads "+NAMES[stage],fighter["name"] == NAMES[stage])
        for facing in FACINGS:
            fighter["facing"] = facing
            fighter["walk"] = 0.0
            arena._update_fighter(0,0.0)
            verify(FORMS[stage]+" runtime still "+facing,fighter["sprite"].texture == fighter["art"]["still"][facing])
            for frame in 8:
                fighter["walk"] = (float(frame)+0.1)/(arena.WALK_FPS*fighter["speed"])
                arena._update_fighter(0,0.0)
                verify(FORMS[stage]+" runtime walk "+facing+str(frame),fighter["sprite"].texture == fighter["art"]["walk"][facing][frame])
        fighter["walk"] = 0.0
        fighter["facing"] = "se"
        arena._update_fighter(0,0.0)
        arena._hud.queue_redraw()
        await frames(2)
        await capture("arena-"+FORMS[stage])
    arena.set_process(true)
    for fighter in arena._fighters: fighter["stun"] = 60.0
    arena._fighters[0]["stun"] = 0.0
    arena._fighters[0]["meter"] = 100
    arena.signature(0)
    await frames(90)
    await capture("hush")
    verify("Hush plays with current Warden art",arena._sig.active)
    FileAccess.open(OUT+"checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"  "))
    print("RESULT ",checks.size()," checks / ",failures.size()," failures")
    for failure in failures:print("FAIL ",failure)
    arena.queue_free()
    await frames(3)
    quit(0 if failures.is_empty() else 1)
