extends Node2D
## The main menu: Concept C, "The Courier Lookout" (Preston, 2026-09-30, from
## docs/Gemini DeepResearch(Hollowtide)/Hollowtide Animated Title Menu Research.docx).
##
## The courier stands on the loess bluff with Cinderhide beside it, both seen
## from behind, looking down at the Old Ferry Ward and the river while rain
## falls. Storm clouds, river fog and the light on the water drift slowly; the
## two characters breathe the way creatures do in battle (whole art pixels,
## feet planted). The menu sits bottom right. New Game fades to black while the
## music fades, then opens the first route.
##
## Second pass (Preston, same day: "more synthy, whimsical, chiptune"): a
## violet-to-rose dusk instead of a grey storm, twinkling pixel stars, embers
## drifting up around Cinderhide, flickering window glows in the ward, lighter
## tinted rain, a bobbing title and a bouncing pixel cursor. Every moving thing
## steps 12 times a second, like drawn frames.
##
## main_menu_art_preview.gd reuses these controls with the approved flat
## dusk landscape and Retro Diffusion walk-in/idles. The base scenery below
## retains the original layered blockout as a fallback.
## New Game chooses the existing male/female courier before opening the hometown.
## Options save audio and motion preferences separately from game progress.
##
## Layers, back to front (research table L1-L6): sky and clouds, far bank,
## river and ward with fog, the bluff, the characters, the rain.

const PX := 2.0  # screen pixels per art pixel, the same for scenery and characters
const MENU_ART := "res://assets/sprites/menu/"
const CREATURE_SHADER = preload("res://scripts/effects/creature_sprite.gdshader")
const RAIN_SHADER = preload("res://scripts/effects/pixel_rain.gdshader")
const SMALL_FONT = preload("res://assets/fonts/Silkscreen-Regular.ttf")
const MUSIC = preload("res://assets/audio/music/main_menu_pixel_rain.mp3")
const CONFIRM_SOUND = preload("res://assets/audio/sfx/ui/confirm.wav")
const CURSOR_SOUND = preload("res://assets/audio/sfx/ui/cursor.wav")
const CANCEL_SOUND = preload("res://assets/audio/sfx/ui/cancel.wav")
const FIRST_SCENE := "res://scenes/world_journey.tscn"
const PREFERENCES := "user://menu_preferences.cfg"
const WALK_ART := "res://assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/"

## The menu's colours: the slate panel and warm silt frame of the battle HUD,
## off-white text, and an ember-orange focus outline (research: text contrast
## above 7:1, focus outline above 3:1).
const SLATE := Color("#1f1b36")     # the panel: deep dusk indigo
const SILT := Color("#8e6fb4")      # its frame: lavender
const TEXT := Color("#fff4e8")
const EMBER := Color("#7fe3d0")     # the focus outline and cursor: mint (well above 3:1 on the panel)
const TITLE_EDGE := Color("#2b2150")
const STEPS := 12.0  # updates a second for everything that moves

@export var music_db: float = -6.0
## Seconds for one breath (Cinderhide's battle idle, per the research).
@export var breath_period: float = 1.9

var _drifting: Array[Parallax2D] = []
var _rain: ShaderMaterial
var _breathers: Array[Sprite2D] = []
var _time := 0.0
var _reduce_motion := false
var _music: AudioStreamPlayer
var _fade: ColorRect
var _buttons: Array[Button] = []
var _continue_button: Button   # only when a save exists (Claude, 2026-10-12)
var _save_note: Label   # only when the save came from its backup (Preston, 2026-10-22)
var _motion_button: Button
var _leaving := false
var _quiet_focus := false
var _stars: Array = []       # [position, phase, bright] in art pixels
var _motes: Array = []       # [position, speed, sway phase]
var _star_layer: Node2D
var _mote_layer: Node2D
var _windows: Sprite2D
var _title: Label
var _title_home := Vector2.ZERO
var _cursor: Polygon2D
var _step_clock := 0.0
var _ui: CanvasLayer
var _main_panel: PanelContainer
var _journey_panel: PanelContainer
var _options_panel: PanelContainer
var _quit_panel: PanelContainer
var _page := "main"
var _focus_controls: Array[Control] = []
var _journey_controls: Array[Control] = []
var _options_controls: Array[Control] = []
var _quit_controls: Array[Control] = []
var _courier_buttons: Array[Button] = []
var _begin_button: Button
var _journey_status: Label
var _options_status: Label
var _selected_courier := "Male"
var _master_volume := 100.0
var _music_volume := 100.0
var _sfx_volume := 100.0   # set from the pause menu's SFX slider; kept and applied here
var _route_scene: PackedScene
var _route_request_error: Error = OK
var _settings_dirty := false

