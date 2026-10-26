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
	var shore: Array[Vector2i] = []   # spots along the pools' edges, for pebbles (pass 4 R3)
	_ground(img, data, t, s, shore)
	_pebbles_and_roots(img, data, t, s, shore)
	for y in h:
		for x in w:
			if tiles[y * w + x] != Gen.WALL and y > 0 and tiles[(y - 1) * w + x] == Gen.WALL:
				for k in 4:
					R._darken(img, Rect2i(x * t, y * t + k, t, 1), 0.55 + 0.1 * k)   # the bank's shadow
	_walls(img, data, t, s)
	# The way down: a dark hole in the clay, worn steps of packed earth going down into it (Claude, 2026-10-23,
	# pass 3 D1: ruin_painter.gd's paint_stairs in the Warren's clay; the three bars read as a menu icon).
	R.paint_stairs(img, data["stairs"], t, CLAY[2], SPECK_LO, Color(0.05, 0.04, 0.03), seed_value)
	return RootbankDetail.finish(img, data, t, seed_value)


static func _floor(tiles: PackedByteArray, w: int, h: int, x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < w and y < h and tiles[y * w + x] != Gen.WALL


## Clay, sand and grass, pixel by pixel from soft noise; a rare pool. A few spots just outside each pool's wet
## rim go into `shore`, where _pebbles_and_roots heaps pebbles.
static func _ground(img: Image, data: Dictionary, t: int, s: int, shore: Array[Vector2i] = []) -> void:
	var w: int = data["w"]
	var h: int = data["h"]
	var tiles: PackedByteArray = data["tiles"]
	# The four noises every pixel reads (tone, sand, grass, pool), laid out once; see R._layer (CR-01; shared from
	# ruin_painter.gd since 2026-10-24, pass 5 A1).
	var W := w * t
	var H := h * t
	var L1 := R._layer(s * 11, 0, W, H, 26.0, 40)
	var L2 := R._layer(0, s * 5, W, H, 34.0, 42)
	var L3 := R._layer(s * 3, 0, W, H, 14.0, 44)
	var L4 := R._layer(s * 7, s, W, H, 30.0, 48)
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
						c = c.lerp(SAND, clampf((sand - 0.62) * 3.0, 0.0, 0.85))   # its ripples come after (_ripples)
					i = r3 + col3[x]
					f = fx3[x]
					var grass := lerpf(lerpf(lat3[i], lat3[i + 1], f), lerpf(lat3[i + lw3], lat3[i + lw3 + 1], f), v3) + 0.12 * walls
					if grass > 0.8 or (grass > 0.77 and (x + y) % 2 == 0):
						# Solid clumps in two tones from a finer noise, a dithered rim. (The white clover dots are gone,
						# Claude, 2026-10-24, pass 4 R4: in the live run they read as specks on the moss.)
						c = GRASS[1] if R._noise(x, y, 5.0, 46) > 0.45 else GRASS[0]
						if grass > 0.84 and R._noise(x, y, 4.0, 45) > 0.7:
							c = GRASS[2]
					i = r4 + col4[x]
					f = fx4[x]
					var pool := lerpf(lerpf(lat4[i], lat4[i + 1], f), lerpf(lat4[i + lw4], lat4[i + lw4 + 1], f), v4)
					if pool > 0.86:
						# Wet dark mud round the edge, still brown water, a lit band along the near shore.
						c = POOL if pool > 0.873 else c.lerp(Color(0.25, 0.18, 0.12), 0.45)
						if pool > 0.875 and pool < 0.884 and R._noise(x, y + 3, 6.0, 49) > 0.5:
							c = POOL_HI
					elif pool > 0.845 and R._h(x, y, 90) > 0.96:
						shore.append(Vector2i(x, y))
					img.set_pixel(x, y, c)
	_ripples(img, data, t, s, L2)


## Ripples the water left (Claude, 2026-10-26, pass 7 F2, L7-13; the live run read the old long, straight, near-white
## strokes as scratches): small patches of three to five short curved marks on the sand, stacked the way a current
## leaves them and leaning together, each mark's crest a step lighter than the sand under it and a shadow pixel under
## the crest a step darker. A mark lands only on bare sand, never on the moss, a pool or the darker clay round a patch.
## `sand` is _ground's sand noise (R._layer), read again here at each patch's centre.
const RIPPLE_CELL := Vector2i(20, 15)   # at most one patch in each cell of this many pixels
const RIPPLE_AT := 0.7                  # the sand noise a patch's centre needs


static func _ripples(img: Image, data: Dictionary, t: int, s: int, sand: Array) -> void:
	var w: int = data["w"]
	var tiles: PackedByteArray = data["tiles"]
	var W := img.get_width()
	var H := img.get_height()
	var lat: PackedFloat64Array = sand[0]
	var lw: int = sand[1]
	var col: PackedInt32Array = sand[2]
	var fxs: PackedFloat64Array = sand[3]
	var rows: PackedInt32Array = sand[4]
	var fys: PackedFloat64Array = sand[5]
	for gy in range(0, H, RIPPLE_CELL.y):
		for gx in range(0, W, RIPPLE_CELL.x):
			if R._h(gx + s, gy, 92) < 0.3:
				continue
			var cx := gx + 3 + int(R._h(gx, gy, 93) * (RIPPLE_CELL.x - 6))
			var cy := gy + 4 + int(R._h(gx, gy, 94) * (RIPPLE_CELL.y - 8))
			if cx >= W or cy >= H or tiles[(cy / t) * w + cx / t] == Gen.WALL:
				continue
			var i := rows[cy] + col[cx]
			var f := fxs[cx]
			if lerpf(lerpf(lat[i], lat[i + 1], f), lerpf(lat[i + lw], lat[i + lw + 1], f), fys[cy]) < RIPPLE_AT:
				continue
			var lean := int(R._h(gy, gx, 95) * 3.0) - 1   # every mark in a patch leans the same way
			# About one patch in three is a single long faint mark, the edge of a wash (Claude, 2026-10-26, pass 8 F3,
			# LH8-11: the stacks alone repeated too evenly).
			if R._h(gx, gy, 99) < 0.33:
				_ripple(img, Vector2i(cx, cy), 11 + int(R._h(cx, cy, 98) * 5.0), lean, 5.0 + R._h(cy, cx, 100) * 5.0, -1, 0.6)
				continue
			var n := 3 + int(R._h(gx, gy, 96) * 3.0)
			# Each gap down the stack its own 4 to 7 pixels and each mark its own sideways offset of -2 to 2 (pass 8 F3;
			# they were exactly 5 apart in a fixed zigzag), the stack centred on the patch.
			var gaps: Array[int] = []
			var span := 0
			for j in n - 1:
				gaps.append(4 + int(R._h(j, gx + gy, 101) * 4.0))
				span += gaps[j]
			var y := cy - span / 2
			for j in n:
				var at := Vector2i(cx + int(R._h(j, gx + gy, 97) * 5.0) - 2, y)
				var length := 6 + int(R._h(at.x, at.y, 98) * 4.0)
				# Some marks lose a pixel at one end (pass 8 F3), so their lengths and ends do not all match.
				var skip := -1
				if R._h(at.y, at.x, 102) > 0.6:
					skip = 0 if R._h(at.x, at.y, 103) > 0.5 else length - 1
				_ripple(img, at, length, lean, 5.0 + R._h(at.x, at.y, 100) * 5.0, skip)
				if j < n - 1:
					y += gaps[j]


## One ripple mark, `length` pixels: a low arch, its ends lower than its middle by up to a quarter of `depth` (5 to
## 10, each mark its own, pass 8 F3; it was 8 for every mark), leaning by `lean` pixels over its length; each crest
## pixel lifted toward SAND_HI, the pixel under it pressed toward SPECK_LO, both by `strength` of their full amount.
## `skip`, when 0 or more, is a pixel of the mark left out.
static func _ripple(img: Image, at: Vector2i, length: int, lean: int, depth := 8.0, skip := -1, strength := 1.0) -> void:
	var half := length / 2
	for k in length:
		if k == skip:
			continue
		var dx := k - half
		var x := at.x + dx
		var u := (k + 0.5) / length - 0.5
		var y := at.y + roundi(u * u * depth) + (dx * lean) / 3   # 0 in the middle, 1 or 2 at the ends
		if x < 0 or y < 0 or x >= img.get_width() or y + 1 >= img.get_height():
			continue
		var c := img.get_pixel(x, y)
		var b := img.get_pixel(x, y + 1)
		if not _sandy(c) or not _sandy(b):
			continue
		img.set_pixel(x, y, c.lerp(SAND_HI, 0.5 * strength))
		img.set_pixel(x, y + 1, b.lerp(SPECK_LO, 0.4 * strength))


## Bare sand: warm (red over green, so not moss or a pool) and light (the clay round a patch is darker).
static func _sandy(c: Color) -> bool:
	return c.r - c.g > 0.06 and c.get_luminance() > 0.48


## Pebbles heaped where the water and the banks left them, and roots wandering out from the banks (Claude,
## 2026-10-24, pass 4 R3; the live run read the even field of grey and white specks as noise). Small heaps of three
## to five pebbles along the foot of the banks and round the pools, the odd lone pebble out on the open clay, clean
## dirt between. A pebble lands only on bare clay or sand, never on the moss, a pool or another pebble.
static func _pebbles_and_roots(img: Image, data: Dictionary, t: int, s: int, shore: Array[Vector2i] = []) -> void:
	var w: int = data["w"]
	var h: int = data["h"]
	var tiles: PackedByteArray = data["tiles"]
	var W := img.get_width()
	var H := img.get_height()
	var heaps: Array[Vector2i] = []
	for ty in h:
		for tx in w:
			if not _floor(tiles, w, h, tx, ty):
				continue
			# Along each bank this tile meets: up to three heaps at its foot.
			for d in [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1)]:
				if _floor(tiles, w, h, tx + d.x, ty + d.y):
					continue
				for k in 3:
					if R._h(tx * 7 + k, ty * 5 + d.x * 3 + d.y, 50 + s) < 0.22:
						continue
					var along := 3 + int(R._h(tx + k * 11, ty, 51 + d.x * 2 + d.y) * (t - 8))
					var off := (4 if d.y < 0 else 2) + int(R._h(tx, ty + k * 13, 52) * 8)   # below the bank's shadow
					var at := Vector2i(along, off) if d.y < 0 else (Vector2i(along, t - 4 - off / 2) if d.y > 0 else Vector2i(off if d.x < 0 else t - 4 - off, along))
					heaps.append(Vector2i(tx * t, ty * t) + at)
	for p in shore:
		heaps.append(p)
	for n in heaps.size():
		var p: Vector2i = heaps[n]
		for k in 3 + int(R._h(p.x, p.y, 53) * 3):
			var q := p + Vector2i(int((R._h(n, k, 54) - 0.5) * 10.0), int((R._h(k, n, 55) - 0.5) * 7.0))
			var roll := R._h(q.x, q.y, 56)
			_pebble(img, q, 2 if roll < 0.4 else (3 if roll < 0.8 else 4), PEBBLE[int(R._h(q.y, q.x, 57) * PEBBLE.size())])
	# The open clay: now and then one small pebble on its own.
	for gy in range(0, H, 16):
		for gx in range(0, W, 16):
			if R._h(gx + s, gy, 58) < 0.88:
				continue
			var q := Vector2i(gx + int(R._h(gx, gy, 51) * 12), gy + int(R._h(gx, gy, 52) * 12))
			if _floor(tiles, w, h, q.x / t, q.y / t):
				_pebble(img, q, 2, PEBBLE[int(R._h(gx, gy, 54) * PEBBLE.size())])
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


