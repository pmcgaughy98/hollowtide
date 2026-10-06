extends Node2D
## A cached domestic room. Existing route progress is read here, never reassigned.
const ROOM = preload("res://assets/sprites/world/courtyard_home_linework_2026_10_04/home_room.png")
const STOVE_FRONT = preload("res://assets/sprites/world/courtyard_home_linework_2026_10_04/home_stove_front.png")
const COAT_FRONT = preload("res://assets/sprites/world/courtyard_home_linework_2026_10_04/home_coat_front.png")
const THRESHOLD_FRONT = preload("res://assets/sprites/world/courtyard_home_linework_2026_10_04/home_threshold_front.png")
const VISIBILITY = preload("res://assets/sprites/world/route1_landing_loop_2026_10_03/canopy_visibility.gdshader")
var _coat: Sprite2D
var _coat_material: ShaderMaterial
const SITES = {
    "table": Vector2(152,112), "bed": Vector2(106,106),
    "stove": Vector2(66,151), "coat": Vector2(174,186),
}

func _ready() -> void:
    if get_parent() == get_tree().root:
        call_deferred("_open_journey")
        return
    var room := Sprite2D.new()
    room.name = "RoomArt"
    room.texture = ROOM
    room.centered = false
    room.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    room.z_index = -10
    add_child(room)
    _foreground("RoomStoveFront", STOVE_FRONT, Vector2(33,177),110)
    _coat = _foreground("RoomCoatFront", COAT_FRONT, Vector2(182,176),114)
    _coat_material = ShaderMaterial.new()
    _coat_material.shader = VISIBILITY
    _coat_material.set_shader_parameter("canopy_opacity",1.0)
    _coat.material = _coat_material
    _foreground("RoomThresholdFront", THRESHOLD_FRONT, Vector2(24,233),209)
    for pair in [
        ["NorthWall",Rect2(26,25,205,52)],
        ["WestWall",Rect2(26,77,10,156)],
        ["EastWall",Rect2(221,77,10,156)],
        ["SouthWestWall",Rect2(26,211,80,22)],
        ["SouthEastWall",Rect2(154,211,77,22)],
        ["BedFootprint",Rect2(38,77,60,28)],
        ["BedsideFootprint",Rect2(38,104,13,10)],
        ["TableFootprint",Rect2(156,83,36,21)],
        ["StoolFootprint",Rect2(165,103,17,8)],
        ["StoveFootprint",Rect2(35,137,24,22)],
        ["WoodStackFootprint",Rect2(35,166,23,11)],
        ["CoatFootprint",Rect2(184,164,36,13)],
    ]:
        _solid(pair[0],pair[1])
    var camera: Camera2D = $Player/Camera2D
    camera.zoom = Vector2(2,2)
    camera.limit_left = -160
    camera.limit_right = 416
    camera.limit_top = -34
    camera.limit_bottom = 290
    camera.offset = Vector2.ZERO
    camera.position = Vector2(0,-24)
    camera.reset_smoothing()

func _foreground(label: String, texture: Texture2D, foot: Vector2, top: float) -> Sprite2D:
    var sprite := Sprite2D.new()
    sprite.name = label
    sprite.texture = texture
    sprite.centered = false
    sprite.position = foot
    sprite.offset = Vector2(0,top-foot.y)
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    $RouteDecor.add_child(sprite)
    return sprite

func _process(delta: float) -> void:
    if _coat == null:
        return
    # Preserve the cupboard base while revealing a courier behind its upper body.
    var player: Node2D = $Player
    var head := _coat.to_local(player.global_position+Vector2(0,-16))
    var covered := player.global_position.y < _coat.global_position.y-2 and _coat.get_rect().has_point(head)
    var opacity: float = _coat_material.get_shader_parameter("canopy_opacity")
    _coat_material.set_shader_parameter("canopy_opacity",move_toward(opacity,0.45 if covered else 1.0,delta*4))

func _solid(label: String, bounds: Rect2) -> void:
    var body := StaticBody2D.new()
    body.name = label
    body.position = bounds.get_center()
    var shape := CollisionShape2D.new()
    var rectangle := RectangleShape2D.new()
    rectangle.size = bounds.size
    shape.shape = rectangle
    body.add_child(shape)
    add_child(body)

func nearest_site() -> String:
    var closest := ""
    var distance := 24.0
    for site in SITES:
        var gap: float = $Player.position.distance_to(SITES[site])
        if gap < distance:
            distance = gap
            closest = site
    return closest

func interaction_hint() -> String:
    match nearest_site():
        "table": return "E  Inspect worktable"
        "bed": return "E  Inspect rest corner"
        "stove": return "E  Inspect home stove"
        "coat": return "E  Check travel hook"
    return "WASD / arrows  Move    Walk through south doorway to leave"

func interact(controller: Node2D) -> void:
    match nearest_site():
        "table":
            var status := "The worktable is clear, with room to lay out your next task."
            if controller.get("report_done"):
                status = "The worktable is clear. Your route report has been filed."
            elif controller.get("pouch_accepted"):
                status = "The worktable is clear. Your current route pouch stays with you."
            controller.call("_show_message","WORKTABLE\n"+status+"\n\n"+controller.get("_objective").text+"\n"+controller.get("_board").text)
        "bed":
            controller.call("_show_message","REST CORNER\nA teal quilt covers the bed. A small cabinet and woven mat keep this corner separate from the working floor.")
        "stove":
            controller.call("_show_message","HOME STOVE\nAn iron stove rests beside a stack of split wood. The clear center floor leaves room to pass between it and the worktable.")
        "coat":
            var detail := "A working coat and spare boots are kept beside the doorway."
            if controller.get("pouch_accepted"):
                detail += " Your carried route pouch stays with you."
            controller.call("_show_message","TRAVEL HOOK\n"+detail)

func _open_journey() -> void:
    var connected: Node2D = load("res://scenes/world_journey.tscn").instantiate()
    connected.initial_area = "courtyard_home"
    get_tree().root.add_child(connected)
    get_tree().current_scene = connected
    queue_free()
