extends "res://scripts/ui/game_pause_menu.gd"
## The existing pause Options/Rebind pages hosted by the title, without pausing a game or exposing game pages.
signal closed
signal page_changed
signal preferences_changed

func _ready() -> void:
	super._ready()
	hint.hide()
	hint.disabled = true
	content.name = "Choices"

func show_page(next: String) -> void:
	if next == "main":
		resume()
		return
	if next not in ["options", "rebind"]:
		return
	super.show_page(next)
	page_changed.emit()

func _save(section: String, key: String, value: Variant) -> void:
	if UI.is_title_pref(section, key):
		get_parent()._save_title_option(section, key, value)
	else:
		super._save(section, key, value)
	preferences_changed.emit()

func resume() -> void:
	overlay.hide()
	closed.emit()

func open() -> void:
	# Only the title's Options button opens this host; P/Esc never opens a game pause menu on the title.
	pass

func _input(event: InputEvent) -> void:
	if overlay.visible or UI.pressed(event, "fullscreen"):
		super._input(event)
