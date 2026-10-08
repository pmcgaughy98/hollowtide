extends SceneTree
## Crowd control, knockback and the objective (Claude, 2026-10-08): airborne stops a creature
## acting and keeps ground hazards off it; a ram is unstoppable; knockback grows as HP falls;
## Tanks shed holds faster; the Crest charges a final's meter when held alone; the clock
## decides a team fight on points.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_objective_check.gd
## Stills to docs/creatures/arena-feel-2026-10-07/objective_*.png.

const OUT := "res://docs/creatures/arena-feel-2026-10-07/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(13)
	# 1. Airborne: Oathfen's Slab Vortex launches; the launched enemy cannot act and a glass pool under it does not burn it.
	arena.team_size = 1
	arena._you = 5; arena._you_stage = 1
	arena._rival = 0; arena._rival_stage = 2
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	foe["body"].position = me["body"].position + Vector2(22, 0)
	foe["stun"] = 0.0
	for m in foe["cds"]:
		foe["cds"][m] = 0.0
	foe["act"] = 0.0
	arena._effects.append({"kind": "glass_pool", "owner": 0, "pos": foe["body"].position, "r": 30.0, "t": 0.0, "tick": 0.0})
	for m in me["cds"]:
		me["cds"][m] = 0.0
	me["act"] = 0.0
	arena.cast(2)
	while not me["windup"].is_empty():
		await process_frame
	await process_frame
	var air: float = foe["airborne"]
	var hp_air: int = foe["hp"]
	var acted := false
	for k in 10:
		await process_frame
		if not foe["windup"].is_empty():
			acted = true
	print("Airborne: Slab Vortex launched the enemy for %.2f s; while in the air it %s and the glass pool under it took %d" % [air, "wound up a move (WRONG)" if acted else "could not act", hp_air - foe["hp"]])
	_save("objective_airborne")
	# 2. Unstoppable: a ramming Ironvent is not pushed.
	arena._you = 3; arena._you_stage = 2
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	arena._fighters[1]["stun"] = 60.0
	me["ram_t"] = 0.3
	var p0: Vector2 = me["body"].position
	arena._hurt(0, 10, Vector2(-1, 0) * 1.5, 1)
	var moved: float = me["body"].position.distance_to(p0)
	me["ram_t"] = 0.0
	# 3. Knockback growth: the same push at full HP and at a quarter.
	me["body"].position = p0
	me["hp"] = me["max_hp"]
	arena._hurt(0, 5, Vector2(-1, 0) * 1.2, 1)
	await _frames(12)   # a big enough push becomes a carry, which moves over frames
	var push_full: float = me["body"].position.distance_to(p0)
	me["body"].position = p0
	me["carry_t"] = 0.0
	me["hp"] = int(me["max_hp"] * 0.25)
	arena._hurt(0, 5, Vector2(-1, 0) * 1.2, 1)
	await _frames(12)
	var push_low: float = me["body"].position.distance_to(p0)
	print("Unstoppable: a push during a ram moved Ironvent %.0f px. Knockback growth: the same push moved it %.0f px at full HP and %.0f px at a quarter" % [moved, push_full, push_low])
	# 4. Tenacity: a 1 s stun on Rampartroot against Stormwick.
	arena._you = 1
	arena._new_match()
	await _frames(3)
	arena._fighters[0]["stun"] = 1.0
	arena._fighters[1]["stun"] = 1.0
	await _frames(15)
	print("Tenacity: after half a second, the tank's stun is at %.2f and the skirmisher's at %.2f" % [arena._fighters[0]["stun"], arena._fighters[1]["stun"]])
	# 5. The Crest: a 3v3, our final alone in the centre circle, then an enemy joins it.
	arena.team_size = 3
	arena._you = 0; arena._rival = 3
	arena._new_match()
	await _frames(3)
	var centre: Vector2 = arena.ARENAS[arena._arena]["floor"].get_center()
	for f in arena._fighters:
		f["stun"] = 60.0
		f["body"].position = centre + Vector2(150 if f["team"] == 1 else -150, 0)
	me = arena._fighters[0]
	me["body"].position = centre
	me["meter"] = 0
	await _frames(30)
	var meter_alone: int = me["meter"]
	var team_alone: int = arena._crest_team
	_save("objective_crest")
	var e0 := -1
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 1:
			e0 = j
			break
	arena._fighters[e0]["body"].position = centre + Vector2(10, 0)
	await _frames(30)
	print("Crest: held alone for 1 s the meter went 0 -> %d (holder team %d); contested for 1 s it went to %d (holder %d)" % [meter_alone, team_alone, me["meter"], arena._crest_team])
	# 6. On points: the clock runs out with our team ahead.
	for f in arena._fighters:
		f["hp"] = int(f["max_hp"] * (0.6 if f["team"] == 0 else 0.4))
	arena._clock = arena.MATCH_SECONDS - 0.05
	await _frames(5)
	print("On points: winner team %d (%s), decided on the clock: %s" % [arena._winner, "ours" if arena._winner == 0 else "theirs", "yes" if arena._on_points else "no"])
	_save("objective_points")
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
