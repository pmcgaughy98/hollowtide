extends Node2D
## Isolated review of the two eight-direction walking assets.

const ART := "res://assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/"
const FONT = preload("res://assets/fonts/Silkscreen-Regular.ttf")
const TITLE_FONT = preload("res://assets/fonts/AlegreyaSansSC-Bold.ttf")
const COURIER_FINISH: Shader = preload("res://scripts/effects/courier_finish.gdshader")
const DIRECTIONS := ["down", "down_left", "left", "up_left", "up", "up_right", "right", "down_right"]

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("#292536")
	background.size = Vector2(1152, 648)
	add_child(background)
	_label("CHIBI WALKING MODELS", Vector2(28, 12), 42, true)
	_build_row("Male", 112, 284)
	_build_row("Female", 354, 526)
	_label("Eight views with stepping, arm swing and follow-through.", Vector2(28, 602), 15)

func _build_row(model_name: String, label_y: float, feet_y: float) -> void:
	_label(model_name.to_upper(), Vector2(28, label_y - 28), 20)
	var frames: SpriteFrames = load(ART + model_name.to_lower() + "_chibi_walk_frames.tres")
	for i in DIRECTIONS.size():
		var direction: String = DIRECTIONS[i]
		var x := 100.0 + i * 136.0
		_label(direction.replace("_", " ").to_upper(), Vector2(x - 52, label_y), 12)
		var actor := AnimatedSprite2D.new()
		actor.name = model_name + "_" + direction
		actor.sprite_frames = frames
		if model_name == "Female":
			var finish := ShaderMaterial.new()
			finish.shader = COURIER_FINISH
			actor.material = finish
		actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		actor.scale = Vector2(2, 2)
		actor.offset = Vector2(0, -32)
		actor.position = Vector2(x, feet_y)
		add_child(actor)
		actor.play("walk_" + direction)

func _label(text: String, at: Vector2, size: int, title: bool = false) -> void:
	var label := Label.new()
	label.text = text
	label.position = at
	label.add_theme_font_override("font", TITLE_FONT if title else FONT)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color("#fff4e8"))
	add_child(label)

