extends Node2D

## Standalone review scene: choose one of the nine illustrated Ember forms and
## try its four moves against the same form. Open this scene and run it in Godot.
const CREATURE_FILES = [
	"002_cinderhide.tres",
	"101_clinkerhide.tres",
	"102_ironvent.tres",
	"103_kithflare.tres",
	"106_fusern.tres",
	"107_slagglass.tres",
	"108_vitrecrag.tres",
]

@onready var _battle: CanvasLayer = $BattleScreen


func _ready() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.06, 0.07, 0.12)
	backdrop.size = get_viewport_rect().size
	add_child(backdrop)

	var title := Label.new()
	title.text = "HOLLOWTIDE  /  EMBER MOVE PREVIEW"
	title.position = Vector2(80, 60)
	title.add_theme_font_size_override("font_size", 30)
	add_child(title)

	var note := Label.new()
	note.text = "Choose a creature. Each battle shows its four moves and imported Forge effects. Flee returns here."
	note.position = Vector2(80, 112)
	note.add_theme_font_size_override("font_size", 17)
	add_child(note)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.position = Vector2(80, 185)
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	add_child(grid)

	for file_name in CREATURE_FILES:
		var creature: CreatureData = load("res://data/creatures/" + file_name)
		if creature == null:
			continue
		var button := Button.new()
		button.text = creature.creature_name
		button.custom_minimum_size = Vector2(240, 72)
		button.pressed.connect(_preview.bind(creature))
		grid.add_child(button)


func _preview(creature: CreatureData) -> void:
	_battle.set("player_creature", creature)
	_battle.call("start", creature)
