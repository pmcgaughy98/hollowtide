extends CanvasLayer
## Town/Hollow overlay. Pauses the scene tree; never changes a turn, team or dungeon rule.
const FONT = preload("res://assets/fonts/AlegreyaSansSC-Bold.ttf")
const PREFS = "user://menu_preferences.cfg"
const TITLE = "res://scenes/creature_opening.tscn"
var overlay: Control
var hint: Button
var content: VBoxContainer
var page = "main"
var controls: Array[Control] = []
var releasing = false
var transition = false
var motion = false
var status: Label
var music_node: Node
var music_mode = Node.PROCESS_MODE_INHERIT

static func attach(scene: Node) -> void:
    if scene.has_node("GamePauseMenu"): return
    var menu = load("res://scripts/ui/game_pause_menu.gd").new()
    menu.name = "GamePauseMenu"
    scene.add_child(menu)

func _ready() -> void:
    layer = 80
    process_mode = Node.PROCESS_MODE_ALWAYS
    hint = _button("Menu  [P]")
    hint.name = "OpenMenu"
    hint.position = Vector2(988,598)
    hint.size = Vector2(150,36)
    hint.custom_minimum_size.y = 36
    hint.focus_mode = Control.FOCUS_NONE
    hint.pressed.connect(open)
    add_child(hint)
    overlay = Control.new()
    overlay.name = "PauseOverlay"
    overlay.size = Vector2(1152,648)
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(overlay)
    var shade = ColorRect.new()
    shade.size = overlay.size
    shade.color = Color(0.04,0.07,0.05,0.72)
    shade.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.add_child(shade)
    var panel = PanelContainer.new()
    panel.name = "PausePanel"
    panel.position = Vector2(316,58)
    panel.custom_minimum_size = Vector2(520,0)
    var box = StyleBoxFlat.new()
    box.bg_color = Color("#242b25")
    box.border_color = Color("#b69b6d")
    box.set_border_width_all(3)
    box.set_content_margin_all(22)
    panel.add_theme_stylebox_override("panel",box)
    overlay.add_child(panel)
    content = VBoxContainer.new()
    content.add_theme_constant_override("separation",10)
    panel.add_child(content)
    overlay.hide()

func _button(text: String) -> Button:
    var b = Button.new()
    b.text = text
    b.custom_minimum_size = Vector2(0,44)
    b.add_theme_font_override("font",FONT)
    b.add_theme_font_size_override("font_size",24)
    b.add_theme_color_override("font_color",Color("#fff4e8"))
    var box = StyleBoxFlat.new()
    box.bg_color = Color("#242b25")
    box.set_content_margin_all(8)
    b.add_theme_stylebox_override("normal",box)
    var focused = box.duplicate() as StyleBoxFlat
    focused.bg_color = Color("#3f5140")
    focused.border_color = Color("#e4ca8e")
    focused.set_border_width_all(2)
    for state in ["focus","hover","pressed"]: b.add_theme_stylebox_override(state,focused)
    return b

func _label(text: String, size: int = 22) -> Label:
    var l = Label.new()
    l.text = text
    l.add_theme_font_override("font",FONT)
    l.add_theme_font_size_override("font_size",size)
    l.add_theme_color_override("font_color",Color("#fff4e8"))
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    l.custom_minimum_size.x = 470
    content.add_child(l)
    return l

func _action(text: String, id: String, callback: Callable) -> Button:
    var b = _button(text)
    b.name = id
    b.pressed.connect(callback)
    content.add_child(b)
    controls.append(b)
    return b

func _config() -> ConfigFile:
    var c = ConfigFile.new()
    c.load(PREFS)
    return c

func _save(section: String, key: String, value: Variant) -> void:
    var c = _config()
    c.set_value(section,key,value)
    var err = c.save(PREFS)
    if status != null: status.text = "Changes are saved automatically." if err == OK else "Settings could not be saved."

func _volume(bus: String, key: String) -> void:
    var c = _config()
    var value = clampf(float(c.get_value("audio",key,100.0)),0,100)
    var caption = _label("%s volume   %d%%" % [bus,int(value)])
    var slider = HSlider.new()
    slider.name = bus + "Volume"
    slider.max_value = 100
    slider.step = 5
    slider.value = value
    slider.custom_minimum_size = Vector2(0,36)
    slider.focus_mode = Control.FOCUS_ALL
    var ring = Panel.new()
    ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var outline = StyleBoxFlat.new()
    outline.bg_color = Color.TRANSPARENT
    outline.border_color = Color("#e4ca8e")
    outline.set_border_width_all(2)
    ring.add_theme_stylebox_override("panel",outline)
    ring.hide()
    slider.add_child(ring)
    slider.focus_entered.connect(ring.show)
    slider.focus_exited.connect(ring.hide)
    content.add_child(slider)
    controls.append(slider)
    slider.value_changed.connect(func(v: float) -> void:
        caption.text = "%s volume   %d%%" % [bus,int(v)]
        var index = AudioServer.get_bus_index(bus)
        if index >= 0:
            AudioServer.set_bus_mute(index,v <= 0)
            AudioServer.set_bus_volume_db(index,linear_to_db(maxf(v/100,0.001)))
        _save("audio",key,v)
    )

