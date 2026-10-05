extends Node2D

## One attached hometown level shares the existing courier and live route state.
## Descriptive labels remain placeholders until Preston chooses fictional names.
const TILESET = preload("res://assets/tilesets/route1_rd_2026_10_01/route1_ground_polished.tres")
const HOME = preload("res://assets/sprites/world/hometown_courtyard_2026_10_03/courtyard_home.png")
const LANES = preload("res://assets/sprites/world/hometown_courtyard_2026_10_03/hometown_lanes.png")
const MARK = preload("res://assets/sprites/world/route1_rd_2026_10_01/marker.png")
const GROUND_SHADER = preload("res://assets/sprites/world/route1_landscape_2026_10_03/ground_variation.gdshader")
const CANOPY_SHADER = preload("res://assets/sprites/world/route1_landing_loop_2026_10_03/canopy_visibility.gdshader")
const WIND_SHADER = preload("res://assets/sprites/world/route1_landscape_2026_10_03/foliage_wind.gdshader")
const FONT = preload("res://assets/fonts/Silkscreen-Regular.ttf")
const TREES = [
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_west.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_north.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_bank_bend.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_east.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_office_grove.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_ridge.png"),
]
const TREE_POINTS = [
	Vector2(66, 144), Vector2(242, 119), Vector2(360, 128),
	Vector2(64, 316), Vector2(140, 372), Vector2(395, 361),
]
const TUFTS = [
	preload("res://assets/sprites/world/route1_landscape_2026_10_03/meadow_tuft_1.png"),
	preload("res://assets/sprites/world/route1_landscape_2026_10_03/meadow_tuft_2.png"),
]
const SHRUBS = [
	preload("res://assets/sprites/world/route1_rd_2026_10_02/bank_shrub_2.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/bank_shrub_4.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/bank_shrub_7.png"),
]
const STONES = preload("res://assets/sprites/world/route1_landscape_2026_10_03/river_stones.png")
var _route: Node2D
var _trees: Array[Sprite2D] = []
var _crown_opacities: Array[float] = []
var _wind: ShaderMaterial
var _clock := 0.0

func _ready() -> void:
	_route = get_parent()
	_build_ground()
	_build_home()
	_build_garden()
	_build_boundary_groves()
	# Route 1 owns the east gate; all other outer edges stay solid.
	_obstacle(self, "WestEdge", Vector2(-8, 192), Vector2(16, 384))
	_obstacle(self, "NorthEdge", Vector2(240, -8), Vector2(480, 16))
	_obstacle(self, "SouthEdge", Vector2(240, 392), Vector2(480, 16))
	_prop("HometownDirectionNotice", MARK, Vector2(448, 168), 0.65)
	_label("HometownDirectionLabel", "DISPATCH >", Vector2(389, 140))
	queue_redraw()

func _build_ground() -> void:
	var ground := TileMapLayer.new()
	ground.name = "Terrain"
	ground.tile_set = TILESET
	ground.z_index = -2
	ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var material := ShaderMaterial.new()
	material.shader = GROUND_SHADER
	ground.material = material
	for x in 30:
		for y in 24:
			# Negative world tiles continue Route 1's existing grass phase.
			ground.set_cell(Vector2i(x, y), 0, Vector2i(posmod((x - 30) * 3 + y, 2), 0))
	add_child(ground)
	var lanes := Sprite2D.new()
	lanes.name = "CourtyardAndGardenLanes"
	lanes.texture = LANES
	lanes.centered = false
	lanes.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	lanes.z_index = 1 # Join over the earlier route-edge grass patch.
	lanes.material = material
	add_child(lanes)

func _prop(label: String, texture: Texture2D, local_at: Vector2, ratio: float = 1.0) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.name = label
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = position + local_at
	sprite.scale = Vector2.ONE * ratio
	var used := texture.get_image().get_used_rect()
	sprite.offset.y = floorf(texture.get_height() * 0.5) - used.end.y
	_route.get_node("RouteDecor").add_child(sprite)
	return sprite

