extends Node2D
## Finished new-creature Team art only; original panels, shadows, text and older forms stay separate.
const Finish := preload("res://scripts/arena/creature_finish.gd")
var sprites: Array[Sprite2D] = []
var used := 0

func clear() -> void:
	used = 0
	for sprite in sprites: sprite.hide()

func paint(tex: Texture2D, dst: Rect2, region: Rect2, tint: Color) -> void:
	if used == sprites.size():
		var well := Control.new()
		well.mouse_filter = Control.MOUSE_FILTER_IGNORE
		well.clip_contents = true
		add_child(well)
		var sprite := Sprite2D.new()
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.region_enabled = true
		Finish.apply(sprite)
		well.add_child(sprite)
		sprites.append(sprite)
	var sprite := sprites[used]
	used += 1
	if sprite.texture != tex: sprite.texture = tex
	sprite.region_rect = region
	var well := sprite.get_parent() as Control
	well.position = dst.position
	well.size = dst.size
	sprite.scale = dst.size / region.size
	sprite.modulate = tint
	sprite.show()
