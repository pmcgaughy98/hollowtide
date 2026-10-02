extends Node2D

## Vitrecrag's signature, Molten Glass as a core meltdown (Preston, 2026-09-28):
## like a foundry crucible tipping over. Once the river of glass reaches the
## target, it bursts into a sheet that floods the ground around and past the
## target, lit white-hot as it lands, while embers rise across the whole screen.
## It lingers, then cools from the source end into crust and fades.
##
## The battle dims and relights the scene around it (MoveData signature fields);
## this node only draws the flood (glass_flood.gdshader) and the embers.
## Call erupt() once; it frees itself when it has cooled.

const FLOOD_SHADER = preload("res://scripts/effects/glass_flood.gdshader")
const HOT := Color("#fcc870")
const BRIGHT := Color("#fc9c4c")
const ORANGE := Color("#fc7424")
const EMBER := Color("#9c3414")
const SMOKE := Color("#4a3a44")
const PALE := Color("#fcdca4")
const FIRE: Array[Color] = [EMBER, ORANGE, BRIGHT, PALE]

## Half-width of the flood at the target, and how far it runs past, in art pixels.
@export var max_spread := 34.0
@export var reach := 40.0
@export var swell_seconds := 0.7
## How long the flood stays molten after the pour stops.
@export var linger_seconds := 1.2
@export var cool_seconds := 1.4
@export var embers_per_second := 70.0
## Drawn pieces from Preston's meltdown effect sheet (2026-09-28): the curling
## lip that leads the flood as it surges out, and the cooled crust left under
## the target as the glass hardens.
@export var wave_lip: Texture2D
@export var crust: Texture2D

@export_group("Ultimate Impact")
## The hit, at the Kingstone Rail bar (Preston, 2026-09-30: signatures are
## ultimate moves). While the river crawls out, the ground under the target
## glows hotter and wider (the omen). When it lands: a white-gold flash over
## the whole screen, a geyser of molten glass blasting up to the sky, the
## explosion, the molten crown bursting up around the target,
## fire rings racing out across the ground, glass globs and slag thrown up,
## the hardest shake and an aftershock. The flood then spreads as before.
@export var burst: Texture2D        ## the explosion at the target (molten_cannon/proj_f01)
## The explosion as an animated Retro Diffusion VFX sheet (4x4 frames). When
## set it replaces `burst` and the drawn crown (2026-10-01: VFX lead now).
@export var impact_vfx: Texture2D
@export var impact_vfx_scale := 3
@export var crown_burst: Texture2D  ## the molten crown bursting up (meltdown/crown)
@export var splash: Texture2D       ## the crown falling back (meltdown/splash_crown)
@export var ground_ring: Texture2D  ## a flat fire ring on the ground (furnace_roar/f5)
@export var globs: Array[Texture2D] = []  ## glass globs thrown up as debris
@export var burst_scale := 3

var _sheet: ColorRect
var _mat: ShaderMaterial
var _embers: Node2D
var _px := 3.0
var _a := Vector2.ZERO
var _b := Vector2.ZERO
var _arrive := 0.3
var _sustain := 1.0
var _time := -1.0
var _debt := 0.0
var _lip: Sprite2D
var _crust: Sprite2D
## Set by the battle: the opponent's sprite and the screen shake.
var target: Sprite2D
var shake: Callable
## The impact draws over the creatures, so it lives in its own node on the stage.
var _front: Node2D
var _omen: Node2D
# Each ember: [stage position, velocity, age, lifetime]
var _parts: Array = []


## start and end are stage positions (the pour and the target's feet); px is one
## art pixel on screen. The flood starts arrive seconds from now, when the river
## lands, and stays molten through sustain plus linger_seconds.
## Redraws per second: the effect simulates every frame but is drawn on twos
## (30 a second), so it moves in steps like drawn frames (Gemini VFX research,
## 2026-09-29: animate on twos or threes).
const DRAW_FPS := 30.0
var _redraw_clock := 0.0

