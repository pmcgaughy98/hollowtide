extends SceneTree
const OUTPUT := "D:/dev/hollowtide-opening-20261008/review/"
var menu: Node2D
var checks: Array[Dictionary] = []
var failures: Array[String] = []
var model := "Male"
var starter := 0
var mode := "keyboard"
var tag := ""

func _initialize() -> void:
	_run()

func frames(count: int) -> void:
	for i in count: await process_frame

func verify(label: String, okay: bool) -> void:
	checks.append({"check":label,"passed":okay})
	if not okay: failures.append(label)
	print(label, ": ", "PASS" if okay else "FAIL")

func key(code: int) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await frames(2)
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await frames(3)

func pad(button: int) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	event.pressed = true
	Input.parse_input_event(event)
	await frames(2)
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await frames(3)

func click(control: Control) -> void:
	var at := control.get_global_rect().get_center()
	var move := InputEventMouseMotion.new()
	move.position = at
	move.global_position = at
	Input.parse_input_event(move)
	await frames(2)
	var event := InputEventMouseButton.new()
	event.position = at
	event.global_position = at
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	Input.parse_input_event(event)
	await frames(2)
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await frames(3)

func accept() -> void:
	if mode == "mouse": await click(root.gui_get_focus_owner())
	elif mode == "pad": await pad(JOY_BUTTON_A)
	else: await key(KEY_ENTER)

func cancel() -> void:
	if mode == "pad": await pad(JOY_BUTTON_B)
	else: await key(KEY_ESCAPE)

func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUTPUT + tag + "-" + label + ".png")

func inside(control: Control) -> bool:
	var rect := control.get_global_rect()
	return Rect2(Vector2.ZERO, Vector2(1152,648)).encloses(rect)

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0: model = args[0]
	if args.size() > 1: starter = int(args[1])
	if args.size() > 2: mode = args[2]
	tag = model.to_lower() + "-" + str(starter) + "-" + mode
	root.content_scale_size = Vector2i(1152,648)
	root.size = Vector2i(1152,648)
	# Each case starts with motion enabled; the reduced case switches it via UI.
	var preferences := ConfigFile.new()
	preferences.load("user://menu_preferences.cfg")
	preferences.set_value("menu","reduce_motion",false)
	preferences.save("user://menu_preferences.cfg")
	# A previous run is useful for proving cancel and failure preserve ownership.
	var party: Node = root.get_node("PlayerParty")
	party.caught.clear()
	party.active_slot = -1
	party.add(load("res://data/creatures/002_cinderhide.tres"))
	var previous: Array = party.caught.duplicate()
	verify("Previous run has one owned partner", previous.size() == 1)
	menu = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	root.add_child.call_deferred(menu)
	await frames(2)
	current_scene = menu
	await frames(10)
	verify("Launch prelude blocks menu input", menu._page == "boot" and not menu._main_panel.visible)
	await capture("launch")
	await key(KEY_ENTER)
	await frames(40)
	verify("Skip reveals menu without starting New Game", menu._boot_done and menu._page == "main")
	verify("Approved artwork menu fits canvas", inside(menu._main_panel) and menu._wordmark.texture != null)
	await capture("menu")
	# Options and cancel still work through the inherited controls.
	await key(KEY_DOWN)
	await accept()
	verify("Options retain inherited controls", menu._page == "options")
	if mode == "reduced":
		if not menu._reduce_motion: await click(menu._motion_button)
		verify("Reduce Motion is selectable in Options", menu._reduce_motion)
	await cancel()
	verify("Options return to menu", menu._page == "main")
	await key(KEY_UP)
	await accept()
	verify("New Game opens courier selection", menu._page == "journey")
	if menu._selected_courier != model:
		await key(KEY_RIGHT)
		await accept()
	verify("Courier choice uses selected model", menu._selected_courier == model)
	await capture("courier")
	await key(KEY_DOWN)
	await accept()
	verify("Continue opens three starter choices", menu._page == "starter" and menu._starter_cards.size() == 3)
	verify("Starter screen fits canvas", inside(menu._starter_panel))
	for i in starter: await key(KEY_RIGHT)
	verify("Arrow focus previews intended partner", menu._starter_index == starter)
	if mode == "mouse": await click(menu._starter_cards[starter])
	else: await accept()
	verify("Selected partner is explicit", menu._starter_cards[starter].button_pressed and menu._starter_action.text.contains(menu.STARTERS[starter].creature_name))
	await capture("starters")
	await accept()
	verify("Partner choice opens confirmation", menu._page == "confirm")
	verify("Confirmation fits canvas", inside(menu._confirm_panel))
	await capture("confirmation")
	await cancel()
	verify("Cancel returns to selected partner", menu._page == "starter" and menu._starter_index == starter)
	verify("Preview and cancellation preserve previous party", party.caught == previous)
	await cancel()
	verify("Starter Back returns to courier", menu._page == "journey" and menu._selected_courier == model)
	await accept()
	# Focus follows the selected card when revisiting the choice.
	await accept()
	await accept()
	verify("Revisit retains intended partner", menu._page == "confirm" and menu._starter_index == starter)
	if mode == "reduced":
		await frames(3)
		verify("Reduce Motion freezes partner animation", menu._portrait_frame == 0)
	# Exercise a safe, recoverable missing destination before final commitment.
	var route_scene: PackedScene = menu._route_scene
	menu._route_scene = null
	await accept()
	verify("Unavailable journey keeps confirmation recoverable", menu._page == "confirm" and menu._opening_status.visible and not menu._leaving)
	verify("Unavailable journey preserves previous party", party.caught == previous)
	verify("Recovery message fits confirmation screen", inside(menu._confirm_panel))
	await capture("recovery")
	menu._route_scene = route_scene
	await accept()
	await frames(120)
	var journey: Node2D = current_scene
	verify("Confirmation enters connected hometown and frees menu", not is_instance_valid(menu) and journey.get("active_id") == "hometown")
	verify("Chosen starter becomes the only partner", party.caught.size() == 1 and party.active_creature() == load(["res://data/creatures/103_kithflare.tres","res://data/creatures/1701_tallowroot.tres","res://data/creatures/001_rimefin.tres"][starter]))
	verify("Courier reaches world without changing model", journey.courier_model == model and journey.active_area.get_node("Player").chibi_model == model)
	var arrival := journey.get_node("FirstPartnerArrival")
	var portrait := arrival.get_node("WelcomeCard").get_child(0).get_child(0)
	verify("Matching portrait uses eight original front idle frames", portrait.frames == load(["res://data/portraits/kithflare_front_idle.tres","res://data/portraits/tallowroot_front_idle.tres","res://data/portraits/rimefin_front_idle.tres"][starter]) and portrait.frames.get_frame_count(&"idle") == 8)
	verify("Partner welcome fits canvas", inside(arrival.get_node("WelcomeCard")))
	await capture("hometown")
	await key(KEY_P)
	verify("Chosen partner is visible in world party panel", journey.route._party_panel.visible and journey.route._party_buttons[0].text.contains(party.active_creature().creature_name))
	await capture("party")
	await cancel()
	var output := FileAccess.open(OUTPUT + tag + "-checks.json", FileAccess.WRITE)
	output.store_string(JSON.stringify({"model":model,"starter":starter,"mode":mode,"checks":checks,"failures":failures},"  "))
	journey.queue_free()
	await frames(4)
	quit(0 if failures.is_empty() else 1)
