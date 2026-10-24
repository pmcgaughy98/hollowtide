extends RefCounted
const TileArt := preload("res://scripts/dungeon/dungeon_tile_art.gd")
# Codex's flat 24px tile sheets (2026-10-10) are switched off: Preston, 2026-10-11, wants the hand-painted,
# textured stones and grass back, the look that matches the boss room. Set true to use the sheets again.
const USE_TILE_ART := false
## The Hollow's look (Claude, 2026-10-10; Preston: the Hollow is a structure that "rose from the river with
## a stone pathway to it", and "the pond looks amazing, I wish the rest looked that good"). Drawn in code
## pixel by pixel like the Warden's pond, no generated art: river-washed flagstones with moss in the
## seams, cracks, silt and standing water; walls of carved stone blocks, dark and wet, a green water
## line at their foot where the river once stood. A set of 24 px tiles is drawn once and stamped.
##   Painter.paint(data, t, seed) -> Image, the same call as floor_painter.gd
##   Painter.paint(data, t, seed, "mouth") for the Hollow Mouth (Claude, 2026-10-22, WORLD-01); see VARIANTS

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

## The Mouth's look (Claude, 2026-10-22, WORLD-01): the same stone where the river still reaches it, silt-washed
## paler and warmer, the moss yellower in the light near the entrance, and the river's old high-water marks lying
## across the slabs as thin silt lines. paint() takes `variant`: "hollow" (the default, the look above, unchanged)
## or "mouth". An unknown name paints the Hollow.
const STONE_MOUTH := [Color("#9c9d8f"), Color("#a2a293"), Color("#abaa98"), Color("#96988c"), Color("#a4a69a")]
const MOSS_MOUTH := Color("#6d883d")
const MOSS_MOUTH_LO := Color("#556b31")
const VARIANTS := {
	"hollow": {"stone": STONE, "moss": MOSS, "moss_lo": MOSS_LO, "silt_lines": false},
	"mouth": {"stone": STONE_MOUTH, "moss": MOSS_MOUTH, "moss_lo": MOSS_MOUTH_LO, "silt_lines": true, "painted": true,
		"water": WATER_MOUTH, "water_deep": WATER_MOUTH_DEEP, "water_hi": WATER_MOUTH_HI, "wall_top": WALL_TOP_MOUTH},
}
## The Mouth, painted (Claude, 2026-10-23, pass 3 D2; the audit: flat grey-blue slabs, square bright pools and a
## grey border beside the warm Rootbank Warren). "painted" adds what the Warren has: small clusters of lighter and
## darker grain in every slab, pools with ragged edges, a ring of wet stone and deeper water in the middle, a warm
## light and cool shade lying across the floor, wall tops in a warmer dark that falls away into black away from the
## floor. The Mouth's own stone, moss and silt are kept; the Hollow's look ("hollow") is unchanged.
const WATER_MOUTH := Color("#3e5d61")
const WATER_MOUTH_DEEP := Color("#2b464c")
const WATER_MOUTH_HI := Color("#a3bfb9")
const WALL_TOP_MOUTH := Color("#302d28")
const WARM := Color(1.0, 0.88, 0.66)   # the light, warm (also the stairs' lit rim)
const COOL := Color(0.30, 0.38, 0.52)  # the shade, cool

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


static func paint(data: Dictionary, t: int, seed_value: int, variant := "hollow") -> Image:
	if USE_TILE_ART and t == 24: return TileArt.paint(data,t,seed_value,"ruin")
	var look: Dictionary = VARIANTS.get(variant, VARIANTS["hollow"])   # Claude, 2026-10-22: the Hollow or the Mouth
	var stones: Array = look["stone"]
	var w: int = data["w"]
	var h: int = data["h"]
	var tiles: PackedByteArray = data["tiles"]
	var W := w * t
	var H := h * t
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	_slabs(img, seed_value, look)
	_weather(img, data, t, seed_value, look)
	if look["silt_lines"]:
		_silt_lines(img, data, t, seed_value)
	for y in h:
		for x in w:
			if tiles[y * w + x] != Gen.WALL and y > 0 and tiles[(y - 1) * w + x] == Gen.WALL:
				for k in 4:
					_darken(img, Rect2i(x * t, y * t + k, t, 1), 0.55 + 0.1 * k)   # the wall's shadow
	if look.get("painted", false):
		_light(img, seed_value)   # the floor's light and shade, under the walls (Claude, 2026-10-24, pass 4 R1)
	_walls(img, data, t, look)
	# The stairs: a dark way down cut into the flagstones (pass 3 D1, paint_stairs below).
	paint_stairs(img, data["stairs"], t, stones[2], SEAM, Color(0.04, 0.05, 0.06), seed_value)
	return img


