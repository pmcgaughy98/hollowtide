extends SceneTree
const W := "D:/dev/hollowtide-title-logo-20261026"
const Team := preload("res://scripts/town/team_state.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
var phase := "before"
var legacy := false
var rows: Array = []
var cases: Array = []
var total := 0
var failed := 0
var cursor_ticks := 0
func _initialize() -> void: _run.call_deferred()
func frames(n: int) -> void:
    for i in n: await process_frame
func check(label: String, good: bool) -> void:
    total += 1
    if not good: failed += 1
    print("LOGO_CHECK ",label," -> ","ok" if good else "FAIL")
func note_sound(child: Node, title: Node) -> void:
    if child is AudioStreamPlayer and child.stream == title.CURSOR_SOUND: cursor_ticks += 1
func alpha(item: CanvasItem) -> float:
    return item.modulate.a if item.is_visible_in_tree() else 0.0
func key(down: bool) -> InputEventKey:
    var e:=InputEventKey.new();e.keycode=KEY_ENTER;e.physical_keycode=KEY_ENTER;e.pressed=down;return e
func send(kind: String, down: bool) -> void:
    if kind=="keyboard": Input.parse_input_event(key(down))
    elif kind=="pad":
        var e:=InputEventJoypadButton.new();e.button_index=JOY_BUTTON_A;e.pressed=down;Input.parse_input_event(e)
    elif kind=="mouse":
        var e:=InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.position=Vector2(20,20);e.global_position=e.position;e.pressed=down;Input.parse_input_event(e)
func shot(tag: String) -> void:
    root.get_texture().get_image().save_png(W+"/"+phase+"/"+tag+".png")
func one(kind: String, reduced: bool) -> void:
    var tag: String=("reduced-" if reduced else "normal-")+kind
    var cfg:=ConfigFile.new();cfg.set_value("menu","reduce_motion",reduced);cfg.save("user://menu_preferences.cfg")
    cursor_ticks=0
    var title: Node=load("res://scenes/opening_flow.tscn" if legacy else "res://scenes/creature_opening.tscn").instantiate()
    root.add_child(title);title.child_entered_tree.connect(note_sound.bind(title))
    var logo: CanvasItem=title._boot.get_node("LaunchWordmark")
    var overlap:=0;var during:=0;var premature:=0;var first_menu:=-1;var last_logo:=-1;var last_fade:=-1
    var boot_done_frame:=-1;var transitional:=0;var fade_frames:=0
    for f in 100:
        if kind!="auto" and f in [2,5,8]: send(kind,true)
        if kind!="auto" and f in [3,6,9]: send(kind,false)
        await process_frame
        await RenderingServer.frame_post_draw
        var old_a: float=alpha(title._boot)*alpha(logo)
        var menu_a: float=alpha(title._wordmark)
        var panel_a: float=alpha(title._main_panel)
        if old_a>0.001: last_logo=f
        if menu_a>0.001 and first_menu<0: first_menu=f
        if old_a>0.001 and menu_a>0.001: overlap+=1
        if title._boot_fading and not title._boot_done:
            during+=1
            if title._page!="boot" or title._leaving: premature+=1
        if menu_a>0.001 and menu_a<0.999: fade_frames+=1
        if title._boot_done and boot_done_frame<0: boot_done_frame=f
        if title._boot_done and (title._boot.visible or title._boot.modulate.a>0.001): last_fade=f
        rows.append({"case":tag,"frame":f,"launch_alpha":old_a,"menu_alpha":menu_a,"panel_alpha":panel_a,"boot_done":title._boot_done,"leaving":title._leaving})
        if kind=="auto" and f in [1,53,60,66,70,74,80]: shot(tag+"-f%03d"%f)
    var metrics: Dictionary={"case":tag,"overlap_frames":overlap,"last_launch_frame":last_logo,"first_menu_frame":first_menu,"menu_fade_frames":fade_frames,"done_frame":boot_done_frame,"cursor_ticks_at_load":cursor_ticks}
    cases.append(metrics)
    print("LOGO_METRIC ",JSON.stringify(metrics))
    check(tag+" title reaches playable menu",title._boot_done and title._page=="main" and not title._leaving)
    check(tag+" skip inputs never start New Game",premature==0 and not title._leaving)
    check(tag+" first menu button receives focus",root.gui_get_focus_owner()==title._buttons[0])
    check(tag+" respects private Reduce motion",title._reduce_motion==reduced)
    if phase!="before":
        check(tag+" no rendered frame contains both logos",overlap==0 and first_menu>last_logo)
        check(tag+" prelude hidden at alpha zero",last_fade<0 and not title._boot.visible and is_zero_approx(title._boot.modulate.a))
        check(tag+" reveal ends at full opacity",is_equal_approx(alpha(title._wordmark),1.0) and is_equal_approx(alpha(title._main_panel),1.0))
        check(tag+" silent initial focus",cursor_ticks==0)
        check(tag+" sequential fade or instant reduced swap",fade_frames==0 if reduced else fade_frames>=5)
    # Repeated completion calls do not reset the finished menu; real Options remains usable.
    title._finish_boot();await frames(2)
    check(tag+" completion is idempotent",title._boot_done and title._page=="main")
    if not legacy:
        title._buttons.filter(func(b):return b.name=="Options")[0].pressed.emit();await frames(2)
        check(tag+" Options still opens after reveal",title._page=="options" and title._options_panel.visible)
    if legacy:
        for i in 300:
            if title._route_scene!=null or title._route_request_error!=OK: break
            await process_frame
    title.queue_free();await frames(4)
func _run() -> void:
    var args:=OS.get_cmdline_user_args()
    if args.has("after"):phase="after"
    legacy=args.has("legacy")
    if legacy:phase+="-legacy"
    DirAccess.make_dir_recursive_absolute(W+"/"+phase)
    root.size=Vector2i(1152,648);root.content_scale_size=root.size
    Team.save_path="user://logo-check-private.save";Team.erase_save()
    for kind in (["auto"] if legacy else ["auto","keyboard","pad","mouse"]): await one(kind,false)
    for kind in (["auto"] if legacy else ["auto","keyboard"]): await one(kind,true)
    if is_instance_valid(UI._blip):UI._blip.free()
    var music:=root.get_node_or_null("HollowtideMusic")
    if music!=null:music.queue_free()
    await frames(4)
    var result: Dictionary={"phase":phase,"total":total,"passed":total-failed,"failed":failed,"cases":cases}
    var file:=FileAccess.open(W+"/"+phase+"-result.json",FileAccess.WRITE);file.store_string(JSON.stringify(result,"\t"));file.close()
    file=FileAccess.open(W+"/"+phase+"-frames.json",FileAccess.WRITE);file.store_string(JSON.stringify(rows));file.close()
    print("LOGO RESULT ",JSON.stringify(result));quit(0 if failed==0 else 1)
