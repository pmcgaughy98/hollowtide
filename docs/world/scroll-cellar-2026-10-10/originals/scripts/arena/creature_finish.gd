extends RefCounted
## Shared display finish, following the saved Hollowtide Sprite Forge house style.
## Source art and palettes are never rebuilt. No time-dependent grain or dither.
const SHADER = preload("res://scripts/arena/creature_finish.gdshader")

static func apply(sprite: Sprite2D, details: bool = false) -> void:
	var finish := ShaderMaterial.new()
	finish.shader = SHADER
	finish.set_shader_parameter("detail_ink", 1.0 if details else 0.0)
	sprite.material = finish
