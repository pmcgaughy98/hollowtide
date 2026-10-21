extends SceneTree
## The Springvault line, the healer (Claude, 2026-10-10). In the dungeon: Archroot knows Spring
## Spit and Seep; Seep heals it and the teammate beside it at once and again each turn it stays;
## it cannot be knocked back while rooted; moving pulls the roots up; the partner AI chooses Seep
## when the team beside it is hurt; the heals count toward evolving; Troughspine spawns wild on The Hollow's B2F.
## In the arena: all three forms fight a full AI match without errors (basic only for now).
##   Godot --path . --fixed-fps 30 --script res://tools/debug/springvault_check.gd

const LINE := 10


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _check(label: String, ok: bool, detail: String) -> int:
	print("%s: %s -> %s" % [label, detail, "ok" if ok else "WRONG"])
	return 0 if ok else 1


func _run() -> void:
	var bad := 0
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[LINE, 1], [0, 0]]   # Archroot: Grok, 2026-10-12, Seep is learned on growing, Troughspine does not know it
	root.add_child(dg)
	await _frames(4)
	for e in dg.ents:
		if e["team"] == 1:
			e["hp"] = 0
			e["node"].visible = false
	var tr: Dictionary = dg.ents[0]
	var kith: Dictionary = dg.ents[1]
	# What Archroot should know, read from the game's own learn data (LEARN in dungeon.gd, Grok's
	# table) instead of a list kept here, so a change there shows up as a change here (Claude,
	# 2026-10-21): its form's basic, then every move the line's forms up to Archroot teach by its
	# level (evolve moves on growing), that its body can perform. It must know Spring Spit and Seep,
	# every move the data gives it (while they fit in four), and nothing the data does not give.
	var lv: int = dg.level_of(LINE)
	var due: Array = [dg.basic_of(tr["form"])]
	for st in tr["stage"] + 1:
		for entry in dg.LEARN.get(dg.form_of(LINE, st), []):
			var reached: bool = (st > 0) if entry[0] is String else int(entry[0]) <= lv
			if reached and not entry[1] in due and dg.MoveBody.can_learn(tr["form"], entry[1]):
				due.append(entry[1])
	var missing: Array = due.filter(func(m: String) -> bool: return not m in tr["moves"])
	var extra: Array = tr["moves"].filter(func(m: String) -> bool: return not m in due)
	bad += _check("Archroot", tr["name"] == "Archroot" and tr["moves"].has("spring_spit") and tr["moves"].has("seep") and (missing.is_empty() or due.size() > dg.MOVES_MAX) and extra.is_empty() and tr["art"]["still"].has("s"),
		"%s at Lv. %d knows %s; its learn data gives %s (missing %s, outside the data %s), art %s" % [tr["name"], lv, str(tr["moves"]), str(due), str(missing), str(extra), str(tr["art"]["still"].has("s"))])

	# Kithflare hurt, standing beside it; Troughspine hurt a little too.
	var d := Vector2i.ZERO
	for dd in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if dg.can_step(tr["pos"], dd) and dg._occupant(tr["pos"] + dd) < 0:
			d = dd
			break
	kith["pos"] = tr["pos"] + d
	dg._place(kith)
	kith["hp"] = 10
	tr["hp"] = tr["max_hp"] - 3
	var heal: int = dg.Arena.MOVES["seep"]["heal"]
	await dg.act_attack(tr["moves"].find("seep"))
	await _frames(20)
	# One heal on use, a second at the end of that turn.
	bad += _check("Seep", kith["hp"] == 10 + 2 * heal and tr["hp"] == tr["max_hp"] and tr.has("seep") and dg.growth["10:1"]["healed"] == 2 * heal + 3,
		"Kithflare 10 -> %d (heal %d twice), Archroot full %s, rooted %s, healed counted %d" % [kith["hp"], heal, str(tr["hp"] == tr["max_hp"]), str(tr.has("seep")), dg.growth["10:1"]["healed"]])

	# Rooted: a charge cannot shove it.
	var at: Vector2i = tr["pos"]
	await dg._shove(1, 0, -d)
	bad += _check("Rooted", tr["pos"] == at and dg.log_lines.back().contains("rooted"), "still at %s, '%s'" % [str(tr["pos"]), dg.log_lines.back()])

	# A turn spent standing: heals again. Then it steps away: the spring sinks.
	kith["hp"] = 10
	await dg.act_rest()
	await _frames(12)
	var stayed: int = kith["hp"]
	var step_d := Vector2i.ZERO
	for dd in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
		if dg.can_step(tr["pos"], dd) and dg._occupant(tr["pos"] + dd) < 0:
			step_d = dd
			break
	await dg.act_move(step_d)
	await _frames(20)
	bad += _check("Stay, then move", stayed == 10 + heal and not tr.has("seep") and dg.log_lines.any(func(l: String) -> bool: return l.contains("pulled its roots up")),
		"stayed: Kithflare 10 -> %d; after the step rooted %s" % [stayed, str(tr.has("seep"))])

	# The partner AI: Archroot as the partner, the leader hurt beside it.
	dg.ents[0] = kith
	dg.ents[1] = tr
	tr["cds"]["seep"] = 0
	kith["pos"] = tr["pos"] + Vector2i(1, 0) if dg.can_step(tr["pos"], Vector2i(1, 0)) else tr["pos"] + Vector2i(-1, 0)
	dg._place(kith)
	kith["hp"] = 8
	var plan: Dictionary = dg._decide(1)
	kith["hp"] = kith["max_hp"]
	tr["hp"] = tr["max_hp"]
	var calm: Dictionary = dg._decide(1)
	bad += _check("Partner AI", plan.get("m", "") == "seep" and calm.get("m", "") != "seep",
		"leader at 8: %s; everyone full: %s" % [str(plan), str(calm)])

	# Evolving reads the heals; B2F can roll it wild.
	var r: Dictionary = dg.EVO[LINE]
	var b2f: Array = dg.DUNGEONS["hollow"]["spawns"][2]   # Troughspine moved to The Hollow on 2026-10-10 (Preston: it belongs there)
	bad += _check("Growth", r["way"] == "healed" and b2f.has([LINE, 0]), "way %s, Hollow B2F spawns %s" % [r["way"], str(b2f)])
	dg.queue_free()
	await _frames(4)

	# The arena: each form in a full AI match, steering off.
	var arena: Node2D = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	arena.poll_input = false
	arena.auto_you = true
	arena.team_size = 1
	arena._rival = 0
	arena._rival_stage = 0
	for st in 3:
		arena._you = LINE
		arena._you_stage = st
		arena._new_match()
		await _frames(3)
		var me: Dictionary = arena._fighters[0]
		var hp0: int = arena._fighters[1]["hp"]
		await create_timer(20.0).timeout   # 20 s of game time, with or without --fixed-fps
		bad += _check("Arena %s" % me["name"], arena._fighters[1]["hp"] < hp0, "basic %s, Kithflare %d -> %d in 20 s" % [arena.MOVES[me["kit"][0]]["name"], hp0, arena._fighters[1]["hp"]])
	arena.queue_free()
	print("RESULT: %s" % ("the healer works" if bad == 0 else "%d problems" % bad))
	quit()
