extends SceneTree
## The loop with real scene changes (Claude, 2026-10-09; Preston: "prologue to town to hollow and
## back"): the prologue now wakes the team on the riverbank (the pilot reaches Highbank through the
## Hollow Mouth, pilot_chain_check), so the check opens Highbank itself; the Mouth of the
## Hollow starts a run with the team record; a clear brings the record home (bag, taught moves, IQ,
## recruits) and greets the team at the Hall; the next run gets it back; a faint comes home with the
## bag lost. Each step is a verdict line (Claude, 2026-10-24, H04).
##   Godot --path . --fixed-fps 30 --script res://tools/debug/town_loop_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


## Stop here when a step did not reach the scene the next one needs (its fields would not exist). Highbank and a
## dungeon floor first show their place card for two frames and build after it (pass 4, T4 and L03b), so this
## also waits for the town's team or the floor's creatures (Claude, 2026-10-24).
func _stop_unless(file: String) -> bool:
	for k in 30 * 10:
		if _scene() == file and _built():
			break
		await _frames(1)
	if _scene() == file and _built():
		return false
	_ok("Expected %s, the scene is %s; the rest is not run" % [file, _scene()], false)
	quit(1)
	return true


func _built() -> bool:
	if _scene() == "hub_town.tscn":
		return not current_scene.team.is_empty()
	if _scene() == "dungeon.tscn":
		return not current_scene.ents.is_empty()
	return current_scene != null


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _scene() -> String:
	return current_scene.scene_file_path.get_file() if current_scene != null else "none"


## A line's IQ in a record, whether its keys are numbers or (after a save) text.
func _iq(iq: Dictionary, line: int) -> int:
	return int(iq.get(line, iq.get(str(line), -1)))


func _run() -> void:
	# 1. The prologue: press through it. It ends on the riverbank, not in Highbank.
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
	var party0: Array = TeamState.data.get("party", [])
	_ok("Prologue: after %d presses the team wakes on the riverbank (%s), party %s" % [presses, _scene(), str(party0)],
		_scene() == "waking_riverbank.tscn" and str(party0) == str([[0, 0], [1, 0]]))
	# Highbank, opened directly with the same starting pair.
	TeamState.start([[0, 0], [1, 0]])
	change_scene_to_node(_town())
	await _frames(6)
	if await _stop_unless("hub_town.tscn"):
		return
	var town: Node = current_scene
	print("Town: spawned at %s with %s" % [str(town.team[0]["pos"]), str(town.team.map(func(e: Dictionary) -> String: return e["form"]))])

	# 2. Into the Hollow.
	town.team[0]["pos"] = Vector2i(32, 28)
	town._place(town.team[0])
	await town.act_move(Vector2i(1, 0))
	await _frames(8)
	var dg: Node = current_scene
	_ok("The Mouth of the Hollow: the scene is %s, back to town after %s, party %s" % [_scene(), str(dg.get("return_to_town")), str(dg.get("party"))],
		_scene() == "dungeon.tscn" and dg.get("return_to_town") == true)
	if await _stop_unless("dungeon.tscn"):
		return

	# 3. Things to carry home, then a clear.
	dg.bag["lamp_oil"] = 2
	var key := "%d:%d" % [dg.party[0][0], dg.party[0][1]]
	var mate_line := int(dg.party[1][0])
	dg.taught[key] = dg.ents[0]["moves"].duplicate()
	dg.iq[mate_line] = 7
	dg.cleared = 0
	dg._finish_after_boss()
	await _frames(30 * 4)
	if await _stop_unless("hub_town.tscn"):
		return
	town = current_scene
	var news: String = town.panel.get("what", "")
	var bag: Dictionary = TeamState.data.get("bag", {})
	var iq: Dictionary = TeamState.data.get("iq", {})
	_ok("After a clear: the leader at %s (the Hall's steps %s); news '%s'; the record's bag %s, IQ %s, cleared %s" % [str(town.team[0]["pos"]), str(town.RETURN_SPOT), news, str(bag), str(iq), str(TeamState.data.get("cleared", 0))],
		town.team[0]["pos"] == town.RETURN_SPOT and news != "" and int(bag.get("lamp_oil", 0)) == 2 and _iq(iq, mate_line) == 7 and int(TeamState.data.get("cleared", 0)) == 1)

	# 4. The next run gets it back.
	town.panel = {}
	town.team[0]["pos"] = Vector2i(32, 28)
	town._place(town.team[0])
	await town.act_move(Vector2i(1, 0))
	await _frames(8)
	if _scene() == "hollow_approach.tscn":
		# The Hollow is reached through its entrance scene (hollow_approach.gd, 2026-10-10): confirm it.
		print("The Hollow's entrance scene opens first")
		var waited := 0
		while not current_scene.ready_to_cross and waited < 30 * 20:
			await _frames(1)
			waited += 1
		current_scene.confirm()
		waited = 0
		while _scene() == "hollow_approach.tscn" and waited < 30 * 20:
			await _frames(1)
			waited += 1
		await _frames(4)
	if await _stop_unless("dungeon.tscn"):
		return
	dg = current_scene
	_ok("Second run: bag %s, taught for %s %s, IQ %s" % [str(dg.bag), key, str(dg.taught.has(key)), str(dg.iq)],
		int(dg.bag.get("lamp_oil", 0)) == 2 and dg.taught.has(key) and _iq(dg.iq, mate_line) == 7)

	# 5. A faint comes home with the bag lost.
	dg.ents[0]["hp"] = 0
	dg._end_turn()
	await create_timer(0.9).timeout   # the fade to the faint screen (2026-10-12)
	var faint: Node = current_scene
	_ok("After a faint: the faint screen first (%s), page %s: '%s'" % [_scene(), str(faint.get("page")), faint._word() if faint.has_method("_word") else ""],
		_scene() == "faint_screen.tscn" and faint.get("page") == 0)
	if await _stop_unless("faint_screen.tscn"):
		return
	faint.advance()   # the partner's word finishes
	faint.advance()   # the defeat panel
	faint.advance()   # home
	await _frames(6)
	town = current_scene
	bag = TeamState.data.get("bag", {})
	_ok("Then home: the scene is %s; news '%s'; the record's bag %s (the lamp oil lost)" % [_scene(), town.panel.get("what", "") if _scene() == "hub_town.tscn" else "", str(bag)],
		_scene() == "hub_town.tscn" and bag.size() == 1 and int(bag.get("reedberry", 0)) == 1)
	quit(1 if fails else 0)


func _town() -> Node:
	var t: Node = load("res://scenes/hub_town.tscn").instantiate()
	TeamState.give_to(t)
	return t
