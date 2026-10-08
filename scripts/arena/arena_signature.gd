extends Node2D
## Signature moves for the arena prototype (Claude, 2026-10-07), in the reference's style:
## the fight freezes, a giant close-up of the attacker slides across with the move's name,
## then a big effect lands on the opponent. Uses each line's existing signature
## (Stormlantern, Root Rampart, Undertow, Furnace Roar) and its sounds; numbers are placeholders for Grok.
##
## The arena calls start(); this node draws in the World's map pixels, and the close-up card
## is drawn on the arena's screen-space layer (see draw_card). It emits `landed` at the
## climax so the arena applies the damage, and `finished` when it is over.

signal landed(target: int, damage: int)
## Stormlantern only: the lantern's light has swept the field; the arena paralyses every opponent.
signal paralyze
## Undertow only: the attacker sinks out of sight (true) or surfaces (false), and where.
signal user_hidden(hidden: bool)
signal user_moved(to: Vector2)
## Furnace Roar only: the pressure wave goes off from `origin` along `dir`; the arena blows
## back every opponent inside the cone (the chosen target also takes the damage).
signal pressure_wave(origin: Vector2, dir: Vector2)
## Molten Glass only: the glass rains down around the strike; the arena cuts and slows everyone inside.
signal glass_rain(at: Vector2, radius: float, damage: int)
## Molten Glass only: the rain cools into pools of glass on the floor that burn and slow enemies.
signal glass_pools(at: Vector2)
## Furnace Roar only: heat geysers erupt under every enemy (vent crowd control), and lava
## seams split the floor along the cone and stay.
signal geysers
signal lava_seams(origin: Vector2, dir: Vector2)
## Verdant Roar only: the roar roots every opponent; the slam leaves a vine field at the target.
signal root_all
signal vine_field(at: Vector2)
signal finished

const CARD_SECONDS := 1.3
const DAMAGE := 30

var active := false
var _kind := ""
var _t := 0.0
var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _target := -1
var _landed := false
var _bolts: Array[PackedVector2Array] = []
var _rng := RandomNumberGenerator.new()
var _play: Callable                     # arena's sound player: play(path, db)
var _shake: Callable                    # arena's screen shake: shake(amount)


func setup(play: Callable, shake: Callable) -> void:
	_play = play
	_shake = shake


## kind: "Stormlantern", "Root Rampart", "Undertow", "Furnace Roar" or "Molten Glass".
func start(kind: String, from: Vector2, to: Vector2, target: int) -> void:
	active = true
	_kind = kind
	_t = 0.0
	_from = from
	_to = to
	_target = target
	_landed = false
	_bolts.clear()
	_rng.seed = 20261007
	match kind:
		"Stormlantern": _play.call("res://assets/audio/sfx/stormlantern/crackle.wav", -2.0)
		"Root Rampart": _play.call("res://assets/audio/sfx/root_rampart/strain.wav", -2.0)
		"Undertow": _play.call("res://assets/audio/sfx/undertow/surge.wav", -2.0)
		"Furnace Roar": _play.call("res://assets/audio/sfx/ironvent/cry.wav", -4.0)
		"Molten Glass": _play.call("res://assets/audio/sfx/vitrecrag/cry.wav", -4.0)
		"Verdant Roar": _play.call("res://assets/audio/sfx/root_rampart/strain.wav", -2.0)


## Seconds into the effect, after the close-up card.
func effect_time() -> float:
	return _t - CARD_SECONDS


func _process(delta: float) -> void:
	if not active:
		return
	var before := effect_time()
	_t += delta
	var e := effect_time()
	match _kind:
		"Stormlantern": _storm_cues(before, e)
		"Root Rampart": _root_cues(before, e)
		"Undertow": _undertow_cues(before, e)
		"Furnace Roar": _roar_cues(before, e)
		"Molten Glass": _glass_cues(before, e)
		"Verdant Roar": _roar_green_cues(before, e)
	if e > (2.9 if _kind == "Furnace Roar" else 2.2):
		active = false
		finished.emit()
	queue_redraw()


func _cue(before: float, now: float, at: float) -> bool:
	return before < at and now >= at


func _land(sound: String) -> void:
	if _landed:
		return
	_landed = true
	_play.call(sound, 2.0)
	_shake.call(9.0)
	landed.emit(_target, DAMAGE)


# ---------------------------------------------------------------- Stormlantern
# (Preston, 2026-10-07) The lantern flares and its light sweeps the whole field, paralysing
# every opponent; lightning crackles down onto the paralysed; then Stormwick hurls the
# lantern core in an arc onto the one target it chose.

const STORM_SWEEP := 0.55              # the light has crossed the field
const STORM_THROW := 0.95
const STORM_LAND := 1.45

