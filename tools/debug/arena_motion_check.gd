extends SceneTree
## Manual control, the movement model and the camera (Claude, 2026-10-08 night): you steer the
## creature you chose, momentum, the universal dash, the AI dodge step, the drop-in camera, the
## action zoom, punch-ins and the crowd banner.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_motion_check.gd
## Stills to docs/creatures/arena-motion-2026-10-08/.

const OUT := "res://docs/creatures/arena-motion-2026-10-08/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(37)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	# 1. The drop-in: the camera starts zoomed and eases out over the first second.
	arena.poll_input = false
	arena.team_size = 3
	arena._you = 0; arena._you_stage = 2
	arena._rival = 3; arena._rival_stage = 2
	arena.control_slot = 1   # you steer the second creature (Rampartroot)
	arena._new_match()
	var z0: float = arena._cam_zoom
	await process_frame
	_save("entry")
	await _frames(30)
	var z1: float = arena._cam_zoom
	print("Drop-in: zoom %.2f at the start, %.2f a second later; you asked for slot %d and control slot %d (%s)" % [z0, z1, arena.control_slot, arena.controlled, arena._fighters[arena.controlled]["name"]])
	# 2. Manual steering with momentum: hold right for a quarter second, then let go.
	var me: Dictionary = arena._fighters[arena.controlled]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	var p0: Vector2 = me["body"].position
	arena.debug_input = Vector2.ZERO
	arena._player_dir = Vector2.RIGHT
	var speeds := []
	for k in 8:
		await process_frame
		speeds.append("%.0f" % me["vel"].length())
	arena._player_dir = Vector2.ZERO
	var at_release: Vector2 = me["body"].position
	await _frames(8)
	var full: float = arena.SPEED * me["speed"]
	print("Momentum: speed over the first eight frames of steering %s (full %.0f); after release it slid %.1f px more" % [str(speeds), full, me["body"].position.distance_to(at_release)])
	# 3. The dash on SPACE: distance covered, afterimages, safety.
	p0 = me["body"].position
	arena._player_dir = Vector2.RIGHT
	arena._player_dash()
	var inv: float = me["invuln"]
	await _frames(6)
	var echoes := 0
	for e in arena._effects:
		if e["kind"] == "echo":
			echoes += 1
	_save("dash")
	print("Dash: covered %.0f px in 0.2 s with %d afterimages and %.2f s of safety; cooldown %.1f s" % [me["body"].position.distance_to(p0), echoes, inv, me["dash_cd"]])
	arena._player_dir = Vector2.ZERO
	# 4. The basic on J: nothing happens until J is held.
	var foe := -1
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 1:
			foe = j
			break
	arena._fighters[foe]["body"].position = me["body"].position + Vector2(24, 0)
	arena.player_target = foe   # Q/E would have picked it; the AI's own pick was a farther enemy
	for m in me["cds"]:
		me["cds"][m] = 0.0
	me["act"] = 0.0
	arena._attack_held = false
	await _frames(10)
	var idle: bool = me["windup"].is_empty() and me["last_move"] == ""
	arena._attack_held = true
	await _frames(3)
	var swung: bool = not me["windup"].is_empty() or me["last_move"] != ""
	arena._attack_held = false
	print("Attack on J: with J up the creature %s; with J held it %s (act %.2f, stun %.1f, dash %.2f, cd %.2f, foe %d, hitstop %.2f, windup %s)" % ["stood ready" if idle else "swung on its own (WRONG)", "swung" if swung else "did nothing (WRONG)", me["act"], me["stun"], me["dash"], me["cds"][me["kit"][0]], arena._foe_of(arena.controlled), arena._hitstop, str(me["windup"])])
	# 5. The AI dodge: Stormwick, free, with Ironvent's claw telegraphed at it; it steps out.
	arena.team_size = 1
	arena.control_slot = 0
	arena._you = 3; arena._you_stage = 2       # Ironvent (yours, on auto so its AI attacks)
	arena._rival = 0; arena._rival_stage = 2   # Stormwick
	arena.auto_you = true
	arena._new_match()
	await _frames(3)
	me = arena._fighters[0]
	var sw: Dictionary = arena._fighters[1]
	sw["body"].position = me["body"].position + Vector2(22, 0)
	for m in me["cds"]:
		me["cds"][m] = 0.0
	sw["stun"] = 0.0
	sw["dodge_cd"] = 0.0
	sw["dash_cd"] = 0.0
	# The step is a 55% call for a skirmisher, so five telegraphs in a row: it should step at least once.
	var hp: int = sw["hp"]
	var steps := 0
	for attempt in 5:
		sw["body"].position = me["body"].position + Vector2(22, 0)
		sw["dodge_cd"] = 0.0
		sw["dash_cd"] = 0.0
		sw["dash"] = 0.0
		me["windup"] = {"m": "cinder_claw", "kind": "melee", "t": 0.25, "total": 0.25, "target": 1, "at": sw["body"].position}
		var dodged := false
		for k in 12:
			await process_frame
			if sw["dash"] > 0.0 or sw["invuln"] > 0.0:
				dodged = true
		if dodged:
			steps += 1
		await _frames(8)
	print("AI dodge: over five telegraphed claws Stormwick stepped out %d times (a 55%% call each) and took %d in all" % [steps, hp - sw["hp"]])
	_save("dodge")
	# 6. Action zoom and the punch-in on a knockout, with the banner.
	arena.auto_you = false
	for f in arena._fighters:
		f["stun"] = 60.0
	sw["body"].position = me["body"].position + Vector2(40, 0)
	await _frames(20)
	var action_zoom: float = arena._cam_zoom
	sw["hp"] = 5
	arena._hurt(1, 30, Vector2(1, 0), 0)
	await _frames(4)
	var ko_zoom_to: float = arena._cam_zoom_to
	var banner: String = arena._banner
	_save("knockout")
	await _frames(20)
	print("Camera: with the two close the zoom settled at %.2f; the knockout punched toward %.2f with the banner '%s'; %.2f after" % [action_zoom, ko_zoom_to, banner, arena._cam_zoom])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
