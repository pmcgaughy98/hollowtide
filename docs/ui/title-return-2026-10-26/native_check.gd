extends SceneTree
const W := "D:/dev/hollowtide-title-return-20261026"
const UI := preload("res://scripts/ui/ui_style.gd")
const Team := preload("res://scripts/town/team_state.gd")
var phase := "before"
var legacy := false
var checks: Array=[]
var failures: Array=[]
var metrics: Array=[]
var sounds: Array=[]
func _initialize() -> void:_run.call_deferred()
func frames(n: int) -> void:
	for i in n:await process_frame
func check(label: String, good: bool) -> void:
	checks.append({"check":label,"passed":good})
	if not good:failures.append(label)
	print(label,": ","PASS" if good else "FAIL")
func alpha(item: CanvasItem) -> float:return item.modulate.a if item.is_visible_in_tree() else 0.0
func sound(child: Node) -> void:
	if child is AudioStreamPlayer and child.stream!=null and child.stream.resource_path.ends_with("/cursor.wav"):sounds.append("cursor")
	if child is AudioStreamPlayer and child.stream!=null and child.stream.resource_path.ends_with("/confirm.wav"):sounds.append("confirm")
func load_title() -> Node:
	var s: Node=load("res://scenes/opening_flow.tscn" if legacy else "res://scenes/creature_opening.tscn").instantiate()
	s.child_entered_tree.connect(sound);root.add_child(s);return s
func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(W+"/"+phase+"/"+name+".png")
func key(code: Key, down: bool) -> void:
	var e:=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=down;Input.parse_input_event(e)
func send(kind: String, down: bool) -> void:
	match kind:
		"keyboard":await key(KEY_ENTER,down)
		"rebound":await key(KEY_Q,down)
		"pad":
			var e:=InputEventJoypadButton.new();e.device=0;e.button_index=JOY_BUTTON_A;e.pressed=down;Input.parse_input_event(e)
		"mouse":
			var e:=InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.position=Vector2(575,400);e.global_position=e.position;e.pressed=down;Input.parse_input_event(e)
func close_title(s: Node) -> void:
	if legacy:
		for i in 300:
			if s._route_scene!=null or s._route_request_error!=OK:break
			await process_frame
	s.queue_free();await frames(5)
func one(kind: String, reduced: bool) -> void:
	var tag: String=("reduced-" if reduced else "normal-")+kind
	var cfg:=ConfigFile.new();cfg.set_value("menu","reduce_motion",reduced);cfg.set_value("future","keep","untouched");cfg.save("user://menu_preferences.cfg");UI.reload_prefs()
	var pref:=FileAccess.get_sha256("user://menu_preferences.cfg")
	if phase.begins_with("after"):
		var flow: Resource=load("res://scripts/opening_flow.gd")
		flow.set("_launch_seen",false)
	sounds=[];var s:=load_title();var start_hint: String=""
	for child in s._boot.get_children():
		if child is Label:start_hint=child.text
	var overlap:=0;var done:=-1;var hint_updated:=false;var pad_hint:=false
	for f in 110:
		if kind!="auto" and f==2:await send(kind,true)
		if kind!="auto" and f==3:await send(kind,false)
		await process_frame;await RenderingServer.frame_post_draw
		if f==0:await shot(tag+"-launch")
		if alpha(s._boot)>0.001 and alpha(s._wordmark)>0.001:overlap+=1
		if phase.begins_with("after") and kind=="rebound" and not s._boot_done:hint_updated=hint_updated or s._boot_hint.text.contains("Q")
		if phase.begins_with("after") and kind=="pad" and f>=2:pad_hint=pad_hint or (s._boot_hint.text.contains(UI.binding_text("confirm")) and UI.last_device()=="pad")
		if s._boot_done:done=f;break
	await frames(2)
	check(tag+" first launch reaches main",done>=0 and s._page=="main" and not s._leaving)
	check(tag+" no simultaneous launch/menu logos",overlap==0)
	check(tag+" first focus is silent",sounds.is_empty())
	check(tag+" first focus belongs to first menu action",root.gui_get_focus_owner()==s._buttons[0])
	if phase.begins_with("after"):
		check(tag+" auto splash advertises skipping, not a required key",start_hint.contains("Skip") and not start_hint.to_lower().contains("continue"))
		check(tag+" prelude and captions hidden at zero alpha",not s._boot.visible and s._boot.modulate.a==0.0 and s._boot.get_children().filter(func(c):return c is Label).all(func(c):return not c.visible and c.modulate.a==0.0))
		if kind=="rebound":check("Live rebound Q appears in splash hint",hint_updated)
		if kind=="pad":check("Splash hint follows controller binding",pad_hint)
		if kind=="auto":check(tag+" first launch still displays its timed card",done>=3 and done<=8 if reduced else done>=55)
		check(tag+" skip cannot activate New Game",not s._leaving)
	await shot(tag+"-menu")
	# A page's own initial focus should not add a cursor or a second confirm.
	var option: Button=s._buttons.filter(func(b):return b.name=="Options")[0]
	s._quiet_focus=true;option.grab_focus();s._quiet_focus=false;sounds.clear();s._title_settings.sounds.clear()
	if kind=="mouse":
		for down in [true,false]:
			var click:=InputEventMouseButton.new();click.button_index=MOUSE_BUTTON_LEFT;click.position=option.get_global_rect().get_center();click.global_position=click.position;click.pressed=down
			Input.parse_input_event(click);await frames(2)
	else:
		var action: String=kind if kind in ["pad","rebound"] else "keyboard"
		await send(action,true);await frames(2);await send(action,false);await frames(2)
	check(tag+" Options opens",s._page=="options" and s._title_settings.overlay.visible)
	check(tag+" Options plays exactly one confirm",sounds==["confirm"])
	check(tag+" Options initial shared focus is quiet",s._title_settings.sounds.is_empty())
	await close_title(s)
	var return_pref:=FileAccess.get_sha256("user://menu_preferences.cfg")
	var return_game_pref:=FileAccess.get_sha256("user://game_prefs.cfg")
	# The next instance represents returning to the title in this process.
	sounds=[];var again:=load_title();var immediately: bool=again._boot_done;var return_frames:=0
	for f in 110:
		if again._boot_done:break
		return_frames+=1;await process_frame
	await frames(2);await shot(tag+"-return")
	metrics.append({"case":tag,"first_done_frame":done,"first_hint":start_hint,"return_ready_in_ready":immediately,"return_wait_frames":return_frames})
	if phase.begins_with("after"):
		check(tag+" return opens main before first draw",immediately and return_frames==0 and again._page=="main")
		check(tag+" return has no dim menu or launch card",not again._boot.visible and again._boot.modulate.a==0.0 and alpha(again._wordmark)==1.0 and alpha(again._main_panel)==1.0)
		check(tag+" return focus is silent",sounds.is_empty())
	check(tag+" returning alone leaves preferences byte exact",FileAccess.get_sha256("user://menu_preferences.cfg")==return_pref)
	check(tag+" returning alone leaves game preferences byte exact",FileAccess.get_sha256("user://game_prefs.cfg")==return_game_pref)
	var kept:=ConfigFile.new();kept.load("user://menu_preferences.cfg")
	var game_kept:=ConfigFile.new();game_kept.load("user://game_prefs.cfg")
	check(tag+" unknown preferences survive existing migration",kept.get_value("future","keep","")=="untouched" or game_kept.get_value("future","keep","")=="untouched")
	await close_title(again)
