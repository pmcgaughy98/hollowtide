extends SceneTree
## Your reach on the floor (Claude, 2026-10-09, Preston: "4"): the ring at the basic's reach,
## the ghost toward the cursor, your wind-ups as the shape they take (a wedge along your aim, a
## spot where the lob lands) and the reach flash after an out-of-range refusal.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_reach_check.gd
## Stills to docs/creatures/arena-reach-2026-10-09/.

const OUT := "res://docs/creatures/arena-reach-2026-10-09/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(5)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena.poll_input = false
	arena.auto_you = false
	arena.team_size = 1
	arena._you = 3; arena._you_stage = 2   # Ironvent: Cinder Claw (melee), Vent Barrage (85 px)
	arena._rival = 1; arena._rival_stage = 2
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	var basic: String = me["kit"][0]
	await _until_free(me, basic)
	var here: Vector2 = me["body"].position
	# 1. The ring and the ghost, mouse live, cursor to the south-east: a still.
	foe["body"].position = here + Vector2(120, 0)
	arena._mouse_live = arena.MOUSE_LIVE
	arena.mouse_override = here + Vector2(60, 60)
	await _frames(2)
	_save("ring_ghost")
	print("Ring at the basic's reach: %d px (%s %d + %d); the ghost is a wedge toward the cursor (see ring_ghost.png)" % [int(arena.MOVES[basic]["range"] + arena.SWEEP_REACH_EXTRA), arena.MOVES[basic]["name"], int(arena.MOVES[basic]["range"]), int(arena.SWEEP_REACH_EXTRA)])
	# 2. A melee wind-up of yours is a wedge along your aim.
	_tap()
	await process_frame
	var s: Dictionary = arena._telegraph_shape(0)
	await _frames(2)
	_save("wedge")
	print("Your Cinder Claw wind-up: shape %s, dir %s, reach %d" % [str(s.get("kind")), str(s.get("dir", Vector2.ZERO).round()), int(s.get("r", 0))])
	await _frames(20)
	# 3. An out-of-range refusal flashes that ability's reach.
	await _until_free(me, basic)
	arena._mouse_live = 0.0
	foe["body"].position = here + Vector2(300, 0)
	var rs := -1
	for k in me["abilities"].size():
		var mm: String = me["abilities"][k]
		if arena.MOVES[mm]["damage"] > 0 and arena.MOVES[mm]["range"] > 0.0 and not arena.MOVES[mm].get("mobility", false):
			rs = k
			break
	var ar: String = me["abilities"][rs]
	me["cds"][ar] = 0.0
	arena.cast(rs)
	await process_frame
	_save("range_hint")
	print("%s refused at 300 px: the reach flash shows %d px for %.1f s" % [arena.MOVES[ar]["name"], int(arena._range_hint["r"]), arena._range_hint["t"]])
	# 4. A lob of yours shows its landing spot at the cursor.
	arena._you = 1; arena._you_stage = 2   # Rampartroot: Seed
	arena._rival = 3
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	foe = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	await _until_free(me, me["kit"][0])
	here = me["body"].position
	foe["body"].position = here + Vector2(0, 100)
	arena._mouse_live = arena.MOUSE_LIVE
	arena.mouse_override = here + Vector2(50, -20)
	_tap()
	await process_frame
	s = arena._telegraph_shape(0)
	await _frames(2)
	_save("spot")
	print("Your Seed wind-up with the foe south and the cursor at (50, -20): shape %s at %s, spot radius %d" % [str(s.get("kind")), str((s.get("at", Vector2.ZERO) - here).round()), int(s.get("r", 0))])
	# 5. The enemy's telegraph is untouched: red, at its target.
	await _frames(20)
	foe["stun"] = 0.0
	me["stun"] = 60.0
	foe["body"].position = here + Vector2(30, 0)
	foe["cds"][foe["kit"][0]] = 0.0
	foe["act"] = 0.0
	arena.cast_as(1, foe["kit"][0])
	await process_frame
	_save("enemy_telegraph")
	print("The enemy's wind-up still draws the old way (enemy_telegraph.png): kind %s" % str(foe["windup"].get("kind", "")))
	quit()


func _tap() -> void:
	arena._attack_buffer = arena.ATTACK_BUFFER


func _until_free(me: Dictionary, basic: String) -> void:
	for k in 90:
		await process_frame
		if me["windup"].is_empty() and me["act"] <= 0.0 and me["cds"][basic] <= 0.0 and arena._attack_buffer <= 0.0:
			return


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