## The way down (Claude, 2026-10-23, pass 3 D1; the audit read the old slab and three grey bars as a menu icon).
## A dark opening cut into the floor: a stone rim lit warm on its far and left edges and shaded cool on the right,
## a seam round it, the shaft's far wall going down into the dark, four steps that narrow and darken as they go
## down, and a few chips of rubble on the rim. `stone` is the floor's own stone (or clay, or slab), `seam` its joint
## colour, `hole` the dark at the bottom, so every painter's stairs sit in its own palette. The footprint is
## stairs_rect(t), which dungeon_finish.gd's sel-out mask uses too; drawn a pixel a design pixel, doubled on a tile
## twice the size.
const STAIRS_SIZE := Vector2i(22, 20)


## The stairs' footprint inside their tile, centred: 22 x 20 on a 24 px tile.
static func stairs_rect(t: int) -> Rect2i:
	var size := STAIRS_SIZE * maxi(1, t / 24)
	return Rect2i(Vector2i(t, t) / 2 - size / 2, size)


static func paint_stairs(img: Image, tile: Vector2i, t: int, stone: Color, seam: Color, hole: Color, seed_value := 0) -> void:
	var k := maxi(1, t / 24)
	var at := tile * t + stairs_rect(t).position
	var mix := seed_value + tile.x * 31 + tile.y * 17
	var px := {}
	for y in STAIRS_SIZE.y:
		for x in STAIRS_SIZE.x:
			var c := _stair_px(x, y, stone, seam, hole, mix)
			if c.a > 0.0:
				px[Vector2i(x, y)] = c
	# Rubble: a few chips on the rim, each with its shadow under it, and a pebble on the top step.
	var chips := [Vector2i(4, 1), Vector2i(12, 2), Vector2i(17, 1), Vector2i(1, 5), Vector2i(2, 13), Vector2i(20, 7), Vector2i(19, 14), Vector2i(5, 18), Vector2i(14, 17), Vector2i(18, 18)]
	var placed := 0
	for i in chips.size():
		if placed >= 4 or _h(i, mix, 71) < 0.55:
			continue
		placed += 1
		var q: Vector2i = chips[i]
		px[q] = stone.lerp(WARM, 0.3)
		if px.has(q + Vector2i(0, 1)):
			px[q + Vector2i(0, 1)] = _shade(stone, 0.6)
	var peb := Vector2i(6 + int(_h(mix, 3, 72) * 10), 14)
	px[peb] = stone.lerp(WARM, 0.2)
	px[peb + Vector2i(0, 1)] = _shade(stone, 0.55)
	for q in px:
		img.fill_rect(Rect2i(at + q * k, Vector2i(k, k)), px[q])


