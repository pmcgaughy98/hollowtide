extends Node2D
## Creature-only portrait sprites; frames, backgrounds and emotion marks stay separate.
const Finish := preload("res://scripts/arena/creature_finish.gd")
var draws: Array = []
var marks: Node2D
var sprites: Array[Sprite2D] = []

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	marks = Node2D.new()
	marks.use_parent_material = false
	marks.z_index = 1
	marks.draw.connect(_draw_marks)
	add_child(marks)

func clear() -> void:
	draws.clear()
	for sprite in sprites: sprite.hide()
	marks.queue_redraw()

func paint(tex: Texture2D, dst: Rect2, face: String, frame: Rect2) -> void:
	var index := draws.size()
	if index == sprites.size():
		var sprite := Sprite2D.new()
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		Finish.apply(sprite)
		add_child(sprite)
		sprites.append(sprite)
	var sprite := sprites[index]
	if sprite.texture != tex: sprite.texture = tex
	sprite.position = dst.position
	sprite.scale = dst.size / tex.get_size()
	sprite.show()
	draws.append({"tex": tex, "dst": dst, "face": face, "frame": frame})
	marks.queue_redraw()

func _draw_marks() -> void:
	for d in draws:
		preload("res://scripts/ui/ui_style.gd")._face_mark(marks, d["frame"], d["face"])
