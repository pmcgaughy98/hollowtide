extends CanvasLayer
## A diagram of the seven real connected areas. Discovery and pins are run-local.
const PLACES := {
    "courtyard_home":["Courtyard home",Vector2(100,352),"Your starting doorstep and a quiet place to return to."],
    "hometown":["Hometown",Vector2(100,222),"Courtyard streets, the shared garden and the courier hall."],
    "courier_hall":["Courier hall",Vector2(268,106),"Meet the dispatcher. Collect a route or report what you found."],
    "route1":["Levee road",Vector2(308,272),"Follow the river road. The old landing branches south; the bridge lies east."],
    "riverfront":["Riverfront",Vector2(522,272),"The city courier branch connects the bridge, historic street and relay yard."],
    "historic_street":["Historic street",Vector2(560,100),"A repair workshop and public ledger, with a handoff back at the riverfront."],
    "relay_yard":["Relay yard",Vector2(654,408),"Read the loading-bay clues, sort a delivery or try partner practice."],
}
const LINKS := [["courtyard_home","hometown"],["hometown","courier_hall"],["hometown","route1"],["route1","riverfront"],["riverfront","historic_street"],["riverfront","relay_yard"]]
const DIRECTIONS := {
    "hometown/courier_hall":"Follow the main street east. Enter the hall's front door.",
    "hometown/courtyard_home":"Take the northwest lane back to your courtyard doorway.",
    "hometown/route1":"Follow the main street east past the ROUTE 1 sign.",
    "courtyard_home/hometown":"Leave through the south doorway.",
    "courier_hall/hometown":"Leave through the south doorway.",
    "route1/hometown":"Follow the levee road west into the hometown.",
    "route1/riverfront":"Follow the levee road east and cross the river bridge.",
    "riverfront/route1":"Cross the bridge on the west side of the riverfront.",
    "riverfront/historic_street":"Follow the north street beside the OLD CITY sign.",
    "riverfront/relay_yard":"Follow the riverfront's east street into the relay yard.",
    "historic_street/riverfront":"Follow the main street south to the riverfront.",
    "relay_yard/riverfront":"Take the west exit back to the courier branch.",
}
var journey: Node2D
var opened := false
var selected := "hometown"
var pinned := ""
var _overlay: Control
var _map: Control
var _buttons: Dictionary = {}
var _detail: Label
var _progress: Label
var _pin_button: Button
var _hud_button: Button
var _resume_physics := false
var _last_area := ""
const INK := Color("#192d30")
const PAPER := Color("#ebdfb7")
const GOLD := Color("#dcb769")

func _ready() -> void:
    name = "WorldAtlas"
    layer = 25
    # Keep the map affordance hidden while the existing battle pauses the world.
    process_mode = Node.PROCESS_MODE_ALWAYS
    journey = get_parent()
    _hud_button = _button("M  Route map",Vector2(18,16),Vector2(240,36),_toggle)
    add_child(_hud_button)
    _overlay = Control.new()
    _overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(_overlay)
    var shade := ColorRect.new()
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.color = Color(0.025,0.05,0.06,0.94)
    _overlay.add_child(shade)
    _label(_overlay,"THE RIVER ROAD",Vector2(40,24),Vector2(830,48),34,GOLD)
    _progress = _label(_overlay,"",Vector2(42,74),Vector2(840,28),18,PAPER)
    _overlay.add_child(_button("Close  /  M · Esc",Vector2(904,36),Vector2(208,42),close_map))
    _map = Control.new()
    _map.position = Vector2(28,114)
    _map.size = Vector2(756,478)
    _map.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _map.draw.connect(_draw_map)
    _overlay.add_child(_map)
    for id in PLACES:
        var node := _button("",PLACES[id][1]-Vector2(73,28),Vector2(146,56),_select.bind(id))
        node.name = id
        _map.add_child(node)
        _buttons[id] = node
    _detail = _label(_overlay,"",Vector2(812,150),Vector2(298,290),23,PAPER)
    _detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _pin_button = _button("Pin destination",Vector2(812,470),Vector2(298,44),_pin)
    _overlay.add_child(_pin_button)
    _overlay.add_child(_button("Clear pin",Vector2(812,524),Vector2(298,38),_clear_pin))
    _label(_overlay,"Arrows / Tab to browse · Enter to select · Walk the roads to discover more",Vector2(42,604),Vector2(1070,28),18,Color("#a6bdb4"))
    _overlay.hide()

func _label(parent: Node, copy: String, at: Vector2, dimensions: Vector2, pixels: int, color: Color) -> Label:
    var label := Label.new()
    label.text = copy
    label.position = at
    label.size = dimensions
    label.add_theme_font_override("font",preload("res://assets/fonts/AlegreyaSansSC-Bold.ttf"))
    label.add_theme_font_size_override("font_size",pixels)
    label.add_theme_color_override("font_color",color)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(label)
    return label

