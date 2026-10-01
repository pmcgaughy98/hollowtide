extends CharacterBody2D

## Walking speed in pixels per second.
## One tile is 16 pixels wide, so 80 works out to five tiles per second.
## This is exported, which means you can change it in the Inspector without
## touching this file.
@export var speed: float = 80.0
@export_range(2.0, 12.0, 0.5) var walk_frames_per_second: float = 7.0
@export_range(8.0, 18.0, 0.5) var side_walk_frames_per_second: float = 14.0
## The chibi courier is Preston's main model (2026-10-01). Untick to bring back
## the taller adult walk sheets, which are kept as a fallback.
@export var use_chibi: bool = true
@export_range(2.0, 12.0, 0.5) var chibi_steps_per_second: float = 8.0

# The chibi courier's walk: one 4x4 atlas of 272-pixel cells, rows DOWN, LEFT,
# RIGHT, UP (the same order as _facing_row), columns the four beats of a step.
# Preston's original poses plus the Walk Forge's passing poses, cut and checked by
# docs/art/characters/chibi-courier-preparation-2026-09-30/walk-forge-inputs/cut_walk_results.py.
# Every cell has its lowest boot pixel at y 260, so one scale and offset fit all.
const CHIBI_SHEET: Texture2D = preload("res://assets/sprites/player/courier_chibi_walk_2026_10_01.png")
const CHIBI_CELL := 272.0
const CHIBI_SCALE := 30.0 / 254.0  # about 30 world pixels tall, the World Forge's map scale
const CHIBI_FOOT := 260.0
# UP has its two opposite steps but no passing pose yet, so each step shows
# planted, then lifted one pixel, which reads as weight moving over the foot.
const CHIBI_UP_LIFT := [0.0, 1.0, 0.0, 1.0]

# Both atlases use 256-by-512 registered cells. Their visible figures are
# 480 and 465 pixels tall, so these scales match displayed height when turning.
const VERTICAL_WALK_SHEET: Texture2D = preload("res://assets/sprites/player/male_vertical_walk_4x2_2026_09_27.png")
const SIDE_WALK_SHEET: Texture2D = preload("res://assets/sprites/player/male_side_walk_refined_8_v2_2026_09_27.png")
const WALK_FRAME_SIZE := Vector2(256, 512)
const VERTICAL_SCALE := Vector2(0.075, 0.075)
const SIDE_SCALE := Vector2(0.0727, 0.0727)

@onready var _sprite: Sprite2D = $Sprite2D
var _facing_row: int = 0 # down, left, right, up
var _walk_phase: float = 0.0


func _physics_process(delta: float) -> void:
	# Reads the four movement actions and turns them into a direction.
	# The result is already normalized, so holding two keys to move diagonally
	# is not faster than moving straight. That is a real bug in a lot of
	# beginner movement code and this one line avoids it.
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	velocity = direction * speed

	# move_and_slide reads velocity, moves the body, and stops it against
	# anything solid. The tilemap collision is what it is stopping against.
	move_and_slide()
	_update_walk(direction, delta)


func _ready() -> void:
	_update_walk(Vector2.ZERO, 0.0)


func _update_walk(direction: Vector2, delta: float) -> void:
	if use_chibi:
		_update_chibi(direction, delta)
		return
	if direction == Vector2.ZERO:
		_walk_phase = 0.0
		# Rest on balanced passing poses while preserving the current facing.
		_show_walk_frame(_facing_row, 2 if _is_side_row(_facing_row) else 1)
		return

	var row: int
	if absf(direction.x) > absf(direction.y):
		row = 1 if direction.x < 0.0 else 2
	else:
		row = 3 if direction.y < 0.0 else 0
	if row != _facing_row:
		_facing_row = row
		_walk_phase = 0.0
	var side_view: bool = _is_side_row(row)
	var frame_count: float = 8.0 if side_view else 4.0
	var fps: float = side_walk_frames_per_second if side_view else walk_frames_per_second
	_walk_phase = fmod(_walk_phase + delta * fps, frame_count)
	_show_walk_frame(row, int(_walk_phase))


func _is_side_row(row: int) -> bool:
	return row == 1 or row == 2


func _show_walk_frame(row: int, frame: int) -> void:
	if _is_side_row(row):
		_sprite.texture = SIDE_WALK_SHEET
		_sprite.flip_h = row == 1
		_sprite.scale = SIDE_SCALE
		_sprite.position = Vector2(0, -18)
		var col: int = frame % 4
		var sheet_row: int = int(floor(float(frame) / 4.0))
		_sprite.region_rect = Rect2(col * WALK_FRAME_SIZE.x, sheet_row * WALK_FRAME_SIZE.y, WALK_FRAME_SIZE.x, WALK_FRAME_SIZE.y)
	else:
		_sprite.texture = VERTICAL_WALK_SHEET
		_sprite.flip_h = false
		_sprite.scale = VERTICAL_SCALE
		_sprite.position = Vector2(0, -18)
		var sheet_row: int = 1 if row == 3 else 0
		_sprite.region_rect = Rect2(frame * WALK_FRAME_SIZE.x, sheet_row * WALK_FRAME_SIZE.y, WALK_FRAME_SIZE.x, WALK_FRAME_SIZE.y)


func _update_chibi(direction: Vector2, delta: float) -> void:
	if direction == Vector2.ZERO:
		# No balanced stand exists yet, so the first stepping pose stands in.
		_walk_phase = 0.0
		_show_chibi_frame(_facing_row, 0)
		return
	var row: int
	if absf(direction.x) > absf(direction.y):
		row = 1 if direction.x < 0.0 else 2
	else:
		row = 3 if direction.y < 0.0 else 0
	if row != _facing_row:
		_facing_row = row
		_walk_phase = 0.0
	_walk_phase = fmod(_walk_phase + delta * chibi_steps_per_second, 4.0)
	_show_chibi_frame(row, int(_walk_phase))


func _show_chibi_frame(row: int, beat: int) -> void:
	_sprite.texture = CHIBI_SHEET
	_sprite.flip_h = false  # LEFT and RIGHT are drawn separately; the satchel stays on its side
	_sprite.scale = Vector2.ONE * CHIBI_SCALE
	var lift: float = CHIBI_UP_LIFT[beat] if row == 3 else 0.0
	# Centered sprite: lift the cell so its boot line sits on the player's origin.
	_sprite.position = Vector2(0.0, -(CHIBI_FOOT - CHIBI_CELL * 0.5) * CHIBI_SCALE - lift)
	_sprite.region_rect = Rect2(beat * CHIBI_CELL, row * CHIBI_CELL, CHIBI_CELL, CHIBI_CELL)
