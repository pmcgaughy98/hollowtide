extends RefCounted
const TileArt := preload("res://scripts/dungeon/dungeon_tile_art.gd")
## The Hollow's look (Claude, 2026-10-10; Preston: the Hollow is a structure that "rose from the river with
## a stone pathway to it", and "the pond looks amazing, I wish the rest looked that good"). Drawn in code
## pixel by pixel like the Warden's pond, no generated art: river-washed flagstones with moss in the
## seams, cracks, silt and standing water; walls of carved stone blocks, dark and wet, a green water
## line at their foot where the river once stood. A set of 24 px tiles is drawn once and stamped.
##   Painter.paint(data, t, seed) -> Image, the same call as floor_painter.gd

const Gen := preload("res://scripts/hollow/hollow_gen.gd")

const STONE := [Color("#8e968f"), Color("#979e95"), Color("#a3a89c"), Color("#868f8b"), Color("#9aa39e")]
const SEAM := Color("#3e4542")
const MOSS := Color("#5f7d3c")
const MOSS_LO := Color("#4a6532")
const SILT := Color("#a08c68")
const WATER := Color("#3f6474")
const WATER_HI := Color("#8fb5c2")
const WALL_TOP := Color("#2d3534")
const WALL := [Color("#4a5655"), Color("#43504f"), Color("#51605e")]
const MORTAR := Color("#262c2b")
const LIP := Color("#7b8780")
const ALGAE := Color("#3f5e37")
const ALGAE_HI := Color("#5b7d45")

static var _tiles := {}


static func _h(x: int, y: int, k: int = 0) -> float:
	var n := (x * 374761393 + y * 668265263 + k * 1442695041) & 0x7fffffff
	n = ((n ^ (n >> 13)) * 1274126177) & 0x7fffffff
	return float(n % 1000) / 1000.0


static func _shade(c: Color, k: float) -> Color:
	return Color(c.r * k, c.g * k, c.b * k, c.a)


## One floor tile: two courses of slabs in a running bond, each slab lit on its top-left and shaded
## bottom-right, speckled; some seams grown over with moss, some slabs cracked; extras by kind.
static func _floor_tile(t: int, v: int, kind: String) -> Image:
	var img := Image.create(t, t, false, Image.FORMAT_RGBA8)
	var half := t / 2
	for row in 2:
		var y0 := row * half
		var cut := 6 + int(_h(v, row, 1) * (t - 12))
		var spans := [[0, cut], [cut, t]] if row == 0 else [[0, t - cut], [t - cut, t]]
		for s in spans.size():
			var x0: int = spans[s][0]
			var x1: int = spans[s][1]
			var c: Color = STONE[int(_h(v, row * 3 + s, 2) * STONE.size())]
			for y in range(y0, y0 + half):
				for x in range(x0, x1):
					var px := c
					var n := _h(x + v * 31, y + row * 7, 3)
					if n > 0.9:
						px = _shade(c, 0.9)
					elif n < 0.05:
						px = c.lightened(0.08)
					if y == y0 + 1 or x == x0 + 1:
						px = c.lightened(0.12)
					if y == y0 + half - 2 or x == x1 - 2:
						px = _shade(c, 0.86)
					if y == y0 or x == x0:
						px = SEAM
					img.set_pixel(x, y, px)
			# A crack across some slabs.
			if _h(v, row * 5 + s, 4) > 0.75:
				var cx := x0 + 3 + int(_h(v, s, 5) * maxf(1, x1 - x0 - 6))
				var cy := y0 + 3
				for k in 6:
					if cx >= x0 + 1 and cx < x1 - 1 and cy < y0 + half - 1:
						img.set_pixel(cx, cy, _shade(c, 0.6))
					cx += 1 if _h(v, k, 6) > 0.5 else -1
					cy += 1
	# Moss in the seams, spilling a pixel onto the stone.
	if kind == "moss" or _h(v, 9, 7) > 0.6:
		for x in t:
			for y in t:
				if img.get_pixel(x, y) == SEAM and _h(x + v, y, 8) > (0.35 if kind == "moss" else 0.7):
					img.set_pixel(x, y, MOSS if _h(x, y, 9) > 0.4 else MOSS_LO)
					if y + 1 < t and _h(x, y, 10) > 0.6 and img.get_pixel(x, y + 1) != SEAM:
						img.set_pixel(x, y + 1, MOSS_LO)
	if kind == "silt":
		for y in t:
			for x in t:
				var d := Vector2(x - t * 0.5, (y - t * 0.55) * 1.4).length()
				if d < t * 0.42 + _h(x, y, 11) * 3.0:
					img.set_pixel(x, y, img.get_pixel(x, y).lerp(SILT, 0.55))
	if kind == "puddle":
		for y in t:
			for x in t:
				var d := Vector2(x - t * 0.5, (y - t * 0.5) * 1.6).length()
				if d < t * 0.34:
					var px := WATER if d > 2.0 else WATER.lightened(0.1)
					if y < t * 0.5 - 1 and absf(x - t * 0.42) < 2.5 and d > 3.0:
						px = WATER_HI
					img.set_pixel(x, y, px)
				elif d < t * 0.34 + 1.2:
					img.set_pixel(x, y, _shade(img.get_pixel(x, y), 0.8))
	return img


