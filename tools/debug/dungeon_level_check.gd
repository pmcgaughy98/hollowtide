extends SceneTree
## Levels (Claude, 2026-10-09; Preston: "keep the evolve by leveling on top of our evolution rules",
## then "level, then conditions"). A downed foe gives the team EXP; levels add health; a teammate
## with every EVO condition met still waits for its evolve level; the level survives the trip home.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_level_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _run() -> void:
	var bad := 0
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0]]
	root.add_child(dg)
	await _frames(4)
	dg.recruit_override = 0.0
	var lead: Dictionary = dg.ents[0]
	var ok: bool = dg.level_of(0) == 1 and lead["max_hp"] == lead["base_hp"]
	print("Start: Kithflare Lv %d, health %d (base %d) -> %s" % [dg.level_of(0), lead["max_hp"], lead["base_hp"], "ok" if ok else "WRONG"])
	bad += 0 if ok else 1

	# 1. A wild creature downed: both teammates get the EXP.
	var j := -1
	for k in dg.ents.size():
		if dg.ents[k]["team"] == 1 and dg.ents[k]["hp"] > 0 and not dg.ents[k].get("boss", false):
			j = k
			break
	var foe_stage: int = dg.ents[j]["stage"]
	dg._wound(0, j, 999, Color.WHITE)
	await _frames(2)
	var want: int = dg.EXP_PER_KO + dg.EXP_PER_STAGE * foe_stage
	ok = int(dg.levels[0]["exp"]) == want and int(dg.levels[1]["exp"]) == want
	print("A foe downed (stage %d): EXP Kithflare %d, Tallowroot %d, wanted %d each -> %s" % [foe_stage + 1, dg.levels[0]["exp"], dg.levels[1]["exp"], want, "ok" if ok else "WRONG"])
	bad += 0 if ok else 1

	# 2. Enough EXP for three levels at once: health grows with it.
	dg.levels[0] = {"lv": 1, "exp": 0}
	var hp_before: int = lead["max_hp"]
	dg.last_sfx.clear()
	dg._gain_exp(100)
	ok = dg.level_of(0) == 4 and lead["max_hp"] == dg._hp_at_level(lead["base_hp"], 4) and lead["max_hp"] > hp_before and dg.last_sfx.has("room_clear")
	print("100 EXP from Lv 1: Lv %d with %d left, health %d -> %d, sound %s -> %s" % [dg.level_of(0), dg.levels[0]["exp"], hp_before, lead["max_hp"], str(dg.last_sfx.keys()), "ok" if ok else "WRONG"])
	bad += 0 if ok else 1

	# 3. Every condition met at Lv 4: still waits for Lv 5. Then the level comes and it is ready.
	var r: Dictionary = dg.EVO[0]
	dg.growth["0:0"] = {"kos": r["kos"][0], "floors": r["floors"][0], "flank": r["need"][0], "ambush": 0, "took": 0, "slam": 0}
	var waits: bool = not dg.evo_ready(0, 0)
	var short: float = dg.evo_progress(0, 0)
	dg.last_sfx.clear()
	dg._gain_exp(dg.exp_to_next(4) - int(dg.levels[0]["exp"]))
	ok = waits and dg.level_of(0) == dg.EVO_LEVEL[0] and dg.evo_ready(0, 0) and dg.last_sfx.has("evolve_ready")
	print("Conditions met at Lv 4: ready %s (progress %.2f); at Lv %d: ready %s, sound %s -> %s" % [str(not waits), short, dg.level_of(0), str(dg.evo_ready(0, 0)), str(dg.last_sfx.keys()), "ok" if ok else "WRONG"])
	bad += 0 if ok else 1

	# 4. The level goes home with the team and comes back on the next run.
	TeamState.start([[0, 0], [1, 0]])
	TeamState.take_from(dg, "")
	dg.queue_free()
	await _frames(4)
	var d2: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	d2.floor_seed = 4242
	d2.poll_input = false
	TeamState.give_to(d2)
	root.add_child(d2)
	await _frames(4)
	var l2: Dictionary = d2.ents[0]
	ok = d2.level_of(0) == d2.EVO_LEVEL[0] and l2["max_hp"] == d2._hp_at_level(l2["base_hp"], d2.level_of(0))
	print("Next run: Kithflare Lv %d, health %d -> %s" % [d2.level_of(0), l2["max_hp"], "ok" if ok else "WRONG"])
	bad += 0 if ok else 1
	d2.queue_free()
	print("RESULT: %s" % ("levels work" if bad == 0 else "%d problems" % bad))
	quit()
