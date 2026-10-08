extends SceneTree
## Player-fired abilities (Claude, 2026-10-07): Stormwick's Flashstep charges, Lantern Volley,
## Lantern Lunge hit and miss, the pounce basic, and the ability bar.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_abilities_check.gd
## Stills to docs/creatures/arena-feel-2026-10-07/abilities_*.png.

const OUT := "res://docs/creatures/arena-feel-2026-10-07/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(21)
	arena.team_size = 1
	arena._you = 0; arena._you_stage = 2       # Stormwick
	arena._rival = 1; arena._rival_stage = 2   # Rampartroot
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	foe["stun"] = 60.0   # holds still for the staged casts
	# 1. Flashstep: three charges, each on its own 3 s timer.
	var before: Vector2 = me["body"].position
	var used := 0
	for k in 4:
		var cd: float = me["cds"]["flashstep"]
		arena.cast(0)
		await _frames(2)
		if me["cds"]["flashstep"] != cd or k < 3:
			used += 1
		me["act"] = 0.0
	print("Flashstep: charge timers after four presses %s (three should be charging, the fourth press refused); moved %.0f px" % [str(me["charge_cds"]["flashstep"].map(func(x): return snappedf(x, 0.1))), me["body"].position.distance_to(before)])
	_save("abilities_bar")
	# 2. Lantern Volley: hops back, then three lantern balls in a spread.
	me["body"].position = foe["body"].position + Vector2(-70, 0)
	me["act"] = 0.0
	me["cds"]["lantern_volley"] = 0.0
	var p0: Vector2 = me["body"].position
	arena.cast(1)
	await _frames(6)
	var balls := 0
	for e in arena._effects:
		if e["kind"] == "fireball" and e["owner"] == 0:
			balls += 1
	print("Lantern Volley: hopped %.0f px back, %d lantern balls in the air" % [p0.distance_to(me["body"].position), balls])
	_save("abilities_volley")
	await _frames(30)
	# 3. Lantern Lunge: lands from 75 px (in reach at the end), misses from 130 px.
	for d in [75.0, 130.0]:
		me["body"].position = foe["body"].position + Vector2(-d, 0)
		me["cds"]["lantern_lunge"] = 0.0
		me["act"] = 0.0
		me["windup"] = {}
		var hp: int = foe["hp"]
		arena.cast(2)
		while not me["windup"].is_empty() or me["ram_t"] > 0.0:
			await process_frame
		await _frames(2)
		if d == 75.0:
			_save("abilities_lunge_hit")
		print("Lantern Lunge from %.0f px: Rampartroot HP %d -> %d (%s)" % [d, hp, foe["hp"], "HIT" if foe["hp"] < hp else "miss"])
	# 4. The pounce basic in a live fight: count pounces the AI makes in 8 s.
	foe["stun"] = 0.0
	arena._rival = 2   # Scourmaw: no roots, so the in-and-out rhythm shows
	arena._new_match()
	me = arena._fighters[0]
	foe = arena._fighters[1]
	var pounces := 0
	var windups := 0
	var interrupted := 0
	var was := 0.0
	var in_windup := false
	var dists := []
	for k in 240:
		await process_frame
		var w: Dictionary = me["windup"]
		if not w.is_empty() and not in_windup and w["m"] == "pounce":
			windups += 1
		if in_windup and w.is_empty() and me["ram_t"] <= 0.0:
			interrupted += 1
		in_windup = not w.is_empty()
		if not w.is_empty() and w["m"] == "pounce" and w["t"] < 0.05 and pounces < windups:
			pounces = windups
			if pounces == 1:
				_save("abilities_pounce")
		was = me["ram_t"]
		if k % 15 == 0:
			dists.append(int(me["body"].position.distance_to(foe["body"].position)))
	print("Pounce vs Scourmaw: %d wind-ups, %d pounces, %d wind-ups ended without a dash, in 8 s; distance every half second %s; abilities untouched by its AI: %s" % [windups, pounces, interrupted, str(dists), str(me["cds"]["lantern_volley"] <= 0.0 and me["cds"]["lantern_lunge"] <= 0.0)])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