## One design pixel of the stairs (22 x 20); a clear colour where the floor shows through (the rounded corners).
static func _stair_px(x: int, y: int, stone: Color, seam: Color, hole: Color, mix: int) -> Color:
	var right := STAIRS_SIZE.x - 1
	var bottom := STAIRS_SIZE.y - 1
	if (x == 0 or x == right) and (y == 0 or y == bottom):
		return Color(0, 0, 0, 0)
	if x == 0 or x == right or y == 0 or y == bottom:
		return seam if y < bottom else _shade(seam, 0.85)   # the seam round the opening
	var c: Color
	if y <= 2 or y >= bottom - 2 or x <= 2 or x >= right - 2:
		# The rim, carved blocks: lit on the far and left edges, the near lip catching the light, the right in shade.
		if y == 1:
			c = stone.lerp(WARM, 0.25)
		elif y == 2:
			c = stone.lerp(WARM, 0.1)
		elif y == bottom - 2:
			c = stone.lerp(WARM, 0.16)
		elif y == bottom - 1:
			c = _shade(stone, 0.92)
		elif x == 1:
			c = stone.lerp(WARM, 0.16)
		elif x == 2:
			c = stone.lerp(WARM, 0.06)
		elif x == right - 1:
			c = _shade(stone, 0.8).lerp(COOL, 0.12)
		else:
			c = _shade(stone, 0.9)
		var joint := (y <= 2 and (x == 7 or x == 15)) or (x <= 2 and y == 9) or (x >= right - 2 and y == 11) or (y >= bottom - 2 and x == 10)
		if joint:
			return seam.lerp(stone, 0.25)
		var n := _h(x, y, mix + 70)
		if n > 0.86:
			c = _shade(c, 0.9)
		elif n < 0.06:
			c = c.lerp(WARM, 0.08)
		return c
	# Inside: the far wall of the shaft, then the steps; the dark round them.
	if y <= 5:
		var wall := _shade(stone, 0.5 - 0.1 * (y - 3)).lerp(COOL, 0.15 + 0.05 * (y - 3))
		if (y == 3 and (x == 7 or x == 13)) or (y > 3 and (x == 10 or x == 16)):
			wall = _shade(wall, 0.7)
		return wall
	# [tread rows, riser row, first x, last x, brightness] from the deepest step to the top one.
	for s in [[[7], 8, 7, 14, 0.34], [[9], 10, 6, 15, 0.5], [[11, 12], 13, 5, 16, 0.7], [[14, 15], 16, 4, 17, 0.92]]:
		var b: float = s[4]
		if x < int(s[2]) or x > int(s[3]):
			continue
		if y in s[0]:
			var tread := _shade(stone, b).lerp(WARM, 0.12 * b) if y == s[0][0] else _shade(stone, b * 0.94)
			if x == int(s[2]):
				tread = tread.lerp(WARM, 0.08)
			elif x == int(s[3]):
				tread = _shade(tread, 0.85)
			return tread
		if y == int(s[1]):
			return _shade(stone, b * 0.62).lerp(COOL, 0.2)
	if x == right - 3:
		return hole.lerp(stone, 0.14)   # the shaft's right side, faintly lit from the left
	return hole


## Mouth only: the light and the shade across the floor (pass 3 D2). A smooth field over the floor picks warm light
## in some places and cool shade in others; both go on as soft overlays, built small and scaled up, so the cost is
## two image blends.
static func _light(img: Image, seed_value: int) -> void:
	var W := img.get_width()
	var H := img.get_height()
	var cell := 24
	var gw := W / cell + 2
	var gh := H / cell + 2
	var s := seed_value % 613
	var warm := Image.create(gw, gh, false, Image.FORMAT_RGBA8)
	var cool := Image.create(gw, gh, false, Image.FORMAT_RGBA8)
	for gy in gh:
		for gx in gw:
			var v := _noise(gx * cell + s * 7, gy * cell + s * 3, 110.0, 64)
			warm.set_pixel(gx, gy, Color(WARM, clampf((v - 0.5) * 0.7, 0.0, 0.18)))
			cool.set_pixel(gx, gy, Color(COOL, clampf((0.5 - v) * 0.75, 0.0, 0.2)))
	for over in [warm, cool]:
		over.resize(gw * cell, gh * cell, Image.INTERPOLATE_BILINEAR)
		img.blend_rect(over, Rect2i(0, 0, W, H), Vector2i.ZERO)


## Mouth only: the wall tops (Claude, 2026-10-24, pass 4 R1 and R2; the live run read the corridor walls as blurry
## grey boxes and every edge as a smooth gradient into the dark). Each wall beside the floor, room or corridor, gets
## the room walls' masonry: a lit brink, a row of carved block tops, the joint behind them; where it stands above
## floor the face of courses comes after (_walls). Past the joint the rough top falls into black in three steps of
## clustered marks (_fall; a 2 x 2 ordered dither until pass 5 A4), each step's edge wandering up to six pixels so no
## edge runs straight. Only the walls' own colours: the face's stones and their lit tops, the mortar, the lip, the dark
## top and black.
## Distances are Chebyshev from the lit ground: floor tiles, and the face (with its brink line) of a wall above floor.
const CAP := 7     # the brick-top row: the brink, five rows of block tops, the joint
const STEP := 4    # each step's depth into the dark


