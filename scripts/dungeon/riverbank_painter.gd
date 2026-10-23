extends RefCounted
const RootbankDetail := preload("res://scripts/dungeon/rootbank_detail.gd")
const TileArt := preload("res://scripts/dungeon/dungeon_tile_art.gd")
# Codex's flat 24px tile sheets (2026-10-10) are switched off: Preston, 2026-10-11, wants the hand-painted,
# textured stones and grass back, the look that matches the boss room. Set true to use the sheets again.
const USE_TILE_ART := false
## The first dungeon's look (Claude, 2026-10-10; Preston: "do what you did for dungeon 1", after the
## Hollow's stone). Tunnels cut through a river bank, drawn in code pixel by pixel like the Hollow and
## the pond, no generated art: packed clay floors with pebbles, sand washed into rippled patches,
## grass and clover where light gets in near the walls, roots crossing the ground, a rare muddy pool;
## walls of banded river sediment with the turf on top and roots hanging off the lip.
## Codex's atlas bank (hollow_bank_painter.gd) is untouched; the dungeon list picks a look per floor.
##   Painter.paint(data, t, seed) -> Image

const Gen := preload("res://scripts/hollow/hollow_gen.gd")
const R := preload("res://scripts/dungeon/ruin_painter.gd")   # its hash and noise
const V := preload("res://scripts/dungeon/valley_painter.gd")   # the one grass ramp (WORLD-02)

const CLAY := [Color("#7c6147"), Color("#8a6d4f"), Color("#95795a")]
const SPECK_LO := Color("#5e4836")
const SAND := Color("#b8a27c")
const SAND_HI := Color("#cdb994")
const PEBBLE := [Color("#9c9890"), Color("#86827a"), Color("#a39684")]
const PEB_HI := Color("#c9c4b8")
const PEB_LO := Color("#4a4640")
const GRASS: Array = V.MEADOW   # Claude, 2026-10-22 (WORLD-02): the valley's meadow, one grass for the whole world
const ROOT := Color("#3f2a19")
const ROOT_HI := Color("#8a6440")
const POOL := Color("#4e5a4c")
const POOL_HI := Color("#8c9a86")
const TURF := [Color("#33402a"), Color("#3c4a2f"), Color("#46553a")]
const BANDS := [Color("#8f6a48"), Color("#a78560"), Color("#6f5540"), Color("#9c7b5a"), Color("#5f4a39")]


static func paint(data: Dictionary, t: int, seed_value: int) -> Image:
	if USE_TILE_ART and t == 24: return TileArt.paint(data,t,seed_value,"riverbank")
	var w: int = data["w"]
	var h: int = data["h"]
	var tiles: PackedByteArray = data["tiles"]
	var img := Image.create(w * t, h * t, false, Image.FORMAT_RGBA8)
	var s := seed_value % 977
	_ground(img, data, t, s)
	_pebbles_and_roots(img, data, t, s)
	for y in h:
		for x in w:
			if tiles[y * w + x] != Gen.WALL and y > 0 and tiles[(y - 1) * w + x] == Gen.WALL:
				for k in 4:
					R._darken(img, Rect2i(x * t, y * t + k, t, 1), 0.55 + 0.1 * k)   # the bank's shadow
	_walls(img, data, t, s)
	# The way down: a dark hole in the clay, worn steps of packed earth.
	var st: Vector2i = data["stairs"]
	var p := Vector2i(st.x * t + t / 2 - 10, st.y * t + t / 2 - 8)
	img.fill_rect(Rect2i(p - Vector2i(2, 2), Vector2i(24, 20)), SPECK_LO)
	img.fill_rect(Rect2i(p, Vector2i(20, 16)), Color(0.05, 0.04, 0.03))
	for k in 3:
		img.fill_rect(Rect2i(p + Vector2i(2 + k * 2, 2 + k * 5), Vector2i(16 - k * 4, 2)), CLAY[2].lightened(0.15 - k * 0.05))
	return RootbankDetail.finish(img, data, t, seed_value)


