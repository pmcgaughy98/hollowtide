extends SceneTree
## Level 1 through the Hollow Mouth (Claude, 2026-10-22, factory lane 7, LP-25). The pilot's first dungeon on seeds
## 1 to 10, played the way dungeon_chain_check's leader plays, a person's simple policy: bump a foe beside it, walk
## up to one it sees close by, otherwise head for the stairs round the traps it has seen, and say yes to recruits.
## No autopilot, so no items, no moves beyond the bump and no resting to heal. The team is the pilot's starting pair
## at level 1, with an empty story, so the Mouth's last stairs play the parcel scene as in the pilot.
## One row per seed: how the run ended, the times it went down, the turns over every try (a try after going down
## starts again at B1F on a new layout, as the game does when the Mouth runs alone), the deepest floor, the lowest share of
## health the leader stood at, the leader's level and the team's size at the end. It judges only that every seed gave
## its row (Claude, 2026-10-24, H27), so a run that stops part way shows: the table is for Grok
## (docs/team/GROK_TASKS_2026-10-22.md, LP-25: the Mouth's spawns and the autopilot's REST_TO are his).
## Engine.time_scale plays the animations faster; every count here is in turns, which it does not change.
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/lv1_run_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const SEEDS := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
const MAX_TURNS := 600     # a seed still short of the way out by then is reported as out of turns
const MAX_DOWNS := 3       # a seed stops after the team goes down this many times
const SPEED := 6.0         # Engine.time_scale while the runs play


func _initialize() -> void:
	_run.call_deferred()


## Wait out what the last action started: the turn's animations, a line of talk, a recruit's question, the clear.
func _settle(dg: Node) -> void:
	for k in 30 * 60:
		if dg.asking >= 0:
			dg.act_recruit(true)
		elif not dg.talk.is_empty():
			if k % 3 == 0:
				UI.finish_line()
				dg.act_talk()
		elif not dg.busy and not dg.cutscene and not dg._finishing:
			return
		await process_frame


## One action of dungeon_chain_check's leader (tools/debug/dungeon_chain_check.gd), without its 999 HP.
## `stalled` turns it to a rest when the last actions spent no turn (a step it could not take).
func _act(dg: Node, stalled: bool) -> void:
	var lead: Dictionary = dg.ents[0]
	if stalled:
		dg.act_rest()
		return
	var foe_d := Vector2i.ZERO
	for d in dg.DIRS:
		var o: int = dg._occupant(lead["pos"] + d)
		if o >= 0 and dg._foes(0, o) and dg.ents[o]["awake"] and dg.can_step(lead["pos"], d):
			foe_d = d
	var near_at := Vector2i(-1, -1)
	for e in dg.ents:
		if e["team"] == 1 and e["hp"] > 0 and e["awake"] and dg._cheb(e["pos"], lead["pos"]) <= 3 and dg._sees(lead["pos"], e["pos"]):
			near_at = e["pos"]
	if foe_d != Vector2i.ZERO:
		dg.act_move(foe_d)
	elif near_at.x >= 0 and dg._step_toward(0, near_at, true, true) != Vector2i.ZERO:
		dg.act_move(dg._step_toward(0, near_at, true, true))   # walk up to it: a wild that shoots from range never comes close
	elif near_at.x >= 0:
		dg.act_rest()
	elif lead["pos"] == dg.data["stairs"]:
		dg.act_stairs()
	else:
		var d2: Vector2i = dg._step_toward(0, dg.data["stairs"], true, true)   # round the traps it has seen
		if d2 == Vector2i.ZERO:
			dg.act_rest()
		else:
			dg.act_move(d2)


func _run() -> void:
	Engine.time_scale = SPEED
	var mouth: Dictionary = load("res://scripts/dungeon/dungeon.gd").DUNGEONS["mouth"]
	var floors: int = int(mouth["floors"])
	var spawns: Dictionary = mouth["spawns"]
	print("Level 1 through the Hollow Mouth (%d floors), dungeon_chain_check's leader, no autopilot; spawns by floor %s" % [floors, str(spawns)])
	print("  %-4s  %-14s  %-5s  %-5s  %-7s  %-9s  %-9s  %-4s  %s" % ["seed", "ended", "downs", "turns", "deepest", "lowest HP", "leader Lv", "team", "secs"])
	var rows := 0
	var cleared_n := 0
	var downs_sum := 0
	var turns_sum := 0
	for sd in SEEDS:
		var t0 := Time.get_ticks_msec()
		seed(sd)   # the floors after B1F take their seed from randi(), and the fights roll on the same generator
		TeamState.start([[0, 0], [1, 0]])
		var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
		TeamState.give_to(dg)
		dg.dungeon = "mouth"
		dg.floor_seed = sd
		dg.poll_input = false
		root.add_child(dg)
		for k in 4:
			await process_frame
		var deepest := 1
		var lowest := 1.0
		var ended := "out of turns"
		var actions := 0
		var idle := 0
		while dg.turn < MAX_TURNS and actions < MAX_TURNS * 3:
			await _settle(dg)
			deepest = maxi(deepest, int(dg.floor_n))
			if dg.cleared > 0:
				ended = "cleared"
				break
			if dg.faints >= MAX_DOWNS:
				ended = "down %d times" % dg.faints
				break
			var lead: Dictionary = dg.ents[0]
			if lead["hp"] > 0:
				lowest = minf(lowest, float(lead["hp"]) / float(lead["max_hp"]))
			var before := int(dg.turn)
			_act(dg, idle >= 2)
			actions += 1
			await process_frame
			await _settle(dg)
			idle = idle + 1 if int(dg.turn) == before else 0
		var lv: int = dg.level_of(int(dg.ents[0]["line"]))
		var team_n: int = dg.ents.filter(func(e: Dictionary) -> bool: return e["team"] == 0).size()
		print("  %-4d  %-14s  %-5d  %-5d  %-7s  %-9s  %-9d  %-4d  %.0f" % [sd, ended, dg.faints, dg.turn, "B%dF" % deepest, "%d%%" % roundi(lowest * 100.0), lv, team_n, (Time.get_ticks_msec() - t0) / 1000.0])
		rows += 1
		cleared_n += 1 if ended == "cleared" else 0
		downs_sum += int(dg.faints)
		turns_sum += int(dg.turn)
		dg.queue_free()
		for k in 3:
			await process_frame
	Engine.time_scale = 1.0
	print("Seeds run %d: cleared %d, went down %d times in all, %.0f turns a seed on average" % [rows, cleared_n, downs_sum, turns_sum / maxf(1.0, rows)])
	print("Every seed gave a row: %d of %d -> %s" % [rows, SEEDS.size(), "ok" if rows == SEEDS.size() else "FAIL"])
	quit(0 if rows == SEEDS.size() else 1)
