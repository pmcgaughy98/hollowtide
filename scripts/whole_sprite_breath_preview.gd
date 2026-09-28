extends Node2D

## Preview of the same whole-sprite idle motion used by battle_screen.gd.
## Keep depth and period aligned with the creature's data resource.
@export var breath_depth: float = 0.026
@export var breath_period: float = 1.9

const INHALE_SHARE := 0.55

@onready var sprite: Sprite2D = $Sprite
var _time: float = 0.0
var _home_position: Vector2
var _home_scale: Vector2


func _ready() -> void:
	_home_position = sprite.position
	_home_scale = sprite.scale


func _process(delta: float) -> void:
	if sprite.texture == null:
		return
	_time += delta
	var cycle: float = fposmod(_time / maxf(0.2, breath_period), 1.0)
	var half: float
	if cycle < INHALE_SHARE:
		half = 0.5 * cycle / INHALE_SHARE
	else:
		half = 0.5 + 0.5 * (cycle - INHALE_SHARE) / (1.0 - INHALE_SHARE)
	var breathe: float = -cos(TAU * half)
	var depth: float = maxf(0.0, breath_depth)
	var tall: float = _home_scale.y * (1.0 + breathe * depth)
	sprite.scale = Vector2(_home_scale.x * (1.0 - breathe * depth * 0.5), tall)
	sprite.position = _home_position + Vector2(0.0, roundf(-sprite.texture.get_height() * (tall - _home_scale.y) * 0.5))
