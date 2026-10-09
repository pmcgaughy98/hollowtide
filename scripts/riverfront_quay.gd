extends Node2D
## A walkable riverfront district, composed from existing approved world art.
## Local prose and the optional quay round are proposals. State lives in this cached area.
const PAVING = preload("res://assets/sprites/world/historic_frontage_2026_10_04/street_pavers.png")
const BRIDGE = preload("res://assets/sprites/world/route1_crossing_2026_10_02/river_bridge_peg_fixed.png")
const WALL = preload("res://assets/sprites/world/route1_rd_2026_10_02/retaining_wall_east.png")
const HEIGHT = preload("res://assets/sprites/world/route1_rd_2026_10_01/height.png")
const REEDS = preload("res://assets/sprites/world/route1_rd_2026_10_02/bank_reeds_3.png")
const STONES = preload("res://assets/sprites/world/route1_landscape_2026_10_03/river_stones.png")
const BED = preload("res://assets/sprites/world/hometown_garden_2026_10_04/timber_bed.png")
const CUTTINGS = preload("res://assets/sprites/world/hometown_garden_2026_10_04/cuttings_row.png")
const WORKSHOP = preload("res://assets/sprites/world/historic_frontage_2026_10_04/repair_workshop.png")
const KEEPER = preload("res://assets/sprites/world/historic_frontage_2026_10_04/workshop_keeper.png")
const NEIGHBOR = preload("res://assets/sprites/world/hometown_garden_2026_10_04/garden_neighbor.png")
const WALKER = preload("res://assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/female_chibi_walk_eight_directions_native80.png")
const SITES := {"quay_board":Vector2(368,472),"quay_landing":Vector2(168,336),"quay_goods":Vector2(768,296),"quay_garden":Vector2(688,680),"quay_gate":Vector2(608,556)}
const STOPS := ["quay_landing","quay_goods","quay_garden"]
const PATHS := [
    Rect2(224,160,56,336), Rect2(224,304,176,64), Rect2(256,400,224,48),
    Rect2(352,400,64,112), Rect2(384,384,240,112), Rect2(608,400,224,48),
    Rect2(736,272,64,144), Rect2(392,248,48,176),
    Rect2(232,544,32,160), Rect2(240,672,224,32),
    Rect2(432,544,32,160), Rect2(448,656,368,48), Rect2(576,520,64,184),
    Rect2(816,544,48,160), Rect2(800,656,48,48),
    Rect2(352,480,64,32), Rect2(448,480,64,48),
]
var observed: Dictionary = {}
var started := false
var completed := false
var _landscape: Node2D
var _area: Node2D
var _paver: AtlasTexture
var _wood: AtlasTexture
var _rail: AtlasTexture
var _gate: StaticBody2D
var _gate_art: Array[Sprite2D] = []
var _status: Label
var _walker: Sprite2D
var _walker_phase := 0.0
var _walker_direction := 1.0
var _pause := 1.0

func _ready() -> void:
    name = "RiverfrontQuay"
    z_index = -5
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    _landscape = get_parent()
    _area = _landscape.get_parent()
    _paver = _atlas(PAVING,Rect2(352,448,32,32))
    _wood = _atlas(BRIDGE,Rect2(48,32,32,32))
    _rail = _atlas(BRIDGE,Rect2(48,12,32,20))
    _build_landing()
    _build_branch_court()
    _build_garden()
    _build_life()
    queue_redraw()

func _atlas(texture: Texture2D, region: Rect2) -> AtlasTexture:
    var part := AtlasTexture.new()
    part.atlas = texture
    part.region = region
    return part

func _solid(label: String, rect: Rect2) -> StaticBody2D:
    var body := StaticBody2D.new()
    body.name = label
    body.position = rect.get_center()
    var shape := CollisionShape2D.new()
    shape.name = "CollisionShape2D"
    var rectangle := RectangleShape2D.new()
    rectangle.size = rect.size
    shape.shape = rectangle
    body.add_child(shape)
    add_child(body)
    return body

