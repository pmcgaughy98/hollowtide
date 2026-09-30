extends Node2D

## Ironvent's Furnace Roar as a self-destructive signature (Preston, 2026-09-29):
## it vents so much heat and pressure that the battlefield itself erupts. Heat
## geysers burst out of the ground around Ironvent and then advance across the
## field toward the opponent, with firework bursts of sparks popping all over
## the scene. The ground under the opponent starts to hiss while the opponent
## shakes harder and harder, then a held breath of silence, then the big one:
## a much bigger geyser bursting out of the ground under the opponent and
## blasting on and on like a beam (Preston: a geyser, beamlike in how it erupts
## and how long it lasts, not a literal ray), sparking, flashing and shaking
## until it sinks back into the ground and smokes. Art from Preston's
## "blast furnace blowdown candidate 3" sheet (assets/sprites/effects/ironvent/field/).
##
## Used as the move's signature_effect: the battle calls erupt(). Before that it
## sets target (the opponent's sprite, which this shakes), source_feet (where
## Ironvent stands) and shake (the battle's screen shake), when present.

@export var charge: Texture2D
@export var geyser: Texture2D
@export var smoke: Texture2D
@export var fireworks: Texture2D
## The big one: a larger, longer version of the field geyser (built from it),
## erupting under the opponent and blasting for a sustained stretch like a beam.
@export var eruption: Texture2D
@export var eruption_alt: Texture2D
## The heat ring from Preston's first Furnace Roar effect sheet (F5 to F8): it
## bursts out around the giant geyser's base, breaks apart and fades to haze.
@export var ring_frames: Array[Texture2D] = []
const RING_SECONDS: Array[float] = [0.14, 0.14, 0.2, 0.22]
const RING_CENTRE_OFFSET := Vector2(-9, 1)  # the ring's middle sits 9 px right of its cell centre
## Seconds the geysers take to advance from Ironvent to the opponent.
@export var field_seconds := 1.3
@export var geysers := 18
@export var firework_bursts := 16
## How many fault lines the field geysers bunch along.
const CLUSTERS := 4
## Where the ground is on the battle stage (the banks and the riverbed), and the
## HUD panels to keep clear, in stage pixels.
@export var area := Rect2(40, 250, 1070, 215)
const HUD_CLEAR: Array[Rect2] = [
	Rect2(0, 0, 510, 130),      # the foe's card
	Rect2(650, 350, 500, 120),  # the player's card
	Rect2(0, 462, 1152, 190),   # the message box and commands
]

var target: Sprite2D
var source_feet := Vector2.ZERO
var shake: Callable

var _px := 3.0
var _end := Vector2.ZERO


func erupt(start: Vector2, end: Vector2, px: float, arrive: float, sustain: float) -> void:
	_px = maxf(1.0, px)
	_end = end
	if source_feet == Vector2.ZERO:
		source_feet = start + Vector2(0, 30 * _px)
	# Around Ironvent first: the ground right beside it gives way.
	_vent(source_feet + Vector2(-70, 6), 0.0)
	_vent(source_feet + Vector2(80, -4), 0.08)
	# Then the whole area goes off: eruptions radiate outward from Ironvent like
	# a shockwave through the ground, scattered across the battlefield (Preston:
	# a final-stage signature affects everything in a wide radius), leaving the
	# spot under the opponent calm for the finale.
	var spots: Array[Vector2] = _scatter(geysers)
	var farthest := 1.0
	for s in spots:
		farthest = maxf(farthest, s.distance_to(source_feet))
	for s in spots:
		var when: float = field_seconds * 0.9 * s.distance_to(source_feet) / farthest + randf_range(0.0, 0.12)
		_vent(s, when)
	# Fireworks burst over the erupting clusters, not evenly across the sky.
	for i in firework_bursts:
		var over: Vector2 = spots[randi() % spots.size()] if not spots.is_empty() else _end
		_firework(Vector2(over.x + randfn(0.0, 40.0), clampf(over.y - randf_range(90.0, 200.0), 40.0, area.position.y + 40.0)),
			randf_range(0.0, field_seconds + 0.4))
	_suspense(field_seconds, arrive)
	get_tree().create_timer(arrive).timeout.connect(_erupt_big.bind(maxf(0.8, sustain)))
	get_tree().create_timer(arrive + maxf(0.8, sustain) + 1.6).timeout.connect(queue_free)