static func _floor_set(t: int) -> Array:
	var key := "floor%d" % t
	if not _tiles.has(key):
		var set: Array = []
		for v in 14:
			set.append(_floor_tile(t, v, "plain"))
		for v in 4:
			set.append(_floor_tile(t, 20 + v, "moss"))
		for v in 2:
			set.append(_floor_tile(t, 30 + v, "silt"))
		set.append(_floor_tile(t, 40, "puddle"))
		_tiles[key] = set
	return _tiles[key]


static func paint(data: Dictionary, t: int, seed_value: int) -> Image:
	if t == 24: return TileArt.paint(data,t,seed_value,"ruin")
	var w: int = data["w"]
	var h: int = data["h"]
	var tiles: PackedByteArray = data["tiles"]
	var W := w * t
	var H := h * t
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	_slabs(img, seed_value)
	_weather(img, data, t, seed_value)
	for y in h:
		for x in w:
			if tiles[y * w + x] != Gen.WALL and y > 0 and tiles[(y - 1) * w + x] == Gen.WALL:
				for k in 4:
					_darken(img, Rect2i(x * t, y * t + k, t, 1), 0.55 + 0.1 * k)   # the wall's shadow
	_walls(img, data, t)
	# The stairs: a dark way down cut into the flagstones, carved steps.
	var st: Vector2i = data["stairs"]
	var s := Vector2i(st.x * t + t / 2 - 10, st.y * t + t / 2 - 8)
	img.fill_rect(Rect2i(s - Vector2i(2, 2), Vector2i(24, 20)), SEAM)
	img.fill_rect(Rect2i(s, Vector2i(20, 16)), Color(0.04, 0.05, 0.06))
	for k in 3:
		img.fill_rect(Rect2i(s + Vector2i(2 + k * 2, 2 + k * 5), Vector2i(16 - k * 4, 2)), STONE[2].lightened(0.1 - k * 0.05))
	return img


