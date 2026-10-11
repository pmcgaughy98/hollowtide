extends Node2D
## Moving contact shadows, below the unchanged creature art.
var actors:Array[Sprite2D]=[]
func _process(_delta:float)->void:queue_redraw()
func _draw()->void:
	for actor in actors:
		var at:=actor.position
		draw_rect(Rect2(at-Vector2(10,1),Vector2(20,2)),Color(0.08,0.10,0.08,0.48))
		draw_rect(Rect2(at-Vector2(7,2),Vector2(14,4)),Color(0.08,0.10,0.08,0.32))
