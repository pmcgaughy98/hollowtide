extends CanvasLayer

## Overworld control for choosing which owned creature enters the next battle.
##
## Deliberately one button rather than a whole party screen. The party holds at
## most six, and the useful thing right now is being able to change who fights
## without opening anything. A real party screen replaces this later;
## PlayerParty.select() is the part that already works, and this is only a face
## on it.
##
## It hides itself during battle for free. The battle screen raises a
## full-screen backdrop on a higher layer and pauses the tree, so this is both
## covered and unable to take a press while a fight is on.

## The creature a fresh game starts with, so the party exists from the first
## frame rather than only after the first battle. Assigned in the Inspector.
@export var starter_creature: CreatureData

var _name_label: Label
var _essence_label: Label
var _switch_button: Button


func _ready() -> void:
	layer = 10
	_build_ui()
	# The same call the battle screen makes, so whichever of the two loads first
	# the starter exists. ensure_starter() does nothing once the party is not
	# empty, so this cannot add a second copy.
	if starter_creature != null:
		PlayerParty.ensure_starter(starter_creature)
	PlayerParty.party_changed.connect(_refresh)
	_refresh()


func _build_ui() -> void:
	var panel := PanelContainer.new()

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	panel.add_child(row)

	var names := VBoxContainer.new()
	names.add_theme_constant_override("separation", 2)
	row.add_child(names)

	# Every size here is set explicitly. The first version left the button and
	# the name label on the theme defaults, which made the panel read as a tiny
	# scrap in the corner and the switch hard to click.
	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 22)
	_essence_label = Label.new()
	_essence_label.add_theme_font_size_override("font_size", 14)
	names.add_child(_name_label)
	names.add_child(_essence_label)

	_switch_button = Button.new()
	_switch_button.custom_minimum_size = Vector2(200, 52)
	_switch_button.add_theme_font_size_override("font_size", 18)
	_switch_button.pressed.connect(_on_switch_pressed)
	row.add_child(_switch_button)

	add_child(panel)
	# Anchored only after the contents exist, so the panel is measured from what
	# it actually holds. Anchoring it while it was still empty gave it a zero
	# size, and it then grew downward from the corner and hung off the bottom of
	# the screen. Growing upward and rightward means the corner it is pinned to
	# can never be pushed offscreen, whatever the contents turn out to be.
	panel.grow_horizontal = Control.GROW_DIRECTION_END
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	panel.set_anchors_and_offsets_preset(
		Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, 20)


## Cycles to the next owned creature, wrapping around at the end.
##
## Wrapping rather than stepping back and forth, because with one button there is
## no way to say "the other direction" and the party is small enough that going
## all the way round is a couple of presses.
func _on_switch_pressed() -> void:
	var count: int = PlayerParty.caught.size()
	if count <= 1:
		return
	PlayerParty.select((PlayerParty.active_slot + 1) % count)


func _refresh() -> void:
	var count: int = PlayerParty.caught.size()
	var creature: CreatureData = PlayerParty.active_creature()

	if creature == null:
		_name_label.text = "No creature yet"
		_essence_label.text = ""
		_switch_button.text = "Switch"
		_switch_button.disabled = true
		return

	_name_label.text = creature.creature_name
	_essence_label.text = creature.essence_name()
	_switch_button.text = "Switch  %d/%d" % [PlayerParty.active_slot + 1, count]
	# With one creature there is nothing to switch to, so the button says so
	# instead of appearing to do something and doing nothing.
	_switch_button.disabled = count <= 1
