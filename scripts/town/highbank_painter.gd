extends RefCounted
## Highbank's ground, given the dungeons' treatment (Claude, 2026-10-10; Preston: "do dungeon 1 and 2
## treatment for highbank. The town buildings look great, just the map could use some love, and we can
## just fill in the outline if needed").
##
## It paints over Codex's ground (highbank_ground_painter.gd); versioned native terrain materials
## opt in through world_tile_art.gd, with these original code functions retained as exact fallbacks,
## and leaves Codex's pixels alone wherever Codex drew a place (the buildings, the plaza, the gate, the
## board, the yard, the shrine) and one tile round each, so their contact shadows and door paths stay.
## Everywhere else: grass with clover, flowers and tufts on the bluff; cobbled lanes; packed earth on
## the terraces; banded cliffs with turf and roots; a living river with reeds and glints. The three
## places that were only an outline get ground of their own: the Bluff Lookout's flagstones and low
## wall, the Old Ferry Landing's worn stones and mooring posts, the Ferry Dock's planks.

const Layout := preload("res://scripts/town/town_layout.gd")
const Detail := preload("res://scripts/town/town_detail_art.gd")
const Tiles := preload("res://scripts/town/world_tile_art.gd")
const SelOut := preload("res://scripts/art/selout.gd")   # the cliff contour (_cliff_contour)
const R := preload("res://scripts/dungeon/ruin_painter.gd")      # hash and noise
const V := preload("res://scripts/dungeon/valley_painter.gd")    # the meadow
const T := Layout.T

const DRAWN := ["hall", "home", "shop", "storage", "scrolls", "gate", "plaza", "board", "yard", "shrine"]
const COBBLE := [Color("#b9a27c"), Color("#c4ad86"), Color("#ae9772"), Color("#cab48e")]
const MORTAR := Color("#7d6b4f")
const EARTH := [Color("#8e7a58"), Color("#99845f"), Color("#a38d66")]
const GRAVEL := Color("#b8aa8a")
const BANDS := [Color("#8f6a48"), Color("#a78560"), Color("#6f5540"), Color("#9c7b5a"), Color("#5f4a39")]
const TURF: Array = V.MEADOW   # Claude, 2026-10-22 (WORLD-02): the valley's meadow, the one grass ramp
const ROOT := Color("#3f2a19")
const DEEP := Color("#2f5866")
const MID := Color("#3b6f7c")
const SHALLOW := Color("#4f8a90")
const GLINT := Color("#a9d4d6")
const REED := [Color("#5d7a3a"), Color("#7a9a4a")]
const PLANK := [Color("#8a6a48"), Color("#9a7853"), Color("#7c5e3f")]
const FLAG := [Color("#a7a493"), Color("#b3ae9a"), Color("#9a9786")]


static func paint(base: Image) -> Image:
	var img: Image = base.duplicate()
	var keep := PackedByteArray()
	keep.resize(Layout.W * Layout.H)
	for p in Layout.PLACES:
		if p["id"] in DRAWN:
			var r: Rect2i = p["rect"].grow(1)
			for y in range(r.position.y, r.end.y):
				for x in range(r.position.x, r.end.x):
					if x >= 0 and y >= 0 and x < Layout.W and y < Layout.H:
						keep[y * Layout.W + x] = 1
	# Inside Codex's places, only its plain grass and earth are repainted (from a layer of fresh ground),
	# so its shadows, door paths and steps stay and no rectangle shows where its area ends.
	var fresh := Image.create(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8)
	var plain_tiles: Array[Vector2i] = []
	for ty in Layout.H:
		for tx in Layout.W:
			if keep[ty * Layout.W + tx] != 1:
				continue
			var kb := Layout.band_of(ty)
			if _path(tx, ty) and kb != "cliff":
				_cobbles(img, tx, ty)   # one street everywhere, through Codex's places too
				continue
			if kb == "grass":
				_grass(fresh, tx, ty)
			elif kb == "terrace":
				_earth(fresh, tx, ty)
			else:
				continue
			plain_tiles.append(Vector2i(tx, ty))
	var open_tiles: Array[Vector2i] = []
	for ty in Layout.H:
		for tx in Layout.W:
			if keep[ty * Layout.W + tx] == 1:
				continue
			var band := Layout.band_of(ty)
			var path := _path(tx, ty)
			if band == "cliff":
				if not path:
					_cliff(img, tx, ty)
				else:
					Tiles.steps(img,tx,ty)
			elif band == "water":
				_river(img, tx, ty)
			elif path:
				_cobbles(img, tx, ty)
			else:
				if band == "grass":
					_grass(fresh, tx, ty)
				else:
					_earth(fresh, tx, ty)
				open_tiles.append(Vector2i(tx, ty))
	# A2 (Claude, 2026-10-24): all the open ground is laid on the fresh layer and takes its patches there in one pass;
	# then it goes in whole on open tiles, and pixel by pixel where Codex's places leave plain ground.
	_patches(fresh)
	for t in open_tiles:
		img.blit_rect(fresh, Rect2i(t * T, Vector2i(T, T)), t * T)
	for t in plain_tiles:
		var kb := Layout.band_of(t.y)
		for py in T:
			for px in T:
				var x := t.x * T + px
				var y := t.y * T + py
				if _plain(base.get_pixel(x, y), kb):
					img.set_pixel(x, y, fresh.get_pixel(x, y))
	_bridges(img, fresh)   # A1: the walks from Market Street to the Shrine and the Yard
	_wear(img)             # A2: worn dirt where lanes turn and at an area's step
	_scatter(img, keep)    # A2: tufts, stones and flowers off the tiles' repeat
	_reeds(img)
	for p in Layout.PLACES:
		match p["id"]:
			"lookout":
				_lookout(img, p["rect"])
			"landing":
				_landing(img, p["rect"])
			"dock":
				_dock(img, p["rect"])
	Tiles.aprons(img)
	Tiles.clearings(img)
	_reading_spot(img, fresh)   # pass 8 T10: the Job Board's reading pad as worn earth, not a tile-sized square
	_fray(img)
	_soften(img)   # pass 5 T9: the ruled edges below Wayline Hall
	# The cliff ledges keep their contour; the lanes no longer get one (Claude, 2026-10-23, T2): world_finish.gd's
	# paint() rims both, over the whole map, and the lane rim was the ink line round every street rectangle.
	return _cliff_contour(Detail.river(img))


const PLAIN_GRASS := [Color("#637849"), Color("#677c4c"), Color("#6b804f"), Color("#6f8352")]   # Codex's grass tones
const PLAIN_EARTH := [Color("#8b7c5b"), Color("#8f805e"), Color("#948461"), Color("#998866")]   # its terrace earth


