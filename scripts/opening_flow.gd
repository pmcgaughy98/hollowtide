extends "res://scripts/main_menu_art_preview.gd"
## The menu chooses appearance. The first partner is met inside the world.
var _boot: Control
var _boot_clock := 0.0
var _boot_done := false
var _boot_fading := false

func _ready() -> void:
    get_tree().root.content_scale_size = Vector2i(1152,648)
    super._ready()
    _fade.z_index = 100
    _begin_button.text = "Start your first morning"
    _build_boot()

func _build_boot() -> void:
    _boot = Control.new()
    _boot.name = "LaunchPrelude"
    _boot.size = Vector2(1152, 648)
    _boot.z_index = 90
    _ui.add_child(_boot)
    var ink := ColorRect.new()
    ink.size = _boot.size
    ink.color = Color("#18172c")
    ink.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _boot.add_child(ink)
    var logo := TextureRect.new()
    logo.name = "LaunchWordmark"
    logo.texture = _wordmark.texture
    logo.size = _wordmark.size
    logo.position = Vector2(246, 216)
    logo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _boot.add_child(logo)
    var caption := _label("EMBER   /   BLOOM   /   TIDE", 22)
    caption.position = Vector2(0, 392)
    caption.size = Vector2(1152, 36)
    caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    caption.modulate = Color("#bdadc7")
    _boot.add_child(caption)
    var hint := _label("Enter / A / click to continue", 18)
    hint.position = Vector2(0, 582)
    hint.size = Vector2(1152, 30)
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint.modulate = Color("#93869e")
    _boot.add_child(hint)
    _page = "boot"
    _main_panel.hide()
    _wordmark.hide()
    _focus_controls.clear()
    _cursor.hide()
    get_viewport().gui_release_focus()

func _finish_boot() -> void:
    if _boot_fading or _boot_done:
        return
    _boot_fading = true
    # Start the approved walk-in as the menu is revealed.
    _time = 0.0
    _wordmark.show()
    _show_page("main", _buttons[0])
    _page = "boot"
    _main_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    get_viewport().gui_release_focus()
    if not _reduce_motion:
        await create_tween().tween_property(_boot, "modulate:a", 0.0, 0.5).finished
    _boot.hide()
    _boot_done = true
    _main_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    _show_page("main", _buttons[0])

func _input(event: InputEvent) -> void:
    if _boot_done:
        return
    # Consume the skip, including during the reveal, so it cannot start New Game.
    if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel") or (event is InputEventMouseButton and event.pressed):
        _finish_boot()
        get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
    super._process(delta)
    if not _boot_done:
        _boot_clock += delta
        if _boot_clock >= (0.2 if _reduce_motion else 1.8): _finish_boot()
        _cursor.hide()

func _close_panel() -> void:
    if _boot_done and not _leaving: super._close_panel()

func _begin_journey() -> void:
    if _leaving or not _boot_done or _route_scene == null: return
    var destination := _route_scene.instantiate()
    if not destination.has_method("set_courier_model") or not destination.has_method("begin_first_morning"):
        destination.free()
        _set_route_error()
        return
    destination.set_courier_model(_selected_courier)
    destination.begin_first_morning(_reduce_motion)
    _save_preferences()
    _leaving = true
    _sound(CONFIRM_SOUND)
    _fade.mouse_filter = Control.MOUSE_FILTER_STOP
    _cursor.hide()
    for control in _focus_controls:
        control.mouse_filter = Control.MOUSE_FILTER_IGNORE
        control.focus_mode = Control.FOCUS_NONE
    var tween := create_tween().set_parallel()
    tween.tween_property(_fade,"color:a",1.0,0.25 if _reduce_motion else 0.7)
    tween.tween_property(_music,"volume_db",-80.0,0.25 if _reduce_motion else 0.85)
    await tween.finished
    var previous_party := PlayerParty.caught.duplicate()
    var previous_active := PlayerParty.active_slot
    PlayerParty.caught.clear()
    PlayerParty.active_slot = -1
    PlayerParty.party_changed.emit()
    var error := get_tree().change_scene_to_node(destination)
    if error != OK:
        PlayerParty.caught.assign(previous_party)
        PlayerParty.active_slot = previous_active
        PlayerParty.party_changed.emit()
        destination.free()
        _leaving = false
        _fade.color.a = 0.0
        _fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
        _music.volume_db = music_db
        for control in _focus_controls:
            control.mouse_filter = Control.MOUSE_FILTER_STOP
            control.focus_mode = Control.FOCUS_ALL
        _journey_status.text = "Could not open the hometown. Your previous party is still available."
        _journey_status.show()
        _show_page("journey",_begin_button)

