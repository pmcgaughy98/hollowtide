extends Node2D

## Ground contacts and slow river glints, below the foot-sorted map actors.
var _clock := 0.0
var _route: Node2D

func _ready() -> void:
	_route = get_parent()
	for child in _route.get_node("RouteDecor").get_children():
		if child.name.begins_with("Cottonwood"):
			_add_obstacle(child, Vector2(10, 7), Vector2(0, -3))
	_add_obstacle(_route.get_node("RouteDecor/WaylineOffice"), Vector2(106, 84), Vector2(0, -46))

func _add_obstacle(parent: Node2D, size: Vector2, at: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = "FootCollision"
	body.position = at
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	shape.shape = rectangle
	body.add_child(shape)
	parent.add_child(body)

func _process(delta: float) -> void:
	_clock = fmod(_clock + delta, 32.0)
	queue_redraw()

func _ellipse(at: Vector2, radius: Vector2, colour: Color) -> void:
	var polygon := PackedVector2Array()
	for beat in 16:
		var angle := TAU * float(beat) / 16.0
		polygon.append(at + Vector2(roundf(cos(angle) * radius.x), roundf(sin(angle) * radius.y)))
	draw_colored_polygon(polygon, colour)

func _contact(at: Vector2, radius: Vector2) -> void:
	_ellipse(at + Vector2(2, 1), radius + Vector2(2, 1), Color(0.10, 0.20, 0.15, 0.10))
	_ellipse(at, radius, Color(0.10, 0.18, 0.13, 0.20))

func _draw() -> void:
	if _route == null:
		return
	for child in _route.get_node("RouteDecor").get_children():
		if child.name.begins_with("Cottonwood"):
			_ellipse(child.position + Vector2(7, 3), Vector2(23, 6), Color(0.09, 0.20, 0.14, 0.16))
			_contact(child.position, Vector2(6, 2))
		elif child.name.begins_with("BankShrub"):
			_contact(child.position, Vector2(8, 2))
		elif child.name.begins_with("RetainingWall"):
			_ellipse(child.position + Vector2(2, 1), Vector2(30, 2), Color(0.09, 0.18, 0.12, 0.20))
	_contact(_route.get_node("RouteDecor/WaylineOffice").position, Vector2(51, 5))
	for actor in ["Player", "Dispatcher", "Marker", "RelayPost", "CinderhideEncounter"]:
		var node: Node2D = _route.get_node(actor)
		_contact(node.position, Vector2(7 if actor != "CinderhideEncounter" else 13, 2))
	for row in 9:
		for column in 3:
			var drift := floorf(fmod(_clock * 1.2 + float(row * 3 + column), 9.0))
			var origin := Vector2(480 + column * 52 + (row % 2) * 7 + drift, 27 + row * 39)
			var opacity := 0.12 + 0.06 * sin(_clock + float(row))
			draw_line(origin, origin + Vector2(8 + (row % 3) * 3, 0), Color(0.64, 0.76, 0.62, opacity), 1.0)
