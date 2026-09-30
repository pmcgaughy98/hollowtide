extends Node2D

## Fire behind a closed mouth, like a dragon full of flame (Vitrecrag's idle,
## Preston 2026-09-28), and what that heat does when the mouth opens.
##
## Lives as a child of the creature's battle sprite, so it rides the sprite's
## breathing scale and hit flash; coordinates are the sprite's own art pixels
## (from its centre, art facing right), so every square drawn is one art pixel.
##
## Moods:
##   FLAMES  idle. A seam along the closed mouth glows hotter on each exhale, and
##           flames spill out over the lips, then the heat lifts them up the
##           snout; each cools from pale gold to dark red into a wisp of smoke.
##           A bigger spill on every exhale.
##   AURA    during a molten attack. No flames: a dim flickering glow hugs the
##           opening and faint heat wisps drift up off it (and off the pour
##           below it), so everything bright on screen is the glass itself.
## gasp() is the moment the mouth opens: the trapped fire escapes in one rush of
## flame and sparks. resume_flames() closes the mouth again: a puff of smoke,
## then the flames come back gradually.
##
## The battle sets `facing` (-1 for a flipped sprite) and calls breathe() with
## the breath (-1 fully out, +1 fully in) while idle.

enum Mood { FLAMES, AURA }
enum Kind { LICK, WISP, SMOKE, SPARK }

## Mouth seam pixels, in art pixels from the sprite's centre, art facing right.
@export var seam: Array[Vector2i] = []
@export var trickle_per_second := 16.0
@export var billow_count := 28
## How hard fire is pushed out over the lips (forward, art pixels per second)
## and how much it first sags down before the heat lifts it.
@export var spill_speed := Vector2(12, 22)
@export var spill_sag := Vector2(0, 6)
## Upward pull that turns a spill into a rising lick (art pixels per second squared).
@export var buoyancy := 48.0
@export var gasp_count := 34
## Heat wisps per second at full aura strength.
@export var aura_wisps_per_second := 14.0

const HOT := Color("#fcc870")
const BRIGHT := Color("#fc9c4c")
const ORANGE := Color("#fc7424")
const DEEP := Color("#dc5c24")
const EMBER := Color("#9c3414")
const SMOKE := Color("#4a3a44")

var facing := 1.0
var active := true
## Set while an attack is steering this effect, so the battle does not hide it.
var attack_owned := false
var mood: int = Mood.FLAMES

var _breath := 0.0
var _was_exhaling := false
var _spawn_debt := 0.0
var _flame_ramp := 1.0  # 0..1, flames easing back in after the mouth closes
var _aura_center := Vector2.ZERO
var _aura_strength := 0.0
var _aura_column := 0.0  # art pixels of pour below the opening that also steams
var _time := 0.0
# Each particle: [position, velocity, age, lifetime, sway phase, kind]
var _parts: Array = []


## Redraws per second: the effect simulates every frame but is drawn on twos
## (30 a second), so it moves in steps like drawn frames (Gemini VFX research,
## 2026-09-29: animate on twos or threes).
const DRAW_FPS := 30.0
var _redraw_clock := 0.0

func breathe(value: float) -> void:
	_breath = value
	var exhaling: bool = value < -0.6
	if exhaling and not _was_exhaling and active and mood == Mood.FLAMES:
		for i in int(billow_count * _flame_ramp):
			_spawn_lick(true)
	_was_exhaling = exhaling


## The mouth opens: the trapped fire escapes in one rush, then the heat turns
## into an aura around `center` (the opening).
func gasp(center: Vector2) -> void:
	for i in gasp_count:
		_spawn_lick(true)
	for i in 10:
		_spawn_spark(Vector2(seam[randi() % seam.size()]) if not seam.is_empty() else center)
	set_aura(center, 0.5, 0.0)


## Switch to the heat aura. strength 0..1; column is how far down the pour from
## the opening also gives off heat.
func set_aura(center: Vector2, strength: float, column: float) -> void:
	mood = Mood.AURA
	_aura_center = center
	_aura_strength = clampf(strength, 0.0, 1.0)
	_aura_column = maxf(0.0, column)


## The mouth closes: a puff of smoke, then the spilling flames ease back in.
func resume_flames() -> void:
	for i in 8:
		var p: Vector2 = Vector2(seam[randi() % seam.size()]) if not seam.is_empty() else _aura_center
		_parts.append([p, Vector2(randf_range(2, 6), randf_range(-8, -4)), 0.0, randf_range(0.6, 1.0), randf() * TAU, Kind.SMOKE])
	mood = Mood.FLAMES
	_flame_ramp = 0.0


func _spawn_lick(billow: bool) -> void:
	if seam.is_empty():
		return
	# Anywhere along the seam; the corner of the mouth (the last pixels) spills most.
	var k: int = seam.size() - 1 - mini(seam.size() - 1, int(abs(randfn(0.0, seam.size() * 0.35))))
	var p := Vector2(seam[k]) + Vector2(randf_range(0.0, 1.0), randf_range(-0.5, 0.5))
	var push: float = 1.3 if billow else 1.0
	var v := Vector2(randf_range(spill_speed.x, spill_speed.y) * push, randf_range(spill_sag.x, spill_sag.y))
	var life: float = randf_range(0.7, 1.2) * (1.2 if billow else 1.0)
	_parts.append([p, v, 0.0, life, randf() * TAU, Kind.LICK])


func _spawn_spark(at: Vector2) -> void:
	_parts.append([at, Vector2(randf_range(4, 18), randf_range(-30, -14)), 0.0, randf_range(0.4, 0.7), 0.0, Kind.SPARK])


