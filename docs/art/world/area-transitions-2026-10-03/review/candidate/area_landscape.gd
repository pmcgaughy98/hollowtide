extends Node2D
@export_enum("hometown", "riverfront") var area_id := "hometown"
const TILESET = preload("res://assets/tilesets/route1_rd_2026_10_01/route1_ground_polished.tres")
const HOME = preload("res://assets/sprites/world/hometown_courtyard_2026_10_03/courtyard_home.png")
const HALL = preload("res://assets/sprites/world/route1_rd_2026_10_02/dispatch_hall_complete.png")
const MARK = preload("res://assets/sprites/world/route1_rd_2026_10_01/marker.png")
const DISPATCHER = preload("res://assets/sprites/world/route1_rd_2026_10_01/dispatcher.png")
const FEMALE = preload("res://assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/female_chibi_walk_eight_directions_native80.png")
const FINISH = preload("res://scripts/effects/courier_finish.gdshader")
const SHOP = preload("res://assets/sprites/world/area_transitions_2026_10_03/brick_shop.png")
const LEDGER = preload("res://assets/sprites/world/area_transitions_2026_10_03/ledger_house.png")
const HOME_ROAD = preload("res://assets/sprites/world/area_transitions_2026_10_03/hometown_streets.png")
const CITY_ROAD = preload("res://assets/sprites/world/area_transitions_2026_10_03/riverfront_streets.png")
const GROUND = preload("res://assets/sprites/world/route1_landscape_2026_10_03/ground_variation.gdshader")
const CANOPY = preload("res://assets/sprites/world/route1_landing_loop_2026_10_03/canopy_visibility.gdshader")
const WATER_MASK = preload("res://assets/sprites/world/area_transitions_2026_10_03/riverfront_water_mask.png")
const WATER = preload("res://assets/sprites/world/route1_crossing_2026_10_02/river_water_native32.png")
const FLOW = preload("res://assets/sprites/world/route1_crossing_2026_10_02/river_flow.gdshader")
const BRIDGE = preload("res://assets/sprites/world/route1_crossing_2026_10_02/river_bridge_peg_fixed.png")
const FONT = preload("res://assets/fonts/Silkscreen-Regular.ttf")
const TREES = [
    preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_west.png"),
    preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_north.png"),
    preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_bank_bend.png"),
    preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_east.png"),
    preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_office_grove.png"),
    preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_ridge.png"),
]
const TUFT = preload("res://assets/sprites/world/route1_landscape_2026_10_03/meadow_tuft_1.png")
const SHRUB = preload("res://assets/sprites/world/route1_rd_2026_10_02/bank_shrub_4.png")
var _area: Node2D
var _trees: Array[Sprite2D] = []
var _clock := 0.0
var _water: ShaderMaterial

func _ready() -> void:
    _area = get_parent()
    var ground := TileMapLayer.new()
    ground.name = "Terrain"
    ground.tile_set = TILESET
    ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    ground.z_index = -10
    var material := ShaderMaterial.new()
    material.shader = GROUND
    ground.material = material
    for x in 64:
        for y in 48:
            ground.set_cell(Vector2i(x,y),0,Vector2i(posmod(x*3+y,2),0))
    add_child(ground)
    _surface("Streets", HOME_ROAD if area_id == "hometown" else CITY_ROAD, Vector2.ZERO, -7)
    _wall("North",Vector2(512,-8),Vector2(1024,16))
    _wall("South",Vector2(512,776),Vector2(1024,16))
    if area_id == "hometown":
        _build_home()
        _wall("West",Vector2(-8,384),Vector2(16,768))
        _wall("EastAboveEntrance",Vector2(1032,248),Vector2(16,496))
        _wall("EastBelowEntrance",Vector2(1032,656),Vector2(16,224))
    else:
        _build_city()
        _wall("East",Vector2(1032,384),Vector2(16,768))
        _wall("WestAboveBridge",Vector2(-8,248),Vector2(16,496))
        _wall("WestBelowBridge",Vector2(-8,648),Vector2(16,240))
        _wall("RiverNorth",Vector2(112,248),Vector2(224,496))
        _wall("RiverSouth",Vector2(112,648),Vector2(224,240))

func _surface(label: String, texture: Texture2D, at: Vector2, depth: int) -> Sprite2D:
    var sprite := Sprite2D.new()
    sprite.name = label
    sprite.texture = texture
    sprite.position = at
    sprite.centered = false
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.z_index = depth
    add_child(sprite)
    return sprite

func _prop(label: String, texture: Texture2D, at: Vector2, ratio: float = 1.0) -> Sprite2D:
    var sprite := Sprite2D.new()
    sprite.name = label
    sprite.texture = texture
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.position = at
    sprite.scale = Vector2.ONE * ratio
    var used := texture.get_image().get_used_rect()
    sprite.offset.y = floorf(texture.get_height()*0.5)-used.end.y
    _area.get_node("RouteDecor").add_child(sprite)
    return sprite

func _wall(label: String, at: Vector2, size: Vector2, parent: Node = null) -> void:
    var body := StaticBody2D.new()
    body.name = label
    body.position = at
    var shape := CollisionShape2D.new()
    var rectangle := RectangleShape2D.new()
    rectangle.size = size
    shape.shape = rectangle
    body.add_child(shape)
    (self if parent == null else parent).add_child(body)

func _label(text: String, at: Vector2) -> void:
    var label := Label.new()
    label.text = text
    label.position = at
    label.add_theme_font_override("font",FONT)
    label.add_theme_font_size_override("font_size",8)
    label.add_theme_color_override("font_color",Color("#e5ddba"))
    label.add_theme_color_override("font_outline_color",Color("#293831"))
    label.add_theme_constant_override("outline_size",2)
    add_child(label)