func _wall_line(label: String, at: Vector2, length: float, vertical := false, collision := true) -> Array[Sprite2D]:
    var sprites: Array[Sprite2D] = []
    for i in range(0,int(length),32):
        var sprite: Sprite2D = _landscape._prop(label,WALL,at+(Vector2(0,i+16) if vertical else Vector2(i+16,0)),0.6)
        if vertical:
            sprite.rotation = PI*0.5
            sprite.offset = Vector2.ZERO
        sprites.append(sprite)
    if collision:
        _solid(label+"Feet",Rect2(at+Vector2(-4,-5),Vector2(8,length) if vertical else Vector2(length,8)))
    return sprites

func _build_landing() -> void:
    # The water collision in area_landscape leaves only this deck-shaped opening.
    for x in range(128,224,32):
        var back: Sprite2D = _landscape._prop("LandingBackRail",_rail,Vector2(x+16,304))
        back.offset = Vector2(0,-10)
        var front: Sprite2D = _landscape._prop("LandingFrontRail",_rail,Vector2(x+16,368))
        front.offset = Vector2(0,-10)
    _solid("LandingNorthRail",Rect2(124,296,100,8))
    _solid("LandingSouthRail",Rect2(124,364,100,8))
    _solid("LandingEnd",Rect2(120,304,8,60))
    _landscape._prop("LandingGauge",HEIGHT,Vector2(142,332),0.7)
    _solid("GaugeFoot",Rect2(139,326,6,6))
    _landscape._label("RIVER LANDING",Vector2(290,290))
    # Bank detail stays outside the walking lane and never widens the water collision.
    for y in [192,240,400,448,584,664,728]:
        _landscape._prop("BankReeds",REEDS,Vector2(220,y),0.85)
    for y in [212,432,620,724]:
        _landscape._prop("BankStones",STONES,Vector2(215,y),0.65)
    _wall_line("UpperQuayEdge",Vector2(224,160),128,true,false)
    _wall_line("MiddleQuayEdge",Vector2(224,384),96,true,false)
    _wall_line("LowerQuayEdge",Vector2(224,560),176,true,false)

func _build_branch_court() -> void:
    _landscape._prop("QuayRepairFront",WORKSHOP,Vector2(416,248),0.6)
    _solid("RepairFrontFeet",Rect2(374,207,84,40))
    _landscape._label("ROPE / REPAIRS",Vector2(373,256))
    _landscape._prop("QuayRoundKeeper",KEEPER,Vector2(340,460),0.5)
    _solid("RoundKeeperFeet",Rect2(336,453,8,7))
    _landscape._prop("QuayRoundBoard",_landscape.MARK,Vector2(368,448),0.65)
    _solid("RoundBoardFeet",Rect2(364,441,8,7))
    _status = _caption("QUAY WALK",Vector2(336,408))
    _landscape._label("< LANDING",Vector2(280,382))
    _landscape._label("GARDEN >",Vector2(394,562))
    # Repeated planted edges give the branch and shop their own recognizable courts.
    for at in [Vector2(424,384),Vector2(584,384),Vector2(656,384),Vector2(688,320),Vector2(848,320)]:
        _bed(at,0.65)
    for at in [Vector2(376,152),Vector2(576,216),Vector2(656,240),Vector2(928,592),Vector2(928,672)]:
        _landscape._prop("QuayShrub",_landscape.SHRUB,at,0.85)
    for at in [Vector2(344,208),Vector2(600,288),Vector2(688,192),Vector2(904,448),Vector2(896,640)]:
        _landscape._prop("QuayGroundCover",_landscape.TUFT,at)
    _landscape._prop("GoodsNotice",_landscape.MARK,Vector2(816,292),0.5)
    _landscape._label("DRY GOODS",Vector2(798,270))

