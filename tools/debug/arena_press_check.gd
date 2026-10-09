extends SceneTree
## Attack on press (Claude, 2026-10-09, Preston: "do 1"): a tap swings at once, out of range it
## whiffs down the line you steer, a tap during recovery is buffered, holding repeats, a free
## swing hits whoever is in the arc, and the AI still fights for itself.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_press_check.gd
## Stills to docs/creatures/arena-press-2026-10-09/.

const OUT := "res://docs/creatures/arena-press-2026-10-09/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(7)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena.poll_input = false
	arena.auto_you = false
	arena.team_size = 1
	arena._you = 3; arena._you_stage = 2   # Ironvent: Cinder Claw, a melee basic
	arena._rival = 1; arena._rival_stage = 2   # Rampartroot, a slow tank
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	var basic: String = me["kit"][0]
	# 1. A tap out of range: it swings down the steering line and whiffs.
	await _until_free(me, basic)   # the drop-in pause
	foe["body"].position = me["body"].position + Vector2(160, 0)
	arena._player_dir = Vector2(0, 1)
	_tap()
	await process_frame
	var w: Dictionary = me["windup"]
	var free: bool = not w.is_empty() and w.get("free", false)
	var aim: Vector2 = w.get("aim", Vector2.ZERO)
	await _frames(12)
	var whiffed := false
	for e in arena._effects:
		if e["kind"] == "sweep" and e["owner"] == 0 and e.get("free", false):
			whiffed = true
	_save("whiff")
	var hp_before: int = foe["hp"]
	await _frames(6)
	print("Tap out of range: the swing started at once (free %s, aimed %s where you steered), a sweep went down that line and the enemy took %d; the basic's cooldown reads %.2f s" % [str(free), str(aim.round()), hp_before - foe["hp"], me["cds"][basic]])
	# 2. A tap in range hits the target.
	await _until_free(me, basic)
	arena._player_dir = Vector2.ZERO
	foe["body"].position = me["body"].position + Vector2(24, 0)
	hp_before = foe["hp"]
	_tap()
	await _frames(14)
	print("Tap in range: the enemy 24 px away took %d" % (hp_before - foe["hp"]))
	_save("hit")
	# 3. A tap during recovery is buffered: it fires when the creature is free.
	await _until_free(me, basic)
	me["act"] = 0.2
	me["cds"][basic] = 0.0
	hp_before = foe["hp"]
	_tap()
	await process_frame
	var fired_early: bool = not me["windup"].is_empty()
	var buffer_after_tap: float = arena._attack_buffer
	await _frames(8)   # recovery over, the buffer fires
	var fired_late: bool = not me["windup"].is_empty() or foe["hp"] < hp_before
	await _frames(14)
	print("Buffer: a tap during recovery did%s fire at once (buffer %.2f s), then fired on its own when recovery ended: %s; the enemy took %d" % ["" if fired_early else " not", buffer_after_tap, str(fired_late), hp_before - foe["hp"]])
	# 4. Holding repeats on the move's rhythm.
	await _until_free(me, basic)
	hp_before = foe["hp"]
	arena._attack_held = true
	var swings := 0
	var was_wind := false
	for k in 120:   # 4 s
		await process_frame
		var winding: bool = not me["windup"].is_empty()
		if winding and not was_wind:
			swings += 1
		was_wind = winding
	arena._attack_held = false
	print("Held for 4 s: %d swings (the basic's cooldown is %.1f s plus telegraph and recovery), the enemy took %d" % [swings, arena.MOVES[basic]["cooldown"], hp_before - foe["hp"]])
	_save("held")
	# 5. A free swing hits whoever is in the arc, not just the target: 3v3, the target far, another enemy in the steering line.
	arena.team_size = 3
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	var enemies := []
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 1:
			enemies.append(j)
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	await _until_free(me, me["kit"][0])
	arena.player_target = enemies[0]
	arena._fighters[enemies[0]]["body"].position = me["body"].position + Vector2(200, 0)
	arena._fighters[enemies[1]]["body"].position = me["body"].position + Vector2(-26, 4)
	arena._fighters[enemies[2]]["body"].position = me["body"].position + Vector2(0, -150)
	arena._player_dir = Vector2(-1, 0)
	var other_hp: int = arena._fighters[enemies[1]]["hp"]
	var target_hp: int = arena._fighters[enemies[0]]["hp"]
	_tap()
	await _frames(14)
	_save("free_arc")
	print("Free swing with the target 200 px away and %s 26 px down the steering line: %s took %d, the target took %d" % [arena._fighters[enemies[1]]["name"], arena._fighters[enemies[1]]["name"], other_hp - arena._fighters[enemies[1]]["hp"], target_hp - arena._fighters[enemies[0]]["hp"]])
	# 6. The AI still fights for itself: an auto 1v1 for 20 s, both sides scoring.
	arena.auto_you = true
	arena.team_size = 1
	arena._you = 0; arena._rival = 3
	arena._new_match()
	await _frames(600)
	print("AI 1v1 for 20 s with nobody steering: Stormwick dealt %d, Ironvent dealt %d" % [arena._fighters[0]["dealt"], arena._fighters[1]["dealt"]])
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
