extends "res://scripts/main_menu.gd"
## Courier Lookout menu with Retro Diffusion walk-in and idle animation.
## The flat backdrop and original source artwork remain preserved.

const IDLE_ART := MENU_ART + "retro_diffusion_idle_2026_10_01/"
const IDLE_FRAME_SIZE := 80

var _previous_aspect: Window.ContentScaleAspect
var _idle_actors: Array[Sprite2D] = []

func _ready() -> void:
	# Keep the full 16:9 composition when the review window is resized.
	_previous_aspect = get_tree().root.content_scale_aspect
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	super._ready()
	_build_wordmark()

func _exit_tree() -> void:
	get_tree().root.content_scale_aspect = _previous_aspect

func _build_scenery() -> void:
	_layer("courier_lookout_dusk_candidate_576.png", 0)
	_star_layer = _dots(_draw_stars)
	# The base animation expects a window sprite. Keep the flat art steady.
	_windows = Sprite2D.new()
	add_child(_windows)
	_find_lights(load(MENU_ART + "courier_lookout_dusk_candidate_576.png").get_image())
	_sky_layer = _dots(_draw_sky_life)
	_water_layer = _dots(_draw_water)
	_lamp_layer = _dots(_draw_lamps)
	# Lamps add light rather than paint over the windows.
	var glow := CanvasItemMaterial.new()
	glow.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_lamp_layer.material = glow


# ------------------------------------------------- life added 2026-10-05
# Everything below reads the flat painting to decide where light already is,
# so glints only land on sunlit water and lamps only on lit windows. It all
# steps 12 times a second like the rest of the menu and stops for Reduce Motion.

var _sky_layer: Node2D
var _water_layer: Node2D
var _lamp_layer: Node2D
var _water_light: Array[Vector2i] = []   # sunset reflection on the open river
var _lamp_streaks: Array[Vector2i] = []  # the town's lamp reflections below the quay
var _lamps: Array = []                   # [pixels, phase, flicker speed] per window
var _glints: Array = []                  # [pixel, length, born, life]
var _life_clock := 0.0
var _rng := RandomNumberGenerator.new()
var _next_flock := 6.0
var _flock_start := -100.0
var _flock_y := 60.0
var _next_star := 11.0
var _shooting_start := -100.0
var _shooting_from := Vector2.ZERO
var _next_shine := 4.0

const FLOCK := [Vector2(0, 0), Vector2(7, -3), Vector2(9, 4), Vector2(16, -5), Vector2(19, 2)]
const FLOCK_SPEED := 26.0   # art pixels a second, right to left
const SHOOTING_SECONDS := 0.6
const SHINE_SECONDS := 0.9


func _find_lights(art: Image) -> void:
	_rng.seed = 20261005
	var window_pixels: Array[Vector2i] = []
	for y in art.get_height():
		for x in art.get_width():
			var c := art.get_pixel(x, y)
			var r := c.r8
			var g := c.g8
			var b := c.b8
			if x > 400 and y > 120 and y < 220 and r > 225 and g > 160 and b < 140:
				window_pixels.append(Vector2i(x, y))
			elif x > 250 and x < 450 and y > 100 and y < 160 and r > 200 and g > 110 and b > 100 and r > b:
				_water_light.append(Vector2i(x, y))
			elif x > 415 and y > 195 and y < 265 and r > 200 and g > 120 and b < 140:
				_lamp_streaks.append(Vector2i(x, y))
	# Neighbouring window pixels belong to one lamp, which flickers as a unit.
	var left := window_pixels.duplicate()
	while not left.is_empty():
		var group: Array[Vector2i] = [left.pop_back()]
		var i := 0
		while i < group.size():
			for j in range(left.size() - 1, -1, -1):
				if absi(left[j].x - group[i].x) <= 2 and absi(left[j].y - group[i].y) <= 2:
					group.append(left[j])
					left.remove_at(j)
			i += 1
		_lamps.append([group, _rng.randf() * TAU, _rng.randf_range(0.6, 1.6)])


func _draw_water(n: Node2D) -> void:
	for g in _glints:
		var age: float = (_time - g[2]) / g[3]
		# Rise, hold, fall in three steps, like a drawn sparkle.
		var a: float = 0.8 if age < 0.25 or age > 0.75 else 1.0
		var c := Color("#fff6ec") if g[1] > 0 else Color("#ffd27a")
		c.a = a
		var p: Vector2 = Vector2(g[0]) * PX
		n.draw_rect(Rect2(p, Vector2(PX * maxi(1, absi(g[1])), PX)), c)


