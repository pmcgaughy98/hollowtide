extends SceneTree
## Traps and the chain (Claude, 2026-10-09; Preston: "way too many warps and they are in the
## hallways... also teammates keep stopping in one area leaving the leader by himself"). Over 40
## floors: no trap in a hallway, in front of a hallway opening, in the start room or a Monster
## House, and at most TRAP_WARP_MAX warps a floor. A partner walking onto a trap sets nothing off;
## the leader does. Then autopilot runs: the longest a partner stays more than 4 tiles behind.
## Placement, the trap trigger and each seed's run are verdict lines; the partner's lag stays printed for
## Preston's call (Q11) (Claude, 2026-10-24, H05).
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_trap_check.gd

var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _run() -> void:
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 1
	dg.poll_input = false
	root.add_child(dg)
	for k in 4:
		await process_frame
	var total := 0
	var hall := 0
	var opening := 0
	var start_room := 0
	var in_house := 0
	var most_warps := 0
	for sd in 40:
		dg.floor_seed = 500 + sd
		dg._build_floor(true)
		var warps := 0
		for tr in dg.traps:
			total += 1
			var room := Rect2i()
			for r in dg.data["rooms"]:
				if r.has_point(tr["pos"]):
					room = r
			if room.size == Vector2i.ZERO:
				hall += 1
			elif dg._by_opening(tr["pos"], room):
				opening += 1
			if room.size != Vector2i.ZERO and room.grow(1).has_point(dg.data["start"]):
				start_room += 1
			if dg.monster_room.has_point(tr["pos"]):
				in_house += 1
			if tr["kind"] == "warp":
				warps += 1
		most_warps = maxi(most_warps, warps)
	print("Placement over 40 floors: %d traps; in hallways %d, in front of an opening %d, in the start room %d, in a Monster House %d; most warps on a floor %d" % [total, hall, opening, start_room, in_house, most_warps])
	_ok("Placement: no trap in a hallway (%d), in front of an opening (%d), in the start room (%d) or in a Monster House (%d)" % [hall, opening, start_room, in_house], hall == 0 and opening == 0 and start_room == 0 and in_house == 0)
	_ok("Placement: at most %d warp a floor (most %d)" % [dg.TRAP_WARP_MAX, most_warps], most_warps <= dg.TRAP_WARP_MAX)
	# A partner on a trap sets nothing off; the leader does.
	dg.floor_seed = 4242
	dg._build_floor(true)
	var tr: Dictionary = dg.traps[0]
	var mate: Dictionary = dg.ents[1]
	var at: Vector2i = mate["pos"]
	mate["pos"] = tr["pos"]
	mate["moved"] = true
	dg._spring_traps()
	var partner_hit: bool = tr["seen"] or mate.get("snared", 0) > 0
	mate["pos"] = at
	mate["moved"] = false
	var lead: Dictionary = dg.ents[0]
	lead["pos"] = tr["pos"]
	lead["moved"] = true
	dg._spring_traps()
	_ok("A %s trap: the partner on it set it off %s; the leader on it set it off %s" % [tr["kind"], str(partner_hit), str(tr["seen"])], not partner_hit and tr["seen"])
	dg.queue_free()
	await process_frame
	# The chain on autopilot.
	for sd in [99, 7, 31337]:
		var d2: Node2D = load("res://scenes/dungeon.tscn").instantiate()
		d2.floor_seed = sd
		d2.poll_input = false
		root.add_child(d2)
		for k in 4:
			await process_frame
		d2.autopilot = true
		var last_turn: int = d2.turn
		var streak := {}
		var longest := 0
		var frames := 0
		while d2.floor_n == 1 and d2.faints == 0 and frames < 30 * 240:
			await process_frame
			frames += 1
			if d2.turn == last_turn:
				continue
			last_turn = d2.turn
			for k in d2.ents.size():
				var e: Dictionary = d2.ents[k]
				if k == 0 or e["team"] != 0 or e["hp"] <= 0:
					continue
				if d2._cheb(e["pos"], d2.ents[0]["pos"]) > 4:
					streak[k] = streak.get(k, 0) + 1
					longest = maxi(longest, streak[k])
				else:
					streak[k] = 0
		print("Autopilot seed %d: %s after %d turns; the longest a partner stayed more than 4 tiles behind: %d turns" % [sd, "reached B2F" if d2.floor_n > 1 else ("went down" if d2.faints > 0 else "still on B1F"), d2.turn, longest])
		_ok("Autopilot seed %d reaches B2F without going down (B%dF, faints %d)" % [sd, d2.floor_n, d2.faints], d2.floor_n > 1 and d2.faints == 0)
		d2.queue_free()
		await process_frame
	quit(1 if fails else 0)