func open() -> void:
    if overlay.visible or transition or get_tree().paused: return
    music_node = get_tree().root.get_node_or_null("HollowtideMusic")
    if is_instance_valid(music_node):
        music_mode = music_node.process_mode
        music_node.process_mode = Node.PROCESS_MODE_ALWAYS
    get_tree().paused = true
    overlay.show()
    hint.hide()
    show_page("main")

func show_page(next: String) -> void:
    page = next
    controls.clear()
    status = null
    for n in content.get_children():
        content.remove_child(n)
        n.queue_free()
    _label("PAUSED",32)
    match page:
        "main":
            _action("Resume","Resume",resume)
            _action("Options","Options",show_page.bind("options"))
            _action("Controls","Controls",show_page.bind("controls"))
            _action("Return to title","ReturnTitle",show_page.bind("title"))
            _action("Quit Game","Quit",show_page.bind("quit"))
        "options":
            _volume("Master","master")
            _volume("Music","music")
            motion = bool(_config().get_value("menu","reduce_motion",false))
            _action("Reduce menu motion: " + ("On" if motion else "Off"),"ReduceMotion",toggle_motion)
            _action("Back","Back",show_page.bind("main"))
            status = _label("Changes are saved automatically.",18)
        "controls":
            _label("Town: WASD / arrows move. E / J / Enter uses a place.")
            _label("Hollow exploration: WASD / arrows move; Shift turns. J / click attacks; 1-3 use moves. I bag; Z rest; E stairs; T team orders; Tab autopilot.",20)
            _label("Real-time fights: WASD / arrows move; J / click attacks; Space dodges; 1-3 use moves; Q / E cycles targets. Y / N answers a recruit after a fight.",20)
            _label("P / controller Start pauses anywhere. Esc pauses when no dialogue or bag is open. Arrows / D-pad navigate menus; Enter / A chooses; Esc / B goes back.",20)
            _action("Back","Back",show_page.bind("main"))
        "title", "quit":
            _label("Return to the title?" if page == "title" else "Quit Hollowtide?",26)
            _label("Progress is not saved to disk yet. Leaving ends this session. Resume keeps your current team and floor.")
            _action("Keep exploring","CancelLeave",show_page.bind("main"))
            _action("Return to title" if page == "title" else "Quit Game","ConfirmLeave",leave)
    for i in controls.size():
        var b = controls[i]
        b.focus_neighbor_top = controls[posmod(i-1,controls.size())].get_path()
        b.focus_neighbor_bottom = controls[(i+1)%controls.size()].get_path()
        b.focus_previous = b.focus_neighbor_top
        b.focus_next = b.focus_neighbor_bottom
        b.focus_neighbor_left = b.get_path()
        b.focus_neighbor_right = b.get_path()
    if not controls.is_empty(): controls[0].grab_focus.call_deferred()

func toggle_motion() -> void:
    motion = not motion
    _save("menu","reduce_motion",motion)
    var b = content.get_node("ReduceMotion") as Button
    b.text = "Reduce menu motion: " + ("On" if motion else "Off")

func _restore_music() -> void:
    if is_instance_valid(music_node): music_node.process_mode = music_mode

func resume() -> void:
    if releasing or transition: return
    releasing = true
    # Raw key polling in the game must not see the closing Enter/Escape as a turn.
    while Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_cancel") or Input.is_physical_key_pressed(KEY_P) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        await get_tree().process_frame
    overlay.hide()
    hint.show()
    _restore_music()
    get_tree().paused = false
    releasing = false

func leave() -> void:
    if transition: return
    transition = true
    if page == "quit":
        get_tree().quit()
        return
    _restore_music()
    get_tree().paused = false
    var err = get_tree().change_scene_to_file(TITLE)
    if err != OK:
        transition = false
        get_tree().paused = true
        if is_instance_valid(music_node): music_node.process_mode = Node.PROCESS_MODE_ALWAYS
        show_page("main")
        _label("The title could not open. You can still resume.")

func _has_modal() -> bool:
    var scene = get_parent()
    if "panel" in scene and not scene.panel.is_empty(): return true
    if "asking" in scene and scene.asking >= 0: return true
    if "talk" in scene and not scene.talk.is_empty(): return true
    if "teach_kind" in scene and scene.teach_kind != "": return true
    return "bag_open" in scene and scene.bag_open

func _input(event: InputEvent) -> void:
    if transition or releasing: return
    var p = event is InputEventKey and event.pressed and not event.echo and (event.physical_keycode == KEY_P or event.keycode == KEY_P)
    p = p or (event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START)
    var cancel = event.is_action_pressed("ui_cancel") and not event.is_echo()
    if not p and not cancel: return
    if overlay.visible:
        if page == "main": resume()
        else: show_page("main")
    elif p or not _has_modal(): open()
    else: return
    get_viewport().set_input_as_handled()

func _exit_tree() -> void:
    _restore_music()
    if overlay != null and overlay.visible and get_tree() != null: get_tree().paused = false
