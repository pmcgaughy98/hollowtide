extends SceneTree
## Current creature-player opening, independent of the F5 development scene.
## Native run: Godot --path . --fixed-fps 30 --script res://tools/debug/opening_flow_check.gd
## Arguments after --: hero=0|1|2 partner=0|1 reduced automatic-storm
## Writes only user://opening-flow-check/. Use an isolated APPDATA for checks.
const TITLE := "res://scenes/creature_opening.tscn"
const OUT := "user://opening-flow-check/"
const UI := preload("res://scripts/ui/ui_style.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
var checks: Array[Dictionary] = []
var failures: Array[String] = []
var hero := 0
var partner_choice := 0
var reduced := false
var automatic_storm := false

func _initialize() -> void:
	_run.call_deferred()

func frames(n: int) -> void:
	for k in n: await process_frame

func scene_name() -> String:
	return current_scene.scene_file_path.get_file() if is_instance_valid(current_scene) else "none"

func verify(label: String, good: bool) -> bool:
	checks.append({"check": label, "passed": good})
	if not good: failures.append(label)
	print(label, ": ", "PASS" if good else "FAIL")
	return good

func until(done: Callable, budget := 180) -> bool:
	for k in budget:
		if done.call(): return true
		await process_frame
	return done.call()

func key(code: Key) -> void:
	for down in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = down
		Input.parse_input_event(event)
		await frames(3)

func click(button: Button) -> void:
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = button.get_global_rect().get_center()
		event.global_position = event.position
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		Input.parse_input_event(event)
		await frames(3)

func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	verify("Capture " + label, image.save_png(OUT + label + ".png") == OK)

func finish() -> void:
	var result := {"hero": hero, "partner_choice": partner_choice, "reduced": reduced,
		"automatic_storm": automatic_storm, "checks": checks, "failures": failures}
	var file := FileAccess.open(OUT + "checks.json", FileAccess.WRITE)
	if file == null:
		push_error("Cannot write opening-flow check results")
		quit(1)
		return
	file.store_string(JSON.stringify(result, "  "))
	file.close()
	# Music survives scene changes; release it on test shutdown.
	var music := root.get_node_or_null("HollowtideMusic")
	if music != null: music.queue_free()
	if is_instance_valid(current_scene): current_scene.queue_free()
	await frames(3)
	# Dialogue Manager's evaluated expressions retain their resource as "self".
	# Clear that transient in-memory cache only after the test's scenes have exited.
	var dialogue: Resource = load("res://dialogue/flood_bank.dialogue")
	dialogue.set("lines", {})
	dialogue = null
	print("OPENING FLOW: ", checks.size(), " checks / ", failures.size(), " failures; ", ProjectSettings.globalize_path(OUT))
	quit(0 if failures.is_empty() else 1)

func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("hero="): hero = arg.trim_prefix("hero=").to_int()
		elif arg.begins_with("partner="): partner_choice = arg.trim_prefix("partner=").to_int()
		elif arg == "reduced": reduced = true
		elif arg == "automatic-storm": automatic_storm = true
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	if not verify("Valid starter/partner arguments", hero in [0, 1, 2] and partner_choice in [0, 1]):
		await finish(); return
	root.size = Vector2i(1152, 648)
	root.content_scale_size = root.size
	var config := ConfigFile.new()
	config.set_value("menu", "reduce_motion", reduced)
	config.save("user://menu_preferences.cfg")
	var main_before: String = ProjectSettings.get_setting("application/run/main_scene")
	var title: Node = load(TITLE).instantiate()
	root.add_child(title)
	current_scene = title
	if not verify("Explicit campaign title reveals", await until(func() -> bool: return title._boot_done and title._page == "main")):
		await finish(); return
	verify("Title respects Reduce Motion", title._reduce_motion == reduced)
	verify("Title is current creature campaign", scene_name() == "creature_opening.tscn")
	await capture("1-title")
	await click(title._buttons[0])
	if not verify("New Game enters storm via real title button", await until(func() -> bool: return scene_name() == "storm_open.tscn")):
		await finish(); return
	await frames(8)
	var storm: Node = current_scene
	verify("Storm receives Reduce Motion", storm.reduce_motion == reduced)
	await capture("2-storm")
	if automatic_storm:
		verify("Storm time freezes and greys", await until(func() -> bool: return is_instance_valid(storm) and storm.frozen and storm.grey > 0.99, 900))
		await capture("3-frozen")
		verify("Soul pixel cluster descends in actual Storm", await until(func() -> bool: return is_instance_valid(storm) and storm.soul_glow > 0.99 and storm.soul_at.y > 30.0, 300))
		await capture("3b-descending-pixels")
		verify("Soul cluster reaches original waking spot before bloom", await until(func() -> bool: return is_instance_valid(storm) and storm.soul_at.distance_to(storm.WAKE_AT) < 1.0 and storm.white == 0.0, 240))
		await capture("3c-landed-pixels")
	else:
		await key(KEY_ENTER)
		verify("First Storm press only arms skip", current_scene == storm and storm._skip_armed)
		await key(KEY_ENTER)
	if not verify("Storm enters actual soul scene", await until(func() -> bool: return scene_name() == "soul_prologue.tscn", 900)):
		await finish(); return
	var soul: Node = current_scene
	verify("Soul receives Reduce Motion", soul.reduce_motion == reduced)
	for k in 30:
		if soul.stage == "choose": break
		await key(KEY_ENTER)
	if not verify("Soul dialogue reaches three starter cards", soul.stage == "choose" and soul.FORMS.size() == 3):
		await finish(); return
	for k in hero: await key(KEY_RIGHT)
	verify("Keyboard selects requested creature", soul.pick == hero)
	await capture("4-choice")
	await frames(14)   # cards ignore the reading press for 0.4 s
	await key(KEY_ENTER)
	verify("Starter asks before committing and defaults to No", soul.stage == "confirm" and soul.chosen == -1 and soul._answer == 1)
	await key(KEY_LEFT)
	await key(KEY_ENTER)
	verify("Soul confirms selected starter", soul.chosen == hero and soul.stage == "after")
	for k in 12:
		if soul.stage in ["fly", "done"]: break
		await key(KEY_ENTER)
	if not verify("Soul hands off to real flood scene", await until(func() -> bool: return scene_name() == "creature_prologue.tscn")):
		await finish(); return
	var flood: Node = current_scene
	if not verify("Dialogue Manager supplies flood narration", await until(func() -> bool: return flood.line != null)):
		await finish(); return
	verify("Chosen hero survives handoff without another starter choice", flood.hero == hero and flood.chosen_by_soul and flood.line.responses.is_empty())
	verify("Flood begins as unnamed narration", flood.line.character == "")
	await capture("5-flood")
	for k in 15:
		if flood.line == null or not flood.line.responses.is_empty(): break
		UI.finish_line()
		await key(KEY_E)
	var others: Array = [0, 1, 2].filter(func(i: int) -> bool: return i != hero)
	var names: Array = flood.line.responses.map(func(r) -> String: return r.text) if flood.line != null else []
	if not verify("Partner choice offers exactly the other two starters", names == others.map(func(i: int) -> String: return flood.NAMES[i])):
		await finish(); return
	UI.finish_line()
	if partner_choice == 1: await key(KEY_DOWN)
	verify("Keyboard selects requested partner response", flood.choice == partner_choice)
	await capture("6-partner-choice")
	await frames(12)   # an answer list takes accept once it has been up 0.3 s (pass 8 S1, L06)
	await key(KEY_E)
	var expected_partner: int = others[partner_choice]
	verify("Chosen partner appears and speaks", flood.partner == expected_partner and flood.partner_sprite.visible and flood.line != null and flood.line.character == flood.NAMES[expected_partner])
	for k in 60:
		if scene_name() != "creature_prologue.tscn" or flood.leaving: break
		UI.finish_line()
		await key(KEY_E)
	if not verify("Flood ends on actual playable riverbank", await until(func() -> bool: return scene_name() == "waking_riverbank.tscn")):
		await finish(); return
	await frames(8)
	verify("Team record contains exactly chosen hero and partner", TeamState.data.get("party", []) == [[hero, 0], [expected_partner, 0]])
	verify("F5 development scene setting preserved", ProjectSettings.get_setting("application/run/main_scene") == main_before)
	await capture("7-riverbank")
	await finish()
