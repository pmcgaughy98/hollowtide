extends Node2D
const LANDSCAPE = preload("res://scripts/area_landscape.gd")
# One winding lane from the hometown to the River Road (Claude 2026-10-05,
# docs/art/world/route1-meadow-refine-2026-10-05). Codex's stepped lanes,
# route1_meadow_approach.png, are kept unused.
const ROAD = preload("res://assets/sprites/world/route1_meadow_refine_2026_10_05/meadow_lane.png")
const TUFTS = [
    preload("res://assets/sprites/world/route1_landscape_2026_10_03/meadow_tuft_1.png"),
    preload("res://assets/sprites/world/route1_landscape_2026_10_03/meadow_tuft_2.png"),
]
# Groves that frame the lane: [x, y, tree variant, mirrored]. From build_meadow.py.
const TREE_LAYOUT := [[-691, 134, 0, true], [-610, 128, 1, true], [-641, 185, 2, false], [-466, 94, 3, true], [-379, 96, 4, true], [-554, 362, 5, false], [-599, 312, 0, true], [-625, 377, 1, true], [-353, 623, 2, true], [-410, 581, 3, true], [-459, 626, 4, false], [-157, 451, 5, false], [-89, 446, 0, false], [-216, 413, 1, true], [-700, 602, 2, true], [-636, 589, 3, true], [-203, 329, 4, true]]
# Grass tufts along the lane and at the groves' feet: [x, y, which, mirrored].
const TUFT_LAYOUT := [[-154, 194, 1, true], [-75, 473, 1, false], [-599, 507, 1, false], [-638, 192, 1, true], [-230, 447, 1, false], [-173, 261, 1, true], [-383, 584, 0, false], [-85, 171, 0, false], [-514, 404, 1, true], [-344, 101, 1, true], [-577, 422, 1, true], [-498, 378, 1, true], [-577, 374, 1, true], [-195, 212, 0, true], [-335, 362, 0, true], [-429, 578, 0, true], [-168, 448, 0, false], [-499, 96, 1, true], [-729, 144, 0, false], [-456, 630, 0, false], [-182, 426, 1, true], [-189, 469, 0, false], [-223, 232, 1, false], [-213, 419, 1, true], [-203, 328, 0, true], [-543, 480, 0, false], [-664, 185, 0, false], [-606, 350, 1, false], [-623, 458, 0, true], [-449, 358, 1, false], [-361, 631, 1, true], [-402, 110, 1, true], [-682, 156, 1, false], [-285, 321, 1, true]]
const TILESET = preload("res://assets/tilesets/route1_rd_2026_10_01/route1_ground_polished.tres")
const GROUND = preload("res://assets/sprites/world/route1_landscape_2026_10_03/ground_variation.gdshader")
const TREES = LANDSCAPE.TREES
const FONT = preload("res://assets/fonts/Silkscreen-Regular.ttf")
var _route: Node2D
var _trees: Array[Sprite2D] = []

func _ready() -> void:
    _route = get_parent()
    var terrain := TileMapLayer.new()
    terrain.name = "MeadowTerrain"
    terrain.tile_set = TILESET
    terrain.rendering_quadrant_size = 128
    terrain.z_index = -10
    terrain.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    var material := ShaderMaterial.new()
    material.shader = GROUND
    terrain.material = material
    for x in range(-48,0):
        for y in 40:
            terrain.set_cell(Vector2i(x,y),0,Vector2i(posmod(x*3+y,2),0))
    add_child(terrain)
    var lane := Sprite2D.new()
    lane.texture = ROAD
    lane.centered = false
    lane.position = Vector2(-768,0)
    lane.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    lane.z_index = -8
    lane.material = material
    add_child(lane)
    for i in TREE_LAYOUT.size():
        var spot: Array = TREE_LAYOUT[i]
        var tree := Sprite2D.new()
        tree.name = "MeadowCottonwood%02d"%i
        tree.texture = TREES[spot[2]%TREES.size()]
        tree.flip_h = spot[3]
        tree.position = Vector2(spot[0],spot[1])
        tree.offset.y = floorf(tree.texture.get_height()*0.5)-tree.texture.get_image().get_used_rect().end.y
        tree.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        var canopy := ShaderMaterial.new()
        canopy.shader = LANDSCAPE.CANOPY
        canopy.set_shader_parameter("canopy_opacity",1.0)
        tree.material = canopy
        _route.get_node("RouteDecor").add_child(tree)
        _trees.append(tree)
        var body := StaticBody2D.new()
        body.position = Vector2(0,-3)
        var shape := CollisionShape2D.new()
        var rectangle := RectangleShape2D.new()
        rectangle.size = Vector2(10,7)
        shape.shape = rectangle
        body.add_child(shape)
        tree.add_child(body)
    for spot in TUFT_LAYOUT:
        var tuft := Sprite2D.new()
        tuft.texture = TUFTS[spot[2]]
        tuft.flip_h = spot[3]
        tuft.position = Vector2(spot[0],spot[1])
        tuft.offset.y = floorf(tuft.texture.get_height()*0.5)-tuft.texture.get_image().get_used_rect().end.y
        tuft.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        _route.get_node("RouteDecor").add_child(tuft)
    var label := Label.new()
    label.text = "< HOMETOWN"
    label.position = Vector2(-744,464)
    label.add_theme_font_override("font",FONT)
    label.add_theme_font_size_override("font_size",8)
    label.add_theme_color_override("font_color",Color("#e5ddba"))
    label.add_theme_color_override("font_outline_color",Color("#293831"))
    label.add_theme_constant_override("outline_size",2)
    add_child(label)

func _process(delta: float) -> void:
    var courier: Node2D = _route.get_node("Player")
    for tree in _trees:
        var covered := courier.position.y<tree.position.y-2 and tree.get_rect().has_point(tree.to_local(courier.global_position+Vector2(0,-16)))
        var current: float = tree.material.get_shader_parameter("canopy_opacity")
        tree.material.set_shader_parameter("canopy_opacity",move_toward(current,0.35 if covered else 1.0,delta*3))
