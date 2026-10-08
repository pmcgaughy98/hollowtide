extends Node2D
## A cached city destination. The sorting exercise is run-local; names and text are proposals.
const TILESET = preload("res://assets/tilesets/route1_rd_2026_10_01/route1_ground_polished.tres")
const PAVING = preload("res://assets/sprites/world/historic_frontage_2026_10_04/street_pavers.png")
const WORKSHOP = preload("res://assets/sprites/world/historic_frontage_2026_10_04/repair_workshop.png")
const OFFICE = preload("res://assets/sprites/world/world_linework_2026_10_04/dispatch_hall.png")
const GARDEN_HOME = preload("res://assets/sprites/world/hometown_homes_2026_10_04/garden_home.png")
const KEEPER = preload("res://assets/sprites/world/historic_frontage_2026_10_04/workshop_keeper.png")
const MARK = preload("res://assets/sprites/world/route1_rd_2026_10_01/marker.png")
const BED = preload("res://assets/sprites/world/hometown_garden_2026_10_04/timber_bed.png")
const CUTTINGS = preload("res://assets/sprites/world/hometown_garden_2026_10_04/cuttings_row.png")
const SHRUB = preload("res://assets/sprites/world/route1_rd_2026_10_02/bank_shrub_4.png")
const TUFT = preload("res://assets/sprites/world/route1_landscape_2026_10_03/meadow_tuft_1.png")
const GROUND = preload("res://assets/sprites/world/route1_landscape_2026_10_03/ground_variation.gdshader")
const CANOPY = preload("res://assets/sprites/world/route1_landing_loop_2026_10_03/canopy_visibility.gdshader")
const FONT = preload("res://assets/fonts/Silkscreen-Regular.ttf")
const TREES = [preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_north.png"), preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_east.png"), preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_ridge.png")]
const SITES = {"board": Vector2(208,496), "works": Vector2(256,288), "garden": Vector2(560,288), "bridge": Vector2(400,496), "practice": Vector2(176,352), "return_path": Vector2(640,552)}
const PATHS = [Rect2(0,464,208,48), Rect2(160,464,448,64), Rect2(160,272,448,64), Rect2(160,336,48,128), Rect2(576,336,32,128), Rect2(304,352,176,80), Rect2(232,240,48,48), Rect2(536,240,48,48), Rect2(376,128,48,336), Rect2(608,272,48,304), Rect2(208,544,448,32), Rect2(192,528,32,48)]
var started := false
var bay_checks: Dictionary = {}
var sorted := false
var _route: Node2D
var _trees: Array[Sprite2D] = []
var _status: Label
var _paving_tile: AtlasTexture

