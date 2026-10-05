extends Node2D

## A quiet river corridor: irregular wet margins, meadow groups and cottonwood groves.
## The approved wet-bank contour is baked; vegetation and wind remain live.
const WET_BANKS = preload("res://assets/sprites/world/route1_static_surfaces_2026_10_03/wet_bank_contours.png")
const GRASS = preload("res://assets/sprites/world/route1_landscape_2026_10_03/meadow_grass.png")
const ROOTS = preload("res://assets/sprites/world/route1_landscape_2026_10_03/silt_roots_small.png")
const TUFTS = [
	preload("res://assets/sprites/world/route1_landscape_2026_10_03/meadow_tuft_1.png"),
	preload("res://assets/sprites/world/route1_landscape_2026_10_03/meadow_tuft_2.png"),
]
const STONES = preload("res://assets/sprites/world/route1_landscape_2026_10_03/river_stones.png")
const GROUND_SHADER = preload("res://assets/sprites/world/route1_landscape_2026_10_03/ground_variation.gdshader")
const WIND_SHADER = preload("res://assets/sprites/world/route1_landscape_2026_10_03/foliage_wind.gdshader")
const TREES = [
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_west.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_north.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_bank_bend.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_south.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_east.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_office_grove.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_ridge.png"),
]
const REEDS = [
	preload("res://assets/sprites/world/route1_rd_2026_10_02/bank_reeds_1.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/bank_reeds_3.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/bank_reeds_5.png"),
]
const SHRUBS = [
	preload("res://assets/sprites/world/route1_rd_2026_10_02/bank_shrub_2.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/bank_shrub_4.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/bank_shrub_7.png"),
]
# Small clusters frame the route, leaving its clear center and every quest approach.
const TREE_POINTS = [
	Vector2(60, 330), Vector2(66, 393), Vector2(120, 425),
	Vector2(58, 562), Vector2(100, 597), Vector2(174, 581),
	Vector2(324, 589), Vector2(391, 604),
	Vector2(733, 94), Vector2(804, 111), Vector2(825, 181),
	Vector2(956, 144), Vector2(964, 246),
	Vector2(956, 619), Vector2(876, 601),
]
const MEADOW_POINTS = [
	Vector2(31, 256), Vector2(90, 264), Vector2(119, 240),
	Vector2(146, 274), Vector2(120, 304), Vector2(176, 327),
	Vector2(53, 447), Vector2(94, 468), Vector2(142, 489),
	Vector2(191, 424), Vector2(251, 444), Vector2(276, 473),
	Vector2(341, 485), Vector2(386, 515), Vector2(342, 554),
	Vector2(235, 565), Vector2(217, 602), Vector2(268, 616),
	Vector2(708, 144), Vector2(770, 151), Vector2(840, 226),
	Vector2(873, 272), Vector2(768, 263), Vector2(929, 222),
	Vector2(940, 299), Vector2(995, 330), Vector2(976, 380),
	Vector2(730, 537), Vector2(783, 566), Vector2(827, 591),
	Vector2(1000, 586), Vector2(921, 563),
	Vector2(322, 55), Vector2(246, 178), Vector2(266, 203),
	Vector2(226, 342), Vector2(303, 334), Vector2(242, 394),
]
const REED_POINTS = [
	Vector2(456, 77), Vector2(451, 134), Vector2(456, 347),
	Vector2(454, 508), Vector2(453, 565), Vector2(455, 611),
	Vector2(665, 36), Vector2(668, 99), Vector2(660, 155),
	Vector2(666, 228), Vector2(664, 312), Vector2(669, 356),
	Vector2(661, 503), Vector2(668, 561), Vector2(666, 620),
]
const STONE_POINTS = [
	Vector2(418, 146), Vector2(425, 313), Vector2(433, 533),
	Vector2(435, 618), Vector2(681, 184), Vector2(683, 288),
	Vector2(682, 529), Vector2(705, 594), Vector2(210, 466),
	Vector2(294, 528), Vector2(756, 207), Vector2(915, 316),
]
const ROOT_POINTS = [
	Vector2(446, 153), Vector2(446, 351), Vector2(446, 568),
	Vector2(678, 121), Vector2(678, 323), Vector2(678, 582),
]

