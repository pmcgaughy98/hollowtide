extends Node2D

## Ironvent as the wild foe using Furnace Roar on Cinderhide, four times on
## Play: heat fills the ridge, the head rears, the close-up cuts in, and the
## roar releases a pressure wave across the field.

const IRONVENT: CreatureData = preload("res://data/creatures/102_ironvent.tres")

func _ready() -> void:
	call_deferred("_start_preview")

func _start_preview() -> void:
	$BattleScreen.start(IRONVENT)
	for i in 4:
		await get_tree().create_timer(2.5, true).timeout
		await $BattleScreen._attack(IRONVENT, false, IRONVENT.moves[3])