## Whether a pixel of Codex's ground is its plain ground for this band (grass on the bluff, earth on the
## terraces), and so can take the new ground. The plaza's sand on the bluff is not, and stays.
static func _plain(c: Color, band: String) -> bool:
	if Tiles.image("grass" if band=="grass" else "earth")!=null:
		for ground in ([Color("#53673e"),Color("#88965e"),Color("#819059")] if band=="grass" else [Color("#a69776"),Color("#73674d")]):
			if c.to_rgba32()==ground.to_rgba32():return true
	for p in (PLAIN_GRASS if band == "grass" else PLAIN_EARTH):
		if absf(c.r - p.r) + absf(c.g - p.g) + absf(c.b - p.b) < 0.09:
			return true
	return false


static func _path(x: int, y: int) -> bool:
	for r in Layout.PATHS:
		if r.has_point(Vector2i(x, y)):
			return true
	return false


## Cobbles: rounded stones in offset rows, sandy mortar, grass creeping in at a lane's edge.
static func _cobbles(img: Image, tx: int, ty: int) -> void:
	if Tiles.lane(img,tx,ty):return
	var edge := not _path(tx, ty - 1) or not _path(tx, ty + 1) or not _path(tx - 1, ty) or not _path(tx + 1, ty)
	for py in T:
		for px in T:
			var x := tx * T + px
			var y := ty * T + py
			var row := y / 6
			var off := 4 if row % 2 == 1 else 0
			var cx := (x + off) % 8
			var cy := y % 6
			var c: Color = COBBLE[int(R._h((x + off) / 8, row, 100) * COBBLE.size())]
			if cx == 0 or cy == 0:
				c = MORTAR
			elif cx == 1 or cy == 1:
				c = c.lightened(0.08)
			elif cx == 7 or cy == 5:
				c = c.darkened(0.12)
			elif R._h(x, y, 101) > 0.93:
				c = c.darkened(0.08)
			var near_edge := (px < 3 and not _path(tx - 1, ty)) or (px > T - 4 and not _path(tx + 1, ty)) or (py < 3 and not _path(tx, ty - 1)) or (py > T - 4 and not _path(tx, ty + 1))
			if edge and near_edge and R._noise(x, y, 5.0, 102) > 0.55:
				c = TURF[1] if R._h(x, y, 103) > 0.4 else TURF[0]   # grass in the joints at the edge
			img.set_pixel(x, y, c)


## The terraces: packed earth with gravel, the odd pebble and a few tufts.
static func _earth(img: Image, tx: int, ty: int) -> void:
	if Tiles.tile(img,"earth",tx,ty):return
	for py in T:
		for px in T:
			var x := tx * T + px
			var y := ty * T + py
			var c: Color = EARTH[0].lerp(EARTH[2], R._noise(x + 5, y, 20.0, 104))
			var n := R._h(x, y, 105)
			if n > 0.93:
				c = GRAVEL
			elif n < 0.06:
				c = c.darkened(0.15)
			if R._noise(x, y + 9, 10.0, 106) > 0.86:
				c = TURF[1] if R._noise(x, y, 4.0, 108) > 0.5 else TURF[0]   # a small solid tuft
			img.set_pixel(x, y, c)


## A cliff tile: a turf lip, then bands of river sediment with stones set in, roots hanging, a dark foot.
static func _cliff(img: Image, tx: int, ty: int) -> void:
	if Tiles.tile(img,"cliff" if ty==18 else "cliff_b",tx,ty):return
	for px in T:
		var x := tx * T + px
		var lip := 2 + int(R._h(x, ty, 109) * 2.5)
		var root_len := 3 + int(R._h(x, ty, 110) * 9) if R._h(x, ty, 111) > 0.88 else 0
		for py in T:
			var y := ty * T + py
			var c: Color
			if py < lip:
				c = TURF[2] if py == 0 else TURF[1]
			else:
				var band := int((py + sin(x * 0.17) * 1.3) / 3.0)
				c = BANDS[posmod(band + tx % 2, BANDS.size())]
				if R._h(x, y, 112) > 0.9:
					c = c.lightened(0.07)
				if R._h(x / 3, y / 2, 113) > 0.96:
					c = Color("#86827a")
				if py >= T - 3:
					c = c.darkened(0.25 + 0.15 * (py - (T - 3)))
				if root_len > 0 and py - lip < root_len:
					c = ROOT
			img.set_pixel(x, y, c)


## The river: shallow by the bank, deep further out, current lines drifting along it, a glint now and then.
static func _river(img: Image, tx: int, ty: int) -> void:
	var top: int = Layout.BANDS[Layout.BANDS.size() - 1]["from"]
	for py in T:
		for px in T:
			var x := tx * T + px
			var y := ty * T + py
			var depth := float(y - top * T) / float(2 * T)
			var c: Color = SHALLOW.lerp(DEEP, clampf(depth * 1.3, 0.0, 1.0))
			if depth < 0.12:
				c = SHALLOW.lightened(0.08)
			var flow := sin(x * 0.11 + R._noise(x, y, 14.0, 114) * 4.0 + y * 0.9)
			if flow > 0.93:
				c = MID.lightened(0.12)
			if R._h(x / 2, y, 115) > 0.985:
				c = GLINT
			img.set_pixel(x, y, c)
	# A foam line where the water meets the bank.
	if ty == top:
		for px in T:
			if R._h(tx * T + px, 0, 116) > 0.3:
				img.set_pixel(tx * T + px, ty * T, Color("#cfe0d8"))


## Reeds along the water's edge, rooted on the last row of the bank.
static func _reeds(img: Image) -> void:
	var y0: int = Layout.BANDS[Layout.BANDS.size() - 1]["from"] * T
	for x in range(0, img.get_width(), 3):
		if R._h(x, 7, 117) < 0.55:
			continue
		var tx := x / T
		var on_dock := false
		for p in Layout.PLACES:
			if p["id"] in ["dock", "landing", "gate"] and p["rect"].grow(1).has_point(Vector2i(tx, Layout.BANDS[Layout.BANDS.size() - 1]["from"] - 1)):
				on_dock = true
		if on_dock:
			continue
		var hgt := 4 + int(R._h(x, 8, 118) * 6)
		for k in hgt:
			var px := x + (1 if k > hgt - 3 and R._h(x, k, 119) > 0.5 else 0)
			img.set_pixel(px, y0 + 2 - k, REED[0] if k < hgt - 2 else REED[1])
		if R._h(x, 9, 120) > 0.7:
			img.set_pixel(x, y0 + 1 - hgt, Color("#7a4f2e"))   # a cattail head
			img.set_pixel(x, y0 - hgt, Color("#7a4f2e"))


