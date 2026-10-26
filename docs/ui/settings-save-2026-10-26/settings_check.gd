extends SceneTree
const W := "D:/dev/hollowtide-settings-save-20261026"
const UI := preload("res://scripts/ui/ui_style.gd")
const Team := preload("res://scripts/town/team_state.gd")
var phase := "before"
var total := 0
var failed := 0

func _initialize() -> void: _run.call_deferred()
func frames(n: int) -> void:
	for i in n: await process_frame
func check(label: String, ok: bool) -> void:
	total+=1
	if not ok:failed+=1
	print("SETTINGS_CHECK ",label," -> ","ok" if ok else "FAIL")
func cfg(path: String) -> ConfigFile:
	var c:=ConfigFile.new();c.load(path);return c
func hash_of(path: String) -> String:
	return FileAccess.get_sha256(path) if FileAccess.file_exists(path) else "missing"
func seed_settings() -> void:
	var c:=ConfigFile.new()
	c.set_value("audio","master",81.0);c.set_value("audio","music",27.0);c.set_value("audio","sfx",23.0)
	c.set_value("menu","courier","Female");c.set_value("menu","reduce_motion",false);c.save(UI.PREFS_PATH)
	var g:=ConfigFile.new()
	g.set_value("input","attack",[{"key":75}]);g.set_value("menu","text_speed",2);g.set_value("display","fullscreen",false);g.set_value("future_game","marker","kept")
	g.save(UI.GAME_PREFS_PATH)
	UI.reload_prefs()
func screenshot(name: String) -> void:
	await frames(4);await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(W+"/native/"+name+".png")

