extends Node2D

## A river of molten glass that flows along the ground from an attacker's pool
## to its target's feet (Vitrecrag's Molten Glass).
##
## It is drawn from squares the size of one art pixel (the attacker's zoom), so
## it stays crisp and matches the sprites' pixel grid, and it can bend, grow and
## move in ways a fixed sprite cannot. Layers from outside in: dark outline,
## cooling edge, orange body, pale core, with bright bands travelling along the
## core toward the target so it reads as flowing. The head is a swollen lobe.
## When the pour stops, the river cools from the source end first into crust
## with a few glowing cracks, then fades.
##
## Call flow() once; the node frees itself when it has cooled.

@export var outline := Color("#3a1410")
@export var edge := Color("#dc5c24")
@export var body := Color("#fc7424")
@export var core := Color("#fc9c4c")
@export var hot := Color("#fcc870")
@export var crust := Color("#4a2420")
@export var crack := Color("#9c3414")

## Half-width in art pixels at the far end (up the screen) and the near end.
@export var far_width := 5.0
@export var near_width := 9.0
## How far the river wanders sideways, in art pixels.
@export var meander := 6.0
@export var cool_seconds := 0.9

var _px := 3.0
var _advance := 0.4
var _sustain := 1.0
var _time := 0.0
var _path: Array[Vector2] = []  # in art pixels, stage coordinates
var _min_y := 0.0
var _max_y := 1.0


## start and end are stage positions; px is the size of one art pixel on screen.
## The head takes advance seconds to reach the end, then the river keeps
## flowing for sustain seconds before it cools.
func flow(start: Vector2, end: Vector2, px: float, advance: float, sustain: float) -> void:
	_px = maxf(1.0, px)
	_advance = maxf(0.1, advance)
	_sustain = maxf(0.0, sustain)
	var a: Vector2 = start / _px
	var b: Vector2 = end / _px
	var steps: int = maxi(2, int(a.distance_to(b)))
	var across: Vector2 = (b - a).normalized().orthogonal()
	_path.clear()
	for i in steps + 1:
		var t: float = float(i) / steps
		# Wanders in gentle curves, pinned at both ends.
		var wander: float = sin(t * PI * 1.6) * sin(t * PI) * meander
		_path.append(a.lerp(b, t) + across * wander)
	_min_y = minf(a.y, b.y)
	_max_y = maxf(a.y, b.y) + 0.001
	_time = 0.0


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()
	if _time > _advance + _sustain + cool_seconds:
		queue_free()


var _stamps := {}


## The cells of one flattened lump of half-width w, as flat [dx, dy, layer, ...]
## triples (0 outline, 1 edge, 2 body, 3 core). Worked out once per width in
## half-pixel steps and reused, which keeps drawing the river cheap.
func _stamp(w: float) -> Array:
	var key: int = roundi(w * 2.0)
	if _stamps.has(key):
		return _stamps[key]
	var rx: float = key / 2.0
	var ry: float = maxf(1.0, rx * 0.5)  # flattened: it lies on the ground
	var cells: Array = []
	for dy in range(-int(ry) - 2, int(ry) + 3):
		for dx in range(-int(rx) - 2, int(rx) + 3):
			if pow(dx / (rx + 1.0), 2) + pow(dy / (ry + 1.0), 2) > 1.0:
				continue
			var d: float = pow(dx / rx, 2) + pow(dy / ry, 2)
			var l: int = 0
			if d <= 1.0:
				l = 1
			if d <= 0.55:
				l = 2
			if d <= 0.18:
				l = 3
			cells.append_array([dx, dy, l])
	_stamps[key] = cells
	return cells


func _draw() -> void:
	if _path.is_empty():
		return
	var n: int = _path.size()
	# Viscous: the head starts quickly and slows as it spreads.
	var head: float = 1.0 - pow(1.0 - clampf(_time / _advance, 0.0, 1.0), 2.0)
	var last: int = int(head * (n - 1))
	var cooling: float = clampf((_time - _advance - _sustain) / cool_seconds, 0.0, 1.0)
	var arrived_for: float = _time - _advance
	var layer := {}   # Vector2i cell -> 0 outline, 1 edge, 2 body, 3 core
	var hot_cells := {}
	var point_of := {}  # cell -> index along the path, for cooling from the source
	# Every other point: the lumps overlap by several pixels, so nothing shows a gap.
	for i in range(0, last + 1, 2):
		var p: Vector2 = _path[i]
		var near: float = clampf((p.y - _min_y) / (_max_y - _min_y), 0.0, 1.0)
		var w: float = lerpf(far_width, near_width, near)
		# Lumps that roll toward the target, plus a fixed ragged edge, so it reads
		# as heavy molten glass rather than a clean beam.
		w *= 1.0 + 0.22 * sin(i * 0.35 - _time * 7.0)
		w *= 1.0 + 0.12 * sin(i * 1.7 + 0.5) * sin(i * 0.9)
		if i > last - 5:
			w *= 1.3  # the swollen head
		if arrived_for > 0.0 and arrived_for < 0.3 and i > n - 8:
			w *= 1.0 + 0.6 * (1.0 - arrived_for / 0.3)  # surges at the target's feet
		var flowing: bool = fposmod(i * 0.1 - _time * 3.0, 1.0) < 0.22
		var cx: int = roundi(p.x)
		var cy: int = roundi(p.y)
		var stamp: Array = _stamp(w)
		for k in range(0, stamp.size(), 3):
			var l: int = stamp[k + 2]
			var cell := Vector2i(cx + stamp[k], cy + stamp[k + 1])
			if l > int(layer.get(cell, -1)):
				layer[cell] = l
				point_of[cell] = i
			if l == 3 and flowing:
				hot_cells[cell] = true
	var fade: float = 1.0 - clampf((cooling - 0.6) / 0.4, 0.0, 1.0)
	for cell in layer:
		var l: int = layer[cell]
		var c: Color = [outline, edge, body, core][l]
		if hot_cells.has(cell) and cooling == 0.0:
			c = hot
		# Cools from the source end first.
		var along: float = float(point_of[cell]) / (n - 1)
		if cooling > 0.0 and along < cooling * 1.4:
			c = crust if l < 2 or (cell.x + cell.y * 3) % 7 != 0 else crack
			if l == 0:
				c = outline
		c.a = fade
		draw_rect(Rect2(Vector2(cell) * _px, Vector2(_px, _px)), c)
