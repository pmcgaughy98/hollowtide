extends SceneTree
## Teammate IQ and health between floors (Claude, 2026-10-09). Each IQ skill is staged twice, with
## the partner below its threshold and at it, and the difference printed. Then health: a hurt
## leader keeps its health down the stairs; a new run starts fresh.
## Each skill is judged one point below its threshold and at it, the thresholds read from dg.IQ_SKILLS
## (Grok's numbers), and the stairs keep the leader's health and add IQ_PER_FLOOR (Claude, 2026-10-24, H06).
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_iq_check.gd

var dg: Node2D
var spot := Vector2i.ZERO
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


## The IQ a skill switches on at (dg.IQ_SKILLS, Grok's thresholds).
func _at(id: String) -> int:
	for sk in dg.IQ_SKILLS:
		if sk["id"] == id:
			return int(sk["at"])
	push_error("no IQ skill '%s'" % id)
	return 999


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
	dg._gain_iq(mate, _at("step_aside"))
	var told: String = dg.log_lines[-1] if not dg.log_lines.is_empty() else ""
	_ok("IQ: %d; Step Aside before %s, after %s; the log says '%s'" % [dg.iq_of(mate), str(before), str(dg.has_iq(mate, "step_aside")), told],
		not before and dg.has_iq(mate, "step_aside") and "Step Aside" in told)

	# Step Aside: a wind-up marks the partner's tile.
	_put(0, spot)
	_put(1, spot + Vector2i(0, 1))
	var w := _wild(spot + Vector2i(4, 1), true, 30)
	dg.ents[w]["windup"] = {"m": dg.ents[w]["moves"][-1], "d": Vector2i(-1, 0), "tiles": [mate["pos"]]}
	dg.iq[line] = _at("step_aside") - 1
	var p0: Dictionary = dg._decide(1)
	dg.iq[line] = _at("step_aside")
	var p1: Dictionary = dg._decide(1)
	var left0: bool = p0.get("kind", "") == "move" and not dg._warned(mate["pos"] + p0.get("d", Vector2i.ZERO))
	var left1: bool = p1.get("kind", "") == "move" and not dg._warned(mate["pos"] + p1.get("d", Vector2i.ZERO))
	_ok("Step Aside: without %s; with %s (steps off the marked tile: without %s, with %s)" % [str(p0), str(p1), left0, left1], not left0 and left1)
	_clear_wild()

	# Finisher: a near healthy foe and a farther wounded one.
	var near := _wild(spot + Vector2i(1, 2), true, 30)
	var weak := _wild(spot + Vector2i(3, 2), true, 4)
	dg.iq[line] = _at("finisher") - 1
	var t0: int = dg._target(1)
	dg.iq[line] = _at("finisher")
	var t1: int = dg._target(1)
	_ok("Finisher: without it goes for the one %d away (%d HP); with it, the one with %d HP" % [dg._cheb(mate["pos"], dg.ents[t0]["pos"]) if t0 >= 0 else -1, dg.ents[t0]["hp"] if t0 >= 0 else -1, dg.ents[t1]["hp"] if t1 >= 0 else -1],
		t0 == near and t1 == weak)
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
	dg.iq[line] = _at("quiet") - 1
	dg._end_turn()
	var woke0: bool = dg.ents[sl]["awake"]
	dg.ents[sl]["awake"] = false
	dg.iq[line] = _at("quiet")
	dg._end_turn()
	_ok("Quiet Steps: the sleeper woke without it %s, with it %s" % [str(woke0), str(dg.ents[sl]["awake"])], woke0 and not dg.ents[sl]["awake"])
	_clear_wild()

	# Ambusher: a sleeper right beside the partner.
	_put(0, spot)
	_put(1, spot + Vector2i(0, 2))
	var amb := _wild(mate["pos"] + Vector2i(1, 0), false, 30)
	dg.iq[line] = _at("ambusher") - 1
	var a0: int = dg._target(1)
	dg.iq[line] = _at("ambusher")
	var a1: int = dg._target(1)
	var plan: Dictionary = dg._decide(1)
	_ok("Ambusher: target without %s, with %s; plan %s" % ["the sleeper" if a0 == amb else str(a0), "the sleeper" if a1 == amb else str(a1), plan.get("kind", "")],
		a0 != amb and a1 == amb and plan.get("kind", "") == "attack")
	_clear_wild()

	# Berry Sense and Fall Back: the partner at 20% beside a foe.
	_put(0, spot)
	_put(1, spot + Vector2i(0, 3))
	var foe := _wild(mate["pos"] + Vector2i(1, 0), true, 30)
	mate["hp"] = int(mate["max_hp"] * 0.2)
	dg.bag["reedberry"] = 1
	dg.iq[line] = _at("berry") - 1
	var b0: Dictionary = dg._decide(1)
	dg.iq[line] = _at("berry")
	var b1: Dictionary = dg._decide(1)
	var hp_before: int = mate["hp"]
	dg.ents[foe]["snared"] = 9
	await dg.act_rest()
	_ok("Berry Sense: plan without %s, with %s; the rest turn healed it %d -> %d, berries left %d" % [b0.get("kind", ""), b1.get("kind", ""), hp_before, mate["hp"], dg.bag.get("reedberry", 0)],
		b0.get("kind", "") != "eat" and b1.get("kind", "") == "eat" and mate["hp"] > hp_before and int(dg.bag.get("reedberry", 0)) == 0)
	mate["hp"] = int(mate["max_hp"] * 0.2)
	dg.bag.erase("reedberry")
	dg.iq[line] = _at("fall_back") - 1
	var f0: Dictionary = dg._decide(1)
	dg.iq[line] = _at("fall_back")
	var f1: Dictionary = dg._decide(1)
	var closer: bool = f1.get("kind", "") == "move" and dg._cheb(mate["pos"] + f1.get("d", Vector2i.ZERO), dg.ents[0]["pos"]) < dg._cheb(mate["pos"], dg.ents[0]["pos"])
	_ok("Fall Back (no berry): plan without %s, with %s (stops fighting and steps toward the leader: %s)" % [f0.get("kind", ""), str(f1), closer],
		f0.get("kind", "") == "attack" and closer)
	_clear_wild()

	# Health between floors.
	var lead: Dictionary = dg.ents[0]
	lead["hp"] = 10
	mate["hp"] = mate["max_hp"]
	var iq0: int = dg.iq_of(mate)
	_put(0, dg.data["stairs"])
	await dg.act_stairs()
	await _frames(3)
	_ok("Down the stairs: leader %d/%d (was 10), partner IQ %d (was %d, plus %d a floor)" % [dg.ents[0]["hp"], dg.ents[0]["max_hp"], dg.iq_of(dg.ents[1]), iq0, dg.IQ_PER_FLOOR],
		dg.ents[0]["hp"] == 10 and dg.iq_of(dg.ents[1]) == iq0 + dg.IQ_PER_FLOOR and iq0 == _at("fall_back"))
	quit(1 if fails else 0)
