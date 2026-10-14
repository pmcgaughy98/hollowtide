extends SceneTree
## Ctrl + direction runs (Claude, 2026-10-14, after Explorers of Sky's B + direction, which its manual and
## its own controls screen both list): one press dashes on until something is worth stopping for. On a real
## floor with the wild creatures, items and traps cleared away, a run must:
##   reach the wall of a room, at a quicker pace than a walk; stop beside an item and short of a seen trap;
##   not stop for an item it started beside; stop on a real key press (through Input, as a player presses
##   it) with nothing else fired afterwards; stop for the pause menu, a warp, a learn prompt, a foe coming
##   into sight and a foe in sight closing in; stop where a hall opens into a room; and follow a hall's bend.
## The first version of this check set `running` false itself, so it passed while the key stop was dead
## code (the adversarial pass of 2026-10-14 found it); the key test now goes through Input.
##   Godot --headless --path . --script res://tools/debug/run_stop_check.gd

var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(cond: bool, what: String) -> void:
	print(("ok    " if cond else "FAIL  ") + what)
	if not cond:
		fails += 1


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _until(cond: Callable, max_frames: int) -> void:
	for k in max_frames:
		if cond.call():
			return
		await process_frame


func _floor(seed: int) -> Node2D:
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = seed
	dg.poll_input = false
	dg.party = [[0, 0]]
	root.add_child(dg)
	await _frames(30)
	_clear(dg)
	return dg


func _clear(dg: Node2D) -> void:
	for e in dg.ents:
		if e["team"] == 1:
			e["hp"] = 0
			e["node"].visible = false
	dg.floor_items.clear()
	dg.traps.clear()


func _put(dg: Node2D, p: Vector2i) -> void:
	var lead: Dictionary = dg.ents[0]
	lead["pos"] = p
	dg._place(lead)


func _reach(dg: Node2D, p: Vector2i, d: Vector2i) -> int:
	var n := 0
	var q := p
	while dg.can_step(q, d) and n < 40:
		q += d
		n += 1
	return n


func _in_house(dg: Node2D, p: Vector2i) -> bool:
	var r: Rect2i = dg.monster_room
	return r.size != Vector2i.ZERO and r.grow(1).has_point(p)


func _near_stairs(dg: Node2D, p: Vector2i) -> bool:
	return dg._cheb(dg.data["stairs"], p) <= 1


func _floor_at(dg: Node2D, p: Vector2i) -> bool:
	var w: int = dg.data["w"]
	return p.x >= 0 and p.y >= 0 and p.x < w and p.y < dg.data["h"] and dg.data["tiles"][p.y * w + p.x] == dg.Gen.FLOOR


## A room tile with `need` or more open steps straight ahead, all in the room, clear of stairs and Monster
## House, with open floor beside the start (for an item the run starts next to).
func _room_line(dg: Node2D, need: int) -> Array:
	var w: int = dg.data["w"]
	for y in dg.data["h"]:
		for x in w:
			var p := Vector2i(x, y)
			if not _floor_at(dg, p) or dg._open_ways(p) <= 2 or _near_stairs(dg, p) or _in_house(dg, p):
				continue
			for d in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]:
				var n := _reach(dg, p, d)
				if n < need:
					continue
				var fine := true
				for k in range(1, n + 1):
					var q: Vector2i = p + d * k
					if dg._open_ways(q) <= 2 or _near_stairs(dg, q) or _in_house(dg, q):
						fine = false
						break
				var side := Vector2i(d.y, d.x)
				if fine and _floor_at(dg, p + side):
					return [p, d, n, side]
	return []


## A hall tile running straight at least two tiles into a corner that turns one way, then on for two more.
func _bend_line(dg: Node2D) -> Array:
	var w: int = dg.data["w"]
	for y in dg.data["h"]:
		for x in w:
			var p := Vector2i(x, y)
			if not _floor_at(dg, p) or dg._open_ways(p) != 2 or _near_stairs(dg, p) or _in_house(dg, p):
				continue
			for d in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]:
				var k := _reach(dg, p, d)
				var corner: Vector2i = p + d * k
				if k < 2 or dg._open_ways(corner) != 2:
					continue
				var turn: Vector2i = dg._bend(corner, d)
				if turn == Vector2i.ZERO:
					continue
				var on: Vector2i = corner + turn
				if dg._open_ways(on) == 2 and dg.can_step(on, turn) and not _near_stairs(dg, on) and not _near_stairs(dg, on + turn):
					return [p, d, corner, turn]
	return []