func _storm_cues(b: float, e: float) -> void:
	if _cue(b, e, 0.02):
		_play.call("res://assets/audio/sfx/stormlantern/crackle.wav", 0.0)
	if _cue(b, e, STORM_SWEEP):
		paralyze.emit()
		_play.call("res://assets/audio/sfx/stormlantern/crack.wav", -2.0)
		_shake.call(6.0)
		for k in 2:
			_bolts.append(_bolt(_to + Vector2(_rng.randf_range(-14, 14), _rng.randf_range(-6, 6))))
	if _cue(b, e, STORM_THROW):
		_play.call("res://assets/audio/sfx/stormlantern/throw.wav", 0.0)
	if _cue(b, e, STORM_LAND):
		_land("res://assets/audio/sfx/stormlantern/boom.wav")


func _bolt(at: Vector2) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var top := Vector2(at.x + _rng.randf_range(-20, 20), -20)
	for i in 11:
		var p := top.lerp(at, i / 10.0)
		if i > 0 and i < 10:
			p.x += _rng.randf_range(-6, 6)
		pts.append(p.round())
	return pts


func _draw_storm(e: float) -> void:
	# The arena dims, so the lantern is the only light.
	draw_rect(Rect2(-40, -40, 470, 300), Color(0.05, 0.04, 0.12, clampf(e * 2.0, 0.0, 0.4)))
	# The flare: rings of lantern light sweep out across the whole field.
	if e < STORM_SWEEP + 0.35:
		for r in 3:
			var k := clampf((e - r * 0.08) / STORM_SWEEP, 0.0, 1.4)
			if k > 0.0:
				var fade := clampf(1.4 - k, 0.0, 1.0)
				draw_arc(_from.round(), 8.0 + 330.0 * k, 0, TAU, 64, Color(1, 0.88, 0.45, 0.8 * fade), 3.0)
		draw_circle(_from.round(), 7.0 + 3.0 * sin(e * 40.0), Color(1, 0.97, 0.8))
		if absf(e - STORM_SWEEP) < 0.08:
			draw_rect(Rect2(-40, -40, 470, 300), Color(1, 0.95, 0.75, 0.35))
	for k in _bolts.size():
		var age := e - STORM_SWEEP - k * 0.12
		if age >= 0.0 and age < 0.2 and int(age * 40) % 2 == 0:
			draw_polyline(_bolts[k], Color(1, 0.85, 0.35, 0.6), 5.0)
			draw_polyline(_bolts[k], Color(1, 1, 0.9), 2.0)
	# The lantern core, thrown in a high arc from the lantern onto the target.
	if e > STORM_THROW and e < STORM_LAND:
		var k := (e - STORM_THROW) / (STORM_LAND - STORM_THROW)
		var p := _from.lerp(_to + Vector2(0, -8), k) + Vector2(0, -sin(k * PI) * 70.0)
		for j in 6:
			var q := _from.lerp(_to + Vector2(0, -8), maxf(0.0, k - j * 0.04)) + Vector2(0, -sin(maxf(0.0, k - j * 0.04) * PI) * 70.0)
			draw_circle(q.round(), 7.0 - j, Color(1, 0.6, 0.2, 0.25))
		draw_circle(p.round(), 9.0, Color("#ff7a1a"))
		draw_circle(p.round(), 5.0, Color("#fff1a8"))
	if e >= STORM_LAND:
		_blast(e - STORM_LAND, Color("#fff1a8"), Color("#ff5a1f"), 46.0)


# ---------------------------------------------------------------- Root Rampart
# Roots tear through the ground from the attacker to the opponent, then a wall of roots
# and stone erupts under it.

func _root_cues(b: float, e: float) -> void:
	if _cue(b, e, 0.05):
		_play.call("res://assets/audio/sfx/root_rampart/slam.wav", 0.0)
		_shake.call(5.0)
	if _cue(b, e, 0.25):
		_play.call("res://assets/audio/sfx/root_rampart/rootwave.wav", -2.0)
	if _cue(b, e, 1.0):
		_land("res://assets/audio/sfx/root_rampart/eruption.wav")


func _draw_root(e: float) -> void:
	var along := clampf((e - 0.2) / 0.8, 0.0, 1.0)
	var n := int(along * 12.0)
	for i in n:
		var p := _from.lerp(_to, (i + 1) / 13.0) + Vector2(0, 4)
		var h := 6.0 + 3.0 * (i % 3)
		_spike(p.round(), h, Color("#5a3f22"), Color("#8fd16a"))
		draw_rect(Rect2((p + Vector2(-5, 0)).round(), Vector2(10, 2)), Color(0.2, 0.14, 0.08, 0.6))
	if e >= 1.0:
		var k := clampf((e - 1.0) / 0.25, 0.0, 1.0)
		for i in 9:
			var x := -24.0 + i * 6.0
			var h := (18.0 + 14.0 * absf(sin(i * 1.7))) * k
			_spike((_to + Vector2(x, 6 - absf(x) * 0.2)).round(), h, Color("#4a3320"), Color("#a4e07a"))
		_blast(e - 1.0, Color("#d8f0a0"), Color("#7a5a32"), 40.0)


