extends RefCounted
## Rootbank's exposed bank and the Shortcut Crew's rooted den.
## Presentation only: every painted pixel stays on a WALL tile. The original
## clay, pools, grass, pebbles, stair footprint and navigation remain untouched.
const Gen := preload("res://scripts/hollow/hollow_gen.gd")
const ClayNoise := preload("res://scripts/dungeon/ruin_painter.gd")
const BARK := Color("#3f2a19")
const BARK_MID := Color("#6f4c30")
const BARK_LIT := Color("#8a6440")
const BARK_EDGE := Color("#251d17")
const TURF := Color("#33402a")
const LEAF := Color("#57783a")
const LEAF_LIT := Color("#6f8f4e")
## A bank's face fills its wall tile but for this many rows of turf at the top (Claude, 2026-10-26, pass 7 F1, L7-12);
## riverbank_painter.gd paints the face to this height and _bank hangs the root mat from its lip.
const FACE_TOP := 3

static func finish(img: Image, data: Dictionary, t: int, seed_value: int) -> Image:
	if t != 24: return img
	# The clay reveals on east/west faces (_edges) are now part of every bank edge's rim, drawn from the shared wall
	# field in riverbank_painter.gd's _walls (Claude, 2026-10-24, pass 5 A3), so they are not drawn twice.
	# Roots originate in connected banks rather than repeating once per tile.
	for y in data.h:
		var x := 0
		while x < data.w:
			if not _back(data, x, y):
				x += 1
				continue
			var first := x
			while x < data.w and _back(data, x, y): x += 1
			_bank(img, data, t, first, x, y, seed_value)
	# Fixed crew arena: two old roots brace the dug-out ceiling and side banks.
	# Recognise its existing geometry; no dungeon/controller or save dependency.
	if is_den(data): _den(img, data, t, data.rooms[0])
	else: _lip_roots(img, data, t, seed_value)   # pass 7 F1
	return img

## The crew's den: one 13 x 10 room. riverbank_painter.gd asks too, to keep bank all round the den for the arch's
## roots to stand on (Claude, 2026-10-24, pass 5 A3).
static func is_den(data: Dictionary) -> bool:
	if data.rooms.size() != 1: return false
	var room: Rect2i = data.rooms[0]
	return room.size == Vector2i(13, 10)

static func _wall(data: Dictionary, x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < data.w and y < data.h and data.tiles[y * data.w + x] == Gen.WALL

static func _back(data: Dictionary, x: int, y: int) -> bool:
	return _wall(data, x, y) and y + 1 < data.h and not _wall(data, x, y + 1)

static func _pixel(img: Image, data: Dictionary, t: int, p: Vector2i, c: Color) -> void:
	if p.x < 0 or p.y < 0 or p.x >= img.get_width() or p.y >= img.get_height(): return
	if _wall(data, p.x / t, p.y / t): img.set_pixelv(p, c)

static func _disc(img: Image, data: Dictionary, t: int, p: Vector2i, radius: int, c: Color) -> void:
	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			if dx * dx + dy * dy <= radius * radius + 1: _pixel(img, data, t, p + Vector2i(dx, dy), c)

static func _root(img: Image, data: Dictionary, t: int, a: Vector2, b: Vector2, c: Vector2, d: Vector2, width: int) -> void:
	var steps := maxi(12, int(a.distance_to(b) + b.distance_to(c) + c.distance_to(d)) * 2)
	var points: Array[Vector2i] = []
	for k in steps + 1:
		var q := a.bezier_interpolate(b, c, d, float(k) / steps)
		points.append(Vector2i(q.round()))
	# One continuous outline, bark body and upper-left ridge; no dark internal
	# dots scattered on walking ground. Thin twigs retain a one-pixel body.
	for p in points: _disc(img, data, t, p + Vector2i(1, 1), width + 1, BARK_EDGE)
	for p in points: _disc(img, data, t, p, width, BARK)
	if width > 1:
		for p in points: _disc(img, data, t, p + Vector2i(-1, -1), width - 1, BARK_MID)
	for k in points.size():
		if k % 9 < 6: _pixel(img, data, t, points[k] + Vector2i(-width, -1), BARK_LIT)

static func _leaves(img: Image, data: Dictionary, t: int, p: Vector2i) -> void:
	# Small overlapping clover silhouettes at the roots' origin, never confetti.
	for off in [Vector2i(-4, -2), Vector2i(0, -5), Vector2i(4, -2), Vector2i(1, 0)]:
		_disc(img, data, t, p + off + Vector2i(0, 1), 3, TURF)
		_disc(img, data, t, p + off, 2, LEAF)
		_pixel(img, data, t, p + off + Vector2i(-1, -1), LEAF_LIT)

static func _bank(img: Image, data: Dictionary, t: int, first: int, end: int, y: int, seed_value: int) -> void:
	var length := (end - first) * t
	var start := first * t
	var foot := (y + 1) * t - 1
	var lip := foot - (t - FACE_TOP)   # the face's grass lip (was foot - 14 before the face grew, pass 7 F1)
	# A root mat follows the bank above its stratified sediment, with occasional
	# forks reaching down to its foot. Global runs avoid tile-border seams.
	var k := 12
	while k < length:
		var phase := seed_value % 977 + 80
		var bend := ClayNoise._h(start + k, y, phase)
		var px := start + k
		var reach := mini(20 + int(bend * 24), start + length - px - 2)
		var a := Vector2(px, lip - 4 - int(bend * 7))
		_root(img, data, t, a, a + Vector2(-3 - bend * 7, 5), Vector2(px + bend * 14, lip + 6), Vector2(px + 2, foot - 1), 1)
		if reach > 8:
			_root(img, data, t, a, a + Vector2(7, -2), Vector2(px + reach - 9, lip + 5 - bend * 12), Vector2(px + reach, lip + 4 + bend * 7), 1)
			_root(img, data, t, Vector2(px + reach / 2, lip + 1), Vector2(px + reach / 2 - 5, lip + 4), Vector2(px + reach / 2 - 3, foot - 5), Vector2(px + reach / 2 - 9, foot), 0)
		if bend > 0.45: _leaves(img, data, t, Vector2i(px - 5, int(a.y) - 2))
		k += 49 + int(ClayNoise._h(px, y, phase + 1) * 41)

## Roots over the lip where the bank meets the floor beside or below it (Claude, 2026-10-26, pass 7 F1, L7-12): a room's
## sides and south and a hallway's walls get roots like the faces have, about one tile in two, each coming out of the
## turf, crossing the grass lip and ending on the clay rim, with clover at its root now and then. The crew's den has
## its own arch instead. u runs from the rim (0) back into the bank, v along the edge.
static func _lip_roots(img: Image, data: Dictionary, t: int, seed_value: int) -> void:
	var phase := seed_value % 977 + 120
	for y in data.h:
		for x in data.w:
			if not _wall(data, x, y):
				continue
			for n: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)]:
				var fx: int = x + n.x
				var fy: int = y + n.y
				if fx < 0 or fy < 0 or fx >= data.w or fy >= data.h or _wall(data, fx, fy):
					continue
				var roll := ClayNoise._h(x * 3 + n.x, y * 5 + n.y, phase)
				if roll < 0.48:
					continue
				var out := Vector2(-n.x, -n.y)   # from the rim back into the bank
				var along := Vector2(absi(n.y), absi(n.x))
				# The rim: the tile's edge on the floor's side, at a spot along it.
				var rim := Vector2(x * t, y * t) + Vector2(maxi(n.x, 0) * (t - 1), 0) + along * (4 + int(ClayNoise._h(x, y, phase + n.x + 3) * (t - 12)))
				var trail := 1.0 if ClayNoise._h(y, x, phase + 7) > 0.5 else -1.0   # which way it trails along the lip
				# A thin root sweeping out of the turf at a slant, along the lip and over it onto the rim.
				var a := rim + out * 13 + along * (-9 * trail)
				_root(img, data, t, a, rim + out * 9 + along * (-3 * trail), rim + out * 4 + along * (3 * trail), rim + out + along * (10 * trail), 0)
				if roll > 0.9:
					# Now and then a short twig off it, back the other way.
					_root(img, data, t, rim + out * 7 + along * (-1 * trail), rim + out * 5 + along * (-4 * trail), rim + out * 3 + along * (-5 * trail), rim + out * 1 + along * (-8 * trail), 0)
				if roll > 0.86:
					_leaves(img, data, t, Vector2i(a + out * 2))

