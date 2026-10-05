class_name VfxSprite
extends Sprite2D
## Plays a Retro Diffusion VFX sheet (Preston, 2026-10-01: VFX are the main
## effects now). The sheet is a grid of equal frames read left to right, top to
## bottom; set hframes and vframes to match. It steps at `fps` like drawn
## animation. A looping one runs until finish() is called (an emitter stopping);
## a one-shot frees itself on its last frame.

@export var fps := 16.0
@export var loop := false

var _time := 0.0
var _finishing := false


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	frame = 0


func _process(delta: float) -> void:
	# A hidden one-shot, such as a hit pop riding along during the flight,
	# must not advance. Otherwise it frees itself before the hit.
	if not visible:
		return
	_time += delta
	var count: int = hframes * vframes
	var step: int = int(_time * fps)
	if (loop and not _finishing):
		frame = step % count
		return
	if step >= count:
		queue_free()
		return
	frame = step


## Stop looping: play on to the last frame, then free. Returns the seconds that takes.
func finish() -> float:
	var count: int = hframes * vframes
	_finishing = true
	# Continue from the current frame rather than jumping back to the start.
	_time = float(frame) / fps
	return float(count - frame) / fps
