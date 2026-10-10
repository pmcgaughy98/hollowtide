extends SceneTree
## Learnsets (Claude, 2026-10-10, Grok's rules in docs/creatures/learnset-draft-2026-10-10.md): what a
## creature knows by level, a level-up move learned or asked about, a refused move, the moves an
## evolved body keeps and loses, wild creatures by floor, and autopilot never stuck on a question.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_learn_check.gd


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _names(dg: Node, moves: Array) -> String:
	return str(moves.map(func(m: String) -> String: return dg.Arena.MOVES[m]["name"]))


func _check(label: String, ok: bool, detail: String) -> int:
	print("%s: %s -> %s" % [label, detail, "ok" if ok else "WRONG"])
	return 0 if ok else 1


func _run() -> void:
	var bad := 0
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0]]
	root.add_child(dg)
	await _frames(4)
	var kith: Dictionary = dg.ents[0]
	var tall: Dictionary = dg.ents[1]
	bad += _check("Lv 1 team", kith["moves"] == ["claw", "ember_feint"] and tall["moves"] == ["seed", "root_snare"],
		"Kithflare %s, Tallowroot %s" % [_names(dg, kith["moves"]), _names(dg, tall["moves"])])

	# What a creature knows when nobody chose: wild ones by floor, evolved forms, the body rule.
	var spark5: Array = dg.moves_for(0, 1, 5)
	var vit12: Array = dg.moves_for(4, 2, 12)
	var kith3: Array = dg.moves_for(0, 0, 3)
	bad += _check("By level", kith3 == ["claw", "ember_feint", "fireball"] and spark5 == ["pounce", "claw", "ember_feint", "fireball"] and not "ember_pellet" in vit12 and vit12[0] == "plate_lunge",
		"Kithflare Lv 3 %s; Sparkwick Lv 5 %s; Vitrecrag Lv 12 %s" % [_names(dg, kith3), _names(dg, spark5), _names(dg, vit12)])

	# Lv 1 to 3: Ember Shot arrives on its own (room in the set) and is stored for the next floor.
	dg._gain_exp(dg.exp_to_next(1) + dg.exp_to_next(2))
	bad += _check("Level 3", dg.level_of(0) == 3 and kith["moves"] == ["claw", "ember_feint", "fireball"] and dg.taught.get("0:0", []) == kith["moves"],
		"Lv %d, moves %s, stored %s" % [dg.level_of(0), _names(dg, kith["moves"]), str(dg.taught.get("0:0", []))])

	# Evolution (at the Growth Shrine since 2026-10-10, scripts/town/evolution.gd): Kithflare meets
	# everything at Lv 5, evolves on the team record, and the next floor brings Sparkwick.
	dg._gain_exp(dg.exp_to_next(3) + dg.exp_to_next(4))
	var r: Dictionary = dg.EVO[0]
	dg.growth["0:0"] = {"kos": r["kos"][0], "floors": r["floors"][0], "flank": r["need"][0], "ambush": 0, "took": 0, "slam": 0}
	var Evolution = load("res://scripts/town/evolution.gd")
	var rec := {"party": dg.party.duplicate(true), "taught": dg.taught, "levels": dg.levels, "growth": dg.growth}
	var evo: Dictionary = Evolution.evolve(rec, 0)
	dg.party = rec["party"]
	kith["pos"] = dg.data["stairs"]
	dg._place(kith)
	await dg.act_stairs()
	await _frames(20)
	var sp: Dictionary = dg.ents[0]
	bad += _check("Evolved", sp["form"] == "sparkwick" and sp["moves"] == ["pounce", "claw", "ember_feint", "fireball"] and dg.teach_kind == "",
		"%s knows %s (Pounce on evolving, the three earlier moves kept)" % [sp["name"], _names(dg, sp["moves"])])

	# Lv 6 with four moves: the panel asks; forget Rake for Wick Bolt.
	dg._gain_exp(dg.exp_to_next(5))
	var rows: Array = dg.teach_rows().map(func(row: Dictionary) -> String: return row["text"])
	var asked: bool = dg.teach_kind == "learn:wick_bolt" and rows.has("DON'T LEARN WICK BOLT")
	var res: String = dg.act_teach(dg.teach_learner, 1)
	bad += _check("Lv 6, full", asked and res == "learned" and sp["moves"] == ["pounce", "wick_bolt", "ember_feint", "fireball"],
		"asked %s with %s; then %s, moves %s" % [str(asked), str(rows), res, _names(dg, sp["moves"])])

	# Lv 8: Lantern Volley offered and let go; nothing changes.
	dg._gain_exp(dg.exp_to_next(6) + dg.exp_to_next(7))
	var asked2: bool = dg.teach_kind == "learn:lantern_volley"
	var res2: String = dg.act_teach(dg.teach_learner, -2)
	bad += _check("Lv 8, refused", asked2 and res2 == "refused" and not "lantern_volley" in sp["moves"] and dg.teach_kind == "",
		"asked %s, %s, moves %s" % [str(asked2), res2, _names(dg, sp["moves"])])

	# The body rule on evolving: a Slagglass becoming Vitrecrag loses Ember Pellet (no seam) and says so.
	var vrec := {"party": [[4, 1]], "taught": {"4:1": ["plate_lunge", "ember_pellet"]}, "levels": {4: {"lv": 12, "exp": 0}}, "growth": {}}
	var vres: Dictionary = Evolution.evolve(vrec, 0)
	var vm: Array = vres["moves"]
	bad += _check("Vitrecrag", not "ember_pellet" in vm and vm[0] == "plate_lunge" and vm.has("molten_cannon") and vm.has("molten_beam") and vres["lost"] == ["ember_pellet"],
		"moves %s, lost %s" % [_names(dg, vm), str(vres["lost"])])

	# Autopilot: a full set is resolved without a question.
	dg.autopilot = true
	sp["moves"].assign(["pounce", "wick_bolt", "ember_feint", "fireball"])
	dg._offer(0, "lantern_volley")
	bad += _check("Autopilot", dg.teach_kind == "" and sp["moves"].has("lantern_volley"),
		"panel open %s, moves %s" % [str(dg.teach_kind != ""), _names(dg, sp["moves"])])
	dg.autopilot = false

	# A wild creature on a deeper floor knows its later moves.
	var w: Dictionary = dg._make(0, 0, 1, sp["pos"])
	bad += _check("Wild on B%dF" % dg.floor_n, w["moves"] == dg.moves_for(0, 0, dg.floor_n), "Kithflare knows %s" % _names(dg, w["moves"]))
	w["node"].queue_free()
	print("RESULT: %s" % ("learnsets work" if bad == 0 else "%d problems" % bad))
	quit()
