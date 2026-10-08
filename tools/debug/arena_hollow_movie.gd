extends SceneTree
## Records Scourmaw's Hollow absence and Phase, one PNG per frame (Claude, 2026-10-07).
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_hollow_movie.gd
## You as Scourmaw glide a circle and phase while Stormwick fires; then you as Kithflare
## fire at a rival Scourmaw, which phases through.
var OUT := ProjectSettings.globalize_path("user://arena_hollow_movie/")
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
	arena._you = 2; arena._you_stage = 2; arena._rival = 0; arena._rival_stage = 2
	arena._new_match()
	for i in 180:
		var a := TAU * i / 140.0
		arena.debug_input = Vector2(cos(a), sin(a)) if i < 150 else Vector2.ZERO
		if i in [40, 110]:
			arena.phase(0)
		if i == 70:
			var me: Dictionary = arena._fighters[0]
			me["facing"] = arena._facing_of(arena._fighters[1]["body"].position - me["body"].position)
			arena.attack(0)
		await _frame()
	arena._you = 0; arena._you_stage = 0; arena._rival = 2; arena._rival_stage = 2
	arena._new_match()
	for i in 120:
		arena.debug_input = Vector2.ZERO
		if i % 25 == 5:
			var me: Dictionary = arena._fighters[0]
			me["facing"] = arena._facing_of(arena._fighters[1]["body"].position - me["body"].position)
			arena.attack(0)
		await _frame()
	print("frames ", n, "  rival hp ", arena._fighters[1]["hp"], "/", arena._fighters[1]["max_hp"])
	quit()

func _frame() -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + "f%04d.png" % n)
	n += 1