static func _slabs(img: Image, r: Rect2i, cols: Array, salt: int) -> void:
	for y in range(r.position.y * T, r.end.y * T):
		for x in range(r.position.x * T, r.end.x * T):
			var row := y / 10
			var off := int(R._h(row, salt, 121) * 12)
			var sx := (x + off) / 14
			var c: Color = cols[int(R._h(sx, row, 122 + salt) * cols.size())]
			var lx := (x + off) % 14
			var ly := y % 10
			if lx == 0 or ly == 0:
				c = MORTAR.darkened(0.1)
			elif lx == 1 or ly == 1:
				c = c.lightened(0.08)
			elif R._h(x, y, 123) > 0.94:
				c = c.darkened(0.1)
			img.set_pixel(x, y, c)


## The Bluff Lookout: a flagstone overlook with a low stone wall along its far edge.
static func _lookout(img: Image, r: Rect2i) -> void:
	_slabs(img, r, FLAG, 1)
	if Detail.available("floor"):Detail.floor_material(img,r)
	if Detail.available("lookout"):return # new low wall replaces the old underpaint
	var y0 := r.position.y * T
	for x in range(r.position.x * T, r.end.x * T):
		for k in 7:
			var c: Color = Color("#8a8574") if k < 2 else Color("#6f6b5c")
			if k == 0:
				c = Color("#b3ae9a")
			if (x / 8) % 2 == 0 and k == 3:
				c = Color("#5a5649")   # the joints between the wall's blocks
			img.set_pixel(x, y0 + k, c)
		img.set_pixel(x, y0 + 7, Color(0.2, 0.18, 0.15))


## The Old Ferry Landing: worn stones with gravel between, and mooring posts along the water side.
static func _landing(img: Image, r: Rect2i) -> void:
	_slabs(img, r, [Color("#a8987a"), Color("#b5a585"), Color("#9c8c70")], 2)
	if Detail.available("floor"):Detail.floor_material(img,r)
	if Detail.available("landing"):return # avoid duplicate old mooring posts below the new art
	var y1 := r.end.y * T - 6
	for k in range(r.position.x * T + 10, r.end.x * T - 6, 36):
		for dy in 9:
			for dx in 5:
				var c := Color("#5e4129") if dx in [1, 2, 3] else Color("#3f2a19")
				if dy == 0:
					c = Color("#8a6440")
				img.set_pixel(k + dx, y1 - 6 + dy, c)


## The Ferry Dock: planks running out over the water, gaps between them, posts at the corners.
static func _dock(img: Image, r: Rect2i) -> void:
	for y in range(r.position.y * T, r.end.y * T + T):
		for x in range(r.position.x * T, r.end.x * T):
			var board := (y - r.position.y * T) / 5
			var c: Color = PLANK[int(R._h(board, x / 30, 124) * PLANK.size())]
			if (y - r.position.y * T) % 5 == 4:
				c = Color("#3f2a19")
			elif R._h(x, y, 125) > 0.92:
				c = c.darkened(0.15)
			elif (x + board * 13) % 37 == 0:
				c = Color("#5e4129")   # a nail line
			img.set_pixel(x, y, c)


static func _grass(img:Image,tx:int,ty:int)->void:
	if not Tiles.tile(img,"grass",tx,ty):V._meadow_tile(img,tx,ty,T,17)


# ---------------------------------------------------------------- ground patches (Claude, 2026-10-24, A2 / L22)
## Open ground was one even carpet: the grass and earth tiles repeat every 8 tiles, and every tile's mean sat within
## 4 or 5 luminance of the rest. A low value noise, its patches 3 to 6 tiles across, now lays the ground a step
## lighter or a step darker (about 10 luminance; darker a touch richer, lighter a touch paler) in round-edged
## patches whose outline is a dithered curve that never follows the tile grid. Then worn dirt where lanes turn and
## outside an area's step, and a few tufts, stones and flowers off the tiles' repeat. Code only, no new tiles; the
## walkable grid does not change.
const PATCH_LO := 0.43      # the field below this: a step darker
const PATCH_HI := 0.55      # above this: a step lighter
const PATCH_EDGE := 0.005   # half the dithered band along a patch's edge, in field units (about a pixel)
const PATCH_STEP := {"grass": 0.1, "terrace": 0.085}   # brightness of one step: 11 luminance a pixel, 9 to 10 a tile
const PATCH_SAT := [1.06, 1.0, 0.96]   # saturation at the darker, plain and lighter steps
const PATCH_SALT := 141
const NEIGH8 := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT, Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)]
static var _patch_masks: Array = []   # [darker, lighter]: whole-map alpha masks, built once


## The patch field at tile (x, y), 0 to 1: value noise on cells of 3 tiles, a quarter of it on cells of 1.5.
static func _field(x: int, y: int) -> float:
	return 0.75 * R._noise(x, y, 3.0, PATCH_SALT) + 0.25 * R._noise(x, y, 1.5, PATCH_SALT + 1)


## `img`'s ground a step darker and a step lighter where the patches lie: each band's rows stepped as a whole by
## adjust_bcs, then copied through the masks. Image calls do the pixel work: about 40 ms for the map, and the masks
## about 90 ms more the first time.
static func _patches(img: Image) -> void:
	var masks := _masks()
	for i in 2:
		var lv := -1 if i == 0 else 1
		var stepped: Image = img.duplicate()
		for b in Layout.BANDS:
			if PATCH_STEP.has(b["kind"]):
				var rows := Rect2i(0, b["from"] * T, img.get_width(), (b["to"] - b["from"] + 1) * T)
				var part := img.get_region(rows)
				part.adjust_bcs(1.0 + lv * PATCH_STEP[b["kind"]], 1.0, PATCH_SAT[lv + 1])
				stepped.blit_rect(part, Rect2i(Vector2i.ZERO, rows.size), rows.position)
		img.blit_rect_mask(stepped, masks[i], Rect2i(Vector2i.ZERO, img.get_size()), Vector2i.ZERO)