func _ensure_menu_inputs() -> void:
	# The project overrides these defaults with keyboard-only events.
	# Add standard pad confirm/cancel for this run, preserving all existing keys.
	for binding in [["ui_accept", JOY_BUTTON_A], ["ui_cancel", JOY_BUTTON_B]]:
		var event := InputEventJoypadButton.new()
		event.device = -1
		event.button_index = binding[1]
		if not InputMap.action_has_event(binding[0], event):
			InputMap.action_add_event(binding[0], event)


func _ready() -> void:
	_ensure_menu_inputs()
	# The first route loads in the background while the menu shows.
	_request_route()
	_load_preferences()
	_build_scenery()
	_build_characters()
	_mote_layer = _dots(_draw_motes)
	_seed_sparkle()
	_build_rain()
	_build_menu()
	_apply_motion_setting()
	_music = AudioStreamPlayer.new()
	_music.stream = MUSIC
	if "loop" in _music.stream:
		_music.stream.loop = true
	_music.volume_db = music_db
	_music.bus = &"Music"
	add_child(_music)
	_music.play()


func _request_route() -> void:
	_route_request_error = ResourceLoader.load_threaded_request(FIRST_SCENE)


# ------------------------------------------------------------------ the scene

## A layer of art at 2x. `drift` > 0 makes it scroll left forever, wrapping.
func _layer(file: String, y: float, drift: float = 0.0) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = load(MENU_ART + file)
	sprite.centered = false
	sprite.scale = Vector2.ONE * PX
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if drift <= 0.0:
		sprite.position = Vector2(0, y * PX)
		add_child(sprite)
		return
	var layer := Parallax2D.new()
	layer.repeat_size = Vector2(sprite.texture.get_width() * PX, 0)
	layer.autoscroll = Vector2(-drift, 0)
	layer.set_meta("drift", layer.autoscroll)  # remembered for Reduce Motion
	layer.repeat_times = 2
	layer.position = Vector2(0, y * PX)
	layer.add_child(sprite)
	add_child(layer)
	_drifting.append(layer)


func _build_scenery() -> void:
	# The research's scroll speeds were -10, -20 and -35. Only things that drift
	# in life move here: clouds, the light on the water and the fog. The far
	# bank and the ward stay put, so the town does not slide past.
	_layer("sky.png", 0)
	_star_layer = _dots(_draw_stars)
	_layer("clouds.png", 0, 10.0)
	_layer("far_bank.png", 136)
	_layer("river.png", 156)
	_layer("glints.png", 156, 18.0)
	_layer("ward.png", 224)
	_layer("window_glow.png", 0)
	_windows = get_child(get_child_count() - 1)
	_layer("fog.png", 212, 24.0)
	_layer("bluff.png", 0)


func _character(tex: Texture2D, feet: Vector2, scale_by: float, depth: float) -> void:
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = false
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale = Vector2.ONE * scale_by
	var used: Rect2i = tex.get_image().get_used_rect()
	# Stand the sprite's feet (the bottom of its drawn pixels) on the bluff.
	s.position = (feet - Vector2(used.position.x + used.size.x * 0.5, used.end.y) * scale_by).round()
	var mat := ShaderMaterial.new()
	mat.shader = CREATURE_SHADER
	var th: float = tex.get_height()
	var tw: float = tex.get_width()
	mat.set_shader_parameter("breath_lift", 0.0)
	mat.set_shader_parameter("breath_cut", float(used.end.y) / th)  # the whole body rises, feet planted
	mat.set_shader_parameter("breath_top", float(used.position.y) / th)
	mat.set_shader_parameter("breath_mid", (used.position.x + used.size.x * 0.5) / tw)
	mat.set_shader_parameter("breath_half", used.size.x * 0.5 / tw)
	mat.set_shader_parameter("heat", 0.0)
	s.material = mat
	s.set_meta("breath_px", maxf(1.0, roundf(depth * used.size.y)))
	add_child(s)
	_breathers.append(s)


