extends SceneTree
## The loop with real scene changes (Claude, 2026-10-09; Preston: "prologue to town to hollow and
## back"): the prologue opens Highbank; the Mouth of the Hollow starts a run with the team record;
## a clear brings the record home (bag, taught moves, IQ, recruits) and greets the team at the Hall;
## the next run gets it back; a faint comes home with the bag lost.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/town_loop_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _scene() -> String:
	return current_scene.scene_file_path.get_file() if current_scene != null else "none"


func _run() -> void:
	# 1. The prologue: press through it.
	change_scene_to_file("res://scenes/creature_prologue.tscn")
	await _frames(6)
	var pro: Node = current_scene
	var presses := 0
	while _scene() == "creature_prologue.tscn" and presses < 60:   # the flood talk: two presses a line (2026-10-11)
		if pro.has_method("advance"):
			pro.advance()
		presses += 1
		await _frames(25)
	await _frames(10)
	print("Prologue: after %d presses the scene is %s; the record's party %s" % [presses, _scene(), str(TeamState.data.get("party", []))])
	if _scene() != "hub_town.tscn":
		TeamState.start([[0, 0], [1, 0]])
		change_scene_to_node(_town())
		await _frames(6)
	var town: Node = current_scene
	print("Town: spawned at %s with %s" % [str(town.team[0]["pos"]), str(town.team.map(func(e: Dictionary) -> String: return e["form"]))])

	# 2. Into the Hollow.
	town.team[0]["pos"] = Vector2i(32, 28)
	town._place(town.team[0])
	await town.act_move(Vector2i(1, 0))
	await _frames(8)
	var dg: Node = current_scene
	print("The Mouth of the Hollow: the scene is %s, back to town after %s, party %s" % [_scene(), str(dg.get("return_to_town")), str(dg.get("party"))])

	# 3. Things to carry home, then a clear.
	dg.bag["lamp_oil"] = 2
	var key := "%d:%d" % [dg.party[0][0], dg.party[0][1]]
	dg.taught[key] = dg.ents[0]["moves"].duplicate()
	dg.iq[dg.party[1][0]] = 7
	dg.cleared = 0
	dg._finish_after_boss()
	await _frames(30 * 4)
	town = current_scene
	print("After a clear: the scene is %s; the leader at %s (the Hall's steps %s); news '%s'; the record's bag %s, IQ %s, cleared %s" % [_scene(), str(town.team[0]["pos"]), str(town.RETURN_SPOT), town.panel.get("what", ""), str(TeamState.data.get("bag", {})), str(TeamState.data.get("iq", {})), str(TeamState.data.get("cleared", 0))])

	# 4. The next run gets it back.
	town.panel = {}
	town.team[0]["pos"] = Vector2i(32, 28)
	town._place(town.team[0])
	await town.act_move(Vector2i(1, 0))
	await _frames(8)
	if _scene() == "hollow_approach.tscn":
		# The Hollow is reached through its entrance scene (hollow_approach.gd, 2026-10-10): confirm it.
		print("The Hollow's entrance scene opens first")
		while not current_scene.ready_to_cross:
			await _frames(1)
		current_scene.confirm()
		while _scene() == "hollow_approach.tscn":
			await _frames(1)
		await _frames(4)
	dg = current_scene
	print("Second run: bag %s, taught for %s %s, IQ %s" % [str(dg.bag), key, str(dg.taught.has(key)), str(dg.iq)])

	# 5. A faint comes home with the bag lost.
	dg.ents[0]["hp"] = 0
	dg._end_turn()
	await create_timer(0.9).timeout   # the fade to the faint screen (2026-10-12)
	var faint: Node = current_scene
	print("After a faint: the faint screen first (%s), page %d: '%s'" % [_scene(), faint.page, faint._word()])
	faint.advance()   # the partner's word finishes
	faint.advance()   # the defeat panel
	faint.advance()   # home
	await _frames(6)
	town = current_scene
	print("Then home: the scene is %s; news '%s'; the record's bag %s" % [_scene(), town.panel.get("what", ""), str(TeamState.data.get("bag", {}))])
	quit()


func _town() -> Node:
	var t: Node = load("res://scenes/hub_town.tscn").instantiate()
	TeamState.give_to(t)
	return t