func _draw_lamps(n: Node2D) -> void:
	for lamp in _lamps:
		# A slow breath with the odd dip, the way an oil lamp gutters.
		var k: float = sin(_time * lamp[2] + lamp[1])
		var a: float = 0.0
		if k > 0.55:
			a = 0.22
		elif k > -0.2:
			a = 0.12
		elif sin(_time * 7.0 + lamp[1]) > 0.9:
			a = -1.0
		if a <= 0.0:
			continue
		for px in lamp[0]:
			n.draw_rect(Rect2(Vector2(px) * PX, Vector2(PX, PX)), Color(1.0, 0.72, 0.36, a))


func _draw_sky_life(n: Node2D) -> void:
	var dark := Color("#2b2150")
	var since := _time - _flock_start
	var lead_x := 600.0 - since * FLOCK_SPEED
	if lead_x > -40.0:
		for i in FLOCK.size():
			var b: Vector2 = (Vector2(lead_x, _flock_y) + FLOCK[i]).round()
			# Two wing frames, each bird a little out of step with the next.
			var up := int(floor(_time * 6.0 + i * 1.3)) % 2 == 0
			for d in ([Vector2(-1, -1), Vector2(0, 0), Vector2(1, -1)] if up else [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0)]):
				n.draw_rect(Rect2((b + d) * PX, Vector2(PX, PX)), dark)
	var t := (_time - _shooting_start) / SHOOTING_SECONDS
	if t >= 0.0 and t <= 1.0:
		var head := (_shooting_from + Vector2(-70, 22) * t).round()
		# A bright head, then a continuous trail back up the way it came.
		for k in 16:
			var c := Color("#fff4e8")
			c.a = (1.0 - k / 16.0) * (1.0 - t * 0.5)
			n.draw_rect(Rect2((head + Vector2(k, -roundf(k / 3.0))) * PX, Vector2(PX, PX)), c)
		for d in [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0)]:
			n.draw_rect(Rect2((head + d) * PX, Vector2(PX, PX)), Color(1.0, 0.95, 0.85, 0.5 * (1.0 - t)))


func _update_life(delta: float) -> void:
	_life_clock += delta
	if _life_clock < 1.0 / STEPS:
		return
	_life_clock = 0.0
	# Keep about two dozen glints on the sunlit water and a few on the lamp streaks.
	_glints = _glints.filter(func(g): return _time - g[2] < g[3])
	while _glints.size() < 26 and not _water_light.is_empty():
		_glints.append([_water_light[_rng.randi() % _water_light.size()], _rng.randi_range(1, 3), _time, _rng.randf_range(0.4, 1.1)])
	while _glints.size() < 33 and not _lamp_streaks.is_empty():
		_glints.append([_lamp_streaks[_rng.randi() % _lamp_streaks.size()], -_rng.randi_range(1, 2), _time, _rng.randf_range(0.3, 0.8)])
	if _time > _next_flock:
		_flock_start = _time
		_flock_y = _rng.randf_range(52.0, 72.0)
		_next_flock = _time + _rng.randf_range(28.0, 45.0)
	if _time > _next_star:
		_shooting_start = _time
		_shooting_from = Vector2(_rng.randf_range(300, 540), _rng.randf_range(6, 24))
		_next_star = _time + _rng.randf_range(20.0, 34.0)
	if _time > _next_shine:
		_shine_start = _time
		_next_shine = _time + _rng.randf_range(7.0, 10.0)
	_update_shine()
	_sky_layer.queue_redraw()
	_water_layer.queue_redraw()
	_lamp_layer.queue_redraw()


# ------------------------------------------------------------ the wordmark
# HOLLOWTIDE as pixel art (Preston 2026-10-05: cool, unique, top centre). The
# menu font is drawn at the painting's own pixel size with smoothing off, then
# shown at 2x like everything else. Dark layers stacked under it give the
# letters depth. The face is sunset gold above a rolling tide line and teal
# water below it, so the name reads as the hollow and the tide. A pale band
# sweeps across it now and then, and a small wave ornament sits underneath.

