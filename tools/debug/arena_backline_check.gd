extends SceneTree
## Oxbowarchon as a backline railgun, kits for every stage, signatures only for finals
## (Claude, 2026-10-08): Rail Shot pierces everything on its line (harder from far), Rail
## Recoil vaults away untouchable, Vent Blast throws back and smoulders, a stage 1 form has
## two abilities and no signature or meter, and an AI Oxbowarchon keeps its distance.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_backline_check.gd
## Stills to docs/creatures/arena-oxbowarchon-2026-10-08/backline_*.png.

const OUT := "res://docs/creatures/arena-oxbowarchon-2026-10-08/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(123)
	# 1. Rail Shot through two enemies on one line (3v3 against the Ironvent line's team).
	arena.team_size = 3
	arena._you = 5; arena._you_stage = 2
	arena._rival = 3; arena._rival_stage = 2
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
	for m in me["cds"]:
		me["cds"][m] = 99.0
	var at: Vector2 = me["body"].position
	arena._fighters[enemies[0]]["body"].position = at + Vector2(80, 0)
	arena._fighters[enemies[1]]["body"].position = at + Vector2(150, 2)
	arena._fighters[enemies[2]]["body"].position = at + Vector2(100, 60)
	arena.player_target = enemies[0]
	var hp: Array = arena._fighters.map(func(f): return f["hp"])
	me["cds"]["rail_shot"] = 0.0
	me["act"] = 0.0
	arena.cast(0)
	await _frames(8)
	_save("backline_rail_telegraph")
	while not me["windup"].is_empty():
		await process_frame
	await _frames(2)
	_save("backline_rail")
	print("Rail Shot: the enemy on the line at 80 px %d->%d, the one behind it at 150 px %d->%d (far bonus), the one off the line %d->%d; Oxbowarchon moved %.0f px during the wind-up and recoil" % [
		hp[enemies[0]], arena._fighters[enemies[0]]["hp"], hp[enemies[1]], arena._fighters[enemies[1]]["hp"], hp[enemies[2]], arena._fighters[enemies[2]]["hp"], at.distance_to(me["body"].position)])
	# 2. Rail Recoil away from a close enemy.
	at = me["body"].position
	arena._fighters[enemies[0]]["body"].position = at + Vector2(20, 0)
	var e_hp: int = arena._fighters[enemies[0]]["hp"]
	me["cds"]["rail_recoil"] = 0.0
	me["act"] = 0.0
	arena.cast(2)
	await process_frame
	var hop: float = at.distance_to(me["body"].position)
	var inv: float = me["invuln"]
	await _frames(6)
	_save("backline_recoil")
	print("Rail Recoil: hopped %.0f px away (untouchable %.2f s); the close enemy took %d and now stands %.0f px off" % [hop, inv, e_hp - arena._fighters[enemies[0]]["hp"], arena._fighters[enemies[0]]["body"].position.distance_to(me["body"].position)])
	# 3. A stage 1 form: two abilities, no signature, no meter.
	arena.team_size = 1
	arena._you_stage = 0
	arena._rival = 1; arena._rival_stage = 2
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	arena._fighters[1]["stun"] = 60.0
	arena._hurt(0, 10, Vector2(1, 0), 1)
	var meter_after_hit: int = me["meter"]
	me["meter"] = 100
	arena.signature(0)
	await process_frame
	print("Preostmar (stage 1): %d abilities, meter after a hit %d, signature with a full meter: %s" % [me["abilities"].size(), meter_after_hit, "fired (WRONG)" if arena._sig.active else "refused"])
	_save("backline_stage1_bar")
	# 4. Vent Blast from Clinkerhide into a held Rampartroot in front of it.
	arena._you = 3; arena._you_stage = 1
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	foe["stun"] = 60.0
	foe["body"].position = me["body"].position + Vector2(30, 0)
	for m in me["cds"]:
		me["cds"][m] = 99.0
	me["cds"]["vent_blast"] = 0.0
	me["act"] = 0.0
	var f_hp: int = foe["hp"]
	var before: Vector2 = foe["body"].position
	arena.cast(2)
	while not me["windup"].is_empty():
		await process_frame
	await _frames(10)
	print("Vent Blast (Clinkerhide): the target took %d, is smouldering %.1f s and was thrown %.0f px; Clinkerhide has %d abilities and passive '%s'" % [f_hp - foe["hp"], foe["smoulder"], foe["body"].position.distance_to(before), me["abilities"].size(), me["passive"]])
	_save("backline_vent_blast")
	# 5. AI 1v1: Oxbowarchon against Ironvent, counting rail shots and recoils and its distance.
	arena.auto_you = true
	arena._you = 5; arena._you_stage = 2
	arena._rival = 3; arena._rival_stage = 2
	arena._new_match()
	me = arena._fighters[0]
	var shots := 0
	var recoils := 0
	var was := false
	var dist_sum := 0.0
	var frames := 0
	var inv_was := false
	while arena._winner < 0 and frames < 3600:
		await process_frame
		frames += 1
		var w: Dictionary = me["windup"]
		var now: bool = not w.is_empty() and w["m"] == "rail_shot"
		if now and not was:
			shots += 1
		was = now
		var inv_now: bool = me["invuln"] > 0.0
		if inv_now and not inv_was:
			recoils += 1
		inv_was = inv_now
		dist_sum += me["body"].position.distance_to(arena._fighters[1]["body"].position)
		if frames == 200:
			_save("backline_match")
	print("Match vs Ironvent: %s after %.0f s; the AI Oxbowarchon fired %d Rail Shots, vaulted %d times, and stood %.0f px from Ironvent on average" % [arena._fighters[arena._winner]["name"] if arena._winner >= 0 else "draw", frames / 30.0, shots, recoils, dist_sum / maxf(1, frames)])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
