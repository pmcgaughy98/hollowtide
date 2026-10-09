extends SceneTree
## The Canvaswing line in the arena (Claude, 2026-10-08): Canvaswing, Windcut, Galeshear, the
## Gale shelter. Stage kits, Shear, Sail Cover, Downdraft grounding shots and lobs, Lift,
## Windbreak, Gale Shear, then AI fights.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_canvaswing_check.gd
## Stills to docs/creatures/arena-canvaswing-2026-10-08/.

const OUT := "res://docs/creatures/arena-canvaswing-2026-10-08/"
const LINE := 8
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(23)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena.team_size = 1
	arena._rival = 0; arena._rival_stage = 2   # Stormwick
	# 1. Each stage's kit.
	for stage in 3:
		arena._you = LINE; arena._you_stage = stage
		arena._new_match()
		await _frames(3)
		var me: Dictionary = arena._fighters[0]
		var names := []
		for m in me["abilities"]:
			names.append(arena.MOVES[m]["name"])
		print("%s (stage %d): basic %s; abilities %s; passive '%s'; role %s/%s; signature %s" % [me["name"], stage + 1, arena.MOVES[me["kit"][0]]["name"], str(names), me["passive"], me["role"], me["group"], "yes" if me["final"] else "no"])
		_save("line_stage%d" % (stage + 1))
	# 2. Shear and Sail Cover on stage 1, then Downdraft against a fireball and a lob.
	arena._you_stage = 0
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	foe["body"].position = me["body"].position + Vector2(24, 0)
	var hp: int = foe["hp"]
	arena._fire(0, "shear", 1)
	var shear: int = hp - foe["hp"]
	me["act"] = 0.0
	me["hp"] = int(me["max_hp"] * 0.5)
	arena._fire(0, "sail_cover", 1)
	var shield: int = me["shield"]
	hp = me["hp"]
	arena._hurt(0, 15, Vector2(-1, 0), 1)
	print("Shear took %d. Sail Cover put a %d shield on the hurt glider; a 15 hit left its HP at %d of %d and the shield at %d" % [shear, shield, me["hp"], hp, me["shield"]])
	me["act"] = 0.0
	me["recovering"] = ""
	foe["body"].position = me["body"].position + Vector2(100, 0)
	arena._fire(0, "downdraft", 1)
	await process_frame
	_save("downdraft")
	# an enemy fireball flying at the glider through the column, and a lob onto its spot
	arena._effects.append({"kind": "fireball", "owner": 1, "pos": foe["body"].position + Vector2(-20, 0), "vel": Vector2(-170, 0), "life": 0.75, "trail": [], "damage": 12})
	arena._effects.append({"kind": "seed", "owner": 1, "from": foe["body"].position, "to": me["body"].position, "t": 0.0, "damage": 14})
	hp = me["hp"]
	var sh: int = me["shield"]
	await _frames(24)
	var balls := 0
	for e in arena._effects:
		if e["kind"] in ["fireball", "seed"]:
			balls += 1
	print("Downdraft: an enemy fireball and a lob aimed through the column; after 0.8 s %d of them are still flying and the glider lost %d HP and %d shield" % [balls, hp - me["hp"], sh - me["shield"]])
	# 3. Lift and Windbreak on stage 2, in a 3v3 with the enemies held.
	arena.team_size = 3
	arena._you_stage = 1
	arena._rival = 3
	arena._new_match()
	await _frames(3)
	var mine := []
	var enemies := []
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 0:
			mine.append(j)
		else:
			enemies.append(j)
	for f in arena._fighters:
		f["stun"] = 60.0
	me = arena._fighters[0]
	me["stun"] = 0.0
	var ally: Dictionary = arena._fighters[mine[1]]
	var e0: Dictionary = arena._fighters[enemies[0]]
	var centre: Vector2 = arena.ARENAS[arena._arena]["floor"].get_center()
	ally["body"].position = centre + Vector2(60, 0)
	e0["body"].position = centre + Vector2(80, 0)
	me["body"].position = centre + Vector2(0, 30)
	ally["hp"] = int(ally["max_hp"] * 0.4)
	ally["rooted"] = 2.0
	var d0: float = ally["body"].position.distance_to(e0["body"].position)
	for m in me["cds"]:
		me["cds"][m] = 0.0
	me["act"] = 0.0
	arena._fire(0, "lift", enemies[0])
	await _frames(2)
	_save("lift")
	print("Lift: the rooted ally %d px from Ironvent went to %d px from it, roots %s, and the glider landed %d px from it" % [d0, ally["body"].position.distance_to(e0["body"].position), "cleared" if ally["rooted"] <= 0.0 else "still on (WRONG)", me["body"].position.distance_to(ally["body"].position)])
	ally["body"].position = me["body"].position + Vector2(20, 0)
	ally["invuln"] = 0.0   # Lift's landing safety would swallow the test hits
	hp = ally["hp"]
	ally["shield"] = 0
	arena._hurt(mine[1], 20, Vector2.ZERO, enemies[0])
	var near: int = hp - ally["hp"]
	ally["body"].position = me["body"].position + Vector2(80, 0)
	hp = ally["hp"]
	arena._hurt(mine[1], 20, Vector2.ZERO, enemies[0])
	print("Windbreak: a 20 hit on the ally beside Windcut took %d; the same hit 80 px away took %d" % [near, hp - ally["hp"]])
	# 4. Gale Shear from the Warden-sized final, enemies gathered round it.
	arena._you_stage = 2
	arena._new_match()
	await _frames(3)
	mine.clear(); enemies.clear()
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 0:
			mine.append(j)
		else:
			enemies.append(j)
	for f in arena._fighters:
		f["stun"] = 60.0
	me = arena._fighters[0]
	me["stun"] = 0.0
	me["meter"] = 100
	me["body"].position = centre
	var dist0 := []
	for k in enemies.size():
		arena._fighters[enemies[k]]["body"].position = centre + Vector2.RIGHT.rotated(k * TAU / 3.0) * 50.0
		dist0.append(arena._fighters[enemies[k]]["body"].position.distance_to(centre))
	arena.signature(0)
	await _frames(60)
	_save("gale_gather")
	await _frames(25)   # past the sweep at 2.6 s
	_save("gale_sweep")
	await _frames(30)
	var dists := []
	var hurt := 0
	var floor_rect: Rect2 = arena.ARENAS[arena._arena]["floor"]
	var at_edge := 0
	for k in enemies.size():
		var p: Vector2 = arena._fighters[enemies[k]]["body"].position
		dists.append(int(p.distance_to(centre)))
		var edge: float = minf(minf(p.x - floor_rect.position.x, floor_rect.end.x - p.x), minf(p.y - floor_rect.position.y, floor_rect.end.y - p.y))
		if edge < 20.0:
			at_edge += 1
		hurt += arena._fighters[enemies[k]]["max_hp"] - arena._fighters[enemies[k]]["hp"]
	var tail := 0
	for j in mine:
		if arena._fighters[j]["haste"] > 0.0:
			tail += 1
	print("Gale Shear: the three enemies went from 50 px round Galeshear to %s px (%d of 3 within 20 px of a wall or rock), %d damage between them from the slams; %d of 3 allies have the tailwind" % [str(dists), at_edge, hurt, tail])
	while arena._sig.active:
		await process_frame
	# 5. AI 1v1 Galeshear against Stormwick.
	arena.team_size = 1
	arena._rival = 0
	arena._new_match()
	await _frames(3)
	arena.auto_you = true
	var frames := 0
	while arena._winner < 0 and frames < 2400:
		await process_frame
		frames += 1
		if frames == 240:
			_save("ai_1v1")
	print("AI 1v1 Galeshear vs Stormwick: %s after %.0f s; dealt %d, took %d" % ["Galeshear" if arena._winner == 0 else ("Stormwick" if arena._winner == 1 else "draw"), frames / 30.0, arena._fighters[0]["dealt"], arena._fighters[0]["max_hp"] - arena._fighters[0]["hp"]])
	# 6. AI 3v3 with Galeshear leading against the Oxbowarchon team (a shooter to ground).
	arena.team_size = 3
	arena._rival = 5
	arena._new_match()
	await _frames(3)
	var team := []
	for f in arena._fighters:
		if f["team"] == 0:
			team.append(f["name"])
	frames = 0
	var drafts := 0
	var was := 0
	while arena._winner < 0 and frames < 2700:
		await process_frame
		frames += 1
		var now := 0
		for e in arena._effects:
			if e["kind"] == "downdraft":
				now += 1
		if now > was:
			drafts += now - was
		was = now
		if frames == 360:
			_save("ai_3v3")
	print("AI 3v3 %s vs the Oxbowarchon team: %s after %.0f s; %d downdrafts raised" % [str(team), "Galeshear's team" if arena._winner == 0 else ("the rival team" if arena._winner == 1 else "draw"), frames / 30.0, drafts])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