func erupt(start: Vector2, end: Vector2, px: float, arrive: float, sustain: float) -> void:
	_px = maxf(1.0, px)
	_a = start
	_b = end
	_arrive = maxf(0.05, arrive)
	_sustain = maxf(0.0, sustain)
	_time = 0.0
	_mat = ShaderMaterial.new()
	_mat.shader = FLOOD_SHADER
	_sheet = ColorRect.new()
	_sheet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sheet.position = Vector2(-60, -60)
	_sheet.size = Vector2(1272, 768)
	_sheet.material = _mat
	add_child(_sheet)
	_mat.set_shader_parameter("px", _px)
	_mat.set_shader_parameter("a", _a)
	_mat.set_shader_parameter("b", _b)
	_mat.set_shader_parameter("origin", _sheet.position)
	_mat.set_shader_parameter("rect_size", _sheet.size)
	_mat.set_shader_parameter("spread", 0.0)
	# The drawn lip and crust sit on the flood, under the creatures like it.
	# The lip is drawn breaking to the left; mirror it when the flood runs right.
	for pair in [["_lip", wave_lip], ["_crust", crust]]:
		if pair[1] == null:
			continue
		var s := Sprite2D.new()
		s.texture = pair[1]
		s.scale = Vector2.ONE * _px
		s.visible = false
		s.flip_h = pair[0] == "_lip" and _b.x > _a.x
		add_child(s)
		set(pair[0], s)
	# Embers rise over the creatures, so they draw last in the stage, not here.
	_embers = Node2D.new()
	_embers.draw.connect(_draw_embers)
	get_parent().add_child.call_deferred(_embers)
	_front = Node2D.new()
	_front.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	get_parent().add_child(_front)
	_omen = UltimateImpact.omen(_front, _b, _px, _arrive, FIRE)
	get_tree().create_timer(_arrive).timeout.connect(_impact)
	get_tree().create_timer(_arrive + 3.0).timeout.connect(_front.queue_free)


func _process(delta: float) -> void:
	if _time < 0.0:
		return
	_time += delta
	var since: float = _time - _arrive
	var molten_until: float = _sustain + linger_seconds
	var spread := 0.0
	var cool := 0.0
	var fade := 1.0
	if since > 0.0:
		# Surges out past its size, then settles back, like a spill hitting the floor.
		var t: float = clampf(since / swell_seconds, 0.0, 1.0)
		var surge: float = 1.0 - pow(1.0 - t, 3.0)
		spread = max_spread * (surge + 0.15 * sin(t * PI))
		spread *= 1.0 + 0.03 * sin(_time * 2.5)
		cool = clampf((since - molten_until) / cool_seconds, 0.0, 1.0)
		fade = 1.0 - clampf((cool - 0.6) / 0.4, 0.0, 1.0)
		_mat.set_shader_parameter("reach", reach * surge)
		_mat.set_shader_parameter("glow", clampf(1.0 - since / 0.35, 0.0, 1.0))
	_mat.set_shader_parameter("spread", spread)
	_mat.set_shader_parameter("cool", cool)
	_mat.set_shader_parameter("fade", fade)
	_place_pieces(since, cool, fade)

	if spread > 0.0 and cool < 0.5:
		_debt += embers_per_second * delta * (1.0 - cool * 2.0)
		while _debt >= 1.0:
			_debt -= 1.0
			_spawn_ember(spread)
	var alive: Array = []
	for p in _parts:
		p[2] += delta
		if p[2] < p[3]:
			var v: Vector2 = p[1]
			v.x += sin(p[2] * 5.0 + p[0].y * 0.05) * 30.0 * delta  # drifting in the heat
			p[1] = v
			p[0] += v * delta
			alive.append(p)
	_parts = alive
	if is_instance_valid(_embers):
		_redraw_clock += delta
		if _redraw_clock >= 1.0 / DRAW_FPS:
			_redraw_clock = fmod(_redraw_clock, 1.0 / DRAW_FPS)
			_embers.queue_redraw()
	if since > molten_until + cool_seconds:
		if is_instance_valid(_embers):
			_embers.queue_free()
		queue_free()


## The lip rides the flood's leading edge while it surges out, standing on the
## flood line; the crust fades in under the target as the glass cools. Both
## snap to the art-pixel grid so they line up with the flood's squares.
func _place_pieces(since: float, cool: float, fade: float) -> void:
	var dir: Vector2 = (_b - _a).normalized()
	if _lip:
		var showing: bool = since > 0.0 and since < swell_seconds + 0.5
		_lip.visible = showing
		if showing:
			var t: float = clampf(since / swell_seconds, 0.0, 1.0)
			var front: Vector2 = _b + dir * reach * _px * (1.0 - pow(1.0 - t, 3.0))
			front.y -= _lip.texture.get_height() * _px * 0.5  # stand on the flood
			_lip.position = (front / _px).round() * _px
			_lip.modulate.a = 1.0 - clampf((since - swell_seconds) / 0.5, 0.0, 1.0)
	if _crust:
		var shown: float = clampf((cool - 0.2) / 0.3, 0.0, 1.0) * fade
		_crust.visible = shown > 0.0
		var at: Vector2 = _b - Vector2(0, _crust.texture.get_height() * _px * 0.3)
		_crust.position = (at / _px).round() * _px
		_crust.modulate.a = shown