## The patch masks. The field is worked out a tile at a time and scaled up smooth to the pixel (cubic to a quarter
## tile, then bilinear: the same curves as cubic all the way for a tenth of the time), then cut at each threshold
## twice, a pixel's worth of field either side: everything past the outer cut, and every other pixel between the two,
## so a patch's edge is a dithered curve.
static func _masks() -> Array:
	if not _patch_masks.is_empty():
		return _patch_masks
	var size := Vector2i(Layout.W * T, Layout.H * T)
	var field := Image.create(Layout.W, Layout.H, false, Image.FORMAT_L8)
	for y in Layout.H:
		for x in Layout.W:
			var v := _field(x, y)
			field.set_pixel(x, y, Color(v, v, v))
	field.resize(Layout.W * 4, Layout.H * 4, Image.INTERPOLATE_CUBIC)
	field.resize(size.x, size.y, Image.INTERPOLATE_BILINEAR)
	var checker := _checker(size)
	var clear := Image.create(size.x, size.y, false, Image.FORMAT_LA8)
	var whole := Rect2i(Vector2i.ZERO, size)
	for lv: int in [-1, 1]:
		var edge: float = PATCH_EDGE * lv   # the outer cut is further from the plain ground
		var cut: float = PATCH_LO if lv < 0 else PATCH_HI
		var core := _cut(field, cut + edge, lv > 0)
		var band := _cut(field, cut - edge, lv > 0)
		band.blit_rect_mask(clear, checker, whole, Vector2i.ZERO)   # every other pixel of the band
		band.blit_rect_mask(core, core, whole, Vector2i.ZERO)       # and all of the core
		_patch_masks.append(band)
	return _patch_masks


## An LA8 mask, opaque where `field` (L8) is above `cut` (below it when not `above`): adjust_bcs's contrast pushes
## the field to 0 or 255 about the cut (turned over by a negative contrast), and with each byte doubled across, the
## same bytes read as grey-and-alpha pairs.
static func _cut(field: Image, cut: float, above: bool) -> Image:
	var m: Image = field.duplicate()
	m.adjust_bcs(0.5 / cut, 400.0 if above else -400.0, 1.0)
	var size := m.get_size()
	m.resize(size.x * 2, size.y, Image.INTERPOLATE_NEAREST)
	return Image.create_from_data(size.x, size.y, false, Image.FORMAT_LA8, m.get_data())


## A whole-map LA8 checkerboard (opaque where x + y is even), a 2 x 2 doubled out by blits.
static func _checker(size: Vector2i) -> Image:
	var m := Image.create(size.x, size.y, false, Image.FORMAT_LA8)
	m.set_pixel(0, 0, Color.WHITE)
	m.set_pixel(1, 1, Color.WHITE)
	var w := 2
	while w < size.x:
		m.blit_rect(m, Rect2i(0, 0, w, 2), Vector2i(w, 0))
		w *= 2
	var h := 2
	while h < size.y:
		m.blit_rect(m, Rect2i(0, 0, size.x, h), Vector2i(0, h))
		h *= 2
	return m


## Worn dirt: the inside corner where a lane turns (feet cut across it) and the ground outside an area's door step.
## The terraces' own earth a shade lighter, round with a ragged edge dithered out, some ground left showing through.
static func _wear(img: Image) -> void:
	var earth := Tiles.image("earth")
	for spot in _wear_spots():
		var c: Vector2 = spot[0]
		var r: float = spot[1]
		for y in range(int(c.y - r - 2.0), int(c.y + r + 2.0)):
			for x in range(int(c.x - r - 2.0), int(c.x + r + 2.0)):
				var p := Vector2i(x, y)
				if x < 0 or y < 0 or not _open_ground(p / T):   # ground only: never a lane, a place, a cliff or water
					continue
				var dist := Vector2(x + 0.5, y + 0.5).distance_to(c) / r + (R._noise(x, y, 4.0, 145) - 0.5) * 0.5
				if dist >= 1.0 or (dist > 0.7 and (dist - 0.7) / 0.3 > _dither(p)) or R._h(x, y, 146) > 0.92:
					continue
				var dirt: Color = Tiles.sample(earth, x, y) if earth != null else WORN[int(R._h(x / 2, y / 2, 138) * WORN.size())]
				img.set_pixelv(p, dirt.lightened(0.05 if Layout.band_of(y / T) == "grass" else 0.08))


## The Job Board's reading spot (Claude, 2026-10-26, pass 8 T10 / L30): world_tile_art.gd's clearings() lays the reading
## pad over its whole tile, a square of earth that, with the corner ticks job_board_painter.gd drew on it, read as a
## dashed rectangle in front of the board. After it, here, the pad becomes earth worn bare by feet, as the worn spots
## above are: an uneven oval in the tile's middle with a dithered edge, the rest of the pad's ground back to grass. The
## same bounds as clearings() (never a lane or a place); the tile, its door and the board are unchanged.
const READING_RX := 10.5   # the worn oval's half-width and half-height, px
const READING_RY := 10.0


static func _reading_spot(img: Image, fresh: Image) -> void:
	var board: Array = Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "board")
	if board.is_empty():
		return
	var d: Vector2i = board[0]["door"] * T
	var earth := Tiles.image("earth")
	var mid := Vector2(d) + Vector2(T * 0.5, T * 0.58)
	for y in T:
		for x in range(-4, T + 4):
			var p := d + Vector2i(x, y)
			if _path(p.x / T, p.y / T) or _in_place(p / T):
				continue
			var off := Vector2(p) + Vector2(0.5, 0.5) - mid
			var dist := Vector2(off.x / READING_RX, off.y / READING_RY).length() + (R._noise(p.x, p.y, 4.0, 172) - 0.5) * 0.4
			if dist < 0.72 or (dist < 1.0 and (dist - 0.72) / 0.28 <= _dither(p)):
				var dirt: Color = Tiles.sample(earth, p.x, p.y) if earth != null else WORN[int(R._h(p.x / 2, p.y / 2, 173) * WORN.size())]
				img.set_pixelv(p, dirt.lightened(0.05))
			else:
				img.set_pixelv(p, fresh.get_pixelv(p))


## [centre px, radius] of each worn spot: every open tile with lane on two sides that meet at one of its corners,
## and the ground outside an area's door where the door is on the area's edge (the Shrine and the Yard have walks).
static func _wear_spots() -> Array:
	var out: Array = []
	for ty in Layout.H:
		for tx in Layout.W:
			if not _open_ground(Vector2i(tx, ty)):
				continue
			for sx in [-1, 1]:
				for sy in [-1, 1]:
					if _path(tx + sx, ty) and _path(tx, ty + sy) and Layout.band_of(ty + sy) != "cliff":
						var corner := Vector2((tx + maxi(sx, 0)) * T, (ty + maxi(sy, 0)) * T)
						out.append([corner, 11.0 + R._h(tx, ty, 147) * 3.0])
	for p in Layout.PLACES:
		if p["kind"] != "area" or WALKS.has(p["id"]):
			continue
		var door: Vector2i = p["door"]
		for d in SIDES:
			if not p["rect"].has_point(door + d) and _open_ground(door + d):
				out.append([Vector2(door * T) + Vector2(T, T) * 0.5 + Vector2(d) * (T * 0.5), 9.0])
	return out


