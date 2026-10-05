extends Node2D

## Oxbowarchon's Kingstone Rail after the release (Preston, 2026-09-29): the
## sphere of energy gathered between the rails IS the projectile. It carries all
## that energy, so it hits as a meteor, not a small slug.
##   1. The frames show the sphere firing up out of the rails.
##   2. Omen: the opponent trembles while a jade shadow spreads on the ground
##      under it, growing as the energy comes down.
##   3. Fall: the ball comes straight down from the top of the screen onto the
##      opponent as a meteor, trailing afterimages.
##   4. Impact: a white-green flash over the whole screen, a column of light
##      from the sky, the starburst and bloom, shockwave rings spreading out,
##      stone and energy debris thrown up, and an aftershock.
## (Preston, same day: no second small launch orb, since the frames already show
## the sphere leaving, and no re-gathering overhead, which read as the orb
## teleporting there and vanishing. `launch` and `gather` stay optional and are
## left empty for Kingstone Rail.)
## (Preston, 2026-09-30: signatures are ultimate moves, the creature's most
## powerful attack, and the hit has to look it. The meteor and impact were
## doubled in size and the omen, flash, light column, debris and aftershock
## were added.)
## Art: Preston's "Kingstone rail projectile 1-4" sheets, cut into
## assets/sprites/effects/oxbowarchon/kingstone_rail/ (see the README there).
## Every sprite is drawn at whole-number multiples of the creature's pixel size,
## and everything drawn here in code is built from whole art pixels too.
##
## Used as the move's signature_effect: the battle calls erupt() on the release
## frame, with start = the sphere's spot between the rails (the move's
## attack_river_offset), end = the opponent's feet and arrive = the seconds until
## the hit frame. It also sets target (the opponent's sprite, which this shakes)
## and shake (the screen shake).

## The sphere leaving the rails (drawn moving up, trail below).
@export var launch: Texture2D
## The energy gathering again overhead, in order (sparks, forming swirl, ball).
@export var gather: Array[Texture2D] = []
## The meteor coming down (drawn moving down, trail above).
@export var meteor: Texture2D
## The impact, in order (starburst, bloom).
@export var bursts: Array[Texture2D] = []
## The shockwave rings that spread and fade after the impact.
@export var rings: Texture2D
## The glowing core left burning where it hit, fading out last.
@export var core: Texture2D
## 16-frame jade burst (4x4). When set, it replaces the two still burst frames.
@export var impact_vfx: Texture2D
@export var impact_vfx_scale := 3
@export var launch_seconds := 0.28
@export var fall_seconds := 0.2
## Size of each stage as a multiple of the creature's pixel size (whole numbers).
@export var gather_scale := 2
@export var meteor_scale := 2
@export var burst_scale := 2
## Afterimages trailing the falling meteor.
@export var trail := 3
## The energy's colours, darkest to brightest (Oxbowarchon's own jade).
@export var palette: Array[Color] = [Color("#0c6c34"), Color("#1cbc4c"), Color("#84f49c"), Color("#d8fce0")]

const GATHER_TOP := 175.0

var target: Sprite2D
var shake: Callable

var _px := 3.0
var _feet := Vector2.ZERO
var _omen: Node2D  # the ground marker, freed the moment the meteor lands


func erupt(start: Vector2, end: Vector2, px: float, arrive: float, _sustain: float) -> void:
	_px = maxf(1.0, px)
	_feet = end
	if is_instance_valid(target):
		_feet.x = target.position.x  # the omen sits under the body, not one foot
	# The battle puts effects under the creatures; this plays in front of them.
	get_parent().move_child(self, -1)
	# Where it hits: the middle of the opponent's body (its sprite's centre),
	# so the impact is not half hidden behind the message box.
	var hit := end - Vector2(0, 14 * _px)
	if is_instance_valid(target):
		hit = target.position
	var fall_at: float = maxf(launch_seconds + 0.2, arrive - fall_seconds)
	_launch(start)
	_tremble(fall_at)
	_omen = UltimateImpact.omen(self, _feet, _px, arrive, palette)
	get_tree().create_timer(launch_seconds + 0.05).timeout.connect(
		_gather.bind(hit, fall_at - launch_seconds - 0.05))
	get_tree().create_timer(fall_at).timeout.connect(_fall.bind(hit))
	get_tree().create_timer(arrive + 2.4).timeout.connect(queue_free)


func _snap(pos: Vector2) -> Vector2:
	return (pos / _px).round() * _px


func _sprite(tex: Texture2D, pos: Vector2, scale_by: int) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale = Vector2.ONE * _px * scale_by
	s.position = _snap(pos)
	add_child(s)
	return s


## The charged sphere shoots up out of the rails and leaves the screen.
func _launch(start: Vector2) -> void:
	if launch == null:
		return
	var s := _sprite(launch, start, 1)
	var top: float = -launch.get_height() * _px
	var elapsed := 0.0
	while elapsed < launch_seconds:
		var k: float = elapsed / launch_seconds
		s.position = _snap(Vector2(start.x, lerpf(start.y, top, k * k)))
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	s.queue_free()


