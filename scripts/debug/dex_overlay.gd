extends CanvasLayer

## Debug tool, not game UI. Press F1 while playing to list every creature the
## project can load, with the roster check result at the top.
##
## This is deliberately ugly and deliberately disposable. When there is a real
## Dex screen, delete this node from main.tscn and this file with it. It exists
## so the creature data is something you can look at rather than take on faith.

const HEADINGS := ["No.", "Name", "Essence", "Own", "HP", "ATK", "DEF", "SPD"]

var _status: Label
var _grid: GridContainer


func _ready() -> void:
	layer = 100
	visible = false

	var background := ColorRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.04, 0.05, 0.09, 0.95)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 40)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)

	column.add_child(_make_label("CREATURE ROSTER      F1 to close",
		Color(0.85, 0.92, 1.0)))

	_status = _make_label("", Color(0.7, 0.75, 0.85))
	column.add_child(_status)

	_grid = GridContainer.new()
	_grid.columns = HEADINGS.size()
	_grid.add_theme_constant_override("h_separation", 28)
	_grid.add_theme_constant_override("v_separation", 4)
	column.add_child(_grid)

	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_dex"):
		visible = not visible
		if visible:
			_refresh()
		get_viewport().set_input_as_handled()


func _refresh() -> void:
	for child in _grid.get_children():
		child.queue_free()
		_grid.remove_child(child)

	var creatures := CreatureRoster.load_all()
	var problems := CreatureRoster.validate(creatures)
	# The evolution rules live in their own check. Append them so the overlay
	# reports a bad line instead of only the single-creature fields.
	problems.append_array(CreatureRoster.validate_evolutions(creatures))
	problems.append_array(CreatureRoster.validate_move_gates(creatures))

	if problems.is_empty():
		_status.text = "%d creatures loaded. All checks passed.   Party: %d / %d" % [
			creatures.size(), PlayerParty.caught.size(), PlayerParty.MAX_PARTY]
		_status.add_theme_color_override("font_color", Color(0.49, 0.88, 0.54))
	else:
		_status.text = "%d problems: %s" % [problems.size(), ", ".join(problems)]
		_status.add_theme_color_override("font_color", Color(1.0, 0.54, 0.48))

	for heading in HEADINGS:
		_grid.add_child(_make_label(heading, Color(0.55, 0.62, 0.75)))

	for c in creatures:
		_grid.add_child(_make_label(c.dex_number, Color(0.55, 0.62, 0.75)))
		_grid.add_child(_make_label(c.creature_name, Color(1, 1, 1)))
		_grid.add_child(_make_label(c.essence_name(), Color(0.75, 0.85, 1.0)))
		var owned := PlayerParty.count_of(c)
		_grid.add_child(_make_label(str(owned) if owned > 0 else "-",
			Color(0.49, 0.88, 0.54) if owned > 0 else Color(0.4, 0.44, 0.52)))
		for stat in [c.base_hp, c.base_attack, c.base_defense, c.base_speed]:
			_grid.add_child(_make_label(str(stat), Color(0.8, 0.8, 0.85)))


func _make_label(text: String, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	return label
