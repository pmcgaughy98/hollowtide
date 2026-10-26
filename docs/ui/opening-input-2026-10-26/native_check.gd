extends SceneTree
const W := "D:/dev/hollowtide-opening-input-20261026"
const UI := preload("res://scripts/ui/ui_style.gd")
const Team := preload("res://scripts/town/team_state.gd")
var total := 0
var failed := 0
var facts: Array = []
func _initialize() -> void:_run.call_deferred()
func frames(n: int) -> void:
    for i in n:await process_frame
func check(label: String, good: bool) -> void:
    total+=1
    if not good:failed+=1
    facts.append({"check":label,"passed":good});print("OPEN_INPUT_CHECK ",label," -> ","ok" if good else "FAIL")
func key(code: int, down:=true, echo:=false) -> InputEventKey:
    var e:=InputEventKey.new();e.physical_keycode=code;e.keycode=code;e.pressed=down;e.echo=echo;return e
func pad(code: int, down:=true) -> InputEventJoypadButton:
    var e:=InputEventJoypadButton.new();e.button_index=code;e.pressed=down;return e
func axis(code: int, value: float) -> InputEventJoypadMotion:
    var e:=InputEventJoypadMotion.new();e.axis=code;e.axis_value=value;return e
func release(e: InputEvent) -> InputEvent:
    var out:=e.duplicate()
    if out is InputEventJoypadMotion:out.axis_value=0.0
    else:out.pressed=false
    return out
func send(e: InputEvent, n:=2) -> void:
    Input.parse_input_event(e);await frames(n)
func tap(e: InputEvent) -> void:
    await send(e);await send(release(e))
func shot(tag: String) -> void:
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(W+"/native/"+tag+".png")
func drop(s: Node) -> void:
    if s.has_meta("handoff"):
        var hand: Node=s.get_meta("handoff")
        if is_instance_valid(hand):hand.free()
    s.queue_free();await frames(4)
func storm() -> Node:
    var s=load("res://scenes/storm_open.tscn").instantiate();s.reduce_motion=true;root.add_child(s);await frames(3);return s
func soul(choose:=false) -> Node:
    var s=load("res://scenes/soul_prologue.tscn").instantiate();root.add_child(s)
    if choose:s.stage="choose";s.line=s.LINES.size()-1;s.shown=s._text().length()
    await frames(4);return s
func skip_case(e: InputEvent, tag: String, picture:=false) -> void:
    var s=await storm();var before:=FileAccess.get_sha256(Team.save_path)
    await send(e)
    check(tag+" first press only arms skip",s._skip_armed and not s.leaving and not s.has_meta("next"))
    if e is InputEventKey:await send(key(e.physical_keycode,true,true))
    await send(e.duplicate())
    check(tag+" repeat before release cannot skip",not s.leaving)
    await send(release(e))
    check(tag+" release opens second-press gate",s._skip_released)
    if picture:
        await shot(tag)
        check(tag+" visible bound-key prompt fits",s._skip_hint.visible and UI.width_in(s._skip_hint.text,"label")<=s._skip_hint.size.x and s._skip_hint.text.contains("Press again to skip"))
    await send(e.duplicate())
    check(tag+" second press enters existing soul destination",s.leaving and s.get_meta("next","")==s.NEXT)
    check(tag+" private saved journey unchanged",FileAccess.get_sha256(Team.save_path)==before)
    await send(release(e));await drop(s)
func advance_case(e: InputEvent, tag: String) -> void:
    var s=await soul();s.shown=s._text().length();UI.finish_line()
    await send(e)
    check(tag+" advances exactly one story line",s.line==1 and s.stage=="talk")
    if e is InputEventKey:
        var before: int=s.line;await send(key(e.physical_keycode,true,true));check(tag+" echo never advances again",s.line==before)
    await send(release(e));await drop(s)