## One pebble, 2, 3 or 4 pixels across, lit top-left, its shadow under it to the right (pass 4 R3). Each row is
## [x, y, tone]: h the lit spot, c the stone, d its shade, s the shadow on the clay. Drawn only when every pixel
## lands on bare clay or sand (red over green; moss, pools and pebbles all fail it).
const PEBBLE_SHAPES := {
	2: [[0, 0, "c"], [1, 0, "c"], [0, 1, "c"], [1, 1, "d"], [1, 2, "s"]],
	3: [[0, 0, "h"], [1, 0, "c"], [2, 0, "c"], [0, 1, "c"], [1, 1, "c"], [2, 1, "d"], [1, 2, "s"], [2, 2, "s"]],
	4: [[1, 0, "h"], [2, 0, "c"], [0, 1, "c"], [1, 1, "c"], [2, 1, "c"], [3, 1, "d"], [1, 2, "c"], [2, 2, "d"], [1, 3, "s"], [2, 3, "s"]],
}


static func _pebble(img: Image, at: Vector2i, size: int, col: Color) -> void:
	var shape: Array = PEBBLE_SHAPES[size]
	for q in shape:
		var x: int = at.x + int(q[0])
		var y: int = at.y + int(q[1])
		if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
			return
		var c := img.get_pixel(x, y)
		if c.r - c.g < 0.06:
			return
	var tones := {"h": PEB_HI, "c": col, "d": col.darkened(0.25), "s": PEB_LO}
	for q in shape:
		img.set_pixel(at.x + int(q[0]), at.y + int(q[1]), tones[q[2]])


