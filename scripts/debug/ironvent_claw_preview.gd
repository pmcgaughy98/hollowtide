extends Node2D

const IRONVENT: CreatureData = preload("res://data/creatures/102_ironvent.tres")
const CINDERHIDE: CreatureData = preload("res://data/creatures/002_cinderhide.tres")

func _ready() -> void:
	call_deferred("_start_preview")

func _start_preview() -> void:
	$BattleScreen.start(CINDERHIDE)

func play_claw() -> void:
	$BattleScreen._attack(IRONVENT, true, IRONVENT.moves[1])

## The same contact move from the foe's side, so the front-view strike can be
## reviewed. The foe sprite here is Cinderhide; only the travel path and impact
## are being checked, not whether Cinderhide should own this move.
func play_foe_claw() -> void:
	$BattleScreen._attack(CINDERHIDE, false, IRONVENT.moves[1])