var _route: Node2D
var _wind_material: ShaderMaterial
var _clock := 0.0
var added_tree_count := 0
var added_detail_count := 0


func _ready() -> void:
	_route = get_parent().get_parent()
	var ground := ShaderMaterial.new()
	ground.shader = GROUND_SHADER
	_route.get_node("Terrain").material = ground
	_wind_material = ShaderMaterial.new()
	_wind_material.shader = WIND_SHADER
	_build_banks()
	_build_groves()
	_build_details()
	_vary_city_trees()


func _process(delta: float) -> void:
	_clock = fmod(_clock + delta, TAU / 0.75)
	_wind_material.set_shader_parameter("scene_clock", _clock)


func _prop(label: String, texture: Texture2D, at: Vector2, wind: bool = false) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.name = label
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = at
	var used := texture.get_image().get_used_rect()
	sprite.offset.y = floorf(texture.get_height() * 0.5) - used.end.y
	if wind:
		sprite.material = _wind_material
	_route.get_node("RouteDecor").add_child(sprite)
	return sprite


func _build_groves() -> void:
	for i in range(TREE_POINTS.size()):
		var tree := _prop("CottonwoodMeadow%02d" % i, TREES[i % TREES.size()], TREE_POINTS[i])
		# Foot collisions allow the player to walk behind the canopy.
		var body := StaticBody2D.new()
		body.name = "FootCollision"
		body.position = Vector2(0, -3)
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(10, 7)
		shape.shape = rectangle
		body.add_child(shape)
		tree.add_child(body)
		added_tree_count += 1
	var shrub_points := [Vector2(36, 372), Vector2(91, 520), Vector2(167, 553), Vector2(354, 621), Vector2(756, 96), Vector2(843, 157), Vector2(992, 289), Vector2(835, 624)]
	for i in range(shrub_points.size()):
		_prop("BankShrubMeadow%02d" % i, SHRUBS[i % SHRUBS.size()], shrub_points[i])
		added_detail_count += 1


func _build_details() -> void:
	for i in range(MEADOW_POINTS.size()):
		_prop("MeadowGrass%02d" % i, TUFTS[i % TUFTS.size()], MEADOW_POINTS[i], true)
	for i in range(3):
		_prop("MeadowThicket%02d" % i, GRASS, [Vector2(210, 548), Vector2(362, 513), Vector2(870, 238)][i], true)
	for i in range(REED_POINTS.size()):
		_prop("BankReedsMeadow%02d" % i, REEDS[i % REEDS.size()], REED_POINTS[i], true)
	for i in range(STONE_POINTS.size()):
		_prop("RiverStones%02d" % i, STONES, STONE_POINTS[i])
	for i in range(ROOT_POINTS.size()):
		_prop("CutbankRoots%02d" % i, ROOTS, ROOT_POINTS[i])
	added_detail_count += 3 + MEADOW_POINTS.size() + REED_POINTS.size() + STONE_POINTS.size() + ROOT_POINTS.size()


func _vary_city_trees() -> void:
	var decor := _route.get_node("RouteDecor")
	for pair in [["CityCottonwood726", 2], ["CityCottonwood950", 4], ["CityCottonwood914", 1]]:
		var tree: Sprite2D = decor.get_node_or_null(pair[0])
		if tree:
			tree.texture = TREES[pair[1]]


func _build_banks() -> void:
	var surface := Sprite2D.new()
	surface.name = "WetBankContours"
	surface.texture = WET_BANKS
	surface.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	surface.centered = false
	surface.position = Vector2(408, 0)
	add_child(surface)
