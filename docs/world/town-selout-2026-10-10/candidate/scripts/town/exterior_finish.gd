extends RefCounted
## Purposeful exteriors: palette-coloured outer rim, original black internal detail.
## Doors without the detail flag keep the exact existing shared creature finish.
const Finish := preload("res://scripts/arena/creature_finish.gd")
const SHADER := preload("res://scripts/town/exterior_finish.gdshader")
static func apply(sprite: Sprite2D, details: bool = false) -> void:
	Finish.apply(sprite, details)
	if details: sprite.material.shader = SHADER
