extends SceneTree
## Player-fired abilities (Claude, 2026-10-07): Stormwick's Ember Feint charges, Lantern Volley,
## the pounce basic, and the ability bar. Updated 2026-10-22: Ember Feint replaced Flashstep on
## 2026-10-08, Lantern Lunge became Lantern Tackle (arena_tackle_check), and since manual control
## your creature's basic waits for J, so the pounce count runs your side on auto.
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
	# 1. Ember Feint: two charges, each on its own 5 s timer; a third press is refused.
	var before: Vector2 = me["body"].position
	for k in 3:
		arena.cast(0)
		await _frames(2)
		me["act"] = 0.0
	var timers: Array = me["charge_cds"]["ember_feint"]
	var charging: int = timers.filter(func(x): return x > 0.0).size()
	print("Ember Feint: charge timers after three presses %s, %d charging, last refusal '%s'%s; moved %.0f px" % [str(timers.map(func(x): return snappedf(x, 0.1))), charging, arena._why, "" if charging == timers.size() and arena._why.begins_with("EMBER FEINT IN") else " (WRONG)", me["body"].position.distance_to(before)])
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
	# 3. The pounce basic in a live fight: count the pounces Stormwick's AI makes in 8 s (a reading, not a verdict).
	foe["stun"] = 0.0
	arena.auto_you = true   # manual control: your basic waits for J unless your side is on auto
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
	print("Pounce vs Scourmaw: %d wind-ups, %d pounces, %d wind-ups ended without a dash, in 8 s on auto (Kit Sense may pick abilities instead); distance every half second %s" % [windups, pounces, interrupted, str(dists)])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
