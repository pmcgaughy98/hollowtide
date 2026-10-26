extends Node2D
## The cold open, before the soul's choice (Claude, 2026-10-10; Preston: "it feels weird to just jump into
## the action. Maybe you see the soul float down in the riverbank picture as the map goes grey and time
## stops. Before it, it was storming like crazy as the river is about to flood").
##
## On the waking riverbank (Codex's waking_native.png, through his finish), before the ruin has risen
## (the river cover from scripts/ui/hollow_rise.gd hides it): a storm at night, rain driven slantwise,
## lightning and thunder, the river high. Then a sharp still: the rain hangs where it is, sound drops away,
## the picture drains to grey. A small light, the only colour left, floats down through the frozen rain to
## the spot where the creature will wake. It brightens to white, and the soul's prologue begins (the
## presence speaks, the choice is made), then the waking, the rise and the Hollow Mouth, as before.
## Two released advance presses skip. Sounds load when present (assets/audio/sfx/story/).

const UI := preload("res://scripts/ui/ui_style.gd")
const Bank := preload("res://scripts/ui/waking_bank.gd")
const Rise := preload("res://scripts/ui/hollow_rise.gd")
const NEXT := "res://scenes/soul_prologue.tscn"
const WAKE_AT := Vector2(168, 80)           # where the waking scene lays the creature down
const SFX := "res://assets/audio/sfx/story/%s.wav"

var reduce_motion := false
var grey := 0.0                             # 0 the storm's colour, 1 time stopped
var flash := 0.0                            # lightning
var frozen := false
var soul_at := Vector2(150, -14)
var soul_glow := 0.0                        # 0 hidden, 1 shown, up to 3 as it flares
var white := 0.0
var leaving := false
var _t := 0.0
var _drops: Array = []                      # {p, len}
var _splashes: Array = []                   # {p, life}
var _wind := 1.0
var _rain_player: AudioStreamPlayer
var world: SubViewport
var lights: SubViewport
var display: Sprite2D
var rain: Node2D
var soul: Node2D
var _skip_armed := false
var _skip_released := false
var _skip_hint: Label


func _ready() -> void:
	# Respect both the title handoff and direct entry with the saved accessibility preference.
	reduce_motion = reduce_motion or UI.reduce_motion()
	get_tree().root.content_scale_size = Vector2i(1152, 648)
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	world = _view()
	var bank := Bank.new()
	bank.show_actor_shadows = false
	world.add_child(bank)
	# The ruin has not risen yet: the river cover, held at its start.
	var cover := Rise.new()
	cover.source = bank.background.texture.get_image()
	cover.finish = bank.background.material
	world.add_child(cover)
	rain = Node2D.new()
	rain.z_index = 10
	rain.draw.connect(_draw_rain)
	world.add_child(rain)
	display = _show(world)
	var sh := Shader.new()
	sh.code = """shader_type canvas_item;
uniform float grey = 0.0;
uniform float flash = 0.0;
uniform vec3 night = vec3(0.42, 0.48, 0.68);   // the storm at night (Codex's finish ignores canvas tints)
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	c.rgb *= night;
	float l = dot(c.rgb, vec3(0.3, 0.59, 0.11)) * 1.25;
	vec3 g = mix(c.rgb, vec3(l * 0.92 + 0.04), grey);
	COLOR = vec4(mix(g, vec3(1.0), flash), c.a);
}"""
	var mat := ShaderMaterial.new()
	mat.shader = sh
	display.material = mat
	# The soul in its own layer, so the grey never touches it.
	lights = _view(true)
	soul = Node2D.new()
	soul.draw.connect(_draw_soul)
	lights.add_child(soul)
	_show(lights)
	for k in 340:
		_drops.append({"p": Vector2(randf() * 420.0 - 20.0, randf() * 216.0), "len": 4.0 + randf() * 4.0})
	var hint_layer := CanvasLayer.new()
	hint_layer.layer = 2
	add_child(hint_layer)
	_skip_hint = Label.new()
	_skip_hint.name = "SkipHint"
	_skip_hint.position = Vector2(24, 600)
	_skip_hint.size = Vector2(1104, 30)
	_skip_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_skip_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_skip_hint.add_theme_font_override("font", UI.font("label"))
	_skip_hint.add_theme_font_size_override("font_size", UI.type_size("label"))
	_skip_hint.add_theme_color_override("font_color", Color(UI.TEXT, 0.8))
	_skip_hint.add_theme_color_override("font_shadow_color", Color.BLACK)
	_skip_hint.add_theme_constant_override("shadow_offset_x", 2)
	_skip_hint.add_theme_constant_override("shadow_offset_y", 2)
	hint_layer.add_child(_skip_hint)
	_rain_player = _sfx("storm_rain", -6.0, true)
	_run()


