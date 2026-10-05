extends Node2D

## Ground contacts and canopy shadows, below the foot-sorted map actors.
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

func _process(_delta: float) -> void:
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
		if child.name.contains("Cottonwood"):
			var size: Vector2 = child.texture.get_size()
			draw_set_transform(child.position + Vector2(11, 5), 0, Vector2(1.0, 0.32))
			draw_texture(child.texture, Vector2(-size.x * 0.5, -size.y * 0.68), Color(0.08, 0.15, 0.09, 0.18))
			draw_set_transform(Vector2.ZERO)
			_ellipse(child.position + Vector2(7, 3), Vector2(23, 6), Color(0.09, 0.20, 0.14, 0.16))
			_contact(child.position, Vector2(6, 2))
		elif child.name.begins_with("BankShrub") or child.name.begins_with("CityShrub") or child.name == "LowFieldShrub":
			_contact(child.position, Vector2(8, 2))
		elif child.name.begins_with("MeadowGrass") or child.name.begins_with("BankReeds"):
			_contact(child.position, Vector2(9, 1))
		elif child.name.begins_with("RetainingWall"):
			_ellipse(child.position + Vector2(2, 1), Vector2(30, 2), Color(0.09, 0.18, 0.12, 0.20))
	_contact(_route.get_node("RouteDecor/WaylineOffice").position, Vector2(51, 5))
	var city_hall := _route.get_node_or_null("RouteDecor/CityCourierBranch")
	if city_hall:
		_contact(city_hall.position, Vector2(39, 4))
	var clerk := _route.get_node_or_null("RouteDecor/CityCourierClerk")
	if clerk:
		_contact(clerk.position, Vector2(6, 2))
	for actor in ["Player", "Dispatcher", "Marker", "RelayPost", "CinderhideEncounter"]:
		var node: Node2D = _route.get_node(actor)
		_contact(node.position, Vector2(7 if actor != "CinderhideEncounter" else 13, 2))
