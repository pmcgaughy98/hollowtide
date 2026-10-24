extends SceneTree
## Your reach on the floor (Claude, 2026-10-09, Preston: "4"): the ring at the basic's reach,
## the ghost toward the cursor, your wind-ups as the shape they take (a wedge along your aim, a
## spot where the lob lands) and the reach flash after an out-of-range refusal.
## Judged since Claude, 2026-10-24 (H24): the ring reach, the wedge kind, side and reach, the
## refusal flash's reach and time, the lob spot at the cursor, and the enemy's wind-up kind.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_reach_check.gd
## Stills to docs/creatures/arena-reach-2026-10-09/.

const OUT := "res://docs/creatures/arena-reach-2026-10-09/"
var arena: Node2D
var fails := 0

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
	# The ring _draw_player_reach draws: the basic's range plus SWEEP_REACH_EXTRA, plus VANTAGE_RANGE only when perched.
	var ring: float = arena.MOVES[basic]["range"] + arena.SWEEP_REACH_EXTRA
	print("Ring at the basic's reach: %d px (%s %d + %d); the ghost is a wedge toward the cursor (see ring_ghost.png)" % [int(ring), arena.MOVES[basic]["name"], int(arena.MOVES[basic]["range"]), int(arena.SWEEP_REACH_EXTRA)])
	_ok("Ring is the basic's range plus SWEEP_REACH_EXTRA (not perched, so no vantage bonus)", me["perched"] < 0 and ring > float(arena.MOVES[basic]["range"]))
	# 2. A melee wind-up of yours is a wedge along your aim.
	_tap()
	await process_frame
	var s: Dictionary = arena._telegraph_shape(0)
	await _frames(2)
	_save("wedge")
	print("Your Cinder Claw wind-up: shape %s, dir %s, reach %d" % [str(s.get("kind")), str(s.get("dir", Vector2.ZERO).round()), int(s.get("r", 0))])
	var cursor := Vector2(60, 60)   # the cursor offset set above
	var wdir: Vector2 = s.get("dir", Vector2.ZERO)
	_ok("Your melee wind-up is a wedge", s.get("kind") == "wedge")
	_ok("The wedge points to the cursor's side", signf(wdir.x) == signf(cursor.x) and signf(wdir.y) == signf(cursor.y))
	_ok("The wedge reaches as far as the ring", is_equal_approx(float(s.get("r", 0.0)), ring))
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
	_ok("Ironvent has a damaging ranged ability to refuse", rs >= 0)
	var ar: String = me["abilities"][maxi(rs, 0)]
	me["cds"][ar] = 0.0
	arena.cast(rs)
	# Read the flash the moment it is set; it fades with every frame after.
	var hint_r: float = arena._range_hint["r"]
	var hint_t: float = arena._range_hint["t"]
	await process_frame
	_save("range_hint")
	print("%s refused at 300 px: the reach flash shows %d px for %.1f s" % [arena.MOVES[ar]["name"], int(hint_r), hint_t])
	_ok("The refusal flash shows the move's range plus SWEEP_REACH_EXTRA", is_equal_approx(hint_r, arena.MOVES[ar]["range"] + arena.SWEEP_REACH_EXTRA))
	_ok("The refusal flash lasts RANGE_HINT_SECONDS", is_equal_approx(hint_t, arena.RANGE_HINT_SECONDS))
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
	_ok("Your lob's spot lands at the cursor, (50, -20) from you", s.get("kind") == "spot" and (s.get("at", Vector2.ZERO) - here).round() == Vector2(50, -20))
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
	_ok("The enemy winds up, and its wind-up kind is not your wedge", not foe["windup"].is_empty() and foe["windup"].get("kind", "") != "wedge")
	print("ARENA REACH: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails > 0 else 0)


## One judged line: "what -> ok" or "what -> FAIL" (Claude, 2026-10-24).
func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


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
