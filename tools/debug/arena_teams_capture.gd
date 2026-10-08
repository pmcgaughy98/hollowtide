extends SceneTree
## Team-fight stills (Claude, 2026-10-07). Plays one AI-only 3v3 (and one 2v2) and saves
## the whole screen at a few moments, plus the result, to docs/creatures/arena-teams-2026-10-07/:
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_teams_capture.gd

const OUT := "res://docs/creatures/arena-teams-2026-10-07/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var arena: Node2D = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	arena.auto_you = true
	for size in [3, 2]:
		seed(7 + size)
		arena.team_size = size
		arena._you = 0
		arena._rival = 0
		arena._you_stage = 2
		arena._rival_stage = 2
		arena._new_match()
		var shots := [60, 240, 480]
		var frames := 0
		while arena._winner < 0 and frames < 3600:
			await process_frame
			frames += 1
			if frames in shots:
				_save("%dv%d_t%02ds" % [size, size, frames / 30])
		for k in 45:
			await process_frame
		_save("%dv%d_end" % [size, size])
		var line := "%dv%d: winner team %d after %.0f s." % [size, size, arena._winner, frames / 30.0]
		for f in arena._fighters:
			line += "  [team %d] %s HP %d/%d dealt %d%s" % [f["team"], f["name"], f["hp"], f["max_hp"], f["dealt"],
				(" down at %.0f s" % f["down_at"]) if f["down_at"] >= 0.0 else ""]
		print(line)
	quit()


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
