extends SceneTree
## Every starter's faces on their face backgrounds, in the game's own portrait frame (Claude, 2026-10-10),
## one row per creature, as the hand-made portrait sheets lay them out. Windowed only.
##   Godot --path . --script res://tools/debug/faces_grid_capture.gd

const UI := preload("res://scripts/ui/ui_style.gd")
var FORMS: Array = (OS.get_environment("FORMS") if OS.get_environment("FORMS") != "" else "kithflare,tallowroot,rimefin").split(",")
const FACES := ["normal", "happy", "joyous", "surprised", "angry", "sad", "worried", "determined"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var c := Control.new()
	c.size = Vector2(1152, 648)
	c.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.add_child(c)
	c.draw.connect(func() -> void:
		c.draw_rect(Rect2(Vector2.ZERO, c.size), Color("#1d2420"))
		for row in FORMS.size():
			for col in FACES.size():
				var face: String = FACES[col]
				var tex: Texture2D = UI.dialogue_portrait(FORMS[row] if face == "normal" else "%s:%s" % [FORMS[row], face])
				UI.portrait(c, Rect2(Vector2(30 + col * 140, 40 + row * 200), Vector2(120, 120)), tex, false, face)
				UI.text(c, Vector2(30 + col * 140, 190 + row * 200), face, 16, UI.MUTED, 120, HORIZONTAL_ALIGNMENT_CENTER))
	for k in 6:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://docs/ui/expressions-2026-10-10/faces_grid_%s.png" % FORMS[0]))
	print("saved")
	quit()