func _ready() -> void:
    if get_parent() == get_tree().root:
        call_deferred("_open_journey")
        return
    _route = get_parent().get("route")
    var ground := TileMapLayer.new()
    ground.name = "Terrain"
    ground.tile_set = TILESET
    ground.z_index = -10
    ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    var material := ShaderMaterial.new()
    material.shader = GROUND
    ground.material = material
    for x in 48:
        for y in 40:
            ground.set_cell(Vector2i(x,y),0,Vector2i(posmod(x*3+y,2),0))
    add_child(ground)
    _paving_tile = AtlasTexture.new()
    _paving_tile.atlas = PAVING
    _paving_tile.region = Rect2(352,448,32,32)
    _prop("SortingOffice",OFFICE,Vector2(400,144),0.75)
    _solid("OfficeFeet",Rect2(350,68,100,74))
    _label("OfficeCaption","RELAY OFFICE",Vector2(354,148))
    _prop("RepairBay",WORKSHOP,Vector2(256,248),0.8)
    _solid("WorkshopFeet",Rect2(201,187,110,60))
    _prop("GardenBay",GARDEN_HOME,Vector2(560,248),0.8)
    _solid("GardenHouseFeet",Rect2(509,198,102,48))
    for item in [["works","WORKS / DRY GOODS",Vector2(256,268)], ["garden","GARDENS / CUTTINGS",Vector2(560,268)], ["bridge","BRIDGE / SEALED MAIL",Vector2(400,476)]]:
        _prop(item[0]+"Waymark",MARK,item[2],0.6)
        _solid(item[0]+"WaymarkFeet",Rect2(item[2]+Vector2(-4,-6),Vector2(8,6)))
        _label(item[0]+"Caption",item[1],item[2]+Vector2(-58,-30))
    _prop("RelayBoard",MARK,Vector2(208,476),0.7)
    _solid("BoardFeet",Rect2(204,470,8,6))
    _status = _label("BoardStatus","SORTING RUN",Vector2(176,440))
    _prop("PracticeKeeper",KEEPER,Vector2(176,332),0.5)
    _solid("KeeperFeet",Rect2(172,325,8,7))
    _label("PracticeCaption","PARTNER PRACTICE",Vector2(160,298))
    _label("ReturnCaption","< BRANCH / BRIDGE",Vector2(32,440))
    _label("LoopCaption","QUIET RETURN PATH",Vector2(564,588))
    for at in [Vector2(528,352),Vector2(528,400)]:
        _prop("CuttingsBed",BED,at)
        for row in [-12,-28]:
            var plants := _prop("LivingCuttings",CUTTINGS,at+Vector2(0,row))
            plants.z_index = 1
        _solid("BedFeet",Rect2(at-Vector2(26,42),Vector2(52,42)))
    var tree_points: Array[Vector2] = []
    for x in range(48,750,72):
        tree_points.append(Vector2(x,56))
        tree_points.append(Vector2(x,624))
    for y in [168,280,392]:
        tree_points.append(Vector2(56,y))
        tree_points.append(Vector2(112,y+32))
    for y in [168,280,392,504]: tree_points.append(Vector2(720,y))
    for i in tree_points.size():
        var tree := _prop("Cottonwood%02d"%i,TREES[i%TREES.size()],tree_points[i])
        _solid("Trunk",Rect2(-5,-6,10,7),tree)
        var canopy := ShaderMaterial.new()
        canopy.shader = CANOPY
        canopy.set_shader_parameter("canopy_opacity",1.0)
        tree.material = canopy
        _trees.append(tree)
    for at in [Vector2(320,224),Vector2(480,224),Vector2(304,352),Vector2(672,336),Vector2(288,592),Vector2(480,592)]: _prop("Planting",SHRUB,at,0.7)
    for at in [Vector2(336,560),Vector2(416,544),Vector2(656,448),Vector2(128,552)]: _prop("Meadow",TUFT,at)
    for bounds in [Rect2(0,-16,768,16),Rect2(0,640,768,16),Rect2(768,0,16,640),Rect2(-16,0,16,448),Rect2(-16,528,16,112)]: _solid("Boundary",bounds)
    var camera: Camera2D = $Player/Camera2D
    camera.limit_left = 0
    camera.limit_right = 768
    camera.limit_top = 0
    camera.limit_bottom = 640
    camera.offset = Vector2.ZERO
    camera.position = Vector2(0,-24)
    camera.reset_smoothing()
    queue_redraw()

func _draw() -> void:
    if _paving_tile == null: return
    for path in PATHS:
        for x in range(int(path.position.x),int(path.end.x),32):
            for y in range(int(path.position.y),int(path.end.y),32):
                draw_texture_rect(_paving_tile,Rect2(Vector2(x,y),Vector2(minf(32,path.end.x-x),minf(32,path.end.y-y))),false)

func _prop(label: String, texture: Texture2D, at: Vector2, ratio: float = 1.0) -> Sprite2D:
    var sprite := Sprite2D.new()
    sprite.name = label
    sprite.texture = texture
    sprite.position = at
    sprite.scale = Vector2.ONE*ratio
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.offset.y = floorf(texture.get_height()*0.5)-texture.get_image().get_used_rect().end.y
    $RouteDecor.add_child(sprite)
    return sprite

func _solid(label: String, bounds: Rect2, parent: Node = null) -> void:
    var body := StaticBody2D.new()
    body.name = label
    body.position = bounds.get_center()
    var shape := CollisionShape2D.new()
    var rectangle := RectangleShape2D.new()
    rectangle.size = bounds.size
    shape.shape = rectangle
    body.add_child(shape)
    (self if parent == null else parent).add_child(body)

func _label(label: String, text: String, at: Vector2) -> Label:
    var caption := Label.new()
    caption.name = label
    caption.text = text
    caption.position = at
    caption.z_index = 8
    caption.add_theme_font_override("font",FONT)
    caption.add_theme_font_size_override("font_size",8)
    caption.add_theme_color_override("font_color",Color("#e5ddba"))
    caption.add_theme_color_override("font_outline_color",Color("#293831"))
    caption.add_theme_constant_override("outline_size",1)
    add_child(caption)
    return caption

func _process(delta: float) -> void:
    for tree in _trees:
        var head := tree.to_local($Player.global_position+Vector2(0,-16))
        var covered: bool = $Player.global_position.y < tree.global_position.y-2 and tree.get_rect().has_point(head)
        var current: float = tree.material.get_shader_parameter("canopy_opacity")
        tree.material.set_shader_parameter("canopy_opacity",move_toward(current,0.35 if covered else 1.0,delta*3))

