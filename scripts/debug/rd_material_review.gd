extends Node2D

## Inspect the six new RD models in the actual battle, from both camera sides.
## Keys 1 to 6 choose a form. The review's party belongs only to this run.
const FORMS: Array[CreatureData] = [
	preload("res://data/creatures/103_kithflare.tres"),
	preload("res://data/retired_creatures/104_wayburn.tres"),
	preload("res://data/retired_creatures/105_coalcrest.tres"),
	preload("res://data/creatures/106_fusern.tres"),
	preload("res://data/creatures/107_slagglass.tres"),
	preload("res://data/creatures/108_vitrecrag.tres"),
]
var review_species_index := 5


func _ready() -> void:
	# Review controls remain available while BattleScreen pauses the world.
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("show_species", review_species_index)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key: int = event.keycode
		if key >= KEY_1 and key <= KEY_6:
			show_species(key - KEY_1)


func show_species(index: int) -> void:
	if index < 0 or index >= FORMS.size():
		return
	review_species_index = index
	PlayerParty.caught.clear()
	PlayerParty.active_slot = -1
	$BattleScreen._phase = $BattleScreen.Phase.OVER
	$BattleScreen.player_creature = FORMS[index]
	$BattleScreen.start(FORMS[index])

