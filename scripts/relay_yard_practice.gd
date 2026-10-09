extends "res://scripts/move_preview.gd"
## Use the existing picker and arena without changing either one's combat rules.
signal return_to_yard

# The picker rebuilt on 2026-10-09 lays its grid out to fit every line itself, so the
# column-fitting override that used to live here (it called a _grid() the picker no longer has) is gone.

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        var code: int = event.physical_keycode if event.physical_keycode else event.keycode
        if code == KEY_ESCAPE and _arena == null:
            return_to_yard.emit()
            get_viewport().set_input_as_handled()
            return
    super._unhandled_input(event)