const WORDMARK_SIZE := Vector2i(330, 84)   # art pixels
const WORDMARK_FONT_SIZE := 50
const WORDMARK_TOP := 6.0                  # art pixels from the top of the screen
const CAP_SHARE := 0.65                    # capital height / font size, measured for Alegreya Sans SC Bold
const DEPTH := [Color("#3d2a6e"), Color("#2e2058"), Color("#221844"), Color("#170f31")]
const RIM := Color("#120a26")
const MINT := Color("#7fe3d0")
const GOLD := Color("#ffd27a")

const FACE_SHADER := """
shader_type canvas_item;
uniform float cap_top = 0.0;
uniform float cap_bottom = 32.0;
uniform float tide_time = 0.0;
uniform float band_x = -1000.0;

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

void fragment() {
	if (COLOR.a < 0.5) { discard; }
	vec2 p = floor(VERTEX);
	float h = cap_bottom - cap_top;
	// The waterline sits below the middle and rolls in whole pixels.
	float water = floor(cap_top + h * 0.62 + 2.2 * sin(p.x * 0.07 + tide_time * 2.0) + 0.5);
	vec3 c;
	if (p.y < water) {
		// Sunset gold to coral in four flat bands, no smooth gradient.
		float k = floor(clamp((p.y - cap_top) / max(water - cap_top, 1.0), 0.0, 0.999) * 4.0) / 3.0;
		vec3 top = vec3(1.0, 0.96, 0.80);
		vec3 mid = vec3(1.0, 0.76, 0.43);
		vec3 low = vec3(0.98, 0.47, 0.47);
		c = k < 0.5 ? mix(top, mid, k * 2.0) : mix(mid, low, k * 2.0 - 1.0);
	} else if (p.y == water) {
		c = vec3(0.90, 1.0, 0.97);  // foam on the tide line, with the odd glint
		if (hash(vec2(floor(p.x / 3.0), floor(tide_time * 4.0))) > 0.88) { c = vec3(1.0); }
	} else {
		float k = floor(clamp((p.y - water) / max(cap_bottom - water, 1.0), 0.0, 0.999) * 3.0) / 2.0;
		c = mix(vec3(0.31, 0.84, 0.78), vec3(0.13, 0.30, 0.55), k);
		// Ripple highlights drift along under the surface.
		if (mod(p.y - water, 4.0) == 2.0 && sin(p.x * 0.35 - tide_time * 3.0 + p.y) > 0.7) {
			c = vec3(0.64, 0.96, 0.91);
		}
	}
	float d = abs(p.x - p.y * 0.6 - band_x);
	c = mix(c, vec3(1.0, 0.98, 0.92), d < 3.0 ? 0.6 : (d < 6.0 ? 0.25 : 0.0));
	COLOR = vec4(c, 1.0);
}
"""
var _wordmark: TextureRect
var _wordmark_home := Vector2.ZERO
var _face: Label
var _ornament: Node2D
var _ornament_y := 0.0
var _shine_start := -100.0
var _shine: ShaderMaterial


func _build_wordmark() -> void:
	if _title == null:
		return
	_title.visible = false  # the base title stays as the fallback, hidden
	var font: FontFile = (TITLE_FONT as FontFile).duplicate()
	font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	font.hinting = TextServer.HINTING_NONE
	font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	var vp := SubViewport.new()
	vp.name = "WordmarkCanvas"
	vp.size = WORDMARK_SIZE
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_ui.add_child(vp)
	var text_w: float = font.get_string_size("HOLLOWTIDE", HORIZONTAL_ALIGNMENT_LEFT, -1, WORDMARK_FONT_SIZE).x
	var at := Vector2(floorf((WORDMARK_SIZE.x - text_w) * 0.5), 2)
	# Depth: the deepest layer first, each one art pixel higher and lighter.
	for i in range(DEPTH.size() - 1, -1, -1):
		vp.add_child(_wordmark_label(font, at + Vector2(0, i + 1), DEPTH[i], 4))
	vp.add_child(_wordmark_label(font, at, RIM, 4))
	_face = _wordmark_label(font, at, Color.WHITE, 0)
	_shine = ShaderMaterial.new()
	_shine.shader = Shader.new()
	_shine.shader.code = FACE_SHADER
	var ascent: float = font.get_ascent(WORDMARK_FONT_SIZE)
	_shine.set_shader_parameter("cap_top", floorf(ascent - CAP_SHARE * WORDMARK_FONT_SIZE))
	_shine.set_shader_parameter("cap_bottom", ascent)
	_face.material = _shine
	vp.add_child(_face)
	_ornament_y = at.y + ascent + DEPTH.size() + 7
	_ornament = Node2D.new()
	_ornament.draw.connect(_draw_ornament)
	vp.add_child(_ornament)
	_wordmark = TextureRect.new()
	_wordmark.name = "Wordmark"
	_wordmark.texture = vp.get_texture()
	_wordmark.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_wordmark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_wordmark.stretch_mode = TextureRect.STRETCH_SCALE
	_wordmark.size = Vector2(WORDMARK_SIZE) * PX
	_wordmark.position = Vector2(roundf((1152.0 - WORDMARK_SIZE.x * PX) * 0.5), WORDMARK_TOP * PX)
	_wordmark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_wordmark)
	_wordmark_home = _wordmark.position
	_update_shine()


