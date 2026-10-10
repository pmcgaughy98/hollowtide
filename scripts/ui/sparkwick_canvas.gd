extends Node2D
## A creature-only draw layer. UI panels/text never pass through a creature material.
var draws: Array = []

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var finish := ShaderMaterial.new()
	finish.shader = preload("res://scripts/arena/creature_finish.gdshader")
	finish.set_shader_parameter("sparkwick_palette", true)
	material = finish

func _draw() -> void:
	for d in draws:
		draw_set_transform(d["at"], 0.0, d["scale"])
		draw_texture_rect_region(d["tex"], d["dest"], d["region"], d["colour"])
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