static func _wall_tops(img: Image, data: Dictionary, t: int, face_h: int, top: Color) -> void:
	var w: int = data["w"]
	var h: int = data["h"]
	var tiles: PackedByteArray = data["tiles"]
	var W := w * t
	var lit_tops: Array = []
	for c in WALL:
		lit_tops.append(c.lightened(0.08))   # the face's course tops, the same colours
	# How far each wall pixel is from the lit ground (_wall_field, shared with the Rootbank Warren since pass 5 A3).
	var F := _wall_field(data, t, face_h + 1)
	var dists: PackedInt32Array = F[0]
	var softs: PackedInt32Array = F[1]
	var alongs: PackedByteArray = F[2]
	var deep: PackedByteArray = F[4]
	# The marks' fine noise for the steps into the dark, laid out once (pass 5 A4; _fall).
	var M := _layer(0, 0, W, h * t, MARK_CELL, MARK_K)
	var mlat: PackedFloat64Array = M[0]
	var mlw: int = M[1]
	var mcol: PackedInt32Array = M[2]
	var mfxs: PackedFloat64Array = M[3]
	var mrows: PackedInt32Array = M[4]
	var mfys: PackedFloat64Array = M[5]
	for y in h:
		for x in w:
			if tiles[y * w + x] != Gen.WALL:
				continue
			if deep[y * w + x] == 1:
				img.fill_rect(Rect2i(x * t, y * t, t, t), Color.BLACK)   # deep in the rock: unseen
				continue
			for py in t:
				var gy := y * t + py
				var row := gy * W + x * t
				for px in t:
					var d := dists[row + px]
					if d <= 0:
						continue   # the tile's own face: _walls paints it
					d -= 1
					var soft := softs[row + px]
					var along_x := alongs[row + px] == 1
					var gx := x * t + px
					var c: Color
					if d == 0:
						c = LIP   # the brink, lit
					elif d < CAP - 1:
						var along := gx if along_x else gy
						if (along + 3) % 8 == 0:
							c = MORTAR   # the joint between two blocks
						else:
							var tone := int(_h((along + 3) / 8, y if along_x else x, 82 if along_x else 84) * WALL.size())
							c = lit_tops[tone] if d <= 2 else WALL[tone]
							if d >= 2 and _h(gx, gy, 83) > 0.94:
								c = MORTAR   # a chip in the block
					elif d == CAP - 1:
						c = MORTAR   # the joint behind the row
					elif soft > CAP + 3 * STEP + 7:
						c = Color.BLACK
					else:
						# Rough dark top, then the steps (_fall); their edges wander up to six pixels on a soft noise.
						var e := soft - CAP - 1 - int(_noise(gx, gy, 9.0, 81) * 7.0)
						var i := mrows[gy] + mcol[gx]
						var f := mfxs[gx]
						var v := lerpf(lerpf(mlat[i], mlat[i + 1], f), lerpf(mlat[i + mlw], mlat[i + mlw + 1], f), mfys[gy])
						c = _fall(e, STEP, v, top, MORTAR, gx, gy)
					img.set_pixel(gx, gy, c)


## The steps into the dark past a wall top's lit rim (Claude, 2026-10-24, pass 5 A3 and A4), shared by the Hollow
## Mouth and the Rootbank Warren. `e` is how far past the rough top the pixel lies, in pixels, its edge already set
## wandering by the caller; `v` is the marks' fine soft noise at the pixel (_layer at MARK_CELL, key MARK_K). Before the
## steps (e < 0) the rough top: `top` with a little `grit`. Then three steps, each `step` pixels deep, of `top` in
## clustered marks over black, each step thinner than the last (FALL_DENSITY), and black after. The marks are the fine
## noise thresholded, clumps of two to four pixels, nudged a little per pixel; they replace the 2 x 2 ordered dither,
## whose checker repeated exactly (LV-10).
const FALL_DENSITY := [0.6, 0.5, 0.42]
const MARK_CELL := 2.0
const MARK_K := 90


