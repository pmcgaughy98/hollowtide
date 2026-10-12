extends SceneTree
## The pilot's climax is never a dead end (Claude, 2026-10-12). In the Warden's room, with the Warden worn down, the
## leader going down starts the stand-off and the stone instead of a faint; with the Warden still strong it is a faint
## as before. Headless: the scene's lines are read as a player would press E, and the run must end cleared with the
## stone carried and a level-5 leader (the shrine gate).
##   Godot --headless --path . --script res://tools/debug/warden_yield_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _frames(n: int) -> void:
	for k in n:
		await process_frame


## The Warden's room with the fight already under way: the Warden met and awake, at `frac` of its health.
func _room(frac: float) -> Node2D:
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["story"] = {"met_crew": true, "parcel": "delivered", "guild_trial": true, "runner": true, "road_talk": true}
	TeamState.data["beaten"] = ["mouth", "first"]
	TeamState.data["levels"] = {0: {"lv": 4, "exp": 150}, 1: {"lv": 4, "exp": 150}}
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 7
	dg.poll_input = false
	TeamState.give_to(dg)
	dg.dungeon = "hollow"
	dg.return_to_town = true
	root.add_child(dg)
	await _frames(3)
	dg.floor_n = dg.floors() + 1
	dg._build_floor(false)
	await _frames(3)
	dg.boss_met = true
	dg.cutscene = false
	dg.talk.clear()
	var w: Dictionary = dg.ents[dg.boss]
	w["awake"] = true
	w["hp"] = maxi(1, int(round(w["max_hp"] * frac)))
	return dg


func _run() -> void:
	# 1. Worn down: the leader falls, the stand-off plays, the run ends cleared with the stone.
	var dg := await _room(0.05)
	var w: Dictionary = dg.ents[dg.boss]
	print("The Warden at %d of %d, the leader Lv %d" % [w["hp"], w["max_hp"], dg.level_of(0)])
	dg.ents[0]["hp"] = 0
	dg._end_turn()
	await _frames(2)
	_ok("No faint: faints %d, the scene on (%s), the Warden at %d" % [dg.faints, str(dg.cutscene), dg.ents[dg.boss]["hp"]], dg.faints == 0 and dg.cutscene)
	var guard := 0
	while not dg.has_meta("went_to_town") and guard < 30 * 120:
		await process_frame
		guard += 1
		if not dg.talk.is_empty() and guard % 4 == 0:
			dg.act_talk()
	_ok("The stand-off and the stone play out: went '%s' after %d frames, cleared %d, stone '%s'" % [str(dg.get_meta("went_to_town", "")), guard, dg.cleared, str(dg.story.get("stone", ""))],
		String(dg.get_meta("went_to_town", "")) == "cleared" and dg.cleared == 1 and String(dg.story.get("stone", "")) == "carried")
	_ok("The leader stands at the shrine gate: Lv %d, HP %d" % [dg.level_of(0), dg.ents[0]["hp"]], dg.level_of(0) >= 5 and dg.ents[0]["hp"] > 0)
	dg.queue_free()
	await _frames(3)
	# 2. Still strong: the climax is unlosable (Preston, 2026-10-12), so this is the stand-off too, not a faint.
	var d2 := await _room(0.8)
	d2.ents[0]["hp"] = 0
	d2._end_turn()
	await _frames(2)
	_ok("With the Warden at %d of %d it is still the stand-off (faints %d, scene on %s)" % [d2.ents[d2.boss]["hp"], d2.ents[d2.boss]["max_hp"], d2.faints, str(d2.cutscene)],
		d2.faints == 0 and d2.cutscene and not d2.has_meta("went_to_town"))
	# 3. Before the Warden wakes (a Listener in the dark), it is a faint as anywhere else.
	var d3 := await _room(1.0)
	d3.ents[d3.boss]["awake"] = false
	d3.ents[0]["hp"] = 0
	d3._end_turn()
	await _frames(2)
	_ok("Before the Warden wakes it is a faint (faints %d, went '%s')" % [d3.faints, str(d3.get_meta("went_to_town", ""))],
		d3.faints == 1 and String(d3.get_meta("went_to_town", "")) == "fainted")
	d3.queue_free()
	d2.queue_free()
	print("WARDEN YIELD: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
