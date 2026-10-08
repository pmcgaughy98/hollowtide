extends SceneTree
## Records evolved-form matches, one PNG per frame (Claude, 2026-10-07).
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_evolved_movie.gd
## Sparkwick vs Huskward, Stormwick vs Scourmaw, Riftfin vs Rampartroot (stone): walking
## in circles around the rival so every facing's walk plays, with attacks.
var OUT := ProjectSettings.globalize_path("user://arena_evolved_movie/")
var arena: Node2D
var n := 0

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	for f in DirAccess.get_files_at(OUT):
		DirAccess.remove_absolute(OUT + f)
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	await process_frame
	for p in [[0, 1, 1, 1, 0], [0, 2, 2, 2, 0], [2, 1, 1, 2, 1]]:
		arena._you = p[0]; arena._you_stage = p[1]; arena._rival = p[2]; arena._rival_stage = p[3]
		arena._set_arena(p[4]); arena._new_match()
		await _circle(150)
	print("frames ", n)
	quit()

## Walk a full circle (all eight facings), attacking the rival now and then.
func _circle(frames: int) -> void:
	for i in frames:
		var a := TAU * i / 120.0
		arena.debug_input = Vector2(cos(a), sin(a))
		if i % 45 == 30:
			var me: Dictionary = arena._fighters[0]
			me["facing"] = arena._facing_of(arena._fighters[1]["body"].position - me["body"].position)
			arena.debug_input = Vector2.ZERO
			arena.attack(0)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OUT + "f%04d.png" % n)
		n += 1