func _spike(base: Vector2, h: float, wood: Color, tip: Color) -> void:
	draw_colored_polygon(PackedVector2Array([base + Vector2(-3, 0), base + Vector2(3, 0), base + Vector2(0, -h)]), wood)
	draw_rect(Rect2(base + Vector2(-1, -h), Vector2(2, 3)), tip)


# ---------------------------------------------------------------- Undertow
# (Preston, 2026-10-07: "the one from the game where it dives from underneath") Scourmaw
# sinks into its hollow, a wake runs under the arena floor to the target, dark water
# swells beneath it, and Scourmaw bursts up through it jaws first. Then it dives again and
# resurfaces back in its own hollow: hit and run.

const DIVE_SINK := 0.3
const DIVE_ARRIVE := 0.95
const DIVE_BURST := 1.1
const DIVE_AWAY := 1.6
const DIVE_HOME := 1.95

func _undertow_cues(b: float, e: float) -> void:
	if _cue(b, e, 0.02):
		_play.call("res://assets/audio/sfx/undertow/whirlpool.wav", -4.0)
	if _cue(b, e, DIVE_SINK):
		user_hidden.emit(true)
		_play.call("res://assets/audio/sfx/undertow/plunge.wav", -2.0)
	if _cue(b, e, DIVE_BURST):
		user_moved.emit(_to + Vector2(0, 4))
		user_hidden.emit(false)
		_land("res://assets/audio/sfx/undertow/burst.wav")
	if _cue(b, e, DIVE_AWAY):
		user_hidden.emit(true)
		_play.call("res://assets/audio/sfx/undertow/plunge.wav", -8.0)
	if _cue(b, e, DIVE_HOME):
		user_moved.emit(_from)
		user_hidden.emit(false)


func _draw_undertow(e: float) -> void:
	# Its own hollow swirls open as it sinks, and again when it comes home.
	var home := clampf(e / DIVE_SINK, 0.0, 1.0) * clampf((DIVE_ARRIVE - e) / 0.2, 0.0, 1.0) + clampf((e - DIVE_AWAY) / 0.2, 0.0, 1.0)
	if home > 0.0:
		_whirl(_from, home, e)
	# The wake: ripples and a dark seam racing under the floor to the target.
	if e > DIVE_SINK and e < DIVE_BURST:
		var k := clampf((e - DIVE_SINK) / (DIVE_ARRIVE - DIVE_SINK), 0.0, 1.0)
		var head := _from.lerp(_to, k)
		draw_line(_from.lerp(_to, maxf(0.0, k - 0.35)).round(), head.round(), Color(0.03, 0.06, 0.1, 0.55), 4.0)
		var dir := (_to - _from).normalized()
		var side := dir.orthogonal()
		for j in 4:
			var at := head - dir * (j * 7.0)
			var w := 3.0 + j * 2.5
			draw_line(at.round(), (at - dir * 6.0 + side * w).round(), Color(0.7, 0.92, 1.0, 0.8 - j * 0.18), 1.0)
			draw_line(at.round(), (at - dir * 6.0 - side * w).round(), Color(0.7, 0.92, 1.0, 0.8 - j * 0.18), 1.0)
	# Dark water swells under the target just before Scourmaw breaks through.
	if e > DIVE_ARRIVE - 0.15 and e < DIVE_BURST:
		var k := clampf((e - DIVE_ARRIVE + 0.15) / 0.3, 0.0, 1.0)
		_whirl(_to, k, e)
	# The burst: a column of black water and spray thrown up round the jaws.
	if e >= DIVE_BURST:
		var k := clampf((e - DIVE_BURST) / 0.5, 0.0, 1.0)
		var fade := 1.0 - k
		draw_rect(Rect2((_to + Vector2(-9, -60 * minf(1.0, k * 3.0))).round(), Vector2(18, 60 * minf(1.0, k * 3.0))), Color(0.05, 0.12, 0.2, 0.7 * fade))
		draw_rect(Rect2((_to + Vector2(-4, -60 * minf(1.0, k * 3.0))).round(), Vector2(8, 60 * minf(1.0, k * 3.0))), Color(0.6, 0.88, 1.0, 0.7 * fade))
		for j in 14:
			var a := j * TAU / 14.0
			var d := Vector2(cos(a), sin(a) * 0.4 - 0.6) * (10.0 + 40.0 * k)
			draw_rect(Rect2((_to + d).round(), Vector2(2, 2)), Color(0.75, 0.95, 1.0, fade))
		_blast(e - DIVE_BURST, Color("#cfeeff"), Color("#1f5f8f"), 34.0)