static func _fall(e: int, step: int, v: float, top: Color, grit: Color, gx: int, gy: int) -> Color:
	if e < 0:
		return grit if _h(gx, gy, 86) > 0.9 else top   # grit in the rough top
	var k := e / step
	if k > 2:
		return Color.BLACK
	return top if v + (_h(gx, gy, 91) - 0.5) * 0.15 < FALL_DENSITY[k] else Color.BLACK


## The distance field the wall tops are painted from (Claude, 2026-10-24, pass 5 A3: factored out of _wall_tops so
## the Rootbank Warren's banks are drawn from the same one). Lit ground is the floor tiles and, where a wall stands
## above floor, its face, `lit_rows` tall with its brink line. For each pixel of a wall tile with lit ground among its
## eight neighbours: dist, the Chebyshev distance to that ground in pixels (0 or less on it: a wall's own face); soft,
## the same with the corners rounded off, for the steps into the dark; along, 1 where the nearest lit edge runs along
## x (the pixel is above or below it); face, 1 where that nearest lit ground is a face rather than floor. deep is per
## tile: 1 for a wall with no lit ground round it, unseen rock. Within a tile of the ground the numbers are exact.
## Returns [dist, soft, along, face, deep]; the first four are the picture's size, row by row, 0 off the walls.
static func _wall_field(data: Dictionary, t: int, lit_rows: int) -> Array:
	var w: int = data["w"]
	var h: int = data["h"]
	var tiles: PackedByteArray = data["tiles"]
	var W := w * t
	var dists := PackedInt32Array()
	var softs := PackedInt32Array()
	var alongs := PackedByteArray()
	var faces := PackedByteArray()
	var deep := PackedByteArray()
	dists.resize(W * h * t)
	softs.resize(W * h * t)
	alongs.resize(W * h * t)
	faces.resize(W * h * t)
	deep.resize(w * h)
	var ex := PackedInt32Array()
	var ey := PackedInt32Array()
	var kinds := PackedByteArray()
	for y in h:
		for x in w:
			if tiles[y * w + x] != Gen.WALL:
				continue
			# The lit ground near this tile, in this tile's pixels: a floor tile whole, a face and its brink.
			var rects: Array[Rect2i] = []
			kinds.resize(0)
			for oy in range(-1, 2):
				for ox in range(-1, 2):
					var xx := x + ox
					var yy := y + oy
					if xx < 0 or yy < 0 or xx >= w or yy >= h:
						continue
					if tiles[yy * w + xx] != Gen.WALL:
						rects.append(Rect2i(ox * t, oy * t, t, t))
						kinds.append(0)
					elif yy + 1 < h and tiles[(yy + 1) * w + xx] != Gen.WALL:
						rects.append(Rect2i(ox * t, oy * t + t - lit_rows, t, lit_rows))
						kinds.append(1)
			if rects.is_empty():
				deep[y * w + x] = 1
				continue
			var n := rects.size()
			ex.resize(n * t)
			ey.resize(n * t)
			for r in n:
				var q: Rect2i = rects[r]
				for k in t:
					ex[r * t + k] = maxi(q.position.x - k, k - q.end.x + 1)
					ey[r * t + k] = maxi(q.position.y - k, k - q.end.y + 1)
			for py in t:
				var row := (y * t + py) * W + x * t
				for px in t:
					var d := 99
					var soft := 99   # the same, with the corners rounded off, for the dark's steps
					var along_x := true
					var kind := 0
					for r in n:
						var a := ex[r * t + px]
						var b := ey[r * t + py]
						var m := maxi(a, b)
						if m < d:
							d = m
							along_x = b >= a   # above or below the lit ground: the edge runs along x
							kind = kinds[r]
						soft = mini(soft, m + (mini(a, b) >> 1 if a > 0 and b > 0 else 0))
					dists[row + px] = d
					softs[row + px] = soft
					alongs[row + px] = 1 if along_x else 0
					faces[row + px] = kind
	return [dists, softs, alongs, faces, deep]


