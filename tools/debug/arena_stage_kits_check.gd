extends SceneTree
## Every stage its own kit; Ember Feint replaces Flashstep (Claude, 2026-10-08). The feint
## hops out of reach even with the wall at its back and leaves embers that burn the chaser;
## Kithflare rakes and spits ember shots; Sparkwick fires Wick Bolt; Tallowroot burrows and
## Rimefin dives behind the target; Cinderhide pounces.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_stage_kits_check.gd
## Stills to docs/creatures/arena-feel-2026-10-07/stagekit_*.png.

const OUT := "res://docs/creatures/arena-feel-2026-10-07/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(44)
	arena.team_size = 1
	# 1. Ember Feint in the open, then with the wall at its back.
	arena._you = 0; arena._you_stage = 2
	arena._rival = 3; arena._rival_stage = 2
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	foe["stun"] = 60.0
	for m in me["cds"]:
		me["cds"][m] = 99.0
	var floor_rect: Rect2 = arena.ARENAS[arena._arena]["floor"]
	me["body"].position = floor_rect.get_center()
	foe["body"].position = me["body"].position + Vector2(20, 0)
	var d0: float = me["body"].position.distance_to(foe["body"].position)
	var start: Vector2 = me["body"].position
	me["cds"]["ember_feint"] = 0.0
	me["act"] = 0.0
	arena.cast(0)
	await process_frame
	var inv: float = me["invuln"]
	var patches := 0
	for e in arena._effects:
		if e["kind"] == "fire_patch":
			patches += 1
	var d1: float = me["body"].position.distance_to(foe["body"].position)
	await _frames(3)
	_save("stagekit_feint")
	foe["body"].position = start
	var f_hp: int = foe["hp"]
	await _frames(36)
	print("Ember Feint (open floor): %.0f px from the enemy to %.0f px, untouchable %.2f s, %d ember patches; the enemy walked onto them and lost %d in 1.2 s" % [d0, d1, inv, patches, f_hp - foe["hp"]])
	# At the wall: the enemy stands between it and the open floor.
	me["body"].position = Vector2(floor_rect.position.x + 2.0, floor_rect.get_center().y)
	foe["body"].position = me["body"].position + Vector2(20, 0)
	foe["stun"] = 60.0
	me["cds"]["ember_feint"] = 0.0
	me["act"] = 0.0
	arena.cast(0)
	await process_frame
	print("Ember Feint (back to the wall): hopped %.0f px and now stands %.0f px from the enemy" % [me["body"].position.distance_to(Vector2(floor_rect.position.x + 2.0, floor_rect.get_center().y)), me["body"].position.distance_to(foe["body"].position)])
	await _frames(3)
	_save("stagekit_feint_wall")
	# 2. Kithflare: Rake basic, Ember Feint and Ember Shot.
	arena._you_stage = 0
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	foe["stun"] = 60.0
	for m in me["cds"]:
		me["cds"][m] = 99.0
	me["cds"]["fireball"] = 0.0
	me["act"] = 0.0
	arena.cast(1)
	while not me["windup"].is_empty():
		await process_frame
	var shots := 0
	for e in arena._effects:
		if e["kind"] == "fireball" and e["owner"] == 0:
			shots += 1
	print("Kithflare: basic %s; abilities %s; Ember Shot fired %d shot(s)" % [arena.MOVES[me["kit"][0]]["name"], str(me["abilities"].map(func(m): return arena.MOVES[m]["name"])), shots])
	_save("stagekit_kithflare")
	# 3. Sparkwick: Wick Bolt and Lantern Charge.
	arena._you_stage = 1
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	foe["stun"] = 60.0
	for m in me["cds"]:
		me["cds"][m] = 99.0
	me["cds"]["wick_bolt"] = 0.0
	me["act"] = 0.0
	var f_hp2: int = foe["hp"]
	arena.cast(1)
	while not me["windup"].is_empty():
		await process_frame
	await _frames(8)
	print("Sparkwick: abilities %s, passive %s; Wick Bolt took the enemy %d->%d" % [str(me["abilities"].map(func(m): return arena.MOVES[m]["name"])), me["passive"], f_hp2, foe["hp"]])
	# 4. Tallowroot burrows behind the target; Rimefin dives.
	for pair in [[1, "burrow"], [2, "dive"]]:
		arena._you = pair[0]; arena._you_stage = 0
		arena._new_match()
		await _frames(3)
		me = arena._fighters[0]
		foe = arena._fighters[1]
		foe["stun"] = 60.0
		for m in me["cds"]:
			me["cds"][m] = 99.0
		me["body"].position = foe["body"].position + Vector2(-100, 0)
		me["cds"][pair[1]] = 0.0
		me["act"] = 0.0
		arena.cast(1)
		var hid := false
		for k in 40:
			await process_frame
			if me["hidden"]:
				hid = true
		var rel: Vector2 = me["body"].position - foe["body"].position
		print("%s %s: went under (%s) and came up %.0f px from the target on its far side (%s)" % [me["name"], arena.MOVES[pair[1]]["name"], "yes" if hid else "no", rel.length(), "yes" if rel.x > 0 else "no"])
	# 5. Cinderhide pounces; and an AI 1v1 Stormwick against Rampartroot counting feints.
	arena._you = 3; arena._you_stage = 0
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	print("Cinderhide: basic %s; abilities %s" % [arena.MOVES[me["kit"][0]]["name"], str(me["abilities"].map(func(m): return arena.MOVES[m]["name"]))])
	arena.auto_you = true
	arena._you = 0; arena._you_stage = 2
	arena._rival = 1; arena._rival_stage = 2
	arena._new_match()
	me = arena._fighters[0]
	var feints := 0
	var inv_was := false
	var frames := 0
	while arena._winner < 0 and frames < 3000:
		await process_frame
		frames += 1
		var inv_now: bool = me["invuln"] > 0.0 and me["tackle"].is_empty()
		if inv_now and not inv_was:
			feints += 1
		inv_was = inv_now
	print("AI 1v1 Stormwick vs Rampartroot: %s after %.0f s; Stormwick feinted %d times; dealt %d, took %d" % [arena._fighters[arena._winner]["name"] if arena._winner >= 0 else "draw", frames / 30.0, feints, me["dealt"], me["max_hp"] - me["hp"]])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
