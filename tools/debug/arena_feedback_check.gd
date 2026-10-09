extends SceneTree
## Cast feedback (Claude, 2026-10-09, Preston: "2"): a good press lights its card, rings the
## creature and sounds; a failed press shakes the card and says why (cooldown, out of range,
## hushed, held, ultimate not ready, charm cooling); a heavy ability of yours landing nudges
## the camera with extra hitstop, an AI hit does not.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_feedback_check.gd
## Stills to docs/creatures/arena-feedback-2026-10-09/.

const OUT := "res://docs/creatures/arena-feedback-2026-10-09/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(3)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena.poll_input = false
	arena.auto_you = false
	arena.team_size = 1
	arena._you = 3; arena._you_stage = 2   # Ironvent: Crest Ram (95 px, 14), Barrage, Blast, Furnace Roar
	arena._rival = 1; arena._rival_stage = 2
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	for f in arena._fighters:
		f["stun"] = 60.0
	me["stun"] = 0.0
	for k in 40:
		await process_frame
		if me["act"] <= 0.0:
			break
	var a0: String = me["abilities"][0]
	# 1. A good press.
	foe["body"].position = me["body"].position + Vector2(40, 0)
	for m in me["cds"]:
		me["cds"][m] = 0.0
	var rings_before := _rings()
	arena.cast(0)
	var flash: float = arena._card_flash[0]
	var playing := 0.0
	for p in arena._sounds:
		if p.playing:
			playing = p.pitch_scale
	await process_frame
	_save("press_ok")
	print("Good press of 1 (%s): card lit %.2f s, %d ring(s) at the feet, a cast sound at pitch %.2f; wind-up started %s" % [arena.MOVES[a0]["name"], flash, _rings() - rings_before, playing, str(not me["windup"].is_empty())])
	await _frames(30)
	# 2. On cooldown.
	me["windup"] = {}
	me["act"] = 0.0
	me["cds"][a0] = 2.4
	arena.cast(0)
	var shake: float = arena._card_shake[0]
	await process_frame
	_save("press_cooldown")
	print("Press of 1 on cooldown: card shakes %.2f s, reason '%s'" % [shake, arena._why])
	# 3. Out of range: refused, nothing spent. (A ranged attack that is not a charge: Crest Ram closes the gap by design.)
	var rs := -1
	for k in me["abilities"].size():
		var mm: String = me["abilities"][k]
		if arena.MOVES[mm]["damage"] > 0 and arena.MOVES[mm]["range"] > 0.0 and not arena.MOVES[mm].get("mobility", false):
			rs = k
			break
	var ar: String = me["abilities"][rs]
	me["cds"][ar] = 0.0
	me["windup"] = {}
	foe["body"].position = me["body"].position + Vector2(300, 0)
	arena.cast(rs)
	print("Press of %d (%s) with the target 300 px off (reach %d): reason '%s', cooldown still %.1f, wind-up %s" % [rs + 1, arena.MOVES[ar]["name"], int(arena.MOVES[ar]["range"]), arena._why, me["cds"][ar], "started (WRONG)" if not me["windup"].is_empty() else "not started"])
	# 4. Hushed, held.
	foe["body"].position = me["body"].position + Vector2(40, 0)
	me["windup"] = {}
	me["cds"][me["abilities"][1]] = 0.0
	me["hush"] = 2.0
	arena.cast(1)
	var why_hush: String = arena._why
	me["hush"] = 0.0
	me["stun"] = 1.0
	arena.cast(1)
	var why_held: String = arena._why
	me["stun"] = 0.0
	print("Hushed: '%s'; stunned: '%s'" % [why_hush, why_held])
	# 5. The ultimate at 40%, the charm cooling.
	me["meter"] = 40
	arena._press_signature()
	var why_ult: String = arena._why
	me["charm_cd"] = 20.0
	arena._unhandled_input(_key(KEY_C))
	print("Ultimate at 40%%: '%s'; charm cooling: '%s' (card 4 shakes %.2f)" % [why_ult, arena._why, arena._card_shake[4]])
	await process_frame
	_save("press_why")
	# 6. A heavy ability of yours landing nudges the camera; an AI hit does not.
	me["last_move"] = a0
	arena._cam_punch_t = 0.0
	arena._hitstop = 0.0
	arena._hurt(1, 20, Vector2(1, 0), 0)
	var punch_you: float = arena._cam_punch_t
	var stop_you: float = arena._hitstop
	arena._cam_punch_t = 0.0
	arena._hitstop = 0.0
	foe["last_move"] = foe["abilities"][0]
	arena._hurt(0, 20, Vector2(-1, 0), 1)
	print("A 20 ability hit of yours: camera nudge %.2f s, hitstop %.2f s; the same hit from the AI on you: nudge %.2f, hitstop %.2f" % [punch_you, stop_you, arena._cam_punch_t, arena._hitstop])
	quit()


func _rings() -> int:
	var n := 0
	for e in arena._effects:
		if e["kind"] == "ring":
			n += 1
	return n


func _key(code: int) -> InputEventKey:
	var ev := InputEventKey.new()
	ev.physical_keycode = code
	ev.pressed = true
	return ev


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
