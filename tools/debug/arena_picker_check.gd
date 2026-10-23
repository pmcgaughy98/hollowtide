extends SceneTree
## The matchup picker (Claude, 2026-10-09): every slot on both sides is chosen, who you steer and
## your charm land on the right creature, the map and rocks follow, and a 2v2 works.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_picker_check.gd
## Stills to docs/creatures/arena-picker-2026-10-09/.

const OUT := "res://docs/creatures/arena-picker-2026-10-09/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var picker: Node2D = load("res://scenes/move_preview.tscn").instantiate()
	root.add_child(picker)
	await process_frame
	await process_frame
	_save("picker")
	# A 3v3 with every slot chosen: Warden, Galeshear, Starward against Scourmaw, Oxbowarchon, Vitrecrag.
	picker._size = 3
	picker._teams = [[[7, 2], [8, 2], [6, 2]], [[2, 2], [5, 2], [4, 2]]]
	picker._control = 1
	picker._charm = "aegis"
	picker._map = 1
	picker._rocks = false
	picker._build()
	await process_frame
	_save("picker_filled")
	picker.start_fight()
	await process_frame
	await process_frame
	var arena: Node2D = picker._arena
	var names := []
	for f in arena._fighters:
		names.append("%s:%s" % ["you" if f["team"] == 0 else "foe", f["name"]])
	print("3v3 from the picker: %s; you steer %s with charm %s; arena %d, rocks %d" % [str(names), arena._fighters[arena.controlled]["name"], arena._fighters[arena.controlled]["charm"], arena._arena, arena._rocks.size()])
	_save("fight_3v3")
	# Escape back, then a 2v2 with one slot left for the random fill.
	arena.queue_free()
	picker._arena = null
	picker._ui.visible = true
	picker._size = 2
	picker._teams = [[[0, 0], null, null], [[3, 1], [1, 2], null]]
	picker._control = 0
	picker._charm = ""
	picker._map = 0
	picker._rocks = true
	picker._build()
	await process_frame
	picker.start_fight()
	await process_frame
	await process_frame
	arena = picker._arena
	names.clear()
	for f in arena._fighters:
		names.append("%s:%s" % ["you" if f["team"] == 0 else "foe", f["name"]])
	print("2v2 with an empty slot filled at random: %s; you steer %s (charm %s, its role's)" % [str(names), arena._fighters[arena.controlled]["name"], arena._fighters[arena.controlled]["charm"]])
	_save("fight_2v2")
	quit()


func _save(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return   # no rendered image headless; stills need a window
	root.get_texture().get_image().save_png(OUT + name + ".png")