## The bank itself (Claude, 2026-10-24, pass 5 A3 and A4; the live run read the old walls as a flat green carpet with
## a dot grid, no edge and no end). Every bank edge beside the floor gets one rim, drawn from ruin_painter.gd's wall
## field (R._wall_field, the Hollow Mouth's): a shadow line against the floor, a sliver of clay face, a lit grass lip,
## then turf in clumps of three greens, never more than a tile deep (TURF_REACH); past it the bank's back course of
## clods, a dark line and black (rootbank_detail.gd's back_course, pass 8). Above a face the face's grass row is the lip
## and the turf starts straight away, so the roots hanging from it stay on the bank.
## Where the bank stands above floor, its face as before: sediment bands with stones set in them, roots hanging from
## the turf, dark at the foot. The crew's den (rootbank_detail.gd's is_den) keeps bank all round its room, for its
## root arch to stand on. Colours: the clay, grass and turf tones, ROOT for the roots, BARK_EDGE for the shadow.
const TURF_REACH := 9      # the turf's depth from the lip, plus up to TURF_WANDER more on its soft noise
const TURF_WANDER := 4.0
const RIM_FACE := 2        # clay face rows between the shadow line and the lip
const BARK_EDGE := Color("#251d17")   # rootbank_detail.gd's root outline, the bank's shadow
## Past the turf, beside the floor and above a face alike, the bank's back course (Claude, 2026-10-26, pass 8 F1 and F2,
## L12; rootbank_detail.gd's back_course): clay clods in shade with a stepped back edge and a dark line along it, then
## black. It replaces the crumbling earth lip beside the floor (pass 6 P3) and, above a face, the rough top and its three
## steps of marks (R._fall), which the live run read as a ragged black band along every wall top once the tile above a
## face was in sight. The turf's own edge now follows only its soft noise, so it wanders without speckling.
## One wall language for rooms and hallways (Claude, 2026-10-26, pass 7 F1, L7-12; the live run read a room's sides as a
## thin lip of turf into black beside the hallways' tall faces). A face now fills its wall tile but for the top
## RootbankDetail.FACE_TOP rows, which are turf, so the turf above it lies in the tile above and the bank stands about two
## tiles high; rootbank_detail.gd hangs its roots down the whole face. Beside or below the floor the turf reaches
## SIDE_REACH (the rim included) instead of TURF_REACH, most of its tile, and its first LIT_GRASS rows past the lip are
## the meadow's grass in clumps, so the bank's edge reads in the light; rootbank_detail.gd lays roots across that lip.
## Past SIDE_DARK it is black at once, with no noise read. SIDE_REACH was 15 until pass 8: 13 leaves room in the tile
## for the back course, so the fog's straight tile edge never cuts it.
const SIDE_REACH := 13
const LIT_GRASS := 3
const SIDE_DARK := SIDE_REACH + int(TURF_WANDER) + RootbankDetail.COURSE_MAX + 1


