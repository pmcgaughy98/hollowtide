extends Node2D
@export_enum("hometown", "riverfront") var area_id := "hometown"
const HOME_SITES = {
    "home": Vector2(224,280), "hall": Vector2(768,442),
    "garden": Vector2(448,608), "directions": Vector2(944,512),
    "route_map": Vector2(540,508),
}
const CITY_SITES = {
    "city_clerk": Vector2(512,400), "city_directions": Vector2(816,512),
}
var garden_activity: Node2D
var quay_activity: Node2D

func _ready() -> void:
    if area_id == "hometown":
        garden_activity = get_node("GardenActivity")
    else:
        quay_activity = get_node("Landscape/RiverfrontQuay")
    if get_parent() == get_tree().root:
        call_deferred("_open_journey")
        return
    var camera: Camera2D = $Player/Camera2D
    camera.limit_left = 0
    camera.limit_top = 0
    camera.limit_right = 1024
    camera.limit_bottom = 768
    camera.offset = Vector2.ZERO
    camera.position = Vector2(0,-24)
    camera.reset_smoothing()

func nearest_site() -> String:
    var closest := ""
    var distance := 30.0
    var sites: Dictionary = (HOME_SITES if area_id == "hometown" else CITY_SITES).duplicate()
    if quay_activity != null: sites.merge(quay_activity.SITES)
    for site in sites:
        var gap: float = $Player.position.distance_to(sites[site])
        if gap < distance:
            distance = gap
            closest = site
    if garden_activity != null:
        for site in garden_activity.SITES:
            var gap: float = $Player.position.distance_to(garden_activity.SITES[site])
            if gap < distance:
                distance = gap
                closest = site
    return closest

func interaction_hint() -> String:
    var site := nearest_site()
    if quay_activity != null and quay_activity.SITES.has(site): return quay_activity.hint(site)
    if garden_activity != null and site in ["garden", "garden_neighbor", "garden_row"]:
        return garden_activity.hint(site)
    match site:
        "home": return "Walk up through courtyard home doorway"
        "hall": return "Walk up through courier hall doorway"
        "garden": return "E  Read shared garden notice"
        "directions": return "E  Read Route 1 directions"
        "route_map": return "E  Open the river-road map"
        "city_clerk": return "E  Speak to city courier"
        "city_directions": return "E  Read city directions"
    return "WASD / arrows  Move    E  Interact"

func interact(controller: Node2D) -> void:
    var site := nearest_site()
    if quay_activity != null and quay_activity.SITES.has(site):
        quay_activity.interact(site,controller)
        return
    if garden_activity != null and site in ["garden", "garden_neighbor", "garden_row"]:
        garden_activity.interact(site, controller)
        return
    match site:
        "home": controller.call("_visit_home_courtyard")
        "hall": controller.call("_show_message", "COURIER HALL\nThe dispatcher is inside. Walk up through the front doorway to collect or report your route.")
        "garden": controller.call("_visit_shared_garden")
        "directions": controller.call("_visit_home_directions")
        "route_map": get_parent().atlas._toggle()
        "city_clerk": controller.call("_visit_city_clerk")
        "city_directions":
            controller.set("city_directions_read",true)
            controller.call("_show_message","CITY ROUTES\nNorth: the historic street, repaired shop and public ledger. East: the relay yard, with loading bays, a sorting run and optional partner practice. Return west over the bridge for Route 1 and the hometown.")

func _open_journey() -> void:
    var connected:Node2D=load("res://scenes/world_journey.tscn").instantiate()
    connected.initial_area=area_id
    get_tree().root.add_child(connected)
    get_tree().current_scene=connected
    queue_free()