func _build_garden() -> void:
    _wall_line("GardenNorthWest",Vector2(448,580),128)
    _wall_line("GardenNorthEast",Vector2(640,580),160)
    _wall_line("GardenSouth",Vector2(448,736),352)
    for x in [448,800]:
        _wall_line("GardenSideNorth",Vector2(x,580),72,true)
        _wall_line("GardenSideSouth",Vector2(x,708),28,true)
    _gate_art = _wall_line("GardenGate",Vector2(576,580),64,false,false)
    _gate = _solid("GardenGateFeet",Rect2(572,575,68,8))
    for at in [Vector2(512,640),Vector2(728,640),Vector2(512,728),Vector2(728,728)]:_bed(at,0.85)
    _landscape._prop("CuttingsKeeper",NEIGHBOR,Vector2(688,658),0.75)
    _solid("CuttingsKeeperFeet",Rect2(684,651,8,7))
    _landscape._label("SHELTERED CUTTINGS",Vector2(544,752))
    _landscape._label("BRANCH GATE",Vector2(577,546))

func _bed(at: Vector2, size: float) -> void:
    _landscape._prop("QuayPlanter",BED,at,size)
    for row in [-12,-28]:
        var plants: Sprite2D = _landscape._prop("QuayCuttings",CUTTINGS,at+Vector2(0,row*size),size)
        plants.z_index = 1
    _solid("PlanterFeet",Rect2(at-Vector2(26,42)*size,Vector2(52,42)*size))

func _build_life() -> void:
    _walker = Sprite2D.new()
    _walker.name = "QuayRunner"
    _walker.texture = WALKER
    _walker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    _walker.region_enabled = true
    _walker.scale = Vector2.ONE*(30.0/64.0)
    _walker.offset = Vector2(0,-32)
    _walker.position = Vector2(640,426)
    var finish := ShaderMaterial.new()
    finish.shader = _landscape.FINISH
    _walker.material = finish
    _area.get_node("RouteDecor").add_child(_walker)
    _walker.region_rect = Rect2(0,480,80,80)

func _caption(text: String, at: Vector2) -> Label:
    var label := Label.new()
    label.text = text
    label.position = at
    label.add_theme_font_override("font",_landscape.FONT)
    label.add_theme_font_size_override("font_size",8)
    label.add_theme_color_override("font_color",Color("#e5ddba"))
    label.add_theme_color_override("font_outline_color",Color("#293831"))
    label.add_theme_constant_override("outline_size",2)
    # World captions share the landscape's depth, not the ground surface's depth.
    _landscape.add_child(label)
    return label

func hint(site: String) -> String:
    match site:
        "quay_board": return "E  Read quay walk" if not completed else "E  Review the quay observations"
        "quay_landing": return "E  Read the landing gauge"
        "quay_goods": return "E  Check the shop's dry ledge"
        "quay_garden": return "E  Speak to the cuttings keeper"
        "quay_gate": return "E  Read the branch-gate notice"
    return ""

