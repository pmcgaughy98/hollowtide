extends SceneTree
## Playtest fixes (Claude, 2026-10-07 night): no damage during the tackle (Thorns), Flashstep
## teleports to a mark, Rampartroot's tank kit (Tail Club, Root Snare, Root Rampart) and the
## Verdant Roar signature, and longer fights.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_rampart_check.gd
## Stills to docs/creatures/arena-feel-2026-10-07/rampart_*.png.

const OUT := "res://docs/creatures/arena-feel-2026-10-07/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(44)
	# 1. Tackle against Rampartroot: Thorns must not touch an invulnerable attacker.
	arena.team_size = 1
	arena._you = 0; arena._you_stage = 2
	arena._rival = 1; arena._rival_stage = 2
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	foe["stun"] = 60.0
	me["cds"]["pounce"] = 99.0
	foe["marked"] = 8.0
	me["cds"]["lantern_tackle"] = 0.0
	me["act"] = 0.0
	var hp0: int = me["hp"]
	arena.cast(2)
	while not me["tackle"].is_empty():
		await process_frame
	print("Tackle vs Rampartroot: my HP %d -> %d during the whole tackle (Thorns used to leak through)" % [hp0, me["hp"]])
	# 2. Flashstep teleports to a marked crate.
	var crate := -1
	for k in arena._rocks.size():
		if arena._rocks[k]["kind"] == "crate":
			crate = k
	foe["marked"] = 0.0
	arena._rocks[crate]["marked"] = 8.0
	me["act"] = 0.0
	var before: Vector2 = me["body"].position
	arena.cast(0)
	await process_frame
	print("Flashstep: moved %.0f px, now %.0f px from the marked crate, invulnerable %.2f s" % [before.distance_to(me["body"].position), me["body"].position.distance_to(arena._rocks[crate]["pos"]), me["invuln"]])
	_save("rampart_flashstep")
	# 3. Rampartroot's kit, you controlling it: Tail Club carries, Root Rampart roots and raises pillars.
	arena._you = 1; arena._rival = 0
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	foe["stun"] = 60.0
	me["cds"]["seed"] = 99.0
	foe["body"].position = me["body"].position + Vector2(24, 0)
	me["cds"]["club_slam"] = 0.0
	me["act"] = 0.0
	var fp: Vector2 = foe["body"].position
	arena.cast(0)
	while not me["windup"].is_empty():
		await process_frame
	await _frames(10)
	print("Tail Club: Stormwick carried %.0f px (slammed: %s)" % [fp.distance_to(foe["body"].position), str(foe["dazzle"] > 0.0)])
	foe["body"].position = me["body"].position + Vector2(80, 0)
	me["cds"]["root_rampart"] = 0.0
	me["act"] = 0.0
	var hp1: int = foe["hp"]
	arena.cast(2)
	while not me["windup"].is_empty():
		await process_frame
	await _frames(8)
	_save("rampart_rootrun")
	await _frames(10)
	print("Root Rampart: Stormwick HP %d -> %d, rooted %s, pillars standing %d" % [hp1, foe["hp"], str(foe["rooted"] > 0.0), arena._walls.size()])
	_save("rampart_pillars")
	# 4. Verdant Roar in a 3v3: every rival rooted, a vine field at the target.
	arena.team_size = 3
	arena._new_match()
	await _frames(30)
	me = arena._fighters[0]
	me["meter"] = 100
	arena.signature(0)
	for t in [1.3 + 0.1, 1.3 + 0.45, 1.3 + 1.1, 1.3 + 1.45]:
		while arena._sig.active and arena._sig._t < t:
			await process_frame
		_save("rampart_roar_%.2fs" % t)
		if absf(t - (1.3 + 0.45)) < 0.01:
			var rooted := 0
			for f in arena._fighters:
				if f["team"] == 1 and f["rooted"] > 0.0:
					rooted += 1
			print("Verdant Roar: %d of 3 rivals rooted by the roar" % rooted)
	await _frames(10)
	var vines := 0
	for e in arena._effects:
		if e["kind"] == "vines":
			vines += 1
	print("Verdant Roar: vine fields on the floor %d; card art is the title card: %s" % [vines, str(me["closeup"].resource_path.get_file())])
	# 5. Fight length: AI 1v1 Stormwick vs Scourmaw and Ironvent vs Rampartroot.
	arena.auto_you = true
	arena.team_size = 1
	for pair in [[0, 2], [3, 1]]:
		arena._you = pair[0]; arena._rival = pair[1]
		arena._new_match()
		var frames := 0
		while arena._winner < 0 and frames < 4500:
			await process_frame
			frames += 1
		print("Fight length %s vs %s: %.0f s (was 11 to 20 s at 100 HP)" % [arena._fighters[0]["name"], arena._fighters[1]["name"], frames / 30.0])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
