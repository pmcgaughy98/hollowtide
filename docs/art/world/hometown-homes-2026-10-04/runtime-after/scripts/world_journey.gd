extends Node2D

## One visible area at a time. Cached scenes retain the existing live assignment.
## Disk saves, party rules and battle state stay with their existing owners.
const AREAS = {
    "hometown": preload("res://scenes/hometown.tscn"),
    "courier_hall": preload("res://scenes/courier_hall.tscn"),
    "courtyard_home": preload("res://scenes/courtyard_home.tscn"),
    "route1": preload("res://scenes/first_route_prototype.tscn"),
    "riverfront": preload("res://scenes/city_riverfront.tscn"),
    "historic_street": preload("res://scenes/historic_street.tscn"),
}
@export_enum("Male", "Female") var courier_model := "Male"
@export_enum("hometown", "route1", "riverfront", "courier_hall", "historic_street", "courtyard_home") var initial_area := "hometown"
var active_area: Node2D
var active_id := ""
var cached: Dictionary = {}
var route: Node2D
var transitioning := false
var transitions: Array[Dictionary] = []
var _fade: ColorRect

func set_courier_model(model: String) -> void:
    courier_model = model

func _ready() -> void:
    var layer := CanvasLayer.new()
    layer.layer = 100
    add_child(layer)
    _fade = ColorRect.new()
    _fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _fade.color = Color(0.08, 0.12, 0.12, 1)
    _fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(_fade)
    # Keep the original quest controller and its HUD, rather than copying flags.
    route = AREAS["route1"].instantiate()
    route.get_node("Player").chibi_model = courier_model
    add_child(route)
    route.get_node("RouteHUD").reparent(self)
    route.get_node("RouteMusic").reparent(self)
    route.process_mode = Node.PROCESS_MODE_DISABLED
    remove_child(route)
    cached["route1"] = route
    var arrival: Vector2 = {"courtyard_home":Vector2(128,208),"hometown":Vector2(224,280),"courier_hall":Vector2(128,208),"route1":Vector2(-720,512),"riverfront":Vector2(320,512),"historic_street":Vector2(384,848)}[initial_area]
    _activate(initial_area, arrival, Vector2.DOWN if initial_area == "hometown" else (Vector2.UP if initial_area == "courtyard_home" else Vector2.RIGHT))
    transitioning = true
    await create_tween().tween_property(_fade, "color:a", 0.0, 0.3).finished
    transitioning = false
    active_area.get_node("Player").set_physics_process(true)

func _activate(id: String, arrival: Vector2, facing: Vector2) -> void:
    var area: Node2D
    if cached.has(id):
        area = cached[id]
    else:
        area = AREAS[id].instantiate()
        area.get_node("Player").chibi_model = courier_model
        cached[id] = area
    active_area = area
    active_id = id
    area.process_mode = Node.PROCESS_MODE_INHERIT
    add_child(area)
    var courier: CharacterBody2D = area.get_node("Player")
    courier.position = arrival
    courier.velocity = Vector2.ZERO
    courier.set_physics_process(false)
    courier.call("_update_walk", facing, 0.0)
    var camera: Camera2D = courier.get_node("Camera2D")
    camera.make_current()
    camera.reset_smoothing()
    route.set("player", courier)
    if id == "historic_street":
        route.set("city_activity",area)
    for property in ["_panel", "_notes_panel", "_party_panel"]:
        route.get(property).hide()
    route.call("_refresh_objective")
    if not area.has_node("AreaEntrances"):
        _build_entrances(area, id)

func _build_entrances(area: Node2D, id: String) -> void:
    var entrances := Node2D.new()
    entrances.name = "AreaEntrances"
    area.add_child(entrances)
    match id:
        "hometown":
            _gate(entrances, "CourtyardHomeDoor", Vector2(233,242), Vector2(20,8), "courtyard_home", Vector2(128,208), Vector2.UP)
            _gate(entrances, "CourierHallDoor", Vector2(768,424), Vector2(20,8), "courier_hall", Vector2(128,208), Vector2.UP)
            _gate(entrances, "LeveeEntrance", Vector2(1016,512), Vector2(16,56), "route1", Vector2(-720,512), Vector2.RIGHT)
        "courtyard_home":
            _gate(entrances, "HomeExit", Vector2(128,232), Vector2(28,12), "hometown", Vector2(233,280), Vector2.DOWN)
        "courier_hall":
            _gate(entrances, "HallExit", Vector2(128,244), Vector2(22,12), "hometown", Vector2(768,452), Vector2.DOWN)
        "route1":
            _gate(entrances, "HometownEntrance", Vector2(-760,512), Vector2(16,56), "hometown", Vector2(980,512), Vector2.LEFT)
            _gate(entrances, "CityBridgeEntrance", Vector2(696,416), Vector2(16,32), "riverfront", Vector2(320,512), Vector2.RIGHT)
        "historic_street":
            _gate(entrances, "RiverfrontReturn", Vector2(384,888), Vector2(56,16), "riverfront", Vector2(880,48), Vector2.DOWN)
        "riverfront":
            _gate(entrances, "HistoricStreetEntrance", Vector2(880,8), Vector2(40,16), "historic_street", Vector2(384,848), Vector2.UP)
            _gate(entrances, "ReturnBridgeEntrance", Vector2(8,512), Vector2(16,32), "route1", Vector2(432,416), Vector2.LEFT)

