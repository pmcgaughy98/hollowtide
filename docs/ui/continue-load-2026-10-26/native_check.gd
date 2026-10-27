extends SceneTree
const W := "D:/dev/hollowtide-continue-load-20261026"
const UI := preload("res://scripts/ui/ui_style.gd")
const Team := preload("res://scripts/town/team_state.gd")
var phase := "before"
var checks: Array=[]
var failures: Array=[]
var metrics: Array=[]
var pressed_at:=0
var confirm_at:=0
var confirms:=0
func _initialize() -> void:_run.call_deferred()
func frames(n: int) -> void:
	for i in n:await process_frame
func check(label: String, good: bool) -> void:
	checks.append({"check":label,"passed":good})
	if not good:failures.append(label)
	print(label,": ","PASS" if good else "FAIL")
func until(done: Callable, budget:=600) -> bool:
	for i in budget:
		if done.call():return true
		await process_frame
	return done.call()
func sound(child: Node) -> void:
	if child is AudioStreamPlayer and child.stream!=null and child.stream.resource_path.ends_with("/confirm.wav"):
		confirm_at=Time.get_ticks_usec();confirms+=1
func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(W+"/"+phase+"/"+name+".png")
func private_save(suspended:=false) -> void:
	Team.start([[0,0],[1,0]]);Team.data["levels"]={0:{"lv":4,"exp":0},1:{"lv":3,"exp":0}}
	Team.data["cleared"]=1
	if suspended:Team.data["suspend"]={"dungeon":"first","floor_n":2,"floor_seed":7,"replay":true,"light":333.0,"turn":9,"hp":[18,17],"downed":0,"traps_sprung":0,"water_rows":0,"party_at_start":[[0,0],[1,0]],"roster_at_start":[]}
	Team.save()
func title(reduced: bool, failure:=false) -> Node:
	var cfg:=ConfigFile.new();cfg.set_value("menu","reduce_motion",reduced);cfg.save("user://menu_preferences.cfg");UI.reload_prefs()
	var s: Node=load("res://scenes/creature_opening.tscn").instantiate()
	if phase=="after":s.set_script(load(W+"/probe_title.gd"));s.force_failure=failure
	s.child_entered_tree.connect(sound);root.add_child(s);current_scene=s
	await until(func() -> bool:return s._boot_done)
	await frames(3);return s
func press(s: Node) -> Dictionary:
	confirm_at=0;confirms=0;pressed_at=Time.get_ticks_usec()
	s._continue_button.pressed.emit()
	var elapsed:=Time.get_ticks_usec()-pressed_at
	return {"dispatch_ms":elapsed/1000.0,"confirm_ms":(confirm_at-pressed_at)/1000.0,"alpha_on_return":s._fade.color.a,"one_confirm":confirms==1}
func cleanup_scene() -> void:
	if is_instance_valid(current_scene):current_scene.queue_free();current_scene=null
	await frames(8)
func success(tag: String, reduced: bool, suspended: bool) -> void:
	private_save(suspended);var before:=FileAccess.get_sha256(Team.save_path)
	var s: Node=await title(reduced);check(tag+" Continue exists",s._continue_button!=null)
	await shot(tag+"-menu")
	var event:=press(s);event["case"]=tag
	check(tag+" dispatch plays one confirm",event.one_confirm)
	if phase=="after":
		check(tag+" immediate feedback before any destination load",event.confirm_ms>=0 and event.confirm_ms<20.0 and event.dispatch_ms<50.0)
		check(tag+" rapid duplicate activation is ignored",s._leaving)
		s._continue_button.pressed.emit();check(tag+" duplicate has no second confirm",confirms==1)
	var f:=0;var max_ms:=0.0;var fade_max_ms:=0.0;var fade_frames:=0;var last:=Time.get_ticks_usec()
	while current_scene==s or current_scene==null:
		await process_frame;await RenderingServer.frame_post_draw
		var now:=Time.get_ticks_usec();var ms: float=(now-last)/1000.0;last=now;max_ms=maxf(max_ms,ms)
		if is_instance_valid(s) and s._fade.color.a<0.999:fade_max_ms=maxf(fade_max_ms,ms);fade_frames+=1
		if is_instance_valid(s) and s._fade.color.a>=0.999 and f<50:await shot(tag+"-covered")
		f+=1
		if f>600:break
	event["frames_to_swap"]=f;event["longest_title_frame_ms"]=max_ms;event["longest_fade_frame_ms"]=fade_max_ms;event["visible_fade_frames"]=fade_frames
	check(tag+" destination scene changes",is_instance_valid(current_scene) and current_scene!=s)
	if phase=="after":
		var probe: Dictionary=get_meta("continue_probe",{});event["probe"]=probe
		check(tag+" loader starts under both opaque covers",probe.get("local_alpha",0.0)>=0.999 and probe.get("shared_alpha",0.0)>=0.999)
		check(tag+" only one threaded load path requested",probe.get("requests",0)==1 and probe.get("path","")==("res://scenes/dungeon.tscn" if suspended else "res://scenes/hub_town.tscn"))
		check(tag+" disk save untouched until destination is ready to dispatch",probe.get("saved_hash","")==before)
	if suspended:
		check(tag+" dungeon destination",current_scene.scene_file_path.ends_with("dungeon.tscn"))
		var run: Node=current_scene
		check(tag+" suspended dungeon/floor/seed preserved",run.dungeon=="first" and run.floor_n==2 and run.floor_seed==7 and run.return_to_town)
		check(tag+" suspend consumed once after dispatch",not Team.has_suspended() and not Team._read().get("data",{}).has("suspend"))
		await until(func() -> bool:return run.ents.size()>=2 and run._fade.color.a<0.01 and run._card_lines.is_empty(),900)
		check(tag+" saved team and HP resume",run.party==[[0,0],[1,0]] and run.ents[0].hp==18 and run.ents[1].hp==17 and run.turn==9)
		check(tag+" shared cover is released for dungeon card",not root.has_node(UI.FADE_NAME))
	else:
		check(tag+" Highbank destination",current_scene.scene_file_path.ends_with("hub_town.tscn"))
		var town: Node=current_scene
		check(tag+" Highbank finishes its own covered arrival",await until(func() -> bool:return town.ready_ms.has("total"),900))
		check(tag+" saved team/cleared/levels survive",town.party==[[0,0],[1,0]] and town.cleared==1 and Team.data.get("levels",{}).get(0,{}).get("lv",0)==4)
		await frames(20);check(tag+" Highbank lifts shared cover",not root.has_node(UI.FADE_NAME))
		# The town's static warm-up survives a scene change. Finish its real room workers before test shutdown.
		await until(func() -> bool:return town._kept.has(town.ROOM_SCENE),900)
		var rooms: Resource=load(town.ROOM_SCRIPT)
		if rooms.call("art_off_main"):
			check(tag+" background room warm-up completes before teardown",await until(func() -> bool:return town.ROOMS_AHEAD.all(func(id: String) -> bool:return rooms.call("prepared",id)),900))
		await frames(6)
	await shot(tag+"-arrived");metrics.append(event);print("CONTINUE METRIC ",JSON.stringify(event));await cleanup_scene()
