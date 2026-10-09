extends "res://scripts/main_menu_art_preview.gd"
## Presentation and a transactional New Game entry around the approved menu.
## No creature data, combat kit, artwork or existing menu script is modified.

const STARTERS: Array[CreatureData] = [
	preload("res://data/creatures/103_kithflare.tres"),
	preload("res://data/creatures/1701_tallowroot.tres"),
	preload("res://data/creatures/001_rimefin.tres"),
]
const ACCENTS := [Color("#ffb881"), Color("#bbd991"), Color("#9fd5ef")]
const ROLES := ["Quick-footed harasser", "Patient field controller", "Ranged river hunter"]
const PLAY_STYLES := [
	"Closes in with claws, then leaves embers behind as it hops out of reach.",
	"Sends out seed pods, snares a pursuer, and burrows beneath the fight.",
	"Keeps its distance with a pressure jet, lays a riptide, and dives under danger.",
]
const PORTRAITS: Array[SpriteFrames] = [
	preload("res://data/portraits/kithflare_front_idle.tres"),
	preload("res://data/portraits/tallowroot_front_idle.tres"),
	preload("res://data/portraits/rimefin_front_idle.tres"),
]

var _starter_panel: PanelContainer
var _confirm_panel: PanelContainer
var _starter_cards: Array[Button] = []
var _starter_portraits: Array[TextureRect] = []
var _starter_controls: Array[Control] = []
var _confirm_controls: Array[Control] = []
var _starter_action: Button
var _starter_details: Label
var _confirm_title: Label
var _confirm_essence: Label
var _confirm_portrait: TextureRect
var _confirm_action: Button
var _opening_status: Label
var _page_shade: ColorRect
var _boot: Control
var _boot_clock := 0.0
var _boot_done := false
var _boot_fading := false
var _starter_index := 0
var _portrait_clock := 0.0
var _portrait_frame := -1
var _entry_pending := false

func _ready() -> void:
	# The painting is authored for this canvas. KEEP in the parent letterboxes it.
	get_tree().root.content_scale_size = Vector2i(1152, 648)
	super._ready()
	_fade.z_index = 100
	_begin_button.text = "Continue"
	_journey_panel.get_node("Choices").get_child(0).text = "1 / 2    Your courier"
	_page_shade = ColorRect.new()
	_page_shade.name = "OpeningBackdropShade"
	_page_shade.size = Vector2(1152, 648)
	_page_shade.color = Color(0.06, 0.04, 0.12, 0.55)
	_page_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_page_shade.z_index = -1
	_page_shade.hide()
	_ui.add_child(_page_shade)
	_build_starter_page()
	_build_confirmation()
	_update_starter()
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

func _build_starter_page() -> void:
	_starter_panel = _panel("StarterChoice", Vector2(72, 178), 1008)
	var list := _list(_starter_panel)
	list.add_theme_constant_override("separation", 10)
	list.add_child(_label("2 / 2    Your first partner", 34))
	list.add_child(_label("Three different ways to meet the road ahead. Who will travel with you?", 22))
	var row := HBoxContainer.new()
	row.name = "Partners"
	row.add_theme_constant_override("separation", 12)
	list.add_child(row)
	for i in STARTERS.size():
		var card := _button("")
		card.name = STARTERS[i].creature_name
		card.custom_minimum_size = Vector2(310, 220)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.toggle_mode = true
		card.pressed.connect(_choose_starter.bind(i))
		card.focus_entered.connect(_preview_starter.bind(i))
		row.add_child(card)
		_starter_cards.append(card)
		_starter_controls.append(card)
		var portrait := _portrait(card, Vector2(63, 0), Vector2(184, 158))
		_starter_portraits.append(portrait)
		var title := _label(STARTERS[i].creature_name, 30)
		title.name = "PartnerName"
		title.position = Vector2(0, 152)
		title.size = Vector2(310, 38)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(title)
		var essence := _label(STARTERS[i].essence_name(), 20)
		essence.position = Vector2(0, 188)
		essence.size = Vector2(310, 28)
		essence.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		essence.modulate = ACCENTS[i]
		essence.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(essence)
	_starter_details = _label("", 22)
	_starter_details.name = "PartnerPlayStyle"
	_starter_details.custom_minimum_size = Vector2(0, 64)
	_starter_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	list.add_child(_starter_details)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	list.add_child(actions)
	_starter_action = _button("")
	_starter_action.name = "ChoosePartner"
	_starter_action.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_starter_action.pressed.connect(_confirm_starter)
	actions.add_child(_starter_action)
	_starter_controls.append(_starter_action)
	var back := _button("Back")
	back.name = "BackToCourier"
	back.custom_minimum_size.x = 172
	back.pressed.connect(_close_panel)
	actions.add_child(back)
	_starter_controls.append(back)
	_starter_panel.hide()

