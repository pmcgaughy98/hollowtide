extends Node2D

## Vitrecrag as the wild foe, so its front view plays the drawn Molten Glass
## pour with the head pulling into the shell. Your side shows Vitrecrag's back,
## where drawn attack frames are skipped, so the pour is only visible here.

const VITRECRAG: CreatureData = preload("res://data/creatures/108_vitrecrag.tres")

func _ready() -> void:
	call_deferred("_start_preview")

## Press Play on this scene and the pour repeats a few times on its own.
## Four hits keep Cinderhide standing, so the battle never ends mid-preview.
func _start_preview() -> void:
	$BattleScreen.start(VITRECRAG)
	for i in 4:
		await get_tree().create_timer(2.5, true).timeout
		await play_foe_molten_glass()

func play_foe_molten_glass() -> void:
	await $BattleScreen._attack(VITRECRAG, false, VITRECRAG.moves[0])
