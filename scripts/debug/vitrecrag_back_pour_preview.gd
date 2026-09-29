extends Node2D

## Vitrecrag on the player's side, seen from behind, pouring Molten Glass at a
## wild Cinderhide. Press Play and it repeats four times on its own. This is
## the view a partner creature would also use in a future 2v2 battle.

const VITRECRAG: CreatureData = preload("res://data/creatures/108_vitrecrag.tres")
const CINDERHIDE: CreatureData = preload("res://data/creatures/002_cinderhide.tres")

func _ready() -> void:
	call_deferred("_start_preview")

func _start_preview() -> void:
	$BattleScreen.start(CINDERHIDE)
	for i in 4:
		await get_tree().create_timer(2.5, true).timeout
		await play_molten_glass()

func play_molten_glass() -> void:
	await $BattleScreen._attack(VITRECRAG, true, VITRECRAG.moves[0])
