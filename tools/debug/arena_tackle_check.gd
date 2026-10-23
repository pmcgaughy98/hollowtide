extends SceneTree
## Stormwick's second kit (Claude, 2026-10-07): Ember Feint invulnerability (it replaced Flashstep
## on 2026-10-08), bouncing lantern balls that mark, the Lantern Tackle zip with a chosen landing,
## crates, and, since SPACE became the dash (2026-10-09), steering another slot of a 3v3 while the
## Stormwick you are not steering fights on its AI.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_tackle_check.gd
## Stills to docs/creatures/arena-feel-2026-10-07/tackle_*.png.

const OUT := "res://docs/creatures/arena-feel-2026-10-07/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(33)
	arena.team_size = 3
	arena._you = 0; arena._you_stage = 2       # Stormwick leads your team
	arena._rival = 1; arena._rival_stage = 2   # Rampartroot, Scourmaw, Stormwick
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	for f in arena._fighters:
		if f["team"] == 1:
			f["stun"] = 60.0   # rivals hold still for the staged casts
	# 1. Ember Feint invulnerability: hurt it during the frames; HP must not move.
	me["cds"]["ember_feint"] = 0.0
	var hp0: int = me["hp"]
	arena.cast(0)
	await process_frame
	var inv: float = me["invuln"]
	arena._hurt(0, 20, Vector2(1, 0), 3)
	print("Ember Feint: invulnerable for %.2f s after the hop; a 20-damage hit during it left HP %d -> %d%s" % [inv, hp0, me["hp"], "" if inv > 0.0 and me["hp"] == hp0 else " (WRONG)"])
	# 2. Volley: aim across the field so the balls reach the edge; count bounces and marks.
	me["body"].position = arena.ARENAS[arena._arena]["floor"].get_center() + Vector2(-60, 0)
	me["cds"]["lantern_volley"] = 0.0
	me["act"] = 0.0
	arena.cast(1)
	var bounces := 0
	for k in 75:
		await process_frame
		var used := 0
		for e in arena._effects:
			if e["kind"] == "fireball" and e.get("mark", false):
				used += arena.BALL_BOUNCES - e["bounce"]
		bounces = maxi(bounces, used)
		if k == 20:
			_save("tackle_volley_bounce")
	var marked_f := 0
	var marked_r := 0
	for f in arena._fighters:
		if f["team"] == 1 and f["marked"] > 0.0:
			marked_f += 1
	for r in arena._rocks:
		if r["marked"] > 0.0:
			marked_r += 1
	print("Volley: %d horizontal bounces seen, %d enemies and %d objects marked" % [bounces, marked_f, marked_r])
	# 3. Tackle: mark two rivals and a crate by hand, then zip; count strikes; land on the crate.
	for f in arena._fighters:
		if f["team"] == 1 and f["name"] != "Stormwick":
			f["marked"] = 8.0
	var crate := -1
	for k in arena._rocks.size():
		if arena._rocks[k]["kind"] == "crate":
			crate = k
	arena._rocks[crate]["marked"] = 8.0
	me["cds"]["pounce"] = 99.0   # no basic attacks during the staged cast
	while me["ram_t"] > 0.0 or not me["windup"].is_empty():
		await process_frame
	var before: Array = arena._fighters.map(func(f): return f["hp"])
	me["cds"]["lantern_tackle"] = 0.0
	me["act"] = 0.0
	arena.cast(2)
	await _frames(2)
	var tk_inv: float = me["invuln"]
	# choose the crate as the landing while it runs
	for k in 6:
		arena._cycle_target(1)
		if me["tackle"].is_empty() or me["tackle"]["land"] == ["r", crate]:
			break
	var land_choice: Array = me["tackle"]["land"] if not me["tackle"].is_empty() else []
	await _frames(12)
	_save("tackle_zip")
	while not me["tackle"].is_empty():
		await process_frame
	await _frames(3)
	_save("tackle_landed")
	var struck := []
	for j in arena._fighters.size():
		if arena._fighters[j]["hp"] < before[j]:
			struck.append("%s -%d" % [arena._fighters[j]["name"], before[j] - arena._fighters[j]["hp"]])
	var at_crate: float = me["body"].position.distance_to(arena._rocks[crate]["pos"])
	print("Tackle: invulnerable %.2f s; landing chosen %s; struck %s; landed %.0f px from the crate" % [tk_inv, str(land_choice), ", ".join(struck), at_crate])
	# 4. Steer slot 1 (the picker's choice since SPACE became the dash); the Stormwick you are
	# not steering should fire its abilities through its AI.
	var c0: int = arena.controlled
	arena.control_slot = 1
	arena._new_match()
	await _frames(3)
	var c1: int = arena.controlled
	var fired := false
	for k in 240:
		await process_frame
		var s: Dictionary = arena._fighters[0]
		if s["hp"] > 0 and s["last_move"] in s["abilities"] and arena.controlled != 0:
			fired = true   # last_move, not cooldowns: every ability starts a match on a 0.5 s cooldown
	_save("tackle_switched")
	print("Steering slot %d -> %d (%s); the Stormwick you are not steering used its abilities in 8 s: %s" % [c0, c1, arena._fighters[c1]["name"], "yes" if fired else "no (WRONG)"])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