func _whirl(at: Vector2, open: float, e: float) -> void:
	draw_set_transform(at.round(), 0.0, Vector2(1.0, 0.4))
	draw_circle(Vector2.ZERO, 14.0 * open, Color(0.02, 0.06, 0.12, 0.7))
	for r in 4:
		var spin := e * (7.0 - r) + r
		draw_arc(Vector2.ZERO, (6.0 + r * 5.0) * open, spin, spin + 4.0, 24, Color(0.4 + r * 0.1, 0.8, 1.0, 0.8 - r * 0.15), 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# ---------------------------------------------------------------- Furnace Roar
# (Claude draft, 2026-10-07, from the turn-based move: "a full warning vent becomes a
# crushing blast", a pressure wave, not a projectile.) Heat fills Ironvent's ridge and the
# ground under it glows; the back vents jet; it rears; then a broad cone of pressure and
# fire blasts toward the target, scorching the floor and throwing debris. The target takes
# the damage; everyone else caught in the cone is blown back.

# Preston (2026-10-07 night): Ironvent is a marquee creature, so this is the showpiece: the
# arena darkens to furnace light and lava seams split the floor from under it; the vents jet;
# it rears and roars (a red flash); HEAT GEYSERS erupt under every enemy on the field and stun
# them (vent crowd control); then the pressure wave and fire cone blast the target and
# everyone in the cone, and the seams stay burning along the cone for a while.
const ROAR_VENTS := 0.25               # the vents start jetting
const ROAR_REAR := 0.75                # it rears and roars
const ROAR_GEYSERS := 1.0              # geysers under every enemy
const ROAR_HIT := 1.35                 # the wave front reaches the target
const ROAR_CONE := 0.7                 # half-width of the cone, radians
const ROAR_REACH := 170.0

func _roar_cues(b: float, e: float) -> void:
	if _cue(b, e, 0.02):
		_play.call("res://assets/audio/sfx/ironvent/buildup.wav", -2.0)
	if _cue(b, e, ROAR_VENTS):
		_play.call("res://assets/audio/sfx/ironvent/vent_hiss.wav", -4.0)
		_shake.call(3.0)
	if _cue(b, e, ROAR_REAR):
		_play.call("res://assets/audio/sfx/ironvent/roar.wav", 0.0)
		_play.call("res://assets/audio/sfx/ironvent/vent_jet.wav", -4.0)
		_shake.call(7.0)
	if _cue(b, e, ROAR_GEYSERS):
		geysers.emit()
		_play.call("res://assets/audio/sfx/arena/rock_break.wav", -4.0)
		_play.call("res://assets/audio/sfx/ironvent/vent_jet.wav", 0.0)
		_shake.call(6.0)
	if _cue(b, e, ROAR_HIT):
		pressure_wave.emit(_from, (_to - _from).normalized())
		lava_seams.emit(_from, (_to - _from).normalized())
		_land("res://assets/audio/sfx/ironvent/blowdown.wav")
	if _cue(b, e, 2.2):
		_play.call("res://assets/audio/sfx/ironvent/cool.wav", -8.0)


func _draw_roar(e: float) -> void:
	var dir := (_to - _from).normalized()
	var mouth := _from + Vector2(0, -14) + dir * 10.0
	# The arena dims to furnace light.
	draw_rect(Rect2(-40, -40, 470, 300), Color(0.12, 0.03, 0.0, clampf(e * 1.5, 0.0, 0.35) * clampf((2.2 - e) / 0.4, 0.0, 1.0)))
	# Heat pooling under it: a glowing ring of cracked ground that brightens until the roar.
	var heat := clampf(e / ROAR_REAR, 0.0, 1.0) * clampf((ROAR_HIT + 0.5 - e) / 0.5, 0.0, 1.0)
	if heat > 0.0:
		draw_set_transform(_from.round() + Vector2(0, 2), 0.0, Vector2(1.0, 0.4))
		draw_circle(Vector2.ZERO, 26.0, Color(1.0, 0.35, 0.05, 0.25 * heat))
		draw_circle(Vector2.ZERO, 15.0, Color(1.0, 0.6, 0.15, 0.35 * heat))
		for i in 8:
			var a := i * TAU / 8.0 + 0.2
			draw_line(Vector2.RIGHT.rotated(a) * 8.0, Vector2.RIGHT.rotated(a + 0.15) * 26.0, Color(1.0, 0.75, 0.3, 0.8 * heat), 1.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		# Pressure: rings of shimmer pulled in toward it.
		for r in 2:
			var k := fmod(e * 1.6 + r * 0.5, 1.0)
			draw_arc(_from.round() + Vector2(0, -10), 40.0 * (1.0 - k), 0, TAU, 32, Color(1.0, 0.8, 0.5, 0.4 * k * heat), 1.0)
	# The vents along its back jet heat: columns that rise and flicker, white-hot at the root.
	if e > ROAR_VENTS and e < ROAR_HIT + 0.6:
		var jet := clampf((e - ROAR_VENTS) / 0.3, 0.0, 1.0) * clampf((ROAR_HIT + 0.6 - e) / 0.3, 0.0, 1.0)
		for v in 4:
			var base := _from + Vector2(-9 + v * 6, -22 + absf(v - 1.5) * 2.0) - dir * 4.0
			var h := (10.0 + 6.0 * sin(e * 30.0 + v * 1.7)) * jet * (1.6 if e > ROAR_REAR else 1.0)
			draw_line(base.round(), (base + Vector2(0, -h)).round(), Color(1.0, 0.45, 0.1, 0.7), 3.0)
			draw_line(base.round(), (base + Vector2(0, -h * 0.6)).round(), Color(1.0, 0.95, 0.7), 1.0)
			draw_circle((base + Vector2(sin(e * 9.0 + v) * 2.0, -h - 3.0)).round(), 2.0, Color(0.35, 0.3, 0.3, 0.5 * jet))
	# Lava seams crack open across the floor from under it as the heat builds.
	if e > ROAR_VENTS:
		var spread := clampf((e - ROAR_VENTS) / (ROAR_HIT - ROAR_VENTS), 0.0, 1.0)
		var cool2 := clampf((2.9 - e) / 0.8, 0.0, 1.0)
		for i in 7:
			var a := i * TAU / 7.0 + 0.4
			var seam := PackedVector2Array()
			var pnt: Vector2 = _from + Vector2(0, 4)
			seam.append(pnt.round())
			for k in 6:
				pnt += Vector2.RIGHT.rotated(a + sin((k + i) * 2.3) * 0.5) * (6.0 + 5.0 * _hash(i * 7 + k)) * Vector2(1.0, 0.55) * spread
				seam.append(pnt.round())
			draw_polyline(seam, Color(0.1, 0.03, 0.0, 0.9 * cool2), 3.0)
			draw_polyline(seam, Color(1.0, 0.5 + 0.3 * sin(e * 12.0 + i), 0.1, 0.9 * cool2), 1.0)
	# The roar itself: a red flash and a shock ring across the whole field.
	if e >= ROAR_REAR and e < ROAR_REAR + 0.5:
		var kr := (e - ROAR_REAR) / 0.5
		if kr < 0.12:
			draw_rect(Rect2(-40, -40, 470, 300), Color(1.0, 0.3, 0.05, 0.4))
		draw_arc(mouth.round(), 10.0 + 330.0 * kr, 0, TAU, 72, Color(1.0, 0.45, 0.1, 0.7 * (1.0 - kr)), 4.0)
	# Mouth glow while it rears.
	if e > ROAR_REAR - 0.2 and e < ROAR_HIT + 0.15:
		draw_circle(mouth.round(), 3.0 + 2.0 * sin(e * 50.0), Color(1.0, 0.95, 0.75))
	# The wave: arcs of fire and pressure rushing out in a cone, edged in smoke.
	if e >= ROAR_REAR:
		var reach := maxf(ROAR_REACH, _from.distance_to(_to) + 20.0)
		var a0 := dir.angle()
		for w in 4:
			var k := clampf((e - ROAR_REAR - w * 0.07) / (ROAR_HIT - ROAR_REAR + 0.15), 0.0, 1.3)
			if k <= 0.0 or k >= 1.3:
				continue
			var fade := clampf(1.3 - k, 0.0, 1.0)
			var r := 10.0 + reach * minf(k, 1.0)
			draw_arc(mouth.round(), r, a0 - ROAR_CONE, a0 + ROAR_CONE, 24, Color(0.25, 0.2, 0.2, 0.5 * fade), 6.0)
			draw_arc(mouth.round(), r - 2.0, a0 - ROAR_CONE * 0.9, a0 + ROAR_CONE * 0.9, 24, Color(1.0, 0.45, 0.1, 0.9 * fade), 3.0)
			draw_arc(mouth.round(), r - 3.0, a0 - ROAR_CONE * 0.6, a0 + ROAR_CONE * 0.6, 20, Color(1.0, 0.95, 0.7, fade), 1.0)
		# Scorched streaks across the floor inside the cone, and debris flung ahead of the wave.
		var spread := clampf((e - ROAR_REAR) / (ROAR_HIT - ROAR_REAR), 0.0, 1.0)
		var cool := clampf((2.2 - e) / 0.6, 0.0, 1.0)
		for i in 7:
			var a := a0 + (i - 3) * ROAR_CONE / 3.5
			var from := mouth + Vector2.RIGHT.rotated(a) * 14.0 + Vector2(0, 14)
			draw_line(from.round(), (from + Vector2.RIGHT.rotated(a) * reach * 0.8 * spread).round(), Color(0.15, 0.06, 0.03, 0.45 * cool), 2.0)
		if e < ROAR_HIT + 0.5:
			for i in 12:
				var a := a0 + (_hash(i) - 0.5) * ROAR_CONE * 2.0
				var d := (20.0 + reach * spread) * (0.6 + 0.4 * _hash(i + 20))
				var p := mouth + Vector2.RIGHT.rotated(a) * d + Vector2(0, -sin(spread * PI) * 10.0 * _hash(i + 40))
				draw_rect(Rect2(p.round(), Vector2(2, 2)), Color("#5a4a40") if i % 3 else Color("#ffb347"))
	if e >= ROAR_HIT:
		_blast(e - ROAR_HIT, Color("#ffe2a0"), Color("#d8401a"), 44.0)


## A fixed pseudo-random number in [0, 1) for particle i (the same every frame).
func _hash(i: int) -> float:
	return fmod(absf(sin(i * 12.9898) * 43758.5453), 1.0)


# ---------------------------------------------------------------- Molten Glass
# (Claude draft, 2026-10-07, from the turn-based ultimate: the molten-glass core "going
# haywire", a buildup, then the shell ruptures.) The crater brightens white, steam jets from
# every seam of the shell, then it ruptures: a column of molten glass bursts up and arcs onto
# the target, and glass rains down all round it. The target takes the damage; everyone else in
# the rain is cut and slowed.

const GLASS_RUPTURE := 0.9
const GLASS_LAND := 1.35
const GLASS_RADIUS := 46.0

func _glass_cues(b: float, e: float) -> void:
	if _cue(b, e, 0.02):
		_play.call("res://assets/audio/sfx/vitrecrag/buildup.wav", -2.0)
	if _cue(b, e, 0.45):
		_shake.call(2.0)
	if _cue(b, e, GLASS_RUPTURE):
		_play.call("res://assets/audio/sfx/vitrecrag/rupture.wav", 0.0)
		_shake.call(6.0)
	if _cue(b, e, GLASS_LAND):
		glass_rain.emit(_to, GLASS_RADIUS, DAMAGE)
		glass_pools.emit(_to)
		_land("res://assets/audio/sfx/ui/hit_strong.wav")


func _draw_glass(e: float) -> void:
	var crater: Vector2 = _from + Vector2(0, -24)
	# The arena dims to kiln light.
	draw_rect(Rect2(-40, -40, 470, 300), Color(0.1, 0.03, 0.0, clampf(e * 1.5, 0.0, 0.35) * clampf((2.2 - e) / 0.4, 0.0, 1.0)))
	# Buildup: the crater brightens from orange to white and steam jets from the seams.
	if e < GLASS_RUPTURE + 0.2:
		var k := clampf(e / GLASS_RUPTURE, 0.0, 1.0)
		var glow := Color(1.0, 0.55 + 0.4 * k, 0.2 + 0.7 * k)
		draw_set_transform(crater.round(), 0.0, Vector2(1.0, 0.5))
		draw_circle(Vector2.ZERO, 7.0 + 4.0 * k + sin(e * 30.0) * k, Color(glow, 0.9))
		draw_circle(Vector2.ZERO, 12.0 + 14.0 * k, Color(1.0, 0.5, 0.15, 0.25 * k))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		for j in 6:
			var a := j * TAU / 6.0 + 0.3
			var base := _from + Vector2(cos(a) * 14.0, -10.0 + sin(a) * 6.0)
			var h := (4.0 + 10.0 * k) * (0.7 + 0.3 * sin(e * 25.0 + j))
			draw_line(base.round(), (base + Vector2(sin(e * 7.0 + j) * 2.0, -h)).round(), Color(0.9, 0.9, 0.95, 0.5 * k), 2.0)
	# Rupture: a column of molten glass up, then an arc of it onto the target.
	if e >= GLASS_RUPTURE and e < GLASS_LAND + 0.1:
		var k := clampf((e - GLASS_RUPTURE) / (GLASS_LAND - GLASS_RUPTURE), 0.0, 1.0)
		var up := clampf(k * 3.0, 0.0, 1.0)
		draw_rect(Rect2((crater + Vector2(-6, -70.0 * up)).round(), Vector2(12, 70.0 * up)), Color(1.0, 0.6, 0.2, 0.8 * (1.0 - k)))
		draw_rect(Rect2((crater + Vector2(-2, -70.0 * up)).round(), Vector2(4, 70.0 * up)), Color(1.0, 0.95, 0.75, 0.9 * (1.0 - k)))
		var p: Vector2 = crater.lerp(_to + Vector2(0, -6), k) + Vector2(0, -sin(k * PI) * 85.0)
		for j in 7:
			var kk := maxf(0.0, k - j * 0.035)
			var qq: Vector2 = crater.lerp(_to + Vector2(0, -6), kk) + Vector2(0, -sin(kk * PI) * 85.0)
			draw_circle(qq.round(), 9.0 - j, Color(1.0, 0.55, 0.15, 0.3))
		draw_circle(p.round(), 10.0, Color("#ff7a1a"))
		draw_circle(p.round(), 6.0, Color("#fff3c0"))
		# Shards of glass thrown out of the column, falling wide.
		for j in 12:
			var fall := clampf(k * 1.4 - _hash(j) * 0.4, 0.0, 1.0)
			var sx: Vector2 = _to + Vector2((_hash(j + 7) - 0.5) * GLASS_RADIUS * 2.0, (_hash(j + 19) - 0.5) * GLASS_RADIUS * 0.9)
			var sp: Vector2 = sx + Vector2(0, -90.0 * (1.0 - fall))
			draw_rect(Rect2(sp.round(), Vector2(2, 3)), Color(1.0, 0.85, 0.6, 0.9))
	if e >= GLASS_LAND:
		var k := clampf((e - GLASS_LAND) / 0.6, 0.0, 1.0)
		# The rain lands: a ring of glass glitter on the floor, cooling from orange to clear.
		draw_set_transform(_to.round() + Vector2(0, 2), 0.0, Vector2(1.0, 0.45))
		draw_circle(Vector2.ZERO, GLASS_RADIUS * (0.6 + 0.4 * k), Color(1.0, 0.6, 0.25, 0.25 * (1.0 - k)))
		draw_arc(Vector2.ZERO, GLASS_RADIUS, 0, TAU, 40, Color(1.0, 0.9, 0.7, 0.8 * (1.0 - k)), 1.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		for j in 24:
			var gp: Vector2 = _to + Vector2.RIGHT.rotated(_hash(j + 31) * TAU) * GLASS_RADIUS * sqrt(_hash(j + 53)) * Vector2(1.0, 0.45)
			draw_rect(Rect2(gp.round(), Vector2(2, 1)), Color(1.0, 0.95, 0.85, 0.9 - 0.5 * k))
		_blast(e - GLASS_LAND, Color("#fff3c0"), Color("#ff6a1a"), 42.0)


# ---------------------------------------------------------------- Verdant Roar
# (Preston, 2026-10-07 night, from the turn-based title card: the seed pod on its tail flares
# green while it roars. "Make it more impactful and really look like a signature.") The pod
# flares and the arena goes green; the roar sends a shockwave across the whole field and roots
# every enemy where it stands (rings of roots erupt outward); then the glowing pod club comes
# down on the target, a towering slam that leaves a vine field. Placeholder name.

const GREEN_ROAR := 0.35
const GREEN_RINGS := 0.45
const GREEN_RAISE := 0.95
const GREEN_SLAM := 1.35

func _roar_green_cues(b: float, e: float) -> void:
	if _cue(b, e, 0.02):
		_play.call("res://assets/audio/sfx/root_rampart/strain.wav", 0.0)
	if _cue(b, e, GREEN_ROAR):
		_play.call("res://assets/audio/sfx/root_rampart/rootwave.wav", 0.0)
		_shake.call(5.0)
		root_all.emit()
	if _cue(b, e, GREEN_RAISE):
		_play.call("res://assets/audio/sfx/root_rampart/slam.wav", -4.0)
	if _cue(b, e, GREEN_SLAM):
		vine_field.emit(_to)
		_land("res://assets/audio/sfx/root_rampart/eruption.wav")


func _draw_roar_green(e: float) -> void:
	var pod: Vector2 = _from + Vector2(-14, -30)
	# The arena goes green from the pod's glow.
	draw_rect(Rect2(-40, -40, 470, 300), Color(0.05, 0.12, 0.03, clampf(e * 1.5, 0.0, 0.4) * clampf((2.2 - e) / 0.4, 0.0, 1.0)))
	# The pod flares: a bright green spiral that brightens to white at the roar.
	var k := clampf(e / GREEN_ROAR, 0.0, 1.0)
	var glow := Color(0.5 + 0.5 * k, 1.0, 0.3 + 0.6 * k)
	draw_circle(pod.round(), 6.0 + 6.0 * k + sin(e * 40.0) * 1.5, Color(glow, 0.95))
	draw_circle(pod.round(), 14.0 + 16.0 * k, Color(0.55, 1.0, 0.35, 0.22))
	draw_arc(pod.round(), 9.0 + 4.0 * k, e * 9.0, e * 9.0 + 4.0, 20, Color(0.85, 1.0, 0.6, 0.9), 2.0)
	# The roar: a green shockwave crosses the whole field.
	if e >= GREEN_ROAR and e < GREEN_ROAR + 0.6:
		var kk := (e - GREEN_ROAR) / 0.6
		draw_arc(_from.round(), 10.0 + 340.0 * kk, 0, TAU, 72, Color(0.6, 1.0, 0.4, 0.8 * (1.0 - kk)), 4.0)
		draw_arc(_from.round(), 10.0 + 340.0 * kk - 6.0, 0, TAU, 72, Color(0.9, 1.0, 0.7, 0.6 * (1.0 - kk)), 2.0)
		if kk < 0.1:
			draw_rect(Rect2(-40, -40, 470, 300), Color(0.7, 1.0, 0.5, 0.35))
	# Rings of roots erupting outward from it across the ground.
	if e >= GREEN_RINGS and e < GREEN_SLAM + 0.3:
		for ring in 4:
			var kr := clampf((e - GREEN_RINGS - ring * 0.12) / 0.3, 0.0, 1.4)
			if kr <= 0.0 or kr >= 1.4:
				continue
			var fade := clampf(1.4 - kr, 0.0, 1.0)
			var rad := 24.0 + ring * 26.0
			for i in 10 + ring * 4:
				var a := i * TAU / (10 + ring * 4) + ring * 0.3
				var base: Vector2 = _from + Vector2(cos(a) * rad, sin(a) * rad * 0.5)
				var h := (8.0 + 6.0 * absf(sin(i * 1.7))) * minf(1.0, kr)
				draw_colored_polygon(PackedVector2Array([base.round() + Vector2(-3, 0), base.round() + Vector2(3, 0), base.round() + Vector2(0, -h)]), Color(0.35, 0.25, 0.13, fade))
				draw_rect(Rect2(base.round() + Vector2(-1, -h), Vector2(2, 3)), Color(0.56, 0.82, 0.42, fade))
	# The club raised, then brought down on the target.
	if e >= GREEN_RAISE and e < GREEN_SLAM:
		var kc := (e - GREEN_RAISE) / (GREEN_SLAM - GREEN_RAISE)
		var top: Vector2 = pod + Vector2(0, -40)
		var p: Vector2 = top.lerp(_to + Vector2(0, -10), pow(kc, 2.0))
		draw_line(_from.round() + Vector2(0, -16), p.round(), Color(0.35, 0.25, 0.13), 5.0)
		draw_circle(p.round(), 11.0, Color(0.56, 0.82, 0.42))
		draw_circle(p.round(), 7.0, Color(0.85, 1.0, 0.6))
	if e >= GREEN_SLAM:
		var ks := clampf((e - GREEN_SLAM) / 0.6, 0.0, 1.0)
		# The slam: a towering column of roots and earth bursts up where it lands.
		var hcol := 70.0 * minf(1.0, ks * 3.0)
		draw_rect(Rect2((_to + Vector2(-9, -hcol)).round(), Vector2(18, hcol)), Color(0.35, 0.25, 0.13, 0.85 * (1.0 - ks)))
		draw_rect(Rect2((_to + Vector2(-4, -hcol)).round(), Vector2(8, hcol)), Color(0.56, 0.82, 0.42, 0.9 * (1.0 - ks)))
		for i in 12:
			var a := i * TAU / 12.0
			var d := Vector2(cos(a), sin(a) * 0.5) * (14.0 + 40.0 * ks)
			draw_rect(Rect2((_to + d).round(), Vector2(3, 3)), Color(0.35, 0.25, 0.13, 1.0 - ks))
		_blast(e - GREEN_SLAM, Color("#d8f0a0"), Color("#4a3320"), 52.0)


# ---------------------------------------------------------------- shared

func _blast(age: float, core: Color, rim: Color, size: float) -> void:
	var k := clampf(age / 0.6, 0.0, 1.0)
	if k >= 1.0:
		return
	draw_circle(_to.round(), size * (0.5 + k) * 0.6, Color(core, 0.6 * (1.0 - k)))
	draw_arc(_to.round(), size * (0.4 + k), 0, TAU, 36, Color(rim, 1.0 - k), 4.0)
	for i in 16:
		var d := Vector2.RIGHT.rotated(i * TAU / 16.0 + 0.3) * size * 1.4 * k
		draw_rect(Rect2((_to + d).round(), Vector2(3, 3)), Color(rim, 1.0 - k))


func _draw() -> void:
	if not active:
		return
	var e := effect_time()
	if e < 0.0:
		return
	match _kind:
		"Stormlantern": _draw_storm(e)
		"Root Rampart": _draw_root(e)
		"Undertow": _draw_undertow(e)
		"Furnace Roar": _draw_roar(e)
		"Molten Glass": _draw_glass(e)
		"Verdant Roar": _draw_roar_green(e)


## The giant close-up card, drawn by the arena on its screen layer while the card runs.
## Returns false when the card is over.
func draw_card(canvas: CanvasItem, art: Texture2D, title: String, accent: Color, font: Font) -> bool:
	if not active or _t > CARD_SECONDS:
		return false
	var k := _t / CARD_SECONDS
	var slide := clampf(_t / 0.22, 0.0, 1.0)
	var out := clampf((_t - (CARD_SECONDS - 0.2)) / 0.2, 0.0, 1.0)
	canvas.draw_rect(Rect2(0, 0, 1152, 648), Color(0, 0, 0, 0.55 * (1.0 - out)))
	var band := Rect2(0, 150, 1152, 300)
	canvas.draw_rect(band, Color(accent.darkened(0.75), 0.92 * (1.0 - out)))
	for i in 14:
		var x := fmod(i * 110.0 + k * 400.0, 1400.0) - 150.0
		canvas.draw_line(Vector2(x, band.position.y), Vector2(x - 120, band.end.y), Color(accent, 0.18 * (1.0 - out)), 14.0)
	canvas.draw_rect(Rect2(0, 146, 1152, 4), Color(accent, 1.0 - out))
	canvas.draw_rect(Rect2(0, 450, 1152, 4), Color(accent, 1.0 - out))
	# The close-up: the creature's full battle art at twice size, sliding in from the left.
	var x := lerpf(-460.0, 80.0, 1.0 - pow(1.0 - slide, 3.0)) - out * 600.0
	canvas.draw_texture_rect(art, Rect2(x, 80, art.get_width() * 2, art.get_height() * 2), false)
	var tx := lerpf(1200.0, 600.0, 1.0 - pow(1.0 - slide, 3.0)) + out * 700.0
	canvas.draw_string(font, Vector2(tx, 280), "SIGNATURE MOVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(accent, 1.0))
	canvas.draw_string(font, Vector2(tx, 340), title.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 52, Color("#F0F4F8"))
	return true