func _spawn_wisp() -> void:
	# Off the rim of the opening, or somewhere along the pour below it.
	# Rim wisps start on the edge of the ring, never inside the lava.
	var side: float = -1.0 if randf() < 0.5 else 1.0
	var angle: float = randf_range(PI * 1.1, PI * 1.9)  # upper half of the ring
	var p: Vector2 = _aura_center + Vector2(cos(angle), sin(angle)) * (_ring_radius() + 1.0)
	var v := Vector2(randf_range(-2, 2), randf_range(-9, -5))
	if _aura_column > 0.0 and randf() < 0.45:
		# Off the stream's edges, drifting sideways out of it as they rise.
		p = _aura_center + Vector2(side * randf_range(4, 6), randf_range(4, _aura_column))
		v = Vector2(side * randf_range(3, 6), randf_range(-8, -4))
	_parts.append([p, v, 0.0, randf_range(0.8, 1.4), randf() * TAU, Kind.WISP])


func _ring_radius() -> int:
	return 3 + int(round(_aura_strength * 3.0))


func _process(delta: float) -> void:
	_time += delta
	if mood == Mood.FLAMES and active:
		_flame_ramp = minf(1.0, _flame_ramp + delta)
		_spawn_debt += trickle_per_second * _flame_ramp * delta
		while _spawn_debt >= 1.0:
			_spawn_debt -= 1.0
			_spawn_lick(false)
	elif mood == Mood.AURA:
		_spawn_debt += aura_wisps_per_second * _aura_strength * delta
		while _spawn_debt >= 1.0:
			_spawn_debt -= 1.0
			_spawn_wisp()
			if randf() < 0.08 * _aura_strength:
				_spawn_spark(_aura_center)
	var alive: Array = []
	for part in _parts:
		part[2] += delta
		if part[2] >= part[3]:
			continue
		var v: Vector2 = part[1]
		match part[5]:
			Kind.LICK:
				v.x *= 1.0 - 1.6 * delta
				v.y -= buoyancy * delta
			Kind.SPARK:
				v.y += 20.0 * delta  # sparks arc
			_:
				v.y *= 1.0 - 0.3 * delta  # wisps and smoke drift and slow
		part[1] = v
		part[0] = (part[0] as Vector2) + v * delta + Vector2(sin(part[2] * 7.0 + part[4]) * 3.0 * delta, 0.0)
		alive.append(part)
	_parts = alive
	_redraw_clock += delta
	if _redraw_clock >= 1.0 / DRAW_FPS:
		_redraw_clock = fmod(_redraw_clock, 1.0 / DRAW_FPS)
		queue_redraw()


func _draw() -> void:
	if mood == Mood.FLAMES:
		# Seam: glows hotter the more fully the creature has breathed out.
		var heat: float = clampf(0.5 - 0.5 * _breath, 0.0, 1.0) * _flame_ramp
		var seam_color: Color = EMBER.lerp(HOT, heat) if active else EMBER
		for s in seam:
			_pixel(Vector2(s), seam_color)
	else:
		# Aura: a dim, flickering glow hugging the opening. Not flames.
		var r: int = _ring_radius()
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				var d: float = sqrt(dx * dx + dy * dy)
				if d > r or d < r - 2:
					continue  # only a rim, two pixels thick
				var flicker: float = 0.5 + 0.5 * sin(_time * 11.0 + dx * 1.7 + dy * 2.3)
				if flicker < 0.35:
					continue
				var c: Color = ORANGE if d < r - 1 else DEEP
				c.a = (0.3 + 0.4 * _aura_strength) * flicker
				_pixel(_aura_center + Vector2(dx, dy), c)
	for part in _parts:
		var t: float = part[2] / part[3]
		var p: Vector2 = part[0]
		match part[5]:
			Kind.LICK:
				var c: Color
				if t < 0.15:
					c = HOT
				elif t < 0.35:
					c = BRIGHT
				elif t < 0.55:
					c = ORANGE
				elif t < 0.7:
					c = DEEP
				elif t < 0.8:
					c = EMBER
				else:
					c = SMOKE
					c.a = 1.0 - (t - 0.8) / 0.2
				# Young flames: small tongues three pixels tall with a cooler flank.
				_pixel(p, c)
				if t < 0.55:
					_pixel(p + Vector2(0, 1), DEEP if t > 0.3 else BRIGHT)
				if t < 0.3:
					_pixel(p + Vector2(0, 2), ORANGE)
					_pixel(p + Vector2(1, 1), DEEP)
			Kind.WISP:
				# Heat haze: starts as a warm glow and cools to smoke as it rises,
				# so it never reads as a dark speck on the bright glass.
				var w: Color = ORANGE.lerp(EMBER, t * 2.0) if t < 0.5 else EMBER.lerp(SMOKE, t * 2.0 - 1.0)
				w.a = 0.6 * (1.0 - t)
				_pixel(p, w)
			Kind.SMOKE:
				var sc: Color = SMOKE
				sc.a = 0.8 * (1.0 - t)
				_pixel(p, sc)
			Kind.SPARK:
				_pixel(p, HOT if t < 0.5 else BRIGHT)


func _pixel(p: Vector2, c: Color) -> void:
	# One art pixel, snapped to the sprite's own grid and mirrored with it.
	var x: float = floorf(p.x) * facing
	if facing < 0.0:
		x -= 1.0
	draw_rect(Rect2(Vector2(x, floorf(p.y)), Vector2.ONE), c)
