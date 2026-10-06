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
## (Preston, 2026-09-30: signatures are ultimate moves and must hit like the
## Kingstone Rail landing. Added through scripts/effects/ultimate_impact.gd: a
## glowing ground marker under the opponent through the suspense, a white-gold
## flash over the whole screen, a geyser tall enough to blast off the top of
## the screen, a burst of sparks over the body, shockwave rings racing out,
## slag thrown up, the hardest shake and an aftershock.)
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
## 16-frame blast sheet (4x4). When set, it is the giant geyser. The two
## eruption frames stay as the fallback.
@export var geyser_vfx: Texture2D
@export var geyser_vfx_scale := 2
## The heat ring from Preston's first Furnace Roar effect sheet (F5 to F8): it
## bursts out around the giant geyser's base, breaks apart and fades to haze.
@export var ring_frames: Array[Texture2D] = []
const RING_SECONDS: Array[float] = [0.14, 0.14, 0.2, 0.22]
const RING_CENTRE_OFFSET := Vector2(-9, 1)  # the ring's middle sits 9 px right of its cell centre
## Optional: a glowing crack that splits the ground from the attacker to the
## opponent over field_seconds (Root Rampart). Transparent (the default) is off.
@export var crack_color := Color(0, 0, 0, 0)
## Optional: a foam wake that races across the surface from the attacker to the
## opponent over field_seconds, two barbel lines trailing it (Undertow). Off by default.
@export var wake_color := Color(0, 0, 0, 0)
## Seconds the geysers take to advance from Ironvent to the opponent.
@export var field_seconds := 1.3
@export var geysers := 24
@export var firework_bursts := 16
## How many fault lines the field geysers bunch along.
const CLUSTERS := 6
## Where the ground is on the battle stage (the banks and the riverbed), and the
## HUD panels to keep clear, in stage pixels.
@export var area := Rect2(40, 244, 1090, 214)
## Only the message box is kept clear. The HP cards are hidden for the whole
## signature, and keeping their spaces clear left the ground around and in
## front of Ironvent bare, so the field only ran toward the opponent
## (Preston, 2026-09-30).
const HUD_CLEAR: Array[Rect2] = [
	Rect2(0, 462, 1152, 190),   # the message box and commands
]
## The directions the fault lines open in, around Ironvent: toward the
## opponent, behind it, its near side (toward the camera), its far side
## (toward the horizon), and the two diagonals on the opponent's side. One
## cluster of geysers goes in each, so the eruption rings the creature.
## 0 is straight away from the opponent; PI is straight toward it.
const SECTORS: Array[float] = [PI, 0.0, PI * 0.5, -PI * 0.5, PI * 0.75, -PI * 0.75]
## How far a cluster can sit from Ironvent, across the screen and in depth.
## The ground is seen at a low angle, so depth is squashed.
const REACH := Vector2(520.0, 100.0)
var _mid: Node2D

var target: Sprite2D
var source_feet := Vector2.ZERO
var shake: Callable

var _px := 3.0
var _end := Vector2.ZERO
var _omen: Node2D
## The finale's added layers draw over the creatures, in their own node on the stage.
var _front: Node2D
## Size of the finale's geyser and burst, in whole multiples of the pixel size.
@export var finale_scale := 4
## The sizes the field geysers come in, as whole multiples of the pixel size;
## each geyser picks one at random. Ironvent is a final-stage creature, so most
## of its field is double or triple size with a few small ones for contrast
## (Preston, 2026-09-30: small same-size geysers read as a first-stage
## creature's power). A first or second stage would use [1] or [1, 1, 2].
@export var geyser_sizes: Array[int] = [1, 2, 2, 3, 3]
const FIRE: Array[Color] = [Color("#9c3414"), Color("#fc7424"), Color("#fc9c4c"), Color("#fcdca4")]