## Flagstones over the whole floor: rows of uneven slabs in a running bond, each slab its own tone,
## lit on the top-left, shaded bottom-right, a few specks, now and then a crack.
static func _slabs(img: Image, seed_value: int, look: Dictionary = {}) -> void:
	if look.is_empty():
		look = VARIANTS["hollow"]
	var stones: Array = look["stone"]
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
			var c: Color = stones[int(_h(row, k, 23) * stones.size())]
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
				var inner := Rect2i(r.position + Vector2i(1, 1), r.size - Vector2i(2, 2))
				if look.get("painted", false) and inner.size.x > 0 and inner.size.y > 0:
					# Grain (pass 3 D2): small clusters of lighter and darker stone, one or two pixels, and pits.
					for n in (r.size.x * r.size.y) / 12:
						var g := Vector2i(inner.position.x + int(_h(n, k * 13 + row, 52) * maxi(1, inner.size.x - 1)), inner.position.y + int(_h(n + 7, k + row * 5, 53) * maxi(1, inner.size.y - 1)))
						var kind := _h(n, k + row, 54)
						var gs := Vector2i(2, 1) if kind < 0.4 else (Vector2i(1, 2) if kind < 0.6 else Vector2i.ONE)
						var gc: Color = c.lightened(0.07) if _h(n, row, 55) > 0.5 else _shade(c, 0.9)
						if kind > 0.92:
							gc = _shade(c, 0.8)   # a pit
						img.fill_rect(Rect2i(g, gs).intersection(inner), gc)
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


## One of _noise's soft noises laid out once over a whole picture (Claude, 2026-10-22, CR-01, in
## riverbank_painter.gd; moved here 2026-10-24, pass 5 A1, so every painter shares the one copy). _noise hashes the
## four lattice corners round a pixel on every call; here the corners are hashed once into a grid, with each column's
## lattice index and eased fraction and each row's, so a pixel reads four numbers and does _noise's own arithmetic on
## them: the same value as _noise(x + ox, y + oy, cell, k) for 0 <= x < W and 0 <= y < H, to the last bit.
## Returns [corner grid, grid width, column index per x, eased fx per x, row start per y, eased fy per y].
static func _layer(ox: int, oy: int, W: int, H: int, cell: float, k: int) -> Array:
	var gx0 := int(floorf(float(ox) / cell))
	var gy0 := int(floorf(float(oy) / cell))
	var lw := int(floorf(float(W - 1 + ox) / cell)) - gx0 + 2
	var lh := int(floorf(float(H - 1 + oy) / cell)) - gy0 + 2
	var lat := PackedFloat64Array()
	lat.resize(lw * lh)
	var kk := k * 1442695041
	for j in lh:
		var yk := (gy0 + j) * 668265263 + kk
		for i in lw:
			var n := ((gx0 + i) * 374761393 + yk) & 0x7fffffff   # _h(gx0 + i, gy0 + j, k), written out
			n = ((n ^ (n >> 13)) * 1274126177) & 0x7fffffff
			lat[j * lw + i] = float(n % 1000) / 1000.0
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


