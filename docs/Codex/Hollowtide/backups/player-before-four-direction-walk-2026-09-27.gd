extends CharacterBody2D

## Walking speed in pixels per second.
## One tile is 16 pixels wide, so 80 works out to five tiles per second.
## This is exported, which means you can change it in the Inspector without
## touching this file.
@export var speed: float = 80.0
@export_range(2.0, 12.0, 0.5) var walk_frames_per_second: float = 7.0
@export_range(4.0, 12.0, 0.5) var side_walk_frames_per_second: float = 8.0

# The generated 4-by-4 sheet is not an even atlas: the columns and rows have
# different margins. These measured crops keep every pose centered at the feet.
const FRAME_LEFTS := [131, 454, 779, 1104]
const FRAME_TOPS := [45, 365, 694, 1029]
const FRAME_SIZE := Vector2(160, 280)
const ORIGINAL_WALK_SHEET: Texture2D = preload("res://assets/sprites/player/character_walk_sheet.jpg")
const SIDE_WALK_SHEET: Texture2D = preload("res://assets/sprites/player/male_side_walk_harmonized_8.png")
const SIDE_FRAME_SIZE := Vector2(256, 512)
const ORIGINAL_SCALE := Vector2(0.12, 0.12)
const SIDE_SCALE := Vector2(0.09, 0.09)

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


func _update_walk(direction: Vector2, delta: float) -> void:
	if direction == Vector2.ZERO:
		_walk_phase = 0.0
		# The new side sheet has no dedicated standing cell; its passing pose is
		# the most balanced place to rest. Front/back retain their old neutral.
		_show_walk_frame(_facing_row, 2 if _is_side_row(_facing_row) else 0)
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
		_sprite.position = Vector2(0, -23)
		var col: int = frame % 4
		var sheet_row: int = int(floor(float(frame) / 4.0))
		_sprite.region_rect = Rect2(col * SIDE_FRAME_SIZE.x, sheet_row * SIDE_FRAME_SIZE.y, SIDE_FRAME_SIZE.x, SIDE_FRAME_SIZE.y)
	else:
		_sprite.texture = ORIGINAL_WALK_SHEET
		_sprite.flip_h = false
		_sprite.scale = ORIGINAL_SCALE
		_sprite.position = Vector2(0, -17)
		_sprite.region_rect = Rect2(FRAME_LEFTS[frame], FRAME_TOPS[row], FRAME_SIZE.x, FRAME_SIZE.y)
