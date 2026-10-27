extends SceneTree
const W := "D:/dev/hollowtide-starter-cards-20261026"
const UI := preload("res://scripts/ui/ui_style.gd")
const Team := preload("res://scripts/town/team_state.gd")
var phase := "before"
var checks: Array = []
var failures: Array = []
var s: Node
func _initialize() -> void: _run.call_deferred()
func frames(n: int) -> void:
	for i in n: await process_frame
func check(label: String, good: bool) -> void:
	checks.append({"check":label,"passed":good})
	if not good: failures.append(label)
	print(label,": ","PASS" if good else "FAIL")
func shot(label: String) -> void:
	await frames(3)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(W+"/"+phase+"/"+label+".png")
func key(code: Key, down: bool, echo:=false) -> void:
	var e:=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=down;e.echo=echo
	Input.parse_input_event(e);await frames(2)
func tap(code: Key) -> void:
	await key(code,true);await key(code,false)
func pad(button: JoyButton, down: bool) -> void:
	var e:=InputEventJoypadButton.new();e.device=0;e.button_index=button;e.pressed=down
	Input.parse_input_event(e);await frames(2)
func axis(value: float) -> void:
	var e:=InputEventJoypadMotion.new();e.device=0;e.axis=JOY_AXIS_LEFT_X;e.axis_value=value
	Input.parse_input_event(e);await frames(2)
func mouse(point: Vector2, down: bool) -> void:
	var e:=InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.position=point;e.global_position=point;e.pressed=down
	Input.parse_input_event(e);await frames(2)
func click(point: Vector2) -> void:
	await mouse(point,true);await mouse(point,false)
func enter_cards() -> void:
	s.stage="talk";s.line=s.LINES.size()-2;s.shown=s._text().length();UI.finish_line()
	s.advance();await frames(1)
func reset_cards() -> void:
	s.chosen=-1;s.pick=0;s.stage="choose";s.line=s.LINES.size()-1;s._choice_wait=0.0;s._accept_released=true
	await frames(2)
