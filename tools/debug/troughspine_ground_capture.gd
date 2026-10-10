extends SceneTree
## Troughspine standing, from all eight sides, beside Kithflare for scale (Claude, 2026-10-10; Preston:
## its back view floated). One still per facing, tiled into one sheet. Windowed only.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/troughspine_ground_capture.gd

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[10, 0], [0, 0]]
	root.add_child(dg)
	for k in 20:
		await process_frame
	var t: Dictionary = dg.ents[0]
	for e in dg.ents.slice(1):   # everyone else out of the shot
		e["node"].visible = false
	var nudge := float(OS.get_environment("SHADOW_NUDGE")) if OS.get_environment("SHADOW_NUDGE") != "" else -1.0
	if nudge >= 0.0:
		t["node"].get_child(0).position.y = nudge
	var sheet := Image.create(8 * 160, 160, false, Image.FORMAT_RGBA8)
	var faces := ["s", "se", "e", "ne", "n", "nw", "w", "sw"]
	for k in faces.size():
		t["facing"] = faces[k]
		dg._place(t)
		for f in 4:
			await process_frame
		await RenderingServer.frame_post_draw
		var shot := root.get_texture().get_image()
		shot.convert(Image.FORMAT_RGBA8)
		sheet.blit_rect(shot, Rect2i(576 - 80, 250, 160, 160), Vector2i(k * 160, 0))
	sheet.save_png(ProjectSettings.globalize_path("res://docs/design/boss-intro-2026-10-10/troughspine_ground%s.png" % ("" if nudge < 0.0 else "_%s" % str(nudge))))
	print("saved troughspine_ground.png")
	quit()
