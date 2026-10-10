extends Node2D
## Original code-drawn joinery, kept in the margins of the title's panels.
func _ready() -> void:
    get_parent().resized.connect(queue_redraw)
    queue_redraw()

func _draw() -> void:
    var span: Vector2 = get_parent().size
    if span.x < 20 or span.y < 20: return
    var ink := Color("#706c4c")
    var gold := Color("#d3b780")
    draw_rect(Rect2(7,7,span.x-14,1),ink)
    draw_rect(Rect2(7,span.y-8,span.x-14,1),ink)
    draw_rect(Rect2(7,8,1,span.y-16),ink)
    draw_rect(Rect2(span.x-8,8,1,span.y-16),ink)
    for at in [Vector2(5,5),Vector2(span.x-10,5),Vector2(5,span.y-10),span-Vector2(10,10)]:
        draw_rect(Rect2(at,Vector2(5,5)),Color("#313b2c"))
        draw_rect(Rect2(at+Vector2.ONE,Vector2(3,3)),gold)
