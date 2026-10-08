extends SceneTree
## The Punchybuns line in the arena (Claude, 2026-10-08): Star Guard shields the most hurt
## ally, Guardian softens blows on allies beside it, Counter Jab dashes to the ally in trouble
## and punches the enemy off, Static Dance charges a stunning jab and hastes allies, and
## Starshield shields and cleanses the team, throws enemies out of the star and leaves a star
## field where allies mend. A stage 1 Punchybun has two abilities and no signature.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_protector_check.gd
## Stills to docs/creatures/arena-starward-2026-10-08/.

const OUT := "res://docs/creatures/arena-starward-2026-10-08/"
var arena: Node2D

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(321)
	# The three stages beside Ironvent.
	arena.team_size = 1
	arena._rival = 3; arena._rival_stage = 2
	for stage in 3:
		arena._you = 6; arena._you_stage = stage
		arena._new_match()
		await _frames(8)
		_save("line_stage%d" % (stage + 1))
	# 1. A 3v3 with Starward leading; everyone held; one ally hurt with an enemy on it.
	arena.team_size = 3
	arena._you_stage = 2
	arena._new_match()
	await _frames(5)
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
	me["stun"] = 0.0
	for m in me["cds"]:
		me["cds"][m] = 99.0
	var at: Vector2 = me["body"].position
	var a: int = allies[0]
	var b: int = allies[1]
	arena._fighters[a]["body"].position = at + Vector2(90, 0)
	arena._fighters[a]["hp"] = int(arena._fighters[a]["max_hp"] * 0.4)
	arena._fighters[enemies[0]]["body"].position = at + Vector2(112, 4)
	arena._fighters[b]["body"].position = at + Vector2(0, 30)
	arena._fighters[enemies[1]]["body"].position = at + Vector2(-60, -40)
	arena._fighters[enemies[2]]["body"].position = at + Vector2(140, 50)
	# Star Guard goes on the hurt ally; a blow on it is absorbed.
	me["cds"]["star_guard"] = 0.0
	me["act"] = 0.0
	arena.cast(1)
	await _frames(2)
	var sh: int = arena._fighters[a]["shield"]
	var a_hp: int = arena._fighters[a]["hp"]
	arena._hurt(a, 20, Vector2(1, 0), enemies[0])
	print("Star Guard: shield %d on the hurt ally; a 20 blow left its HP %d->%d and the shield at %d" % [sh, a_hp, arena._fighters[a]["hp"], arena._fighters[a]["shield"]])
	_save("star_guard")
	# Guardian: the ally beside Starward takes less.
	var b_hp: int = arena._fighters[b]["hp"]
	arena._hurt(b, 20, Vector2(1, 0), enemies[0])
	print("Guardian: a 20 blow on the ally beside Starward took %d" % [b_hp - arena._fighters[b]["hp"]])
	# Counter Jab: dash to the hurt ally, punch the enemy off it.
	me["cds"]["counter_jab"] = 0.0
	me["act"] = 0.0
	var e_hp: int = arena._fighters[enemies[0]]["hp"]
	var e_pos: Vector2 = arena._fighters[enemies[0]]["body"].position
	arena.cast(2)
	await _frames(8)
	print("Counter Jab: Starward now %.0f px from the hurt ally; the enemy on it took %d and was thrown %.0f px" % [me["body"].position.distance_to(arena._fighters[a]["body"].position), e_hp - arena._fighters[enemies[0]]["hp"], arena._fighters[enemies[0]]["body"].position.distance_to(e_pos)])
	_save("counter_jab")
	# Static Dance, then a charged jab on the close enemy.
	me["cds"]["static_dance"] = 0.0
	me["act"] = 0.0
	arena.cast(0)
	await _frames(2)
	var hasted: int = 0
	for j in allies:
		if arena._fighters[j]["haste"] > 0.0:
			hasted += 1
	arena._fighters[enemies[0]]["body"].position = me["body"].position + Vector2(18, 0)
	arena._fighters[enemies[0]]["stun"] = 0.0
	e_hp = arena._fighters[enemies[0]]["hp"]
	var cold: int = arena._dmg("jab", 0, enemies[0])
	arena._fire(0, "jab", enemies[0])
	await process_frame
	print("Static Dance: charged %.1f s, %d allies hasted; the charged jab did %d (a cold jab is %d) and held the enemy %.2f s" % [me["charged"] + 0.07, hasted, e_hp - arena._fighters[enemies[0]]["hp"], cold, arena._fighters[enemies[0]]["stun"]])
	# 2. Starshield: an ally Glassed and rooted, enemies inside the star, then the field.
	for j in enemies:
		arena._fighters[j]["stun"] = 60.0   # held again (the jab test freed one, and its AI fired Furnace Roar over the field still)
		arena._fighters[j]["meter"] = 0
	arena._fighters[a]["glassed"] = 3.0
	arena._fighters[a]["rooted"] = 3.0
	arena._fighters[a]["body"].position = me["body"].position + Vector2(-30, 10)
	arena._fighters[enemies[1]]["body"].position = me["body"].position + Vector2(40, -10)
	arena._fighters[enemies[2]]["body"].position = me["body"].position + Vector2(130, 0)
	var ally_hp: int = arena._fighters[a]["hp"]
	var near_pos: Vector2 = arena._fighters[enemies[1]]["body"].position
	me["meter"] = 100
	arena.signature(0)
	while arena._sig.active and arena._sig._t < 1.3 + 0.6:
		await process_frame
	_save("starshield_forming")
	while arena._sig.active and arena._sig._t < 1.3 + 0.85:
		await process_frame
	_save("starshield_snap")
	while arena._sig.active:
		await process_frame
	await _frames(2)
	var fields := 0
	for e in arena._effects:
		if e["kind"] == "star_field":
			fields += 1
	var shields := 0
	for j in [0] + allies:
		if arena._fighters[j]["shield"] > 0:
			shields += 1
	print("Starshield: %d of 3 allies shielded (%d each); the hurt ally's glass %.1f and roots %.1f (cleansed); the enemy inside the star was thrown %.0f px (Repelled: %s); the enemy outside it was not moved (%s); %d star field" % [
		shields, me["shield"], arena._fighters[a]["glassed"], arena._fighters[a]["rooted"], arena._fighters[enemies[1]]["body"].position.distance_to(near_pos), "yes" if arena._fighters[enemies[1]]["body"].position.distance_to(me["body"].position) > 60.0 else "no", "stayed" if arena._fighters[enemies[2]]["body"].position.distance_to(me["body"].position) > 120.0 else "moved", fields])
	await _frames(60)
	print("Star field: the hurt ally standing in it went %d -> %d HP in 2 s" % [ally_hp, arena._fighters[a]["hp"]])
	_save("star_field")
	# 3. A stage 1 Punchybun: two abilities, no meter.
	arena.team_size = 1
	arena._you_stage = 0
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	arena._hurt(0, 10, Vector2(1, 0), 1)
	print("Punchybun (stage 1): %d abilities, meter after a hit %d" % [me["abilities"].size(), me["meter"]])
	# 4. AI 3v3 with Starward: how often it guards; and an AI 1v1 against Rampartroot.
	arena.auto_you = true
	arena.team_size = 3
	arena._you_stage = 2
	arena._rival = 1
	arena._new_match()
	me = arena._fighters[0]
	var guards := 0
	var counters := 0
	var frames := 0
	var was_pos: Vector2 = me["body"].position
	while arena._winner < 0 and frames < 2400:
		var sh_before: Array = arena._fighters.map(func(f): return f["shield"])
		await process_frame
		frames += 1
		for j in arena._fighters.size():
			if arena._fighters[j]["team"] == 0 and arena._fighters[j]["shield"] > sh_before[j]:
				guards += 1
		if me["body"].position.distance_to(was_pos) > 40.0:
			counters += 1
		was_pos = me["body"].position
		if frames == 240:
			_save("match_3v3")
	print("AI 3v3 vs the Rampartroot line: %s after %.0f s; shields raised on the team %d times; Starward dashed %d times" % [("your team" if arena._fighters[arena._winner]["team"] == 0 else "the rival team") if arena._winner >= 0 else "draw", frames / 30.0, guards, counters])
	arena.team_size = 1
	arena._new_match()
	me = arena._fighters[0]
	frames = 0
	while arena._winner < 0 and frames < 3600:
		await process_frame
		frames += 1
	print("AI 1v1 vs Rampartroot: %s after %.0f s; dealt %d, took %d" % [arena._fighters[arena._winner]["name"] if arena._winner >= 0 else "draw", frames / 30.0, me["dealt"], me["max_hp"] - me["hp"]])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