func failure_and_retry() -> void:
	private_save(true);var before:=FileAccess.get_sha256(Team.save_path)
	var s: Node=await title(false,true);press(s)
	await until(func() -> bool:return not s._leaving);await frames(20)
	check("Simulated loader failure returns to usable title",current_scene==s and s._page=="main" and not s._continue_button.disabled and s._fade.color.a==0 and root.gui_get_focus_owner()==s._continue_button)
	check("Failed loader preserves unconsumed suspend bytes",Team.has_suspended() and FileAccess.get_sha256(Team.save_path)==before)
	check("Failure removes shared black cover",not root.has_node(UI.FADE_NAME));await shot("failure-restored")
	s.force_failure=false;var old_id:=s.get_instance_id();press(s)
	check("Retry after resource failure reaches saved dungeon",await until(func() -> bool:return current_scene!=null and current_scene.get_instance_id()!=old_id and current_scene.scene_file_path.ends_with("dungeon.tscn")))
	var run: Node=current_scene
	await until(func() -> bool:return run.ents.size()>=2 and run._fade.color.a<0.01 and run._card_lines.is_empty(),900)
	check("Successful retry consumes suspend only once",not Team.has_suspended() and run.dungeon=="first" and run.floor_n==2 and run.turn==9)
	await shot("retry-arrived")
	await cleanup_scene()
func missing_save() -> void:
	private_save();var s: Node=await title(true);Team.erase_save();press(s)
	await until(func() -> bool:return not s._leaving);await frames(18)
	check("Missing save disables only Continue and restores main",current_scene==s and s._page=="main" and s._continue_button.disabled and root.gui_get_focus_owner()!=s._continue_button)
	check("Missing save does not start a destination load",s.requests==0)
	await cleanup_scene()
func lazy_legacy() -> void:
	var s: Node=load("res://scenes/opening_flow.tscn").instantiate();root.add_child(s);current_scene=s;await frames(6)
	check("Legacy title does not request unused route at boot",not s._route_requested and s._route_scene==null)
	await until(func() -> bool:return s._boot_done)
	s._on_new_game()
	check("Legacy New Game requests its still-used courier route",s._route_requested and s._page=="journey")
	check("Lazy route eventually enables original Begin action",await until(func() -> bool:return s._route_scene!=null and not s._begin_button.disabled,600))
	await cleanup_scene()
func _run() -> void:
	phase=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(W+"/"+phase)
	root.size=Vector2i(1152,648);root.content_scale_size=root.size;Team.save_path="user://continue-load-private.save";Team.erase_save()
	await success("highbank-normal",false,false)
	if phase=="after":
		await success("highbank-reduced",true,false);await success("warren-suspend",false,true);await failure_and_retry();await missing_save();await lazy_legacy()
	Team.erase_save()
	if is_instance_valid(UI._blip):UI._blip.free()
	for p in UI._ticks.values():
		if is_instance_valid(p):p.queue_free()
	var music:=root.get_node_or_null("HollowtideMusic")
	if music!=null:music.queue_free()
	await frames(8)
	var result:={"phase":phase,"total":checks.size(),"failed":failures.size(),"checks":checks,"metrics":metrics,"failures":failures}
	var file:=FileAccess.open(W+"/"+phase+"-result.json",FileAccess.WRITE);file.store_string(JSON.stringify(result,"  "));file.close()
	print("CONTINUE LOAD RESULT ",checks.size()," checks / ",failures.size()," failures");quit(0 if failures.is_empty() else 1)
