extends SceneTree

## Run with Godot --headless --path <project> --script res://tests/field_encounter_smoke.gd.
## Exercises the real main scene, physics overlap, E input, a selected move, and Flee.

func _initialize() -> void:
	call_deferred("_run")


func _require(condition: bool, description: String) -> bool:
	if not condition:
		push_error("FAIL: " + description)
		quit(1)
		return false
	print("PASS: " + description)
	return true


func _wait_until(condition: Callable, seconds: float = 5.0) -> bool:
	var deadline := Time.get_ticks_msec() + int(seconds * 1000.0)
	while not condition.call():
		if Time.get_ticks_msec() >= deadline:
			return false
		await create_timer(0.02).timeout
	return true


func _settle_physics() -> void:
	for frame in range(4):
		await physics_frame
	await process_frame


func _press_interact() -> void:
	var press := InputEventKey.new()
	press.physical_keycode = KEY_E
	press.keycode = KEY_E
	press.pressed = true
	Input.parse_input_event(press)
	await process_frame
	var release := InputEventKey.new()
	release.physical_keycode = KEY_E
	release.keycode = KEY_E
	release.pressed = false
	Input.parse_input_event(release)
	await process_frame


func _run() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	if not _require(scene != null, "main scene loads"):
		return
	var main := scene.instantiate()
	root.add_child(main)
	current_scene = main
	await _settle_physics()

	var player: CharacterBody2D = main.get_node("Player")
	var encounter: Area2D = main.get_node("CinderhideEncounter")
	var battle: Node = main.get_node("BattleScreen")
	var prompt := encounter.get_node("Prompt")
	var spawn := player.global_position
	if not _require(encounter.get_script() != null and prompt is Label, "encounter script and supported prompt load"):
		return
	if not _require(not prompt.visible and not battle.visible, "prompt and battle begin hidden"):
		return

	await _press_interact()
	if not _require(not paused and not battle.visible, "E at a distance does not start battle"):
		return

	player.global_position = encounter.global_position + Vector2(0, 20)
	await _settle_physics()
	if not _require(prompt.visible and encounter.get("_player_nearby"), "physics overlap shows the encounter prompt"):
		return
	await _press_interact()
	if not _require(paused and battle.visible, "E near Cinderhide opens battle and pauses the world"):
		return
	if not _require(battle.get("_foe").creature_name == "Cinderhide" and battle.player_creature.creature_name == "Cinderhide", "wild Cinderhide meets your Cinderhide"):
		return

	var frozen_position := player.global_position
	Input.action_press("move_right")
	await create_timer(0.15).timeout
	Input.action_release("move_right")
	if not _require(player.global_position.is_equal_approx(frozen_position), "player cannot walk during battle"):
		return

	var strike: Button = battle.get("_strike_button")
	var choices: VBoxContainer = battle.get("_buttons")
	var ready := await _wait_until(func(): return choices.visible and not battle.get("_strike_button").disabled)
	if not _require(ready, "battle reaches its action choices"):
		return
	var foe_hp_before: int = battle.get("_foe_hp")
	strike.pressed.emit()
	var fire_seen := await _wait_until(func(): return battle.find_child("MoveEffect", false, false) != null)
	if not _require(fire_seen, "Cinderhide's turn throws a selected move effect"):
		return
	ready = await _wait_until(func(): return choices.visible and not battle.get("_strike_button").disabled)
	if not _require(ready and battle.get("_foe_hp") < foe_hp_before, "the selected move completes its animation and deals damage"):
		return
	if not _require(battle.get("_player_hp") < battle.player_creature.base_hp, "the foe takes its turn"):
		return
	if not _require(battle.get("_player_hp") <= battle.player_creature.base_hp - 8, "the foe's selected Ember move deals damage"):
		return

	var flee: Button = battle.get("_flee_button")
	if not _require(flee != null, "Flee control is present"):
		return
	flee.pressed.emit()
	var finished := await _wait_until(func(): return not paused and not battle.visible)
	if not _require(finished, "Flee returns to the world"):
		return

	var resumed_position := player.global_position
	Input.action_press("move_right")
	await create_timer(0.15).timeout
	Input.action_release("move_right")
	if not _require(player.global_position.distance_to(resumed_position) > 1.0, "movement resumes after battle"):
		return
	player.global_position = spawn
	await _settle_physics()
	if not _require(not prompt.visible and not encounter.get("_player_nearby"), "leaving the creature clears the prompt"):
		return
	await _press_interact()
	if not _require(not paused and not battle.visible, "E remains inactive outside the encounter after battle"):
		return

	player.global_position = encounter.global_position + Vector2(0, 20)
	await _settle_physics()
	await _press_interact()
	ready = await _wait_until(func(): return choices.visible and not battle.get("_strike_button").disabled)
	if not _require(ready and battle.get("_foe_hp") == battle.get("_foe").base_hp, "the encounter can be entered again with fresh battle HP"):
		return
	flee.pressed.emit()
	finished = await _wait_until(func(): return not paused and not battle.visible)
	if not _require(finished, "the second encounter also returns cleanly"):
		return
	print("FIELD_ENCOUNTER_SMOKE_OK")
	quit(0)

