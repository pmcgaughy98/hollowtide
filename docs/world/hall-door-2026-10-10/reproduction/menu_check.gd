extends SceneTree
const OUT = "D:/dev/hollowtide-hall-door-20261010/review/"
var checks: Array = []
var failed: Array = []
func _initialize() -> void: call_deferred("run")
func verify(s: String, ok: bool) -> void:
	checks.append({"check":s,"passed":ok})
	if not ok: failed.append(s)
	print(s,": ",ok)
func frames(n: int) -> void:
	for i in n: await process_frame
func hold(code: Key, down: bool) -> void:
	var e := InputEventKey.new()
	e.keycode=code; e.physical_keycode=code; e.pressed=down
	Input.parse_input_event(e)
func key(code: Key) -> void:
	hold(code,true); await frames(2); hold(code,false); await frames(3)
func click(b: Control) -> void:
	var e := InputEventMouseButton.new()
	e.button_index=MOUSE_BUTTON_LEFT; e.position=b.get_global_rect().get_center(); e.pressed=true
	Input.parse_input_event(e); await frames(2)
	e=InputEventMouseButton.new(); e.button_index=MOUSE_BUTTON_LEFT; e.position=b.get_global_rect().get_center(); e.pressed=false
	Input.parse_input_event(e); await frames(3)
func pad(button: JoyButton) -> void:
	var e := InputEventJoypadButton.new(); e.button_index=button; e.pressed=true
	Input.parse_input_event(e); await frames(2)
	e=InputEventJoypadButton.new(); e.button_index=button; e.pressed=false
	Input.parse_input_event(e); await frames(3)
func shot(name: String) -> void:
	await frames(4)
	root.get_texture().get_image().save_png(OUT+name+".png")