## High above the opponent the energy gathers again: sparks, a forming swirl,
## a ball, each held a moment, pulsing brighter as the fall gets close.
func _gather(hit: Vector2, seconds: float) -> void:
	if gather.is_empty() or seconds <= 0.05:
		return
	# Above the opponent but below the HP cards (they end about 130 px down).
	var at := Vector2(hit.x, maxf(GATHER_TOP, hit.y - 190.0))
	var g := _sprite(gather[0], at, gather_scale)
	var step: float = seconds / gather.size()
	for i in gather.size():
		g.texture = gather[i]
		g.modulate = Color(1.0, 1.0, 1.0, 1.0) if i % 2 == 0 else Color(1.25, 1.35, 1.25, 1.0)
		await get_tree().create_timer(step).timeout
	g.queue_free()


## The opponent shivers harder while the energy hangs overhead, then goes still
## for a breath just before it lands.
func _tremble(seconds: float) -> void:
	if not is_instance_valid(target):
		return
	var home: Vector2 = target.position
	var hush: float = minf(0.18, seconds * 0.25)
	var elapsed := 0.0
	var side := 1.0
	while elapsed < seconds - hush:
		var k: float = elapsed / maxf(0.01, seconds - hush)
		if is_instance_valid(target):
			target.position = home + Vector2(roundf(lerpf(0.0, 2.0, k)) * _px * side, 0)
		side = -side
		await get_tree().create_timer(0.05).timeout
		elapsed += 0.05
	if is_instance_valid(target):
		target.position = home


## The meteor crashes down with afterimages, then the impact plays.
func _fall(hit: Vector2) -> void:
	if meteor == null:
		return
	var h: float = meteor.get_height() * _px * meteor_scale
	# The meteor is drawn trail-up with the ball at the bottom; aim the ball at the hit.
	var land := hit - Vector2(0, h * 0.5 - meteor.get_width() * _px * meteor_scale * 0.5)
	var top := Vector2(hit.x, -h * 0.5)
	var s := _sprite(meteor, top, meteor_scale)
	var ghosts: Array[Sprite2D] = []
	for i in trail:
		var gh := _sprite(meteor, top, meteor_scale)
		gh.modulate = Color(0.8, 1.2, 1.0, 0.4 - 0.1 * i)
		ghosts.append(gh)
	move_child(s, -1)
	var elapsed := 0.0
	while elapsed < fall_seconds:
		var k: float = elapsed / fall_seconds
		s.position = _snap(Vector2(land.x, lerpf(top.y, land.y, k * k)))
		# The ball burns brighter the closer it gets.
		s.modulate = Color(1.0, 1.0, 1.0).lerp(Color(1.5, 1.6, 1.5), k)
		for i in ghosts.size():
			var gk: float = maxf(0.0, k - 0.12 * (i + 1))
			ghosts[i].position = _snap(Vector2(land.x, lerpf(top.y, land.y, gk * gk)))
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	s.queue_free()
	for gh in ghosts:
		gh.queue_free()
	_impact(hit)


## The hit itself, layered so it reads as a creature's most powerful attack.
func _impact(hit: Vector2) -> void:
	if is_instance_valid(_omen):
		_omen.queue_free()
	if shake.is_valid():
		shake.call(60)
	UltimateImpact.flash(self, palette[3])
	UltimateImpact.column(self, hit.x, hit.y + 20.0 * _px, _px, palette)
	UltimateImpact.ring(self, rings, hit, _px, burst_scale)
	UltimateImpact.ring(self, rings, hit, _px, burst_scale, 5, 0.14)
	UltimateImpact.debris(self, hit, _px, [palette[1], palette[2], palette[3], Color("#3c342c")])
	# The aftershock: the ground heaves once more after the first blast.
	get_tree().create_timer(0.35).timeout.connect(func() -> void:
		if shake.is_valid():
			shake.call(18))
	if impact_vfx != null:
		var v := VfxSprite.new()
		v.texture = impact_vfx
		v.hframes = 4
		v.vframes = 4
		v.fps = 16.0
		v.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		v.scale = Vector2.ONE * _px * impact_vfx_scale
		v.position = _snap(hit)
		add_child(v)
	# Starburst, then the bloom swelling one size, then the burning core.
	# The sheet above takes this beat when it is set.
	var holds := [0.16, 0.22]
	if impact_vfx != null:
		await get_tree().create_timer(0.7).timeout
	else:
		for i in bursts.size():
			var b := _sprite(bursts[i], hit, burst_scale)
			if i == 1:
				# The bloom swells by whole sizes, stepped, not smoothly.
				await get_tree().create_timer(holds[1] * 0.5).timeout
				b.scale = Vector2.ONE * _px * (burst_scale + 1)
				await get_tree().create_timer(holds[1] * 0.5).timeout
			else:
				await get_tree().create_timer(holds[mini(i, holds.size() - 1)]).timeout
			b.queue_free()
	if core != null:
		var c := _sprite(core, hit, burst_scale)
		var fade := create_tween()
		fade.tween_property(c, "modulate:a", 0.0, 0.5).set_delay(0.15)
		fade.tween_callback(c.queue_free)
