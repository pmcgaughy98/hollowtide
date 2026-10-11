extends RefCounted
## The Hollow's first floor, the valley (Claude, 2026-10-10; Preston: the Hollow is "a small, sheltered
## valley or dip between hills", and the structure rose from the river "with a stone pathway to it").
## Drawn in code like the pond and the stone, no generated art: the open ground is meadow, deep green
## with flowers and tall tufts; the halls between are the stone pathway, worn slabs set in the grass;
## the walls are the hills seen from above, rolling turf shaded by its slope, with bushes, trees and
## rocks breaking through, and a grassy earth bank where a hill meets the floor.
##   Painter.paint(data, t, seed) -> Image

const Gen := preload("res://scripts/hollow/hollow_gen.gd")
const R := preload("res://scripts/dungeon/ruin_painter.gd")   # its hash and noise

const MEADOW := [Color("#4f7a36"), Color("#5b8a3c"), Color("#67974a")]
const TUFT := Color("#86b25a")
const TUFT_LO := Color("#3e6229")
const FLOWERS := [Color("#f2a7c3"), Color("#fff4e8"), Color("#f2d16b"), Color("#b9a3e8")]
const SLAB := [Color("#8f8b7a"), Color("#85816f"), Color("#9a9584")]
const SEAM := Color("#57604a")
const HILL := [Color("#2c4721"), Color("#3b5c2b"), Color("#4f7637")]
const LEAF := [Color("#2f4d24"), Color("#3f6a2c"), Color("#5a8a3a")]
const TRUNK := Color("#4a3220")
const ROCK := [Color("#7d7a6c"), Color("#9a9686"), Color("#5d5b50")]
const EARTH := [Color("#6b5238"), Color("#7d6142"), Color("#5a4430")]


static func paint(data: Dictionary, t: int, seed_value: int) -> Image:
	var w: int = data["w"]
	var h: int = data["h"]
	var tiles: PackedByteArray = data["tiles"]
	var img := Image.create(w * t, h * t, false, Image.FORMAT_RGBA8)
	var s := seed_value % 983
	var room := PackedByteArray()
	room.resize(w * h)
	for rr in data["rooms"]:
		var r: Rect2i = rr
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				if x >= 0 and y >= 0 and x < w and y < h:
					room[y * w + x] = 1
	for ty in h:
		for tx in w:
			if tiles[ty * w + tx] == Gen.WALL:
				continue
			if room[ty * w + tx] == 1:
				_meadow_tile(img, tx, ty, t, s)
			else:
				_path_tile(img, tx, ty, t, s)
	_hills(img, data, t, s)
	for y in h:
		for x in w:
			if tiles[y * w + x] != Gen.WALL and y > 0 and tiles[(y - 1) * w + x] == Gen.WALL:
				for k in 4:
					R._darken(img, Rect2i(x * t, y * t + k, t, 1), 0.6 + 0.1 * k)   # the hill's shadow
	# The way on: a dark cleft in the ground with stone steps going down into the structure.
	var st: Vector2i = data["stairs"]
	var p := Vector2i(st.x * t + t / 2 - 10, st.y * t + t / 2 - 8)
	img.fill_rect(Rect2i(p - Vector2i(2, 2), Vector2i(24, 20)), SEAM)
	img.fill_rect(Rect2i(p, Vector2i(20, 16)), Color(0.04, 0.05, 0.05))
	for k in 3:
		img.fill_rect(Rect2i(p + Vector2i(2 + k * 2, 2 + k * 5), Vector2i(16 - k * 4, 2)), SLAB[2].lightened(0.1 - k * 0.05))
	return img


## Meadow: two greens from soft noise, short blades, tall tufts and flowers here and there.
static func _meadow_tile(img: Image, tx: int, ty: int, t: int, s: int) -> void:
	for py in t:
		for px in t:
			var x := tx * t + px
			var y := ty * t + py
			var n := R._noise(x + s * 7, y, 18.0, 70)
			var c: Color = MEADOW[0].lerp(MEADOW[2], n)
			if (x * 3 + y * 7) % 11 == 0 and R._h(x, y, 71) > 0.3:
				c = c.lightened(0.1)   # a blade catching the light
			elif R._h(x, y, 72) > 0.94:
				c = c.darkened(0.15)
			img.set_pixel(x, y, c)
	# Tall tufts: a few upright blades with a dark root.
	for k in 3:
		if R._h(tx * 5 + k, ty, 73 + s) < 0.55:
			continue
		var bx := tx * t + 3 + int(R._h(tx, ty * 3 + k, 74) * (t - 6))
		var by := ty * t + 5 + int(R._h(tx * 3 + k, ty, 75) * (t - 8))
		for b in [-1, 0, 1]:
			var hgt := 3 + (1 if b == 0 else 0)
			for q in hgt:
				img.set_pixel(bx + b, by - q, TUFT if q > 0 else TUFT_LO)
	# Flowers.
	for k in 2:
		if R._h(tx + k * 9, ty, 76 + s) < 0.75:
			continue
		var fx := tx * t + 3 + int(R._h(tx, ty + k, 77) * (t - 6))
		var fy := ty * t + 3 + int(R._h(tx + k, ty, 78) * (t - 6))
		var col: Color = FLOWERS[int(R._h(tx, ty, 79 + k) * FLOWERS.size())]
		for o in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			img.set_pixel(fx + o.x, fy + o.y, col)
		img.set_pixel(fx, fy, Color("#e8b84a"))


