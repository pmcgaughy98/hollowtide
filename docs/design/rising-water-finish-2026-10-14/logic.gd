extends SceneTree
## Rising water on the Hollow's valley floor (R5 of the genre synthesis; Claude, 2026-10-12). Headless; windowed
## it also saves a still of the flooded floor to docs/design/water-2026-10-12/. Checks: the valley floor has
## water and a ceiling below the stairs and the start; every WATER_EVERY turns a row floods from the bottom;
## on a rise the current carries the leader and a lying item a tile downstream while a Tide wild stays; wet
## feet cost light; the water never passes its ceiling; a floor without water stays dry.
##   Godot --headless --path . --script res://tools/debug/water_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
var OUT := "D:/dev/hollowtide-rising-water-20261014/"+("live/" if OS.get_cmdline_user_args().has("live") else "stage/")
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _snap(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	for k in 3:
		await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


func _dungeon(id: String, seed: int) -> Node2D:
	TeamState.start([[0, 0], [1, 0]])
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = seed
	dg.poll_input = false
	TeamState.give_to(dg)
	dg.dungeon = id
	root.add_child(dg)
	await _frames(4)
	return dg


## A floor tile on the lowest floor row whose east neighbour is free floor too, not used yet.
func _bottom_spot(dg: Node2D, used: Array) -> Vector2i:
	var h: int = dg.water_base
	for x in range(0, int(dg.data["w"]) - 1):
		var p := Vector2i(x, h - 1)
		var q := p + Vector2i(1, 0)
		if dg._floor_at(p) and dg._floor_at(q) and dg._occupant(p) < 0 and dg._occupant(q) < 0 and not used.has(p) and not used.has(q):
			used.append(p)
			used.append(q)
			return p
	return Vector2i(-1, -1)


func _run() -> void:
	root.size=Vector2i(1152,648)
	# A seed whose valley floor has room for the water to climb a few rows and three bottom-row spots.
	var dg: Node2D = null
	var seed := 0
	for s in range(1, 60):
		var d := await _dungeon("hollow", s)
		var used: Array = []
		var spots := 0
		for k in 3:
			if _bottom_spot(d, used) != Vector2i(-1, -1):
				spots += 1
		if s <= 3:
			print("  seed %d: water here %s, base row %d, can climb %d, bottom spots %d (start y %d, stairs y %d)" % [s, str(d.water_here()), d.water_base, d.water_max, spots, d.data["start"].y, d.data["stairs"].y])
		if d.water_here() and d.water_max >= 3 and spots == 3:
			dg = d
			seed = s
			break
		d.queue_free()
		await _frames(2)
	_ok("A valley floor with water in it: seed %d, the water can climb %d rows (lowest floor row %d, start y %d, stairs y %d)" % [seed, dg.water_max if dg else 0, dg.water_base - 1 if dg else 0, dg.data["start"].y if dg else -1, dg.data["stairs"].y if dg else -1], dg != null)
	if dg == null:
		print("WATER: 1 FAILED")
		quit(1)
		return
	var stairs: Vector2i = dg.data["stairs"]
	var start: Vector2i = dg.data["start"]
	_ok("Dry to begin with: rows %d, the stairs dry %s" % [dg.water_rows, not dg.wet(stairs)], dg.water_rows == 0 and not dg.wet(stairs))
	# 1. The first rise.
	var used: Array = []
	var a := _bottom_spot(dg, used)
	dg.turn = dg.WATER_EVERY
	dg._end_turn()
	_ok("At turn %d one row floods: rows %d, a bottom tile wet %s, the stairs dry %s, the start dry %s" % [dg.turn, dg.water_rows, dg.wet(a), not dg.wet(stairs), not dg.wet(start)],
		dg.water_rows == 1 and dg.wet(a) and not dg.wet(stairs) and not dg.wet(start))
	# 2. The current on the next rise: the leader and a lying item go a tile downstream; a Tide wild stays.
	var lead: Dictionary = dg.ents[0]
	lead["pos"] = a
	dg._place(lead)
	var b := _bottom_spot(dg, used)
	var stone := {"pos": b, "kind": "river_stone"}   # kept by reference: the floor stocks stones of its own
	dg.floor_items.append(stone)
	var c := _bottom_spot(dg, used)
	var swimmer: Dictionary = dg._make(10, 0, 1, c)   # Troughspine, a Tide line
	swimmer["awake"] = false
	dg.ents.append(swimmer)
	dg._place(swimmer)
	var tide_in: bool = CreatureData.Essence.TIDE in swimmer["essences"]
	var light0: float = dg.light
	dg.turn = dg.WATER_EVERY * 2
	dg._end_turn()
	var item_at: Vector2i = stone["pos"]
	_ok("On the rise the current carries the leader %s -> %s and the stone %s -> %s; %s (Tide %s) stays at %s; wet feet cost light %.1f -> %.1f" % [str(a), str(lead["pos"]), str(b), str(item_at), swimmer["name"], str(tide_in), str(swimmer["pos"]), light0, dg.light],
		dg.water_rows == 2 and lead["pos"] == a + Vector2i(1, 0) and item_at == b + Vector2i(1, 0) and tide_in and swimmer["pos"] == c and dg.light <= light0 - dg.WET_LIGHT)
	# 3. Never past the ceiling, and no rise off the clock.
	dg.turn = dg.WATER_EVERY * 2 + 1
	dg._end_turn()
	var between: int = dg.water_rows
	for k in 40:
		dg.turn = dg.WATER_EVERY * (3 + k)   # back on the clock
		dg._end_turn()
	_ok("Off the clock nothing rises (%d); after 40 more rises the water sits at its ceiling %d of %d, the stairs dry %s, the start dry %s" % [between, dg.water_rows, dg.water_max, not dg.wet(stairs), not dg.wet(start)],
		between == 2 and dg.water_rows == dg.water_max and not dg.wet(stairs) and not dg.wet(start))
	# The leader on the dry row just above the water line for the still, the partner beside it.
	var shore := Vector2i(-1, -1)
	for y in range(dg.water_base - dg.water_rows - 1, -1, -1):
		for x in dg.data["w"]:
			var p := Vector2i(x, y)
			if dg._floor_at(p) and dg._occupant(p) < 0 and dg._floor_at(p + Vector2i(0, 1)):
				shore = p
				break
		if shore != Vector2i(-1, -1):
			break
	if shore != Vector2i(-1, -1):
		lead["pos"] = shore
		dg._place(lead)
		if dg.ents.size() > 1 and dg.ents[1]["team"] == 0:
			var side := shore + Vector2i(-1, 0) if dg._floor_at(shore + Vector2i(-1, 0)) and dg._occupant(shore + Vector2i(-1, 0)) < 0 else shore + Vector2i(0, -1)
			dg.ents[1]["pos"] = side
			dg._place(dg.ents[1])
		dg._reveal()
	print("  still: the leader at %s, the water line at row %d" % [str(lead["pos"]), dg.water_base - dg.water_rows])
	await _snap("flooded")
	dg.queue_free()
	await _frames(2)
	# 4. A floor without water stays dry.
	var dry := await _dungeon("first", 3)
	for k in 5:
		dry.turn += dry.WATER_EVERY
		dry._end_turn()
	_ok("Rootbank Warren B1F has no water: here %s, rows %d" % [str(dry.water_here()), dry.water_rows], not dry.water_here() and dry.water_rows == 0)
	dry.queue_free()
	print("WATER: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	var music:=root.get_node_or_null("HollowtideMusic")
	if music!=null:music.queue_free()
	await _frames(4)
	quit(1 if fails else 0)