## Flagstones over the whole floor: rows of uneven slabs in a running bond, each slab its own tone,
## lit on the top-left, shaded bottom-right, a few specks, now and then a crack.
static func _slabs(img: Image, seed_value: int) -> void:
	var W := img.get_width()
	var H := img.get_height()
	var y := 0
	var row := 0
	while y < H:
		var rh := 10 + int(_h(row, seed_value, 20) * 6)
		var x := -int(_h(row, seed_value, 21) * 18)
		var k := 0
		while x < W:
			var sw := 16 + int(_h(row * 131 + k, seed_value, 22) * 22)
			var c: Color = STONE[int(_h(row, k, 23) * STONE.size())]
			c = c.lightened((_h(k, row, 24) - 0.5) * 0.12)
			var r := Rect2i(x, y, sw, rh).intersection(Rect2i(0, 0, W, H))
			if r.size.x > 0 and r.size.y > 0:
				img.fill_rect(r, c)
				img.fill_rect(Rect2i(r.position.x, r.position.y + 1, r.size.x, 1), c.lightened(0.1))
				img.fill_rect(Rect2i(r.position.x + 1, r.position.y, 1, r.size.y), c.lightened(0.07))
				img.fill_rect(Rect2i(r.position.x, r.end.y - 1, r.size.x, 1), _shade(c, 0.85))
				img.fill_rect(Rect2i(r.end.x - 1, r.position.y, 1, r.size.y), _shade(c, 0.88))
				img.fill_rect(Rect2i(r.position.x, r.position.y, r.size.x, 1), SEAM)
				img.fill_rect(Rect2i(r.position.x, r.position.y, 1, r.size.y), SEAM)
				for n in 5:
					var p := Vector2i(r.position.x + 2 + int(_h(n, k * 7 + row, 25) * maxi(1, r.size.x - 4)), r.position.y + 2 + int(_h(n, k + row * 3, 26) * maxi(1, r.size.y - 4)))
					if r.has_point(p):
						img.set_pixel(p.x, p.y, _shade(c, 0.88) if n % 2 == 0 else c.lightened(0.06))
				if _h(k, row, 27) > 0.88:   # a crack, a few pixels wandering down the slab
					var cx := r.position.x + 3 + int(_h(k, row, 28) * maxi(1, r.size.x - 6))
					for q in mini(r.size.y - 2, 7):
						if cx > r.position.x and cx < r.end.x - 1:
							img.set_pixel(cx, r.position.y + 1 + q, _shade(c, 0.62))
						cx += (1 if _h(q, k, 29) > 0.6 else (-1 if _h(q, k, 29) < 0.3 else 0))
			x += sw
			k += 1
		y += rh
		row += 1


## Smooth noise for the stains: hashed points on a coarse grid, blended between.
static func _noise(x: float, y: float, cell: float, k: int) -> float:
	var gx := floorf(x / cell)
	var gy := floorf(y / cell)
	var fx := x / cell - gx
	var fy := y / cell - gy
	fx = fx * fx * (3.0 - 2.0 * fx)
	fy = fy * fy * (3.0 - 2.0 * fy)
	var a := _h(int(gx), int(gy), k)
	var b := _h(int(gx) + 1, int(gy), k)
	var c := _h(int(gx), int(gy) + 1, k)
	var d := _h(int(gx) + 1, int(gy) + 1, k)
	return lerpf(lerpf(a, b, fx), lerpf(c, d, fx), fy)


## Weather over the stones, in 2-pixel blocks: silt washed into soft stains, moss creeping out of the
## seams (more of it near the walls), and a few shallow pools left by the river.
static func _weather(img: Image, data: Dictionary, t: int, seed_value: int) -> void:
	var w: int = data["w"]
	var tiles: PackedByteArray = data["tiles"]
	var W := img.get_width()
	var H := img.get_height()
	var s := seed_value % 911
	for by in range(0, H, 2):
		for bx in range(0, W, 2):
			var tx := bx / t
			var ty := by / t
			if tiles[ty * w + tx] == Gen.WALL:
				continue
			var near_wall := false
			for d in [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1)]:
				var q := Vector2i((bx + d.x * 5) / t, (by + d.y * 5) / t)
				if q.x >= 0 and q.y >= 0 and q.x < w and q.y < data["h"] and tiles[q.y * w + q.x] == Gen.WALL:
					near_wall = true
			var silt := _noise(bx + s * 13, by, 40.0, 30)
			var moss := _noise(bx, by + s * 7, 28.0, 31) + (0.18 if near_wall else 0.0)
			var pool := _noise(bx + s * 3, by + s * 5, 34.0, 32)
			for dy in 2:
				for dx in 2:
					var x := bx + dx
					var y := by + dy
					if x >= W or y >= H:
						continue
					var c: Color = img.get_pixel(x, y)
					if pool > 0.84:
						var edge := pool < 0.855
						c = WATER.lightened(0.04 if pool < 0.88 else 0.0) if not edge else _shade(c, 0.72)
						if not edge and pool > 0.862 and pool < 0.868 and _h(x, y, 33) > 0.5:
							c = WATER_HI   # a broken glint along the shore
					else:
						if silt > 0.66:
							c = c.lerp(SILT, clampf((silt - 0.66) * 2.2, 0.0, 0.5))
						if moss > 0.74 or (moss > 0.71 and (x + y) % 2 == 0):
							# Solid clumps, two tones from a second, finer noise; a dithered rim.
							c = MOSS if _noise(x, y, 6.0, 36) > 0.45 else MOSS_LO
						elif moss > 0.66 and c.v < 0.3:
							c = MOSS_LO   # moss starting in the seams around a clump
					img.set_pixel(x, y, c)