static func _den(img: Image, data: Dictionary, t: int, room: Rect2i) -> void:
	var left := float(room.position.x * t - 9)
	var right := float(room.end.x * t + 8)
	var top := float(room.position.y * t - 13)
	var mid := (left + right) * 0.5
	var bottom := float(room.end.y * t - 19)
	# The arch lives behind the room: bulky root shoulders settle into the
	# side banks, with a woven crown over the existing back face and stairs.
	_root(img, data, t, Vector2(left, bottom), Vector2(left - 18, top + 75), Vector2(left - 15, top - 33), Vector2(mid + 35, top - 25), 4)
	_root(img, data, t, Vector2(right, bottom - 45), Vector2(right + 16, top + 43), Vector2(right + 10, top - 30), Vector2(mid - 28, top - 15), 4)
	_root(img, data, t, Vector2(left - 6, top + 80), Vector2(left - 29, top + 32), Vector2(left + 15, top - 44), Vector2(mid - 35, top - 36), 2)
	_root(img, data, t, Vector2(right + 5, top + 98), Vector2(right + 29, top + 8), Vector2(right - 9, top - 43), Vector2(mid + 38, top - 35), 2)
	_root(img, data, t, Vector2(mid - 48, top - 35), Vector2(mid - 18, top - 39), Vector2(mid + 9, top - 12), Vector2(mid + 43, top - 25), 1)
	_root(img, data, t, Vector2(mid + 48, top - 35), Vector2(mid + 22, top - 37), Vector2(mid + 5, top - 42), Vector2(mid - 16, top - 29), 1)
	for side in [-1, 1]:
		var shoulder := left if side < 0 else right
		for k in [0, 1, 2]:
			var y: float = top + 40 + k * 55
			_root(img, data, t, Vector2(shoulder, y), Vector2(shoulder + side * 21, y - 7), Vector2(shoulder + side * 23, y + 20), Vector2(shoulder + side * 30, y + 25), 1)
			_leaves(img, data, t, Vector2i(int(shoulder + side * 13), int(y + 11)))
	for k in [0, 1, 2, 3, 4]:
		var x: float = left + 28 + k * 62
		_root(img, data, t, Vector2(x, top - 16), Vector2(x + 15, top - 12), Vector2(x + 1, top + 5), Vector2(x + 10, top + 11), 1)
		_leaves(img, data, t, Vector2i(int(x + 9), int(top - 20)))
