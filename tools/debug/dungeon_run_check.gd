extends SceneTree
## The run loop (Claude, 2026-10-09, Preston: "Upgrade"): items lie on the floor and go in the
## bag when stepped on; a Reedberry heals; a River Stone hits down a line and is refused with
## nobody there; the lantern drains with turns, sets how far the leader sees, and relights on a
## knockout; a trap springs and shows itself; a Monster House fills its room; a Rally Seed gets
## the leader back up; fainting loses the bag; the autopilot still clears a floor.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_run_check.gd
## Stills to docs/design/dungeon-run-loop-2026-10-09/.

const OUT := "res://docs/design/dungeon-run-loop-2026-10-09/"

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.real_time_battles = false   # this check tests the turn-based fight rules (2026-10-09: fights are real-time by default)
	root.add_child(dg)
	await _frames(4)
	var lead: Dictionary = dg.ents[0]
	var kinds := []
	for it in dg.floor_items:
		kinds.append(dg.ITEMS[it["kind"]]["name"])
	var all_floor := true
	for it in dg.floor_items:
		all_floor = all_floor and dg._floor_at(it["pos"])
	for tr in dg.traps:
		all_floor = all_floor and dg._floor_at(tr["pos"]) and not tr["seen"]
	print("Stock: items %s; %d hidden traps; Monster House %s; all on open floor: %s; the bag starts with %s" % [str(kinds), dg.traps.size(), "yes" if dg.monster_room.size != Vector2i.ZERO else "no", str(all_floor), str(dg.bag)])
	_save("start")
	# 1. Pick up: put an item next to the leader and step on it.
	var d := _free_dir(dg, lead["pos"])
	dg.floor_items.append({"pos": lead["pos"] + d, "kind": "river_stone"})
	await dg.act_move(d)
	print("Pick up: stepping on a River Stone put it in the bag: %s" % str(dg.bag.get("river_stone", 0) == 1))
	# 2. A Reedberry heals.
	lead["hp"] = lead["max_hp"] - 20
	var hp: int = lead["hp"]
	var t0: int = dg.turn
	await dg.act_use_item("reedberry")
	print("Reedberry: %d -> %d, a turn spent: %s, left in the bag: %d" % [hp, lead["hp"], str(dg.turn == t0 + 1), dg.bag.get("reedberry", 0)])
	# 3. The stone: refused with nobody in a line, then thrown at a wild creature.
	var wild := -1
	for k in dg.ents.size():
		if dg.ents[k]["team"] == 1:
			wild = k
			break
	var foe: Dictionary = dg.ents[wild]
	var keep: Vector2i = foe["pos"]
	for e in dg.ents:
		if e["team"] == 1:
			e["pos"] = Vector2i(-40, -40)
	t0 = dg.turn
	await dg.act_use_item("river_stone")
	var refused: bool = dg.turn == t0 and dg.bag.get("river_stone", 0) == 1
	var line_d := Vector2i.ZERO
	for dd in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if dg._floor_at(lead["pos"] + dd) and dg._floor_at(lead["pos"] + dd * 2) and dg._occupant(lead["pos"] + dd) < 0 and dg._occupant(lead["pos"] + dd * 2) < 0:
			line_d = dd
			break
	foe["pos"] = lead["pos"] + line_d * 2
	foe["awake"] = true
	dg._place(foe)
	hp = foe["hp"]
	await dg.act_use_item("river_stone")
	print("River Stone: with nobody in a line %s; thrown at %s 2 tiles off it took %d" % ["refused for free" if refused else "used (WRONG)", foe["name"], hp - foe["hp"]])
	for e in dg.ents:
		if e["team"] == 1 and e != foe:
			e["pos"] = keep + Vector2i(30, 30)
	# 4. The lantern: drains with turns, sets the reach, relights on a knockout.
	dg.light = 100.0
	var r_full: int = dg.light_radius()
	for k in 30:
		await dg.act_rest()
	var after_rest: float = dg.light
	dg.light = 10.0
	dg._reveal()
	var r_low: int = dg.light_radius()
	foe["hp"] = 1
	var lit_before: float = dg.light
	await dg.act_attack(0)
	if foe["hp"] > 0:
		foe["hp"] = 0
		dg._hit(0, wild, lead["moves"][0])
	print("Lantern: 30 rests took it from 100 to %d; the reach is %d tiles at full light and %d at 10; downing %s relit it %d -> %d" % [int(after_rest), r_full, r_low, foe["name"], int(lit_before), int(dg.light)])
	_save("dark")
	# 5. A trap springs and shows itself.
	dg.light = 100.0
	var td := _free_dir(dg, lead["pos"])
	dg.traps.append({"pos": lead["pos"] + td, "kind": "snare", "seen": false})
	await dg.act_move(td)
	var snared: int = lead.get("snared", 0)
	var spot: Vector2i = lead["pos"]
	var free2 := _free_dir(dg, lead["pos"])
	await dg.act_move(free2)
	print("Snare: sprung and shown: %s; it holds for %d turns after the one it springs on; a step while held kept the leader in place: %s" % [str(dg.traps[-1]["seen"]), snared - 1, str(lead["pos"] == spot)])
	lead["snared"] = 0
	# 6. A Monster House fills its room.
	var rooms: Array = dg.data["rooms"]
	var room: Rect2i = rooms[0]
	for rm in rooms:
		if not rm.grow(1).has_point(lead["pos"]):
			room = rm
			break
	dg.monster_room = room
	dg.monster_sprung = false
	var before: int = dg.ents.size()
	lead["pos"] = room.get_center()
	dg._place(lead)
	dg._end_turn()
	var fresh := 0
	for k in range(before, dg.ents.size()):
		if dg.ents[k]["team"] == 1 and dg.ents[k]["awake"] and room.has_point(dg.ents[k]["pos"]):
			fresh += 1
	await _frames(2)
	_save("monster_house")
	print("Monster House: entering the room set %d awake wild creatures in it; the leader's sprite is in the room: %s" % [fresh, str(lead["node"].position.distance_to(dg._tile_px(lead["pos"])) < 1.0)])
	# 7. A Rally Seed gets the leader back up; fainting without one loses the bag.
	dg.bag["rally_seed"] = 1
	lead["hp"] = 0
	dg._end_turn()
	var up: int = lead["hp"]
	dg.bag["lamp_oil"] = 2
	lead["hp"] = 0
	dg._end_turn()
	await _frames(3)
	print("Rally Seed: the leader got back up with %d HP; with no seed it fainted (faints %d) and the bag became %s" % [up, dg.faints, str(dg.bag)])
	# 8. The autopilot still clears a floor.
	dg.floor_seed = 99
	dg._build_floor(true)
	await _frames(3)
	dg.autopilot = true
	var frames := 0
	var start_floor: int = dg.floor_n
	while dg.floor_n == start_floor and frames < 30 * 240:
		await process_frame
		frames += 1
	print("Autopilot: %s after %d turns, %d faints, lantern %d, bag %s" % ["reached B%dF" % dg.floor_n if dg.floor_n != start_floor else "stuck (WRONG)", dg.turn, dg.faints, int(dg.light), str(dg.bag)])
	await _frames(10)
	_save("b2f")
	quit()


func _free_dir(dg: Node2D, p: Vector2i) -> Vector2i:
	for dd in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
		if dg.can_step(p, dd) and dg._occupant(p + dd) < 0:
			var trap := false
			for tr in dg.traps:
				if tr["pos"] == p + dd:
					trap = true
			if not trap:
				return dd
	return Vector2i(1, 0)


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