## Walls: the top of carved masonry seen from above, a lit lip where it meets the floor, and where a
## wall stands above floor, its face: courses of blocks, mortar, and a green water line at the foot.
static func _walls(img: Image, data: Dictionary, t: int) -> void:
	var w: int = data["w"]
	var h: int = data["h"]
	var tiles: PackedByteArray = data["tiles"]
	var face_h: int = int(t * 0.6)
	for y in h:
		for x in w:
			if tiles[y * w + x] != Gen.WALL:
				continue
			for py in t:
				for px in t:
					var gx := x * t + px
					var gy := y * t + py
					# Rough dark stone, big blocks with faint joints and soft light and dark patches.
					var c := WALL_TOP.lightened((_noise(gx, gy, 10.0, 16) - 0.5) * 0.12)
					var row := gy / 16
					if gy % 16 == 0 or (gx + int(_h(row, 0, 37) * 24)) % 30 == 0:
						c = _shade(c, 0.88)
					img.set_pixel(gx, gy, c)
			var fl := func(dx: int, dy: int) -> bool:
				var xx := x + dx
				var yy := y + dy
				return xx >= 0 and yy >= 0 and xx < w and yy < h and tiles[yy * w + xx] == Gen.FLOOR
			if fl.call(-1, 0):
				img.fill_rect(Rect2i(x * t, y * t, 1, t), LIP)
			if fl.call(1, 0):
				img.fill_rect(Rect2i(x * t + t - 1, y * t, 1, t), LIP)
			if fl.call(0, -1):
				img.fill_rect(Rect2i(x * t, y * t, t, 2), LIP)
			if fl.call(0, 1):
				var y0: int = y * t + t - face_h
				img.fill_rect(Rect2i(x * t, y0 - 1, t, 1), LIP.lightened(0.15))
				for k in face_h:
					var course := k / 5
					for px in t:
						var off := 4 if course % 2 == 1 else 0
						var c: Color = WALL[int(_h(x * 3 + (px + off) / 8, y * 5 + course, 17) * WALL.size())]
						if k % 5 == 4 or (px + off) % 8 == 0:
							c = MORTAR
						elif k % 5 == 0:
							c = c.lightened(0.08)
						# The water line: algae on the lowest courses, drips running down into it.
						if k >= face_h - 4:
							c = ALGAE if _h(x * t + px, k, 18) > 0.3 else ALGAE_HI
						elif k >= face_h - 8 and _h(x * t + px, 0, 19) > 0.82:
							c = ALGAE
						if k == face_h - 1:
							c = Color(0.06, 0.07, 0.06)
						img.set_pixel(x * t + px, y0 + k, c)


static func _darken(img: Image, r: Rect2i, k: float) -> void:
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			var c: Color = img.get_pixel(x, y)
			img.set_pixel(x, y, Color(c.r * k, c.g * k, c.b * k))
