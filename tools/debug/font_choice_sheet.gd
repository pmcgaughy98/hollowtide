extends SceneTree
## Dialogue font candidates side by side in the real box (Claude, 2026-10-10; Preston: Pixelify's T and k are
## hard to make out). Each at a size on its own pixel grid. Windowed only:
##   Godot --path . --fixed-fps 30 --script res://tools/debug/font_choice_sheet.gd
## Writes docs/ui/type-2026-10-10/font_choice.png.

const UI := preload("res://scripts/ui/ui_style.gd")
const LINE := "Take this to Kithflare at the dock. Thank Starward, okay?"
const CANDIDATES := [
	["A  Pixelify Sans (now)", "res://assets/fonts/PixelifySans-Variable.ttf", 10.93, 3],
	["B  VT323, double", "res://assets/fonts/VT323-Regular.ttf", 20.0, 2],
	["C  DotGothic16", "res://assets/fonts/DotGothic16-Regular.ttf", 16.0, 1],
	["D  DotGothic16, double", "res://assets/fonts/DotGothic16-Regular.ttf", 16.0, 2],
	["E  Jersey 10", "res://assets/fonts/Jersey10-Regular.ttf", 18.65, 2],
]


class Sheet extends Node2D:
	var fonts: Array = []
	func _draw() -> void:
		draw_rect(Rect2(0, 0, 1152, 648), Color("#1b211c"))
		for k in fonts.size():
			var c: Array = fonts[k]
			var box := Rect2(24, 12 + k * 126, 1104, 116)
			UI.panel(self, box, 0.95)
			UI.say(self, box.position + Vector2(24, 26), String(c[0]), "label", UI.EDGE_LIGHT)
			var at := (box.position + Vector2(26, 76)).round()
			draw_string(c[1], at + Vector2(2, 2), LINE, HORIZONTAL_ALIGNMENT_LEFT, -1, c[2], UI.SHADOW)
			draw_string(c[1], at, LINE, HORIZONTAL_ALIGNMENT_LEFT, -1, c[2], UI.TEXT)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.content_scale_size = Vector2i(1152, 648)
	var sheet := Sheet.new()
	for c in CANDIDATES:
		var base: FontFile = load(c[1]).duplicate()
		base.antialiasing = TextServer.FONT_ANTIALIASING_NONE
		base.hinting = TextServer.HINTING_NONE
		base.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
		base.oversampling = 1.0
		var v := FontVariation.new()
		v.base_font = base
		var size := int(round(float(c[2]) * float(c[3])))
		var k: float = float(c[2]) * float(c[3]) / float(size)
		v.variation_transform = Transform2D(0.0, Vector2(k, k), 0.0, Vector2.ZERO)
		var ts := TextServerManager.get_primary_interface()
		v.opentype_features = {ts.name_to_tag("liga"): 0}
		sheet.fonts.append([c[0], v, size])
	root.add_child(sheet)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://docs/ui/type-2026-10-10/font_choice.png"))
	print("FONT CHOICE: saved")
	quit()
