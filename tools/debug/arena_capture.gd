extends SceneTree
## Plays the arena prototype with scripted input and saves stills (Claude, 2026-10-07).
##   Godot --path . --script res://tools/debug/arena_capture.gd
## Walks Kithflare, fires each starter's attack, and captures mid-attack and impact.
var OUT := ProjectSettings.globalize_path("user://arena_captures/")
var arena: Node2D

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await create_timer(0.3).timeout
	await _snap("1_start")
	arena.debug_input = Vector2(1, -0.4)
	await create_timer(0.25).timeout
	await _snap("2_walk")
	arena.debug_input = Vector2.ZERO
	arena.attack()
	await create_timer(0.12).timeout
	await _snap("3_fireball")
	await create_timer(0.35).timeout
	await _snap("4_fire_hit")
	arena._player = 2
	arena._facing[2] = "w"
	await create_timer(0.7).timeout
	arena.attack()
	await create_timer(0.18).timeout
	await _snap("5_beam")
	arena._player = 1
	arena._facing[1] = "s"
	await create_timer(0.7).timeout
	arena.attack()
	await create_timer(0.25).timeout
	await _snap("6_seed")
	await create_timer(0.3).timeout
	await _snap("7_seed_burst")
	arena._set_arena(1)
	await create_timer(0.3).timeout
	await _snap("8_stone_arena")
	quit()

func _snap(n: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + n + ".png")
	print("saved ", n)