func nearest_site() -> String:
    var site := ""
    var distance := 30.0
    for id in SITES:
        var gap: float = $Player.position.distance_to(SITES[id])
        if gap < distance:
            site = id
            distance = gap
    return site

func interaction_hint() -> String:
    var site := nearest_site()
    if site == "practice": return "E  Partner practice"
    if site == "board": return "E  Relay board"
    if site != "": return "E  Inspect " + site.replace("_"," ")
    return "WASD / arrows  Move    West lane: riverfront"

func objective_text() -> String:
    if sorted: return "Relay handoff complete. Try partner practice or return to the branch."
    if started: return "Compare the loading bays, then route the cuttings at the relay board."
    return "Explore the relay yard. The courier board has a sorting run."

func interact(controller: Node2D) -> void:
    var site := nearest_site()
    if site == "board":
        started = true
        if sorted:
            controller.call("_show_message","RELAY BOARD\nThe cuttings are checked into the garden bay. The handoff stays recorded while you explore the city. Partner practice is optional, by the west side of the court.")
        elif bay_checks.size() < 3:
            controller.call("_show_message","RELAY BOARD\nA bundle of living cuttings has arrived wrapped in damp cloth. Compare the three loading-bay notices before choosing where it goes. Look for its handling needs, not just the nearest doorway.")
        else:
            _choose_bay(controller)
        _status.text = "HANDOFF CHECKED" if sorted else "COMPARE THREE BAYS"
    elif site in ["works","garden","bridge"]:
        bay_checks[site] = true
        var text: String = {"works":"WORKS BAY\nDry tools and repair fittings. Keep cloth and iron dry; this covered bay is for workshop stock.","garden":"GARDEN BAY\nLiving cuttings and planting supplies. Damp bundles stay in the shade beside the planted beds, then leave with the garden runner.","bridge":"BRIDGE BAY\nSealed letters and crossing reports. The branch checks their address before the westbound runner leaves."}[site]
        controller.call("_show_message",text)
    elif site == "practice":
        controller.call("_show_message","PARTNER PRACTICE\nChoose a practice matchup with the yard keeper. Practice uses the arena's current kits and leaves your delivery and owned party untouched. Escape leaves the fight; Escape again returns to this yard.")
        _choices(controller,["Choose practice matchup","Keep exploring"],[_start_practice, _close_choices])
    elif site == "return_path":
        controller.call("_show_message","RETURN PATH\nThe quieter planted lane circles behind the loading court and returns to the branch entrance. It gives runners room to pass without cutting through the planted beds.")

func _choose_bay(controller: Node2D) -> void:
    controller.call("_show_message","RELAY BOARD\nWhere should the damp bundle of living cuttings go?")
    _choices(controller,["Works: dry tools","Gardens: living cuttings","Bridge: sealed mail"],[_submit.bind("works"),_submit.bind("garden"),_submit.bind("bridge")])

func _choices(controller: Node2D, texts: Array, callbacks: Array) -> void:
    var choices: VBoxContainer = controller.get("_choices")
    for child in choices.get_children():
        choices.remove_child(child)
        child.queue_free()
    choices.show()
    for i in texts.size():
        var button := Button.new()
        button.text = texts[i]
        controller.call("_style_route_button",button)
        button.pressed.connect(callbacks[i])
        choices.add_child(button)
        if i == 0: button.grab_focus()

func _submit(bay: String) -> void:
    sorted = bay == "garden" and bay_checks.size() == 3
    _status.text = "HANDOFF CHECKED" if sorted else "TRY ANOTHER BAY"
    _route.call("_show_message","RELAY HANDOFF\nThe damp bundle is checked into the shaded garden bay. The runners can keep their dry stock and sealed letters separate." if sorted else "RELAY HANDOFF\nThe bundle is still waiting here. Living cuttings need the shaded, damp bay beside the planted beds. You can check the notices and try again.")

func _close_choices() -> void:
    _route.get("_choices").hide()
    _route.get("_panel").hide()
    $Player.set_physics_process(true)

func _start_practice() -> void:
    _close_choices()
    get_parent().call("open_relay_practice")

func _open_journey() -> void:
    var journey: Node2D = load("res://scenes/world_journey.tscn").instantiate()
    journey.initial_area = "relay_yard"
    journey.courier_model = $Player.chibi_model
    get_tree().change_scene_to_node(journey)