func _run() -> void:
	phase=OS.get_environment("HT_SETTINGS_PHASE")
	root.size=Vector2i(1152,648);root.content_scale_size=Vector2i(1152,648)
	Team.save_path="user://settings-private-team.save"
	DirAccess.make_dir_recursive_absolute(W+"/native")
	if phase in ["before","after"]:seed_settings()
	var title=load("res://scenes/creature_opening.tscn").instantiate();root.add_child(title)
	var waited:=0
	while not(title._boot_done and title._page=="main") and waited<300:
		await process_frame;waited+=1
	check("title reaches menu",title._boot_done and title._page=="main")
	title._on_options();await frames(3)
	if phase in ["before","after"]:
		check("saved courier and three volumes loaded",title._selected_courier=="Female" and title._master_volume==81 and title._music_volume==27 and title._sfx_volume==23)
		check("initial shared motion cache off",not UI.reduce_motion())
		var c:=cfg(UI.PREFS_PATH);c.set_value("future_title","marker","keep me");c.save(UI.PREFS_PATH)
		var game_hash:=hash_of(UI.GAME_PREFS_PATH)
		# Drive the real title volume signal and Reduce Motion button; neither uses a test save implementation.
		(title._options_controls[0] as HSlider).value=30
		title._motion_button.pressed.emit()
		c=cfg(UI.PREFS_PATH)
		check("unknown title section survives actual menu saves",c.get_value("future_title","marker","")=="keep me")
		check("all five title values saved together",c.get_value("audio","master",0)==30 and c.get_value("audio","music",0)==27 and c.get_value("audio","sfx",0)==23 and c.get_value("menu","courier","")=="Female" and c.get_value("menu","reduce_motion",false))
		check("title save leaves separate game prefs byte exact",hash_of(UI.GAME_PREFS_PATH)==game_hash)
		check("successful title save clears dirty state",not title._settings_dirty)
		check("successful title save leaves no temporary file",not FileAccess.file_exists(UI.PREFS_PATH+".tmp"))
		check("shared motion reader immediately sees title change",UI.reduce_motion())
		var g:=cfg(UI.GAME_PREFS_PATH)
		check("bindings speed screen and future game key survive",g.get_value("input","attack",[])==[{"key":75}] and g.get_value("menu","text_speed",0)==2 and g.get_value("display","fullscreen",true)==false and g.get_value("future_game","marker","")=="kept")
		await screenshot(phase+"-title-settings")
		# The current pause helper is Claude's active file; verify its real call without changing it.
		var pause=load("res://scripts/ui/game_pause_menu.gd").new()
		pause.status=Label.new()
		pause._save("audio","sfx",41.0)
		c=cfg(UI.PREFS_PATH)
		check("pause save keeps female courier and master volume",c.get_value("menu","courier","")=="Female" and c.get_value("audio","master",0)==30 and c.get_value("audio","sfx",0)==41)
		check("pause save reports success",pause.status.text=="Changes are saved automatically.")
		check("pause helper retains prior complete backup",cfg(UI.PREFS_PATH+".bak").get_value("audio","sfx",0)==23)
		check("pause helper consumes its temporary file",not FileAccess.file_exists(UI.PREFS_PATH+".tmp"))
		pause._save("menu","text_speed",0)
		check("pause game preference keeps title file exact",cfg(UI.PREFS_PATH).get_value("audio","sfx",0)==41 and UI.text_speed()==0 and cfg(UI.GAME_PREFS_PATH).get_value("input","attack",[])==[{"key":75}])
		pause.status.free();pause.free()
		# Leave a partial pending write, as a process stopped before rename would. The fresh process must ignore it.
		var keep=hash_of(UI.PREFS_PATH)
		var orphan=FileAccess.open(UI.PREFS_PATH+".tmp",FileAccess.WRITE);orphan.store_string("[audio]\nmaster=");orphan.close()
		check("interrupted pending write leaves final file exact",hash_of(UI.PREFS_PATH)==keep)
	elif phase=="restart":
		check("fresh launch ignores incomplete temp and restores all title values",title._master_volume==30 and title._music_volume==27 and title._sfx_volume==41 and title._selected_courier=="Female" and title._reduce_motion)
		check("fresh launch retains separate bindings and text speed",cfg(UI.GAME_PREFS_PATH).get_value("input","attack",[])==[{"key":75}] and UI.text_speed()==0)
		(title._options_controls[0] as HSlider).value=60
		check("next real save replaces stale pending file",cfg(UI.PREFS_PATH).get_value("audio","master",0)==60 and not FileAccess.file_exists(UI.PREFS_PATH+".tmp"))
		await screenshot("restart-title-settings")
	elif phase=="failures":
		var tmp=ProjectSettings.globalize_path(UI.PREFS_PATH+".tmp")
		if FileAccess.file_exists(tmp):DirAccess.remove_absolute(tmp)
		DirAccess.make_dir_absolute(tmp)
		var final_hash=hash_of(UI.PREFS_PATH)
		title._master_volume=77;title._settings_dirty=true;title._save_preferences()
		check("temp-write failure leaves prior settings byte exact",hash_of(UI.PREFS_PATH)==final_hash)
		check("temp-write failure retains retry flag and visible error",title._settings_dirty and title._options_status.text=="Settings could not be saved.")
		await screenshot("failed-temp-write")
		DirAccess.remove_absolute(tmp)
		title._save_preferences()
		check("retry saves requested values and clears error message",not title._settings_dirty and cfg(UI.PREFS_PATH).get_value("audio","master",0)==77 and title._options_status.text=="Changes are saved automatically.")
		# Force only the final rename to fail: a nonempty directory occupies the destination.
		var dest=ProjectSettings.globalize_path(UI.PREFS_PATH)
		DirAccess.rename_absolute(dest,dest+".test-preserved")
		DirAccess.make_dir_absolute(dest)
		var block=FileAccess.open(dest+"/test-blocker",FileAccess.WRITE);block.store_string("private fixture");block.close()
		title._master_volume=88;title._settings_dirty=true;title._save_preferences()
		check("rename failure retains retry flag and visible error",title._settings_dirty and title._options_status.text=="Settings could not be saved.")
		check("rename failure leaves complete pending values",cfg(UI.PREFS_PATH+".tmp").get_value("audio","master",0)==88)
		DirAccess.remove_absolute(dest+"/test-blocker");DirAccess.remove_absolute(dest)
		DirAccess.rename_absolute(dest+".test-preserved",dest)
		title._save_preferences()
		check("rename retry replaces existing file and clears error message",not title._settings_dirty and cfg(UI.PREFS_PATH).get_value("audio","master",0)==88 and title._options_status.text=="Changes are saved automatically.")
		check("failure retries preserve courier and SFX",cfg(UI.PREFS_PATH).get_value("menu","courier","")=="Female" and cfg(UI.PREFS_PATH).get_value("audio","sfx",0)==41)
	title.queue_free();await frames(3)
	var music=root.get_node_or_null("HollowtideMusic")
	if music!=null:music.queue_free()
	await frames(3)
	var record={"phase":phase,"passed":total-failed,"total":total,"failed":failed,"user_dir":OS.get_user_data_dir()}
	var f=FileAccess.open(W+"/"+phase+"-result.json",FileAccess.WRITE);f.store_string(JSON.stringify(record,"\t"));f.close()
	print("SETTINGS RESULT ",JSON.stringify(record))
	quit(0 if phase=="before" or failed==0 else 1)
