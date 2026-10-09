extends SceneTree
const OUTPUT := "D:/dev/hollowtide-opening-20261008/review/front-idle-portraits.png"

func _initialize() -> void:
	_run()

func _run() -> void:
	root.content_scale_size = Vector2i(1152,648)
	root.size = Vector2i(1152,648)
	var layer := CanvasLayer.new()
	root.add_child.call_deferred(layer)
	await process_frame
	var back := ColorRect.new()
	back.size = Vector2(1152,648)
	back.color = Color("#18172c")
	layer.add_child(back)
	var title := _label("Front-view idle portraits", 40)
	title.position = Vector2(64,40)
	layer.add_child(title)
	var names := ["Kithflare", "Tallowroot", "Rimefin"]
	var colors := [Color("#ffb881"),Color("#bbd991"),Color("#9fd5ef")]
	for i in 3:
		var panel := PanelContainer.new()
		panel.position = Vector2(64 + i * 348, 140)
		panel.custom_minimum_size = Vector2(324,408)
		var box := StyleBoxFlat.new()
		box.bg_color = Color("#1f1b36")
		box.border_color = colors[i]
		box.set_border_width_all(2)
		box.set_content_margin_all(24)
		panel.add_theme_stylebox_override("panel",box)
		layer.add_child(panel)
		var list := VBoxContainer.new()
		list.add_theme_constant_override("separation",24)
		panel.add_child(list)
		var portrait := preload("res://scripts/creature_portrait.gd").new()
		portrait.frames = load("res://data/portraits/"+names[i].to_lower()+"_front_idle.tres")
		portrait.custom_minimum_size = Vector2(256,256)
		list.add_child(portrait)
		var caption := _label(names[i],34)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.modulate = colors[i]
		list.add_child(caption)
	var note := _label("8 original front frames per portrait / Source artwork preserved",22)
	note.position = Vector2(64,588)
	note.modulate = Color("#bdadc7")
	layer.add_child(note)
	for i in 20: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUTPUT)
	layer.queue_free()
	await process_frame
	quit()

func _label(text: String, size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font",preload("res://assets/fonts/AlegreyaSansSC-Bold.ttf"))
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_color_override("font_color",Color("#fff4e8"))
	return label