static func _floor(tiles: PackedByteArray, w: int, h: int, x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < w and y < h and tiles[y * w + x] != Gen.WALL


## One of R._noise's soft noises laid out once over the whole floor (Claude, 2026-10-22, CR-01): R._noise hashes
## the four lattice corners around a pixel on every call, which was most of the Warren's build time. Here the
## corners are hashed once into a grid, with each column's lattice index and eased fraction and each row's, so a
## pixel reads four numbers and does R._noise's own arithmetic on them. The floor is the same pixel for pixel.
## Returns [corner grid, grid width, column index per x, eased fx per x, row start per y, eased fy per y].
static func _layer(ox: int, oy: int, W: int, H: int, cell: float, k: int) -> Array:
	var gx0 := int(floorf(float(ox) / cell))
	var gy0 := int(floorf(float(oy) / cell))
	var lw := int(floorf(float(W - 1 + ox) / cell)) - gx0 + 2
	var lh := int(floorf(float(H - 1 + oy) / cell)) - gy0 + 2
	var lat := PackedFloat64Array()
	lat.resize(lw * lh)
	for j in lh:
		for i in lw:
			lat[j * lw + i] = R._h(gx0 + i, gy0 + j, k)
	var col := PackedInt32Array()
	var fxs := PackedFloat64Array()
	col.resize(W)
	fxs.resize(W)
	for x in W:
		var xf := float(x + ox)
		var gx := floorf(xf / cell)
		var fx := xf / cell - gx
		fxs[x] = fx * fx * (3.0 - 2.0 * fx)
		col[x] = int(gx) - gx0
	var row := PackedInt32Array()
	var fys := PackedFloat64Array()
	row.resize(H)
	fys.resize(H)
	for y in H:
		var yf := float(y + oy)
		var gy := floorf(yf / cell)
		var fy := yf / cell - gy
		fys[y] = fy * fy * (3.0 - 2.0 * fy)
		row[y] = (int(gy) - gy0) * lw
	return [lat, lw, col, fxs, row, fys]


## Clay, sand and grass, pixel by pixel from soft noise; a rare pool.
static func _ground(img: Image, data: Dictionary, t: int, s: int) -> void:
	var w: int = data["w"]
	var h: int = data["h"]
	var tiles: PackedByteArray = data["tiles"]
	# The four noises every pixel reads (tone, sand, grass, pool), laid out once; see _layer.
	var W := w * t
	var H := h * t
	var L1 := _layer(s * 11, 0, W, H, 26.0, 40)
	var L2 := _layer(0, s * 5, W, H, 34.0, 42)
	var L3 := _layer(s * 3, 0, W, H, 14.0, 44)
	var L4 := _layer(s * 7, s, W, H, 30.0, 48)
	var lat1: PackedFloat64Array = L1[0]
	var lat2: PackedFloat64Array = L2[0]
	var lat3: PackedFloat64Array = L3[0]
	var lat4: PackedFloat64Array = L4[0]
	var lw1: int = L1[1]
	var lw2: int = L2[1]
	var lw3: int = L3[1]
	var lw4: int = L4[1]
	var col1: PackedInt32Array = L1[2]
	var col2: PackedInt32Array = L2[2]
	var col3: PackedInt32Array = L3[2]
	var col4: PackedInt32Array = L4[2]
	var fx1: PackedFloat64Array = L1[3]
	var fx2: PackedFloat64Array = L2[3]
	var fx3: PackedFloat64Array = L3[3]
	var fx4: PackedFloat64Array = L4[3]
	var row1: PackedInt32Array = L1[4]
	var row2: PackedInt32Array = L2[4]
	var row3: PackedInt32Array = L3[4]
	var row4: PackedInt32Array = L4[4]
	var fy1: PackedFloat64Array = L1[5]
	var fy2: PackedFloat64Array = L2[5]
	var fy3: PackedFloat64Array = L3[5]
	var fy4: PackedFloat64Array = L4[5]
	for ty in h:
		for tx in w:
			if tiles[ty * w + tx] == Gen.WALL:
				continue
			# How close the walls are, for the grass that grows where light gets in.
			var walls := 0
			for d in [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1)]:
				if not _floor(tiles, w, h, tx + d.x, ty + d.y):
					walls += 1
			for py in t:
				var y := ty * t + py
				var r1 := row1[y]
				var r2 := row2[y]
				var r3 := row3[y]
				var r4 := row4[y]
				var v1 := fy1[y]
				var v2 := fy2[y]
				var v3 := fy3[y]
				var v4 := fy4[y]
				for px in t:
					var x := tx * t + px
					var i := r1 + col1[x]
					var f := fx1[x]
					var tone := lerpf(lerpf(lat1[i], lat1[i + 1], f), lerpf(lat1[i + lw1], lat1[i + lw1 + 1], f), v1)
					var c: Color = CLAY[0].lerp(CLAY[2], tone)
					# R._h(x, y, 41), written out.
					var hn := (x * 374761393 + y * 668265263 + 41 * 1442695041) & 0x7fffffff
					hn = ((hn ^ (hn >> 13)) * 1274126177) & 0x7fffffff
					var n := float(hn % 1000) / 1000.0
					if n > 0.9:
						c = c.lightened(0.07)
					elif n < 0.08:
						c = c.lerp(SPECK_LO, 0.5)
					i = r2 + col2[x]
					f = fx2[x]
					var sand := lerpf(lerpf(lat2[i], lat2[i + 1], f), lerpf(lat2[i + lw2], lat2[i + lw2 + 1], f), v2)
					if sand > 0.62:
						c = c.lerp(SAND, clampf((sand - 0.62) * 3.0, 0.0, 0.85))
						if sand > 0.7 and sin(x * 0.5 + y * 0.16 + R._noise(x, y, 9.0, 43) * 2.0) > 0.93:
							c = SAND_HI   # ripples the water left
					i = r3 + col3[x]
					f = fx3[x]
					var grass := lerpf(lerpf(lat3[i], lat3[i + 1], f), lerpf(lat3[i + lw3], lat3[i + lw3 + 1], f), v3) + 0.12 * walls
					if grass > 0.8 or (grass > 0.77 and (x + y) % 2 == 0):
						# Solid clumps in two tones from a finer noise, a dithered rim, the odd clover flower.
						c = GRASS[1] if R._noise(x, y, 5.0, 46) > 0.45 else GRASS[0]
						if grass > 0.84 and R._noise(x, y, 4.0, 45) > 0.7:
							c = GRASS[2]
						if R._h(x, y, 47) > 0.985:
							c = Color("#e8e2c4")
					i = r4 + col4[x]
					f = fx4[x]
					var pool := lerpf(lerpf(lat4[i], lat4[i + 1], f), lerpf(lat4[i + lw4], lat4[i + lw4 + 1], f), v4)
					if pool > 0.86:
						# Wet dark mud round the edge, still brown water, a lit band along the near shore.
						c = POOL if pool > 0.873 else c.lerp(Color(0.25, 0.18, 0.12), 0.45)
						if pool > 0.875 and pool < 0.884 and R._noise(x, y + 3, 6.0, 49) > 0.5:
							c = POOL_HI
					img.set_pixel(x, y, c)