## The stone pathway: two worn stepping stones a tile, uneven in size and place, grass between them.
static func _path_tile(img: Image, tx: int, ty: int, t: int, s: int) -> void:
	_meadow_tile(img, tx, ty, t, s)
	for k in 2:
		var rw := 5 + int(R._h(tx * 2 + k, ty, 80) * 3)
		var rh := 4 + int(R._h(tx, ty * 2 + k, 81) * 3)
		var cx := tx * t + (6 if k == 0 else 17) + int(R._h(tx + k, ty, 82) * 3) - 1
		var cy := ty * t + (7 if k == 0 else 16) + int(R._h(tx, ty + k, 83) * 3) - 1
		var c: Color = SLAB[int(R._h(tx * 3 + k, ty, 84) * SLAB.size())]
		for dy in range(-rh, rh + 1):
			for dx in range(-rw, rw + 1):
				var e := pow(absf(dx) / (rw + 0.5), 2.0) + pow(absf(dy) / (rh + 0.5), 2.0) + (R._h(cx + dx, cy + dy, 85) - 0.5) * 0.25
				if e > 1.0:
					continue
				var pc := c
				if e > 0.78:
					pc = c.darkened(0.3) if dy >= 0 else c.lightened(0.06)
				elif dx + dy < -rw * 0.4:
					pc = c.lightened(0.1)
				elif R._h(cx + dx, cy + dy, 86) > 0.92:
					pc = c.darkened(0.12)
				img.set_pixel(cx + dx, cy + dy, pc)
			# A shadow on the grass under its near edge.
		for dx in range(-rw + 1, rw):
			var sy := cy + rh + 1
			if sy < img.get_height():
				img.set_pixel(cx + dx, sy, img.get_pixel(cx + dx, sy).darkened(0.3))


## The hills: turf shaded by the slope (lighter toward the floor it rolls down to), with bushes, trees
## and rocks, and a grassy earth bank where a hill meets the floor below.
static func _hills(img: Image, data: Dictionary, t: int, s: int) -> void:
	var w: int = data["w"]
	var h: int = data["h"]
	var tiles: PackedByteArray = data["tiles"]
	var dist := PackedInt32Array()
	dist.resize(w * h)
	for i in w * h:
		dist[i] = 0 if tiles[i] != Gen.WALL else 99
	for pass_n in 6:   # how far each hill tile is from open ground, for the slope's light
		for y in h:
			for x in w:
				var i := y * w + x
				if dist[i] == 0:
					continue
				var best := dist[i]
				for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var xx: int = x + d.x
					var yy: int = y + d.y
					if xx >= 0 and yy >= 0 and xx < w and yy < h:
						best = mini(best, dist[yy * w + xx] + 1)
				dist[i] = best
	for ty in h:
		for tx in w:
			if tiles[ty * w + tx] != Gen.WALL:
				continue
			for py in t:
				for px in t:
					var x := tx * t + px
					var y := ty * t + py
					var height := _height(dist, w, h, (x + 0.5) / t - 0.5, (y + 0.5) / t - 0.5)
					var n := R._noise(x + s, y + s, 22.0, 83)
					var c: Color = HILL[2].lerp(HILL[0], clampf(height + (n - 0.5) * 0.35, 0.0, 1.0))
					if (x * 3 + y * 7) % 13 == 0 and R._h(x, y, 84) > 0.5:
						c = c.lightened(0.07)
					img.set_pixel(x, y, c)
	# A lit rim where a hill meets the floor beside or below it.
	var W := img.get_width()
	var H := img.get_height()
	for ty in h:
		for tx in w:
			if tiles[ty * w + tx] != Gen.WALL:
				continue
			for d in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1)]:
				var xx: int = tx + d.x
				var yy: int = ty + d.y
				if xx < 0 or yy < 0 or xx >= w or yy >= h or tiles[yy * w + xx] == Gen.WALL:
					continue
				for k in t:
					var px: int = tx * t + (k if d.y != 0 else (0 if d.x < 0 else t - 1))
					var py: int = ty * t + (0 if d.y != 0 else k)
					img.set_pixel(px, py, HILL[2].lightened(0.12))
					var qx: int = px + d.x
					var qy: int = py + d.y
					if qx >= 0 and qy >= 0 and qx < W and qy < H:
						img.set_pixel(qx, qy, img.get_pixel(qx, qy).darkened(0.35))   # its edge shadow on the floor
	# Woods on the high ground: big overlapping canopies; bushes and rocks on the lower slopes.
	for gy in range(-4, H, 9):
		for gx in range(-4, W, 9):
			var cx := gx + int(R._h(gx, gy, 85 + s) * 8)
			var cy := gy + int(R._h(gx, gy, 86 + s) * 8)
			var tx := clampi(cx / t, 0, w - 1)
			var ty := clampi(cy / t, 0, h - 1)
			if tiles[ty * w + tx] != Gen.WALL:
				continue
			var d := dist[ty * w + tx]
			var r := R._h(gx, gy, 87 + s)
			if d >= 2 and r > 0.25:
				_tree(img, cx, cy, 6 + int(R._h(gx, gy, 88) * 4), r > 0.7)
			elif d == 1 and r > 0.7:
				_tree(img, cx, cy, 3 + int(R._h(gx, gy, 88) * 2), false)
			elif d == 1 and r < 0.12:
				_rock(img, cx, cy, 2 + int(R._h(gx, gy, 89) * 2))
	# The bank where a hill meets the floor below it: earth under a grassy lip.
	var face_h := int(t * 0.45)
	for ty in h:
		for tx in w:
			if tiles[ty * w + tx] != Gen.WALL or ty + 1 >= h or tiles[(ty + 1) * w + tx] == Gen.WALL:
				continue
			var y0 := ty * t + t - face_h
			for px in t:
				var x := tx * t + px
				var lip := 1 + int(R._h(x, ty, 90) * 2.5)
				for k in face_h:
					var c: Color
					if k < lip:
						c = HILL[2].lightened(0.06)
					else:
						c = EARTH[int(R._h(x, k + ty, 91) * EARTH.size())]
						if k >= face_h - 1:
							c = c.darkened(0.4)
					img.set_pixel(x, y0 + k, c)