func _build_characters() -> void:
	# The courier from behind (the walk sheet's back row) and Cinderhide's
	# approved back sprite, both at the scene's art-pixel size, on the bluff.
	_character(load(MENU_ART + "courier_back.png"), Vector2(300, 478), PX, 0.012)
	_character(load("res://assets/sprites/creatures/cinderhide_back.png"), Vector2(432, 480), PX, 0.026)


## A layer drawn in code (the stars, the embers), redrawn on the step.
func _dots(drawer: Callable) -> Node2D:
	var n := Node2D.new()
	n.draw.connect(drawer.bind(n))
	add_child(n)
	return n


func _seed_sparkle() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260930
	for i in 34:
		_stars.append([Vector2(rng.randi_range(4, 572), rng.randi_range(3, 44)), rng.randf() * TAU, rng.randf() < 0.25])
	# Embers rising from around Cinderhide and along the bluff's lip.
	for i in 14:
		_motes.append([Vector2(rng.randf_range(150, 300), rng.randf_range(120, 240)), rng.randf_range(4.0, 9.0), rng.randf() * TAU])


func _draw_stars(n: Node2D) -> void:
	for star in _stars:
		var k: float = (sin(_time * 2.2 + star[1]) + 1.0) * 0.5
		if k < 0.2:
			continue  # this one blinks out for a moment
		var c := Color("#fff4e8") if star[2] else Color("#cdb8f0")
		c.a = 0.45 + 0.55 * roundf(k * 2.0) / 2.0  # three brightness steps, not a smooth fade
		var p: Vector2 = star[0] * PX
		n.draw_rect(Rect2(p, Vector2(PX, PX)), c)
		if star[2] and k > 0.85:
			# The bright ones flash a little cross at their peak.
			for d in [Vector2(PX, 0), Vector2(-PX, 0), Vector2(0, PX), Vector2(0, -PX)]:
				n.draw_rect(Rect2(p + d, Vector2(PX, PX)), Color(c, c.a * 0.5))


func _draw_motes(n: Node2D) -> void:
	for mote in _motes:
		var p: Vector2 = (mote[0] as Vector2).round() * PX
		var hot: bool = sin(_time * 5.0 + mote[2]) > 0.3
		n.draw_rect(Rect2(p, Vector2(PX, PX)), Color("#ffd27a") if hot else Color("#fc7424"))


func _build_rain() -> void:
	var rect := ColorRect.new()
	rect.size = Vector2(1152, 648)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rain = ShaderMaterial.new()
	_rain.shader = RAIN_SHADER
	_rain.set_shader_parameter("px", PX)
	_rain.set_shader_parameter("tint", Color(0.78, 0.8, 1.0, 0.26))  # lavender-blue drizzle
	_rain.set_shader_parameter("density", 0.09)
	rect.material = _rain
	add_child(rect)


func _process(delta: float) -> void:
	_poll_route()
	_place_cursor()
	if _reduce_motion:
		return
	_time += delta
	# Breathing in whole art pixels, like the battle idle: up on the inhale,
	# back down on the exhale, the feet never moving.
	var k: float = (sin(TAU * _time / breath_period) + 1.0) * 0.5
	for s in _breathers:
		var most: float = s.get_meta("breath_px")
		(s.material as ShaderMaterial).set_shader_parameter("breath_lift", roundf(k * most))
	_step_clock += delta
	if _step_clock < 1.0 / STEPS:
		return
	var dt: float = _step_clock
	_step_clock = 0.0
	# Embers drift up and sway, and start again at the bottom once they fade out.
	for mote in _motes:
		mote[0] += Vector2(sin(_time * 1.7 + mote[2]) * 0.6, -mote[1] * dt)
		if mote[0].y < 70.0:
			mote[0] = Vector2(randf_range(150, 300), randf_range(215, 240))
	_star_layer.queue_redraw()
	_mote_layer.queue_redraw()
	# Window lights flicker a little, like lamps.
	_windows.modulate.a = 0.75 + 0.25 * roundf(randf() * 2.0) / 2.0
	# The title bobs by one art pixel; the cursor bounces toward its choice.
	_title.position.y = _title_home.y + roundf(sin(_time * 1.6)) * PX
	_place_cursor()


# ------------------------------------------------------------------ the menu