func _portrait(parent: Node, at: Vector2, dimensions: Vector2) -> TextureRect:
	var portrait := TextureRect.new()
	portrait.name = "Portrait"
	portrait.position = at
	portrait.size = dimensions
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(portrait)
	return portrait

func _build_confirmation() -> void:
	_confirm_panel = _panel("PartnerConfirmation", Vector2(312, 172), 528)
	var list := _list(_confirm_panel)
	_confirm_title = _label("", 36)
	_confirm_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	list.add_child(_confirm_title)
	var art := Control.new()
	art.custom_minimum_size = Vector2(0, 152)
	list.add_child(art)
	_confirm_portrait = _portrait(art, Vector2(132, 0), Vector2(220, 152))
	_confirm_essence = _label("", 22)
	_confirm_essence.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	list.add_child(_confirm_essence)
	var copy := _label("Your partner joins you in your hometown.", 22)
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	list.add_child(copy)
	_confirm_action = _button("Begin Journey")
	_confirm_action.name = "BeginWithPartner"
	_confirm_action.pressed.connect(_commit_journey)
	list.add_child(_confirm_action)
	_confirm_controls.append(_confirm_action)
	var back := _button("Keep looking")
	back.name = "KeepLooking"
	back.pressed.connect(_close_panel)
	list.add_child(back)
	_confirm_controls.append(back)
	_opening_status = _label("", 20)
	_opening_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_opening_status.hide()
	list.add_child(_opening_status)
	_confirm_panel.hide()

func _begin_journey() -> void:
	if _leaving or not _boot_done:
		return
	_sound(CONFIRM_SOUND)
	_show_page("starter", _starter_cards[_starter_index])

func _preview_starter(index: int) -> void:
	if _leaving:
		return
	_starter_index = index
	_update_starter()

func _choose_starter(index: int) -> void:
	_preview_starter(index)
	_sound(CONFIRM_SOUND)
	_starter_action.grab_focus()

func _update_starter() -> void:
	if _starter_action == null:
		return
	_starter_action.text = "Travel with " + STARTERS[_starter_index].creature_name
	_starter_details.text = ROLES[_starter_index] + "\n" + PLAY_STYLES[_starter_index]
	_starter_details.modulate = ACCENTS[_starter_index]
	for i in _starter_cards.size():
		_starter_cards[i].set_pressed_no_signal(i == _starter_index)
		var box := _starter_cards[i].get_theme_stylebox("normal").duplicate() as StyleBoxFlat
		box.border_color = ACCENTS[i]
		box.set_border_width_all(2 if i == _starter_index else 0)
		_starter_cards[i].add_theme_stylebox_override("normal", box)
	if _page == "starter":
		_starter_action.focus_neighbor_top = _starter_cards[_starter_index].get_path()
	_update_portraits()

func _confirm_starter() -> void:
	if _leaving:
		return
	_confirm_title.text = "Travel with " + STARTERS[_starter_index].creature_name + "?"
	_confirm_essence.text = STARTERS[_starter_index].essence_name()
	_confirm_essence.modulate = ACCENTS[_starter_index]
	_opening_status.hide()
	_sound(CONFIRM_SOUND)
	_show_page("confirm", _confirm_action)
	_update_portraits()

func _show_page(page: String, first: Control) -> void:
	super._show_page(page, first)
	if _starter_panel == null:
		return
	_starter_panel.visible = page == "starter"
	_confirm_panel.visible = page == "confirm"
	_page_shade.visible = page in ["journey", "starter", "confirm"]
	if page not in ["starter", "confirm"]:
		return
	_focus_controls.assign(_starter_controls if page == "starter" else _confirm_controls)
	for i in _focus_controls.size():
		var control := _focus_controls[i]
		control.focus_neighbor_top = _focus_controls[posmod(i - 1, _focus_controls.size())].get_path()
		control.focus_neighbor_bottom = _focus_controls[(i + 1) % _focus_controls.size()].get_path()
		control.focus_previous = control.focus_neighbor_top
		control.focus_next = control.focus_neighbor_bottom
		control.focus_neighbor_left = control.get_path()
		control.focus_neighbor_right = control.get_path()
	if page == "starter":
		for i in _starter_cards.size():
			_starter_cards[i].focus_neighbor_left = _starter_cards[posmod(i - 1, 3)].get_path()
			_starter_cards[i].focus_neighbor_right = _starter_cards[(i + 1) % 3].get_path()
			_starter_cards[i].focus_neighbor_bottom = _starter_action.get_path()
		_starter_action.focus_neighbor_top = _starter_cards[_starter_index].get_path()
		_starter_controls[-1].focus_neighbor_top = _starter_cards[_starter_index].get_path()
		_starter_action.focus_neighbor_right = _starter_controls[-1].get_path()
		_starter_controls[-1].focus_neighbor_left = _starter_action.get_path()
	first.grab_focus.call_deferred()
	_place_cursor.call_deferred()