func choose(p: Node, name: String) -> void: await click(p.content.get_node(name))
func run() -> void:
	root.size=Vector2i(1152,648)
	# Only the runner's isolated APPDATA, never the user's live preferences.
	var initial := ConfigFile.new()
	initial.set_value("audio","master",100.0); initial.set_value("audio","music",100.0)
	initial.set_value("menu","reduce_motion",false); initial.set_value("menu","courier","Male")
	initial.save("user://menu_preferences.cfg")
	verify("F5 main scene is the creature opening",ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/creature_opening.tscn")
	var menu: Node = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	root.add_child(menu); current_scene=menu
	await frames(3); await key(KEY_ENTER); await frames(65)
	verify("Boot skip does not activate New Game",current_scene==menu and menu._boot_done and menu._page=="main")
	verify("Title starts with focused New Game",root.gui_get_focus_owner()==menu._buttons[0])
	await click(menu._buttons[1]); await frames(3)
	verify("Mouse opens title Options",menu._page=="options")
	var master: HSlider=menu._options_controls[0]
	master.grab_focus(); await key(KEY_LEFT)
	verify("Keyboard adjusts title Master volume",master.value==95)
	await key(KEY_ESCAPE)
	verify("Title Options cancel restores its button focus",menu._page=="main" and root.gui_get_focus_owner()==menu._buttons[1])
	await click(menu._buttons[2])
	verify("Title Quit requires confirmation",menu._page=="quit")
	await key(KEY_ESCAPE)
	verify("Title Quit cancel keeps title",current_scene==menu and menu._page=="main")
	await shot("title")
	await click(menu._buttons[0]); await frames(35)
	var story: Node=current_scene
	verify("Real mouse New Game enters creature story",story.has_method("choose"))
	if not story.has_method("choose"): quit(1); return
	await click(story.cards[2])
	verify("Identity choice uses Rimefin",story.hero==2)
	await key(KEY_ENTER)
	verify("Identity confirm advances to survivor story",story.phase==1)
	await key(KEY_ESCAPE)
	verify("Story Back retains identity",story.phase==0 and story.hero==2)
	await key(KEY_ENTER); await click(story.cards[0]); await key(KEY_ENTER)
	verify("Companion chosen in story, with truthful Highbank destination",story.phase==2 and story.partner==0 and story.confirm.text=="Reach Highbank together")
	await shot("story")
	await key(KEY_ENTER); await frames(40)
	var town: Node=current_scene
	verify("Final confirmation reaches Highbank with selected team",town.get_script().resource_path.ends_with("hub_town.gd") and town.party==[[2,0],[0,0]])
	if not town.has_node("GamePauseMenu"): quit(1); return
	var p: Node=town.get_node("GamePauseMenu")
	await frames(40)
	var town_music: Node=root.get_node("HollowtideMusic")
	verify("Claude town track actually plays on Music bus",town_music._players.any(func(player:AudioStreamPlayer)->bool:return player.playing and player.bus==&"Music"))
	await key(KEY_ESCAPE)
	verify("Esc opens town pause with Resume focus",paused and p.overlay.visible and root.gui_get_focus_owner()==p.content.get_node("Resume"))
	var position: Vector2i=town.team[0].pos
	hold(KEY_W,true); await frames(20); hold(KEY_W,false); await frames(2)
	verify("Town movement freezes while paused",town.team[0].pos==position)
	await shot("town-pause")
	await key(KEY_UP)
	verify("Pause keyboard focus wraps to Quit",root.gui_get_focus_owner()==p.content.get_node("Quit"))
	await key(KEY_DOWN)
	verify("Pause keyboard focus wraps to Resume",root.gui_get_focus_owner()==p.content.get_node("Resume"))
	await choose(p,"Options")
	verify("Pause Options reads title settings",p.content.get_node("MasterVolume").value==95)
	p.content.get_node("MusicVolume").grab_focus(); await key(KEY_LEFT)
	await choose(p,"ReduceMotion")
	var config := ConfigFile.new(); config.load("user://menu_preferences.cfg")
	verify("Pause Options persists audio and motion without removing legacy keys",config.get_value("audio","music")==95 and config.get_value("menu","reduce_motion")==true and config.has_section_key("menu","courier"))
	verify("Music bus follows pause slider",is_equal_approx(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")),linear_to_db(0.95)))
	verify("Gameplay music keeps playing while paused",town_music._players.any(func(player:AudioStreamPlayer)->bool:return player.playing))
	await shot("pause-options")
	await key(KEY_ESCAPE); await choose(p,"Controls"); await shot("pause-controls")
	verify("Controls page stays inside viewport",p.content.get_parent().get_global_rect().end.y<=648)
	await key(KEY_ESCAPE); await choose(p,"ReturnTitle")
	verify("Return title confirmation defaults to safe cancel",p.page=="title" and root.gui_get_focus_owner()==p.content.get_node("CancelLeave"))
	await key(KEY_ENTER); await choose(p,"Quit"); await key(KEY_ESCAPE)
	verify("Both leave confirmations cancel without losing town",current_scene==town and p.page=="main" and paused)
	await key(KEY_ENTER); await frames(3)
	verify("Resume releases pause without opening a town service",not paused and town.panel.is_empty() and town.team[0].pos==position)
	await pad(JOY_BUTTON_START)
	verify("Controller Start opens pause",paused and p.overlay.visible)
	await pad(JOY_BUTTON_DPAD_DOWN); await pad(JOY_BUTTON_DPAD_DOWN); await pad(JOY_BUTTON_DPAD_DOWN); await pad(JOY_BUTTON_A)
	verify("Controller D-pad traverses Team/Bag and A opens Options",p.page=="options")
	await pad(JOY_BUTTON_B)
	verify("Controller B returns to main pause",p.page=="main" and paused)
	await pad(JOY_BUTTON_A)
	verify("Controller A resumes without changing town",not paused and town.panel.is_empty())
	town.panel={"name":"Test dialogue","what":"Preserved","service":"test"}
	await key(KEY_ESCAPE)
	verify("Esc still closes existing town dialogue",not paused and town.panel.is_empty())
	await click(p.hint)
	verify("Visible Menu button opens pause",paused and p.overlay.visible)
	await choose(p,"ReturnTitle"); await choose(p,"ConfirmLeave"); await frames(55)
	menu=current_scene
	verify("Confirmed return opens title and unpauses tree",not paused and menu.get_script().resource_path.ends_with("creature_opening.gd"))
	verify("Returned title loads shared settings and preserves Claude theme",menu._reduce_motion and menu._music_volume==95 and menu._music.stream.resource_path.ends_with("title.mp3"))
	var music: Node=root.get_node("HollowtideMusic")
	verify("Shared gameplay music fades away at title",music.current=="" and music.process_mode==Node.PROCESS_MODE_INHERIT)
	change_scene_to_file("res://scenes/dungeon.tscn"); await frames(10)
	var dungeon: Node=current_scene
	verify("Dungeon defaults to turn-based combat",not dungeon.real_time_battles)
	p=dungeon.get_node("GamePauseMenu")
	await key(KEY_P)
	var turn: int=dungeon.turn
	var light: float=dungeon.light
	var positions: Array=dungeon.ents.map(func(e:Dictionary)->Variant:return e.pos)
	dungeon.autopilot=true
	hold(KEY_W,true); await frames(20); hold(KEY_W,false); await frames(2)
	verify("Dungeon pause freezes turns, lantern, monsters and autopilot",paused and dungeon.turn==turn and dungeon.light==light and positions==dungeon.ents.map(func(e:Dictionary)->Variant:return e.pos))
	dungeon.autopilot=false
	await shot("dungeon-pause")
	verify("Music remains available in paused Options",music.process_mode==Node.PROCESS_MODE_ALWAYS)
	verify("All dungeon main buttons fit viewport",p.content.get_parent().get_global_rect().end.y<=648)
	await choose(p,"Team"); verify("Claude Team page retained",p.page=="team" and p.content.get_children().any(func(n:Node)->bool:return n is Label and n.text.contains("KITHFLARE")))
	await key(KEY_ESCAPE); await choose(p,"Bag"); verify("Claude Bag page retained",p.content.has_node("Use_reedberry"))
	await key(KEY_ESCAPE); await choose(p,"Floor"); verify("Claude Floor page retained",p.page=="floor")
	await key(KEY_ESCAPE); await choose(p,"Log"); verify("Claude Log page retained",p.page=="log")
	await key(KEY_ESCAPE)
	await key(KEY_ENTER)
	verify("Keyboard Resume spends no dungeon turn",not paused and dungeon.turn==turn and music.process_mode==Node.PROCESS_MODE_INHERIT)
	await key(KEY_I)
	verify("Existing I opens bag",dungeon.bag_open)
	await key(KEY_P); await key(KEY_ENTER)
	verify("Pausing over bag preserves bag and does not consume its item",dungeon.bag_open and dungeon.bag.get("reedberry")==1 and dungeon.turn==turn)
	await key(KEY_ESCAPE)
	verify("Esc closes bag without opening pause",not paused and not dungeon.bag_open)
	# Review-only optional-mode fixture; production still defaults to turn based.
	var wild: Dictionary=dungeon.ents.filter(func(e:Dictionary)->bool:return e.team==1)[0]
	wild.pos=dungeon.ents[0].pos+Vector2i(1,0); wild.awake=true
	dungeon.real_time_battles=true; dungeon.in_battle=true; dungeon._start_battle(); await frames(2)
	verify("Existing real-time fight starts",dungeon._battle!=null)
	await key(KEY_P)
	var battle: Node=dungeon._battle
	var battle_time: float=dungeon._battle_t
	var fight_positions: Array=battle._fighters.map(func(f:Dictionary)->Variant:return f.body.position)
	hold(KEY_D,true); await frames(20); hold(KEY_D,false); await frames(2)
	verify("Pause freezes the existing real-time fight too",paused and battle_time==dungeon._battle_t and fight_positions==battle._fighters.map(func(f:Dictionary)->Variant:return f.body.position))
	await choose(p,"ReturnTitle"); await choose(p,"ConfirmLeave"); await frames(45)
	verify("Returning from a paused fight restores title",not paused and current_scene.get_script().resource_path.ends_with("creature_opening.gd"))
	var file := FileAccess.open(OUT+"menu-checks.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failed},"  ")); file.close()
	print("CHECKS ",checks.size()," FAILURES ",failed.size())
	quit(0 if failed.is_empty() else 1)
