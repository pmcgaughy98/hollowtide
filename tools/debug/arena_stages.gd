extends SceneTree
## Stills of the arena with evolved forms (Claude, 2026-10-07).
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_stages.gd
var OUT := ProjectSettings.globalize_path("user://arena_captures/")
var arena: Node2D

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	await process_frame
	var plans := [[0, 2, 1, 2, 0, "stormwick_vs_rampartroot"], [2, 2, 0, 1, 0, "scourmaw_vs_sparkwick"],
		[1, 1, 2, 1, 1, "huskward_vs_riftfin"], [2, 1, 1, 2, 1, "riftfin_vs_rampartroot"]]
	for p in plans:
		arena._you = p[0]; arena._you_stage = p[1]; arena._rival = p[2]; arena._rival_stage = p[3]
		arena._set_arena(p[4]); arena._new_match()
		for i in 40:
			arena.debug_input = Vector2(1, 0.3) if i < 20 else Vector2.ZERO
			if i == 25:
				arena._fighters[0]["facing"] = "e"
				arena.attack(0)
			await process_frame
		await _snap(p[5])
	arena._you = 0; arena._you_stage = 2; arena._rival = 2; arena._rival_stage = 2
	arena._set_arena(0); arena._new_match()
	await process_frame
	arena._fighters[0]["meter"] = 100
	arena.signature(0)
	for i in 20:
		await process_frame
	await _snap("stormwick_card")
	for i in 55:
		await process_frame
	await _snap("stormwick_strike")
	print("hp after signature: ", arena._fighters[1]["hp"], " / ", arena._fighters[1]["max_hp"])
	quit()

func _snap(n: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + n + ".png")
	print("saved ", n)