func _obstacle(parent: Node2D, label: String, at: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = label
	body.position = at
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	shape.shape = rectangle
	body.add_child(shape)
	parent.add_child(body)

func _label(label: String, text: String, at: Vector2) -> void:
	var caption := Label.new()
	caption.name = label
	caption.text = text
	caption.position = at
	caption.add_theme_font_override("font", FONT)
	caption.add_theme_font_size_override("font_size", 8)
	caption.add_theme_color_override("font_color", Color("#e5ddba"))
	caption.add_theme_color_override("font_outline_color", Color("#293831"))
	caption.add_theme_constant_override("outline_size", 2)
	add_child(caption)

func _build_home() -> void:
	_prop("HometownCourtyardHome", HOME, Vector2(136, 168), 0.75)
	_obstacle(self, "HomeFootprint", Vector2(136, 145), Vector2(96, 50))

func _build_garden() -> void:
	_wind = ShaderMaterial.new()
	_wind.shader = WIND_SHADER
	for row in 2:
		for col in 3:
			var herb := _prop("HometownGardenPlant%d%d" % [row, col], TUFTS[(row + col) % 2], Vector2(269 + col * 16, 269 + row * 22), 0.35)
			herb.material = _wind
	_prop("HometownGardenNotice", MARK, Vector2(308, 296), 0.6)
	_label("HometownGardenLabel", "SHARED GARDEN", Vector2(248, 232))
	var points := [Vector2(98, 242), Vector2(176, 271), Vector2(379, 311)]
	for i in points.size():
		_prop("HometownShrub%02d" % i, SHRUBS[i % SHRUBS.size()], points[i], 0.8)
	for i in 3:
		_prop("HometownStones%02d" % i, STONES, [Vector2(68, 356), Vector2(431, 324), Vector2(236, 350)][i], 0.65)
	for i in 5:
		var point: Vector2 = [Vector2(74, 200), Vector2(181, 206), Vector2(287, 168), Vector2(417, 234), Vector2(333, 353)][i]
		var tuft := _prop("HometownMeadowTuft%02d" % i, TUFTS[i % 2], point, 0.75)
		tuft.material = _wind

func _build_boundary_groves() -> void:
	for i in TREE_POINTS.size():
		var tree := _prop("HometownTree%02d" % i, TREES[i % TREES.size()], TREE_POINTS[i])
		_obstacle(tree, "FootCollision", Vector2(0, -3), Vector2(10, 7))
		var canopy := ShaderMaterial.new()
		canopy.shader = CANOPY_SHADER
		tree.material = canopy
		_trees.append(tree)
		_crown_opacities.append(1.0)

func _process(delta: float) -> void:
	_clock = fmod(_clock + delta, TAU / 0.75)
	_wind.set_shader_parameter("scene_clock", _clock)
	var courier: CharacterBody2D = _route.get_node("Player")
	for i in _trees.size():
		var tree := _trees[i]
		var head := tree.to_local(courier.global_position + Vector2(0, -16))
		var covered := courier.global_position.y < tree.global_position.y - 2 and tree.get_rect().has_point(head)
		_crown_opacities[i] = move_toward(_crown_opacities[i], 0.35 if covered else 1.0, delta * 3.0)
		tree.material.set_shader_parameter("canopy_opacity", _crown_opacities[i])

func _ellipse(at: Vector2, radius: Vector2, colour: Color) -> void:
	var outline := PackedVector2Array()
	for i in 16:
		var angle := TAU * float(i) / 16.0
		outline.append(at + Vector2(roundf(cos(angle) * radius.x), roundf(sin(angle) * radius.y)))
	draw_colored_polygon(outline, colour)

func _draw() -> void:
	_ellipse(Vector2(138, 168), Vector2(51, 5), Color(0.09, 0.18, 0.12, 0.2))
	for i in TREE_POINTS.size():
		var texture: Texture2D = TREES[i % TREES.size()]
		var size := texture.get_size()
		draw_set_transform(TREE_POINTS[i] + Vector2(10, 5), 0, Vector2(1, 0.32))
		draw_texture(texture, Vector2(-size.x * 0.5, -size.y * 0.68), Color(0.08, 0.15, 0.09, 0.18))
		draw_set_transform(Vector2.ZERO)
		_ellipse(TREE_POINTS[i], Vector2(6, 2), Color(0.1, 0.18, 0.13, 0.2))