## A few small things off the tiles' 8-tile repeat, from the meadow's palette: tufts, stones and flowers on the bluff,
## stones and dry tufts on the terraces. About one quiet tile in six; never within a tile of a lane, a place, a cliff
## or the water (the seams copy ground across from a few px out, and would print a thing twice).
static func _scatter(img: Image, keep: PackedByteArray) -> void:
	for ty in Layout.H:
		var kind := Layout.band_of(ty)
		if kind != "grass" and kind != "terrace":
			continue
		for tx in Layout.W:
			if keep[ty * Layout.W + tx] == 1 or R._h(tx, ty, 150) > (0.17 if kind == "grass" else 0.14) or not _quiet(tx, ty):
				continue
			var p := Vector2i(tx * T + 5 + int(R._h(tx, ty, 151) * 13.0), ty * T + 7 + int(R._h(tx, ty, 152) * 12.0))
			var roll := R._h(tx, ty, 153)
			if roll < (0.45 if kind == "grass" else 0.35):
				_tuft(img, p, kind == "grass")
			elif roll < (0.75 if kind == "grass" else 1.0):
				_stone(img, p)
			else:
				_flower(img, p, R._h(tx, ty, 154))


## Open ground with open ground on all eight sides.
static func _quiet(tx: int, ty: int) -> bool:
	if not _open_ground(Vector2i(tx, ty)):
		return false
	for d in NEIGH8:
		if not _open_ground(Vector2i(tx, ty) + d):
			return false
	return true


## Three blades, the middle one tallest, the outer two leaning out at the tip; lush on the bluff, dry on the terraces.
static func _tuft(img: Image, p: Vector2i, lush: bool) -> void:
	var top: Color = V.TUFT if lush else TURF[1]
	for b in [-1, 0, 1]:
		var hgt := 2 + (1 if b == 0 else 0) + (1 if R._h(p.x + b, p.y, 155) > 0.6 else 0)
		for q in hgt:
			img.set_pixel(p.x + b + (b if q == hgt - 1 and hgt > 2 else 0), p.y - q, top if q > 0 else V.TUFT_LO)


## A pebble 2 or 3 px wide, lit top-left, its shadow on the ground below and to the right.
static func _stone(img: Image, p: Vector2i) -> void:
	var w := 2 + int(R._h(p.x, p.y, 156) * 1.999)
	for x in w:
		img.set_pixel(p.x + x + 1, p.y + 2, img.get_pixel(p.x + x + 1, p.y + 2).darkened(0.3))
	for x in w:
		img.set_pixel(p.x + x, p.y, GRAVEL if x == 0 else V.ROCK[1])
		img.set_pixel(p.x + x, p.y + 1, V.ROCK[2] if x == w - 1 else V.ROCK[1])


## A small flower in one of the meadow's colours, a gold eye, its stem.
static func _flower(img: Image, p: Vector2i, roll: float) -> void:
	var col: Color = V.FLOWERS[int(roll * V.FLOWERS.size())]
	img.set_pixel(p.x, p.y + 1, V.TUFT_LO)
	for o in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1)]:
		img.set_pixelv(p + o, col)
	img.set_pixelv(p, Color("#e8b84a"))


# ---------------------------------------------------------------- the walks to the Shrine and the Yard (Claude, 2026-10-24, A1)
## Market Street down to the Growth Shrine and the Training Yard: Codex's painters bridged the grass gap with a flat
## blend of two earth tones, a tan rectangle with ruled sides whose pixels held one colour for 20 px at a time
## (Preston's live run, LV-12a). Each is now a short stone walk like the switchback crossings: the lane's own stone,
## a tread every 6 px with its nose lit and a shadow under it, joints and chips breaking every course; a worn earth
## verge 2 to 4 px wide down each side, dithered into the stone; sides that wander a few px either way of the old line
## and dither into the grass; a ragged foot. What the old flat blend covered and the walk does not takes the fresh
## ground back. Pictures only.
## Each place's old blend, as its painter drew it: how far it ran on below the door's top, its half-width, and (the
## Yard's) how it widened toward the street, 1 px every `flare` rows.
const WALKS := {"shrine": {"below": 8, "half": 12, "flare": 0}, "yard": {"below": 14, "half": 11, "flare": 6}}
const TREAD := Color("#d0b891")         # the crossings' tread nose and shadow (world_tile_art.gd steps)
const TREAD_SHADOW := Color("#665a45")
const JOINT := Color("#807559")         # the ground painter's road joint


static func _bridges(img: Image, fresh: Image) -> void:
	var lane := Tiles.image("lane")
	var earth := Tiles.image("earth")
	for p in Layout.PLACES:
		if not WALKS.has(p["id"]):
			continue
		var w: Dictionary = WALKS[p["id"]]
		var d: Vector2i = p["door"] * T
		var cx := d.x + 12.0
		var y0 := d.y - T
		var y1: int = d.y + w["below"]
		for y in range(y0, y1):
			var old_half: int = w["half"] + (maxi(0, d.y - y) / w["flare"] if w["flare"] > 0 else 0)
			var hw := 10.0 + 3.0 * _wander(y, int(cx), 6.0, 160)   # 10 to 13 px each side of the middle
			if y >= d.y:
				hw = minf(hw, old_half)   # inside the place, never wider than the old blend
			var verge := 2 + int(R._h(y / 5, int(cx), 161) * 2.999)   # 2 to 4 px, in runs of 5 rows (as the road's)
			for x in range(int(cx) - 17, int(cx) + 17):
				var pos := Vector2i(x, y)
				var k := hw - absf(x + 0.5 - cx)   # px in from the walk's side
				var foot := y1 - 1 - int(2.5 * _wander(x, y1, 4.0, 163))   # the ragged last rows
				var walk := k > 0.0 and y <= foot and not (k <= 1.0 and _dither(pos) > 0.5) and not (y == foot and _dither(pos) > 0.5)
				var old := x >= cx - old_half and x < cx + old_half
				if not walk:
					if old:
						img.set_pixelv(pos, fresh.get_pixelv(pos))   # the ground the old blend covered
					continue
				var c: Color
				if k <= verge or (k <= verge + 1 and (x + y) % 2 == 0):
					c = Tiles.sample(earth, x, y).darkened(0.06) if earth != null else Color("#918461")
				else:
					c = _walk_stone(lane, x, y, y - y0)
				img.set_pixelv(pos, c)


