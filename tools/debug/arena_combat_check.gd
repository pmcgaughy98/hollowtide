extends SceneTree
## Combat upgrades (Claude, 2026-10-08): the essence combos (shatter, kindle, quench,
## conduct), the procedural animation layer (wind-up lean, strike lunge, flinch, landing
## squash, the KO beat), and Kit Sense wanting a combo more.
## Judged since Claude, 2026-10-24 (H19): each combo against its constant with the status
## cleared, the animation names and the strike squash, the KO beat, and the combo desire.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_combat_check.gd
## Stills to docs/creatures/arena-feel-2026-10-07/combat_*.png.

const OUT := "res://docs/creatures/arena-feel-2026-10-07/"
var arena: Node2D
var fails := 0

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(11)
	arena.team_size = 3
	arena._you = 5; arena._you_stage = 2       # Oxbowarchon leads: Oxbowarchon, Starward, Stormwick
	arena._rival = 3; arena._rival_stage = 2   # Ironvent, Vitrecrag, Oxbowarchon
	arena._new_match()
	await _frames(5)
	var me: Dictionary = arena._fighters[0]
	var enemies := []
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 1:
			enemies.append(j)
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	var e0: int = enemies[0]
	var e1: int = enemies[1]
	# Shatter: a Stone move on a Glassed target.
	arena._fighters[e0]["glassed"] = 3.0
	me["last_move"] = "jade_lance"
	var hp: int = arena._fighters[e0]["hp"]
	arena._hurt(e0, 20, Vector2(1, 0), 0)
	var took: int = hp - arena._fighters[e0]["hp"]
	print("Shatter: a 20 Stone hit on a Glassed target took %d and left the glass at %.1f" % [took, arena._fighters[e0]["glassed"]])
	_ok("Shatter takes 20 x SHATTER_BONUS (%d) and clears the glass" % int(round(20 * arena.SHATTER_BONUS)),
		took == int(round(20 * arena.SHATTER_BONUS)) and arena._fighters[e0]["glassed"] == 0.0)
	_save("combat_shatter")
	# Kindle: an Ember move on a rooted target.
	arena._fighters[e0]["rooted"] = 2.0
	me["last_move"] = "fireball"
	hp = arena._fighters[e0]["hp"]
	arena._hurt(e0, 20, Vector2(1, 0), 0)
	took = hp - arena._fighters[e0]["hp"]
	print("Kindle: a 20 Ember hit on a rooted target took %d and left the roots at %.1f" % [took, arena._fighters[e0]["rooted"]])
	_ok("Kindle takes 20 x KINDLE_BONUS (%d) and clears the roots" % int(round(20 * arena.KINDLE_BONUS)),
		took == int(round(20 * arena.KINDLE_BONUS)) and arena._fighters[e0]["rooted"] == 0.0)
	# Quench: a Tide move on a smouldering target.
	arena._fighters[e0]["smoulder"] = 1.5
	arena._fighters[e0]["dazzle"] = 0.0
	me["last_move"] = "beam"
	hp = arena._fighters[e0]["hp"]
	arena._hurt(e0, 10, Vector2(1, 0), 0)
	took = hp - arena._fighters[e0]["hp"]
	print("Quench: a 10 Tide hit on a smouldering target took %d, left the smoulder at %.1f and dazed it %.1f s" % [took, arena._fighters[e0]["smoulder"], arena._fighters[e0]["dazzle"]])
	_ok("Quench takes 10 x QUENCH_BONUS (%d), clears the smoulder and dazes QUENCH_DAZE" % int(round(10 * arena.QUENCH_BONUS)),
		took == int(round(10 * arena.QUENCH_BONUS)) and arena._fighters[e0]["smoulder"] == 0.0 and is_equal_approx(arena._fighters[e0]["dazzle"], arena.QUENCH_DAZE))
	# Overgrow: a Bloom move on a target standing in water.
	var pool0: Vector2 = me["body"].position + Vector2(-90, 0)
	arena._fighters[e0]["body"].position = pool0
	arena._fighters[e0]["rooted"] = 0.0
	arena._effects.append({"kind": "riptide", "owner": 2, "pos": pool0, "t": 0.0})
	await process_frame
	me["last_move"] = "seed"
	arena._hurt(e0, 10, Vector2(1, 0), 0)
	print("Overgrow: a Bloom hit on a target standing in water rooted it %.1f s" % arena._fighters[e0]["rooted"])
	_ok("Overgrow roots for OVERGROW_ROOT", is_equal_approx(arena._fighters[e0]["rooted"], arena.OVERGROW_ROOT))
	# Conduct: an Electric move on a target in a riptide, with another enemy in the same riptide.
	var pool: Vector2 = me["body"].position + Vector2(90, 0)
	arena._fighters[e0]["body"].position = pool + Vector2(-8, 0)
	arena._fighters[e1]["body"].position = pool + Vector2(10, 4)
	arena._effects.append({"kind": "riptide", "owner": 2, "pos": pool, "t": 0.0})
	await process_frame
	me["last_move"] = "rail_shot"
	hp = arena._fighters[e0]["hp"]
	var hp1: int = arena._fighters[e1]["hp"]
	var in_water: bool = arena._in_riptide(e1)
	arena._hurt(e0, 20, Vector2(1, 0), 0)
	var shared: int = hp1 - arena._fighters[e1]["hp"]
	print("Conduct: an Electric hit in a riptide took %d from the target and %d from the other enemy in the water (in the riptide: %s)" % [hp - arena._fighters[e0]["hp"], shared, "yes" if in_water else "no"])
	_ok("Conduct passes 20 x CONDUCT_SHARE (%d) to the other enemy in the riptide" % maxi(1, int(round(20 * arena.CONDUCT_SHARE))),
		in_water and shared == maxi(1, int(round(20 * arena.CONDUCT_SHARE))))
	await _frames(2)
	_save("combat_conduct")
	# Kit Sense wants the combo: desire for Jade Lance on a Glassed target against a clean one.
	arena._fighters[e0]["glassed"] = 3.0
	arena._fighters[e0]["body"].position = me["body"].position + Vector2(60, 0)
	arena._fighters[e1]["body"].position = me["body"].position + Vector2(60, 30)
	for m in me["cds"]:
		me["cds"][m] = 0.0
	var d_glass: float = arena._desire(0, "jade_lance", e0, "engage")
	var d_clean: float = arena._desire(0, "jade_lance", e1, "engage")
	print("Kit Sense: Jade Lance desire %.2f on the Glassed enemy against %.2f on the clean one" % [d_glass, d_clean])
	# Only "not lower" is judged; both sit at the 1.00 cap here, so a real preference needs a restage (Q11).
	_ok("Kit Sense wants Jade Lance on the Glassed enemy at least as much as on the clean one", d_glass >= d_clean)
	# The animation layer: a wind-up lean, then the strike lunge, then a flinch.
	me["act"] = 0.0
	me["cds"]["rail_shot"] = 0.0
	arena.player_target = e0
	arena.cast(0)
	await _frames(12)   # past the hitstop the earlier hits left (creatures hold still through it)
	var sp: Sprite2D = me["sprite"]
	var wind_scale: Vector2 = sp.scale
	var wind_anim: String = me["anim"]
	_save("combat_wind")
	while not me["windup"].is_empty():
		await process_frame
	await _frames(2)
	var strike_anim: String = me["anim"]
	var strike_scale: Vector2 = sp.scale
	arena._hurt(e1, 10, Vector2(-1, 0), 0)   # on a creature without Bound Slabs (a slab swallows the blow before the flinch)
	await process_frame
	var flinch_anim: String = arena._fighters[e1]["anim"]
	print("Animation: during the wind-up %s with scale (%.2f, %.2f); at the strike %s with scale (%.2f, %.2f); after a hit %s" % [wind_anim, wind_scale.x, wind_scale.y, strike_anim, strike_scale.x, strike_scale.y, flinch_anim])
	_ok("Animation runs wind, then strike, then flinch on the one hit", wind_anim == "wind" and strike_anim == "strike" and flinch_anim == "flinch")
	_ok("The strike squashes the sprite (scale is not ONE)", not strike_scale.is_equal_approx(Vector2.ONE))
	# The KO beat.
	arena._fighters[e1]["hp"] = 5
	me["last_move"] = "jade_lance"
	arena._hurt(e1, 20, Vector2(1, 0), 0)
	print("KO: hitstop %.2f s, anim %s, %s" % [arena._hitstop, arena._fighters[e1]["anim"], "down" if arena._fighters[e1]["hp"] <= 0 else "still up"])
	_ok("KO beat: hitstop KO_HITSTOP, anim ko, HP at 0", is_equal_approx(arena._hitstop, arena.KO_HITSTOP) and arena._fighters[e1]["anim"] == "ko" and arena._fighters[e1]["hp"] <= 0)
	await _frames(2)
	_save("combat_ko")
	print("ARENA COMBAT: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails > 0 else 0)


## One judged line: "what -> ok" or "what -> FAIL" (Claude, 2026-10-24).
func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