func _close_panel() -> void:
	if _leaving or not _boot_done:
		return
	if _page == "confirm":
		_sound(CANCEL_SOUND)
		_show_page("starter", _starter_cards[_starter_index])
	elif _page == "starter":
		_sound(CANCEL_SOUND)
		_show_page("journey", _begin_button)
	else:
		super._close_panel()

func _process(delta: float) -> void:
	super._process(delta)
	if not _boot_done:
		_boot_clock += delta
		if _boot_clock >= (0.2 if _reduce_motion else 1.8):
			_finish_boot()
		_cursor.hide()
	_portrait_clock += delta
	var frame := 0 if _reduce_motion else int(_portrait_clock * 8.0) % 8
	if frame != _portrait_frame:
		_portrait_frame = frame
		_update_portraits()

func _update_portraits() -> void:
	for i in _starter_portraits.size():
		_starter_portraits[i].texture = _starter_texture(i)
	if _confirm_portrait != null:
		_confirm_portrait.texture = _starter_texture(_starter_index)

func _starter_texture(index: int) -> Texture2D:
	var creature := STARTERS[index]
	if creature.idle_frames.is_empty():
		return creature.sprite
	return creature.idle_frames[maxi(0, _portrait_frame) % creature.idle_frames.size()]

func _commit_journey() -> void:
	if _leaving or _entry_pending or _page != "confirm":
		return
	if _route_scene == null:
		_opening_status.text = "Preparing your journey. Please try again in a moment."
		_opening_status.show()
		return
	var destination := _route_scene.instantiate()
	if not destination.has_method("set_courier_model"):
		destination.free()
		_opening_status.text = "The journey could not be opened. Please try again."
		_opening_status.show()
		return
	destination.call("set_courier_model", _selected_courier)
	_entry_pending = true
	_leaving = true
	_save_preferences()
	_sound(CONFIRM_SOUND)
	for control in _focus_controls:
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		control.focus_mode = Control.FOCUS_NONE
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	_cursor.hide()
	var tween := create_tween().set_parallel()
	tween.tween_property(_fade, "color:a", 1.0, 0.25 if _reduce_motion else 0.7)
	tween.tween_property(_music, "volume_db", -80.0, 0.25 if _reduce_motion else 0.85)
	await tween.finished
	# New Game starts a new run only at final confirmation. Back/cancel never
	# mutates the party. Keep the previous run available if the scene swap fails.
	var previous_party := PlayerParty.caught.duplicate()
	var previous_active := PlayerParty.active_slot
	PlayerParty.caught.clear()
	PlayerParty.active_slot = -1
	var added := PlayerParty.add(STARTERS[_starter_index])
	var error := get_tree().change_scene_to_node(destination) if added else ERR_CANT_CREATE
	if error == OK:
		var welcome := preload("res://scripts/first_partner_arrival.gd").new()
		welcome.creature = STARTERS[_starter_index]
		welcome.portrait_frames = PORTRAITS[_starter_index]
		welcome.accent = ACCENTS[_starter_index]
		welcome.reduce_motion = _reduce_motion
		destination.add_child(welcome)
	else:
		PlayerParty.caught.assign(previous_party)
		PlayerParty.active_slot = previous_active
		PlayerParty.party_changed.emit()
		destination.free()
		_entry_pending = false
		_leaving = false
		_fade.color.a = 0.0
		_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_music.volume_db = music_db
		for control in _focus_controls:
			control.mouse_filter = Control.MOUSE_FILTER_STOP
			control.focus_mode = Control.FOCUS_ALL
		_opening_status.text = "The journey could not be opened. Your previous party is still available."
		_opening_status.show()
		_show_page("confirm", _confirm_action)