func _build_menu() -> void:
	_ui = CanvasLayer.new()
	_ui.name = "MenuUI"
	_ui.layer = 10
	add_child(_ui)
	_title = Label.new()
	_title.name = "Title"
	_title.text = "HOLLOWTIDE"
	_title.add_theme_font_override("font", UI.font("display"))
	_title.add_theme_font_size_override("font_size", UI.type_size("display"))
	_title.add_theme_color_override("font_color", TEXT)
	_title.add_theme_color_override("font_outline_color", TITLE_EDGE)
	_title.add_theme_constant_override("outline_size", 10)
	_title.add_theme_color_override("font_shadow_color", Color("#e07a9a"))
	_title.add_theme_constant_override("shadow_offset_x", 4)
	_title.add_theme_constant_override("shadow_offset_y", 4)
	_title.position = Vector2(56, 34)
	_ui.add_child(_title)
	_title_home = _title.position

	_main_panel = _panel("MainChoices", Vector2(820, 410), 290)
	var list := _list(_main_panel)
	# Continue is listed first when the team has a save (Claude, 2026-10-12, scripts/town/team_state.gd);
	# New Game stays as it was and only overwrites the save when the new team first reaches Highbank.
	var entries: Array = []
	if TeamState.has_save():
		entries.append(["Continue", "Continue", _on_continue])
	entries.append_array([
		["NewGame", "New Game", _on_new_game],
		["Options", "Options", _on_options],
		["Quit", "Quit", _on_quit]])
	for entry in entries:
		var b := _button(entry[1])
		b.name = entry[0]
		b.pressed.connect(entry[2])
		list.add_child(b)
		_buttons.append(b)
		if entry[0] == "Continue":
			_continue_button = b
	# The last save was damaged (a crash or power cut mid-write) and the one before it was read instead:
	# say so, as Preston asked, instead of quietly continuing from an older point (2026-10-22).
	if _continue_button != null and TeamState.restored_from_backup:
		# Two fixed lines, no autowrap: a wrapping label with no minimum width asks its container for one
		# character per line, and the panel grew to 1373 px (measured 2026-10-22).
		_save_note = _label("Your last save was damaged.\nThe one before it was loaded.", 18)
		_save_note.name = "SaveNote"
		list.add_child(_save_note)

	_build_journey_panel()
	_build_options_panel()
	_build_quit_panel()
	_cursor = Polygon2D.new()
	_cursor.name = "FocusCursor"
	_cursor.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(4, 0), Vector2(4, 2), Vector2(6, 2),
		Vector2(6, 4), Vector2(8, 4), Vector2(8, 6), Vector2(6, 6),
		Vector2(6, 8), Vector2(4, 8), Vector2(4, 10), Vector2(0, 10)])
	_cursor.scale = Vector2.ONE * PX
	_cursor.color = EMBER
	_ui.add_child(_cursor)

	_fade = ColorRect.new()
	_fade.name = "TransitionFade"
	_fade.color = Color(0, 0, 0, 0)
	_fade.size = Vector2(1152, 648)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_fade)
	_quiet_focus = true
	_show_page("main", _buttons[0])
	set_deferred("_quiet_focus", false)


const UI := preload("res://scripts/ui/ui_style.gd")
const TeamState := preload("res://scripts/town/team_state.gd")   # the save behind Continue (Claude, 2026-10-12)

func _panel(node_name: String, at: Vector2, width: float) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = node_name
	var box := UI.frame("panel").duplicate()
	box.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel", box)
	panel.position = at
	panel.custom_minimum_size = Vector2(width, 0)
	_ui.add_child(panel)
	return panel


func _list(panel: PanelContainer) -> VBoxContainer:
	var list := VBoxContainer.new()
	list.name = "Choices"
	list.add_theme_constant_override("separation", 8)
	panel.add_child(list)
	return list


