extends SceneTree
const W := "D:/dev/hollowtide-title-new-game-20261026"
const UI := preload("res://scripts/ui/ui_style.gd")
const Team := preload("res://scripts/town/team_state.gd")
var total := 0
var failed := 0
var facts := {}
func _initialize() -> void:_run.call_deferred()
func frames(n: int) -> void:
	for i in n:await process_frame
func check(label: String, ok: bool) -> void:
	total+=1
	if not ok:failed+=1
	print("NEW_GAME_CHECK ",label," -> ","ok" if ok else "FAIL")
func file_hash() -> String:
	return FileAccess.get_sha256(Team.save_path) if FileAccess.file_exists(Team.save_path) else "none"
func shot(name: String) -> void:
	await frames(4);await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(W+"/native/"+name+".png")
func seed_record(where: String, level: int) -> void:
	Team.erase_save()
	Team.data={"party":[[0,0],[1,0]],"levels":{0:{"lv":level,"exp":0},1:{"lv":3,"exp":0}},"metas":{}}
	if where!="Highbank":
		Team.data["suspend"]={"dungeon":where,"floor_n":2,"floor_seed":17,"light":80,"turn":9}
	Team.save()
func launch() -> Node:
	var title=load(W+"/probe_title.gd").new();root.add_child(title)
	var waited:=0
	while not(title._boot_done and title._page=="main") and waited<300:await process_frame;waited+=1
	return title
func button(title: Node, name: String) -> Button:
	return title._buttons.filter(func(b):return b.name==name)[0]
func fit(title: Node, name: String) -> void:
	var r: Rect2=title._main_panel.get_global_rect();facts[name]=[r.position.x,r.position.y,r.size.x,r.size.y]
	check(name+" full main menu above key hint",r.position.y>=0 and r.end.y<=608 and r.end.x<=1136)
	if title._continue_details!=null:
		var detail: Label=title._continue_details
		check(name+" summary fits one line below Continue",UI.width_in(detail.text,"body")<=detail.size.x and detail.get_line_count()==1 and detail.get_global_rect().position.y>=title._continue_button.get_global_rect().end.y)
func drop(title: Node) -> void:
	title.queue_free();await frames(4)
func key(code: Key) -> InputEventKey:
	var e:=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=true;return e
func pad(code: int, down := true) -> InputEventJoypadButton:
	var e:=InputEventJoypadButton.new();e.button_index=code;e.pressed=down;return e
