extends Node2D
@export_enum("hometown", "riverfront") var area_id := "hometown"
const HOME_SITES = {
    "home": Vector2(224,280), "hall": Vector2(768,442),
    "garden": Vector2(448,608), "directions": Vector2(944,512),
}
const CITY_SITES = {
    "city_clerk": Vector2(512,400), "city_directions": Vector2(816,512),
}
func _ready() -> void:
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
    var sites: Dictionary = HOME_SITES if area_id == "hometown" else CITY_SITES
    for site in sites:
        var gap: float = $Player.position.distance_to(sites[site])
        if gap < distance:
            distance = gap
            closest = site
    return closest

func interaction_hint() -> String:
    match nearest_site():
        "home": return "E  Check home courtyard"
        "hall": return "Walk up through courier hall doorway"
        "garden": return "E  Read shared garden notice"
        "directions": return "E  Read Route 1 directions"
        "city_clerk": return "E  Speak to city courier"
        "city_directions": return "E  Read city directions"
    return "WASD / arrows  Move    E  Interact"

func interact(controller: Node2D) -> void:
    match nearest_site():
        "home": controller.call("_visit_home_courtyard")
        "hall": controller.call("_show_message", "COURIER HALL\nThe dispatcher is inside. Walk up through the front doorway to collect or report your route.")
        "garden": controller.call("_visit_shared_garden")
        "directions": controller.call("_visit_home_directions")
        "city_clerk": controller.call("_visit_city_clerk")
        "city_directions": controller.call("_visit_city_directions")