func _gate(parent: Node, label: String, at: Vector2, size: Vector2, destination: String, arrival: Vector2, facing: Vector2) -> void:
    var entrance := Area2D.new()
    entrance.name = label
    entrance.position = at
    entrance.collision_layer = 0
    entrance.collision_mask = 1
    var shape := CollisionShape2D.new()
    var rectangle := RectangleShape2D.new()
    rectangle.size = size
    shape.shape = rectangle
    entrance.add_child(shape)
    parent.add_child(entrance)
    entrance.body_entered.connect(func(body: Node2D) -> void:
        if body == active_area.get_node("Player") and not transitioning:
            travel(destination, arrival, facing)
    )

func travel(destination: String, arrival: Vector2, facing: Vector2) -> void:
    if transitioning or not AREAS.has(destination):
        return
    transitioning = true
    active_area.get_node("Player").set_physics_process(false)
    call_deferred("_perform_travel", destination, arrival, facing)

func _perform_travel(destination: String, arrival: Vector2, facing: Vector2) -> void:
    # Entrance signals fire during physics. Disable collisions only after that callback.
    active_area.process_mode = Node.PROCESS_MODE_DISABLED
    _fade.mouse_filter = Control.MOUSE_FILTER_STOP
    await create_tween().tween_property(_fade, "color:a", 1.0, 0.22).finished
    var previous := active_id
    remove_child(active_area)
    _activate(destination, arrival, facing)
    transitions.append({"from":previous, "to":destination, "arrival":str(arrival)})
    await get_tree().physics_frame
    await create_tween().tween_property(_fade, "color:a", 0.0, 0.22).finished
    _fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    transitioning = false
    active_area.get_node("Player").set_physics_process(true)

func _process(_delta: float) -> void:
    if active_area == null or active_id == "route1":
        return
    route.get("_area_label").text = {"courtyard_home":"HOMETOWN / COURTYARD HOME", "hometown":"HOMETOWN / COURTYARD STREETS", "courier_hall":"HOMETOWN / COURIER HALL", "riverfront":"CITY / RIVERFRONT", "historic_street":"CITY / HISTORIC STREET"}[active_id]
    if active_id == "historic_street" or (active_id == "riverfront" and cached.has("historic_street") and cached["historic_street"].started and not cached["historic_street"].handoff_verified):
        route.get("_objective").text = cached["historic_street"].call("objective_text")
    var hint: Label = route.get("_hint")
    if transitioning or route.get("_panel").visible:
        hint.text = ""
    elif route.get("_notes_panel").visible:
        hint.text = "J / E  Close field notes"
    elif route.get("_party_panel").visible:
        hint.text = "P / E  Close party"
    else:
        hint.text = active_area.call("interaction_hint") + "    J  Notes    P  Party"

func _unhandled_input(event: InputEvent) -> void:
    if active_id == "route1" or transitioning or active_area == null:
        return
    if event is InputEventKey and event.pressed and not event.echo:
        var code: int = event.physical_keycode if event.physical_keycode else event.keycode
        if code == KEY_J and not route.get("_panel").visible and not route.get("_party_panel").visible:
            route.call("_toggle_notes")
            get_viewport().set_input_as_handled()
            return
        if code == KEY_P and not route.get("_panel").visible and not route.get("_notes_panel").visible:
            route.call("_toggle_party")
            get_viewport().set_input_as_handled()
            return
    if not event.is_action_pressed("interact") or event.is_echo():
        return
    if route.get("_notes_panel").visible:
        route.call("_toggle_notes")
    elif route.get("_party_panel").visible:
        route.call("_toggle_party")
    elif route.get("_panel").visible:
        if route.get("_choices").visible:
            return
        route.get("_panel").hide()
        active_area.get_node("Player").set_physics_process(true)
    else:
        var site: String = active_area.call("nearest_site")
        active_area.call("interact", route)
        if active_id == "riverfront" and site == "city_clerk" and cached.has("historic_street"):
            cached["historic_street"].call("offer_handoff_if_requested")
    get_viewport().set_input_as_handled()

func _exit_tree() -> void:
    for area in cached.values():
        if is_instance_valid(area) and not area.is_inside_tree():
            area.free()