func _button(copy: String, at: Vector2, dimensions: Vector2, action: Callable) -> Button:
    var button := Button.new()
    button.text = copy
    button.position = at
    button.size = dimensions
    button.add_theme_font_override("font",preload("res://assets/fonts/AlegreyaSansSC-Bold.ttf"))
    button.add_theme_font_size_override("font_size",20)
    for state in ["normal","hover","pressed","focus","disabled"]:
        var style := StyleBoxFlat.new()
        style.bg_color = INK if state != "hover" else Color("#31534d")
        if state == "focus": style.bg_color = Color.TRANSPARENT
        style.border_color = GOLD if state in ["focus","hover"] else Color("#61786d")
        style.set_border_width_all(2 if state == "focus" else 1)
        style.set_corner_radius_all(3)
        button.add_theme_stylebox_override(state,style)
    button.add_theme_color_override("font_color",PAPER)
    button.pressed.connect(action)
    return button

func known(id: String) -> bool:
    if journey.visited_areas.has(id): return true
    for link in LINKS:
        if id in link and (journey.visited_areas.has(link[0]) or journey.visited_areas.has(link[1])): return true
    return false

func first_hop(destination: String) -> String:
    var queue: Array = [[journey.active_id,""]]
    var seen := {journey.active_id:true}
    while not queue.is_empty():
        var step: Array = queue.pop_front()
        if step[0] == destination: return step[1]
        for link in LINKS:
            if step[0] not in link: continue
            var next: String = link[1] if step[0] == link[0] else link[0]
            if seen.has(next): continue
            seen[next] = true
            queue.append([next,next if step[1] == "" else step[1]])
    return ""

func guidance(id: String) -> String:
    if id == journey.active_id: return "You are here. Explore on foot."
    return DIRECTIONS.get(journey.active_id+"/"+first_hop(id),"Follow the marked connections.")

func _available() -> bool:
    if get_tree().paused or journey.transitioning or journey.active_area == null or journey.has_node("RelayPractice"): return false
    if journey.route.get_node("BattleScreen").visible: return false
    for property in ["_panel","_notes_panel","_party_panel"]:
        if journey.route.get(property).visible: return false
    return true

func _toggle() -> void:
    if opened: close_map(); return
    if not _available(): return
    opened = true
    var player: CharacterBody2D = journey.active_area.get_node("Player")
    _resume_physics = player.is_physics_processing()
    player.velocity = Vector2.ZERO
    player.set_physics_process(false)
    journey.get_node("RouteHUD").hide()
    _overlay.show()
    _select(journey.active_id)
    _buttons[selected].grab_focus()

func close_map() -> void:
    if not opened: return
    opened = false
    _overlay.hide()
    get_viewport().gui_release_focus()
    journey.get_node("RouteHUD").show()
    journey.active_area.get_node("Player").set_physics_process(_resume_physics)

func _select(id: String) -> void:
    selected = id
    for key in PLACES:
        var discovered: bool = journey.visited_areas.has(key)
        _buttons[key].disabled = not known(key)
        _buttons[key].text = (PLACES[key][0] if known(key) else "Uncharted")+ ("\nYOU ARE HERE" if key == journey.active_id else ("\nVisited" if discovered else ""))
        _buttons[key].modulate = Color.WHITE if known(key) else Color(0.55,0.65,0.61)
    _progress.text = "%d / %d places visited   ·   Nearby roads appear as you explore" % [journey.visited_areas.size(),PLACES.size()]
    _detail.text = PLACES[id][0].to_upper()+"\n"+("Visited" if journey.visited_areas.has(id) else "Nearby / not yet visited")+"\n\n"+PLACES[id][2]+"\n\n"+guidance(id)
    _pin_button.text = "Pinned" if pinned == selected else "Pin destination"
    _map.queue_redraw()

func _pin() -> void:
    pinned = selected
    _select(selected)

func _clear_pin() -> void:
    pinned = ""
    _select(selected)

func _draw_map() -> void:
    _map.draw_style_box(_buttons["hometown"].get_theme_stylebox("normal"),Rect2(Vector2.ZERO,_map.size))
    var river := PackedVector2Array([Vector2(433,0),Vector2(418,108),Vector2(442,198),Vector2(430,294),Vector2(454,392),Vector2(436,478)])
    _map.draw_polyline(river,Color("#28555e"),34,true)
    _map.draw_polyline(river,Color("#50818a"),2,true)
    for link in LINKS:
        var a: Vector2 = PLACES[link[0]][1]
        var b: Vector2 = PLACES[link[1]][1]
        var visible_road: bool = journey.visited_areas.has(link[0]) or journey.visited_areas.has(link[1])
        _map.draw_line(a,b,GOLD if visible_road else Color("#354645"),3,true)
    _map.draw_arc(PLACES[selected][1],86,0,TAU,64,Color("#dcb769"),1,true)

func _input(event: InputEvent) -> void:
    var toggle: bool = event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_M
    if toggle:
        _toggle()
        get_viewport().set_input_as_handled()
    elif opened and event.is_action_pressed("ui_cancel"):
        close_map()
        get_viewport().set_input_as_handled()
    elif opened and (event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and event.physical_keycode in [KEY_J,KEY_P])):
        get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
    _hud_button.visible = not opened and _available()
    _hud_button.text = "M  Route map" if pinned == "" else "M  Map / " + PLACES[pinned][0]
    if _last_area != journey.active_id:
        _last_area = journey.active_id
        if opened: _select(journey.active_id)
