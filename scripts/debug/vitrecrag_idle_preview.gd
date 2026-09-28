extends Node2D

const VITRECRAG: CreatureData = preload("res://data/creatures/108_vitrecrag.tres")

func _ready() -> void:
	call_deferred("_start_preview")

func _start_preview() -> void:
	$BattleScreen.start(VITRECRAG)
