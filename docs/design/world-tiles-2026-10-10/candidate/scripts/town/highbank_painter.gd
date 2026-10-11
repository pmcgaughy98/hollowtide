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
const R := preload("res://scripts/dungeon/ruin_painter.gd")      # hash and noise
const V := preload("res://scripts/dungeon/valley_painter.gd")    # the meadow
const T := Layout.T

const DRAWN := ["hall", "home", "shop", "storage", "scrolls", "gate", "plaza", "board", "yard", "shrine"]
const COBBLE := [Color("#b9a27c"), Color("#c4ad86"), Color("#ae9772"), Color("#cab48e")]
const MORTAR := Color("#7d6b4f")
const EARTH := [Color("#8e7a58"), Color("#99845f"), Color("#a38d66")]
const GRAVEL := Color("#b8aa8a")
const BANDS := [Color("#8f6a48"), Color("#a78560"), Color("#6f5540"), Color("#9c7b5a"), Color("#5f4a39")]
const TURF := [Color("#4f7a36"), Color("#5b8a3c"), Color("#67974a")]
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
			for py in T:
				for px in T:
					var x := tx * T + px
					var y := ty * T + py
					if _plain(base.get_pixel(x, y), kb):
						img.set_pixel(x, y, fresh.get_pixel(x, y))
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
			elif band == "grass":
				_grass(img, tx, ty)
			else:
				_earth(img, tx, ty)
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
	return Detail.river(img)


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