## The walk's stone at (x, y), `ly` rows down it: the lane's stone, and every 6 rows a tread as on the crossings (a lit
## nose row, two rows of shadow under it), laid as stones 5 px long, each its own shade, a gap of stone between two.
static func _walk_stone(lane: Image, x: int, y: int, ly: int) -> Color:
	var s: Color = Tiles.sample(lane, x, y) if lane != null else COBBLE[int(R._h(x / 6, y / 5, 164) * COBBLE.size())]
	var course := ly / 6
	var r := ly % 6
	if r != 0 and r < 4:
		return s
	var off := int(R._h(course, 0, 165) * 6.0)   # each course's gaps fall somewhere else
	if posmod(x + off, 6) == 0:
		return s.darkened(0.1 if r == 0 else 0.3)
	var tone := R._h((x + off) / 6, course, 166)
	if r == 0:
		return TREAD if tone < 0.5 else TREAD.darkened(0.07)
	return TREAD_SHADOW if tone < 0.5 else TREAD_SHADOW.lightened(0.08)


# ---------------------------------------------------------------- frayed seams (Claude, 2026-10-23, T2 / L22)
## The street was a collage: hard rectangles of cobble with an ink rim round each. Now every seam where a lane, or
## the flagstones of the Bluff Lookout and the Old Ferry Landing, meets open grass or earth wanders a few px either
## way of the old straight line, over a dithered band 2 to 4 px wide, with tufts of grass leaning over the stones
## on the bluff and loose grit on the terraces; and a lane that stops (Market Street's west end, the landing lane's
## east end) wears into packed dirt over its last tile and a half, rounding off to a worn tongue the ground takes.
## Pictures only: the walkable tiles do not change. A procedural pass, no new tiles (full autotiling is call P8).
const BAND_MIN := 2     # the dithered band between paving and ground, px
const BAND_MAX := 4
const FRAY_SHIFT := 6   # a frayed pixel takes the ground this far out across the seam, so its texture runs on
const TAPER := 36       # px over which a dead end wears from cobble to dirt
const TONGUE := 9       # px the worn dirt runs on past the end, into the ground
const WORN := [Color("#9a8560"), Color("#a6916a"), Color("#8c7856")]   # packed dirt, when the earth tile is missing
const SIDES := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
const BAYER := [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]   # 4 x 4 ordered dither


static func _fray(img: Image) -> void:
	var src: Image = img.duplicate()   # every copy reads the picture as it was before this pass
	for ty in Layout.H:
		for tx in Layout.W:
			if not _path(tx, ty) or Layout.band_of(ty) == "cliff" or _in_place(Vector2i(tx, ty)):
				continue
			for d in SIDES:
				if _open_ground(Vector2i(tx, ty) + d):
					_fray_side(img, src, Vector2i(tx, ty), d, 0)
	for p in Layout.PLACES:
		if p["id"] in ["lookout", "landing"]:
			var r: Rect2i = p["rect"]
			for ty in range(r.position.y, r.end.y):
				for tx in range(r.position.x, r.end.x):
					for d in SIDES:
						var n: Vector2i = Vector2i(tx, ty) + d
						if not r.has_point(n) and _open_ground(n):
							_fray_side(img, src, Vector2i(tx, ty), d, 40)
	for end in _lane_ends():
		_taper(img, src, end[0], end[1])


## Open ground a seam can fray into: on the map, grass or terrace, no lane and no place's own art.
static func _open_ground(t: Vector2i) -> bool:
	if t.x < 0 or t.y < 0 or t.x >= Layout.W or t.y >= Layout.H:
		return false
	return Layout.band_of(t.y) in ["grass", "terrace"] and not _path(t.x, t.y) and not _in_place(t)


static func _in_place(t: Vector2i) -> bool:
	for p in Layout.PLACES:
		if p["rect"].has_point(t):
			return true
	return false


## Smooth value noise along a seam, 0 to 1, over cells `cell` px long.
static func _wander(g: int, line: int, cell: float, salt: int) -> float:
	var c := floori(g / cell)
	var f := (g - c * cell) / cell
	f = f * f * (3.0 - 2.0 * f)
	return lerpf(R._h(c, line, salt), R._h(c + 1, line, salt), f)


static func _dither(p: Vector2i) -> float:
	return (BAYER[posmod(p.y, 4) * 4 + posmod(p.x, 4)] + 0.5) / 16.0


## One side of tile `t` (paved) where it meets ground at `t + d`. Across the seam, k counts px in from the paving's
## outer pixel (negative is out on the ground). The seam sits `o` px in, wandering -2 to 4 along it; inside it a
## band 2 to 4 px wide fades from ground to paving by ordered dither. Ground that takes paving pixels is carried
## across from FRAY_SHIFT px out, paving that spills onto the ground from 3 px in, so both textures run on.
static func _fray_side(img: Image, src: Image, t: Vector2i, d: Vector2i, salt: int) -> void:
	var across := Vector2i(absi(d.y), absi(d.x))   # runs along the seam
	var edge: Vector2i = t * T + Vector2i(T - 1 if d.x > 0 else 0, T - 1 if d.y > 0 else 0)   # the paving's outer pixel row
	var line: int = edge.y if d.y != 0 else 50000 + edge.x   # one seam, one noise, across tile joins
	var grassy := Layout.band_of((t + d).y) == "grass"
	for i in T:
		var e: Vector2i = edge + across * i
		var g: int = e.x if across.x == 1 else e.y
		var o := -2.0 + 6.0 * (0.7 * _wander(g, line, 12.0, 130 + salt) + 0.3 * _wander(g, line, 4.0, 131 + salt))
		var band := float(BAND_MIN + int(R._h(g / 3, line, 132 + salt) * (BAND_MAX - BAND_MIN + 0.999)))
		for k in range(-2, BAND_MAX + 5):
			var p: Vector2i = e - d * k
			var x := float(k) - o   # px past the seam toward the paving
			var paving := x >= band or (x >= 0.0 and x / band > _dither(p))
			if k >= 0 and not paving:
				img.set_pixelv(p, _at(src, p + d * FRAY_SHIFT))
			elif k < 0 and paving:
				img.set_pixelv(p, _at(src, p - d * 3))
		# A tuft where the seam runs in deepest on the bluff: blades of the ground's own greens over the paving.
		var tuft := _wander(g, line, 4.0, 133 + salt)
		if grassy and tuft > 0.68 and i % 2 == 0:
			var root := ceili(o) - 1
			var grow := 1 + int(R._h(g, line, 134 + salt) * 2.999)
			var lean: Vector2i = across * (1 if R._h(g, line, 135 + salt) > 0.5 else -1)
			var green := _at(src, e + d * FRAY_SHIFT)
			for k in grow:
				var at: Vector2i = e - d * (root + 1 + k) + (lean if k == grow - 1 and grow > 1 else Vector2i.ZERO)
				img.set_pixelv(at, green.lightened(0.16) if k == grow - 1 else green.darkened(0.05))
		elif not grassy and tuft > 0.8 and R._h(g, line, 136 + salt) > 0.5:
			img.set_pixelv(e - d * (ceili(o) + 1), GRAVEL)   # grit kicked onto the stones


