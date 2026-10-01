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
## This is the first slice. The scenery is stand-in art from
## tools/build_menu_blockout.py; real art from the World Asset Forge replaces
## those files one at a time without changing this script.
##
## Layers, back to front (research table L1-L6): sky and clouds, far bank,
## river and ward with fog, the bluff, the characters, the rain.

const PX := 2.0  # screen pixels per art pixel, the same for scenery and characters
const MENU_ART := "res://assets/sprites/menu/"
const CREATURE_SHADER = preload("res://scripts/effects/creature_sprite.gdshader")
const RAIN_SHADER = preload("res://scripts/effects/pixel_rain.gdshader")
const TITLE_FONT = preload("res://assets/fonts/AlegreyaSansSC-Bold.ttf")
const SMALL_FONT = preload("res://assets/fonts/Silkscreen-Regular.ttf")
const MUSIC = preload("res://assets/audio/music/main_menu_pixel_rain.mp3")
const CONFIRM_SOUND = preload("res://assets/audio/sfx/ui/confirm.wav")
const CURSOR_SOUND = preload("res://assets/audio/sfx/ui/cursor.wav")
const CANCEL_SOUND = preload("res://assets/audio/sfx/ui/cancel.wav")
const FIRST_SCENE := "res://scenes/first_route_prototype.tscn"

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


func _ready() -> void:
	# The first route loads in the background while the menu shows.
	ResourceLoader.load_threaded_request(FIRST_SCENE)
	_build_scenery()
	_build_characters()
	_mote_layer = _dots(_draw_motes)
	_seed_sparkle()
	_build_rain()
	_build_menu()
	_music = AudioStreamPlayer.new()
	_music.stream = MUSIC
	if "loop" in _music.stream:
		_music.stream.loop = true
	_music.volume_db = music_db
	_music.bus = &"Music"
	add_child(_music)
	_music.play()


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
	var ui := CanvasLayer.new()
	ui.layer = 10
	add_child(ui)
	var title := Label.new()
	title.text = "HOLLOWTIDE"
	title.add_theme_font_override("font", TITLE_FONT)
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", TEXT)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	title.add_theme_constant_override("shadow_offset_x", 4)
	title.add_theme_constant_override("shadow_offset_y", 4)
	title.add_theme_color_override("font_outline_color", TITLE_EDGE)
	title.add_theme_constant_override("outline_size", 10)
	title.add_theme_color_override("font_shadow_color", Color("#e07a9a"))  # a rose drop shadow
	title.position = Vector2(56, 34)
	ui.add_child(title)
	_title = title
	_title_home = title.position

	var panel := PanelContainer.new()
	var box := StyleBoxFlat.new()
	box.bg_color = SLATE
	box.border_color = SILT
	box.set_border_width_all(4)
	box.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", box)
	panel.position = Vector2(820, 410)
	panel.custom_minimum_size = Vector2(290, 0)
	ui.add_child(panel)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 8)
	panel.add_child(list)
	# Continue comes when there is a save system; for now there are no saves.
	for entry in [["New Game", _on_new_game], ["Reduce Motion: Off", _on_toggle_motion], ["Quit", _on_quit]]:
		var b := _button(entry[0])
		b.pressed.connect(entry[1])
		list.add_child(b)
		_buttons.append(b)
	_motion_button = _buttons[1]
	# Explicit focus routing so a pad or keyboard never gets stuck (research).
	for i in _buttons.size():
		var up: Button = _buttons[(i - 1 + _buttons.size()) % _buttons.size()]
		var down: Button = _buttons[(i + 1) % _buttons.size()]
		_buttons[i].focus_neighbor_top = up.get_path()
		_buttons[i].focus_neighbor_bottom = down.get_path()
	_quiet_focus = true
	_buttons[0].grab_focus.call_deferred()
	set_deferred("_quiet_focus", false)

	# The chiptune cursor: a little pixel arrow that bounces beside the choice.
	_cursor = Polygon2D.new()
	_cursor.polygon = PackedVector2Array([Vector2(0, 0), Vector2(4, 0), Vector2(4, 2), Vector2(6, 2), Vector2(6, 4),
		Vector2(8, 4), Vector2(8, 6), Vector2(6, 6), Vector2(6, 8), Vector2(4, 8), Vector2(4, 10), Vector2(0, 10)])
	_cursor.scale = Vector2.ONE * PX
	_cursor.color = EMBER
	ui.add_child(_cursor)
	_place_cursor.call_deferred()

	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.size = Vector2(1152, 648)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(_fade)


func _place_cursor() -> void:
	var owner := get_viewport().gui_get_focus_owner()
	if _cursor == null or not (owner is Button) or not _buttons.has(owner):
		return
	var r: Rect2 = owner.get_global_rect()
	var bounce: float = roundf((sin(_time * 7.0) + 1.0) * 0.5) * PX * 2.0
	_cursor.position = Vector2(r.position.x + 10.0 + bounce, r.position.y + (r.size.y - 10.0 * PX) * 0.5).round()


func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 44)  # a clear target, per the research
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_override("font", TITLE_FONT)
	b.add_theme_font_size_override("font_size", 26)
	for state in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
		b.add_theme_color_override(state, TEXT)
	var plain := StyleBoxFlat.new()
	plain.bg_color = SLATE
	plain.set_content_margin_all(8)
	plain.content_margin_left = 40  # room for the cursor
	var focus := plain.duplicate()
	focus.bg_color = SLATE.lightened(0.08)
	focus.border_color = EMBER
	focus.set_border_width_all(2)
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
	p.bus = &"Master"  # straight out, so it is not ducked with the music
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()


func _on_focus() -> void:
	if not _quiet_focus and not _leaving:
		_sound(CURSOR_SOUND)


func _on_toggle_motion() -> void:
	# Reduce Motion: clouds, fog and water stop, the rain freezes and the
	# characters stop breathing, so the scene is a still picture.
	_reduce_motion = not _reduce_motion
	_sound(CONFIRM_SOUND)
	_motion_button.text = "Reduce Motion: %s" % ("On" if _reduce_motion else "Off")
	for layer in _drifting:
		layer.autoscroll = Vector2.ZERO if _reduce_motion else layer.get_meta("drift", layer.autoscroll)
	_rain.set_shader_parameter("frozen", 1.0 if _reduce_motion else 0.0)


func _on_new_game() -> void:
	if _leaving:
		return
	_leaving = true
	_sound(CONFIRM_SOUND)
	for b in _buttons:
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.focus_mode = Control.FOCUS_NONE
	# The screen fades to black over a second while the music fades over one
	# and a half; the route opens only after both, so nothing cuts off.
	var t := create_tween().set_parallel()
	t.tween_property(_fade, "color:a", 1.0, 1.0)
	t.tween_property(_music, "volume_db", -80.0, 1.5)
	await t.finished
	var scene: PackedScene = ResourceLoader.load_threaded_get(FIRST_SCENE)
	get_tree().change_scene_to_packed(scene)


func _on_quit() -> void:
	_sound(CANCEL_SOUND)
	get_tree().quit()
