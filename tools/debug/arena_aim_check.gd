extends SceneTree
## Mouse aim and target lock (Claude, 2026-10-09, Preston: "3"): with the mouse live the swing
## goes at the enemy in the cone along the cursor line, not the auto target; nobody there makes
## it a free swing toward the cursor; a ranged basic flies toward the cursor; a lob lands at the
## cursor; holding the button faces the cursor; right click locks and clears; with the mouse
## idle the keyboard play of item 1 is unchanged.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_aim_check.gd
## Stills to docs/creatures/arena-aim-2026-10-09/.

const OUT := "res://docs/creatures/arena-aim-2026-10-09/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(11)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena.poll_input = false
	arena.auto_you = false
	arena.team_size = 3
	arena._you = 3; arena._you_stage = 2   # Ironvent, a melee basic
	arena._rival = 1; arena._rival_stage = 2
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var enemies := []
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 1:
			enemies.append(j)
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	var basic: String = me["kit"][0]
	await _until_free(me, basic)
	var a: Dictionary = arena._fighters[enemies[0]]
	var b: Dictionary = arena._fighters[enemies[1]]
	var c: Dictionary = arena._fighters[enemies[2]]
	var here: Vector2 = me["body"].position
	a["body"].position = here + Vector2(30, 0)     # the auto target, east
	b["body"].position = here + Vector2(0, 34)     # south
	c["body"].position = here + Vector2(0, -200)   # far
	arena.player_target = -1
	me["target"] = enemies[0]
	me["retarget"] = 5.0
	# 1. The cursor south: the swing goes at B, not the auto target A.
	arena._mouse_live = arena.MOUSE_LIVE
	arena.mouse_override = here + Vector2(0, 80)
	var a_hp: int = a["hp"]
	var b_hp: int = b["hp"]
	_tap()
	await process_frame
	var aimed: Vector2 = me["windup"].get("aim", Vector2.ZERO)
	await _frames(14)
	_save("cone_target")
	print("Cursor south with A 30 px east and B 34 px south: the swing aimed %s, B took %d, A took %d; facing %s" % [str(aimed.round()), b_hp - b["hp"], a_hp - a["hp"], me["facing"]])
	# 2. The cursor at empty ground west: a free swing that way, nobody hit.
	await _until_free(me, basic)
	arena._mouse_live = arena.MOUSE_LIVE
	arena.mouse_override = here + Vector2(-120, 0)
	a_hp = a["hp"]; b_hp = b["hp"]
	_tap()
	await process_frame
	var w: Dictionary = me["windup"]
	print("Cursor west over empty ground: free %s, aimed %s, at %s (reach %d); A took %d, B took %d after the swing" % [str(w.get("free", false)), str(w.get("aim", Vector2.ZERO).round()), str((w.get("at", Vector2.ZERO) - here).round()), int(arena.MOVES[basic]["range"]), 0, 0])
	await _frames(14)
	# 3. Holding the button faces the cursor even standing still.
	arena.mouse_override = here + Vector2(-50, -50)
	arena._mouse_live = arena.MOUSE_LIVE
	arena._attack_held = true
	me["cds"][basic] = 5.0   # nothing fires, it only turns
	await _frames(3)
	var faced: String = me["facing"]
	arena._attack_held = false
	me["cds"][basic] = 0.0
	print("Holding the button with the cursor to the north-west: facing %s" % faced)
	# 4. Right click locks the enemy under the cursor; on empty ground it clears.
	arena.mouse_override = b["body"].position + Vector2(6, -8)
	arena._lock_under_cursor()
	var locked: int = arena.player_target
	await process_frame
	_save("lock")
	arena.mouse_override = here + Vector2(0, -120)
	arena._lock_under_cursor()
	print("Right click on %s: locked %s; right click on empty ground: lock %s" % [b["name"], "it" if locked == enemies[1] else "the wrong one (WRONG)", "cleared" if arena.player_target < 0 else "kept (WRONG)"])
	# 5. A ranged basic flies toward the cursor; a lob lands at the cursor.
	arena.team_size = 1
	arena._you = 9; arena._you_stage = 2   # Highsignal: Whistle Dart
	arena._rival = 1
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	await _until_free(me, me["kit"][0])
	here = me["body"].position
	foe["body"].position = here + Vector2(0, 90)
	arena._mouse_live = arena.MOUSE_LIVE
	arena.mouse_override = here + Vector2(100, 0)   # east, away from the foe
	_tap()
	await _frames(10)
	var dart_dir := Vector2.ZERO
	for e in arena._effects:
		if e["kind"] == "fireball" and e["owner"] == 0:
			dart_dir = e["vel"].normalized()
	print("Whistle Dart with the foe south and the cursor east: the dart flies %s" % str(dart_dir.round()))
	await _frames(20)
	arena._you = 1; arena._you_stage = 2   # Rampartroot: Seed, a lob
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
	foe["body"].position = here + Vector2(0, 90)
	arena._mouse_live = arena.MOUSE_LIVE
	arena.mouse_override = here + Vector2(70, -30)
	_tap()
	await process_frame
	w = me["windup"]
	await _frames(14)
	var landed := Vector2(INF, INF)
	for e in arena._effects:
		if e["kind"] == "seed" and e["owner"] == 0:
			landed = e["to"]
	_save("lob_cursor")
	print("Seed with the foe south and the cursor at (70, -30): the telegraph sat at %s, the seed flies to %s" % [str((w.get("at", Vector2.ZERO) - here).round()), str((landed - here).round()) if landed.x != INF else "nowhere (WRONG)"])
	# 6. Mouse idle: item 1's keyboard play, the swing goes at the target in reach.
	await _frames(20)
	arena._mouse_live = 0.0
	arena.mouse_override = here + Vector2(-100, 0)   # a stale cursor west
	foe["body"].position = here + Vector2(30, 0)
	var hp: int = foe["hp"]
	await _until_free(me, me["kit"][0])
	_tap()
	await process_frame
	w = me["windup"]
	await _frames(14)
	print("Mouse idle with a stale cursor west and the target 30 px east: free %s, the target took %d" % [str(w.get("free", false)), hp - foe["hp"]])
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