## Weather over the stones, in 2-pixel blocks: silt washed into soft stains, moss creeping out of the
## seams (more of it near the walls), and a few shallow pools left by the river.
static func _weather(img: Image, data: Dictionary, t: int, seed_value: int, look: Dictionary = {}) -> void:
	if look.is_empty():
		look = VARIANTS["hollow"]
	var moss_hi: Color = look["moss"]
	var moss_lo: Color = look["moss_lo"]
	var painted: bool = look.get("painted", false)
	var water: Color = look.get("water", WATER)
	var water_deep: Color = look.get("water_deep", WATER)
	var water_hi: Color = look.get("water_hi", WATER_HI)
	var w: int = data["w"]
	var h: int = data["h"]
	var tiles: PackedByteArray = data["tiles"]
	var W := img.get_width()
	var H := img.get_height()
	var s := seed_value % 911
	# The silt, moss and pool noises laid out once (Claude, 2026-10-24, pass 5 A2; _layer, the same numbers as _noise).
	var LS := _layer(s * 13, 0, W, H, 40.0, 30)
	var LM := _layer(0, s * 7, W, H, 28.0, 31)
	var LP := _layer(s * 3, s * 5, W, H, 34.0, 32)
	var lat_s: PackedFloat64Array = LS[0]
	var lat_m: PackedFloat64Array = LM[0]
	var lat_p: PackedFloat64Array = LP[0]
	var lw_s: int = LS[1]
	var lw_m: int = LM[1]
	var lw_p: int = LP[1]
	var col_s: PackedInt32Array = LS[2]
	var col_m: PackedInt32Array = LM[2]
	var col_p: PackedInt32Array = LP[2]
	var fx_s: PackedFloat64Array = LS[3]
	var fx_m: PackedFloat64Array = LM[3]
	var fx_p: PackedFloat64Array = LP[3]
	var row_s: PackedInt32Array = LS[4]
	var row_m: PackedInt32Array = LM[4]
	var row_p: PackedInt32Array = LP[4]
	var fy_s: PackedFloat64Array = LS[5]
	var fy_m: PackedFloat64Array = LM[5]
	var fy_p: PackedFloat64Array = LP[5]
	var sides := [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1)]
	for by in range(0, H, 2):
		var ty := by / t
		for bx in range(0, W, 2):
			var tx := bx / t
			if tiles[ty * w + tx] == Gen.WALL:
				continue
			var near_wall := false
			for d: Vector2i in sides:
				var q := Vector2i((bx + d.x * 5) / t, (by + d.y * 5) / t)
				if q.x >= 0 and q.y >= 0 and q.x < w and q.y < h and tiles[q.y * w + q.x] == Gen.WALL:
					near_wall = true
			var i := row_s[by] + col_s[bx]
			var f := fx_s[bx]
			var silt := lerpf(lerpf(lat_s[i], lat_s[i + 1], f), lerpf(lat_s[i + lw_s], lat_s[i + lw_s + 1], f), fy_s[by])
			i = row_m[by] + col_m[bx]
			f = fx_m[bx]
			var moss := lerpf(lerpf(lat_m[i], lat_m[i + 1], f), lerpf(lat_m[i + lw_m], lat_m[i + lw_m + 1], f), fy_m[by]) + (0.18 if near_wall else 0.0)
			i = row_p[by] + col_p[bx]
			f = fx_p[bx]
			var pool := lerpf(lerpf(lat_p[i], lat_p[i + 1], f), lerpf(lat_p[i + lw_p], lat_p[i + lw_p + 1], f), fy_p[by])
			for dy in 2:
				for dx in 2:
					var x := bx + dx
					var y := by + dy
					if x >= W or y >= H:
						continue
					var c: Color = img.get_pixel(x, y)
					if painted and pool > 0.8:
						# Pass 3 D2: the shore wanders a pixel at a time, a ring of wet stone round it, the water
						# deeper toward the middle, a broken glint along the shore.
						var pj := pool + (_noise(x, y, 3.0, 62) - 0.5) * 0.03
						if pj > 0.84:
							c = water.lerp(water_deep, clampf((pj - 0.85) / 0.05, 0.0, 1.0))
							if pj < 0.847 and _noise(x, y, 2.0, 33) > 0.72:
								c = water_hi
							elif _h(x / 3, y, 63) > 0.985:
								c = water.lightened(0.12)   # a ripple
						elif pj > 0.822:
							c = _shade(c, 0.8).lerp(water, 0.16)
						if pj > 0.822:
							img.set_pixel(x, y, c)
							continue
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
							c = moss_hi if _noise(x, y, 6.0, 36) > 0.45 else moss_lo
						elif moss > 0.66 and c.v < 0.3:
							c = moss_lo   # moss starting in the seams around a clump
					img.set_pixel(x, y, c)