func _view(transparent := false) -> SubViewport:
	var v := SubViewport.new()
	v.size = Vector2i(384, 216)
	v.transparent_bg = transparent
	v.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	v.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	add_child(v)
	return v


func _show(v: SubViewport) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = v.get_texture()
	s.centered = false
	s.scale = Vector2.ONE * 3
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(s)
	return s


func _run() -> void:
	var tree := get_tree()
	var fade := ColorRect.new()
	fade.size = Vector2(1152, 648)
	fade.color = Color.BLACK
	var layer := CanvasLayer.new()
	add_child(layer)
	layer.add_child(fade)
	var tw := create_tween()
	tw.tween_property(fade, "color:a", 0.0, 0.4 if reduce_motion else 1.4)
	await tw.finished
	# The storm: three strikes, the wind building.
	for strike in [1.4, 1.9, 1.2]:
		await tree.create_timer(strike).timeout
		if leaving:
			return
		await _lightning()
	await tree.create_timer(0.4 if reduce_motion else 1.0).timeout
	# Time stops.
	frozen = true
	_sfx("time_stop", -4.0)
	if _rain_player != null:
		create_tween().tween_property(_rain_player, "volume_db", -60.0, 0.3)
	tw = create_tween()
	tw.tween_method(func(v: float) -> void: grey = v, 0.0, 1.0, 0.2 if reduce_motion else 0.7)
	await tw.finished
	await tree.create_timer(0.3 if reduce_motion else 1.0).timeout
	# The soul comes down.
	_sfx("soul_descend", -6.0)
	tw = create_tween()
	tw.tween_property(self, "soul_glow", 1.0, 0.6)
	await tw.finished
	tw = create_tween()
	tw.tween_property(self, "soul_at", WAKE_AT, 1.5 if reduce_motion else 4.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
	await tree.create_timer(0.3 if reduce_motion else 0.8).timeout
	tw = create_tween().set_parallel()
	tw.tween_property(self, "soul_glow", 3.0, 0.9)
	tw.tween_property(self, "white", 1.0, 1.0).set_delay(0.3)
	await tw.finished
	_next()


func _lightning() -> void:
	if reduce_motion or UI.reduce_motion():
		flash = 0.4   # one soft pulse; the shared fade below lasts 0.35 seconds
	else:
		for k in 2:
			flash = 0.85
			await get_tree().create_timer(0.06).timeout
			flash = 0.15
			await get_tree().create_timer(0.07).timeout
	var tw := create_tween()
	tw.tween_property(self, "flash", 0.0, 0.35)
	_wind = 1.6
	await get_tree().create_timer(0.35).timeout
	_sfx("thunder", -2.0)


func _process(delta: float) -> void:
	_t += delta
	_skip_hint.visible = not leaving and (_skip_armed or _t >= 4.0)
	if _skip_hint.visible:
		var keys := PackedStringArray()
		for action in UI.INPUT_ADVANCE:
			var binding := UI.binding_text(action)
			if binding != "" and not keys.has(binding): keys.append(binding)
		_skip_hint.text = "%s  %s" % [" / ".join(keys), "Press again to skip" if _skip_armed else "Skip"]
	if not frozen:
		_wind = lerpf(_wind, 1.0 + 0.3 * sin(_t * 0.7), delta)
		for d in _drops:
			d["p"] += Vector2(-110.0 * _wind, 330.0) * delta
			if d["p"].y > 216.0 or d["p"].x < -20.0:
				if d["p"].y > 90.0 and randf() < 0.35:
					_splashes.append({"p": Vector2(d["p"].x, minf(d["p"].y, 214.0)), "life": 0.18})
				d["p"] = Vector2(randf() * 440.0, -randf() * 30.0)
		for s in _splashes:
			s["life"] -= delta
		_splashes = _splashes.filter(func(s: Dictionary) -> bool: return s["life"] > 0.0)
	display.material.set_shader_parameter("grey", grey)
	display.material.set_shader_parameter("flash", flash)
	rain.queue_redraw()
	soul.queue_redraw()


func _draw_rain() -> void:
	var slant := Vector2(-110.0 * _wind, 330.0).normalized()
	for d in _drops:
		var a: Vector2 = d["p"]
		rain.draw_line(a.round(), (a - slant * float(d["len"])).round(), Color(0.86, 0.92, 1.0, 0.85), 1.0)
	for s in _splashes:
		rain.draw_rect(Rect2(s["p"].round() + Vector2(-1, 0), Vector2(3, 1)), Color(0.85, 0.9, 1.0, 0.6))


func _draw_soul() -> void:
	if soul_glow > 0.0:
		var bob := Vector2(sin(_t * 1.7) * 3.0, sin(_t * 2.3) * 1.0)
		var at := (soul_at + bob).round()
		var k := minf(soul_glow, 1.0)
		var big := maxf(soul_glow - 1.0, 0.0)
		soul.draw_circle(at, 12.0 + big * 14.0, Color(0.75, 0.85, 1.0, 0.10 * k))
		soul.draw_circle(at, 7.0 + big * 8.0, Color(0.85, 0.92, 1.0, 0.25 * k))
		soul.draw_circle(at, 4.0 + big * 4.0, Color(0.95, 0.97, 1.0, 0.6 * k))
		soul.draw_circle(at, 2.0 + big * 2.0, Color(1.0, 1.0, 1.0, k))
	if white > 0.0:
		soul.draw_rect(Rect2(0, 0, 384, 216), Color(1, 1, 1, white))


func _unhandled_input(event: InputEvent) -> void:
	if leaving: return
	# Centre events match no pressed action, but must reset the shared stick-edge state.
	if event is InputEventJoypadMotion: UI._motion_edge(event)
	var advance := false
	for action in UI.INPUT_ADVANCE:
		if UI.pressed(event, action): advance = true
	if advance:
		if _skip_armed and _skip_released:
			_next()
		else:
			_skip_armed = true
			_skip_released = false
		get_viewport().set_input_as_handled()
	elif _skip_armed:
		for action in UI.INPUT_ADVANCE:
			if event.is_action_released(action):
				_skip_released = true
				get_viewport().set_input_as_handled()


func _next() -> void:
	if leaving:
		return
	leaving = true
	var scene: Node = load(NEXT).instantiate()
	scene.set("reduce_motion", reduce_motion)
	if is_inside_tree() and get_tree().current_scene == self:
		get_tree().change_scene_to_node(scene)
	else:
		set_meta("next", NEXT)   # the check reads this instead of leaving the scene
		scene.free()


func _sfx(name: String, db: float, loop := false) -> AudioStreamPlayer:
	if not ResourceLoader.exists(SFX % name):
		return null
	var p := AudioStreamPlayer.new()
	var stream: AudioStream = load(SFX % name)
	if loop and stream is AudioStreamWAV:
		stream = stream.duplicate()
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = int(stream.get_length() * stream.mix_rate)
	p.stream = stream
	p.volume_db = db
	p.bus = &"SFX"   # the storm's world sounds on the effects slider (FEEL-08; Claude, 2026-10-22)
	add_child(p)
	p.play()
	if not loop:
		p.finished.connect(p.queue_free)
	return p
