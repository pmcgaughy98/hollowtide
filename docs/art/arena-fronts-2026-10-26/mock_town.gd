extends Node2D
var _world: Node2D
func _ready() -> void:
	_world=Node2D.new();add_child(_world)
func _place(e: Dictionary) -> void:
	e.node.position=Vector2(e.pos.x*144+72,e.pos.y*188+176)
	e.sprite.texture=e.still[e.facing];e.sprite.offset=Vector2(0,-33);e.sprite.scale=Vector2(2,2)
