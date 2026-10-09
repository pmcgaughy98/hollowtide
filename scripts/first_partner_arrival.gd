extends CanvasLayer
## A short non-blocking welcome showing the partner actually added to the run.
var creature: CreatureData
var portrait_frames: SpriteFrames
var accent := Color.WHITE
var reduce_motion := false
var _card: PanelContainer
var _clock := 0.0
var _closing := false

func _ready() -> void:
	name = "FirstPartnerArrival"
	layer = 30
	_card = PanelContainer.new()
	_card.name = "WelcomeCard"
	_card.position = Vector2(752, 478)
	_card.custom_minimum_size = Vector2(352, 118)
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := StyleBoxFlat.new()
	box.bg_color = Color("#1f1b36")
	box.border_color = accent
	box.set_border_width_all(2)
	box.set_content_margin_all(14)
	_card.add_theme_stylebox_override("panel", box)
	add_child(_card)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 14)
	_card.add_child(row)
	var portrait := preload("res://scripts/creature_portrait.gd").new()
	portrait.name = "PartnerPortrait"
	portrait.frames = portrait_frames
	portrait.reduce_motion = reduce_motion
	portrait.custom_minimum_size = Vector2(80, 80)
	row.add_child(portrait)
	var list := VBoxContainer.new()
	list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(list)
	list.add_child(_label("YOUR FIRST PARTNER", 18, Color("#bdadc7")))
	list.add_child(_label(creature.creature_name, 28, accent))
	list.add_child(_label(creature.essence_name(), 20, Color("#fff4e8")))
	list.add_child(_label("P to view your party", 18, Color("#bdadc7")))
	if not reduce_motion:
		_card.modulate.a = 0.0
		create_tween().tween_property(_card, "modulate:a", 1.0, 0.35)

func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", preload("res://assets/fonts/AlegreyaSansSC-Bold.ttf"))
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _process(delta: float) -> void:
	_clock += delta
	if _clock >= 4.5 and not _closing:
		_closing = true
		if not reduce_motion:
			await create_tween().tween_property(_card, "modulate:a", 0.0, 0.35).finished
		queue_free()
