extends SceneTree
## Position is power (Claude, 2026-10-09): AMBUSH on a sleeping creature, PINCER with a teammate on
## the far side, a charge that shoves, and a SLAM into a wall or a body that hurts, breaks a
## wind-up and costs the next turn. Each case is staged in one room and measured.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_position_check.gd
## Stills to docs/design/dungeon-position-2026-10-09/.

const OUT := "res://docs/design/dungeon-position-2026-10-09/"

var dg: Node2D
var spot := Vector2i.ZERO


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	dg = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.real_time_battles = false
	dg.party = [[0, 0], [1, 0]]
	root.add_child(dg)
	await _frames(4)
	for room in dg.data["rooms"]:
		if room.size.x >= 6 and room.size.y >= 3:
			spot = room.position + Vector2i(1, 1)
			break
	dg.traps.clear()
	dg.floor_items.clear()
	dg.monster_room = Rect2i()   # a Monster House springing in the test room spoils the staging (Grok's 2026-10-10 spawn tables put one here)
	for k in dg.ents.size():
		if dg.ents[k]["team"] == 1:
			dg.ents[k]["hp"] = 0   # every generated wild creature out of the way
			dg.ents[k]["node"].visible = false
	var lead: Dictionary = dg.ents[0]
	var mate: Dictionary = dg.ents[1]
	var basic: String = lead["moves"][0]
	var charge := ""
	for m in lead["moves"]:
		if dg.move_reach(m)["kind"] == "dash":
			charge = m
	var rim: int = _wild(spot + Vector2i(1, 0))
	_put(0, spot)
	_put(1, spot + Vector2i(0, 2))
	var w: Dictionary = dg.ents[rim]

	# 1. Ambush, then the same hit on it awake.
	w["awake"] = false
	var tags: Array = dg.position_tags(0, rim)
	var a := await _swing(rim, basic, Vector2i(1, 0))
	w["awake"] = true
	var plain := 0
	for k in 6:
		plain += await _swing(rim, basic, Vector2i(1, 0))
	print("Ambush: tags %s; the sleeping hit took %d, awake hits took %.1f on average (x%.2f)" % [str(tags), a, plain / 6.0, a / maxf(1.0, plain / 6.0)])

	# 2. Pincer: the partner stands right behind the Rimefin.
	_put(1, spot + Vector2i(2, 0))
	tags = dg.position_tags(0, rim)
	var p := 0
	for k in 6:
		p += await _swing(rim, basic, Vector2i(1, 0))
	print("Pincer: tags %s; hits took %.1f on average (x%.2f)" % [str(tags), p / 6.0, p / maxf(1.0, plain)])
	_put(1, spot + Vector2i(0, 2))

	# 3. A charge into open floor shoves it one tile.
	print("Charge: %s" % (dg.Arena.MOVES[charge]["name"] if charge != "" else "none (WRONG)"))
	lead["cds"][charge] = 0
	w["hp"] = w["max_hp"]
	await dg.use_move(0, charge, Vector2i(1, 0))
	print("Shove: the Rimefin went from +1 to %s, staggered %d (expect +2, 0)" % [str(w["pos"] - spot), w.get("stagger", 0)])

	# 4. A charge with a wall behind it: SLAM, the wind-up is broken, and it loses its next turn.
	var x := spot.x
	while dg._floor_at(Vector2i(x + 1, spot.y)):
		x += 1
	var edge := Vector2i(x, spot.y)
	_put(rim, edge)
	_put(0, edge - Vector2i(1, 0))
	_put(1, edge - Vector2i(1, 2) if dg._floor_at(edge - Vector2i(1, 2)) else edge - Vector2i(3, 0))
	w["hp"] = w["max_hp"]
	w["facing"] = "w"
	w["windup"] = {"m": w["moves"][-1], "d": Vector2i(-1, 0), "tiles": dg.move_tiles(rim, w["moves"][-1], Vector2i(-1, 0))}
	lead["cds"][charge] = 0
	var before: int = w["hp"]
	var slam_text := false
	dg.use_move(0, charge, Vector2i(1, 0))
	for k in 30:
		await process_frame
		for pop in dg._pops:
			if pop["text"] == "SLAM!":
				slam_text = true
		if slam_text and k > 6:
			break
	_save("slam_wall")
	await _frames(20)
	print("Slam into the wall: position %s (unchanged: %s), took %d, SLAM shown %s, wind-up broken %s, staggered %d" % [str(w["pos"] - edge), str(w["pos"] == edge), before - w["hp"], str(slam_text), str(not w.has("windup")), w.get("stagger", 0)])
	var lead_hp: int = lead["hp"]
	await dg.act_rest()
	print("Its next turn: skipped %s (leader took %d, it gathered nothing: %s), stagger now %d" % [str(lead["hp"] == lead_hp), lead_hp - lead["hp"], str(not w.has("windup")), w.get("stagger", 0)])

	# 5. A charge into a creature with another behind it: both take the knock.
	var rim2: int = _wild(spot + Vector2i(2, 0))
	var w2: Dictionary = dg.ents[rim2]
	_put(rim, spot + Vector2i(1, 0))
	_put(0, spot)
	_put(1, spot + Vector2i(0, 2))
	w["hp"] = w["max_hp"]
	w["stagger"] = 0
	lead["cds"][charge] = 0
	var h1: int = w["hp"]
	var h2: int = w2["hp"]
	await dg.use_move(0, charge, Vector2i(1, 0))
	print("Slam into a body: the first Rimefin took %d and stayed at %s, the one behind took %d (slam %d)" % [h1 - w["hp"], str(w["pos"] - spot), h2 - w2["hp"], maxi(2, int(round(w2["max_hp"] * dg.SLAM_SHARE)))])

	# 6. A slammed leader loses its turn: the next press only passes it.
	w2["hp"] = 0
	w2["node"].visible = false
	w["hp"] = 0
	w["node"].visible = false
	lead["stagger"] = 1
	var at: Vector2i = lead["pos"]
	var t0: int = dg.turn
	await dg.act_move(Vector2i(0, 1))
	print("Leader reeling: moved %s, turns passed %d, stagger now %d" % [str(lead["pos"] != at), dg.turn - t0, lead.get("stagger", 0)])
	await dg.act_move(Vector2i(0, 1))
	print("Next press: moved %s" % str(lead["pos"] != at))
	quit()


## One hit of move m on creature j from the leader, the health restored after: what it took.
func _swing(j: int, m: String, d: Vector2i) -> int:
	var o: Dictionary = dg.ents[j]
	o["hp"] = o["max_hp"]
	dg.ents[0]["cds"][m] = 0
	await dg.use_move(0, m, d)
	var took: int = o["max_hp"] - o["hp"]
	o["hp"] = o["max_hp"]
	return took


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
	await process_frame
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))