static func _walls(img: Image, data: Dictionary, t: int, s: int) -> void:
	var w: int = data["w"]
	var h: int = data["h"]
	var tiles: PackedByteArray = data["tiles"]
	var face_h: int = t - RootbankDetail.FACE_TOP   # was int(t * 0.62), 14 rows (pass 7 F1)
	var W := w * t
	var H := h * t
	var den := RootbankDetail.is_den(data)
	var F := R._wall_field(data, t, face_h + 1)
	var dists: PackedInt32Array = F[0]
	var alongs: PackedByteArray = F[2]
	var faced: PackedByteArray = F[3]
	var deep: PackedByteArray = F[4]
	# The turf's soft noise (its patches and where it ends) and the marks' fine one, laid out once (R._layer).
	var L := R._layer(0, 0, W, H, 12.0, 61)
	var lat: PackedFloat64Array = L[0]
	var lw: int = L[1]
	var col: PackedInt32Array = L[2]
	var fxs: PackedFloat64Array = L[3]
	var rows: PackedInt32Array = L[4]
	var fys: PackedFloat64Array = L[5]
	var M := R._layer(0, 0, W, H, R.MARK_CELL, R.MARK_K)
	var mlat: PackedFloat64Array = M[0]
	var mlw: int = M[1]
	var mcol: PackedInt32Array = M[2]
	var mfxs: PackedFloat64Array = M[3]
	var mrows: PackedInt32Array = M[4]
	var mfys: PackedFloat64Array = M[5]
	var tip: Color = TURF[2].lightened(0.1)
	var lip_end := RIM_FACE + 2
	for y in h:
		for x in w:
			if tiles[y * w + x] != Gen.WALL:
				continue
			var deep_tile := deep[y * w + x] == 1
			if deep_tile and not den:
				img.fill_rect(Rect2i(x * t, y * t, t, t), Color.BLACK)   # deep in the bank: unseen
				continue
			for py in t:
				var gy := y * t + py
				var r := rows[gy]
				var fy := fys[gy]
				var mr := mrows[gy]
				var mfy := mfys[gy]
				for px in t:
					var gx := x * t + px
					var k := gy * W + gx
					var d := 99 if deep_tile else dists[k]
					if d <= 0:
						continue   # the face, painted below
					d -= 1
					if not den and d >= SIDE_DARK:
						img.set_pixel(gx, gy, Color.BLACK)   # past the furthest the back course reaches (pass 8)
						continue
					var beside := faced[k] == 0 or alongs[k] == 0   # beside or below the floor, not above a face
					var i := r + col[gx]
					var f := fxs[gx]
					var nv := lerpf(lerpf(lat[i], lat[i + 1], f), lerpf(lat[i + lw], lat[i + lw + 1], f), fy)
					var c: Color
					var reach := int((SIDE_REACH if beside else TURF_REACH) + nv * TURF_WANDER)   # where the turf ends, wandering
					if not den and d >= reach:
						# Past the turf, beside the floor or above a face: the back course, its dark line, then black (pass 8
						# F1 and F2). It ends inside its tile, so neither the fog's tile edge nor the picture's frame cuts it.
						# The rim and the lit grass below always lie inside the turf's reach, so they come to no harm here.
						if d - reach > RootbankDetail.COURSE_MAX:
							c = Color.BLACK
						else:
							var along_x := alongs[k] == 1
							c = RootbankDetail.back_course(d - reach, gx if along_x else gy, y if along_x else x, BANDS)
						img.set_pixel(gx, gy, c)
						continue
					i = mr + mcol[gx]
					f = mfxs[gx]
					var mv := lerpf(lerpf(mlat[i], mlat[i + 1], f), lerpf(mlat[i + mlw], mlat[i + mlw + 1], f), mfy)
					if not deep_tile and faced[k] == 0 and d <= lip_end:
						# The rim against the floor: the shadow line, the clay face, the lit grass lip.
						if d == 0:
							c = BARK_EDGE
						elif d <= RIM_FACE:
							c = BANDS[1] if mv > 0.56 else BANDS[0]
						elif d < lip_end or mv > 0.45:
							c = GRASS[2] if mv > 0.38 else GRASS[1]
						else:
							c = TURF[1]
					elif not deep_tile and faced[k] == 0 and d <= lip_end + LIT_GRASS:
						# Just past the lip the bank's grass still has the light: the meadow's greens in clumps (pass 7 F1).
						c = GRASS[1] if mv > 0.5 else (GRASS[0] if mv > 0.34 else TURF[2])
					else:
						# Turf in clumps: dark and light clumps from the fine noise, the whole lighter or darker in
						# soft patches, darker toward its far edge; a few blade tips catching the light.
						var lift := (nv - 0.5) * 0.3 - (0.12 if d > reach - 3 and not den else 0.0)
						if mv - lift < 0.36:
							c = TURF[0]
						elif mv - lift > 0.7:
							c = tip if mv > 0.8 and d < reach - 3 else TURF[2]
						else:
							c = TURF[1]
					img.set_pixel(gx, gy, c)
			var open_below := _floor(tiles, w, h, x, y + 1)
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
