extends SceneTree
## Ironvent's bruiser kit (Claude, 2026-10-07): a Crest Ram that carries Stormwick into the
## boulder, Cinder Claw, Stoke filling and venting, then an AI-only 1v1 to the end.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_ironvent_check.gd
## Stills to docs/creatures/arena-ironvent-2026-10-07/kit_*.png.

const OUT := "res://docs/creatures/arena-ironvent-2026-10-07/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	seed(3)
	arena.team_size = 1
	arena._you = 3; arena._you_stage = 2       # Ironvent
	arena._rival = 0; arena._rival_stage = 2   # Stormwick
	arena._new_match()
	await _frames(3)
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	# 1. Staged ram: Stormwick stands just in front of the boulder, Ironvent 70 px left of it.
	var rock: Dictionary = arena._rocks[0]
	foe["body"].position = rock["pos"] + Vector2(-rock["rx"] - 16, 2)
	me["body"].position = foe["body"].position + Vector2(-70, 0)
	foe["stun"] = 3.0   # holds still for the test
	var hp0: int = foe["hp"]
	arena._do_move(0, "crest_ram", 1)
	for k in 14:
		await process_frame
		if k == 6:
			_save("kit_ram_run")
	await _frames(8)
	_save("kit_ram_slam")
	print("Crest Ram: Stormwick HP %d -> %d, carried %s, slammed %s, rock HP %d/%d" % [hp0, foe["hp"],
		"yes" if foe["carry_t"] > 0.0 or foe["body"].position.distance_to(rock["pos"]) < rock["rx"] + 12 else "no",
		"yes" if foe["dazzle"] > 0.0 else "no", rock["hp"], rock["max_hp"]])
	# 2. Stoke: four hits fill it, the fifth is boosted and vents.
	me["heat"] = 0.0
	foe["hp"] = foe["max_hp"]
	for k in 4:
		arena._do_move(0, "cinder_claw", 1)
		await _frames(2)
	var heat: float = me["heat"]
	var before: int = foe["hp"]
	var plain: int = arena._dmg("cinder_claw", 0, 1)
	me["heat"] = 100.0
	var hot: int = arena._dmg("cinder_claw", 0, 1)
	arena._do_move(0, "cinder_claw", 1)
	await _frames(3)
	_save("kit_stoke_vent")
	print("Stoke: heat after 4 hits %.0f; claw damage cold %d, hot %d; after venting heat %.0f (HP %d -> %d)" % [heat, plain, hot, me["heat"], before, foe["hp"]])
	# 3. A full AI match from a fresh start.
	arena.auto_you = true
	arena._new_match()
	var frames := 0
	while arena._winner < 0 and frames < 2700:
		await process_frame
		frames += 1
		if frames == 150:
			_save("kit_match")
	var w: Dictionary = arena._fighters[arena._winner] if arena._winner >= 0 else {}
	print("Match: %s after %.0f s; Ironvent dealt %d, Stormwick dealt %d" % [w.get("name", "draw"), frames / 30.0,
		arena._fighters[0]["dealt"], arena._fighters[1]["dealt"]])
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