func _wordmark_label(font: Font, at: Vector2, color: Color, outline: int) -> Label:
	var label := Label.new()
	label.text = "HOLLOWTIDE"
	label.position = at
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", WORDMARK_FONT_SIZE)
	label.add_theme_color_override("font_color", color)
	if outline > 0:
		label.add_theme_constant_override("outline_size", outline)
		label.add_theme_color_override("font_outline_color", RIM)
	return label


## A small rolling wave between gold diamonds, under the name.
func _draw_ornament() -> void:
	var cx := float(WORDMARK_SIZE.x / 2)
	var phase := floorf(_time * STEPS) / STEPS
	for x in range(-44, 45):
		if absi(x) < 5:
			continue  # room for the centre diamond
		var y := roundf(sin(x * 0.42 - phase * 3.0))
		var p := Vector2(cx + x, _ornament_y + y)
		_ornament.draw_rect(Rect2(p + Vector2(0, 1), Vector2.ONE), RIM)
		_ornament.draw_rect(Rect2(p, Vector2.ONE), MINT)
	var diamond := [Vector2(0, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)]
	for c in [Vector2(cx - 50, _ornament_y), Vector2(cx, _ornament_y), Vector2(cx + 50, _ornament_y)]:
		for d in diamond:
			_ornament.draw_rect(Rect2(c + d + Vector2(0, 1), Vector2.ONE), RIM)
		for d in diamond:
			_ornament.draw_rect(Rect2(c + d, Vector2.ONE), GOLD)


func _update_shine() -> void:
	if _shine == null:
		return
	var t := (_time - _shine_start) / SHINE_SECONDS
	var x := -1000.0
	if t >= 0.0 and t <= 1.0:
		x = roundf(lerpf(-60.0, WORDMARK_SIZE.x + 40.0, t))
	_shine.set_shader_parameter("band_x", x)
	_shine.set_shader_parameter("tide_time", floorf(_time * STEPS) / STEPS)
	# The whole wordmark bobs by one art pixel, like the old title.
	_wordmark.position.y = _wordmark_home.y + roundf(sin(_time * 1.6)) * PX
	_ornament.queue_redraw()


func _build_characters() -> void:
	var courier := _menu_idle("CourierMenuIdle", "courier_idle_contrast_atlas.png", Vector2(300, 424), 2.4, 0.0, 3.0)
	var shadow := _menu_contact_shadow(Vector2(432, 448))
	var cinderhide := _menu_idle("CinderhideMenuIdle", "cinderhide_idle_dusk_lit_atlas.png", Vector2(432, 448), 3.2, 0.8)
	_walk_in(courier, "menu_courier_walk_atlas.png", Vector2(-126, 42), 0.8, 0.3)
	_walk_in(cinderhide, "menu_cinderhide_walk_atlas.png", Vector2(-136, 50), 0.96, 0.5, shadow)
	_update_menu_actors()

func _menu_contact_shadow(feet: Vector2) -> Node2D:
	# Two quiet, pixel-aligned footprints anchor the creature to the bluff.
	var shadow := Node2D.new()
	shadow.name = "CinderhideContactShadow"
	shadow.position = feet.round()
	add_child(shadow)
	var outer := Polygon2D.new()
	outer.name = "AmbientFootprint"
	outer.polygon = PackedVector2Array([
		Vector2(-66, -12), Vector2(-42, -20), Vector2(42, -22),
		Vector2(66, -16), Vector2(64, -10), Vector2(40, -2),
		Vector2(-12, 4), Vector2(-52, 0), Vector2(-66, -6)])
	outer.color = Color(0.20, 0.15, 0.18, 0.12)
	outer.antialiased = false
	shadow.add_child(outer)
	var inner := Polygon2D.new()
	inner.name = "ContactFootprint"
	inner.polygon = PackedVector2Array([
		Vector2(-56, -10), Vector2(-34, -16), Vector2(40, -18),
		Vector2(54, -14), Vector2(40, -6), Vector2(0, 0),
		Vector2(-42, -2), Vector2(-56, -6)])
	inner.color = Color(0.20, 0.15, 0.18, 0.18)
	inner.antialiased = false
	shadow.add_child(inner)
	return shadow

