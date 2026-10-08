extends SceneTree
## Stages each arena effect at a known spot and saves stills at full size (Claude, 2026-10-07).
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_vfx_check.gd
var OUT := ProjectSettings.globalize_path("user://arena_captures/")
var arena: Node2D

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	await process_frame
	arena._you = 0; arena._you_stage = 2; arena._rival = 2; arena._rival_stage = 0
	arena._new_match()
	arena._fighters[0]["body"].position = Vector2(80, 120)
	arena._fighters[1]["body"].position = Vector2(330, 180)
	# A fireball in flight, a beam, and two impacts (fire and earth), all at once.
	arena._effects.append({"kind": "fireball", "owner": 0, "pos": Vector2(140, 100), "vel": Vector2(170, 0), "life": 5.0, "trail": [], "damage": 0})
	arena._effects.append({"kind": "beam", "owner": 1, "from": Vector2(150, 160), "dir": Vector2(1, -0.2).normalized(), "len": 0.0, "life": 5.0, "damage": 0, "reach": 120.0})
	await create_timer(0.35).timeout
	arena._burst(Vector2(250, 110), Color("#ffb347"), Color("#ff5a1f"), 26.0, true, "fire_burst")
	arena._burst(Vector2(110, 175), Color("#b7e07a"), Color("#7a5a32"), 28.0, true, "earth_burst")
	await create_timer(0.15).timeout
	await _snap("vfx_a")
	await create_timer(0.25).timeout
	await _snap("vfx_b")
	quit()

func _snap(n: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + n + ".png")
	print("saved ", n)
