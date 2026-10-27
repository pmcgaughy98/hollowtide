extends Node2D
## Sprite tool test (2026-10-26): can PixelLab make the courier's eight-direction walk from one
## front frame, and can its faults be repaired by hand afterwards? Three sets step together at 8 FPS,
## drawn at 2x: the in-game Retro Diffusion walk on top, the raw PixelLab walk in the middle, and the
## PixelLab walk after the fix chain (tools/art/walk_fix/compose_walk.py) at the bottom. All atlases
## share one layout: 80 px cells, eight frames per row, rows turning clockwise from down, feet on row
## 72 of the cell. Open scenes/debug/sprite_tool_test.tscn and press F6. Space pauses, Left and Right
## step a frame. Measurements and still comparisons: docs/art/characters/sprite-tool-test-2026-10-26/
## (the fixed set's are under fix/).

const RD_ATLAS := "res://assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/male_chibi_walk_matched_turns_native80.png"
const PL_ATLAS := "res://assets/sprites/player/pixellab_walk_test_2026_10_26/pixellab_courier_walk_native80.png"
const PL_FIXED_ATLAS := "res://assets/sprites/player/pixellab_walk_test_2026_10_26/pixellab_courier_walk_fixed_native80.png"
const FONT = preload("res://assets/fonts/Silkscreen-Regular.ttf")
const TITLE_FONT = preload("res://assets/fonts/AlegreyaSansSC-Bold.ttf")
const DIRECTIONS := ["down", "down_left", "left", "up_left", "up", "up_right", "right", "down_right"]

const CELL := 80.0
const FOOT_Y := 72.0       # the row of the cell the feet stand on, same as CHIBI_FOOT in player.gd
const FRAMES := 8
const FPS := 8.0
const ZOOM := 2.0
const FIRST_X := 100.0     # feet of the first column
const STEP_X := 136.0      # distance between columns
const BACKGROUND := Color("#292536")
const GROUND := Color("#6b7b5a")
const GROUND_LINE := Color("#4f5c41")
const INK := Color("#fff4e8")

var _sprites: Array[Sprite2D] = []
var _clock := 0.0
var _frame := 0
var _paused := false
var _frame_label: Label


func _ready() -> void:
	var background := ColorRect.new()
	background.color = BACKGROUND
	background.size = Vector2(1152, 648)
	add_child(background)
	_label("SPRITE TOOL TEST", Vector2(28, 4), 26, true)
	# Direction names once, above the three sets, so the rows can sit close enough to fit 648 px.
	for i in DIRECTIONS.size():
		_label(String(DIRECTIONS[i]).replace("_", " ").to_upper(), Vector2(FIRST_X + i * STEP_X - 52.0, 42.0), 11)
	# Each set: heading at the top, feet 158 px lower (the highest head, cell row 6, is 132 px above the feet at 2x).
	_build_row("RETRO DIFFUSION, IN GAME NOW", RD_ATLAS, 60.0, 218.0)
	_build_row("PIXELLAB TEST, RAW (FROM ONE FRONT FRAME)", PL_ATLAS, 230.0, 388.0)
	_build_row("PIXELLAB TEST, FIXED BY HAND RULES AFTER GENERATING", PL_FIXED_ATLAS, 400.0, 558.0)
	_label("Same layout, same foot row. Space pauses, Left and Right step one frame.", Vector2(28, 574), 13)
	_frame_label = _label("", Vector2(28, 598), 13)
	_show_frame()


## One set: a heading, a ground strip with a line under the feet, and eight stepping sprites.
func _build_row(heading: String, atlas_path: String, top: float, feet_y: float) -> void:
	_label(heading, Vector2(28, top), 16)
	var strip := ColorRect.new()
	strip.color = GROUND
	strip.position = Vector2(FIRST_X - 72.0, top + 22.0)
	strip.size = Vector2(STEP_X * 8.0 + 8.0, feet_y - top - 14.0)
	add_child(strip)
	var line := ColorRect.new()
	line.color = GROUND_LINE
	# The foot row covers feet_y to feet_y + ZOOM on screen, so the line sits just under it.
	line.position = Vector2(strip.position.x, feet_y + ZOOM)
	line.size = Vector2(strip.size.x, 2.0)
	add_child(line)

	var texture: Texture2D = null
	if ResourceLoader.exists(atlas_path):
		texture = load(atlas_path) as Texture2D
	if texture == null:
		_label("Missing or not imported yet: " + atlas_path, Vector2(FIRST_X - 60.0, top + 50.0), 12)
		return
	for i in DIRECTIONS.size():
		var x := FIRST_X + i * STEP_X
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.region_enabled = true
		sprite.scale = Vector2(ZOOM, ZOOM)
		# The node sits on the feet: the cell is centred, so lift it by the foot row's distance from the centre.
		sprite.offset = Vector2(0.0, -(FOOT_Y - CELL * 0.5))
		sprite.position = Vector2(x, feet_y)
		sprite.set_meta("row", i)
		add_child(sprite)
		_sprites.append(sprite)


func _process(delta: float) -> void:
	if _paused:
		return
	_clock += delta
	var step := 1.0 / FPS
	while _clock >= step:
		_clock -= step
		_frame = (_frame + 1) % FRAMES
		_show_frame()


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	match key.keycode:
		KEY_SPACE:
			_paused = not _paused
		KEY_RIGHT:
			_paused = true
			_frame = (_frame + 1) % FRAMES
		KEY_LEFT:
			_paused = true
			_frame = (_frame + FRAMES - 1) % FRAMES
		_:
			return
	_show_frame()


## Every sprite shows the same frame of its own row, so the two sets stay in step.
func _show_frame() -> void:
	for sprite in _sprites:
		var row: int = sprite.get_meta("row")
		sprite.region_rect = Rect2(_frame * CELL, row * CELL, CELL, CELL)
	if _frame_label:
		_frame_label.text = "Frame f%d (f0 to f%d)%s" % [_frame, FRAMES - 1, "  paused" if _paused else ""]


func _label(text: String, at: Vector2, size: int, title: bool = false) -> Label:
	var label := Label.new()
	label.text = text
	label.position = at
	label.add_theme_font_override("font", TITLE_FONT if title else FONT)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", INK)
	add_child(label)
	return label