## Ground spots across the area in clusters: a few fault lines give way, each
## erupting in a bunch, with calm ground between them. Evenly spread random
## spots read as computer-made; bunched ones read as placed (Gemini VFX
## research, 2026-09-29). Off the HUD, not on top of each other, and not too
## near the opponent's feet (the finale's spot) or Ironvent.
func _scatter(count: int) -> Array[Vector2]:
	var centres: Array[Vector2] = []
	var tries := 0
	while centres.size() < CLUSTERS and tries < 200:
		tries += 1
		var c := Vector2(randf_range(area.position.x, area.end.x), randf_range(area.position.y, area.end.y))
		if _blocked(c) or centres.any(func(q: Vector2) -> bool: return q.distance_to(c) < 220.0):
			continue
		centres.append(c)
	var spots: Array[Vector2] = []
	tries = 0
	while spots.size() < count and tries < count * 60 and not centres.is_empty():
		tries += 1
		var p: Vector2 = centres[randi() % centres.size()] + Vector2(randfn(0.0, 55.0), randfn(0.0, 22.0))
		if not area.has_point(p) or _blocked(p):
			continue
		if spots.any(func(q: Vector2) -> bool: return q.distance_to(p) < 42.0):
			continue
		spots.append(p)
	return spots


func _blocked(p: Vector2) -> bool:
	if HUD_CLEAR.any(func(r: Rect2) -> bool: return r.has_point(p)):
		return true
	return p.distance_to(_end) < 110.0 or p.distance_to(source_feet) < 60.0


## A sprite standing on the ground at pos (its bottom edge there), on the art grid.
func _stand(tex: Texture2D, pos: Vector2) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale = Vector2.ONE * _px
	s.offset = Vector2(0, -tex.get_height() * 0.5)
	s.position = (pos / _px).round() * _px
	s.flip_h = randf() < 0.5
	add_child(s)
	return s


## One ground vent: it hisses, erupts, then smokes.
func _vent(pos: Vector2, delay: float) -> void:
	await get_tree().create_timer(delay + 0.001).timeout
	var hiss := _stand(charge, pos)
	await get_tree().create_timer(0.22).timeout
	hiss.queue_free()
	var column := _stand(geyser, pos)
	if shake.is_valid():
		shake.call(10)
	var t := create_tween()
	t.tween_interval(0.35)
	for i in 3:
		t.tween_property(column, "visible", false, 0.0)
		t.tween_interval(0.04)
		t.tween_property(column, "visible", true, 0.0)
		t.tween_interval(0.04)
	await t.finished
	column.queue_free()
	var puff := _stand(smoke, pos)
	var rise := create_tween().set_parallel()
	rise.tween_property(puff, "position:y", puff.position.y - 10 * _px, 0.9)
	rise.tween_property(puff, "modulate:a", 0.0, 0.9).set_ease(Tween.EASE_IN)
	rise.finished.connect(puff.queue_free)


func _firework(pos: Vector2, delay: float) -> void:
	await get_tree().create_timer(delay + 0.001).timeout
	var s := Sprite2D.new()
	s.texture = fireworks
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale = Vector2.ONE * _px
	s.position = (pos / _px).round() * _px
	s.flip_h = randf() < 0.5
	add_child(s)
	var t := create_tween()
	t.tween_interval(0.25)
	t.tween_property(s, "modulate:a", 0.0, 0.3)
	t.finished.connect(s.queue_free)