func _label(text: String, size: int = 24) -> Label:
	var label := Label.new()
	label.text = text
	var role := "title" if size >= 30 else "body"
	label.add_theme_font_override("font", UI.font(role))
	label.add_theme_font_size_override("font_size", UI.type_size(role))
	label.add_theme_color_override("font_color", TEXT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _build_journey_panel() -> void:
	_journey_panel = _panel("Journey", Vector2(650, 150), 460)
	var list := _list(_journey_panel)
	list.add_child(_label("Your courier", 34))
	list.add_child(_label("Choose who will make the journey.", 22))
	var row := HBoxContainer.new()
	row.name = "Couriers"
	row.add_theme_constant_override("separation", 12)
	list.add_child(row)
	for model in ["Male", "Female"]:
		var card := _button("")
		card.name = model
		card.custom_minimum_size = Vector2(202, 200)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.toggle_mode = true
		card.pressed.connect(_select_courier.bind(model))
		# Moving onto a courier also chooses it, so arrows and the label agree.
		card.focus_entered.connect(_select_courier.bind(model))
		row.add_child(card)
		_courier_buttons.append(card)
		_journey_controls.append(card)
		var preview := TextureRect.new()
		preview.name = "Portrait"
		var atlas := AtlasTexture.new()
		var file := "male_chibi_walk_matched_turns_native80.png" if model == "Male" else "female_chibi_walk_eight_directions_native80.png"
		atlas.atlas = load(WALK_ART + file)
		atlas.region = Rect2(0, 0, 80, 80)
		preview.texture = atlas
		if model == "Female":
			var finish := ShaderMaterial.new()
			finish.shader = preload("res://scripts/effects/courier_finish.gdshader")
			preview.material = finish
		preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		preview.position = Vector2(21, 4)
		preview.size = Vector2(160, 160)
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(preview)
		var caption := _label(model, 24)
		caption.name = "Caption"
		caption.position = Vector2(0, 164)
		caption.size = Vector2(202, 30)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.add_child(caption)
	_begin_button = _button("Begin Journey")
	_begin_button.name = "Begin"
	_begin_button.pressed.connect(_begin_journey)
	list.add_child(_begin_button)
	_journey_controls.append(_begin_button)
	var back := _button("Back")
	back.name = "Back"
	back.pressed.connect(_close_panel)
	list.add_child(back)
	_journey_controls.append(back)
	_journey_status = _label("", 18)
	_journey_status.name = "Status"
	_journey_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	list.add_child(_journey_status)
	_update_courier_selection()


func _build_options_panel() -> void:
	_options_panel = _panel("Options", Vector2(700, 120), 410)
	var list := _list(_options_panel)
	list.add_child(_label("Options", 34))
	_volume_control(list, "Master volume", "Master", _master_volume)
	_volume_control(list, "Music volume", "Music", _music_volume)
	_motion_button = _button("")
	_motion_button.name = "ReduceMotion"
	_motion_button.pressed.connect(_on_toggle_motion)
	list.add_child(_motion_button)
	_options_controls.append(_motion_button)
	_update_motion_label()
	var back := _button("Back")
	back.name = "Back"
	back.pressed.connect(_close_panel)
	list.add_child(back)
	_options_controls.append(back)
	_options_status = _label("Changes are saved automatically.", 18)
	_options_status.name = "Status"
	list.add_child(_options_status)


func _volume_control(list: VBoxContainer, caption: String, bus: String, initial: float) -> void:
	var label := _label("%s   %d%%" % [caption, int(initial)], 22)
	label.name = bus + "Value"
	list.add_child(label)
	var slider := HSlider.new()
	slider.name = bus + "Volume"
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 5
	slider.value = initial
	slider.custom_minimum_size = Vector2(0, 52)
	slider.focus_mode = Control.FOCUS_ALL
	var track := UI.frame("panel_dim").duplicate()
	var fill := UI.frame("panel_focus").duplicate()
	slider.add_theme_stylebox_override("slider", track)
	slider.add_theme_stylebox_override("grabber_area", fill)
	slider.add_theme_stylebox_override("grabber_area_highlight", fill)
	slider.value_changed.connect(func(value: float) -> void:
		if bus == "Master":
			_master_volume = value
		else:
			_music_volume = value
		label.text = "%s   %d%%" % [caption, int(value)]
		_apply_volume(bus, value)
		_settings_dirty = true
		_save_preferences()
	)
	var ring := Panel.new()
	ring.name = "FocusRing"
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ring.offset_left = -6
	ring.offset_top = -2
	ring.offset_right = 6
	ring.offset_bottom = 2
	var outline := UI.frame("panel_focus").duplicate()
	# The focus frame sits behind the slider, keeping its grabber visible.
	ring.show_behind_parent = true
	ring.add_theme_stylebox_override("panel", outline)
	ring.visible = false
	slider.add_child(ring)
	slider.focus_entered.connect(func() -> void:
		ring.visible = true
		label.add_theme_color_override("font_color", EMBER)
	)
	slider.focus_exited.connect(func() -> void:
		ring.visible = false
		label.add_theme_color_override("font_color", TEXT)
	)
	slider.focus_entered.connect(_on_focus)
	slider.mouse_entered.connect(slider.grab_focus)
	list.add_child(slider)
	_options_controls.append(slider)


func _build_quit_panel() -> void:
	_quit_panel = _panel("QuitConfirmation", Vector2(720, 330), 390)
	var list := _list(_quit_panel)
	list.add_child(_label("Leave Hollowtide?", 32))
	var back := _button("Keep Exploring")
	back.name = "Back"
	back.pressed.connect(_close_panel)
	list.add_child(back)
	_quit_controls.append(back)
	var quit := _button("Quit Game")
	quit.name = "ConfirmQuit"
	quit.pressed.connect(_confirm_quit)
	list.add_child(quit)
	_quit_controls.append(quit)


func _show_page(page: String, first: Control) -> void:
	_page = page
	_main_panel.visible = page == "main"
	_journey_panel.visible = page == "journey"
	_options_panel.visible = page == "options"
	_quit_panel.visible = page == "quit"
	_focus_controls.clear()
	match page:
		"main":
			for b in _buttons:
				_focus_controls.append(b)
		"journey":
			_focus_controls.assign(_journey_controls)
		"options":
			_focus_controls.assign(_options_controls)
		"quit":
			_focus_controls.assign(_quit_controls)
	# Every page is its own focus loop. Hidden controls cannot receive focus.
	for i in _focus_controls.size():
		var control := _focus_controls[i]
		var previous := _focus_controls[(i - 1 + _focus_controls.size()) % _focus_controls.size()]
		var next := _focus_controls[(i + 1) % _focus_controls.size()]
		control.focus_neighbor_top = previous.get_path()
		control.focus_neighbor_bottom = next.get_path()
		control.focus_previous = previous.get_path()
		control.focus_next = next.get_path()
		control.focus_neighbor_left = control.get_path()
		control.focus_neighbor_right = control.get_path()
	# Horizontal arrows also move between the two courier portraits.
	if page == "journey":
		_courier_buttons[0].focus_neighbor_left = _courier_buttons[1].get_path()
		_courier_buttons[0].focus_neighbor_right = _courier_buttons[1].get_path()
		_courier_buttons[1].focus_neighbor_left = _courier_buttons[0].get_path()
		_courier_buttons[1].focus_neighbor_right = _courier_buttons[0].get_path()
		for card in _courier_buttons:
			card.focus_neighbor_bottom = _begin_button.get_path()
		_begin_button.focus_neighbor_top = _courier_buttons[0 if _selected_courier == "Male" else 1].get_path()
	first.grab_focus.call_deferred()
	_place_cursor.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _page != "main" and not _leaving:
		_close_panel()
		get_viewport().set_input_as_handled()


func _place_cursor() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if _cursor == null:
		return
	_cursor.visible = focused is Button and _focus_controls.has(focused) and not _leaving
	if not _cursor.visible:
		return
	var rect: Rect2 = focused.get_global_rect()
	var bounce: float = 0.0 if _reduce_motion else roundf((sin(_time * 7.0) + 1.0) * 0.5) * PX * 2.0
	_cursor.position = Vector2(rect.position.x + 10.0 + bounce, rect.position.y + (rect.size.y - 10.0 * PX) * 0.5).round()


func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 52)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_override("font", UI.font("button"))
	b.add_theme_font_size_override("font_size", UI.type_size("button"))
	for state in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
		b.add_theme_color_override(state, TEXT)
	var plain := UI.frame("panel").duplicate()
	plain.content_margin_top = 8
	plain.content_margin_bottom = 8
	plain.content_margin_left = 40
	var focus := UI.frame("panel_focus").duplicate()
	focus.content_margin_top = 8
	focus.content_margin_bottom = 8
	focus.content_margin_left = 40
	b.add_theme_stylebox_override("normal", plain)
	b.add_theme_stylebox_override("pressed", focus)
	b.add_theme_stylebox_override("hover", focus)
	b.add_theme_stylebox_override("focus", focus)
	b.focus_entered.connect(_on_focus)
	b.focus_entered.connect(_place_cursor)
	b.mouse_entered.connect(b.grab_focus)
	return b