func _spawn_ember(spread: float) -> void:
	# Anywhere on the flood, weighted toward the pool around the target.
	var t: float = sqrt(randf())
	var along: Vector2 = _a.lerp(_b + (_b - _a).normalized() * reach * _px * 0.6, t)
	var off := Vector2(randf_range(-1.0, 1.0), randf_range(-0.5, 0.5)) * spread * _px * t
	var speed := randf_range(40.0, 140.0) * (_px / 3.0)
	_parts.append([along + off, Vector2(randf_range(-10, 10), -speed), 0.0, randf_range(0.8, 2.0)])


func _draw_embers() -> void:
	for p in _parts:
		var t: float = p[2] / p[3]
		var c: Color
		if t < 0.3:
			c = HOT
		elif t < 0.55:
			c = BRIGHT
		elif t < 0.75:
			c = ORANGE
		elif t < 0.9:
			c = EMBER
		else:
			c = SMOKE
		c.a = 1.0 - maxf(0.0, t - 0.8) / 0.2
		var cell: Vector2 = (p[0] / _px).floor() * _px
		_embers.draw_rect(Rect2(cell, Vector2(_px, _px)), c)


## The river has reached the target: everything at once, then the flood.
func _impact() -> void:
	if not is_instance_valid(_front):
		return
	if is_instance_valid(_omen):
		_omen.queue_free()
	if shake.is_valid():
		shake.call(60)
	var hit: Vector2 = target.position if is_instance_valid(target) else _b - Vector2(0, 14.0 * _px)
	UltimateImpact.flash(_front, PALE)
	# The geyser: molten glass blasting from the ground up past the top of the screen.
	UltimateImpact.column(_front, _b.x, _b.y, _px, FIRE, 18.0)
	UltimateImpact.ring(_front, ground_ring, _b, _px, burst_scale, 5)
	UltimateImpact.ring(_front, ground_ring, _b, _px, burst_scale, 5, 0.14)
	UltimateImpact.debris(_front, _b - Vector2(0, 6.0 * _px), _px, [ORANGE, BRIGHT, HOT, SMOKE], 26, globs, 2)
	get_tree().create_timer(0.35).timeout.connect(func() -> void:
		if shake.is_valid():
			shake.call(18))
	# The explosion at the body, then the crown of glass bursting up from the
	# ground around it, swelling one size, then falling back as a splash.
	if impact_vfx != null:
		var v := VfxSprite.new()
		v.texture = impact_vfx
		v.hframes = 4
		v.vframes = 4
		v.fps = 20.0
		v.scale = Vector2.ONE * _px * impact_vfx_scale
		v.position = (hit / _px).round() * _px
		_front.add_child(v)
		await get_tree().create_timer(0.3).timeout
	elif burst != null:
		var b := _piece(burst, hit, burst_scale + 1)
		await get_tree().create_timer(0.14).timeout
		b.queue_free()
	if crown_burst != null and impact_vfx == null:
		# The crown stands on the ground, so it reaches up; one size smaller than
		# the burst keeps it below the HP card.
		var c := _piece(crown_burst, _b, burst_scale - 1, true)
		await get_tree().create_timer(0.32).timeout
		c.queue_free()
	if splash != null:
		var sp := _piece(splash, _b, burst_scale - 1, true)
		var fade := create_tween()
		fade.tween_property(sp, "modulate:a", 0.0, 0.4).set_delay(0.15)
		fade.tween_callback(sp.queue_free)


## A drawn piece on the front node at whole-number size. `grounded` stands it on
## `at` (its bottom edge on the floor line) instead of centring it there.
func _piece(tex: Texture2D, at: Vector2, scale_by: int, grounded := false) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex
	s.scale = Vector2.ONE * _px * scale_by
	if grounded:
		s.offset.y = -tex.get_height() * 0.5
	s.position = (at / _px).round() * _px
	_front.add_child(s)
	return s
