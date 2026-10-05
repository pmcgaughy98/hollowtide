extends Node2D
## This room calls the existing dispatcher; assignment and party stay in WorldJourney.
const ROOM = preload("res://assets/sprites/world/courier_hall_2026_10_03/courier_hall_native.png")
const COUNTER = preload("res://assets/sprites/world/courier_hall_2026_10_03/counter_foreground.png")
const DISPATCHER = preload("res://assets/sprites/world/route1_rd_2026_10_01/dispatcher.png")
const SITES = {"dispatch":Vector2(132,142), "board":Vector2(72,86), "sorting":Vector2(180,171)}
func _ready() -> void:
    var room:=Sprite2D.new()
    room.name="RoomArt";room.texture=ROOM;room.centered=false
    room.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;room.z_index=-10
    add_child(room)
    var clerk:=Sprite2D.new()
    clerk.name="Dispatcher";clerk.texture=DISPATCHER
    clerk.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    clerk.scale=Vector2.ONE*(30.0/46.0)
    clerk.position=Vector2(132,96)
    var used:=DISPATCHER.get_image().get_used_rect()
    clerk.offset.y=floorf(DISPATCHER.get_height()*0.5)-used.end.y
    $RouteDecor.add_child(clerk)
    var front:=Sprite2D.new()
    front.name="CounterFront";front.texture=COUNTER;front.centered=false
    front.position=Vector2(103,130);front.offset=Vector2(0,-40)
    front.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    $RouteDecor.add_child(front)
    for pair in [
        ["NorthWall",Rect2(20,20,215,53)],
        ["WestWall",Rect2(20,73,9,163)],
        ["EastWall",Rect2(229,73,7,163)],
        ["DispatchDesk",Rect2(103,56,126,74)],
        ["WestSorting",Rect2(28,74,20,125)],
        ["EastSorting",Rect2(195,132,30,65)],
        ["SouthWestWall",Rect2(20,200,89,35)],
        ["SouthEastWall",Rect2(143,200,92,35)]]:
        _solid(pair[0],pair[1])
    var camera:Camera2D=$Player/Camera2D
    camera.zoom=Vector2(2,2)
    # Frame the complete small room without changing the courier or prop scale.
    camera.limit_left=-160;camera.limit_right=416
    camera.limit_top=-34;camera.limit_bottom=290
    camera.offset=Vector2.ZERO;camera.position=Vector2(0,-24)
    camera.reset_smoothing()
func _solid(label:String, bounds:Rect2) -> void:
    var body:=StaticBody2D.new();body.name=label
    body.position=bounds.get_center()
    var shape:=CollisionShape2D.new()
    var rectangle:=RectangleShape2D.new();rectangle.size=bounds.size
    shape.shape=rectangle;body.add_child(shape);add_child(body)
func nearest_site() -> String:
    var closest:=""
    var distance:=24.0
    for site in SITES:
        var gap:float=$Player.position.distance_to(SITES[site])
        if gap<distance:distance=gap;closest=site
    return closest
func interaction_hint() -> String:
    match nearest_site():
        "dispatch":return "E  Speak to dispatcher"
        "board":return "E  Read courier board"
        "sorting":return "E  Inspect sorting shelves"
    return "WASD / arrows  Move    Walk through south doorway to leave"
func interact(controller:Node2D) -> void:
    match nearest_site():
        "dispatch":controller.call("_visit_dispatch")
        "board":
            controller.call("_show_message","COURIER BOARD\n"+controller.get("_objective").text+"\n"+controller.get("_board").text)
        "sorting":
            controller.call("_show_message","SORTING SHELVES\nTied canvas bags are arranged beside the counter. Your sealed route pouch stays closed; the dispatcher handles the assignment.")