func _run() -> void:
	root.size=Vector2i(1152,648);root.content_scale_size=Vector2i(1152,648)
	Team.save_path="user://new-game-private.save"
	DirAccess.make_dir_recursive_absolute(W+"/native")
	Team.erase_save()
	var title=await launch()
	check("gate defaults off and no save has no Continue detail",not title.new_game_confirm_enabled and title._continue_button==null and title._continue_details==null)
	fit(title,"no-save")
	title.new_game_confirm_enabled=true
	button(title,"NewGame").pressed.emit()
	check("no save bypasses prompt even with preview flag on",title.launch_count==1 and not title._new_game_panel.visible and file_hash()=="none")
	await drop(title)
	for item in [["Highbank",7,"Highbank   Lv 7"],["first",12,"Rootbank Warren B2F   Lv 12"],["mouth",4,"Hollow Mouth B2F   Lv 4"],["hollow",18,"The Hollow B2F   Lv 18"]]:
		seed_record(item[0],item[1]);var before:=file_hash()
		Team.data={"private_sentinel":"do not load preview into the running team"}
		title=await launch()
		check(item[0]+" detail reads the saved place and leader level",title._continue_details.text==item[2] and Team.data.has("private_sentinel"))
		check(item[0]+" preview preserves saved bytes",file_hash()==before)
		fit(title,item[0])
		await shot("continue-"+item[0])
		check("installed prompt remains gated for "+item[0],not title.new_game_confirm_enabled)
		if item[0]=="Highbank":
			button(title,"NewGame").pressed.emit()
			check("default-off saved game retains existing launch behaviour",title.launch_count==1 and not title._new_game_panel.visible and file_hash()==before)
		await drop(title)
	# A valid backup supplies both Continue details and the existing recovery note.
	seed_record("Highbank",9)
	var original=FileAccess.get_file_as_bytes(Team.save_path)
	var f=FileAccess.open(Team.save_path+".bak",FileAccess.WRITE);f.store_buffer(original);f.close()
	f=FileAccess.open(Team.save_path,FileAccess.WRITE);f.store_string("cut");f.close()
	var corrupt_hash:=file_hash()
	title=await launch()
	check("backup details and existing recovery note both show",title._continue_details.text=="Highbank   Lv 9" and title._save_note!=null)
	fit(title,"backup")
	check("preview never repairs or overwrites a damaged primary",file_hash()==corrupt_hash and FileAccess.get_file_as_bytes(Team.save_path+".bak")==original)
	await shot("continue-backup")
	await drop(title)
	# Both entry points must use the same preview-only prompt; No and Esc preserve origin and disk.
	for origin in ["main","help"]:
		seed_record("Highbank",7);var before:=file_hash()
		title=await launch();title.new_game_confirm_enabled=true
		var action: Button=button(title,"NewGame")
		if origin=="help":title._open_help();await frames(3);action=title._help_controls[2]
		action.grab_focus();await frames(2);action.pressed.emit();await frames(4)
		check(origin+" New Game opens prompt before launch",title._page=="new_game" and title._new_game_panel.visible and title.launch_count==0 and not title._leaving)
		check(origin+" prompt defaults to No",root.gui_get_focus_owner()==title._new_game_controls[0] and title._new_game_controls[0].text=="No")
		var r: Rect2=title._new_game_panel.get_global_rect()
		check(origin+" prompt and both buttons fit",Rect2(16,0,1120,636).encloses(r) and title._new_game_controls.all(func(b):return r.encloses(b.get_global_rect())))
		await shot("prompt-from-"+origin)
		title._new_game_controls[0].pressed.emit();await frames(3)
		check(origin+" No returns to exact origin and leaves save",title._page==origin and root.gui_get_focus_owner()==action and title.launch_count==0 and file_hash()==before)
		action.pressed.emit();await frames(3);Input.parse_input_event(key(KEY_ESCAPE));await frames(3)
		check(origin+" Esc cancels without launching or changing save",title._page==origin and title.launch_count==0 and file_hash()==before)
		action.grab_focus();action.pressed.emit();await frames(3)
		Input.parse_input_event(pad(JOY_BUTTON_B));await frames(2);Input.parse_input_event(pad(JOY_BUTTON_B,false));await frames(3)
		check(origin+" controller Back cancels without changing save",title._page==origin and title.launch_count==0 and file_hash()==before)
		action.grab_focus();action.pressed.emit();await frames(3)
		title._new_game_controls[1].grab_focus()
		Input.parse_input_event(pad(JOY_BUTTON_A));await frames(2);Input.parse_input_event(pad(JOY_BUTTON_A,false));await frames(3)
		check(origin+" Yes invokes existing launch exactly once",title.launch_count==1 and title._leaving and not title._new_game_confirmed and file_hash()==before)
		title._confirm_new_game()
		check(origin+" repeated confirmation cannot launch twice",title.launch_count==1)
		await drop(title)
	# One real scene transition verifies the privately enabled preview path beyond the counting fixture.
	seed_record("Highbank",7)
	var smoke_hash:=file_hash()
	var real_title=load("res://scenes/creature_opening.tscn").instantiate()
	real_title.new_game_confirm_enabled=true
	change_scene_to_node(real_title)
	var smoke_wait:=0
	while not real_title._boot_done and smoke_wait<300:await process_frame;smoke_wait+=1
	button(real_title,"NewGame").grab_focus();button(real_title,"NewGame").pressed.emit();await frames(3)
	check("real title pauses before storm at private preview prompt",real_title._page=="new_game" and not real_title._leaving)
	real_title._new_game_controls[1].pressed.emit()
	var arrived:=false
	for i in 180:
		await process_frame
		if current_scene!=null and current_scene.get_script()!=null and current_scene.get_script().resource_path=="res://scripts/storm_open.gd":
			arrived=true
			break
	check("real Yes enters existing storm scene",arrived)
	check("real storm entry preserves current saved journey",file_hash()==smoke_hash)
	if current_scene!=null:current_scene.queue_free()
	await frames(4)
	Team.erase_save()
	var music=root.get_node_or_null("HollowtideMusic")
	if music!=null:music.queue_free()
	if is_instance_valid(UI._blip):UI._blip.queue_free()
	await frames(4)
	var result={"passed":total-failed,"total":total,"failed":failed,"bounds":facts,"prompt_default":"OFF; only private instances enabled for review"}
	f=FileAccess.open(W+"/native-result.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"\t"));f.close();print("NEW GAME RESULT ",JSON.stringify(result));quit(0 if failed==0 else 1)
