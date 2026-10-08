extends "res://scripts/move_preview.gd"
## Use the existing picker and arena without changing either one's combat rules.
signal return_to_yard

func _grid() -> void:
    super._grid()
    # Fit all current lines into this practice screen, including the seventh column.
    for child in _ui.get_children():
        if child is GridContainer:
            var width := floorf((get_viewport_rect().size.x-96.0-12.0*(child.columns-1))/child.columns)
            for button in child.get_children():
                button.custom_minimum_size.x = minf(150.0,width)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        var code: int = event.physical_keycode if event.physical_keycode else event.keycode
        if code == KEY_ESCAPE and _arena == null:
            return_to_yard.emit()
            get_viewport().set_input_as_handled()
            return
    super._unhandled_input(event)