## A pixel of `src`, the nearest one on the picture when `p` is off it.
static func _at(src: Image, p: Vector2i) -> Color:
	return src.get_pixelv(p.clamp(Vector2i.ZERO, src.get_size() - Vector2i.ONE))


## Lanes that stop in open ground: [rect, outward direction] for each short side of a PATHS rect whose tiles
## (those not under a place) face ground, where no other lane turns off beside it.
static func _lane_ends() -> Array:
	var out: Array = []
	for r in Layout.PATHS:
		if r.size.x == r.size.y:
			continue
		var along := Vector2i(1, 0) if r.size.x > r.size.y else Vector2i(0, 1)
		var across := Vector2i(along.y, along.x)
		for d in [along, -along]:
			var first: Vector2i = r.position if d.x + d.y < 0 else r.position + (r.size - Vector2i.ONE) * along
			var dead := true
			var seen := false
			for k in (r.size.y if along.x == 1 else r.size.x):
				var t: Vector2i = first + across * k
				if _in_place(t):
					continue
				seen = true
				if not _open_ground(t + d):
					dead = false
				for s in [across, -across]:
					if not r.has_point(t + s) and _path(t.x + s.x, t.y + s.y):
						dead = false   # a lane turns off here: a corner, not an end
			if dead and seen:
				out.append([r, d])
	return out


## A dead end wears out: its corners round off and a worn cap of packed dirt runs TONGUE px on into the ground; over
## its last TAPER px the cobbles sink into that dirt in patches, nearly all of them at the end, none a tile and a half
## in. The dirt is the terraces' own earth, a shade lighter; every outline is dithered into the ground.
const ROUND := 12.0   # px over which a dead end's corners round off


static func _taper(img: Image, src: Image, r: Rect2i, d: Vector2i) -> void:
	var earth := Tiles.image("earth")
	var px := Rect2i(r.position * T, r.size * T)
	var vertical := d.y != 0
	var c0: int = px.position.x if vertical else px.position.y   # across the lane
	var c1: int = px.end.x - 1 if vertical else px.end.y - 1
	var half := (c1 - c0 + 1) * 0.5
	var mid := (c0 + c1) * 0.5
	var sgn: int = d.x + d.y
	var tip: int = (px.end.y - 1 if vertical else px.end.x - 1) if sgn > 0 else (px.position.y if vertical else px.position.x)
	for u in range(-TONGUE, TAPER):   # u: px in from the end, negative past it
		var a: int = tip - sgn * u
		for c in range(c0, c1 + 1):
			var p := Vector2i(c, a) if vertical else Vector2i(a, c)
			if p.x < 0 or p.y < 0 or p.x >= img.get_width() or p.y >= img.get_height() or _in_place(p / T):
				continue
			var off := absf(c - mid) / half   # 0 on the lane's centre line, 1 at its sides
			var limit := 1.2   # past ROUND the lane's own sides hold (the seams are frayed already)
			if u < 0:
				limit = 0.78 * sqrt(maxf(0.0, 1.0 - pow(float(u) / TONGUE, 2.0)))
			elif u < ROUND:
				limit = 0.78 + 0.22 * sqrt(maxf(0.0, 1.0 - pow(1.0 - u / ROUND, 2.0)))
			var x := (limit - off + (R._noise(p.x, p.y, 4.0, 137) - 0.5) * 0.24) / 0.1   # 0 on the worn outline
			if x <= 0.0 or (x < 1.0 and x < _dither(p)):
				if u >= 0:
					img.set_pixelv(p, _at(src, p + d * (TAPER + FRAY_SHIFT)))   # the ground from past the end
				continue
			var dirt: Color = Tiles.sample(earth, p.x, p.y).lightened(0.05) if earth != null else WORN[int(R._h(p.x / 2, p.y / 2, 138) * WORN.size())]
			var wear := 1.0 - float(u) / TAPER
			if u < 0 or 0.65 * R._noise(p.x, p.y, 5.0, 139) + 0.35 * R._h(p.x, p.y, 140) < 0.15 + 0.7 * pow(wear, 1.5):
				img.set_pixelv(p, dirt)


# ---------------------------------------------------------------- below Wayline Hall (Claude, 2026-10-24, pass 5 T9 / LV-12)
## Below the Hall the street, the Crossroads' clearing and the Job Board's reading pad still met the grass along ruled
## lines (Preston's live run, LV-12: the Crossroads' top edge ran straight for 113 px). Here an irregular noise mask
## moves every straight edge between grass and paving or dirt off its line: along the edge the boundary wanders up to
## SOFT_REACH px either way (two value noises, on 12 px and 4 px cells), the pixels it crosses take their new side's
## texture from SOFT_SHIFT px further in, so stones and blades run on, and the new edge's own row is dithered. Edges
## across columns first, then across rows. A building keeps its pixels; pictures only, the walkable grid is the same.
## Highbank's street picture is kept on disk: raise hub_town.gd's STREET_VERSION with any change here.
const SOFT_TILES := Rect2i(15, 7, 19, 5)   # columns 15 to 33, rows 7 to 11: from the Hall's steps to the Crossroads
const SOFT_REACH := 3     # px the edge may move either way
const SOFT_SHIFT := 6     # px further in that a moved pixel takes its new side's texture from
const SOFT_CLEAN := 2     # px of one kind on each side that make an edge (a tuft, a flower or a stone stays as it is)
const SOFT_RUN := 5       # an edge this many px straight, or more, is moved
const K_OTHER := 0
const K_GRASS := 1
const K_PAVED := 2        # cobble, mortar, packed dirt: the warm ground


static func _soften(img: Image) -> void:
	var area := Rect2i(SOFT_TILES.position * T, SOFT_TILES.size * T)
	var pad := SOFT_REACH + SOFT_SHIFT + SOFT_CLEAN + 1
	var span := area.grow(pad).intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	var solid := _solid_mask(span)
	for across in [Vector2i(0, 1), Vector2i(1, 0)]:   # (0, 1): edges between a row and the next, so lines run along x
		var src: Image = img.duplicate()
		var kinds := _kinds(src, span)
		var along := Vector2i(across.y, across.x)
		var lanes: int = area.size.y if across.y == 1 else area.size.x   # the lines an edge can sit on
		var steps: int = area.size.x if across.y == 1 else area.size.y   # the px along each line
		var next: int = 1 if across.y == 0 else span.size.x              # the px across the edge, in `kinds`
		for li in lanes:
			var run: Array[int] = []
			var run_kind := -1
			for si in steps + 1:
				var edge := -1
				if si < steps:
					var p: Vector2i = area.position + along * si + across * li
					var at: int = (p.y - span.position.y) * span.size.x + (p.x - span.position.x)
					if kinds[at] != kinds[at + next] and kinds[at] != K_OTHER and kinds[at + next] != K_OTHER:   # most px: no edge
						edge = _edge_at(kinds, span, solid, p, across)
				if edge >= 0 and edge == run_kind:
					run.append(si)
					continue
				if run.size() >= SOFT_RUN:
					for s in run:
						_move_edge(img, src, kinds, span, solid, area.position + along * s + across * li, across, run_kind)
				run.clear()
				run_kind = edge
				if edge >= 0:
					run.append(si)