func _sound(stream: AudioStream) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = -6.0
	p.bus = &"UI"   # title clicks with the other clicks (FEEL-08; Claude, 2026-10-22)
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()


func _on_focus() -> void:
	if not _quiet_focus and not _leaving:
		_sound(CURSOR_SOUND)


func _on_new_game() -> void:
	if _leaving:
		return
	_sound(CONFIRM_SOUND)
	_show_page("journey", _courier_buttons[0] if _selected_courier == "Male" else _courier_buttons[1])


## Continue (Claude, 2026-10-12): read the team's save and open Highbank with it, the same fade out as
## the journey. The save is written by the town (hub_town.gd) when the team arrives or sets out.
func _on_continue() -> void:
	if _leaving or ("_boot_done" in self and not get("_boot_done")):
		return
	if not TeamState.load_save():
		_sound(CANCEL_SOUND)
		if _continue_button != null:
			_continue_button.disabled = true
		return
	# A run kept by a quit mid-dungeon resumes at the top of its floor; otherwise Highbank.
	var town: Node
	if TeamState.has_suspended():
		var run: Dictionary = TeamState.take_suspended()
		town = load("res://scenes/dungeon.tscn").instantiate()
		TeamState.give_to(town)
		town.set("dungeon", String(run.get("dungeon", "first")))
		town.set("floor_n", int(run.get("floor_n", 1)))
		town.set("floor_seed", int(run.get("floor_seed", 0)))
		town.set("replay", bool(run.get("replay", false)))
		town.set("return_to_town", true)
		town.set("resume", run)
	else:
		town = load("res://scenes/hub_town.tscn").instantiate()
		TeamState.give_to(town)
	_save_preferences()
	_leaving = true
	_sound(CONFIRM_SOUND)
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	_cursor.visible = false
	for control in _focus_controls:
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		control.focus_mode = Control.FOCUS_NONE
	var tween := create_tween().set_parallel()
	tween.tween_property(_fade, "color:a", 1.0, 0.25 if _reduce_motion else 0.7)
	tween.tween_property(_music, "volume_db", -80.0, 0.25 if _reduce_motion else 0.85)
	await tween.finished
	var error := get_tree().change_scene_to_node(town)
	if error != OK:
		town.free()
		_leaving = false
		_fade.color.a = 0.0
		_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_music.volume_db = music_db
		for control in _focus_controls:
			control.mouse_filter = Control.MOUSE_FILTER_STOP
			control.focus_mode = Control.FOCUS_ALL
		_show_page("main", _buttons[0])


