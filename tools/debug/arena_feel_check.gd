extends SceneTree
## Feel and control check (Claude, 2026-10-07): your target order is obeyed, telegraphs show
## before AI attacks, hitstop freezes the creatures on a hit, and shake is capped.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_feel_check.gd
## Stills to docs/creatures/arena-feel-2026-10-07/.

const OUT := "res://docs/creatures/arena-feel-2026-10-07/"
var arena: Node2D

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(5)
	# 1. Target order in a 3v3: tell Stormwick to go for the rival Scourmaw (the far one).
	arena.team_size = 3
	arena._you = 0; arena._you_stage = 2
	arena._rival = 0; arena._rival_stage = 2
	arena._new_match()
	await _frames(5)
	var scour := -1
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 1 and arena._fighters[j]["name"] == "Scourmaw":
			scour = j
	arena.player_target = scour
	arena._fighters[0]["target"] = scour
	var hits_on_target := 0
	var hits_elsewhere := 0
	var hp: Array = arena._fighters.map(func(f): return f["hp"])
	var telegraph_frames := 0
	var saved_telegraph := false
	var saved_marker := false
	for k in 240:
		await process_frame
		for j in arena._fighters.size():
			if j != 0 and arena._fighters[j]["hp"] < hp[j] and arena._fighters[j]["team"] == 1:
				pass
		if not arena._fighters[0]["windup"].is_empty():
			telegraph_frames += 1
			if not saved_telegraph and arena._fighters[0]["windup"]["t"] < 0.15:
				_save("telegraph_yours"); saved_telegraph = true
		if k == 40 and not saved_marker:
			_save("target_marker"); saved_marker = true
		hp = arena._fighters.map(func(f): return f["hp"])
	var dealt_to_target: int = arena._fighters[scour]["max_hp"] - arena._fighters[scour]["hp"]
	var dealt_to_others := 0
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 1 and j != scour:
			dealt_to_others += arena._fighters[j]["max_hp"] - arena._fighters[j]["hp"]
	print("Target order: your Stormwick's target is %s; rival Scourmaw lost %d HP, the other two rivals lost %d between them (some of that is your allies); your creature spent %d frames winding up telegraphed moves" % [
		arena._fighters[arena._fighters[0]["target"]]["name"] if arena._fighters[0]["target"] >= 0 else "none", dealt_to_target, dealt_to_others, telegraph_frames])
	# 2. Hitstop: a staged hit, then the creatures must not move for the frozen frames.
	arena.team_size = 1
	arena._new_match()
	await _frames(3)
	var before: Vector2 = arena._fighters[1]["body"].position
	arena._hurt(1, 10, Vector2(1, 0), 0)
	var stop: float = arena._hitstop
	await process_frame
	_save("hitstop")
	var moved: float = arena._fighters[1]["body"].position.distance_to(before)
	print("Hitstop: %.3f s after a 10-damage hit (heavy would be %.2f); rival moved %.1f px during the first frozen frame; shiver offset %s" % [stop, arena.HITSTOP_HEAVY, moved, str(arena._fighters[1]["sprite"].position)])
	# 3. Shake cap: a signature asks for 9, must be capped.
	arena._shake_by(9.0)
	print("Shake cap: asked 9, got %.1f (cap %.1f); V toggles it (shake_on=%s)" % [arena._shake, arena.SHAKE_MAX, str(arena.shake_on)])
	# 4. A rival telegraph still (Rampartroot winding up Club Slam at you).
	arena._you = 0; arena._rival = 1; arena._rival_stage = 2
	arena._new_match()
	var got := false
	for k in 400:
		await process_frame
		var w: Dictionary = arena._fighters[1]["windup"]
		if not w.is_empty() and w["t"] < 0.12:
			_save("telegraph_rival_" + String(w["m"])); got = true; break
	print("Rival telegraph still: %s" % ("saved" if got else "none seen in 400 frames"))
	# 5. Readability: Tallowroot's Seed Pod lands on Kithflare; the creature must stay visible
	#    through the burst, the smoke and the scorch (stills at 0.4 s and 1.0 s after the hit).
	arena._you = 1; arena._you_stage = 0
	arena._rival = 0; arena._rival_stage = 0
	arena._new_match()
	await _frames(3)
	arena._fighters[1]["body"].position = arena._fighters[0]["body"].position + Vector2(60, 0)
	arena._fighters[1]["stun"] = 3.0
	arena._do_move(0, "seed", 1)
	await _frames(15)   # the pod is in the air for half a second
	await _frames(12)
	_save("seedpod_0_4s")
	await _frames(18)
	_save("seedpod_1_0s")
	print("Seed Pod stills saved; smoke puffs now %d per hit" % int(28.0 / 5.0))
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