## The kind of each px in `span`: grass (green over red), paved (warm: red over green and blue) or other. Read from the
## raw bytes, as get_pixel per px costs about ten times as much.
static func _kinds(src: Image, span: Rect2i) -> PackedByteArray:
	var region := src.get_region(span)
	if region.get_format() != Image.FORMAT_RGBA8:
		region.convert(Image.FORMAT_RGBA8)
	var bytes := region.get_data()
	var out := PackedByteArray()
	out.resize(span.size.x * span.size.y)
	for i in out.size():
		var r := bytes[i * 4]
		var g := bytes[i * 4 + 1]
		var b := bytes[i * 4 + 2]
		if g > r + 6 and g >= b:
			out[i] = K_GRASS
		elif r >= g and r > b + 12:
			out[i] = K_PAVED
	return out


static func _kind(kinds: PackedByteArray, span: Rect2i, p: Vector2i) -> int:
	if not span.has_point(p):
		return K_OTHER
	return kinds[(p.y - span.position.y) * span.size.x + (p.x - span.position.x)]


## 1 for each px of `span` inside a building's footprint: its art is never moved, nor copied.
static func _solid_mask(span: Rect2i) -> PackedByteArray:
	var out := PackedByteArray()
	out.resize(span.size.x * span.size.y)
	for p in Layout.PLACES:
		if p["kind"] != "building":
			continue
		var r := Rect2i(p["rect"].position * T, p["rect"].size * T).intersection(span)
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				out[(y - span.position.y) * span.size.x + (x - span.position.x)] = 1
	return out


## The edge between `p` and `p + across`, as its two kinds (top or left kind * 3 + the other), when both sides are grass
## or paved, different, SOFT_CLEAN px deep each, and neither is a building's; else -1.
static func _edge_at(kinds: PackedByteArray, span: Rect2i, solid: PackedByteArray, p: Vector2i, across: Vector2i) -> int:
	var a := _kind(kinds, span, p)
	var b := _kind(kinds, span, p + across)
	if a == b or a == K_OTHER or b == K_OTHER:
		return -1
	for i in SOFT_CLEAN:
		if _kind(kinds, span, p - across * i) != a or _kind(kinds, span, p + across * (1 + i)) != b:
			return -1
	if _solid(solid, span, p) or _solid(solid, span, p + across):
		return -1
	return a * 3 + b


static func _solid(solid: PackedByteArray, span: Rect2i, p: Vector2i) -> bool:
	return not span.has_point(p) or solid[(p.y - span.position.y) * span.size.x + (p.x - span.position.x)] == 1


## Moves one px column (or row) of an edge: the near side (kind a, at `p`) reaches o px past the old line, o from -3 to 3
## along the edge; each px it crosses takes its new side's texture from SOFT_SHIFT px further in, or its mirror across the
## old line when that px is not of the kind. The first px past the new line is dithered back to the near side. A building's
## px is never written or read: the edge stops at its footprint (the Hall's steps meet its door).
static func _move_edge(img: Image, src: Image, kinds: PackedByteArray, span: Rect2i, solid: PackedByteArray, p: Vector2i, across: Vector2i, edge: int) -> void:
	var a := edge / 3
	var b := edge % 3
	var g: int = p.x if across.y == 1 else p.y            # where along the edge
	var line: int = (p.y if across.y == 1 else 70000 + p.x)   # one noise per line
	var w := 0.7 * _wander(g, line, 12.0, 180) + 0.3 * _wander(g, line, 4.0, 181)
	var o := clampi(roundi(-SOFT_REACH + 2.0 * SOFT_REACH * w), -SOFT_REACH, SOFT_REACH)
	# i counts px past the old line on the far side (1 is p + across); the near side now holds up to i == o.
	for i in range(mini(o, 0) + 1, maxi(o, 0) + 2):
		var q: Vector2i = p + across * i
		var near := i <= o or (i == o + 1 and _dither(q) > 0.5)
		var want := a if near else b
		if _kind(kinds, span, q) == want or _solid(solid, span, q):
			continue
		var from: Vector2i = q - across * SOFT_SHIFT if near else q + across * SOFT_SHIFT
		if _kind(kinds, span, from) != want or _solid(solid, span, from):
			from = p - across * (i - 1) if near else p + across * (1 - i)   # the mirror across the old line
		if _kind(kinds, span, from) == want and not _solid(solid, span, from):
			img.set_pixelv(q, src.get_pixelv(from))


## The cliff ledges' contour (world_finish.gd's sel-out on its cliff mask), run on the two cliff rows alone instead
## of the whole map: the same pixels, a fraction of the work (Claude, 2026-10-23, T1).
static func _cliff_contour(img: Image) -> Image:
	if img.get_size() != Vector2i(Layout.W * T, Layout.H * T):
		return img
	var out: Image = img.duplicate()
	for b in Layout.BANDS:
		if b["kind"] != "cliff":
			continue
		var y0: int = maxi(0, b["from"] * T - 3)
		var y1: int = mini(img.get_height(), (b["to"] + 1) * T + 3)
		var strip := Rect2i(0, y0, img.get_width(), y1 - y0)
		var mask := Image.create(strip.size.x, strip.size.y, false, Image.FORMAT_RGBA8)
		mask.fill(Color.BLACK)
		mask.fill_rect(Rect2i(0, b["from"] * T - y0, strip.size.x, (b["to"] - b["from"] + 1) * T), Color.WHITE)
		for r in Layout.PATHS:   # the stair channels divide the ledge
			mask.fill_rect(Rect2i(r.position.x * T, r.position.y * T - y0, r.size.x * T, r.size.y * T), Color.BLACK)
		var rimmed: Image = SelOut.selout(img.get_region(strip), mask)
		out.blit_rect(rimmed, Rect2i(Vector2i.ZERO, strip.size), strip.position)
		for p in Layout.PLACES:   # a place and the tile round it keep their own pixels, as world_finish.gd does
			var g: Rect2i = p["rect"].grow(1)
			var keep := Rect2i(g.position * T, g.size * T).intersection(strip)
			if keep.has_area():
				out.blit_rect(img, keep, keep.position)
	return out
