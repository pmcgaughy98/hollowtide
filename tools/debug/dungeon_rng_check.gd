extends SceneTree
## The dungeon run's own random generator (Claude, 2026-10-27, pass 9 D3, Grok task 9). The damage roll, the recruit
## rolls, the warp room and the next floor_seed draw from dungeon.gd's _run_rng, seeded from floor_seed at each floor,
## so Godot's generator (camera shake, particles) and the frame count no longer move them. Three runs of B1F of
## Rootbank Warren: two at one seed, the second with Godot's generator drawn 400 times between rolls and extra frames
## waited, and one at the next seed. Each takes ten damage rolls of the leader's first move on a wild creature, then
## takes the stairs and reads B2F's seed.
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/dungeon_rng_check.gd

const SEED := 31337
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _run() -> void:
	var a: Dictionary = await _rolls(SEED, false)
	var b: Dictionary = await _rolls(SEED, true)
	var c: Dictionary = await _rolls(SEED + 1, false)
	print("  seed %d: rolls %s, B2F seed %d" % [SEED, str(a["rolls"]), a["next"]])
	print("  seed %d, Godot's generator drawn between: rolls %s, B2F seed %d" % [SEED, str(b["rolls"]), b["next"]])
	print("  seed %d: rolls %s, B2F seed %d" % [SEED + 1, str(c["rolls"]), c["next"]])
	_ok("A floor_seed set before the floor builds is kept (%d, %d)" % [a["seed"], b["seed"]], a["seed"] == SEED and b["seed"] == SEED)
	_ok("The ten rolls vary, so the probe can see a change (%d distinct)" % _distinct(a["rolls"]), _distinct(a["rolls"]) > 1)
	_ok("Same seed, same damage rolls, with Godot's generator drawn 400 times and 7 frames between each", a["rolls"] == b["rolls"])
	_ok("Same seed, same B2F seed (%d, %d)" % [a["next"], b["next"]], a["next"] == b["next"] and a["floor"] == 2 and b["floor"] == 2)
	_ok("The next seed gives other rolls and another B2F", a["rolls"] != c["rolls"] and a["next"] != c["next"])
	print("DUNGEON RNG: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit()


func _distinct(a: Array) -> int:
	var seen := {}
	for v in a:
		seen[v] = true
	return seen.size()


## B1F at `sd`: ten damage rolls, then the stairs. With `burn`, Godot's own generator is drawn between rolls and the
## stairs wait longer, as a longer card or more particles would.
func _rolls(sd: int, burn: bool) -> Dictionary:
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = sd
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0]]
	root.add_child(dg)
	await _frames(20)
	var out := {"seed": dg.floor_seed, "rolls": [], "next": -1, "floor": dg.floor_n}
	var j := -1
	for k in dg.ents.size():
		if dg.ents[k]["team"] == 1:
			j = k
			break
	var m: String = dg.ents[0]["moves"][0]
	for r in 10:
		if burn:
			for k in 400:
				randf()
			await _frames(7)
		out["rolls"].append(dg.damage(0, j, m) if j >= 0 else -1)
	dg.ents[0]["pos"] = dg.data["stairs"]
	dg._place(dg.ents[0])
	if burn:
		for k in 400:
			randi()
	dg.act_stairs()
	for k in 30 * 20:
		await process_frame
		if burn and k % 3 == 0:
			randf()
		if dg.floor_n == 2 and not dg.busy:
			break
	out["next"] = dg.floor_seed
	out["floor"] = dg.floor_n
	dg.queue_free()
	await _frames(3)
	return out