func _run() -> void:
    root.size=Vector2i(1152,648);root.content_scale_size=root.size
    DirAccess.make_dir_recursive_absolute(W+"/native")
    var cfg:=ConfigFile.new();cfg.set_value("menu","reduce_motion",false);cfg.save("user://menu_preferences.cfg");UI.reload_prefs()
    Team.save_path="user://opening-input-private.save";Team.erase_save();Team.data={"party":[[0,0]],"levels":{0:{"lv":8}}};Team.save()
    for item in [[key(KEY_E),"storm-E"],[key(KEY_J),"storm-J"],[key(KEY_ENTER),"storm-Enter"],[key(KEY_SPACE),"storm-Space"],[pad(JOY_BUTTON_A),"storm-pad-A"],[pad(JOY_BUTTON_X),"storm-pad-X"]]:
        await skip_case(item[0],item[1],item[1] in ["storm-Enter","storm-pad-A"])
    var s=await storm()
    check("storm hint begins hidden",not s._skip_hint.visible)
    await frames(125)
    check("storm hint appears after four seconds without arming",s._t>=4.0 and s._skip_hint.visible and not s._skip_armed and not s.leaving)
    await shot("storm-idle-hint");await drop(s)
    for item in [[key(KEY_E),"soul-E"],[key(KEY_J),"soul-J"],[key(KEY_ENTER),"soul-Enter"],[key(KEY_SPACE),"soul-Space"],[pad(JOY_BUTTON_A),"soul-pad-A"],[pad(JOY_BUTTON_X),"soul-pad-X"]]:await advance_case(item[0],item[1])
    s=await soul(true)
    await send(axis(JOY_AXIS_LEFT_X,0.9));check("left stick selects once",s.pick==1)
    await send(axis(JOY_AXIS_LEFT_X,0.95));check("held stick does not repeat",s.pick==1)
    await send(axis(JOY_AXIS_LEFT_X,0.0));await send(axis(JOY_AXIS_LEFT_X,0.9));check("centred stick can select again in same direction",s.pick==2)
    await send(axis(JOY_AXIS_LEFT_X,0.0));await send(axis(JOY_AXIS_LEFT_X,-0.9));check("stick opposite direction works",s.pick==1)
    await send(axis(JOY_AXIS_LEFT_X,0.0));await shot("soul-pad-choice")
    var chosen: int=s.pick;await tap(pad(JOY_BUTTON_A));check("pad confirms one selected creature",s.stage=="after" and s.chosen==chosen and s.line==0)
    await drop(s)
    var prefs:=root.get_node("InputPrefs")
    for item in [["confirm",KEY_K,0],["confirm",KEY_V,1],["attack",KEY_C,0],["attack",KEY_U,1],["interact",KEY_O,0],["move_left",KEY_F,0],["move_left",KEY_Q,1],["move_right",KEY_H,0],["move_right",KEY_R,1],["cancel",KEY_B,0]]:
        check("save private binding "+str(item[0])+"/"+str(item[2]),prefs.save_binding(item[0],key(item[1]),item[2]))
    var saved:=UI.load_game_prefs();var bindings=saved.get_section_keys("input")
    # Restore only the map, keeping the saved file; a fresh apply must recover these choices.
    for action in bindings:
        var defaults: Dictionary=ProjectSettings.get_setting("input/"+action)
        InputMap.action_erase_events(action)
        for ev in defaults.get("events",[]):InputMap.action_add_event(action,ev.duplicate())
    check("saved bindings reapply from private file",prefs.apply_saved(true)>=bindings.size())
    s=await soul(true)
    await tap(key(KEY_D));await tap(key(KEY_A));check("retired raw A/D keys no longer bypass rebind",s.pick==0)
    await tap(key(KEY_R));check("saved rebound right works",s.pick==1)
    await tap(key(KEY_Q));check("saved rebound left works",s.pick==0)
    for code in [KEY_J,KEY_E,KEY_SPACE,KEY_ENTER]:await tap(key(code))
    check("retired raw advance keys no longer bypass rebind",s.stage=="choose" and s.chosen==-1)
    await shot("soul-rebound-choice")
    var before:=FileAccess.get_sha256(Team.save_path);await tap(key(KEY_K))
    check("saved rebound confirm chooses once",s.stage=="after" and s.chosen==0 and s.line==0)
    check("choice input leaves saved journey untouched",FileAccess.get_sha256(Team.save_path)==before)
    await drop(s)
    await skip_case(key(KEY_K),"storm-rebound-K",true)
    check("save advance trigger rebind",prefs.save_binding("confirm",axis(JOY_AXIS_TRIGGER_RIGHT,1.0)))
    await skip_case(axis(JOY_AXIS_TRIGGER_RIGHT,0.9),"storm-trigger",false)
    # A rebound keyboard advance works on the boot and focused title buttons; loading changes no map.
    var map_before=InputMap.action_get_events("ui_accept").map(func(ev):return UI._input_id(ev))
    var title: Node=load("res://scenes/creature_opening.tscn").instantiate();root.add_child(title);await frames(2)
    await tap(key(KEY_K));check("rebound key consumes title prelude",title._boot_fading or title._boot_done)
    for i in 120:
        if title._boot_done:break
        await process_frame
    await frames(3)
    check("prelude key never starts New Game",title._boot_done and title._page=="main" and not title._leaving)
    check("title no longer patches input map",not title.has_method("_ensure_menu_inputs") and map_before==InputMap.action_get_events("ui_accept").map(func(ev):return UI._input_id(ev)))
    var options: Button=title._buttons.filter(func(b):return b.name=="Options")[0];options.grab_focus();await frames(2);await tap(key(KEY_K))
    check("rebound key opens focused title Options",title._page=="options")
    await tap(key(KEY_B));check("rebound Back closes Options",title._page=="main" and root.gui_get_focus_owner()==options)
    var help: Button=title._buttons.filter(func(b):return b.name=="HowToPlay")[0];help.grab_focus();await frames(2);await tap(key(KEY_K))
    check("rebound key opens focused title Help",title._page=="help")
    await tap(key(KEY_B));check("rebound Back returns to Help button",title._page=="main" and root.gui_get_focus_owner()==help)
    await drop(title);prefs.reset_defaults()
    Team.erase_save()
    if is_instance_valid(UI._blip):UI._blip.free()
    var music:=root.get_node_or_null("HollowtideMusic")
    if music!=null:music.queue_free()
    await frames(6)
    var result: Dictionary={"total":total,"passed":total-failed,"failed":failed,"checks":facts}
    var f:=FileAccess.open(W+"/native-result.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"\t"));f.close()
    print("OPENING INPUT RESULT ",JSON.stringify({"total":total,"passed":total-failed,"failed":failed}));quit(0 if failed==0 else 1)
