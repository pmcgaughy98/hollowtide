extends SceneTree
## Vitrecrag as the Ember tank (Claude, 2026-10-08): Molten Glass erupts round Vitrecrag
## itself and Glasses every enemy in the ring (allies untouched), the glass field it leaves is
## wide, the Glassed status burns, slows and then sets hard, and Glass Guard halves blows,
## plants it and Glasses melee attackers.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_tank_check.gd
## Stills to docs/creatures/arena-feel-2026-10-07/tank_*.png.

const OUT := "res://docs/creatures/arena-feel-2026-10-07/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	arena.auto_you = true
	seed(88)
	# 1. Molten Glass in a 3v3: two enemies close, one far, an ally close.
	arena.team_size = 3
	arena._you = 4; arena._you_stage = 2
	arena._rival = 0; arena._rival_stage = 2
	arena._new_match()
	await _frames(10)
	var me: Dictionary = arena._fighters[0]
	var enemies := []
	var allies := []
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 1:
			enemies.append(j)
		elif j != 0:
			allies.append(j)
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0   # everyone else holds still; the tank fires
	var at: Vector2 = me["body"].position
	arena._fighters[enemies[0]]["body"].position = at + Vector2(34, 6)
	arena._fighters[enemies[1]]["body"].position = at + Vector2(-30, -14)
	arena._fighters[enemies[2]]["body"].position = at + Vector2(120, 0)
	arena._fighters[allies[0]]["body"].position = at + Vector2(0, 24)
	arena._fighters[allies[1]]["body"].position = at + Vector2(-20, 18)
	var hp0: Array = arena._fighters.map(func(f): return f["hp"])
	me["meter"] = 100
	arena.signature(0)
	while arena._sig.active and arena._sig._t < 1.3 + 1.1:
		await process_frame
	_save("tank_glass_rupture")
	while arena._sig.active:
		await process_frame
	await _frames(2)
	var pools := []
	var reach := 0.0
	for e in arena._effects:
		if e["kind"] == "glass_pool":
			pools.append(e)
			reach = maxf(reach, e["pos"].distance_to(at) + e["r"])
	var line := "Molten Glass: %d pools, field reaches %.0f px from Vitrecrag;" % [pools.size(), reach]
	for j in enemies:
		line += "  enemy at %.0f px %d->%d glassed %.1f s;" % [arena._fighters[j]["body"].position.distance_to(at), hp0[j], arena._fighters[j]["hp"], arena._fighters[j]["glassed"]]
	for j in allies:
		line += "  ally %d->%d glassed %.1f;" % [hp0[j], arena._fighters[j]["hp"], arena._fighters[j]["glassed"]]
	print(line)
	_save("tank_glass_field")
	# 2. The status: move the glassed enemy out of the field and watch it burn, slow, then set.
	# (Out of the field, rooted so it cannot walk back in, every move on cooldown, so the only
	# damage left is the glass itself.)
	var g: int = enemies[0]
	arena._fighters[g]["body"].position = at + Vector2(0, -70)
	arena._fighters[g]["stun"] = 0.0
	arena._fighters[g]["rooted"] = 60.0
	for m in arena._fighters[g]["cds"]:
		arena._fighters[g]["cds"][m] = 99.0
	me["stun"] = 60.0
	var hp_g: int = arena._fighters[g]["hp"]
	var set_seen := false
	var clung := 0
	var frames := 0
	while frames < 150:
		await process_frame
		frames += 1
		if arena._fighters[g]["glassed"] > 0.0:
			clung += 1
		if arena._fighters[g]["glassed"] <= 0.0 and arena._fighters[g]["stun"] > 0.0:
			set_seen = true
		if frames == 30:
			_save("tank_glassed")
	print("Glassed: the glass clung %.1f s more and burned %d HP; the enemy %s when it set (walk speed x%.2f while glassed, by rule)" % [clung / 30.0, hp_g - arena._fighters[g]["hp"], "was held" if set_seen else "was NOT held", arena.GLASSED_SLOW])
	# 3. Glass Guard against Ironvent up close.
	arena.auto_you = false
	arena.team_size = 1
	arena._rival = 3; arena._rival_stage = 2
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	foe["stun"] = 60.0
	foe["body"].position = me["body"].position + Vector2(24, 0)
	me["cds"]["glass_guard"] = 0.0
	me["act"] = 0.0
	var heat0: float = me["heat"]
	var hp_me: int = me["hp"]
	arena.cast(2)
	await process_frame
	arena._hurt(0, 20, Vector2(1, 0), 1)
	await _frames(2)
	print("Glass Guard: guarding %.1f s; a 20 blow took %d; the attacker up close is %s; kiln heat %.0f -> %.0f" % [me["guard"], hp_me - me["hp"], "Glassed" if foe["glassed"] > 0.0 else "not glassed", heat0, me["heat"]])
	_save("tank_guard")
	# 4. A full AI 1v1 against Rampartroot, the other tank.
	arena.auto_you = true
	arena._rival = 1
	arena._new_match()
	me = arena._fighters[0]
	frames = 0
	var guards := 0
	var was := false
	while arena._winner < 0 and frames < 3600:
		await process_frame
		frames += 1
		var now: bool = me["guard"] > 0.0
		if now and not was:
			guards += 1
		was = now
		if frames == 150:
			_save("tank_match")
	print("Match vs Rampartroot: %s after %.0f s; your Vitrecrag's AI guarded %d times; dealt %d, took %d" % [arena._fighters[arena._winner]["name"] if arena._winner >= 0 else "draw", frames / 30.0, guards, me["dealt"], me["max_hp"] - me["hp"]])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