## Mouth only (Claude, 2026-10-22, WORLD-01): the river's old high-water marks, thin broken silt lines lying
## across the flagstones in twos and threes, a band of them every so often down the floor. Standing water is
## left alone (the mark stops at the shore); wall tiles are skipped, and the walls are drawn over them after.
static func _silt_lines(img: Image, data: Dictionary, t: int, seed_value: int) -> void:
	var w: int = data["w"]
	var tiles: PackedByteArray = data["tiles"]
	var W := img.get_width()
	var H := img.get_height()
	var s := seed_value % 757
	var y := 5 + int(_h(s, 0, 40) * 12)
	var band := 0
	while y < H - 3:
		var lines := 2 + int(_h(band, s, 41) * 2)
		for n in lines:
			var ly := y + n * (2 + int(_h(band, n, 42) * 2))
			if ly >= H:
				break
			var x := 0
			while x < W:
				var run := 10 + int(_h(x + band * 97, ly, 43) * 26)
				var gap := 3 + int(_h(x, ly + band, 44) * 9)
				if _h(x, band * 13 + n, 45) > 0.3:
					for k in run:
						var px := x + k
						if px >= W:
							break
						if tiles[(ly / t) * w + px / t] == Gen.WALL:
							continue
						var c: Color = img.get_pixel(px, ly)
						if c.b > c.r + 0.1:
							continue   # standing water
						img.set_pixel(px, ly, c.lerp(SILT, 0.6))
						if ly + 1 < H and _h(px, ly, 47) > 0.5:
							var under: Color = img.get_pixel(px, ly + 1)
							if under.b <= under.r + 0.1:
								img.set_pixel(px, ly + 1, under.lerp(SILT, 0.25))   # a softer pixel under the line
				x += run + gap
		y += 16 + int(_h(band, s, 46) * 16)
		band += 1


## Walls: the top of carved masonry seen from above, a lit lip where it meets the floor, and where a
## wall stands above floor, its face: courses of blocks, mortar, and a green water line at the foot.
static func _walls(img: Image, data: Dictionary, t: int, look: Dictionary = {}) -> void:
	var top: Color = look.get("wall_top", WALL_TOP)
	var painted: bool = look.get("painted", false)
	var w: int = data["w"]
	var h: int = data["h"]
	var tiles: PackedByteArray = data["tiles"]
	var face_h: int = int(t * 0.6)
	# The Hollow's rough tops: their soft noise laid out once, and each 16-pixel row's joint offset worked out once
	# (Claude, 2026-10-24, pass 5 A2; the same numbers as _noise(gx, gy, 10.0, 16) and _h(row, 0, 37)).
	var lat := PackedFloat64Array()
	var lw := 0
	var cols := PackedInt32Array()
	var fxs := PackedFloat64Array()
	var rows := PackedInt32Array()
	var fys := PackedFloat64Array()
	var joint := PackedInt32Array()
	if painted:
		_wall_tops(img, data, t, face_h, top)   # the Mouth's masonry and its dithered dark (pass 4 R1, R2)
	else:
		var L := _layer(0, 0, w * t, h * t, 10.0, 16)
		lat = L[0]
		lw = L[1]
		cols = L[2]
		fxs = L[3]
		rows = L[4]
		fys = L[5]
		joint.resize((h * t) / 16 + 1)
		for row in joint.size():
			joint[row] = int(_h(row, 0, 37) * 24)
	for y in h:
		for x in w:
			if tiles[y * w + x] != Gen.WALL:
				continue
			var fl := func(dx: int, dy: int) -> bool:
				var xx := x + dx
				var yy := y + dy
				return xx >= 0 and yy >= 0 and xx < w and yy < h and tiles[yy * w + xx] == Gen.FLOOR
			if not painted:
				for py in t:
					var gy := y * t + py
					var r := rows[gy]
					var fy := fys[gy]
					var jo := joint[gy / 16]
					for px in t:
						var gx := x * t + px
						# Rough dark stone, big blocks with faint joints and soft light and dark patches.
						var i := r + cols[gx]
						var f := fxs[gx]
						var c := top.lightened((lerpf(lerpf(lat[i], lat[i + 1], f), lerpf(lat[i + lw], lat[i + lw + 1], f), fy) - 0.5) * 0.12)
						if gy % 16 == 0 or (gx + jo) % 30 == 0:
							c = _shade(c, 0.88)
						img.set_pixel(gx, gy, c)
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