## The hill's height at a point between tile centres, blended so its shading has no tile edges.
static func _height(dist: PackedInt32Array, w: int, h: int, fx: float, fy: float) -> float:
	var x0 := clampi(int(floorf(fx)), 0, w - 1)
	var y0 := clampi(int(floorf(fy)), 0, h - 1)
	var x1 := clampi(x0 + 1, 0, w - 1)
	var y1 := clampi(y0 + 1, 0, h - 1)
	var ax := clampf(fx - floorf(fx), 0.0, 1.0)
	var ay := clampf(fy - floorf(fy), 0.0, 1.0)
	var v := lerpf(lerpf(dist[y0 * w + x0], dist[y0 * w + x1], ax), lerpf(dist[y1 * w + x0], dist[y1 * w + x1], ax), ay)
	return clampf(v / 5.0, 0.0, 1.0)


static func _tree(img: Image, cx: int, cy: int, r: int, round_tree: bool) -> void:
	var W := img.get_width()
	var H := img.get_height()
	# Shadow first, then a canopy of three greens lit from the top-left.
	for dy in range(-r, r + 2):
		for dx in range(-r, r + 3):
			if dx * dx + dy * dy <= r * r and cx + dx + 2 < W and cy + dy + 2 < H and cx + dx + 2 >= 0 and cy + dy + 2 >= 0:
				var p := Vector2i(cx + dx + 2, cy + dy + 2)
				img.set_pixel(p.x, p.y, img.get_pixel(p.x, p.y).darkened(0.35))
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			var dd := dx * dx + dy * dy
			if dd > r * r or cx + dx < 0 or cy + dy < 0 or cx + dx >= W or cy + dy >= H:
				continue
			var c: Color = LEAF[1]
			if dx + dy < -r * 0.6:
				c = LEAF[2]
			elif dx + dy > r * 0.6:
				c = LEAF[0]
			if dd > (r - 1) * (r - 1) and dx + dy > 0:
				c = LEAF[0].darkened(0.2)
			if round_tree and R._h(cx + dx, cy + dy, 92) > 0.85:
				c = c.lightened(0.12)
			img.set_pixel(cx + dx, cy + dy, c)


static func _rock(img: Image, cx: int, cy: int, r: int) -> void:
	var W := img.get_width()
	var H := img.get_height()
	for dy in range(-r, r + 1):
		for dx in range(-r - 1, r + 2):
			if dx * dx + dy * dy * 2 <= r * r + 2 and cx + dx >= 0 and cy + dy >= 0 and cx + dx < W and cy + dy < H:
				var c: Color = ROCK[0]
				if dx < 0 and dy < 0:
					c = ROCK[1]
				elif dx > 0 and dy >= 0:
					c = ROCK[2]
				img.set_pixel(cx + dx, cy + dy, c)