func _run() -> void:
	phase=OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(W+"/"+phase)
	root.size=Vector2i(1152,648);root.content_scale_size=root.size
	Team.save_path="user://starter-cards-private.save";Team.erase_save();Team.data={"party":[[0,0]]};Team.save()
	var saved:=FileAccess.get_sha256(Team.save_path)
	s=load("res://scenes/soul_prologue.tscn").instantiate();root.add_child(s);await frames(6)
	s._ui.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed: print("MOUSE_LOCAL ",e.position," stage=",s.stage," ready=",s._choice_ready() if phase=="after" else true))
	await enter_cards();check("Real last story line opens three cards",s.stage=="choose" and s.chosen==-1)
	await shot("cards")
	if phase=="after":
		# Hold the reading key across the transition: neither time nor repeats can choose.
		await reset_cards();s.stage="talk";s.line=s.LINES.size()-2;s.shown=s._text().length()
		await frames(3);UI.finish_line()
		await key(KEY_ENTER,true);check("Reading press opens cards without committing",s.stage=="choose" and s.chosen==-1)
		await frames(16);await key(KEY_ENTER,true);await key(KEY_ENTER,true,true)
		check("Held/repeated reading press stays on cards after guard expires",s.stage=="choose" and s.chosen==-1)
		await key(KEY_ENTER,false);await tap(KEY_ENTER)
		check("Fresh accept opens confirmation with No selected",s.stage=="confirm" and s._answer==1 and s.chosen==-1)
		await shot("confirm-no");await tap(KEY_ENTER)
		check("No returns to same uncommitted creature",s.stage=="choose" and s.pick==0 and s.chosen==-1)
		await tap(KEY_ENTER);await tap(KEY_ESCAPE)
		check("Cancel returns without committing",s.stage=="choose" and s.chosen==-1)
		await reset_cards();s._choice_wait=0.4
		await tap(KEY_ENTER);check("Accept inside first0.4s is ignored",s.stage=="choose")
		await frames(14)
		await reset_cards();s._choice_wait=0.4
		await key(KEY_ENTER,true);await frames(15);await key(KEY_ENTER,true)
		check("Early accept held past guard still needs release",s.stage=="choose" and s.chosen==-1)
		await key(KEY_ENTER,false);await tap(KEY_ENTER)
		check("Release after early accept permits fresh confirmation",s.stage=="confirm" and s.chosen==-1)
		await reset_cards();s._choice_wait=0.4
		var same: Vector2=root.get_stretch_transform()*s._ui.get_screen_transform()*s._card_rect(0).get_center()
		await mouse(same,true);await frames(15);await mouse(same,true)
		check("Early mouse hold cannot open question after guard",s.stage=="choose" and s.chosen==-1)
		await mouse(same,false);await click(same)
		check("Fresh mouse press after guard opens question",s.stage=="confirm")
		for hero in 3:
			await reset_cards()
			for k in hero: await tap(KEY_RIGHT)
			check("Keyboard focuses starter%d"%hero,s.pick==hero)
			await tap(KEY_ENTER);await tap(KEY_LEFT)
			await shot("confirm-yes-%d"%hero)
			await key(KEY_ENTER,true)
			check("Yes commits requested starter%d"%hero,s.stage=="after" and s.chosen==hero and s.line==0)
			await key(KEY_ENTER,true);await key(KEY_ENTER,true,true)
			check("Commit press cannot advance first after-line%d"%hero,s.line==0)
			check("Pick plays presence swell on UI bus%d"%hero,s._presence.playing and s._presence.bus==&"UI" and s._presence.stream.resource_path.ends_with("presence_swell.wav"))
			await key(KEY_ENTER,false)
		await reset_cards();await pad(JOY_BUTTON_A,true);await pad(JOY_BUTTON_A,false)
		check("Pad A opens confirmation",s.stage=="confirm")
		await pad(JOY_BUTTON_B,true);await pad(JOY_BUTTON_B,false)
		check("Pad B returns to cards",s.stage=="choose" and s.chosen==-1)
		await axis(1.0);await axis(0.0);await axis(1.0);await axis(0.0)
		check("Stick centre and repress move two cards",s.pick==2)
		await pad(JOY_BUTTON_A,true);await pad(JOY_BUTTON_A,false)
		await axis(-1.0);await axis(0.0);await pad(JOY_BUTTON_A,true);await pad(JOY_BUTTON_A,false)
		check("Pad stick plus A commits Rimefin",s.stage=="after" and s.chosen==2)
		await reset_cards()
		var binding:=InputEventKey.new();binding.physical_keycode=KEY_Q
		InputMap.action_erase_events("confirm");InputMap.action_add_event("confirm",binding)
		await tap(KEY_Q);check("Rebound confirm opens question",s.stage=="confirm")
		await tap(KEY_LEFT);await tap(KEY_Q);check("Rebound confirm commits",s.stage=="after" and s.chosen==0)
		for layout in [["base",Vector2i(1152,648)],["wide",Vector2i(1536,648)],["tall",Vector2i(960,720)]]:
			root.size=layout[1];await frames(6);await reset_cards()
			var screen: Transform2D=root.get_stretch_transform()*s._ui.get_screen_transform()
			print("SCREEN_TRANSFORM ",layout[0]," ",screen," UI=",s._ui.position," root=",root.get_visible_rect())
			await click(screen*s._card_rect(1).get_center())
			check(layout[0]+" mouse focuses Tallowroot",s.pick==1 and s.stage=="choose")
			await click(screen*s._card_rect(1).get_center())
			check(layout[0]+" second click asks",s.stage=="confirm" and s.chosen==-1)
			await shot(layout[0]+"-question")
			await click(screen*s._answer_rect(1).get_center())
			check(layout[0]+" mouse No preserves choice",s.stage=="choose" and s.pick==1 and s.chosen==-1)
			await click(screen*s._card_rect(1).get_center());await click(screen*s._answer_rect(0).get_center())
			check(layout[0]+" mouse Yes commits",s.stage=="after" and s.chosen==1)
		check("Shared showcase scale is a whole art pixel",s._card_scale()==floorf(s._card_scale()) and s._card_scale()>=1.0)
		for form in s.FORMS:
			var box: Rect2i=s.CreatureIdle.box(s.CreatureIdle.frames(form))
			check(form+" all-frame union fits portrait interior",box.size.x*s._card_scale()<=264 and box.size.y*s._card_scale()<=164)
		check("Selection uses dedicated UI cursor and confirm sounds",UI._ticks.has("cursor") and UI._ticks.has("confirm") and UI._ticks.cursor.bus==&"UI" and UI._ticks.confirm.bus==&"UI")
	check("Saved journey bytes unchanged",FileAccess.get_sha256(Team.save_path)==saved)
	s.queue_free();await frames(5)
	for p in UI._ticks.values():
		if is_instance_valid(p):p.queue_free()
	if is_instance_valid(UI._blip):UI._blip.free()
	var music:=root.get_node_or_null("HollowtideMusic")
	if music!=null:music.queue_free()
	Team.erase_save();await frames(5)
	var result:={"total":checks.size(),"failed":failures.size(),"checks":checks,"failures":failures}
	var f:=FileAccess.open(W+"/"+phase+"-result.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"  "));f.close()
	print("STARTER CARDS RESULT ",checks.size()," checks, ",failures.size()," failures");quit(0 if failures.is_empty() else 1)
