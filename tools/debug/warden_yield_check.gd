extends SceneTree
## The pilot's climax is never a dead end (Claude, 2026-10-12). In the Warden's room, with the Warden worn down, the
## leader going down starts the stand-off and the stone instead of a faint; with the Warden still strong it is a faint
## as before. Headless: the scene's lines are read as a player would press E, and the run must end cleared with the
## stone carried and a level-5 leader (the shrine gate).
## Pass 7 (Claude, 2026-10-26, L7-01 and L7-02): the ending is read at a player's pace (each line up 1.5 s), every
## typed line is recorded, and a line said twice, back to back or anywhere in the ending, is a FAIL (a blow queued
## after the Warden's fall used to replay the whole ending three times). The leader falls to a real blow, so its
## knock-out fade runs, and it must stay whole and in sight on every frame of the scene. A second blow on the fallen
## Warden replays nothing and pays no second EXP.
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/warden_yield_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const READ_FRAMES := 45        # 1.5 s on each line at the checks' 30 frames a second
const ENDING_MAX_SECS := 100.0 # the ending, read at that pace, from the fall to the town (about 85 s of it unique)
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
## With `play_intro` its entrance has played out first.
func _room(frac: float, play_intro := true) -> Node2D:
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
	# The Warden's entrance plays out first, as it does in play (L7-01): left running, its own lines ("Rest, then. The
	# pond will keep you." among them) came in the middle of the ending and read as repeats.
	var guard := 0
	while play_intro and not dg.intro.get("done", false) and guard < 30 * 180:
		await process_frame
		guard += 1
		if not dg.talk.is_empty() and guard % 4 == 0:
			dg.act_talk()
	if play_intro and not dg.intro.get("done", false):
		_ok("The Warden's entrance ends within %d frames" % guard, false)
	await _frames(3)
	dg.boss_met = true
	dg.cutscene = false
	dg.talk.clear()
	var w: Dictionary = dg.ents[dg.boss]
	w["awake"] = true
	w["hp"] = maxi(1, int(round(w["max_hp"] * frac)))
	return dg


## The ending played to the town at a reader's pace: E after a line has been up READ_FRAMES (twice when the first
## press only finishes the typing). Returns every typed line in order, the frames it took, and the leader's least
## alpha and frames out of sight while a scene was on.
func _play_ending(dg: Node2D, limit: int) -> Dictionary:
	var lines: Array = []
	var cur: Variant = null
	var up := 0
	var frames := 0
	var min_a := 1.0
	var hidden := 0
	var lying := false
	while not dg.has_meta("went_to_town") and frames < limit:
		await process_frame
		frames += 1
		if dg.cutscene and not dg.ents.is_empty():
			var n: Node2D = dg.ents[0]["node"]
			min_a = minf(min_a, n.modulate.a)
			if not n.visible:
				hidden += 1
			if frames < 10 and dg.ents[0].get("down", false):
				lying = true
		if dg.talk.is_empty():
			cur = null
			continue
		if not (cur is Array) or not is_same(dg.talk[0], cur):
			cur = dg.talk[0]
			up = 0
			lines.append("%s: %s" % [cur[0], cur[1]])
		up += 1
		if up >= READ_FRAMES:
			dg.act_talk()
			if not dg.talk.is_empty() and is_same(dg.talk[0], cur):
				dg.act_talk()
	return {"lines": lines, "frames": frames, "min_a": min_a, "hidden": hidden, "lying": lying}


## Every line of the ending once: a FAIL line for each one said twice in a row or twice anywhere (L7-01).
func _lines_once(label: String, lines: Array) -> void:
	var seen := {}
	var twice: Array = []
	var in_a_row := 0
	for k in lines.size():
		if k > 0 and lines[k] == lines[k - 1]:
			in_a_row += 1
			print("   repeated back to back at line %d: %s -> FAIL" % [k, lines[k]])
		if seen.has(lines[k]) and not twice.has(lines[k]):
			twice.append(lines[k])
		seen[lines[k]] = true
	for l in twice:
		print("   said twice in the ending: %s -> FAIL" % l)
	_ok("%s: %d typed lines, %d unique, %d back to back, %d said twice" % [label, lines.size(), seen.size(), in_a_row, twice.size()],
		in_a_row == 0 and twice.is_empty() and not lines.is_empty())


## All the EXP a line has earned: the levels it has climbed plus what it holds toward the next.
func _total_exp(dg: Node2D, rec: Dictionary) -> int:
	var n := int(rec["exp"])
	for lv in range(1, int(rec["lv"])):
		n += dg.exp_to_next(lv)
	return n