func _tree(at: Vector2, variant: int) -> void:
    var tree := _prop("Cottonwood%02d"%_trees.size(),TREES[variant%TREES.size()],at)
    _wall("FootCollision",Vector2(0,-3),Vector2(10,7),tree)
    var material := ShaderMaterial.new()
    material.shader = CANOPY
    tree.material = material
    _trees.append(tree)

func _build_home() -> void:
    for pair in [[Vector2(224,256),"CourtyardHome"],[Vector2(560,224),"NeighborHome"],[Vector2(288,608),"GardenHome"]]:
        _prop(pair[1],HOME,pair[0],0.75)
        _wall(pair[1]+"Footprint",pair[0]+Vector2(0,-23),Vector2(96,50))
    var hall := _prop("DispatcherHall",HALL,Vector2(768,418),0.75)
    _wall("HallFootprint",Vector2(0,-46),Vector2(106,84),hall)
    _prop("Dispatcher",DISPATCHER,Vector2(768,456),0.652174)
    _label("COURIER HALL",Vector2(728,306))
    _prop("LeveeDirectionNotice",MARK,Vector2(944,492),0.65)
    _label("ROUTE 1 >",Vector2(902,457))
    _prop("GardenNotice",MARK,Vector2(448,594),0.6)
    _label("SHARED GARDEN",Vector2(405,550))
    for row in 3:
        for col in 5:
            _prop("GardenPlant%d%d"%[row,col],TUFT,Vector2(396+col*16,564+row*16),0.35)
    var points := [
        Vector2(80,128),Vector2(144,160),Vector2(368,128),Vector2(432,160),
        Vector2(656,112),Vector2(736,136),Vector2(864,128),Vector2(944,168),
        Vector2(80,304),Vector2(96,392),Vector2(96,488),Vector2(80,608),
        Vector2(416,432),Vector2(464,464),Vector2(640,640),Vector2(720,672),
        Vector2(928,336),Vector2(944,416),Vector2(896,608),Vector2(944,680),
        Vector2(96,736),Vector2(176,704),Vector2(384,736),Vector2(496,712),
        Vector2(816,736),Vector2(928,744),
    ]
    for i in points.size():
        _tree(points[i],i)
    for at in [Vector2(336,240),Vector2(656,368),Vector2(368,496),Vector2(816,592),Vector2(592,720)]:
        _prop("YardShrub%d"%int(at.x),SHRUB,at,0.8)

func _build_city() -> void:
    var river := _surface("RiverSurface",WATER_MASK,Vector2.ZERO,-9)
    _water = ShaderMaterial.new()
    _water.shader = FLOW
    _water.set_shader_parameter("river_texture",WATER)
    _water.set_shader_parameter("surface_size",Vector2(224,768))
    river.material = _water
    _surface("BridgeDeck",BRIDGE,Vector2(0,456),-6)
    var rail := _prop("BridgeSouthRail",BRIDGE,Vector2(144,547))
    rail.offset = Vector2.ZERO
    rail.region_enabled = true
    rail.region_rect = Rect2(0,70,288,42)
    var hall := _prop("CityCourierBranch",HALL,Vector2(512,362),0.75)
    _wall("HallFootprint",Vector2(0,-46),Vector2(106,84),hall)
    var clerk := _prop("CityCourierClerk",FEMALE,Vector2(512,376),30.0/64.0)
    clerk.region_enabled = true
    clerk.region_rect = Rect2(0,0,80,80)
    clerk.offset = Vector2(0,-32)
    var finish := ShaderMaterial.new()
    finish.shader = FINISH
    clerk.material = finish
    _wall("ClerkFootprint",Vector2(0,-4),Vector2(16,10),clerk)
    _label("COURIER BRANCH",Vector2(466,254))
    var shop := _prop("ReusedBrickShop",SHOP,Vector2(768,264),0.75)
    _wall("ShopFootprint",Vector2(0,-39),Vector2(170,76),shop)
    var ledger := _prop("StreetLedgerHouse",LEDGER,Vector2(336,640),0.75)
    _wall("LedgerFootprint",Vector2(0,-43),Vector2(146,82),ledger)
    _prop("CityDirectionBoard",MARK,Vector2(816,492),0.75)
    _label("CITY ROUTES",Vector2(776,459))
    var points := [
        Vector2(288,112),Vector2(368,136),Vector2(464,112),Vector2(560,128),
        Vector2(640,112),Vector2(864,136),Vector2(944,168),Vector2(944,304),
        Vector2(304,304),Vector2(336,384),Vector2(896,400),
        Vector2(640,624),Vector2(720,664),Vector2(944,608),Vector2(944,712),
        Vector2(448,736),Vector2(544,712),Vector2(832,736),
    ]
    for i in points.size():
        _tree(points[i],i)
    for at in [Vector2(288,192),Vector2(288,456),Vector2(608,552),Vector2(896,552),Vector2(448,672)]:
        _prop("CityShrub%d"%int(at.x),SHRUB,at,0.8)

func _process(delta: float) -> void:
    _clock = fmod(_clock+delta,320.0)
    if _water:
        _water.set_shader_parameter("flow_offset",Vector2(0,fmod(floorf(_clock*2),32)))
    var player: Node2D = _area.get_node("Player")
    for tree in _trees:
        var head := tree.to_local(player.global_position+Vector2(0,-16))
        var covered := player.global_position.y<tree.global_position.y-2 and tree.get_rect().has_point(head)
        var current: float = tree.material.get_shader_parameter("canopy_opacity")
        tree.material.set_shader_parameter("canopy_opacity",move_toward(current,0.35 if covered else 1.0,delta*3))
