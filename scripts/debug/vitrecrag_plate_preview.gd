extends Node2D

## Vitrecrag as the wild foe using Plate Lunge on Cinderhide, four times on
## Play: brace and draw back, charge with the plate sliding out, hit at full
## extension, plate retracts on the way home.

const VITRECRAG: CreatureData = preload("res://data/creatures/108_vitrecrag.tres")

func _ready() -> void:
	call_deferred("_start_preview")

func _start_preview() -> void:
	$BattleScreen.start(VITRECRAG)
	for i in 4:
		await get_tree().create_timer(2.5, true).timeout
		await play_foe_plate_lunge()

func play_foe_plate_lunge() -> void:
	await $BattleScreen._attack(VITRECRAG, false, VITRECRAG.moves[2])
