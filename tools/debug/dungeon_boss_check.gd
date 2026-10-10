extends SceneTree
## Monster Houses, the floor plan and the boss floor (Claude, 2026-10-09). A Monster House has bait
## in it, drops in more creatures in bigger rooms with a banner, and relights the lantern when
## cleared. The floor plan follows Explorers of Sky: generated floors, an optional rest floor, and
## the boss's fixed floor last (one arena, only the boss and its helpers). The boss floor opens on a
## dialogue scene; the boss sleeps through it, wakes with a banner and a health bar when it ends,
## does not budge, still loses a gathered move to a charge, never asks to join, and its fall clears
## the dungeon. Then whole runs on autopilot, boss included.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_boss_check.gd
## Stills to docs/design/dungeon-boss-2026-10-09/.

const OUT := "res://docs/design/dungeon-boss-2026-10-09/"

var dg: Node2D


func _initialize() -> void:
	_run.call_deferred()


func _fresh(sd: int) -> void:
	if dg != null:
		dg.queue_free()
		await process_frame
	dg = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = sd
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0]]
	root.add_child(dg)
	await _frames(4)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	# ---- 1. Monster House: find a floor that has one
	await _fresh(1)
	var found := -1
	for sd in range(1, 80):
		dg.floor_seed = sd
		dg._build_floor(true)
		if dg.monster_room.size != Vector2i.ZERO:
			found = sd
			break
	var room: Rect2i = dg.monster_room
	var bait: int = dg.floor_items.filter(func(it: Dictionary) -> bool: return room.has_point(it["pos"])).size()
	print("Monster House: seed %d, room %s, items lying in it before it springs: %d" % [found, str(room.size), bait])
	for e in dg.ents:
		if e["team"] == 1:
			e["hp"] = 0
			e["node"].visible = false
	var inside := Vector2i(-1, -1)
	for y in range(room.position.y, room.end.y):
		for x in range(room.position.x, room.end.x):
			if inside == Vector2i(-1, -1) and dg._floor_at(Vector2i(x, y)) and dg._occupant(Vector2i(x, y)) < 0:
				inside = Vector2i(x, y)
	dg.ents[0]["pos"] = inside
	dg._place(dg.ents[0])
	dg._reveal()
	dg._monster_house()
	var house: Array = dg.ents.filter(func(e: Dictionary) -> bool: return e.get("house", false))
	var high := 0
	for e in house:
		if e["node"].position.y < dg._tile_px(e["pos"]).y - 30.0:
			high += 1
	await _frames(5)
	_save("monster_house_drop")
	await _frames(30)
	var landed := 0
	for e in house:
		if e["node"].position.distance_to(dg._tile_px(e["pos"])) < 1.0:
			landed += 1
	print("Sprung: %d dropped in (%d started above their tile, %d landed); banner '%s'" % [house.size(), high, landed, dg._banner["text"]])
	dg.light = 50.0
	for e in house:
		e["hp"] = 0
		e["node"].visible = false
	await dg.act_rest()
	print("Cleared: lantern 50 -> %.0f; banner '%s'; cleared flag %s" % [dg.light, dg._banner["text"], str(dg.house_cleared)])

	# ---- 2. A rest floor
	await _fresh(4242)
	dg.rest_floor = 2
	dg.floor_n = 2
	dg.ents[0]["hp"] = 5
	dg._build_floor(false)
	var wild: int = dg.ents.filter(func(e: Dictionary) -> bool: return e["team"] == 1).size()
	print("Rest floor: kind %s, rooms %d, wild %d, items %d, traps %d, leader %d/%d, banner '%s'" % [dg.floor_kind(), dg.data["rooms"].size(), wild, dg.floor_items.size(), dg.traps.size(), dg.ents[0]["hp"], dg.ents[0]["max_hp"], dg._banner["text"]])

	# ---- 3. The boss floor
	await _fresh(4242)
	dg.boss_intro = false   # the bosses' scenes have their own captures; this checks the fight and the finish
	dg.recruit_override = 1.0   # every beaten creature would ask, so a boss that does not is measured
	dg.floor_n = dg.FLOORS + 1
	dg._build_floor(true)
	if dg.boss < 0:
		print("Boss: none placed (WRONG)")
		quit()
		return
	var b: Dictionary = dg.ents[dg.boss]
	var plain: Dictionary = dg._make(dg.BOSS[0], dg.BOSS[1], 1, Vector2i.ZERO)
	plain["node"].queue_free()
	var minions: int = dg.ents.filter(func(e: Dictionary) -> bool: return e.get("minion", false)).size()
	var others: int = dg.ents.filter(func(e: Dictionary) -> bool: return e["team"] == 1 and not e.get("boss", false) and not e.get("minion", false)).size()
	print("Boss floor B%dF: kind %s, %d room, items %d, traps %d, other wild %d; %s with %d HP (a plain wild one has %d), %d helpers" % [dg.floor_n, dg.floor_kind(), dg.data["rooms"].size(), dg.floor_items.size(), dg.traps.size(), others, b["name"], b["max_hp"], int(round(plain["max_hp"] * dg.WILD_HP)), minions])
	await _frames(3)
	_save("boss_scene")
	var lines: int = dg.talk.size()
	var first: String = "%s: %s" % [dg.talk[0][0], dg.talk[0][1]] if lines > 0 else ""
	print("Scene: %d lines, first '%s'; boss asleep during it %s" % [lines, first, str(not b["awake"])])
	for k in lines:
		dg.act_talk()
	await _frames(3)
	_save("boss_met")
	print("After the scene: banner '%s' / '%s', boss awake %s, helpers awake %d" % [dg._banner["text"], dg._banner["sub"], str(b["awake"]), dg.ents.filter(func(e: Dictionary) -> bool: return e.get("minion", false) and e["awake"]).size()])
	var lead: Dictionary = dg.ents[0]
	lead["max_hp"] = 999
	lead["hp"] = 999
	var spot: Vector2i = lead["pos"]
	lead["pos"] = dg.data["stairs"]
	dg._place(lead)
	var f0: int = dg.floor_n
	await dg.act_stairs()
	print("Stairs while it stands: floor %d -> %d (sealed)" % [f0, dg.floor_n])
	lead["pos"] = spot
	dg._place(lead)
	for e in dg.ents:
		if e.get("minion", false):
			e["hp"] = 0
			e["node"].visible = false
	var charge := ""
	for m in lead["moves"]:
		if dg.move_reach(m)["kind"] == "dash":
			charge = m
	var side := Vector2i(0, 1)
	lead["pos"] = b["pos"] + side
	dg._place(lead)
	var at: Vector2i = b["pos"]
	b["windup"] = {"m": b["moves"][-1], "d": side, "tiles": []}
	lead["cds"][charge] = 0
	await dg.use_move(0, charge, -side)
	print("Charge into it while it gathers: moved %s, wind-up broken %s, staggered %d" % [str(b["pos"] != at), str(not b.has("windup")), b.get("stagger", 0)])
	lead["cds"][charge] = 0
	await dg.use_move(0, charge, -side)
	print("Charge into it otherwise: moved %s" % str(b["pos"] != at))
	b["hp"] = 1
	var c0: int = dg.cleared
	await dg.use_move(0, lead["moves"][0], -side)
	await _frames(4)
	_save("boss_beaten")
	print("Beaten: banner '%s'; asked to join %s" % [dg._banner["text"], str(dg.asking >= 0)])
	await _frames(30 * 4)
	print("Then: cleared %d -> %d, back on floor %d" % [c0, dg.cleared, dg.floor_n])

	# ---- 4. Whole runs on autopilot, boss included
	for sd in [99, 7, 31337]:
		await _fresh(sd)
		dg.autopilot = true
		var frames := 0
		var met := false
		var boss_t := 0
		while dg.cleared == 0 and dg.faints == 0 and frames < 30 * 600:
			await process_frame
			frames += 1
			if dg.boss_met and dg.boss_alive():
				met = true
				boss_t += 1
		print("Autopilot run seed %d: cleared %d, faints %d, %d turns, %.0f s on screen; met the boss %s, fought it %.0f s; team %s" % [sd, dg.cleared, dg.faints, dg.turn, frames / 30.0, str(met), boss_t / 30.0, str(dg.party)])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	await _frames(2)
	# Headless has no viewport texture. The printed numbers are the check.
	if DisplayServer.get_name() == "headless":
		return
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))
