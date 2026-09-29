extends Node2D

## Vitrecrag as the wild foe firing Molten Cannon at Cinderhide, four times on
## Play: head pulls in and the jaws open, the core heats through the brace, the
## cannon fires with a kick, and the glass shell arcs over and bursts.

const VITRECRAG: CreatureData = preload("res://data/creatures/108_vitrecrag.tres")

func _ready() -> void:
	call_deferred("_start_preview")

func _start_preview() -> void:
	$BattleScreen.start(VITRECRAG)
	for i in 4:
		await get_tree().create_timer(2.5, true).timeout
		await $BattleScreen._attack(VITRECRAG, false, VITRECRAG.moves[3])
