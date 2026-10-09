extends SceneTree
## The first fight on the levee (Claude, 2026-10-09): with a partner chosen, the Cinderhide on
## the levee opens an arena 1v1 (you steer your partner, story mode); a loss returns you to the
## levee with the creature still there; a win clears the road. The launch setting points at
## the opening flow.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/first_fight_check.gd
## Stills to docs/world/first-fight-2026-10-09/.

const OUT := "res://docs/world/first-fight-2026-10-09/"
var journey: Node2D
var party: Node

func _initialize() -> void:
	_run.call_deferred()   # the autoloads (PlayerParty) exist only after the tree starts


func _run() -> void:
	party = root.get_node("PlayerParty")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	print("Launch scene: %s" % ProjectSettings.get_setting("application/run/main_scene"))
	journey = load("res://scenes/world_journey.tscn").instantiate()
	journey.set_courier_model("Male")
	journey.begin_first_morning(true)
	root.add_child(journey)
	await _frames(12)
	# Skip the hall story: the partner is chosen (Kithflare) and the story is complete.
	var story: Node = journey.partner_story
	party.add(story.STARTERS[0])
	story.completed = true
	var ff: Node = journey.first_fight
	print("First morning set up: partner %s, first-fight script %s" % [party.active_creature().creature_name, "attached" if ff != null else "missing (WRONG)"])
	# To the levee.
	journey.travel("route1", Vector2(-720, 512), Vector2.RIGHT)
	await _frames(30)
	var enc: Node = journey.active_area.get_node_or_null("CinderhideEncounter")
	var bridged: bool = enc != null and enc.get("_battle_screen") == ff
	print("On the levee (%s): the Cinderhide's battle screen is the arena bridge: %s" % [journey.active_id, str(bridged)])
	# 1. Meet it: the arena opens with Kithflare against Cinderhide, you at the controls, story mode.
	ff.start(enc.creature)
	await _frames(6)
	var arena: Node2D = journey.get_node("FirstFightArena").get_child(0)
	var names := []
	for f in arena._fighters:
		names.append("%s:%s" % ["you" if f["team"] == 0 else "wild", f["name"]])
	print("Arena: %s; you steer %s; story mode %s; the journey is paused: %s" % [str(names), arena._fighters[arena.controlled]["name"], str(arena.story_mode), str(journey.process_mode == Node.PROCESS_MODE_DISABLED)])
	await _frames(40)
	_save("fight")
	# 2. A loss: Kithflare down. The levee returns with the Cinderhide still there.
	arena._fighters[0]["hp"] = 0
	arena._check_winner(1)
	var waited := 0
	while journey.has_node("FirstFightArena") and waited < 200:
		await process_frame
		waited += 1
	var panel_text: String = journey.route.get("_body").text
	print("Loss: back on the levee after %.1f s with the Cinderhide %s; message '%s'" % [waited / 30.0, "still there" if is_instance_valid(enc) and enc.visible else "gone (WRONG)", panel_text.left(60)])
	_save("after_loss")
	journey.route.get("_panel").hide()
	# 3. A win: the Cinderhide leaves and the road is open.
	ff.start(enc.creature)
	await _frames(6)
	arena = journey.get_node("FirstFightArena").get_child(0)
	arena._fighters[1]["hp"] = 0
	arena._check_winner(0)
	waited = 0
	while journey.has_node("FirstFightArena") and waited < 200:
		await process_frame
		waited += 1
	await process_frame
	panel_text = journey.route.get("_body").text
	print("Win: back on the levee after %.1f s; the Cinderhide %s; won flag %s; message '%s'" % [waited / 30.0, "is gone" if not is_instance_valid(enc) or not enc.visible or enc.process_mode == Node.PROCESS_MODE_DISABLED else "still there (WRONG)", str(ff.won), panel_text.left(60)])
	_save("after_win")
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
