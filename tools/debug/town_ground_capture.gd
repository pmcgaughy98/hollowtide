extends SceneTree
## Highbank's painted ground on its own, the whole map, saved for review (Claude, 2026-10-10).
##   Godot --headless --path . --script res://tools/debug/town_ground_capture.gd

func _initialize() -> void:
	var img: Image = load("res://scripts/town/hub_town.gd").paint()
	img.save_png(ProjectSettings.globalize_path("res://docs/world/highbank-ground-2026-10-10/%s.png" % (OS.get_environment("NAME") if OS.get_environment("NAME") != "" else "ground")))
	print("saved ", img.get_size())
	quit()
