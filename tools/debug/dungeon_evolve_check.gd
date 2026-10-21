extends SceneTree
## Evolution by conditions (Claude, 2026-10-09; Preston chose option A). The growth counters fill
## from real play; a creature short of one condition does not evolve; one that meets all three
## evolves on the next floor into its line's next form, with that form's kit. The new floor
## heals it to the new form's full HP. A faint does not undo it; a final never evolves. Then autopilot runs
## show how fast it comes naturally.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_evolve_check.gd
## Stills to docs/design/dungeon-evolution-2026-10-09/.

const OUT := "res://docs/design/dungeon-evolution-2026-10-09/"


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0]]
	dg.story = {"stone": "installed"}   # the shrine is awake, so the run points the way to it (stone_check.gd covers before)
	root.add_child(dg)
	await _frames(4)
	dg.traps.clear()
	dg.monster_room = Rect2i()
	var lead: Dictionary = dg.ents[0]
	var mate: Dictionary = dg.ents[1]

	# 1. The counters fill from play: a knockout, a flank hit, damage taken.
	var g0: Dictionary = dg.growth["0:0"].duplicate()
	var w: Dictionary = dg._make(2, 0, 1, Vector2i.ZERO)
	var d := Vector2i.ZERO
	for dd in dg.DIRS:
		if dg.can_step(lead["pos"], dd) and dg._occupant(lead["pos"] + dd) < 0 and dg._occupant(lead["pos"] + dd * 2) < 0 and dg._floor_at(lead["pos"] + dd * 2):
			d = dd
			break
	w["pos"] = lead["pos"] + d
	w["awake"] = false
	w["hp"] = 1
	dg.ents.append(w)
	dg._place(w)
	await dg.use_move(0, lead["moves"][0], d)   # a sleeping foe: AMBUSH, and it goes down
	var g1: Dictionary = dg.growth["0:0"]
	print("Counters: Kithflare's knockouts %d -> %d, flank hits %d -> %d, ambushes %d -> %d" % [g0["kos"], g1["kos"], g0["flank"], g1["flank"], g0["ambush"], g1["ambush"]])
	var took0: int = dg.growth["1:0"]["took"]
	dg._wound(0, 1, 5, Color.WHITE)
	print("Counters: Tallowroot took 5, its 'took' went %d -> %d" % [took0, dg.growth["1:0"]["took"]])

	# 2. Short of one condition: no evolution. Kithflare has its knockouts and flank hits, one floor of two.
	var r: Dictionary = dg.EVO[0]
	dg.growth["0:0"] = {"kos": r["kos"][0], "floors": 0, "flank": r["need"][0], "ambush": 0, "took": 0, "slam": 0}
	dg.levels[0] = {"lv": dg.EVO_LEVEL[0], "exp": 0}   # the level is met; this part checks the conditions
	print("Progress short of one floor: %.2f, ready %s" % [dg.evo_progress(0, 0), str(dg.evo_ready(0, 0))])
	lead["pos"] = dg.data["stairs"]
	dg._place(lead)
	await dg.act_stairs()
	await _frames(3)
	print("After one floor: %s on B%dF, party %s, evolutions %d" % [dg.ents[0]["name"], dg.floor_n, str(dg.party), dg.evolved_log.size()])

	# 3. The next floor meets the last condition: it becomes ready, and stays itself in the Hollow
	# (evolving happens at the Growth Shrine in Highbank since 2026-10-10; tools/debug/evolution_check.gd).
	lead = dg.ents[0]
	lead["pos"] = dg.data["stairs"]
	dg._place(lead)
	await dg.act_stairs()
	await _frames(20)
	var told: bool = dg.log_lines.any(func(l: String) -> bool: return l.contains("Growth Shrine"))
	var still_kith: bool = dg.ents[0]["form"] == "kithflare" and dg.party[0] == [0, 0]
	print("Ready, not evolved: ready %s, still Kithflare %s, told to visit the Growth Shrine %s -> %s" % [str(dg.evo_ready(0, 0)), str(still_kith), str(told), "ok" if dg.evo_ready(0, 0) and still_kith and told else "WRONG"])
	if DisplayServer.get_name() != "headless":
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + "ready.png"))
	print("Tallowroot not ready: %s (progress %.2f)" % [str(not dg.evo_ready(1, 0)), dg.evo_progress(1, 0)])

	# 5. A final never evolves.
	dg.growth["0:2"] = {"kos": 99, "floors": 99, "flank": 99, "ambush": 99, "took": 999, "slam": 99}
	print("A final: progress %.2f, ready %s" % [dg.evo_progress(0, 2), str(dg.evo_ready(0, 2))])
	dg.queue_free()
	await process_frame

	# 6. Natural pace: autopilot runs from fresh, two runs each, counting what grows.
	for sd in [99, 7]:
		var d2: Node2D = load("res://scenes/dungeon.tscn").instantiate()
		d2.floor_seed = sd
		d2.poll_input = false
		root.add_child(d2)
		await _frames(4)
		d2.autopilot = true
		var frames := 0
		while d2.cleared + d2.faints < 2 and frames < 30 * 900:
			await process_frame
			frames += 1
		var rows: Array = []
		for k in d2.party.size():
			var key := "%d:%d" % [d2.party[k][0], d2.party[k][1]]
			var g: Dictionary = d2.growth.get(key, {})
			rows.append("%s %s kos %d floors %d way %d (%.0f%%)" % [d2.form_of(d2.party[k][0], d2.party[k][1]), key, g.get("kos", 0), g.get("floors", 0), g.get(d2.EVO[d2.party[k][0]]["way"], 0) if d2.EVO.has(d2.party[k][0]) else 0, 100.0 * d2.evo_progress(d2.party[k][0], d2.party[k][1])])
		print("Autopilot seed %d, %d runs (%d cleared, %d fainted), %d turns: evolutions %s; %s" % [sd, d2.cleared + d2.faints, d2.cleared, d2.faints, d2.turn, str(d2.evolved_log), "; ".join(rows)])
		d2.queue_free()
		await process_frame
	quit()