func _menu_idle(actor_name: String, file: String, feet: Vector2, cycle: float, phase: float, pixel_scale: float = PX) -> Sprite2D:
	var actor := Sprite2D.new()
	actor.name = actor_name
	actor.texture = load(IDLE_ART + file)
	actor.hframes = int(actor.texture.get_width() / float(IDLE_FRAME_SIZE))
	actor.centered = false
	actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	actor.scale = Vector2.ONE * pixel_scale
	var first := actor.texture.get_image().get_region(Rect2i(0, 0, IDLE_FRAME_SIZE, IDLE_FRAME_SIZE))
	var used := first.get_used_rect()
	# One fixed anchor for the full loop keeps the sprites on the path.
	actor.position = (feet - Vector2(used.position.x + used.size.x * 0.5, used.end.y) * pixel_scale).round()
	actor.set_meta("cycle", cycle)
	actor.set_meta("phase", phase)
	actor.set_meta("feet", feet)
	actor.set_meta("idle_texture", actor.texture)
	actor.set_meta("idle_home", actor.position)
	add_child(actor)
	_idle_actors.append(actor)
	# Drawn frames already contain breathing; no second deformation shader.
	return actor

func _walk_in(actor: Sprite2D, file: String, travel: Vector2, cycle: float, start: float, shadow: Node2D = null) -> void:
	var walk_texture: Texture2D = load(IDLE_ART + file)
	var first := walk_texture.get_image().get_region(Rect2i(0, 0, IDLE_FRAME_SIZE, IDLE_FRAME_SIZE))
	var used := first.get_used_rect()
	var feet: Vector2 = actor.get_meta("feet")
	var anchor := Vector2(used.position.x + used.size.x * 0.5, used.end.y)
	actor.set_meta("walk_texture", walk_texture)
	actor.set_meta("walk_home", (feet - anchor * actor.scale.x).round())
	actor.set_meta("travel", travel)
	actor.set_meta("walk_cycle", cycle)
	actor.set_meta("walk_start", start)
	actor.set_meta("walk_duration", cycle * 3.0)
	if shadow != null:
		actor.set_meta("contact_shadow", shadow)

func _process(delta: float) -> void:
	super._process(delta)
	if _reduce_motion:
		return
	_update_menu_actors()
	_update_life(delta)

func _update_menu_actors() -> void:
	# Arrival and drawn frames share the clock, so Reduce Motion freezes both.
	for actor in _idle_actors:
		var local_time: float = maxf(0.0, _time - float(actor.get_meta("walk_start")))
		var duration: float = actor.get_meta("walk_duration")
		var feet: Vector2 = actor.get_meta("feet")
		if local_time < duration:
			var travel: Vector2 = actor.get_meta("travel")
			var walk_texture: Texture2D = actor.get_meta("walk_texture")
			var gait: float = actor.get_meta("walk_cycle")
			var displacement := travel * (1.0 - local_time / duration)
			actor.texture = walk_texture
			actor.hframes = int(walk_texture.get_width() / float(IDLE_FRAME_SIZE))
			actor.frame = int(floor(fposmod(local_time, gait) / gait * actor.hframes))
			actor.position = (Vector2(actor.get_meta("walk_home")) + displacement).round()
			if actor.has_meta("contact_shadow"):
				var shadow: Node2D = actor.get_meta("contact_shadow")
				shadow.position = (feet + displacement).round()
		else:
			var idle_texture: Texture2D = actor.get_meta("idle_texture")
			var cycle: float = actor.get_meta("cycle")
			actor.texture = idle_texture
			actor.hframes = int(idle_texture.get_width() / float(IDLE_FRAME_SIZE))
			actor.frame = int(floor(fposmod(local_time - duration, cycle) / cycle * actor.hframes))
			actor.position = actor.get_meta("idle_home")
			if actor.has_meta("contact_shadow"):
				var shadow: Node2D = actor.get_meta("contact_shadow")
				shadow.position = feet.round()
