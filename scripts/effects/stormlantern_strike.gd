extends "res://scripts/effects/sky_rail_strike.gd"

## Stormwick's Stormlantern (Preston, 2026-10-05). Kingstone Rail's meteor,
## impact and rings, with Stormlantern's own opening: lightning strikes down out
## of the storm onto Stormwick's rod crest, and the charge it carries is what
## overloads the lantern (the attack frames show that). Then, at the tail snap,
## the core leaves the lantern and comes down on the opponent as Kingstone's does.
##
## The battle calls erupt() on the move's first emit frame (the rear). This
## strikes the bolt at once, waits `release_after` seconds for the tail snap,
## and then runs the inherited launch, fall and impact from the lantern.

## Where the crest is, in art pixels from the lantern spot the battle passes in
## (the move's attack_river_offset, measured on the snap pose).
@export var crest_from_start := Vector2(70, -60)
## Seconds from the bolt to the tail snap that throws the core.
@export var release_after := 2.0
## Flashes of the bolt: on/off times in seconds after it strikes, in pairs.
const FLASHES := [[0.0, 0.14], [0.2, 0.45], [0.52, 0.66]]

var _bolt: Node2D
var _bolt_points := PackedVector2Array()
var _branch_points := PackedVector2Array()
var _rng := RandomNumberGenerator.new()


func erupt(start: Vector2, end: Vector2, px: float, arrive: float, sustain: float) -> void:
	_px = maxf(1.0, px)
	get_parent().move_child(self, -1)
	# The art faces right; when the battle flips the attacker to face left (the
	# opponent is to its left), the crest sits on the other side of the lantern.
	var facing := 1.0 if end.x >= start.x else -1.0
	_strike(start + Vector2(crest_from_start.x * facing, crest_from_start.y) * _px)
	await get_tree().create_timer(release_after).timeout
	super.erupt(start, end, px, maxf(0.4, arrive - release_after), sustain)


func _strike(crest: Vector2) -> void:
	_bolt = Node2D.new()
	add_child(_bolt)
	_bolt.draw.connect(_draw_bolt)
	_rng.seed = 20261005
	for f in FLASHES:
		get_tree().create_timer(f[0]).timeout.connect(_flash.bind(crest, true))
		get_tree().create_timer(f[1]).timeout.connect(_flash.bind(crest, false))
	get_tree().create_timer(0.75).timeout.connect(_bolt.queue_free)


## A new jagged path each flash, in whole art pixels, from above the screen
## down to the crest, with one fork.
func _flash(crest: Vector2, on: bool) -> void:
	if not is_instance_valid(_bolt):
		return
	_bolt_points.clear()
	_branch_points.clear()
	if on:
		var p := crest + Vector2(_rng.randf_range(-40, 40) * _px, -720)
		var steps := 22
		for i in steps + 1:
			var k := float(i) / steps
			var q := p.lerp(crest, k)
			if i > 0 and i < steps:
				q.x += _rng.randf_range(-7, 7) * _px
			_bolt_points.append(_snap(q))
		var from := _bolt_points[steps / 2]
		var b := from
		_branch_points.append(b)
		for i in 6:
			b += Vector2(_rng.randf_range(4, 12) * _px * (1 if i % 2 == 0 else 0.4), _rng.randf_range(6, 14) * _px)
			_branch_points.append(_snap(b))
		if shake.is_valid():
			shake.call(18)
	_bolt.queue_redraw()


func _draw_bolt() -> void:
	if _bolt_points.size() < 2:
		return
	var glow: Color = palette[2]
	glow.a = 0.55
	_bolt.draw_polyline(_bolt_points, glow, 8.0 * _px)
	_bolt.draw_polyline(_bolt_points, palette[3], 3.0 * _px)
	_bolt.draw_polyline(_branch_points, glow, 5.0 * _px)
	_bolt.draw_polyline(_branch_points, palette[3], 2.0 * _px)
	# The crest flares where the bolt lands.
	var tip := _bolt_points[_bolt_points.size() - 1]
	for r in [6, 4, 2]:
		var c: Color = palette[3] if r == 2 else palette[2]
		c.a = 0.35 if r == 6 else (0.6 if r == 4 else 1.0)
		_bolt.draw_rect(Rect2(tip - Vector2(r, r) * _px, Vector2(r, r) * 2 * _px), c)
