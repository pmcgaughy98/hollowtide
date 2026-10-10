extends SceneTree
## Teammate IQ and health between floors (Claude, 2026-10-09). Each IQ skill is staged twice, with
## the partner below its threshold and at it, and the difference printed. Then health: a hurt
## leader keeps its health down the stairs; a new run starts fresh.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_iq_check.gd

var dg: Node2D
var spot := Vector2i.ZERO


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _wild(pos: Vector2i, awake: bool, hp: int) -> int:
	var w: Dictionary = dg._make(2, 0, 1, pos)
	w["awake"] = awake
	w["max_hp"] = maxi(hp, 30)
	w["hp"] = hp
	dg.ents.append(w)
	dg._place(w)
	return dg.ents.size() - 1


func _clear_wild() -> void:
	for e in dg.ents:
		if e["team"] == 1:
			e["hp"] = 0
			e["node"].visible = false


func _put(k: int, p: Vector2i) -> void:
	dg.ents[k]["pos"] = p
	dg._place(dg.ents[k])


func _run() -> void:
	dg = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0]]
	root.add_child(dg)
	await _frames(4)
	dg.traps.clear()
	dg.floor_items.clear()
	dg.monster_room = Rect2i()
	for room in dg.data["rooms"]:
		if room.size.x >= 8 and room.size.y >= 5:
			spot = room.position + Vector2i(1, 1)
			break
	_clear_wild()
	var mate: Dictionary = dg.ents[1]
	var line: int = mate["line"]

	# Gaining IQ: three floors' worth switches on the first skill.
	var before: bool = dg.has_iq(mate, "step_aside")
	dg._gain_iq(mate, 3)
	print("IQ: %d; Step Aside before %s, after %s; the log says '%s'" % [dg.iq_of(mate), str(before), str(dg.has_iq(mate, "step_aside")), dg.log_lines[-1]])

	# Step Aside: a wind-up marks the partner's tile.
	_put(0, spot)
	_put(1, spot + Vector2i(0, 1))
	var w := _wild(spot + Vector2i(4, 1), true, 30)
	dg.ents[w]["windup"] = {"m": dg.ents[w]["moves"][-1], "d": Vector2i(-1, 0), "tiles": [mate["pos"]]}
	dg.iq[line] = 0
	var p0: Dictionary = dg._decide(1)
	dg.iq[line] = 3
	var p1: Dictionary = dg._decide(1)
	print("Step Aside: without %s; with %s (the new tile is marked: %s)" % [str(p0), str(p1), str(dg._warned(mate["pos"] + p1.get("d", Vector2i.ZERO))) if p1.get("kind", "") == "move" else "-"])
	_clear_wild()

	# Finisher: a near healthy foe and a farther wounded one.
	var near := _wild(spot + Vector2i(1, 2), true, 30)
	var weak := _wild(spot + Vector2i(3, 2), true, 4)
	dg.iq[line] = 0
	var t0: int = dg._target(1)
	dg.iq[line] = 6
	var t1: int = dg._target(1)
	print("Finisher: without it goes for the one %d away (%d HP); with it, the one with %d HP" % [dg._cheb(mate["pos"], dg.ents[t0]["pos"]), dg.ents[t0]["hp"], dg.ents[t1]["hp"]])
	_clear_wild()

	# Quiet Steps: a sleeper the partner can see and the leader cannot.
	_put(0, spot)
	_put(1, spot + Vector2i(5, 3))
	var far := Vector2i(-99, -99)
	for room in dg.data["rooms"]:
		if not room.has_point(spot) and room.size.x >= 3:
			far = room.get_center()
			break
	_put(0, far)
	var sl := _wild(mate["pos"] + Vector2i(2, 0), false, 30)
	dg.iq[line] = 0
	dg._end_turn()
	var woke0: bool = dg.ents[sl]["awake"]
	dg.ents[sl]["awake"] = false
	dg.iq[line] = 10
	dg._end_turn()
	print("Quiet Steps: the sleeper woke without it %s, with it %s" % [str(woke0), str(dg.ents[sl]["awake"])])
	_clear_wild()

	# Ambusher: a sleeper right beside the partner.
	_put(0, spot)
	_put(1, spot + Vector2i(0, 2))
	var amb := _wild(mate["pos"] + Vector2i(1, 0), false, 30)
	dg.iq[line] = 10
	var a0: int = dg._target(1)
	dg.iq[line] = 15
	var a1: int = dg._target(1)
	var plan: Dictionary = dg._decide(1)
	print("Ambusher: target without %s, with %s; plan %s" % [str(a0), "the sleeper" if a1 == amb else str(a1), plan.get("kind", "")])
	_clear_wild()

	# Berry Sense and Fall Back: the partner at 20% beside a foe.
	_put(0, spot)
	_put(1, spot + Vector2i(0, 3))
	var foe := _wild(mate["pos"] + Vector2i(1, 0), true, 30)
	mate["hp"] = int(mate["max_hp"] * 0.2)
	dg.bag["reedberry"] = 1
	dg.iq[line] = 15
	var b0: Dictionary = dg._decide(1)
	dg.iq[line] = 20
	var b1: Dictionary = dg._decide(1)
	var hp_before: int = mate["hp"]
	dg.ents[foe]["snared"] = 9
	await dg.act_rest()
	print("Berry Sense: plan without %s, with %s; the rest turn healed it %d -> %d, berries left %d" % [b0.get("kind", ""), b1.get("kind", ""), hp_before, mate["hp"], dg.bag.get("reedberry", 0)])
	mate["hp"] = int(mate["max_hp"] * 0.2)
	dg.bag.erase("reedberry")
	dg.iq[line] = 20
	var f0: Dictionary = dg._decide(1)
	dg.iq[line] = 25
	var f1: Dictionary = dg._decide(1)
	print("Fall Back (no berry): plan without %s, with %s" % [f0.get("kind", ""), str(f1)])
	_clear_wild()

	# Health between floors.
	var lead: Dictionary = dg.ents[0]
	lead["hp"] = 10
	mate["hp"] = mate["max_hp"]
	_put(0, dg.data["stairs"])
	await dg.act_stairs()
	await _frames(3)
	print("Down the stairs: leader %d/%d (was 10), partner IQ kept %d" % [dg.ents[0]["hp"], dg.ents[0]["max_hp"], dg.iq_of(dg.ents[1])])
	quit()
