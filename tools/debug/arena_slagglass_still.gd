extends SceneTree
## One still of the redesigned Slagglass in the arena (Claude, 2026-10-08), between Fusern and
## Vitrecrag against the Ironvent line, walking, so all three stages of the kiln line show.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_slagglass_still.gd
## Stills to docs/creatures/slagglass-redo-2026-10-08/arena_*.png.

const OUT := "res://docs/creatures/slagglass-redo-2026-10-08/"
var arena: Node2D

func _initialize() -> void:
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	arena.auto_you = true
	seed(5)
	arena.team_size = 3
	arena._you = 4; arena._you_stage = 1       # Slagglass leads; its team is the kiln line's neighbours
	arena._rival = 3; arena._rival_stage = 1   # Clinkerhide
	arena._new_match()
	for k in 45:
		await process_frame
	root.get_texture().get_image().save_png(OUT + "arena_walk.png")
	arena.team_size = 1
	for stage in 3:
		arena._you_stage = stage
		arena._new_match()
		for k in 6:
			await process_frame
		root.get_texture().get_image().save_png(OUT + "arena_stage%d.png" % (stage + 1))
	print("Slagglass stills saved")
	quit()
