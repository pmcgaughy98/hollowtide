extends Node2D

## Ironvent's Furnace Roar release as a trick shot (Preston, 2026-09-29): after
## the whole blowdown build-up, all that leaves the jaws is one small ember (F1
## from Preston's effect sheet). It drifts to the target, lands, and sits there
## flickering like a dud for a beat... then the move's impact detonates it.
## (Earlier versions sent the three heavy arcs, F3; Preston found them
## overwhelming.)
##
## Used as a move's attack_emitter, so the battle scales it by the creature's
## zoom and mirrors it for the foe: positions here are in the sheet's pixels.
## The battle calls aim_at() with the target; the ember moves toward it without
## rotating, so the pixels stay square.

@export var ember: Texture2D    # F1: the small glow
@export var puff_seconds := 0.12
## Seconds the ember takes to drift to the target, and how long it sits there
## as a dud before the detonation (match the move's pause frame).
@export var travel_seconds := 0.48
@export var dud_seconds := 0.4

const EMBER_CENTRE_X := 11.0
const EMBER_CENTRE_Y := 16.0
const CELL_CENTRE := Vector2(32, 16)

var _time := 0.0
var _target := Vector2(120, 0)
var _sprite: Sprite2D


## The battle calls this with the target's position on screen.
func aim_at(global_point: Vector2) -> void:
	_target = to_local(global_point)


func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = ember
	_sprite.offset = CELL_CENTRE - Vector2(EMBER_CENTRE_X, EMBER_CENTRE_Y)
	add_child(_sprite)


func _process(delta: float) -> void:
	_time += delta
	if _time < puff_seconds:
		return  # a small puff at the jaws
	var t: float = (_time - puff_seconds) / travel_seconds
	if t < 1.0:
		# A lazy drift with a slight bob, nothing like a heavy shot.
		var p: Vector2 = _target * t + Vector2(0, sin(t * PI * 2.0) * 4.0)
		_sprite.position = p.round()
		return
	var sat: float = _time - puff_seconds - travel_seconds
	if sat < dud_seconds:
		# The dud: it sits on the target, flickering, as if nothing will happen.
		_sprite.position = _target.round()
		_sprite.visible = int(sat / 0.06) % 3 != 2
		return
	_sprite.visible = false  # the detonation (the move's impact) takes over
	if sat > dud_seconds + 0.5:
		queue_free()
