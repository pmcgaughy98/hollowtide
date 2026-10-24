extends SceneTree
## Team tactics (Claude, 2026-10-09): T cycles follow me / go after foes / guard me without
## spending a turn; a partner walks round to the far side of a foe the leader is on and lands
## PINCER hits; each order changes how far a partner goes.
## Each part is a verdict line; the leash per order is dg.TACTIC_LEASH (Claude, 2026-10-24, H07).
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_tactics_check.gd
## Stills to docs/design/dungeon-tactics-2026-10-09/.

const OUT := "res://docs/design/dungeon-tactics-2026-10-09/"

var dg: Node2D
var spot := Vector2i.ZERO
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	dg = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[1, 0], [0, 0]]   # Tallowroot leads; Kithflare, a melee partner, is the one that flanks
	root.add_child(dg)
	await _frames(4)
	for room in dg.data["rooms"]:
		if room.size.x >= 8 and room.size.y >= 4:
			spot = room.position + Vector2i(1, 1)
			break
	dg.traps.clear()
	dg.floor_items.clear()
	dg.monster_room = Rect2i()   # a Monster House springing in the test room spoils the staging (Grok's 2026-10-10 spawn tables put one here)
	for e in dg.ents:
		if e["team"] == 1:
			e["hp"] = 0
			e["node"].visible = false
	var lead: Dictionary = dg.ents[0]
	var mate: Dictionary = dg.ents[1]
	lead["max_hp"] = 999   # the leader only stands there; a faint would restart the floor
	lead["hp"] = 999

	# 1. The order switch: three presses come back round, and no turn passes.
	var t0: int = dg.turn
	var seen: Array = [dg.tactic]
	for k in 3:
		dg.act_tactic()
		seen.append(dg.tactic)
	_ok("Orders: %s; turns spent %d" % [str(seen), dg.turn - t0], seen == dg.TACTICS + [dg.TACTICS[0]] and dg.turn == t0)

	# 2. Pincer: the leader holds a tough Rimefin's west side; the melee partner starts two tiles below.
	var rim := _wild(spot + Vector2i(2, 1))
	var w: Dictionary = dg.ents[rim]
	w["max_hp"] = 400
	w["hp"] = 400
	_put(0, spot + Vector2i(1, 1))
	_put(1, spot + Vector2i(1, 3))   # two tiles from the far side (FLANK_REACH)
	var flank: Vector2i = dg.pincer_tile(1, rim)
	var reached := -1
	for k in 8:
		w["snared"] = 99   # held still, so its Lunge never shoves the leader out of the pincer
		await dg.act_rest()
		if OS.get_environment("TACTICS_TRACE") != "":
			print("  turn %d: leader %s partner %s rimefin %s flank %s | %s" % [k + 1, str(lead["pos"] - spot), str(mate["pos"] - spot), str(w["pos"] - spot), str(dg.pincer_tile(1, rim) - spot), " / ".join(dg.log_lines.slice(-3))])
		if mate["pos"] == flank and reached < 0:
			reached = k + 1
	_save("pincer")
	_ok("Pincer: the far side is %s from the Rimefin; the partner got there after %d rests and landed %d PINCER hits in 8 turns" % [str(flank - w["pos"]), reached, dg.pincers], reached > 0 and reached <= 8 and dg.pincers > 0)
	w["hp"] = 0
	w["node"].visible = false

	# 3. Reach: a held-fast Rimefin 6 tiles from the leader, in sight.
	var far := _wild(spot + Vector2i(6, 1))
	var f: Dictionary = dg.ents[far]
	f["snared"] = 99
	f["max_hp"] = 400
	f["hp"] = 400
	for order in ["follow", "go", "guard"]:
		dg.tactic = order
		_put(0, spot + Vector2i(0, 1))
		_put(1, spot + Vector2i(0, 2))
		var closest := 99
		var off := 0
		var hp0: int = f["hp"]
		for k in 7:
			f["snared"] = 99
			await dg.act_rest()
			closest = mini(closest, dg._cheb(mate["pos"], f["pos"]))
			off = maxi(off, dg._cheb(mate["pos"], lead["pos"]))
		var took: int = hp0 - f["hp"]
		print("%s: the partner came within %d of the far Rimefin, strayed up to %d from the leader, took %d off it" % [dg.TACTIC_NAMES[order], closest, off, took])
		_ok("%s: the partner stays within %d of the leader (strayed up to %d)" % [dg.TACTIC_NAMES[order], dg.TACTIC_LEASH[order], off], off <= dg.TACTIC_LEASH[order])
		if order == "go":
			_ok("%s: the partner goes after the far Rimefin (took %d off it)" % [dg.TACTIC_NAMES[order], took], took > 0)
		else:
			_ok("%s: the partner leaves the far Rimefin alone (took %d off it)" % [dg.TACTIC_NAMES[order], took], took == 0)
	# Guard still fights what comes to the leader.
	_put(far, spot + Vector2i(1, 1))
	var hp: int = f["hp"]
	for k in 3:
		f["snared"] = 99
		await dg.act_rest()
	_ok("%s, a foe beside the leader: the partner took %d off it in 3 turns" % [dg.TACTIC_NAMES[dg.tactic], hp - f["hp"]], hp - f["hp"] > 0)
	quit(1 if fails else 0)


func _wild(pos: Vector2i) -> int:
	var w: Dictionary = dg._make(2, 0, 1, pos)
	w["awake"] = true
	dg.ents.append(w)
	dg._place(w)
	return dg.ents.size() - 1


func _put(k: int, pos: Vector2i) -> void:
	dg.ents[k]["pos"] = pos
	dg._place(dg.ents[k])


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	await _frames(2)
	if DisplayServer.get_name() == "headless":   # no viewport texture headless; the still needs a window (Claude, 2026-10-24)
		return
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))