func pause_return() -> void:
	var host:=Node2D.new();root.add_child(host);current_scene=host
	var pause: Node=load("res://scripts/ui/game_pause_menu.gd").new();host.add_child(pause);await frames(3)
	pause.open();pause.show_page("title");await frames(3)
	check("Pause Return to title confirmation offers expected action",pause.content.get_node_or_null("ConfirmLeave")!=null)
	pause.content.get_node("ConfirmLeave").grab_focus()
	await key(KEY_ENTER,true);await frames(2);await key(KEY_ENTER,false)
	var seen:=false
	for i in 100:
		await process_frame
		if current_scene!=host and is_instance_valid(current_scene):seen=true;break
	check("Actual pause confirmation returns to campaign title",seen and current_scene.scene_file_path.ends_with("creature_opening.tscn"))
	if not seen:return
	var s: Node=current_scene
	check("Actual paused return never rebuilds the splash hold",s._boot_done and not s._boot.visible and s._wordmark.modulate.a==1.0)
	await frames(12);await shot("actual-pause-return")
	check("Return fade lifts onto usable main page",s._page=="main" and not paused and root.gui_get_focus_owner()==s._buttons[0])
	s.queue_free();current_scene=null;await frames(5)
func _run() -> void:
	var args:=OS.get_cmdline_user_args();phase=args[0];legacy=args.has("legacy")
	if legacy:phase+="-legacy"
	DirAccess.make_dir_recursive_absolute(W+"/"+phase)
	root.size=Vector2i(1152,648);root.content_scale_size=root.size
	Team.save_path="user://title-return-private.save";Team.erase_save();Team.data={"party":[[0,0]]};Team.save();var saved:=FileAccess.get_sha256(Team.save_path)
	var original: Array=InputMap.action_get_events("confirm").duplicate()
	if phase=="before":await one("auto",false)
	else:
		for kind in (["auto"] if legacy else ["auto","keyboard","pad","mouse"]):await one(kind,false)
		await one("auto",true)
		if not legacy:
			InputMap.action_erase_events("confirm");var q:=InputEventKey.new();q.physical_keycode=KEY_Q;InputMap.action_add_event("confirm",q);UI.set_device("keyboard")
			await one("rebound",false)
			InputMap.action_erase_events("confirm")
			for e in original:InputMap.action_add_event("confirm",e)
			await pause_return()
	check("Private saved journey remains byte exact",FileAccess.get_sha256(Team.save_path)==saved);Team.erase_save()
	if is_instance_valid(UI._blip):UI._blip.free()
	for p in UI._ticks.values():
		if is_instance_valid(p):p.queue_free()
	var music:=root.get_node_or_null("HollowtideMusic")
	if music!=null:music.queue_free()
	await frames(6)
	var result:={"phase":phase,"total":checks.size(),"failed":failures.size(),"checks":checks,"metrics":metrics,"failures":failures}
	var f:=FileAccess.open(W+"/"+phase+"-result.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"  "));f.close()
	print("TITLE RETURN RESULT ",checks.size()," checks / ",failures.size()," failures");quit(0 if failures.is_empty() else 1)