func interact(site: String, controller: Node2D) -> void:
    if site in STOPS:
        observed[site] = true
        var messages := {
            "quay_landing":"RIVER LANDING\nThe pale wear-line on the gauge stands above today's water. The deck stays clear so couriers can read it from the bank. You note the exposed mark.",
            "quay_goods":"DRY GOODS\nThe shopfront stands on a raised stone ledge above the damp paving. Its sheltered threshold keeps arriving goods away from the river edge. You note the higher approach.",
            "quay_garden":"CUTTINGS KEEPER\nThe low wall takes the river wind; the young plants stand behind it. We carry them through the side openings while the branch gate is shut. You note the sheltered rows.",
        }
        controller._show_message(messages[site]+"\n\nQuay observations: %d / 3. Return to the board by the bridge when ready."%observed.size())
    elif site == "quay_gate":
        controller._show_message("BRANCH GATE\n"+("The gate is open. This path leads straight back to the courier branch." if completed else "Closed during the morning check. Both garden side paths are open. The quay board beside the bridge lists the three stops."))
    elif site == "quay_board":
        started = true
        if observed.size() == STOPS.size():
            if not completed:
                completed = true
                _gate.get_node("CollisionShape2D").set_deferred("disabled",true)
                for sprite in _gate_art: sprite.hide()
            controller._show_message("QUAY WALK COMPLETE\nThe landing mark, dry-goods ledge and sheltered rows are recorded. The keeper opens the garden's north gate. It now leads straight back to the branch court.\n\nYou can still reach the old city to the north and the relay yard to the east.")
        else:
            var remaining: Array[String] = []
            for pair in [["quay_landing","landing gauge: west along the promenade"],["quay_goods","dry-goods ledge: north at the brick shop"],["quay_garden","cuttings keeper: through either garden side path"]]:
                if not observed.has(pair[0]): remaining.append(pair[1])
            controller._show_message("QUAY WALK  /  %d OF 3\nThe branch keeper is checking how the riverfront carries its daily work. Look around these places, then return here to open the garden's branch-side gate:\n\n"%observed.size()+"\n".join(remaining))
    _status.text = "GATE OPEN" if completed else ("QUAY WALK %d/3"%observed.size() if started or not observed.is_empty() else "QUAY WALK")

func _process(delta: float) -> void:
    if _walker == null:return
    var journey: Node = _area.get_parent()
    if journey == null or journey.get("route") == null:return
    var route: Node = journey.route
    var courier: Node2D = _area.get_node("Player")
    var blocked: bool = route._panel.visible or route._notes_panel.visible or route._party_panel.visible or (journey.atlas != null and journey.atlas.opened)
    var nearby := _walker.position.distance_to(courier.position) < 32
    if journey.reduced_motion or blocked or nearby:
        _walker.region_rect.position.x = 0
        return
    if _pause > 0:
        _pause = maxf(0,_pause-delta)
        _walker.region_rect.position.x = 0
        return
    _walker_phase += delta*7
    _walker.position.x += _walker_direction*18*delta
    _walker.region_rect = Rect2(int(_walker_phase)%8*80,480 if _walker_direction>0 else 160,80,80)
    if _walker.position.x >= 840 or _walker.position.x <= 640:
        _walker.position.x = clampf(_walker.position.x,640,840)
        _walker_direction *= -1
        _pause = 2.0

func _tiles(texture: Texture2D, rect: Rect2) -> void:
    for x in range(int(rect.position.x),int(rect.end.x),32):
        for y in range(int(rect.position.y),int(rect.end.y),32):
            draw_texture_rect_region(texture,Rect2(x,y,minf(32,rect.end.x-x),minf(32,rect.end.y-y)),Rect2(0,0,minf(32,rect.end.x-x),minf(32,rect.end.y-y)))

func _draw() -> void:
    if _paver == null:return
    # Tile the union on one shared grid: overlapping paths cannot leave boxed seams.
    var cells: Dictionary = {}
    for path in PATHS:
        for x in range(int(path.position.x),int(path.end.x),8):
            for y in range(int(path.position.y),int(path.end.y),8):cells[Vector2i(x,y)] = true
    for at in cells:
        draw_texture_rect_region(_paver,Rect2(Vector2(at),Vector2(8,8)),Rect2(posmod(at.x,32),posmod(at.y,32),8,8))
        for delta in [Vector2i(-8,0),Vector2i(8,0),Vector2i(0,-8),Vector2i(0,8)]:
            if not cells.has(at+delta):
                var edge: Rect2 = Rect2(at.x-1 if delta.x<0 else at.x+8,at.y,1,8) if delta.x != 0 else Rect2(at.x,at.y-1 if delta.y<0 else at.y+8,8,1)
                draw_rect(edge,Color("#586557"))
    _tiles(_wood,Rect2(128,304,160,60))
