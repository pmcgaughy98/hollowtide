extends Node2D
## A cached historic street with run-local address observations.
## It shares the original courier dialogue/notes; no new save or reward system.
const TILESET = preload("res://assets/tilesets/route1_rd_2026_10_01/route1_ground_polished.tres")
const SHOP = preload("res://assets/sprites/world/area_transitions_2026_10_03/brick_shop.png")
const LEDGER = preload("res://assets/sprites/world/area_transitions_2026_10_03/ledger_house.png")
const STREET = preload("res://assets/sprites/world/historic_street_2026_10_03/street_pavers.png")
const MARK = preload("res://assets/sprites/world/route1_rd_2026_10_01/marker.png")
const GROUND = preload("res://assets/sprites/world/route1_landscape_2026_10_03/ground_variation.gdshader")
const CANOPY = preload("res://assets/sprites/world/route1_landing_loop_2026_10_03/canopy_visibility.gdshader")
const FONT = preload("res://assets/fonts/Silkscreen-Regular.ttf")
const SHRUB = preload("res://assets/sprites/world/route1_rd_2026_10_02/bank_shrub_4.png")
const TREES = [
    preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_north.png"),
    preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_bank_bend.png"),
    preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_east.png"),
    preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_office_grove.png"),
    preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_ridge.png"),
]
const SITES = {"board":Vector2(384,664),"shop":Vector2(544,428),"ledger":Vector2(224,428)}
const TREE_POINTS = [
    Vector2(72,160),Vector2(168,160),Vector2(288,168),Vector2(480,168),Vector2(600,160),Vector2(696,184),
    Vector2(72,368),Vector2(696,384),Vector2(80,576),Vector2(688,576),
    Vector2(96,784),Vector2(192,816),Vector2(576,816),Vector2(672,784),
]
var started := false
var lintel_checked := false
var ledger_checked := false
var handoff_verified := false
var last_submitted_number := 0
var _route: Node2D
var _status: Label
var _trees: Array[Sprite2D] = []
func _ready() -> void:
    _route = get_parent().get("route")
    var ground := TileMapLayer.new()
    ground.name="Terrain";ground.tile_set=TILESET
    ground.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;ground.z_index=-10
    var material:=ShaderMaterial.new();material.shader=GROUND;ground.material=material
    for x in 48:
        for y in 56:ground.set_cell(Vector2i(x,y),0,Vector2i(posmod(x*3+y,2),0))
    add_child(ground)
    var street:=Sprite2D.new()
    street.name="HistoricPaving";street.texture=STREET;street.centered=false;street.z_index=-7
    street.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;add_child(street)
    var shop:=_prop("RemodelledBrickShop",SHOP,Vector2(544,400),0.85)
    _solid("ShopFootprint",Rect2(468,336,152,62))
    _prop("PublicLedgerHouse",LEDGER,Vector2(224,400),0.85)
    _solid("LedgerFootprint",Rect2(160,326,128,74))
    # Separate current shop fitting from the retained doorway lintel.
    _label("CurrentShopAddress","18",Vector2(537,327))
    _label("OldShopLintel","6",Vector2(541,353))
    _label("LedgerCaption","STREET LEDGER",Vector2(168,410))
    var board:=_prop("StreetCourierBoard",MARK,Vector2(384,644),0.75)
    _solid("BoardFoot",Rect2(-3,-5,6,5),board)
    _status=_label("AddressBoardStatus","",Vector2(336,604))
    _label("ReturnWaymark","BRANCH / BRIDGE V",Vector2(334,795))
    for i in TREE_POINTS.size():
        var tree:=_prop("HistoricCottonwood%02d"%i,TREES[i%TREES.size()],TREE_POINTS[i])
        _solid("FootCollision",Rect2(-5,-6,10,7),tree)
        var canopy:=ShaderMaterial.new();canopy.shader=CANOPY
        canopy.set_shader_parameter("canopy_opacity",1.0);tree.material=canopy;_trees.append(tree)
    for at in [Vector2(120,456),Vector2(648,456),Vector2(256,600),Vector2(512,600),Vector2(272,776),Vector2(496,776)]:
        _prop("PlantedStreetEdge%d%d"%[int(at.x),int(at.y)],SHRUB,at,0.65)
    for item in [
        ["NorthEdge",Rect2(0,-16,768,16)],["WestEdge",Rect2(-16,0,16,896)],
        ["EastEdge",Rect2(768,0,16,896)],["SouthWestEdge",Rect2(0,896,344,16)],
        ["SouthEastEdge",Rect2(424,896,344,16)]]:
        _solid(item[0],item[1])
    var camera:Camera2D=$Player/Camera2D
    camera.limit_left=0;camera.limit_right=768;camera.limit_top=0;camera.limit_bottom=896
    camera.offset=Vector2.ZERO;camera.position=Vector2(0,-80)
    camera.reset_smoothing()
    _update_board()
func _prop(label:String,texture:Texture2D,at:Vector2,ratio:float=1.0) -> Sprite2D:
    var sprite:=Sprite2D.new()
    sprite.name=label;sprite.texture=texture;sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.position=at;sprite.scale=Vector2.ONE*ratio
    var used:=texture.get_image().get_used_rect()
    sprite.offset.y=floorf(texture.get_height()*0.5)-used.end.y
    $RouteDecor.add_child(sprite);return sprite
func _solid(label:String,bounds:Rect2,parent:Node=null) -> void:
    var body:=StaticBody2D.new();body.name=label;body.position=bounds.get_center()
    var shape:=CollisionShape2D.new();var rectangle:=RectangleShape2D.new()
    rectangle.size=bounds.size;shape.shape=rectangle;body.add_child(shape)
    (self if parent==null else parent).add_child(body)
func _label(label:String,text:String,at:Vector2) -> Label:
    var caption:=Label.new();caption.name=label;caption.text=text;caption.position=at;caption.z_index=9
    caption.add_theme_font_override("font",FONT);caption.add_theme_font_size_override("font_size",8)
    caption.add_theme_color_override("font_color",Color("#e5ddba"))
    caption.add_theme_color_override("font_outline_color",Color("#293831"))
    caption.add_theme_constant_override("outline_size",1);add_child(caption);return caption
func nearest_site() -> String:
    var closest:="";var distance:=28.0
    for site in SITES:
        var gap:float=$Player.position.distance_to(SITES[site])
        if gap<distance:distance=gap;closest=site
    return closest
func interaction_hint() -> String:
    match nearest_site():
        "board":return "E  Read street courier board"
        "shop":return "E  Compare shop doorway numbers"
        "ledger":return "E  Read public street ledger"
    return "WASD / arrows  Move    South lane returns to riverfront"
func interact(_controller:Node2D) -> void:
    match nearest_site():
        "board":visit_board()
        "shop":visit_shop()
        "ledger":visit_ledger()
func _process(delta:float) -> void:
    var courier:Node2D=$Player
    for tree in _trees:
        var head:=tree.to_local(courier.global_position+Vector2(0,-16))
        var covered:bool=courier.global_position.y<tree.global_position.y-2 and tree.get_rect().has_point(head)
        var current:float=tree.material.get_shader_parameter("canopy_opacity")
        tree.material.set_shader_parameter("canopy_opacity",move_toward(current,0.35 if covered else 1.0,delta*3))