func erupt(start: Vector2, end: Vector2, px: float, arrive: float, sustain: float) -> void:
	_px = maxf(1.0, px)
	_end = end
	if source_feet == Vector2.ZERO:
		source_feet = start + Vector2(0, 30 * _px)
	# Around Ironvent first: the ground right beside it gives way.
	var biggest: int = geyser_sizes.max() if not geyser_sizes.is_empty() else 1
	_vent(source_feet + Vector2(-70, 6), 0.0, biggest)
	_vent(source_feet + Vector2(80, -4), 0.08, maxi(1, biggest - 1))
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
		var size: int = geyser_sizes.pick_random() if not geyser_sizes.is_empty() else 1
		# Depth: ground higher on the screen is farther away, so geysers there are
		# a size smaller; ones on Ironvent's near side stand in front of it, and
		# stay small enough close in that they do not hide it.
		var depth: float = s.y - source_feet.y
		if depth < -30.0:
			size = maxi(1, size - 1)
		var near: bool = depth > 6.0
		if near and absf(s.x - source_feet.x) < 170.0:
			size = mini(size, 2)
		_vent(s, when, size, _near_layer() if near else null)
	# Fireworks burst over the erupting clusters, not evenly across the sky.
	for i in firework_bursts:
		var over: Vector2 = spots[randi() % spots.size()] if not spots.is_empty() else _end
		_firework(Vector2(over.x + randfn(0.0, 40.0), clampf(over.y - randf_range(90.0, 200.0), 40.0, area.position.y + 40.0)),
			randf_range(0.0, field_seconds + 0.4))
	if crack_color.a > 0.0 or wake_color.a > 0.0:
		_travel(source_feet, _end, field_seconds)
	_suspense(field_seconds, arrive)
	get_tree().create_timer(arrive).timeout.connect(_erupt_big.bind(maxf(0.8, sustain)))
	get_tree().create_timer(arrive + maxf(0.8, sustain) + 1.6).timeout.connect(queue_free)


## Ground spots across the area in clusters: a few fault lines give way, each
## erupting in a bunch, with calm ground between them. Evenly spread random
## spots read as computer-made; bunched ones read as placed (Gemini VFX
## research, 2026-09-29). Off the HUD, not on top of each other, and not too
## near the opponent's feet (the finale's spot) or Ironvent.
func _scatter(count: int) -> Array[Vector2]:
	var toward: float = signf(_end.x - source_feet.x)
	if toward == 0.0:
		toward = -1.0
	var centres: Array[Vector2] = []
	for k in mini(CLUSTERS, SECTORS.size()):
		for attempt in 40:
			var angle: float = SECTORS[k] + randf_range(-0.3, 0.3)
			var far: float = randf_range(0.35, 1.0)
			# cos(PI) = -1 is toward the opponent; flip it to whichever side that is.
			var c := source_feet + Vector2(-cos(angle) * toward * REACH.x, sin(angle) * REACH.y) * far
			c = c.clamp(area.position, area.end)
			if _blocked(c) or centres.any(func(q: Vector2) -> bool: return q.distance_to(c) < 130.0):
				continue
			centres.append(c)
			break
	var spots: Array[Vector2] = []
	var tries := 0
	while spots.size() < count and tries < count * 60 and not centres.is_empty():
		tries += 1
		# Each cluster in turn, so every side of Ironvent gets its share.
		var p: Vector2 = centres[tries % centres.size()] + Vector2(randfn(0.0, 55.0), randfn(0.0, 20.0))
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
func _stand(tex: Texture2D, pos: Vector2, host: Node = null) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale = Vector2.ONE * _px
	s.offset = Vector2(0, -tex.get_height() * 0.5)
	s.position = (pos / _px).round() * _px
	s.flip_h = randf() < 0.5
	(host if host != null else self).add_child(s)
	return s


