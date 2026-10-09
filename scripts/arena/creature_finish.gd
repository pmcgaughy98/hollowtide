extends RefCounted
## Shared display finish, following the saved Hollowtide Sprite Forge house style.
## Source art and palettes are never rebuilt. No time-dependent grain or dither.
const SHADER = preload("res://scripts/arena/creature_finish.gdshader")

static func apply(sprite: Sprite2D) -> void:
	var finish := ShaderMaterial.new()
	finish.shader = SHADER
	sprite.material = finish
