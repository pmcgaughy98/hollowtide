extends Node2D

## Oxbowarchon as the wild foe firing Kingstone Rail at Cinderhide, three times
## on Play: the rails swing up to the sky, the sphere builds between them while
## it braces, it releases, and the slug comes down on the opponent.

const OXBOWARCHON: CreatureData = preload("res://data/creatures/903_oxbowarchon.tres")

func _ready() -> void:
	call_deferred("_start_preview")

func _start_preview() -> void:
	$BattleScreen.start(OXBOWARCHON)
	for i in 3:
		await get_tree().create_timer(2.5, true).timeout
		await $BattleScreen._attack(OXBOWARCHON, false, OXBOWARCHON.moves[0])
