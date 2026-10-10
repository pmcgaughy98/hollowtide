extends Node2D
## Only rival portraits pass through the creature material. Frames and text stay separate.
var draws: Array = []
var marks: Node2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var finish := ShaderMaterial.new()
	finish.shader = preload("res://scripts/arena/creature_finish.gdshader")
	finish.set_shader_parameter("detail_ink", 0.65)
	material = finish
	marks = Node2D.new()
	marks.use_parent_material = false
	marks.draw.connect(_draw_marks)
	add_child(marks)

func clear() -> void:
	draws.clear()
	queue_redraw()
	marks.queue_redraw()

func paint(tex: Texture2D, dst: Rect2, face: String, frame: Rect2) -> void:
	draws.append({"tex": tex, "dst": dst, "face": face, "frame": frame})
	queue_redraw()
	marks.queue_redraw()

func _draw() -> void:
	for d in draws:
		draw_texture_rect(d["tex"], d["dst"], false)

func _draw_marks() -> void:
	for d in draws:
		preload("res://scripts/ui/ui_style.gd")._face_mark(marks, d["frame"], d["face"])
