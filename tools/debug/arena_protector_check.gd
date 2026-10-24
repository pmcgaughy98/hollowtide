extends SceneTree
## The Punchybuns line in the arena (Claude, 2026-10-08): Star Guard shields the most hurt
## ally, Guardian softens blows on allies beside it, Counter Jab dashes to the ally in trouble
## and punches the enemy off, Static Dance charges a stunning jab and hastes allies, and
## Starshield shields and cleanses the team, throws enemies out of the star and leaves a star
## field where allies mend. A stage 1 Punchybun has two abilities and no signature.
## Verdicts (Claude, 2026-10-24, factory pass 4): every step ends "-> ok" or "-> WRONG". The AI
## 3v3 now runs past MATCH_SECONDS so it ends on a knockout or on points, and its result line
## reads the winning team (the winner is a team number, not a fighter).
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
		_hold(f)
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
	_check("Star Guard", sh > 0 and arena._fighters[a]["hp"] == a_hp and arena._fighters[a]["shield"] == sh - 20,
		"shield %d on the hurt ally; a 20 blow left its HP %d->%d and the shield at %d" % [sh, a_hp, arena._fighters[a]["hp"], arena._fighters[a]["shield"]])
	_save("star_guard")
	# Guardian: the ally beside Starward takes less. How much less has no agreed check yet (Q11),
	# so this line is printed, not judged. On 2026-10-24 no form carried the "guardian" passive
	# (Starward's is "chain"), so the blow lands whole; the line says which.
	var b_hp: int = arena._fighters[b]["hp"]
	arena._hurt(b, 20, Vector2(1, 0), enemies[0])
	print("Guardian (printed only): a 20 blow on the ally beside Starward took %d; Starward's passive is %s" % [b_hp - arena._fighters[b]["hp"], me["passive"]])
	# Counter Jab: dash to the hurt ally, punch the enemy off it.
	me["cds"]["counter_jab"] = 0.0
	me["act"] = 0.0
	var e_hp: int = arena._fighters[enemies[0]]["hp"]
	var e_pos: Vector2 = arena._fighters[enemies[0]]["body"].position
	arena.cast(2)
	await _frames(8)
	var to_ally: float = me["body"].position.distance_to(arena._fighters[a]["body"].position)
	_check("Counter Jab", to_ally < 90.0 and e_hp - arena._fighters[enemies[0]]["hp"] > 0,
		"Starward now %.0f px from the hurt ally (was 90); the enemy on it took %d and was thrown %.0f px" % [to_ally, e_hp - arena._fighters[enemies[0]]["hp"], arena._fighters[enemies[0]]["body"].position.distance_to(e_pos)])
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
	var charged_hit: int = e_hp - arena._fighters[enemies[0]]["hp"]
	_check("Static Dance", hasted > 0 and charged_hit > cold and arena._fighters[enemies[0]]["stun"] > 0.0,
		"charged %.1f s, %d allies hasted; the charged jab did %d (a cold jab is %d) and held the enemy %.2f s" % [me["charged"] + 0.07, hasted, charged_hit, cold, arena._fighters[enemies[0]]["stun"]])
	# 2. Starshield: an ally Glassed and rooted, enemies inside the star, then the field.
	for j in enemies:
		_hold(arena._fighters[j])   # held again (the jab test freed one, and its AI fired Furnace Roar over the field still)
		arena._fighters[j]["meter"] = 0
	arena._fighters[a]["glassed"] = 3.0
	arena._fighters[a]["rooted"] = 3.0
	arena._fighters[a]["body"].position = me["body"].position + Vector2(-30, 10)
	arena._fighters[enemies[1]]["body"].position = me["body"].position + Vector2(40, -10)
	arena._fighters[enemies[2]]["body"].position = me["body"].position + Vector2(130, 0)
	var ally_hp: int = arena._fighters[a]["hp"]
	var near_pos: Vector2 = arena._fighters[enemies[1]]["body"].position
	var far_pos: Vector2 = arena._fighters[enemies[2]]["body"].position
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
	var near_now: float = arena._fighters[enemies[1]]["body"].position.distance_to(me["body"].position)
	var far_moved: float = arena._fighters[enemies[2]]["body"].position.distance_to(far_pos)
	_check("Starshield shields", shields == 3 and me["shield"] == arena.STARSHIELD_SHIELD,
		"%d of 3 allies shielded (%d each, rule %d)" % [shields, me["shield"], arena.STARSHIELD_SHIELD])
	print("Starshield cleanse (printed): the hurt ally's glass %.1f and roots %.1f" % [arena._fighters[a]["glassed"], arena._fighters[a]["rooted"]])
	_check("Starshield throw", near_now > arena.STARSHIELD_RADIUS and far_moved < 1.0 and fields == 1,
		"the enemy inside the star was thrown %.0f px and now stands %.0f px out (star %.0f); the enemy outside it moved %.0f px; %d star field" % [
		arena._fighters[enemies[1]]["body"].position.distance_to(near_pos), near_now, arena.STARSHIELD_RADIUS, far_moved, fields])
	await _frames(60)
	_check("Star field", arena._fighters[a]["hp"] > ally_hp, "the hurt ally standing in it went %d -> %d HP in 2 s" % [ally_hp, arena._fighters[a]["hp"]])
	_save("star_field")
	# 3. A stage 1 Punchybun: two abilities, no meter.
	arena.team_size = 1
	arena._you_stage = 0
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	arena._hurt(0, 10, Vector2(1, 0), 1)
	_check("Punchybun (stage 1)", me["abilities"].size() == 2 and me["meter"] == 0, "%d abilities, meter after a hit %d" % [me["abilities"].size(), me["meter"]])
	# 4. AI 3v3 with Starward: how often it guards; and an AI 1v1 against Rampartroot. The 3v3
	# ends on points at MATCH_SECONDS of match time, but hitstop pauses that clock and every
	# signature's opening freezes it (on 2026-10-24 a 180 s budget ran out short of 120 s of
	# match time, a draw; the full match took 204 s), so the budget is three times MATCH_SECONDS.
	arena.auto_you = true
	arena.team_size = 3
	arena._you_stage = 2
	arena._rival = 1
	arena._new_match()
	me = arena._fighters[0]
	var guards := 0
	var counters := 0
	var frames := 0
	var budget: int = int(arena.MATCH_SECONDS * 30.0) * 3
	var was_pos: Vector2 = me["body"].position
	while arena._winner < 0 and frames < budget:
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
	_check("AI 3v3 vs the Rampartroot line", arena._winner >= 0 and guards > 0,
		"%s after %.0f s (%.0f s of match time)%s; shields raised on the team %d times; Starward dashed %d times" % [("your team" if arena._winner == 0 else "the rival team") if arena._winner >= 0 else "draw", frames / 30.0, arena._clock, " on points" if arena._on_points else "", guards, counters])
	arena.team_size = 1
	arena._new_match()
	me = arena._fighters[0]
	frames = 0
	while arena._winner < 0 and frames < 3600:
		await process_frame
		frames += 1
	print("AI 1v1 vs Rampartroot: %s after %.0f s; dealt %d, took %d" % [arena._fighters[arena._winner]["name"] if arena._winner >= 0 else "draw", frames / 30.0, me["dealt"], me["max_hp"] - me["hp"]])
	quit()


## Holds fighter f still for a staged step: a long stun, and no charm or dodge to break it
## (Beads cleanse a stun; Claude, 2026-10-24).
func _hold(f: Dictionary) -> void:
	f["stun"] = 60.0
	f["charm_cd"] = 99.0
	f["dodge_cd"] = 99.0


func _check(label: String, ok: bool, detail: String) -> void:
	print("%s: %s -> %s" % [label, detail, "ok" if ok else "WRONG"])


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
