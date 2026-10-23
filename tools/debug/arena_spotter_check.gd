extends SceneTree
## The Dustkite line in the arena (Claude, 2026-10-09): Dustkite, Waywhistle, Highsignal, the
## Spotter. Stage kits, Whistle Dart, Signal Mark (team hits land harder, Stormwick teleports
## to it), Decoy Call (the enemy spends its dodge on air), Vantage (perched, melee cannot reach),
## the Spotter passive, High Signal, then AI fights.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_spotter_check.gd
## Stills to docs/creatures/arena-dustkite-2026-10-09/.

const OUT := "res://docs/creatures/arena-dustkite-2026-10-09/"
const LINE := 9
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(59)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena.poll_input = false
	arena.auto_you = true
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
	# 2. Whistle Dart and Signal Mark on stage 1.
	arena._you_stage = 0
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	foe["dodge_cd"] = 99.0; foe["charm_cd"] = 99.0
	foe["body"].position = me["body"].position + Vector2(70, 0)
	arena.player_target = 1
	var hp: int = foe["hp"]
	arena._fire(0, "whistle_dart", 1)
	await _frames(14)
	var dart: int = hp - foe["hp"]
	me["act"] = 0.0
	arena._fire(0, "signal_mark", 1)
	hp = foe["hp"]
	arena._hurt(1, 20, Vector2(1, 0), 0)
	var on_mark: int = hp - foe["hp"]
	foe["marked"] = 0.0
	hp = foe["hp"]
	arena._hurt(1, 20, Vector2(1, 0), 0)
	print("Whistle Dart took %d. Signal Mark: a 20 hit on the marked enemy took %d, the same hit unmarked took %d" % [dart, on_mark, hp - foe["hp"]])
	_save("mark")
	# 3. Decoy Call: the enemy, free, steps out of nothing and spends its dodge.
	foe["stun"] = 0.0
	foe["dodge_cd"] = 0.0; foe["dash_cd"] = 0.0
	foe["body"].position = me["body"].position + Vector2(40, 0)
	me["act"] = 0.0
	arena._fire(0, "decoy_call", 1)
	var decoy_shown: bool = not me["windup"].is_empty() and me["windup"].get("decoy", false)
	var stepped := false
	for k in 20:
		await process_frame
		if foe["dash"] > 0.0:
			stepped = true
	foe["stun"] = 60.0
	print("Decoy Call: the false telegraph %s; the enemy %s and its dodge cooldown reads %.1f s" % ["showed" if decoy_shown else "did not show (WRONG)", "stepped out of nothing" if stepped else "did not bite (a 55% call)", foe["dodge_cd"]])
	_save("decoy")
	# 4. Vantage on stage 2: up a rock, a claw cannot reach, the dart reaches further.
	arena._you_stage = 1
	arena._rival = 3   # Ironvent
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	var rk := -1
	for k in arena._rocks.size():
		if arena._rocks[k]["kind"] == "stone":
			rk = k
			break
	me["body"].position = arena._rocks[rk]["pos"] + Vector2(-30, 10)
	foe["body"].position = me["body"].position + Vector2(60, 0)   # close, so the AI keeps the perch
	for m in me["cds"]:
		me["cds"][m] = 0.0
	me["act"] = 0.0
	arena._fire(0, "vantage", 1)
	await _frames(2)
	var perched: bool = me["perched"] >= 0
	foe["body"].position = me["body"].position + Vector2(20, 8)
	foe["stun"] = 0.0
	arena.player_target = -1
	hp = me["hp"]
	arena.cast_as(1, "cinder_claw")
	await _frames(14)
	foe["stun"] = 60.0
	_save("vantage")
	var reach: bool = arena._wants(0, "whistle_dart", foe)
	foe["body"].position = me["body"].position + Vector2(150, 0)
	var far_reach: bool = arena._wants(0, "whistle_dart", foe)
	print("Vantage: %s; Ironvent's claw from 20 px took %d (melee cannot reach a perch); the dart reaches an enemy 150 px out: %s" % ["perched on a rock" if perched else "did not perch (WRONG)", hp - me["hp"], "yes" if far_reach else "no (WRONG)"])
	# 5. The Spotter passive marks the first enemy in range.
	foe["marked"] = 0.0
	me["spot_cd"] = {}
	me["perched"] = -1
	foe["body"].position = me["body"].position + Vector2(100, 0)
	await _frames(3)
	print("Spotter passive: the enemy that came within 120 px is marked %.1f s" % foe["marked"])
	# 6. High Signal on the final: everyone marked, the next ability doubled.
	arena.team_size = 3
	arena._you_stage = 2
	arena._rival = 3
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	var enemies := []
	var mine := []
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 1:
			enemies.append(j)
		else:
			mine.append(j)
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	me["meter"] = 100
	arena.signature(0)
	await _frames(75)   # the card, then the carry at 1.0 s
	var marked := 0
	for j in enemies:
		if arena._fighters[j]["marked"] > 0.0 and arena._fighters[j]["signal"] > 0:
			marked += 1
	_save("high_signal")
	var e0: Dictionary = arena._fighters[enemies[0]]
	e0["slabs"] = 0
	# The hitter must own an ability to spend the signal on. Since 2026-10-10 the second slot is
	# the Springvault line, basic-only in the arena, so take the first ally that has one.
	var helper: int = mine.filter(func(j): return j != 0 and not arena._fighters[j]["abilities"].is_empty())[0]
	var ally: Dictionary = arena._fighters[helper]
	ally["last_move"] = ally["abilities"][0]
	hp = e0["hp"]
	arena._hurt(enemies[0], 20, Vector2.ZERO, helper)
	var doubled: int = hp - e0["hp"]
	hp = e0["hp"]
	arena._hurt(enemies[0], 20, Vector2.ZERO, helper)
	print("High Signal: %d of 3 enemies marked and signalled; an ally's 20 ability hit took %d (marked x1.15, signal x2), the next %d" % [marked, doubled, hp - e0["hp"]])
	while arena._sig.active:
		await process_frame
	# 7. AI fights.
	arena.team_size = 1
	arena._rival = 0
	arena._new_match()
	await _frames(3)
	var frames := 0
	while arena._winner < 0 and frames < 2400:
		await process_frame
		frames += 1
		if frames == 240:
			_save("ai_1v1")
	print("AI 1v1 Highsignal vs Stormwick: %s after %.0f s; dealt %d, took %d" % ["Highsignal" if arena._winner == 0 else ("Stormwick" if arena._winner == 1 else "draw"), frames / 30.0, arena._fighters[0]["dealt"], arena._fighters[0]["max_hp"] - arena._fighters[0]["hp"]])
	arena.team_size = 3
	arena._rival = 4
	arena._new_match()
	await _frames(3)
	var team := []
	for f in arena._fighters:
		if f["team"] == 0:
			team.append(f["name"])
	frames = 0
	while arena._winner < 0 and frames < 2700:
		await process_frame
		frames += 1
		if frames == 360:
			_save("ai_3v3")
	print("AI 3v3 %s vs the Vitrecrag team: %s after %.0f s" % [str(team), "Highsignal's team" if arena._winner == 0 else ("the rival team" if arena._winner == 1 else "draw"), frames / 30.0])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
