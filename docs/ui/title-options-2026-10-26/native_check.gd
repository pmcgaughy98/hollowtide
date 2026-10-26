extends SceneTree
const W := "D:/dev/hollowtide-title-options-20261026"
const UI := preload("res://scripts/ui/ui_style.gd")
const ControlsText := preload("res://scripts/ui/controls_text.gd")
const Team := preload("res://scripts/town/team_state.gd")
const PauseBase := preload("res://scripts/ui/game_pause_menu.gd")
var phase := "before"
var total := 0
var failed := 0
var bounds := {}
func _initialize() -> void:_run.call_deferred()
func frames(n: int) -> void:
	for i in n:await process_frame
func check(label: String, ok: bool) -> void:
	total+=1
	if not ok:failed+=1
	print("OPTIONS_CHECK ",label," -> ","ok" if ok else "FAIL")
func cfg(path: String) -> ConfigFile:
	var c:=ConfigFile.new();c.load(path);return c
func text_in(n: Node) -> String:
	var out: String=n.text+"\n" if n is Label else ""
	for child in n.get_children():out+=text_in(child)
	return out
func fit(panel: Control, key: String) -> void:
	var r:=panel.get_global_rect();bounds[key]=[r.position.x,r.position.y,r.size.x,r.size.y]
	check(key+" panel frame inside safe screen",r.position.x>=16 and r.position.y>=0 and r.end.x<=1136 and r.end.y<=636)
func shot(name: String) -> void:
	await frames(4);await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(W+"/native-"+phase+"/"+name+".png")
func key(code: Key) -> InputEventKey:
	var e:=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=true;return e
func seed_settings() -> void:
	var c:=ConfigFile.new();c.set_value("audio","master",100.0);c.set_value("audio","music",100.0);c.set_value("audio","sfx",100.0);c.set_value("menu","reduce_motion",false);c.set_value("menu","courier","Female");c.save(UI.PREFS_PATH)
	var g:=ConfigFile.new();g.set_value("menu","text_speed",1);g.set_value("display","fullscreen",false);g.set_value("future_game","marker","keep");g.save(UI.GAME_PREFS_PATH);UI.reload_prefs()