## A hall tile whose straight line runs at least three hall tiles and then opens into a room.
func _hall_line(dg: Node2D) -> Array:
	var w: int = dg.data["w"]
	for y in dg.data["h"]:
		for x in w:
			var p := Vector2i(x, y)
			if not _floor_at(dg, p) or dg._open_ways(p) != 2 or _near_stairs(dg, p) or _in_house(dg, p):
				continue
			for d in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]:
				var q := p
				var k := 0
				while dg.can_step(q, d) and k < 30:
					q += d
					k += 1
					if _near_stairs(dg, q) or _in_house(dg, q):
						break
					if dg._open_ways(q) > 2:
						if k >= 3:
							return [p, d, k]
						break
	return []


func _key(code: int, down: bool) -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = code
	ev.keycode = code
	ev.pressed = down
	Input.parse_input_event(ev)


func _run() -> void:
	var dg := await _floor(4242)
	var line := _room_line(dg, 7)
	_ok(not line.is_empty(), "found a straight room line on B1F (seed 4242)")
	if line.is_empty():
		quit(1)
		return
	var p: Vector2i = line[0]
	var d: Vector2i = line[1]
	var n: int = line[2]
	var side: Vector2i = line[3]
	var lead: Dictionary = dg.ents[0]
	var steps_in := func() -> int: return maxi(absi(lead["pos"].x - p.x), absi(lead["pos"].y - p.y))
	# 1. To the wall, timed against a walk.
	_put(dg, p)
	var t0 := Time.get_ticks_msec()
	await dg.act_run(d)
	var ms := float(Time.get_ticks_msec() - t0) / maxi(1, steps_in.call())
	_ok(lead["pos"] == p + d * n, "a run crosses the room to the wall: %d of %d steps (%s)" % [steps_in.call(), n, dg.run_stop])
	_put(dg, p)
	var t1 := Time.get_ticks_msec()
	await dg.act_move(d)
	var walk_ms := float(Time.get_ticks_msec() - t1)
	_ok(ms < walk_ms * 0.75, "a run is quicker than a walk: %.0f ms a step against %.0f" % [ms, walk_ms])
	# 2. An item four steps ahead: it stops beside it.
	_put(dg, p)
	dg.floor_items.append({"pos": p + d * 4, "kind": "reedberry"})
	await dg.act_run(d)
	_ok(lead["pos"] == p + d * 3, "an item four steps ahead: the run stops beside it (%d steps in, %s)" % [steps_in.call(), dg.run_stop])
	dg.floor_items.clear()
	# 3. An item it starts beside does not stop it.
	_put(dg, p)
	dg.floor_items.append({"pos": p + side, "kind": "reedberry"})
	await dg.act_run(d)
	_ok(lead["pos"] == p + d * n, "an item beside the start: the run still reaches the wall (%d steps in, %s)" % [steps_in.call(), dg.run_stop])
	dg.floor_items.clear()
	# 4. A seen trap four steps ahead: it stops short of it.
	_put(dg, p)
	dg.traps.append({"pos": p + d * 4, "kind": "snare", "seen": true})
	await dg.act_run(d)
	_ok(lead["pos"] == p + d * 3, "a seen trap four steps ahead: the run stops short of it (%d steps in, %s)" % [steps_in.call(), dg.run_stop])
	dg.traps.clear()
	# 5. An unseen warp three steps ahead: the run ends where the warp left it.
	_put(dg, p)
	dg.traps.append({"pos": p + d * 3, "kind": "warp", "seen": false})
	await dg.act_run(d)
	_ok(dg.run_stop == "carried off", "an unseen warp on the path: the run ends there (%s, now at %s)" % [dg.run_stop, str(lead["pos"])])
	dg.traps.clear()
	_clear(dg)
	# 6. A real key mid-run, through Input as a player presses it; nothing else fires after.
	dg.poll_input = true
	_put(dg, p)
	var turn_before: int = dg.turn
	dg.act_run(d)
	await _until(func() -> bool: return steps_in.call() >= 2, 200)
	_key(KEY_J, true)
	await _frames(3)
	_key(KEY_J, false)
	await _until(func() -> bool: return not dg.running and not dg.busy, 200)
	await _frames(10)
	var after_key: int = steps_in.call()
	_ok(dg.run_stop == "key" and after_key <= 4 and after_key < n, "a J press at step 2 ends the run %d steps in (%s)" % [after_key, dg.run_stop])
	_ok(dg.turn - turn_before == after_key, "and fires nothing afterwards: %d turns for %d steps" % [dg.turn - turn_before, after_key])
	dg.poll_input = false
	# 7. The pause menu mid-run.
	_put(dg, p)
	dg.act_run(d)
	await _until(func() -> bool: return steps_in.call() >= 2, 200)
	var menu: CanvasLayer = dg.get_node("GamePauseMenu")
	menu.open()
	await _frames(3)
	menu.resume()
	await _until(func() -> bool: return not dg.running and not dg.busy, 200)
	_ok(steps_in.call() <= 4 and steps_in.call() < n, "the pause menu ends a run (%d steps in, %s)" % [steps_in.call(), dg.run_stop])
	# 8. A learn prompt mid-run.
	_put(dg, p)
	dg.act_run(d)
	await _until(func() -> bool: return steps_in.call() >= 2, 200)
	dg.teach_kind = "learn:pounce"
	dg.teach_learner = 0
	await _until(func() -> bool: return not dg.running and not dg.busy, 200)
	_ok(dg.run_stop == "prompt" and steps_in.call() < n, "a learn prompt mid-run ends it (%d steps in, %s)" % [steps_in.call(), dg.run_stop])
	dg.teach_kind = ""
	dg.teach_learner = -1
	# 9. A foe coming into sight mid-run.
	_put(dg, p)
	dg.act_run(d)
	await _until(func() -> bool: return steps_in.call() >= 2, 200)
	var spot := Vector2i.ZERO
	for k in range(n, 4, -1):
		var q: Vector2i = p + d * k
		if dg._occupant(q) < 0 and dg._sees(lead["pos"], q):
			spot = q
			break
	if spot != Vector2i.ZERO:
		var foe: Dictionary = dg._make(2, 0, 1, spot)
		dg.ents.append(foe)
		dg._place(foe)
	await _until(func() -> bool: return not dg.running and not dg.busy, 200)
	_ok(spot != Vector2i.ZERO and dg.run_stop == "foe in sight" and lead["pos"] != spot, "a foe comes into sight at step 2: the run stops %d steps in (%s)" % [steps_in.call(), dg.run_stop])
	_clear(dg)
	# 10. A foe already in sight from the start, in the way: the run stops two tiles short of it.
	_put(dg, p)
	var far := n
	while far > 4 and not dg._sees(p, p + d * far):
		far -= 1
	_ok(dg._sees(p, p + d * far), "a spot %d tiles ahead is in sight from the start" % far)
	var foe2: Dictionary = dg._make(2, 0, 1, p + d * far)
	foe2["awake"] = false
	dg.ents.append(foe2)
	dg._place(foe2)
	await dg.act_run(d)
	_ok(dg.run_stop in ["foe close", "hit"] and dg._cheb(lead["pos"], foe2["pos"]) >= 1, "a foe in sight at the end of the line: the run stops %d tiles from it (%s)" % [dg._cheb(lead["pos"], foe2["pos"]), dg.run_stop])
	# The closing-in rule itself: a foe in sight two tiles off counts, three does not.
	_clear(dg)
	_put(dg, p)
	var near_foe: Dictionary = dg._make(2, 0, 1, p + d * 2)
	dg.ents.append(near_foe)
	dg._place(near_foe)
	var two: bool = dg._foe_within(p, 2)
	near_foe["pos"] = p + d * 3
	dg._place(near_foe)
	var three: bool = dg._foe_within(p, 2)
	_ok(two and not three, "a foe in sight 2 tiles off stops a run; 3 tiles off does not (%s, %s)" % [str(two), str(three)])
	_clear(dg)
	dg.queue_free()
	await _frames(4)
	# 11 and 12. Halls: a run stops where a hall opens into a room, and follows a bend.
	var opened := false
	var bent := false
	for seed in [4242, 99, 7, 31337, 2024, 555]:
		var dg2 := await _floor(seed)
		if not opened:
			var hl := _hall_line(dg2)
			if not hl.is_empty():
				opened = true
				_put(dg2, hl[0])
				await dg2.act_run(hl[1])
				var at: Vector2i = dg2.ents[0]["pos"]
				_ok(at == hl[0] + hl[1] * hl[2], "seed %d: a hall run stops where the hall opens into a room (%s)" % [seed, dg2.run_stop])
		if not bent:
			var bl := _bend_line(dg2)
			if not bl.is_empty():
				bent = true
				_put(dg2, bl[0])
				await dg2.act_run(bl[1])
				var at2: Vector2i = dg2.ents[0]["pos"]
				var past: bool = (at2 - bl[2]).x * bl[3].x + (at2 - bl[2]).y * bl[3].y > 0
				_ok(past, "seed %d: a hall run follows the bend at %s and goes on past it (ended at %s, %s)" % [seed, str(bl[2]), str(at2), dg2.run_stop])
		dg2.queue_free()
		await _frames(4)
		if opened and bent:
			break
	_ok(opened, "found a hall that opens into a room")
	_ok(bent, "found a hall with a bend")
	print("run stop: %s (%d failed)" % ["all ok" if fails == 0 else "FAILED", fails])
	quit(1 if fails > 0 else 0)
