extends SceneTree
## A generated floor painted the Hollow's way (scripts/dungeon/ruin_painter.gd), saved as a PNG for review.
##   Godot --headless --path . --script res://tools/debug/ruin_paint_capture.gd

func _initialize() -> void:
	var dg_script: GDScript = load("res://scripts/dungeon/dungeon.gd")
	var c: Dictionary = dg_script.get_script_constant_map()
	var data: Dictionary = c["Gen"].generate(4242, c["RECIPE"])
	var t0 := Time.get_ticks_msec()
	var which := OS.get_environment("PAINTER") if OS.get_environment("PAINTER") != "" else "ruin_painter"
	var img: Image = load("res://scripts/dungeon/%s.gd" % which).paint(data, 24, 4242)
	print("painted %dx%d in %d ms" % [img.get_width(), img.get_height(), Time.get_ticks_msec() - t0])
	img.save_png(ProjectSettings.globalize_path("res://docs/design/hollow-ruin-2026-10-10/%s_full.png" % which))
	quit()
