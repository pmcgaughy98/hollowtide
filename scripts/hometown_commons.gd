extends Node2D
## Compose the existing pavers, planting and waymarks into a readable first hub.
const PAVING = preload("res://assets/sprites/world/historic_frontage_2026_10_04/street_pavers.png")
const BED = preload("res://assets/sprites/world/hometown_garden_2026_10_04/timber_bed.png")
const CUTTINGS = preload("res://assets/sprites/world/hometown_garden_2026_10_04/cuttings_row.png")
const PATHS := [Rect2(528,472,288,80),Rect2(736,432,64,40)]
var _tile: AtlasTexture

func _ready() -> void:
    name = "CourierCommons"
    z_index = -5
    var landscape: Node2D = get_parent()
    _tile = AtlasTexture.new()
    _tile.atlas = PAVING
    _tile.region = Rect2(352,448,32,32)
    for at in [Vector2(608,458),Vector2(676,458),Vector2(608,604),Vector2(792,604)]:
        landscape._prop("CommonsBed",BED,at,0.8)
        for row in [-12,-25]:
            var plants: Sprite2D = landscape._prop("CommonsCuttings",CUTTINGS,at+Vector2(0,row),0.8)
            plants.z_index = 1
        landscape._wall("CommonsBedFeet",at-Vector2(0,18),Vector2(42,36))
    landscape._tree(Vector2(624,380),2)
    landscape._tree(Vector2(688,388),4)
    for at in [Vector2(192,304),Vector2(256,304),Vector2(520,286),Vector2(600,286),Vector2(840,456),Vector2(840,560),Vector2(752,608)]:
        landscape._prop("CommonsPlanting",landscape.SHRUB,at,0.75)
    landscape._prop("FirstMorningWaymark",landscape.MARK,Vector2(264,318),0.6)
    landscape._wall("FirstWaymarkFeet",Vector2(264,316),Vector2(8,6))
    landscape._label("HALL / GARDEN >",Vector2(232,289))
    landscape._prop("CommonsMapBoard",landscape.MARK,Vector2(524,488),0.65)
    landscape._wall("MapBoardFeet",Vector2(524,484),Vector2(8,6))
    landscape._label("ROUTE MAP",Vector2(500,459))
    landscape._label("COURIER SQUARE",Vector2(632,548))
    landscape._label("< GARDEN / HOME",Vector2(564,562))
    landscape._label("HALL ^     LEVEE >",Vector2(712,562))
    for at in [Vector2(344,304),Vector2(448,288),Vector2(520,400),Vector2(832,672),Vector2(224,672)]:
        landscape._prop("CommonsMeadow",landscape.TUFT,at)
    queue_redraw()

func _draw() -> void:
    if _tile == null: return
    for path in PATHS:
        draw_rect(path.grow(2),Color("#576658"))
        for x in range(int(path.position.x),int(path.end.x),32):
            for y in range(int(path.position.y),int(path.end.y),32):
                draw_texture_rect(_tile,Rect2(Vector2(x,y),Vector2(minf(32,path.end.x-x),minf(32,path.end.y-y))),false)
