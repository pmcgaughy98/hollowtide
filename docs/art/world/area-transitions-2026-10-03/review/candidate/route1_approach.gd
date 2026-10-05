extends Node2D
const LANDSCAPE = preload("res://scripts/area_landscape.gd")
const ROAD = preload("res://assets/sprites/world/area_transitions_2026_10_03/route1_meadow_approach.png")
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
    var points := [
        Vector2(-688,128),Vector2(-608,112),Vector2(-480,144),Vector2(-336,112),Vector2(-224,128),Vector2(-96,112),
        Vector2(-688,288),Vector2(-528,224),Vector2(-352,288),Vector2(-208,288),Vector2(-80,288),
        Vector2(-704,448),Vector2(-512,448),Vector2(-400,480),Vector2(-240,464),
        Vector2(-672,616),Vector2(-576,608),Vector2(-416,608),Vector2(-240,600),Vector2(-96,584),
    ]
    for i in points.size():
        var tree := Sprite2D.new()
        tree.name = "MeadowCottonwood%02d"%i
        tree.texture = TREES[i%TREES.size()]
        tree.position = points[i]
        tree.offset.y = floorf(tree.texture.get_height()*0.5)-tree.texture.get_image().get_used_rect().end.y
        tree.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        var canopy := ShaderMaterial.new()
        canopy.shader = LANDSCAPE.CANOPY
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
