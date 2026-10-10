extends SceneTree
const OUT="D:/dev/hollowtide-title-refinement-20261010/review/"
var passed:=0
var failed:=0
func _initialize() -> void:call_deferred("run")
func frames(n:int) -> void:
    for i in n:await process_frame
func verify(ok:bool,label:String) -> void:
    if ok:passed+=1;print("PASS ",label)
    else:failed+=1;push_error(label)
func key(code:Key) -> void:
    for down in [true,false]:
        var e:=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=down
        Input.parse_input_event(e);await frames(3)
func pad(code:JoyButton) -> void:
    for down in [true,false]:
        var e:=InputEventJoypadButton.new();e.button_index=code;e.pressed=down
        Input.parse_input_event(e);await frames(3)
func click(c:Control) -> void:
    var at:=c.get_global_rect().get_center()
    for down in [true,false]:
        var e:=InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.position=at;e.pressed=down
        Input.parse_input_event(e);await frames(3)
func shot(name:String) -> void:
    await frames(3);root.get_texture().get_image().save_png(OUT+name+".png")
func inside(c:Control) -> bool:
    var rect:=c.get_global_rect()
    return rect.position.x>=0 and rect.position.y>=0 and rect.end.x<=1152 and rect.end.y<=648
func run() -> void:
    root.size=Vector2i(1152,648)
    var cfg:=ConfigFile.new();cfg.set_value("menu","reduce_motion",false);cfg.save("user://menu_preferences.cfg")
    var m:Node=load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
    root.add_child(m);current_scene=m
    await frames(2);await shot("launch-prelude")
    await pad(JOY_BUTTON_A);await frames(20)
    verify(m._boot_done and current_scene==m and m._page=="main","Pad boot skip lands on title, not New Game")
    verify((m._boot.get_child(0) as ColorRect).color==Color("#161f1b") and m._launch_hint.text=="A to continue","Launch card shares forest palette and controller hint")
    verify(root.gui_get_focus_owner()==m._buttons[0],"New Game has first focus")
    verify(m._buttons.size()==4 and m._focus_controls.map(func(c:Control):return c.name)==[&"NewGame",&"Options",&"HowToPlay",&"Quit"],"Visible and controller order agree; Quit last")
    verify(inside(m._main_panel),"Four choices and hints fit the viewport")
    verify(m._main_panel.get_global_rect().end.y<=628,"Main menu has space below its bottom frame")
    verify(m.get_node("CreatureVillage").texture.resource_path.ends_with("creature_village_2026_10_09.png") and m._idle_actors.is_empty(),"Approved village retained without title creatures")
    verify(m._input_hint.text.contains("D-pad"),"Controller hints follow real pad input")
    await shot("title-controller")
    await pad(JOY_BUTTON_DPAD_DOWN);await pad(JOY_BUTTON_DPAD_DOWN)
    verify(root.gui_get_focus_owner()==m._help_button and m._action_copy.text.contains("Highbank"),"Pad reaches Help and updates action description")
    await pad(JOY_BUTTON_A)
    verify(m._page=="help" and m._help_panel.visible and not m._main_panel.visible,"Pad opens Help without starting a game")
    verify(m._help_topic=="journey" and inside(m._help_panel),"Journey guide fits screen")
    await shot("help-journey")
    await pad(JOY_BUTTON_DPAD_RIGHT);await pad(JOY_BUTTON_A)
    verify(m._help_topic=="controls" and root.gui_get_focus_owner()==m._help_controls[1],"Pad switches help topic and preserves its focus")
    verify(inside(m._help_panel),"Controls guide fits screen")
    await shot("help-controls")
    await pad(JOY_BUTTON_B)
    verify(m._page=="main" and root.gui_get_focus_owner()==m._help_button,"Pad Back restores originating How to play choice")
    await key(KEY_DOWN)
    verify(root.gui_get_focus_owner()==m._buttons[2] and m._input_hint.text.contains("Enter"),"Keyboard follows visible order and switches hints")
    await key(KEY_DOWN)
    verify(root.gui_get_focus_owner()==m._buttons[0],"Focus wraps from Quit to New Game")
    await click(m._buttons[1]);verify(m._page=="options" and inside(m._options_panel),"Mouse opens styled Options inside screen")
    verify(m._input_device=="mouse" and m._input_hint.text.begins_with("Click"),"Actual mouse input updates choice hint")
    await shot("title-options")
    await key(KEY_ESCAPE)
    verify(root.gui_get_focus_owner()==m._buttons[1],"Options Back restores Options focus")
    await click(m._buttons[2]);verify(m._page=="quit" and inside(m._quit_panel) and root.gui_get_focus_owner()==m._quit_controls[0],"Quit confirms with safe Back focus")
    await shot("title-quit")
    await key(KEY_ESCAPE);await click(m._help_button)
    await click(m._help_controls[3])
    verify(m._page=="main" and root.gui_get_focus_owner()==m._help_button,"Mouse Help Back restores Help focus")
    await click(m._help_button)
    verify(m._help_topic=="controls","Reopening Help retains the selected topic")
    await click(m._help_controls[2]);await frames(28)
    var p:Node=current_scene
    verify(p!=m and p.has_method("choose") and p.phase==0,"Help Start New Game opens the existing creature awakening")
    await pad(JOY_BUTTON_B);await frames(70)
    var title:Node=current_scene
    verify(title.has_method("_open_help") and title._page=="main","Story Back returns to refined title")
    await key(KEY_UP);await key(KEY_DOWN)
    await shot("title-keyboard")
    await click(title._buttons[1]);await click(title._motion_button);await key(KEY_ESCAPE)
    verify(title._reduce_motion,"Real Options toggle enables Reduce Motion")
    await click(title._help_button);await click(title._help_controls[2]);await frames(16)
    verify(current_scene.has_method("choose") and current_scene.reduce_motion,"Guide New Game carries Reduce Motion into creature opening")
    print("TITLE_RESULT passes=%d failures=%d"%[passed,failed])
    current_scene.queue_free();await frames(45)
    for n in root.get_children():n.queue_free()
    load("res://scripts/audio/music.gd")._inst=null
    await frames(4);quit.call_deferred(0 if failed==0 else 1)