func _select_courier(model: String) -> void:
	if _leaving or model == _selected_courier:
		_update_courier_selection()
		return
	_selected_courier = model
	_settings_dirty = true
	_update_courier_selection()
	_save_preferences()
	_sound(CONFIRM_SOUND)


func _update_courier_selection() -> void:
	if _begin_button != null:
		_begin_button.focus_neighbor_top = _courier_buttons[0 if _selected_courier == "Male" else 1].get_path()
	for i in _courier_buttons.size():
		var selected: bool = (i == 0 and _selected_courier == "Male") or (i == 1 and _selected_courier == "Female")
		_courier_buttons[i].set_pressed_no_signal(selected)
		_courier_buttons[i].get_node("Portrait").modulate = Color.WHITE if selected else Color(0.75, 0.75, 0.85)
		_courier_buttons[i].get_node("Caption").text = ("Male" if i == 0 else "Female") + (" (selected)" if selected else "")


func _on_options() -> void:
	if _leaving:
		return
	_sound(CONFIRM_SOUND)
	_show_page("options", _options_controls[0])


func _on_quit() -> void:
	if _leaving:
		return
	_sound(CANCEL_SOUND)
	_show_page("quit", _quit_controls[0])


func _close_panel() -> void:
	if _leaving:
		return
	# Back to the button that opened the page, by name: Continue may sit first (Claude, 2026-10-12).
	var back_to := "Options" if _page == "options" else ("Quit" if _page == "quit" else "NewGame")
	var return_to: Control = _buttons[0]
	for b in _buttons:
		if b.name == back_to:
			return_to = b
	_save_preferences()
	_sound(CANCEL_SOUND)
	_show_page("main", return_to)


func _confirm_quit() -> void:
	_save_preferences()
	get_tree().quit()


func _update_motion_label() -> void:
	_motion_button.text = "Reduce Motion: %s" % ("On" if _reduce_motion else "Off")


func _on_toggle_motion() -> void:
	_reduce_motion = not _reduce_motion
	_settings_dirty = true
	_sound(CONFIRM_SOUND)
	_update_motion_label()
	_apply_motion_setting()
	_save_preferences()


