extends Node2D

const VITRECRAG: CreatureData = preload("res://data/creatures/108_vitrecrag.tres")
const CINDERHIDE: CreatureData = preload("res://data/creatures/002_cinderhide.tres")

func _ready() -> void:
	call_deferred("_start_preview")

func _start_preview() -> void:
	$BattleScreen.start(CINDERHIDE)

func play_molten_glass() -> void:
	$BattleScreen._attack(VITRECRAG, true, VITRECRAG.moves[0])

func play_molten_beam() -> void:
	$BattleScreen._attack(VITRECRAG, true, VITRECRAG.moves[1])

func play_molten_cannon() -> void:
	$BattleScreen._attack(VITRECRAG, true, VITRECRAG.moves[3])
