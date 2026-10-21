extends SceneTree
## The chain after fights and recruits (Preston, 2026-10-09: "after the first battle they stay there,
## and when you defeat and recruit a new teammate they go where the other teammates stayed"). Cause
## found here: a recruit joining in a hallway between a partner and the leader blocked it, and
## partners could not pass a teammate. Fixed by letting partners swap past teammates.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_chain_check.gd The leader plays like a
## person: walks to the stairs, attacks only a foe next to it, says yes to recruits. Every turn,
## a teammate more than 5 tiles from the leader for 4 turns running is reported with what it is
## trying to do.

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for sd in [99, 7, 31337, 4242, 5, 11]:
		seed(sd)   # the floors after B1F take their seed from randi(): without this the stall moved from seed to seed between runs
		var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
		dg.floor_seed = sd
		dg.poll_input = false
		root.add_child(dg)
		for k in 4:
			await process_frame
		dg.ents[0]["max_hp"] = 999
		dg.ents[0]["hp"] = 999
		dg.recruit_override = 1.0
		var far := {}
		var told := 0
		var longest := 0
		var turns := 0
		while dg.floor_n <= 3 and turns < 900:
			turns += 1
			while dg.busy:
				await process_frame
			dg.ents[0]["max_hp"] = 999   # every turn: a level-up sets max_hp back to the real one (hp += new - old), and
			dg.ents[0]["hp"] = 999       # the leader then went down and the run restarted at B1F (2026-10-21)
			if dg.asking >= 0:
				dg.act_recruit(true)
				continue
			var lead: Dictionary = dg.ents[0]
			var foe_d := Vector2i.ZERO
			for d in dg.DIRS:
				var o: int = dg._occupant(lead["pos"] + d)
				if o >= 0 and dg._foes(0, o) and dg.ents[o]["awake"] and dg.can_step(lead["pos"], d):
					foe_d = d
			var near_foe := false
			var near_at := Vector2i.ZERO
			for o2 in dg.ents:
				if o2["team"] == 1 and o2["hp"] > 0 and o2["awake"] and dg._cheb(o2["pos"], lead["pos"]) <= 3 and dg._sees(lead["pos"], o2["pos"]):
					near_foe = true
					near_at = o2["pos"]
			if foe_d != Vector2i.ZERO:
				await dg.act_move(foe_d)
			elif near_foe and dg._step_toward(0, near_at, true, true) != Vector2i.ZERO:
				await dg.act_move(dg._step_toward(0, near_at, true, true))   # walk up to it: a wild that shoots from range never comes next to the leader, which rested beside it for good
			elif near_foe:
				await dg.act_rest()
			elif lead["pos"] == dg.data["stairs"]:
				await dg.act_stairs()
				dg.ents[0]["max_hp"] = 999
				dg.ents[0]["hp"] = 999
				far.clear()
				continue
			else:
				var d2: Vector2i = dg._step_toward(0, dg.data["stairs"], true, true)   # round the traps it has seen, as the autopilot does: a Warp Eddy on the straight way to the stairs sent it back to the far room forever
				if d2 == Vector2i.ZERO:
					await dg.act_rest()
				else:
					await dg.act_move(d2)
			await process_frame
			for k in dg.ents.size():
				var e: Dictionary = dg.ents[k]
				if k == 0 or e["team"] != 0 or e["hp"] <= 0:
					continue
				if dg._cheb(e["pos"], dg.ents[0]["pos"]) > 5:
					far[k] = far.get(k, 0) + 1
					longest = maxi(longest, far[k])
					if far[k] == 12 and told < 4:   # only a real stall gets a report
						told += 1
						var t: int = dg._target(k)
						var plan: Dictionary = dg._decide(k)
						var ahead := 0
						for a in range(k - 1, -1, -1):
							if dg.ents[a]["team"] == 0 and dg.ents[a]["hp"] > 0:
								ahead = a
								break
						print("seed %d turn %d: %s (ents %d) at %s, leader at %s, %d tiles; ahead is %s at %s; target %s; plan %s; tactic %s; snared %d; stagger %d; awake %s; step to ahead %s" % [sd, dg.turn, e["name"], k, str(e["pos"]), str(dg.ents[0]["pos"]), dg._cheb(e["pos"], dg.ents[0]["pos"]), dg.ents[ahead]["name"], str(dg.ents[ahead]["pos"]), (dg.ents[t]["name"] + str(dg.ents[t]["pos"]) + " awake " + str(dg.ents[t]["awake"])) if t >= 0 else "none", str(plan), dg.tactic, e.get("snared", 0), e.get("stagger", 0), str(e["awake"]), str(dg._step_toward(k, dg.ents[ahead]["pos"]))])
				else:
					far[k] = 0
		print("seed %d: %d turns, floor %d, team %s; the longest a teammate stayed more than 5 tiles behind: %d turns" % [sd, dg.turn, dg.floor_n, str(dg.ents.filter(func(e: Dictionary) -> bool: return e["team"] == 0).map(func(e: Dictionary) -> String: return e["name"])), longest])
		if dg.floor_n <= 3:
			print("seed %d: FAIL, still on B%dF after %d turns of the check" % [sd, dg.floor_n, turns])
		dg.queue_free()
		await process_frame
	quit()