## One ground vent: it hisses, bursts up out of the ground, flickers out, then
## smokes. `size` is a whole multiple of the pixel size; bigger ones shake harder.
func _vent(pos: Vector2, delay: float, size: int = 1, host: Node = null) -> void:
	await get_tree().create_timer(delay + 0.001).timeout
	var full: float = _px * size
	var hiss := _stand(charge, pos, host)
	hiss.scale = Vector2.ONE * full
	await get_tree().create_timer(0.22).timeout
	hiss.queue_free()
	var column := _stand(geyser, pos, host)
	# Bursts up from its base in a split second, like the finale's.
	column.scale = Vector2(full, 0.0)
	create_tween().tween_property(column, "scale:y", full, 0.08 + 0.02 * size).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	if shake.is_valid():
		shake.call(6 + 5 * size)
	var t := create_tween()
	t.tween_interval(0.35 + 0.1 * (size - 1))  # the big ones blast a little longer
	for i in 3:
		t.tween_property(column, "visible", false, 0.0)
		t.tween_interval(0.04)
		t.tween_property(column, "visible", true, 0.0)
		t.tween_interval(0.04)
	await t.finished
	column.queue_free()
	var puff := _stand(smoke, pos, host)
	puff.scale = Vector2.ONE * full
	var rise := create_tween().set_parallel()
	rise.tween_property(puff, "position:y", puff.position.y - 10 * full, 0.9)
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
	# The omen: the ground under the opponent glows wider and hotter until the hit.
	_omen = UltimateImpact.omen(_front_node(), _end, _px, arrive - from, FIRE, 48.0)
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
	if is_instance_valid(_omen):
		_omen.queue_free()
	var stage: Node2D = get_parent()
	var front: Node2D = _front_node()
	UltimateImpact.flash(front, FIRE[3])
	_ring_at_base()
	var body: Vector2 = target.position if is_instance_valid(target) else _end - Vector2(0, 14.0 * _px)
	UltimateImpact.ring(front, ring_frames[0] if not ring_frames.is_empty() else null, _end, _px, finale_scale, 5, 0.1, RING_CENTRE_OFFSET)
	UltimateImpact.ring(front, ring_frames[0] if not ring_frames.is_empty() else null, _end, _px, finale_scale, 5, 0.24, RING_CENTRE_OFFSET)
	UltimateImpact.debris(front, _end - Vector2(0, 6.0 * _px), _px, [FIRE[1], FIRE[2], FIRE[3], Color("#3c342c")], 26)
	# The blast opens as a column of fire as wide as the opponent, narrowing into
	# the drawn geyser that keeps erupting.
	UltimateImpact.column(front, _end.x, _end.y, _px, FIRE, 26.0)
	# A burst of sparks over the body the moment it hits, bigger than the body.
	if fireworks != null:
		var pop := _stand(fireworks, body)
		pop.reparent(stage)
		pop.offset = Vector2.ZERO
		pop.scale = Vector2.ONE * _px * finale_scale
		pop.position = (body / _px).round() * _px
		get_tree().create_timer(0.18).timeout.connect(pop.queue_free)
	get_tree().create_timer(0.4).timeout.connect(func() -> void:
		if shake.is_valid():
			shake.call(18))
	var b: Sprite2D
	var using_vfx := geyser_vfx != null
	if using_vfx:
		var v := VfxSprite.new()
		v.texture = geyser_vfx
		v.hframes = 4
		v.vframes = 4
		v.fps = 14.0
		v.loop = true
		v.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		# The frame's bottom sits on the ground under the opponent.
		v.offset = Vector2(0, -float(geyser_vfx.get_height()) / 8.0)
		v.position = (_end / _px).round() * _px
		stage.add_child(v)
		b = v
	else:
		b = _stand(eruption, _end)
		b.flip_h = false
		b.reparent(stage)
	# It engulfs the opponent, so it draws over everything on the stage, big
	# enough (whole pixels) to blast off the top of the screen.
	var full: float = _px * (geyser_vfx_scale if using_vfx else finale_scale)
	var frame_h: float = float(geyser_vfx.get_height()) / 4.0 if using_vfx else eruption.get_height()
	var top: float = frame_h * full
	# Bursts up out of the ground in a split second (it grows from its base).
	b.scale = Vector2(full, 0.0)
	create_tween().tween_property(b, "scale:y", full, 0.14).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	if shake.is_valid():
		shake.call(60)
	var elapsed := 0.0
	var i := 0
	while elapsed < seconds:
		if not using_vfx:
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
	if using_vfx:
		(b as VfxSprite).finish()
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


## The node the finale's added layers draw in, last on the stage so it is in
## front of the creatures. Made on first use; freed with this effect.
func _front_node() -> Node2D:
	if not is_instance_valid(_front):
		_front = Node2D.new()
		_front.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		get_parent().add_child(_front)
		tree_exiting.connect(_front.queue_free)
	return _front


