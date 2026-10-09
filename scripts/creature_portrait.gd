extends TextureRect
## Reusable UI portrait from existing front art through AtlasTexture regions.
## The SpriteFrames resource owns its source references and crop, never pixels.
@export var frames: SpriteFrames
@export var reduce_motion := false
var _clock := 0.0
var _frame := -1

func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_frame()

func _process(delta: float) -> void:
	_clock += delta
	_update_frame()

func _update_frame() -> void:
	if frames == null or not frames.has_animation(&"idle"):
		return
	var count := frames.get_frame_count(&"idle")
	if count == 0:
		return
	var index := 0 if reduce_motion else int(_clock * frames.get_animation_speed(&"idle")) % count
	if index != _frame:
		_frame = index
		texture = frames.get_frame_texture(&"idle", index)
