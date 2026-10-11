extends SceneTree
## A sheet of Hollowtide's type roles (Claude, 2026-10-10; scripts/ui/ui_style.gd TYPE): each role's face at
## its own size on a moss panel, a button in its four states, and the dungeon's arrival banner and HUD.
## Windowed only (it saves pictures):
##   Godot --path . --fixed-fps 30 --script res://tools/debug/type_specimen.gd
## Writes docs/ui/type-2026-10-10/specimen.png and dungeon_hud.png.

const UI := preload("res://scripts/ui/ui_style.gd")
const OUT := "res://docs/ui/type-2026-10-10/"


class Sheet extends Node2D:
	func _draw() -> void:
		draw_rect(Rect2(0, 0, 1152, 648), Color("#1b211c"))
		UI.panel(self, Rect2(24, 20, 1104, 608))
		var rows := [
			["title", "ROOTBANK WARREN", "Place names, banners, headings"],
			["story", "Deliver it, and you are both runners of the Wayline.", "Dialogue and narration"],
			["body", "Kithflare used Ember Claw! Rimefin took 12 damage.", "Message log, descriptions, panels"],
			["button", "CROSS TO THE HOLLOW", "Buttons and menu rows"],
			["label", "LV 5   IQ 7   [SHIFT] TURN", "Small labels, key hints"],
			["number", "36/42  128  B3F", "HP, levels, counts"],
		]
		var y := 88.0
		for r in rows:
			var role: String = r[0]
			UI.say(self, Vector2(60, y), r[1], role, UI.EDGE_LIGHT if role == "title" else UI.TEXT)
			UI.say(self, Vector2(60, y + 26), "%s  -  %s, %d px" % [String(r[2]), role, UI.type_size(role)], "label", UI.MUTED)
			y += 84.0
		UI.nameplate(self, Vector2(820, 120), "Starward")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.content_scale_size = Vector2i(1152, 648)
	var sheet := Sheet.new()
	root.add_child(sheet)
	# A button in each state, as menus show them.
	var states := [["NORMAL", ""], ["CHOSEN", "focus"], ["PRESSED", "pressed"], ["CANNOT", "disabled"]]
	for k in states.size():
		var b := Button.new()
		b.text = states[k][0]
		b.position = Vector2(560 + k * 136, 360)
		b.custom_minimum_size = Vector2(124, 54)
		var box: StyleBox = UI.frame("panel").duplicate()
		b.add_theme_stylebox_override("normal", box)
		var lit: StyleBox = UI.frame("panel_focus").duplicate()
		for s in ["focus", "hover", "pressed"]:
			b.add_theme_stylebox_override(s, lit)
		UI.style_button(b)
		match states[k][1]:
			"focus":
				b.add_theme_color_override("font_color", UI.EDGE_LIGHT)
				b.add_theme_stylebox_override("normal", lit)
			"pressed":
				b.toggle_mode = true
				b.button_pressed = true
			"disabled":
				b.disabled = true
		sheet.add_child(b)
	await _frames(4)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + "specimen.png"))
	sheet.queue_free()

	# The dungeon on arrival: the place-name banner and the HUD.
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.poll_input = false
	dg.floor_seed = 4242
	root.add_child(dg)
	await _frames(12)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + "dungeon_hud.png"))
	print("TYPE SPECIMEN: saved")
	quit()


func _frames(n: int) -> void:
	for k in n:
		await process_frame
