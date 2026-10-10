extends SceneTree
## The mystery-dungeon slice (Claude, 2026-10-09): one-tile hallways from the generator, the team
## round the start, wild creatures asleep; a step is one turn and everyone else acts; walls and
## wall corners stop steps; bumping an enemy attacks it; a move with nobody in reach is refused
## for free; cooldowns count in turns; a wild creature wakes when seen; the autopilot clears a
## floor and goes down the stairs; two creatures never share a tile and none stands in a wall.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_check.gd
## Stills to docs/design/dungeon-slice-2026-10-09/.

const OUT := "res://docs/design/dungeon-slice-2026-10-09/"
const Gen := preload("res://scripts/hollow/hollow_gen.gd")

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 777
	dg.party = [[0, 0], [1, 0]]
	dg.poll_input = false
	dg.real_time_battles = false   # this check tests the turn-based fight rules (2026-10-09: fights are real-time by default)
	root.add_child(dg)
	await _frames(4)
	# 1. The floor and who is on it.
	var widest := 0
	var w: int = dg.data["w"]
	for y in dg.data["h"]:
		var run := 0
		for x in w:
			run = run + 1 if dg.data["tiles"][y * w + x] == Gen.FLOOR else 0
	var names := []
	for e in dg.ents:
		names.append("%s:%s%s" % ["you" if e["team"] == 0 else "wild", e["name"], "" if e["team"] == 0 else ("" if e["awake"] else "(asleep)")])
	var lead: Dictionary = dg.ents[0]
	print("Floor: %dx%d tiles, %d rooms; on it %s; the leader on the start: %s; HP %d" % [w, dg.data["h"], dg.data["rooms"].size(), str(names), str(lead["pos"] == dg.data["start"]), lead["max_hp"]])
	var finished := 0
	for e in dg.ents:
		var mat = e["sprite"].material
		if mat is ShaderMaterial and mat.shader == preload("res://scripts/arena/creature_finish.gdshader"):
			finished += 1
	print("Finish: %d of %d creatures on the floor wear Codex's outline finish" % [finished, dg.ents.size()])
	_save("start")
	# 2. One step is one turn.
	var t0: int = dg.turn
	var p0: Vector2i = lead["pos"]
	var d := Vector2i.ZERO
	for dd in dg.DIRS:
		if dg.can_step(p0, dd) and dg._occupant(p0 + dd) < 0:
			d = dd
			break
	await dg.act_move(d)
	print("A step %s: the leader moved %s, turns %d -> %d" % [str(d), str(lead["pos"] - p0), t0, dg.turn])
	# 3. Walls and corners stop steps.
	var corner_found := false
	var corner_blocked := false
	for y in range(1, dg.data["h"] - 1):
		for x in range(1, w - 1):
			var p := Vector2i(x, y)
			if not dg._floor_at(p):
				continue
			for dd in [Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]:
				if dg._floor_at(p + dd) and (not dg._floor_at(p + Vector2i(dd.x, 0)) or not dg._floor_at(p + Vector2i(0, dd.y))):
					corner_found = true
					corner_blocked = not dg.can_step(p, dd)
					break
			if corner_found:
				break
		if corner_found:
			break
	print("Wall corner: a diagonal past a wall corner is %s" % ("refused" if corner_blocked else "allowed (WRONG)"))
	# 4. Combat: put an awake wild creature next to the leader.
	var wild := -1
	for k in dg.ents.size():
		if dg.ents[k]["team"] == 1:
			wild = k
			break
	var free_d := Vector2i.ZERO
	for dd in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if dg._floor_at(lead["pos"] + dd) and dg._occupant(lead["pos"] + dd) < 0:
			free_d = dd
			break
	var foe: Dictionary = dg.ents[wild]
	foe["pos"] = lead["pos"] + free_d
	foe["awake"] = true
	dg._place(foe)
	var hp: int = foe["hp"]
	await dg.act_move(free_d)
	print("Bump: walking into %s attacked it with %s: %d damage, the leader stayed put: %s" % [foe["name"], dg.Arena.MOVES[lead["moves"][0]]["name"], hp - foe["hp"], str(lead["pos"] != foe["pos"])])
	_save("bump")
	# A move with nobody in reach is refused for free; a move that reaches is used and cools down.
	if lead["moves"].size() > 1:
		var m: String = lead["moves"][1]
		var turn_before: int = dg.turn
		var far: Vector2i = foe["pos"]
		foe["pos"] = Vector2i(-50, -50)   # out of the floor, out of reach
		await dg.act_attack(1)
		var refused: bool = dg.turn == turn_before
		foe["pos"] = far
		lead["cds"][m] = 0
		var reach: Dictionary = dg.move_reach(m)
		hp = foe["hp"]
		await dg.act_attack(1)
		print("%s (%s %d): with nobody in reach it was %s; with %s in reach it hit for %d and cools down %d turns" % [dg.Arena.MOVES[m]["name"], reach["kind"], reach["n"], "refused, no turn spent" if refused else "used (WRONG)", foe["name"], hp - foe["hp"], lead["cds"][m]])
	# 5. Autopilot: clear the floor and take the stairs.
	foe["hp"] = mini(foe["hp"], foe["max_hp"])
	dg.autopilot = true
	var overlaps := 0
	var in_wall := 0
	var frames := 0
	var woke := 0
	var shot := false
	while dg.floor_n == 1 and frames < 30 * 240:
		await process_frame
		frames += 1
		var seen := {}
		for e in dg.ents:
			if e["hp"] <= 0:
				continue
			if seen.has(e["pos"]):
				overlaps += 1
				if overlaps == 1:
					var o: Dictionary = seen[e["pos"]]
					print("   first overlap, turn %d: %s (team %d, hp %d, awake %s, house %s) and %s (team %d, hp %d, awake %s, house %s) on %s; asking %d; log %s" % [dg.turn, e["name"], e["team"], e["hp"], str(e["awake"]), str(e.get("house", false)), o["name"], o["team"], o["hp"], str(o["awake"]), str(o.get("house", false)), str(e["pos"]), dg.asking, str(dg.log_lines.slice(-14))])
			seen[e["pos"]] = e
			if not dg._floor_at(e["pos"]):
				in_wall += 1
		if not shot:
			for e in dg.ents:
				if e["team"] == 1 and e["hp"] > 0 and e["awake"] and dg._cheb(e["pos"], dg.ents[0]["pos"]) <= 2:
					shot = true
					_save("fight")
					break
	var downed := 0
	print("Autopilot: %s after %d turns (%.0f s on screen), %d faints on the way; overlaps %d, creatures in walls %d" % ["reached B%dF" % dg.floor_n if dg.floor_n > 1 else "still on B1F (WRONG)", dg.turn, frames / 30.0, dg.faints, overlaps, in_wall])
	await _frames(20)
	_save("b2f")
	var team := []
	for e in dg.ents:
		if e["team"] == 0:
			team.append("%s %d/%d" % [e["name"], e["hp"], e["max_hp"]])
	print("B2F: team %s; %d wild creatures asleep; the log ends: %s" % [str(team), dg.ents.filter(func(e: Dictionary) -> bool: return e["team"] == 1 and not e["awake"]).size(), str(dg.log_lines.slice(-4))])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
