extends SceneTree
const W := "D:/dev/hollowtide-launch-frames-20261010/"
var count := 0
var bad := 0
var out := W+"review/after/"
func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
	for k in n: await process_frame
func check(ok: bool, text: String) -> void:
	count+=1
	if not ok: bad+=1
	print("PASS " if ok else "FAIL ",text)
func key(code: Key) -> void:
	for down in [true,false]:
		var e:=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=down
		Input.parse_input_event(e);await frames(3)
func click(b: Control) -> void:
	for down in [true,false]:
		var e:=InputEventMouseButton.new();e.position=b.get_global_rect().get_center();e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down
		Input.parse_input_event(e);await frames(3)
func inside(c: Control) -> bool:
	var r:=c.get_global_rect()
	return r.position.x>=0 and r.position.y>=0 and r.end.x<=1152 and r.end.y<=648
func shot(name: String) -> void:
	await frames(6);await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out+name+".png")
func run() -> void:
	root.size=Vector2i(1152,648)
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"):out=W+"review/live/"
	DirAccess.make_dir_recursive_absolute(out)
	var config:=ConfigFile.new();config.set_value("menu","reduce_motion",false);config.set_value("audio","master",100.0);config.save("user://menu_preferences.cfg")
	check(ResourceLoader.exists("res://scenes/creature_opening.tscn"),"creature launch scene remains available; current development F5 preserved")
	change_scene_to_file("res://scenes/creature_opening.tscn");await frames(8)
	var m:Node=current_scene
	await shot("boot");await key(KEY_ENTER);await frames(65)
	check(m._boot_done and m._page=="main","boot skip lands on title")
	check(m._main_panel.get_theme_stylebox("panel") is StyleBoxEmpty,"title text composition preserved")
	check(m._buttons.size()==4 and inside(m._main_panel),"four title choices stay within screen")
	check(m.get_node("CreatureVillage").texture.resource_path.ends_with("creature_village_2026_10_09.png"),"original village artwork retained")
	await shot("title")
	await click(m._buttons[1]);await frames(8)
	check(m._options_panel.get_theme_stylebox("panel") is StyleBoxTexture and inside(m._options_panel),"pixel Options fits screen")
	var volume:HSlider=m._options_controls[0]
	volume.grab_focus();await key(KEY_LEFT)
	check(volume.value==95 and volume.size.y>=48,"framed slider adjusts volume by keyboard")
	await shot("options");await key(KEY_ESCAPE)
	check(root.gui_get_focus_owner()==m._buttons[1],"Options Back restores focus")
	await click(m._help_button);await frames(8)
	check(inside(m._help_panel) and m._help_panel.get_theme_stylebox("panel") is StyleBoxTexture,"pixel Journey guide fits screen")
	await shot("help-journey")
	await click(m._help_controls[1]);await frames(8)
	check(m._help_topic=="controls" and inside(m._help_panel),"Controls guide fits screen")
	await shot("help-controls");await key(KEY_ESCAPE)
	await click(m._buttons[2]);await frames(8)
	check(m._page=="quit" and inside(m._quit_panel) and root.gui_get_focus_owner()==m._quit_controls[0],"pixel Quit confirms with safe Back focus")
	await shot("quit");await key(KEY_ESCAPE)
	await click(m._help_button);await click(m._help_controls[2]);await frames(40)
	check(current_scene.get_script().resource_path.ends_with("soul_prologue.gd"),"Help Start New Game retains soul-story route")
	change_scene_to_file("res://scenes/creature_opening.tscn");await frames(8)
	m=current_scene;await key(KEY_ENTER);await frames(65)
	await click(m._buttons[0]);await frames(40)
	check(current_scene.get_script().resource_path.ends_with("soul_prologue.gd"),"real New Game still opens Claude's soul story")
	# Soul's own native check covers the automatic handoff; exercise the waking choices here.
	change_scene_to_file("res://scenes/creature_prologue.tscn");await frames(10)
	var pro:Node=current_scene
	for phase in 3:
		check(pro.phase==phase and inside(pro.panel),"waking phase %d choice panel fits"%phase)
		check(pro.confirm.size.y>=48 and pro.confirm.get_theme_stylebox("normal") is StyleBoxTexture,"waking phase %d actions have intact pixel corners"%phase)
		for b in pro.cards: check(inside(b),"phase %d choice %s fits"%[phase,b.text])
		check(pro.dialogue._wrapped(pro.prose.text,878).split("\n").size()<=3,"phase %d dialogue fits its text box"%phase)
		check(pro.dialogue.portrait.material is ShaderMaterial,"phase %d portrait uses existing creature finish"%phase)
		await shot("wake-%d"%phase)
		if phase==0:
			await click(pro.cards[2]);check(pro.hero==2,"identity mouse choice retains existing model")
		elif phase==1:
			await click(pro.cards[0]);check(pro.partner==0,"companion mouse choice retains existing model")
		await key(KEY_ENTER);await frames(20)
	check(current_scene.get_script().resource_path.ends_with("hub_town.gd") and current_scene.party==[[2,0],[0,0]],"framed final confirmation reaches town with selected team")
	await frames(10)
	current_scene.queue_free();await frames(12)
	var arrival:CanvasLayer=load("res://scripts/first_partner_arrival.gd").new()
	var arena:Script=load("res://scripts/arena/arena_prototype.gd")
	arrival.creature=load(arena.LINES[2].forms[0][1])
	arrival.accent=Color("#8fd3ff")
	var idle:=SpriteFrames.new();idle.add_animation("idle")
	idle.add_frame("idle",load("res://assets/sprites/ui/dialogue/rimefin.png"))
	arrival.portrait_frames=idle;arrival.reduce_motion=true
	root.add_child(arrival);await frames(8)
	check(inside(arrival._card) and arrival._card.get_theme_stylebox("panel") is StyleBoxTexture,"legacy partner welcome pixel card fits screen")
	await shot("partner-welcome")
	arrival.queue_free();await frames(8)
	for n in root.get_children():n.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await frames(12)
	print("FRAMES ",count-bad,"/",count," PASS")
	quit(0 if bad==0 else 1)