## Pebbles scattered over the clay (rounded, lit top-left), and roots wandering out from the banks.
static func _pebbles_and_roots(img: Image, data: Dictionary, t: int, s: int) -> void:
	var w: int = data["w"]
	var h: int = data["h"]
	var tiles: PackedByteArray = data["tiles"]
	var W := img.get_width()
	var H := img.get_height()
	for gy in range(0, H, 9):
		for gx in range(0, W, 9):
			if R._h(gx + s, gy, 50) < 0.8:
				continue
			var cx := gx + int(R._h(gx, gy, 51) * 7)
			var cy := gy + int(R._h(gx, gy, 52) * 7)
			if not _floor(tiles, w, h, cx / t, cy / t):
				continue
			var r := 1 + int(R._h(gx, gy, 53) * 2.0)
			var col: Color = PEBBLE[int(R._h(gx, gy, 54) * PEBBLE.size())]
			for dy in range(-r, r + 1):
				for dx in range(-r - 1, r + 2):
					if dx * dx + dy * dy * 2 <= r * r + 2 and cx + dx < W and cy + dy < H and cx + dx >= 0 and cy + dy >= 0:
						var pc := col
						if dx < 0 and dy < 0:
							pc = PEB_HI
						elif dx > 0 and dy > 0:
							pc = col.darkened(0.25)
						img.set_pixel(cx + dx, cy + dy, pc)
			if cy + r + 1 < H:
				img.set_pixel(cx, cy + r + 1, PEB_LO)   # its shadow
	# Roots: a few per floor, each wandering out of a bank face across the ground.
	for k in 26:
		var tx := int(R._h(k, s, 55) * w)
		var ty := int(R._h(k, s, 56) * h)
		if not _floor(tiles, w, h, tx, ty) or _floor(tiles, w, h, tx, ty - 1):
			continue
		var p := Vector2(tx * t + R._h(k, 1, 57) * t, ty * t + 2)
		var dir := Vector2(R._h(k, 2, 58) - 0.5, 1.0).normalized()
		for step in 18 + int(R._h(k, 3, 59) * 20):
			var q := Vector2i(p.round())
			if not _floor(tiles, w, h, q.x / t, q.y / t):
				break
			img.set_pixel(q.x, q.y, ROOT_HI if step % 4 == 0 else ROOT)
			if q.x + 1 < W:
				img.set_pixel(q.x + 1, q.y, ROOT)
			if q.y + 1 < H:
				img.set_pixel(q.x, q.y + 1, ROOT.darkened(0.3))   # its shadow on the clay
			dir = dir.rotated((R._h(k, step, 60) - 0.5) * 0.7)
			p += dir