## The layer for geysers on Ironvent's near side: in front of Ironvent, but
## still behind an opponent that stands nearer the camera than it does. When
## Ironvent itself is the nearer creature, that is simply the front layer.
func _near_layer() -> Node2D:
	if is_instance_valid(_mid):
		return _mid
	if not is_instance_valid(target) or target.position.y <= source_feet.y or target.get_parent() != get_parent():
		return _front_node()
	_mid = Node2D.new()
	_mid.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	get_parent().add_child(_mid)
	get_parent().move_child(_mid, target.get_index())  # just under the opponent
	tree_exiting.connect(_mid.queue_free)
	return _mid


## The crack or the wake: a path from the attacker's feet to the opponent's,
## jagged for a crack and gently waving for a wake, revealed front first over
## `seconds`, in whole art pixels. The crack stays and fades with the finale;
## the wake's foam fades behind its head as it goes.
func _travel(from: Vector2, to: Vector2, seconds: float) -> void:
	var line := Node2D.new()
	add_child(line)
	move_child(line, 0)
	var pts := PackedVector2Array()
	var steps := 40
	var side := Vector2(-(to - from).y, (to - from).x).normalized()
	for i in steps + 1:
		var k := float(i) / steps
		var p := from.lerp(to, k)
		if crack_color.a > 0.0:
			p += side * randf_range(-5.0, 5.0) * _px * (1.0 - absf(k - 0.5))
		else:
			p += side * sin(k * TAU * 2.0) * 3.0 * _px
		pts.append(((p / _px).round()) * _px)
	var shown := [0.0]
	line.draw.connect(func() -> void:
		var n := int(shown[0] * steps)
		if n < 1:
			return
		var head: Vector2 = pts[n]
		if crack_color.a > 0.0:
			var dark := Color(0.08, 0.06, 0.04, 0.95)
			var w := maxf(_px, 2.0)
			line.draw_polyline(pts.slice(0, n + 1), dark, 5.0 * w)
			line.draw_polyline(pts.slice(0, n + 1), crack_color, 2.0 * w)
			# Short forks split off every few steps, so it reads as the ground giving way.
			for i in range(3, n, 5):
				var fork_dir: Vector2 = side * (1.0 if i % 2 == 0 else -1.0) + (to - from).normalized() * 0.5
				var tip: Vector2 = pts[i] + fork_dir * 10.0 * w
				line.draw_line(pts[i], tip, dark, 3.0 * w)
				line.draw_line(pts[i], tip, crack_color, w)
		else:
			# The wake: something big gliding under the surface. A long dark
			# shape under the water, two lines of foam spreading back from its
			# head, and two barbels trailing ahead of it.
			var back: Vector2 = (pts[maxi(0, n - 6)] - head).normalized()
			var body := PackedVector2Array()
			var centre: Vector2 = head + back * 18.0 * _px
			for a_step in 16:
				var ang := a_step / 16.0 * TAU
				body.append(centre + back * cos(ang) * 22.0 * _px + side * sin(ang) * 6.0 * _px)
			line.draw_colored_polygon(body, Color(0.02, 0.05, 0.08, 0.55))
			var left := PackedVector2Array()
			var right := PackedVector2Array()
			for k in range(n, maxi(0, n - 14), -1):
				var spread: float = (3.0 + (n - k) * 2.2) * _px
				left.append(pts[k] + side * spread)
				right.append(pts[k] - side * spread)
			if left.size() > 1:
				line.draw_polyline(left, wake_color, 2.0 * _px)
				line.draw_polyline(right, wake_color, 2.0 * _px)
			for sgn: float in [-1.0, 1.0]:
				var tip: Vector2 = head + side * sgn * 4.0 * _px
				line.draw_line(tip, tip - back * 14.0 * _px + side * sgn * 10.0 * _px, Color(0.07, 0.12, 0.16, 0.95), 2.0 * _px)
	)
	var t := create_tween()
	t.tween_method(func(v: float) -> void:
		shown[0] = v
		line.queue_redraw(), 0.0, 1.0, seconds)
	if crack_color.a <= 0.0:
		t.tween_property(line, "modulate:a", 0.0, 0.3)

