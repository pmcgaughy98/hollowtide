extends Node2D
var _world: Node2D
var npcs: Array = []
func _ready() -> void:
	_world = Node2D.new();add_child(_world)
func _place(e: Dictionary) -> void:
	e.node.position=Vector2(200,600)
	e.sprite.texture=e.still[e.facing]
