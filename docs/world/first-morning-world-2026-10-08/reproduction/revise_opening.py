from pathlib import Path
import hashlib,json
root=Path(__file__).parent
live=Path('C:/Users/pmcga/dev/hollowtide')
name='scripts/opening_flow.gd'
data=(live/name).read_bytes()
(root/'originals'/name).write_bytes(data)
baseline=json.loads((root/'baseline.json').read_text());baseline[name]=hashlib.sha256(data).hexdigest()
(root/'baseline.json').write_text(json.dumps(baseline,indent=2))
source=data.decode()
constants=source[source.index('const STARTERS:'):source.index('var _starter_panel:')]
(root/'starter_constants.txt').write_text(constants)
boot=source[source.index('func _build_boot()'):source.index('func _build_starter_page()')]
result='''extends "res://scripts/main_menu_art_preview.gd"
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

'''+boot+'''
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
'''
(root/'project'/name).write_text(result)
print('Opening now enters the first morning without choosing a partner')
