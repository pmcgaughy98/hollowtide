extends SceneTree
## The dungeon's aiming (Claude, 2026-10-10; Preston: "fix aiming system using synthesis"). dungeon.gd aim():
## the current facing wins when it hits; otherwise the foe last hit while still in reach; otherwise the
## nearest foe, then the smallest turn. Before, it took the first direction in a fixed list (east first).
## Also: a tap of Shift faces the nearest foe, and the aim mark names the foe the basic would hit.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_aim_check.gd
## Windowed it saves a still of turn mode to docs/design/dungeon-aim-2026-10-10/.

const OUT := "res://docs/design/dungeon-aim-2026-10-10/"

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
	dg.party = [[0, 0], [1, 0]]   # Kithflare leads: its basic is a one-tile swing (Tallowroot's is a burst)
	root.add_child(dg)
	await _frames(4)
	for room in dg.data["rooms"]:
		if room.size.x >= 8 and room.size.y >= 6:
			spot = room.position + Vector2i(2, 2)
			break
	dg.traps.clear()
	dg.floor_items.clear()
	dg.monster_room = Rect2i()
	for e in dg.ents:
		if e["team"] == 1:
			e["hp"] = 0
			e["node"].visible = false
	var lead: Dictionary = dg.ents[0]
	lead["max_hp"] = 999
	lead["hp"] = 999
	var basic: String = lead["moves"][0]
	_put(0, spot + Vector2i(1, 1))
	_put(1, spot + Vector2i(5, 4))   # the partner out of the way
	var east := _wild(spot + Vector2i(2, 1))
	var sw := _wild(spot + Vector2i(0, 2))

	print("%s's basic %s reaches as %s" % [lead["name"], basic, str(dg.move_reach(basic))])
	# 1. Two foes in reach, facing away from both: the smaller turn wins, not "east because it is first".
	lead["facing"] = "w"
	_ok("Facing west, foes east and south-west: aims %s (south-west, a 45 degree turn)" % str(dg.aim(0, basic)), dg.aim(0, basic) == Vector2i(-1, 1))

	# 2. The foe last hit stays the aim while it is in reach.
	await dg.use_move(0, basic, Vector2i(1, 0))
	await _frames(2)
	lead["facing"] = "w"
	_ok("After hitting the east foe, facing west again: aims %s (east, the marked foe)" % str(dg.aim(0, basic)), dg.aim(0, basic) == Vector2i(1, 0))
	_ok("The aim mark names the east foe (%d)" % dg.aim_target(), dg.aim_target() == east)

	# 3. Turning to a foe on purpose always wins.
	dg.act_face(Vector2i(-1, 1))
	_ok("Shift-turned to the south-west foe: aims %s" % str(dg.aim(0, basic)), dg.aim(0, basic) == Vector2i(-1, 1))
	_ok("The aim mark follows the turn (%d)" % dg.aim_target(), dg.aim_target() == sw)

	# 4. Nothing in reach: no aim, the mark is off.
	for j in [east, sw]:
		dg.ents[j]["hp"] = 0
		dg.ents[j]["node"].visible = false
	_ok("No foe in reach: aim %s, mark %d" % [str(dg.aim(0, basic)), dg.aim_target()], dg.aim(0, basic) == Vector2i.ZERO and dg.aim_target() == -1)

	# 5. A tap of Shift faces the nearest foe it can see.
	var far := _wild(spot + Vector2i(5, 1))
	var near := _wild(spot + Vector2i(1, 4))
	for j in [far, near]:
		dg.ents[j]["snared"] = 99
	dg.visible_tiles[dg.ents[far]["pos"]] = true
	dg.visible_tiles[dg.ents[near]["pos"]] = true
	lead["facing"] = "n"
	dg.act_face_nearest()
	_ok("Shift tap with foes 4 east and 3 south: now facing %s" % lead["facing"], lead["facing"] == "s")

	# A still of turn mode, with the aim mark on a foe in reach.
	dg.ents[near]["pos"] = spot + Vector2i(1, 2)
	dg._place(dg.ents[near])
	dg.turn_mode = true
	dg._reveal()   # sight from the leader's new tile, so the still is not under fog
	if DisplayServer.get_name() != "headless":
		await _frames(150)   # the floor name banner fades first
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + "turn_mode.png"))
	print("DUNGEON AIM: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)


func _wild(pos: Vector2i) -> int:
	var w: Dictionary = dg._make(2, 0, 1, pos)
	w["awake"] = true
	w["max_hp"] = 400
	w["hp"] = 400
	dg.ents.append(w)
	dg._place(w)
	return dg.ents.size() - 1


func _put(k: int, pos: Vector2i) -> void:
	dg.ents[k]["pos"] = pos
	dg._place(dg.ents[k])


func _frames(n: int) -> void:
	for k in n:
		await process_frame