func _run() -> void:
	# 1. Worn down: the Warden's blow drops the leader (its knock-out fade starts), the stand-off plays, the run ends
	# cleared with the stone, and the leader is in sight on every frame of it.
	var dg := await _room(0.05)
	var w: Dictionary = dg.ents[dg.boss]
	print("The Warden at %d of %d, the leader Lv %d" % [w["hp"], w["max_hp"], dg.level_of(0)])
	dg._wound(dg.boss, 0, int(dg.ents[0]["hp"]), Color(1, 1, 1))
	dg._end_turn()
	await _frames(2)
	_ok("No faint: faints %d, the scene on (%s), the Warden at %d" % [dg.faints, str(dg.cutscene), dg.ents[dg.boss]["hp"]], dg.faints == 0 and dg.cutscene)
	var r1 := await _play_ending(dg, 30 * 200)
	_ok("The stand-off and the stone play out: went '%s' after %d frames, cleared %d, stone '%s'" % [str(dg.get_meta("went_to_town", "")), r1["frames"], dg.cleared, str(dg.story.get("stone", ""))],
		String(dg.get_meta("went_to_town", "")) == "cleared" and dg.cleared == 1 and String(dg.story.get("stone", "")) == "carried")
	_ok("The leader stands at the shrine gate: Lv %d, HP %d" % [dg.level_of(0), dg.ents[0]["hp"]], dg.level_of(0) >= 5 and dg.ents[0]["hp"] > 0)
	_ok("The leader is seen all through the scene: least alpha %.2f, %d frames hidden, lying where it fell at the start %s" % [r1["min_a"], r1["hidden"], str(r1["lying"])],
		r1["min_a"] > 0.9 and r1["hidden"] == 0 and r1["lying"])
	_lines_once("The ending after the leader falls", r1["lines"])
	_ok("The ending at a reader's pace: %.1f s from the fall to the town (under %d)" % [r1["frames"] / 30.0, int(ENDING_MAX_SECS)], r1["frames"] / 30.0 < ENDING_MAX_SECS)
	dg.queue_free()
	await _frames(3)
	# 4. The partner drops the Warden, and a blow queued behind it lands after the stand-off has stood it back up at 1 HP:
	# the ending plays once and the boss's EXP is paid once (L7-01).
	var d4 := await _room(0.05)
	var w4: Dictionary = d4.ents[d4.boss]
	var rec0: Dictionary = d4.levels[0].duplicate()
	var c: Dictionary = load("res://scripts/dungeon/dungeon.gd").get_script_constant_map()
	var grant: int = int(c["EXP_PER_KO"]) + int(c["EXP_PER_STAGE"]) * int(w4["stage"]) + int(c["EXP_BOSS"])
	d4._wound(1, d4.boss, int(w4["hp"]), Color(1, 1, 1))
	await _frames(2)
	var stood := int(w4["hp"])
	d4._wound(1, d4.boss, maxi(1, stood), Color(1, 1, 1))
	var r4 := await _play_ending(d4, 30 * 200)
	_ok("A second blow after the fall (the Warden stood at %d HP): went '%s', cleared %d" % [stood, str(d4.get_meta("went_to_town", "")), d4.cleared],
		String(d4.get_meta("went_to_town", "")) == "cleared" and d4.cleared == 1)
	_lines_once("The ending with a second blow", r4["lines"])
	var gained: int = _total_exp(d4, d4.levels[0]) - _total_exp(d4, rec0)
	_ok("The Warden's EXP paid once: the leader gained %d, one grant is %d" % [gained, grant], gained == grant)
	d4.queue_free()
	await _frames(3)
	# 2. Still strong: the climax is unlosable (Preston, 2026-10-12), so this is the stand-off too, not a faint.
	var d2 := await _room(0.8)
	d2.ents[0]["hp"] = 0
	d2._end_turn()
	await _frames(2)
	_ok("With the Warden at %d of %d it is still the stand-off (faints %d, scene on %s)" % [d2.ents[d2.boss]["hp"], d2.ents[d2.boss]["max_hp"], d2.faints, str(d2.cutscene)],
		d2.faints == 0 and d2.cutscene and not d2.has_meta("went_to_town"))
	d2.queue_free()   # before the next room: two rooms' lines at once share the one typed-line state (UI.line_done)
	await _frames(3)
	# 3. Before the Warden wakes (a Listener in the dark), it is a faint as anywhere else.
	var d3 := await _room(1.0, false)   # no entrance: after it the team stands in the Warden's sight and wakes it
	d3.ents[d3.boss]["awake"] = false
	d3.ents[0]["hp"] = 0
	d3._end_turn()
	await _frames(2)
	_ok("Before the Warden wakes it is a faint (faints %d, went '%s')" % [d3.faints, str(d3.get_meta("went_to_town", ""))],
		d3.faints == 1 and String(d3.get_meta("went_to_town", "")) == "fainted")
	d3.queue_free()
	print("WARDEN YIELD: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