func _run() -> void:
	phase=OS.get_environment("HT_OPTIONS_PHASE")
	root.size=Vector2i(1152,648);root.content_scale_size=Vector2i(1152,648)
	Team.save_path="user://title-options-private.save"
	DirAccess.make_dir_recursive_absolute(W+"/native-"+phase)
	if phase!="restart":seed_settings()
	var prefs=root.get_node("InputPrefs")
	if phase=="restart":prefs.apply_saved(true)
	var title=load("res://scenes/creature_opening.tscn").instantiate();root.add_child(title)
	var waited:=0
	while not(title._boot_done and title._page=="main") and waited<300:await process_frame;waited+=1
	check("title reaches main",title._boot_done and title._page=="main")
	title._on_options();await frames(6)
	fit(title._options_panel,"options")
	check("Options does not pause the title",not paused)
	if phase=="before":
		check("title has three volume sliders",title._options_controls.filter(func(c):return c is HSlider).size()==3)
		await shot("options")
		title._close_panel();await frames(3);title._open_help();title._show_help_topic("controls");await frames(5)
		var words:=text_in(title._help_copy)
		check("keyboard help includes live run and message bindings",words.contains("Ctrl") and words.contains("messages"))
		await shot("controls-keyboard")
	else:
		var host: CanvasLayer=title._title_settings
		var content: VBoxContainer=host.content
		var sliders: Array=host.controls.filter(func(c):return c is HSlider)
		check("reuses three pause volume rows and all options",sliders.size()==3 and content.has_node("ScreenMode") and content.has_node("TextSpeed") and content.has_node("ReduceMotion") and content.has_node("Rebind"))
		check("settings host is the existing pause menu family",host is PauseBase)
		var look=preload("res://scripts/ui/game_pause_menu.gd")
		var parts: Dictionary=look._slider_parts
		check("all sliders use the exact shared fill track and knob",sliders.all(func(s):return s.get_theme_stylebox("slider")==parts["track"] and s.get_theme_stylebox("grabber_area")==parts["fill"] and s.get_theme_icon("grabber")==parts["knob"]))
		await shot("options")
		if phase=="after":
			for entry in [[0,55.0,"master"],[1,35.0,"music"],[2,20.0,"sfx"]]:
				(sliders[entry[0]] as HSlider).value=entry[1]
				check("real "+entry[2]+" slider saves and applies bus",cfg(UI.PREFS_PATH).get_value("audio",entry[2],0)==entry[1] and is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(["Master","Music","SFX"][entry[0]]))),entry[1]/100.0))
			content.get_node("TextSpeed").pressed.emit();check("Text speed row saves shared game key",UI.text_speed()==2)
			content.get_node("ReduceMotion").pressed.emit();check("motion row refreshes title fields and shared cache",title._reduce_motion and UI.reduce_motion())
			content.get_node("ScreenMode").pressed.emit();await frames(3)
			check("screen row applies full screen and stores shared key",UI.screen_full() and DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN)
			content.get_node("ScreenMode").pressed.emit();await frames(4)
			check("screen row returns to windowed and saves it",not UI.screen_full() and DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_WINDOWED)
			check("title-owned audio fields stay synchronized",title._master_volume==55 and title._music_volume==35 and title._sfx_volume==20)
			content.get_node("Rebind").pressed.emit();await frames(6)
			fit(title._options_panel,"rebind")
			var rebind=host.content.get_node("RebindPage")
			rebind.listen("attack");rebind.take(key(KEY_K));await frames(5)
			check("title rebind page changes actual saved attack",UI.binding_text("attack","keyboard")=="K" and cfg(UI.GAME_PREFS_PATH).has_section_key("input","attack"))
			await shot("rebind")
			rebind.listen("bag")
			Input.parse_input_event(key(KEY_ESCAPE));await frames(4)
			check("cancel listening stays on rebind without closing title",host.page=="rebind" and rebind.listening=="" and title._page=="options")
			Input.parse_input_event(key(KEY_ESCAPE));await frames(5)
			check("cancel rebind returns to Options",host.page=="options" and host.overlay.visible)
		else:
			check("fresh process restores audio motion and courier",title._master_volume==55 and title._music_volume==35 and title._sfx_volume==20 and title._reduce_motion and title._selected_courier=="Female")
			check("fresh process restores text speed and custom attack",UI.text_speed()==2 and UI.binding_text("attack","keyboard")=="K")
		host.content.get_node("Back").pressed.emit();await frames(5)
		check("Back returns to Options button without pausing tree",title._page=="main" and not host.overlay.visible and not paused and root.gui_get_focus_owner().name=="Options")
		title._open_help();title._show_help_topic("controls");await frames(5)
		fit(title._help_panel,"help-keyboard")
		var words:=text_in(title._help_copy)
		check("keyboard Help equals current shared source",ControlsText.groups("keyboard").all(func(g):return words.contains(g["head"]) and g["lines"].all(func(s):return words.contains(s))) and words.contains(ControlsText.note("keyboard")))
		check("Help contains rebound attack plus second key run and messages",words.contains("K / Space: attack") and words.contains("Ctrl") and words.contains("messages"))
		check("active Controls tab has focused frame",(title._help_controls[1] as Button).get_theme_stylebox("normal").texture==UI.frame("panel_focus").texture and (title._help_controls[0] as Button).get_theme_stylebox("normal").texture==UI.frame("panel").texture)
		if phase=="after":
			prefs.save_binding("attack",key(KEY_U));await frames(4)
			check("open Help refreshes immediately after a binding save",text_in(title._help_copy).contains("U / Space: attack"))
			prefs.save_binding("attack",key(KEY_K));await frames(4)
		await shot("controls-keyboard")
		Input.parse_input_event(key(KEY_PAGEDOWN));await frames(4)
		check("keyboard Page Down scrolls Help to remaining text",title._help_scroll.scroll_vertical>0)
		await shot("controls-keyboard-bottom")
		var pad:=InputEventJoypadMotion.new();pad.axis=JOY_AXIS_LEFT_X;pad.axis_value=0.8
		Input.parse_input_event(pad);await frames(6)
		words=text_in(title._help_copy)
		check("real pad input refreshes open Help to controller bindings",UI.last_device()=="pad" and words.contains(ControlsText.note("pad")) and ControlsText.groups("pad").all(func(g):return g["lines"].all(func(s):return words.contains(s))))
		fit(title._help_panel,"help-pad")
		title._help_scroll.scroll_vertical=0;await frames(3)
		await shot("controls-pad")
		var scroll: ScrollContainer=title._help_scroll
		scroll.scroll_vertical=100000;await frames(4)
		check("scroll exposes final Controls note and keeps actions visible",scroll.scroll_vertical>0 and title._help_copy.get_global_rect().end.y<=scroll.get_global_rect().end.y+2 and title._help_panel.get_global_rect().encloses(title._help_controls[3].get_global_rect()))
		await shot("controls-pad-bottom")
		UI.set_device("keyboard");prefs.device_changed.emit("keyboard");await frames(4)
		title._show_help_topic("journey");await frames(5)
		fit(title._help_panel,"help-journey")
		check("journey tab remains focused and story text preserved",(title._help_controls[0] as Button).get_theme_stylebox("normal").texture==UI.frame("panel_focus").texture and text_in(title._help_copy).contains("A voice beneath the riverbank"))
		await shot("help-journey")
	title.queue_free();await frames(4)
	var music=root.get_node_or_null("HollowtideMusic")
	if music!=null:music.queue_free()
	if is_instance_valid(UI._blip):UI._blip.queue_free()
	await frames(4)
	var result={"phase":phase,"passed":total-failed,"total":total,"failed":failed,"bounds":bounds}
	var f=FileAccess.open(W+"/"+phase+"-result.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"\t"));f.close();print("OPTIONS RESULT ",JSON.stringify(result))
	quit(0 if phase=="before" or failed==0 else 1)