## The ground under the opponent hisses, the opponent shakes harder and harder,
## then everything goes still for a held breath before the eruption.
func _suspense(from: float, arrive: float) -> void:
	await get_tree().create_timer(from).timeout
	var hisses: Array[Sprite2D] = []
	var span: float = arrive - from
	var hush: float = minf(0.2, span * 0.25)
	for i in 3:
		var h := _stand(charge, _end + Vector2((i - 1) * 26, 4 - abs(i - 1) * 6))
		h.visible = false
		hisses.append(h)
	var home: Vector2 = target.position if is_instance_valid(target) else Vector2.ZERO
	var elapsed := 0.0
	var side := 1.0
	while elapsed < span - hush:
		var k: float = elapsed / (span - hush)
		for i in hisses.size():
			# One more vent wakes each third of the way, all flickering faster.
			hisses[i].visible = k > i / 3.0 and int(elapsed / lerpf(0.12, 0.05, k)) % 2 == 0
		if is_instance_valid(target):
			var amp: float = roundf(lerpf(1.0, 3.0, k)) * _px
			target.position = home + Vector2(amp * side, 0)
			side = -side
		if shake.is_valid() and int(elapsed / 0.2) != int((elapsed - 0.04) / 0.2):
			shake.call(int(lerpf(4.0, 12.0, k)))
		await get_tree().create_timer(0.04).timeout
		elapsed += 0.04
	# The held breath.
	for h in hisses:
		h.queue_free()
	if is_instance_valid(target):
		target.position = home


## The heat ring bursting out along the ground around the giant geyser's base,
## at the geyser's size, drawn just under it.
func _ring_at_base() -> void:
	if ring_frames.is_empty():
		return
	var r := Sprite2D.new()
	r.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	r.scale = Vector2.ONE * _px * 2.0
	r.offset = RING_CENTRE_OFFSET
	r.position = (_end / _px).round() * _px
	get_parent().add_child(r)
	for i in ring_frames.size():
		r.texture = ring_frames[i]
		await get_tree().create_timer(RING_SECONDS[mini(i, RING_SECONDS.size() - 1)]).timeout
	r.queue_free()


## The big one: the giant geyser bursts out of the ground under the opponent,
## keeps erupting for the whole hit, then sinks back into the ground and smokes.
func _erupt_big(seconds: float) -> void:
	_ring_at_base()
	var b := _stand(eruption, _end)
	b.flip_h = false
	# It engulfs the opponent, so it draws over everything on the stage, at
	# double size (whole pixels) so it towers over the field geysers.
	b.reparent(get_parent())
	var full: float = _px * 2.0
	var top: float = eruption.get_height() * full
	# Bursts up out of the ground in a split second (it grows from its base).
	b.scale = Vector2(full, 0.0)
	create_tween().tween_property(b, "scale:y", full, 0.14).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	if shake.is_valid():
		shake.call(30)
	var elapsed := 0.0
	var i := 0
	while elapsed < seconds:
		b.texture = eruption if i % 2 == 0 else eruption_alt
		if i % 3 == 0:
			# Sparks keep bursting out of its crown.
			_firework(_end + Vector2(randf_range(-40, 40), -top * randf_range(0.75, 1.0)), 0.0)
			if shake.is_valid():
				shake.call(16)
		if is_instance_valid(target):
			target.self_modulate = Color(1.7, 1.3, 1.1) if i % 2 == 0 else Color.WHITE
		await get_tree().create_timer(0.06).timeout
		elapsed += 0.06
		i += 1
	if is_instance_valid(target):
		target.self_modulate = Color.WHITE
	# It sinks back into the ground, leaving smoke where it stood.
	var sink := create_tween()
	sink.tween_property(b, "scale:y", 0.0, 0.2).set_ease(Tween.EASE_IN)
	await sink.finished
	b.queue_free()
	for dx in [-24, 0, 24]:
		var puff := _stand(smoke, _end + Vector2(dx, 0))
		var rise := create_tween().set_parallel()
		rise.tween_property(puff, "position:y", puff.position.y - 14 * _px, 1.2)
		rise.tween_property(puff, "modulate:a", 0.0, 1.2).set_ease(Tween.EASE_IN)
		rise.finished.connect(puff.queue_free)
