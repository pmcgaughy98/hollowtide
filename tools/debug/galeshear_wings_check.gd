extends SceneTree
const OUT := "D:/dev/hollowtide-galeshear-wings-20261008/native/"
const BEFORE := "D:/dev/hollowtide-galeshear-wings-20261008/originals/assets/sprites/arena/galeshear/small/"
const FACINGS := ["s","se","e","ne","n","nw","w","sw"]
var checks: Array[Dictionary] = []
var failures: Array[String] = []
func _initialize() -> void: _run.call_deferred()
func frames(n: int) -> void:
    for i in n: await process_frame
func verify(label: String, passed: bool) -> void:
    checks.append({"check":label,"passed":passed})
    if not passed: failures.append(label)
    print(label,": ",passed)
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
func _run() -> void:
    DirAccess.make_dir_recursive_absolute(OUT)
    root.size = Vector2i(1152,648)
    root.content_scale_size = Vector2i(1152,648)
    var review := Node2D.new()
    root.add_child(review)
    var background := ColorRect.new()
    background.size = Vector2(1152,648)
    background.color = Color("#18292e")
    review.add_child(background)
    caption(review,"GALESHEAR / COMPLETE WING SILHOUETTES",Vector2(28,12),30)
    caption(review,"Original left · repaired right / native game textures at 2x",Vector2(28,50),20)
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
            var old := Image.load_from_file(BEFORE+filename)
            var current: Texture2D = load("res://assets/sprites/arena/galeshear/small/"+filename)
            pairs[i][0].texture = ImageTexture.create_from_image(old)
            pairs[i][1].texture = current
            for sprite in pairs[i]:
                var bounds: Rect2i = sprite.texture.get_image().get_used_rect()
                sprite.offset = Vector2(0,sprite.texture.get_height()*0.5-bounds.end.y)
            var used := current.get_image().get_used_rect()
            verify(filename+" clear borders",used.position.x >= 3 and used.position.y >= 3 and used.end.x <= current.get_width()-3 and used.end.y <= current.get_height()-3)
        await frames(2)
        await capture("stills" if frame < 0 else "walk-frame-%d"%frame)
    review.queue_free()
    await frames(2)
    var arena: Node2D = load("res://scenes/arena_prototype.tscn").instantiate()
    root.add_child(arena)
    current_scene = arena
    await frames(3)
    arena._you = 8
    arena._you_stage = 2
    arena._rival = 0
    arena._rival_stage = 2
    arena.team_size = 1
    arena._new_match()
    await frames(3)
    arena.set_process(false)
    arena._fighters[0]["target"] = -1
    verify("Latest arena loads Galeshear",arena._fighters[0]["name"] == "Galeshear")
    for facing in FACINGS:
        var fighter: Dictionary = arena._fighters[0]
        fighter["facing"] = facing
        fighter["walk"] = 0.0
        arena._update_fighter(0,0.0)
        await frames(2)
        await capture("arena-"+facing)
        for frame in 8:
            fighter["walk"] = (float(frame)+0.1)/(arena.WALK_FPS*fighter["speed"])
            arena._update_fighter(0,0.0)
            verify("Runtime walk "+facing+str(frame),fighter["sprite"].texture == fighter["art"]["walk"][facing][frame])
    arena.set_process(true)
    for fighter in arena._fighters: fighter["stun"] = 60.0
    arena._fighters[0]["stun"] = 0.0
    arena._fighters[0]["meter"] = 100
    arena.signature(0)
    await frames(60)
    await capture("gale-shear")
    verify("Current signature runs with repaired art",arena._sig.active)
    FileAccess.open(OUT+"checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"  "))
    print("RESULT ",checks.size()," checks / ",failures.size()," failures")
    quit(0 if failures.is_empty() else 1)