## The bank itself: turf on top seen from above, a grassy lip, and where it stands above floor, a face
## of sediment bands with pebbles in them, roots hanging from the turf, dark at the foot.
static func _walls(img: Image, data: Dictionary, t: int, s: int) -> void:
	var w: int = data["w"]
	var h: int = data["h"]
	var tiles: PackedByteArray = data["tiles"]
	var face_h: int = int(t * 0.62)
	# The turf's soft noise laid out once, and the blade tip's colour worked out once (CR-01; see _layer).
	var L := _layer(0, 0, w * t, h * t, 12.0, 61)
	var lat: PackedFloat64Array = L[0]
	var lw: int = L[1]
	var col: PackedInt32Array = L[2]
	var fxs: PackedFloat64Array = L[3]
	var rows: PackedInt32Array = L[4]
	var fys: PackedFloat64Array = L[5]
	var tip: Color = TURF[2].lightened(0.1)
	for y in h:
		for x in w:
			if tiles[y * w + x] != Gen.WALL:
				continue
			for py in t:
				var gy := y * t + py
				var r := rows[gy]
				var fy := fys[gy]
				for px in t:
					var gx := x * t + px
					# Calm turf: one dark green, softly lighter and darker, with short blade strokes.
					var i := r + col[gx]
					var f := fxs[gx]
					var nv := lerpf(lerpf(lat[i], lat[i + 1], f), lerpf(lat[i + lw], lat[i + lw + 1], f), fy)
					var c: Color = TURF[1].lightened((nv - 0.5) * 0.14)
					# Upright blades: two pixels tall, a light tip over a dark root, scattered. (The root's own
					# TURF[0] branch never drew: it asked the same question the tip already answered.)
					if gx % 3 == 1 and R._h(gx / 3, gy / 4, 62) > 0.6:
						c = tip if gy % 4 == 0 else (TURF[2] if gy % 4 == 1 else c)
					img.set_pixel(gx, gy, c)
			var open_below := _floor(tiles, w, h, x, y + 1)
			for side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1)]:
				if _floor(tiles, w, h, x + side.x, y + side.y):
					# Grass blades fringing the lip.
					for k in t:
						var bx: int = x * t + (k if side.y != 0 else (0 if side.x < 0 else t - 1))
						var by: int = y * t + (0 if side.y < 0 else k) if side.y != 0 else y * t + k
						img.set_pixel(bx, by, GRASS[int(R._h(bx, by, 63) * GRASS.size())])
			if open_below:
				var y0: int = y * t + t - face_h
				var band0 := int(R._h(x, 0, 65) * 3)   # this tile's band offset, the same down the whole face
				for px in t:
					var gx := x * t + px
					img.set_pixel(gx, y0 - 1, GRASS[1] if R._h(gx, 0, 64) > 0.3 else GRASS[2])
					var wave := sin(gx * 0.18 + s) * 1.2
					for k in face_h:
						var band := int((k + wave) / 3.0)
						var c: Color = BANDS[posmod(band + band0, BANDS.size())]
						if R._h(gx, k, 66) > 0.9:
							c = c.lightened(0.08)
						if R._h(gx / 3, (k + y * 7) / 2, 67) > 0.95:
							c = PEBBLE[1]   # a stone set in the bank
						if k >= face_h - 2:
							c = c.darkened(0.45 if k == face_h - 1 else 0.25)
						img.set_pixel(gx, y0 + k, c)
					# Roots hanging from the turf.
					if R._h(gx, y, 68) > 0.9:
						for k in 2 + int(R._h(gx, y, 69) * (face_h - 4)):
							img.set_pixel(gx, y0 + k, ROOT if k % 4 else ROOT_HI)