func _apply_motion_setting() -> void:
	for layer in _drifting:
		layer.autoscroll = Vector2.ZERO if _reduce_motion else layer.get_meta("drift", layer.autoscroll)
	_rain.set_shader_parameter("frozen", 1.0 if _reduce_motion else 0.0)


func _apply_volume(bus: String, percent: float) -> void:
	var index := AudioServer.get_bus_index(bus)
	if index < 0:
		return
	AudioServer.set_bus_mute(index, percent <= 0.0)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(percent / 100.0, 0.001)))


func _load_preferences() -> void:
	var config := ConfigFile.new()
	if config.load(PREFERENCES) != OK:
		return
	_master_volume = clampf(float(config.get_value("audio", "master", 100.0)), 0.0, 100.0)
	_music_volume = clampf(float(config.get_value("audio", "music", 100.0)), 0.0, 100.0)
	_sfx_volume = clampf(float(config.get_value("audio", "sfx", 100.0)), 0.0, 100.0)
	_reduce_motion = bool(config.get_value("menu", "reduce_motion", false))
	_selected_courier = str(config.get_value("menu", "courier", "Male"))
	if _selected_courier not in ["Male", "Female"]:
		_selected_courier = "Male"
	_apply_volume("Master", _master_volume)
	_apply_volume("Music", _music_volume)
	_apply_volume("SFX", _sfx_volume)


func _save_preferences() -> void:
	if not _settings_dirty:
		return
	var config := ConfigFile.new()
	config.load(PREFERENCES)   # keep keys this menu does not edit
	config.set_value("audio", "master", _master_volume)
	config.set_value("audio", "music", _music_volume)
	config.set_value("audio", "sfx", _sfx_volume)
	config.set_value("menu", "reduce_motion", _reduce_motion)
	config.set_value("menu", "courier", _selected_courier)
	var error := config.save(PREFERENCES + ".tmp")
	if error == OK:
		error = DirAccess.rename_absolute(ProjectSettings.globalize_path(PREFERENCES + ".tmp"), ProjectSettings.globalize_path(PREFERENCES))
	if error == OK:
		_settings_dirty = false
		UI.reload_prefs()
		_options_status.text = "Changes are saved automatically."
	else:
		_options_status.text = "Settings could not be saved."
		push_warning("Menu preferences could not be saved: %s" % error_string(error))


func _poll_route() -> void:
	if _route_scene != null:
		return
	if _route_request_error != OK:
		_set_route_error()
		return
	var status := ResourceLoader.load_threaded_get_status(FIRST_SCENE)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		_route_scene = ResourceLoader.load_threaded_get(FIRST_SCENE) as PackedScene
		if _route_scene == null:
			_set_route_error()
		else:
			_begin_button.disabled = false
			_journey_status.visible = false
	elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		_set_route_error()
	else:
		_begin_button.disabled = true
		_journey_status.text = "Preparing your journey..."
		_journey_status.visible = true


func _set_route_error() -> void:
	_begin_button.disabled = true
	_journey_status.text = "Route 1 could not be opened. Please try again later."
	_journey_status.visible = true


func _begin_journey() -> void:
	if _leaving or _route_scene == null:
		return
	# Set the courier before any area builds its eight-direction atlas.
	var destination := _route_scene.instantiate()
	if not destination.has_method("set_courier_model"):
		destination.free()
		_set_route_error()
		return
	destination.call("set_courier_model", _selected_courier)
	_save_preferences()
	_leaving = true
	_sound(CONFIRM_SOUND)
	for control in _focus_controls:
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		control.focus_mode = Control.FOCUS_NONE
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	_cursor.visible = false
	var tween := create_tween().set_parallel()
	tween.tween_property(_fade, "color:a", 1.0, 1.0)
	tween.tween_property(_music, "volume_db", -80.0, 1.5)
	await tween.finished
	var error := get_tree().change_scene_to_node(destination)
	if error != OK:
		destination.free()
		_leaving = false
		_fade.color.a = 0.0
		_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_music.volume_db = music_db
		for control in _focus_controls:
			control.mouse_filter = Control.MOUSE_FILTER_STOP
			control.focus_mode = Control.FOCUS_ALL
		_journey_status.text = "The journey could not be opened. Please try again."
		_journey_status.visible = true
		_show_page("journey", _begin_button)
