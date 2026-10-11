extends RefCounted
## The rooms inside Highbank's buildings, painted in code pixel by pixel like the dungeons (Claude,
## 2026-10-10). No generated art. Each piece of furniture is a block of its own colours with a lit top-left,
## a shaded bottom-right and a dark ink outline, the way the creatures and the town art are finished.
##   room_painter.paint("home", ROOMS["home"]) -> Image (w x h tiles at 24 px)

const R := preload("res://scripts/dungeon/ruin_painter.gd")   # hash and noise
const T := 24
const INK := Color("#1f1610")


static func paint(id: String, r: Dictionary) -> Image:
	var img := Image.create(r["w"] * T, r["h"] * T, false, Image.FORMAT_RGBA8)
	if id == "hall":
		_hall(img, r)
	elif id == "hall_low":
		_lower(img, r)
	elif id == "chamber":
		_chamber(img, r)
	elif id == "runners":
		_runners(img, r)
	else:
		_home(img, r)
	if id == "home":
		img = preload("res://scripts/town/home_room_art.gd").paint(img)
	elif id == "hall":
		img = preload("res://scripts/town/hall_room_art.gd").paint(img)
		_stairs(img, Rect2i(14 * T, 10 * T, 2 * T, 2 * T), true)   # down to the Hall floor (town_room STAIRS_DOWN)
	if id in ["hall", "hall_low", "chamber", "runners"]:
		img = preload("res://scripts/town/hall_floors_art.gd").paint(id, img)
		_fixtures(id, img)
		img = preload("res://scripts/town/hall_fixtures_art.gd").paint(id, img)
	return img


## Drawn last, over Codex's finished room layer (Preston, 2026-10-11): doors and the hatch in the side walls
## seen from above, edge-on; tall cases standing against the back wall, front to the viewer; the stairs
## down as a dark opening. Codex's own cases are reused, shortened to stand in front of the wall.
static func _fixtures(id: String, img: Image) -> void:
	var w := img.get_width() / T
	match id:
		"hall":
			_stairs(img, Rect2i(14 * T, 10 * T, 2 * T, 2 * T), true)
		"hall_low":
			_stairs(img, Rect2i(25 * T, 13 * T, 2 * T, 2 * T), false)
			_side_door(img, 0, 5, 2, true)
			_side_door(img, w - 1, 5, 2, false)
			_side_hatch(img, 0, 8, 2)
			_cabinet(img, "supply", 27 * T + 2, 2)
		"chamber":
			_cabinet(img, "keepsakes", T + 2, 2)
			_cabinet(img, "ledgers", 15 * T + 2, 2)
		"runners":
			_side_door(img, 0, 5, 2, true)
			for k in 2:   # coat pegs on the east wall, seen from above
				_block(img, Rect2i((w - 1) * T - 4, 4 * T + 6 + k * 22, 7, 4), Color("#6b4a2e"), 0.2)


## One of Codex's upright cases (assets/sprites/world/hall_floors_2026_10_11/), its top two shelves and its
## base, standing on floor row `row` with its back to the back wall.
static func _cabinet(img: Image, name: String, x: int, row: int) -> void:
	var path := "res://assets/sprites/world/hall_floors_2026_10_11/%s.png" % name
	if not FileAccess.file_exists(path):
		_upright(img, x, T - 4, row, "books" if name == "ledgers" else ("keepsakes" if name == "keepsakes" else "supplies"))
		return
	var src := Image.load_from_file(ProjectSettings.globalize_path(path))
	src.convert(Image.FORMAT_RGBA8)
	var top_part := 56
	var base := 6
	var case := Image.create(src.get_width(), top_part + base, false, Image.FORMAT_RGBA8)
	case.blit_rect(src, Rect2i(0, 0, src.get_width(), top_part), Vector2i.ZERO)
	case.blit_rect(src, Rect2i(0, src.get_height() - base, src.get_width(), base), Vector2i(0, top_part))
	case = preload("res://scripts/art/selout.gd").selout(case)
	var bottom := (row + 1) * T - 2
	_shadow(img, Rect2i(x + 2, bottom, case.get_width(), 4), 0.35)
	img.blend_rect(case, Rect2i(Vector2i.ZERO, case.get_size()), Vector2i(x, bottom - case.get_height()))


# ---------------------------------------------------------------- helpers

## A block with an ink outline, lit top-left and shaded bottom-right.
static func _block(img: Image, rect: Rect2i, c: Color, light := 0.12, shade := 0.22) -> void:
	img.fill_rect(rect, INK)
	var inner := rect.grow(-1)
	if inner.size.x <= 0 or inner.size.y <= 0:
		return
	img.fill_rect(inner, c)
	img.fill_rect(Rect2i(inner.position, Vector2i(inner.size.x, 1)), c.lightened(light))
	img.fill_rect(Rect2i(inner.position, Vector2i(1, inner.size.y)), c.lightened(light * 0.7))
	img.fill_rect(Rect2i(inner.position.x, inner.end.y - 1, inner.size.x, 1), c.darkened(shade))
	img.fill_rect(Rect2i(inner.end.x - 1, inner.position.y, 1, inner.size.y), c.darkened(shade * 0.8))


static func _shadow(img: Image, rect: Rect2i, k := 0.3) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
				img.set_pixel(x, y, img.get_pixel(x, y).darkened(k))


static func _glow(img: Image, at: Vector2, radius: float, col: Color, strength: float) -> void:
	for y in range(int(at.y - radius), int(at.y + radius)):
		for x in range(int(at.x - radius), int(at.x + radius)):
			if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
				continue
			var d := Vector2(x, y).distance_to(at) / radius
			if d < 1.0:
				var k := strength * floorf((1.0 - d) * 4.0) / 4.0   # stepped, like pixel art
				img.set_pixel(x, y, img.get_pixel(x, y).lerp(col, k))


static func _walls(img: Image, r: Dictionary, top: Color, rim: Color) -> void:
	var w: int = r["w"]
	var h: int = r["h"]
	for y in h * T:
		for x in w * T:
			var tx := x / T
			var ty := y / T
			var wall := tx == 0 or tx == w - 1 or ty == h - 1
			if not wall:
				continue
			var c := top.lightened((R._noise(x, y, 9.0, 130) - 0.5) * 0.1)
			img.set_pixel(x, y, c)
	# A lit rim where the walls meet the floor.
	for y in range(2 * T, (h - 1) * T):
		img.set_pixel(T - 1, y, rim)
		img.set_pixel((w - 1) * T, y, rim)
	for x in range(T, (w - 1) * T):
		img.set_pixel(x, (h - 1) * T, rim)


static func _door(img: Image, r: Dictionary, frame: Color) -> void:
	var d: Vector2i = r["door"]
	var x0 := d.x * T
	var y0 := d.y * T
	img.fill_rect(Rect2i(x0 - 3, y0, T + 6, T), INK)
	img.fill_rect(Rect2i(x0 - 2, y0, 2, T), frame)
	img.fill_rect(Rect2i(x0 + T, y0, 2, T), frame)
	for y in T:   # daylight through the open door, brightest at the sill
		img.fill_rect(Rect2i(x0, y0 + y, T, 1), Color("#e8d9a8").lerp(Color("#7a8a58"), float(y) / T))
	img.fill_rect(Rect2i(x0 - 2, y0, T + 4, 2), frame.lightened(0.15))   # the sill


# ---------------------------------------------------------------- home

const PLANK := [Color("#8a6038"), Color("#946a40"), Color("#7e5632")]
const BARK := Color("#3d2b1e")
const ROOT := [Color("#6b4a2e"), Color("#7a5636"), Color("#5a3d25")]


static func _home(img: Image, r: Dictionary) -> void:
	var w: int = r["w"]
	var h: int = r["h"]
	# The floor: warm planks, board seams, knots and nails.
	for y in range(2 * T, (h - 1) * T):
		for x in range(T, (w - 1) * T):
			var board := y / 6
			var off := int(R._h(board, 0, 131) * 30)
			var c: Color = PLANK[int(R._h((x + off) / 40, board, 132) * PLANK.size())]
			if y % 6 == 0:
				c = c.darkened(0.35)
			elif (x + off) % 40 == 0:
				c = c.darkened(0.3)
			elif R._h(x, y, 133) > 0.97:
				c = c.darkened(0.18)
			elif y % 6 == 1:
				c = c.lightened(0.06)
			img.set_pixel(x, y, c)
	# The back wall: root timbers standing side by side, moss in the joints, a round window.
	for y in range(0, 2 * T):
		for x in range(0, w * T):
			var log := x / 7
			var c: Color = ROOT[int(R._h(log, 0, 134) * ROOT.size())]
			var lx := x % 7
			if lx == 0:
				c = BARK
			elif lx == 1:
				c = c.lightened(0.1)
			elif lx == 6:
				c = c.darkened(0.2)
			if y < 4:
				c = BARK.lightened(0.05)   # the beam along the top
			elif y > 2 * T - 4:
				c = c.darkened(0.3)        # where the wall meets the floor
			if lx == 0 and R._h(log, y / 4, 135) > 0.7 and y > 8:
				c = Color("#5f7d3c")       # moss in a joint
			img.set_pixel(x, y, c)
	var win := Vector2(w * T * 0.5, 22)
	for y in range(int(win.y - 13), int(win.y + 13)):
		for x in range(int(win.x - 13), int(win.x + 13)):
			var d := Vector2(x, y).distance_to(win)
			if d < 13:
				var c := Color("#f3e6b4") if d < 10 else (INK if d >= 12 else Color("#8a6440"))
				if d < 10 and (absf(x - win.x) < 1 or absf(y - win.y) < 1):
					c = Color("#8a6440")   # the window's cross
				img.set_pixel(x, y, c)
	_walls(img, r, BARK, Color("#7a5636"))
	# The rug in the middle of the room: an oval of woven stripes.
	var rug := Vector2(7 * T, 7 * T)
	for y in range(int(rug.y - 22), int(rug.y + 22)):
		for x in range(int(rug.x - 46), int(rug.x + 46)):
			var e := pow((x - rug.x) / 46.0, 2) + pow((y - rug.y) / 22.0, 2)
			if e < 1.0:
				var ring := int(e * 5.0)
				var c: Color = [Color("#a8452f"), Color("#d4a04a"), Color("#a8452f"), Color("#6e7a3c"), Color("#d4a04a")][ring]
				if e > 0.92:
					c = INK
				img.set_pixel(x, y, c)
	# Light from the window falling across the floor.
	for y in range(2 * T, 6 * T):
		var spread := (y - 2 * T) * 0.4
		for x in range(int(win.x - 14 - spread), int(win.x + 14 + spread)):
			img.set_pixel(x, y, img.get_pixel(x, y).lerp(Color("#fff2c4"), 0.12))
	# The moss bed: a wooden frame, a mossy mattress, a folded cream blanket and a pillow.
	_shadow(img, Rect2i(1 * T + 2, 4 * T - 2, 3 * T, 4), 0.35)
	_block(img, Rect2i(1 * T, 2 * T, 3 * T, 2 * T - 2), Color("#7a5636"))
	_block(img, Rect2i(1 * T + 3, 2 * T + 3, 3 * T - 6, 2 * T - 9), Color("#5f7d3c"), 0.18)
	_block(img, Rect2i(1 * T + 3, 2 * T + 22, 3 * T - 6, 14), Color("#e9dcb8"), 0.08)
	_block(img, Rect2i(1 * T + 6, 2 * T + 5, 16, 10), Color("#f2e8cc"), 0.06)
	# The hearth against the back wall: a stone arch, the fire, a kettle.
	var hx := 9 * T
	var hy := 2 * T - 30
	for k in 8:
		_block(img, Rect2i(hx + k * 12, hy + (0 if k in [0, 7] else 2), 12, 12), Color("#8a8574"))
	_block(img, Rect2i(hx, hy + 10, 4 * T, 30), Color("#7d7a6c"))
	img.fill_rect(Rect2i(hx + 18, hy + 14, 60, 22), Color("#1a1210"))
	for y in range(hy + 22, hy + 36):
		for x in range(hx + 22, hx + 74):
			if R._h(x / 3, y / 3, 136) > 0.35 + (hy + 36 - y) * 0.03:
				img.set_pixel(x, y, [Color("#f2c14e"), Color("#e8732a"), Color("#ffdf8a")][int(R._h(x, y, 137) * 3)])
	_block(img, Rect2i(hx + 40, hy + 12, 16, 12), Color("#4a4f52"))
	_glow(img, Vector2(hx + 48, hy + 40), 46, Color("#ffb45a"), 0.35)
	# The table with its lantern and a map.
	_shadow(img, Rect2i(6 * T + 3, 6 * T - 2, 3 * T, 5), 0.35)
	_block(img, Rect2i(6 * T, 4 * T + 4, 3 * T, 2 * T - 6), Color("#9a7044"))
	_block(img, Rect2i(6 * T + 8, 4 * T + 10, 30, 20), Color("#e8dcb8"), 0.05)
	img.fill_rect(Rect2i(6 * T + 14, 4 * T + 16, 18, 1), Color("#5a7a9a"))   # the river on the map
	_block(img, Rect2i(7 * T + 20, 4 * T + 8, 12, 16), Color("#c9a640"))
	img.fill_rect(Rect2i(7 * T + 23, 4 * T + 12, 6, 7), Color("#fff2a6"))
	_glow(img, Vector2(7 * T + 26, 4 * T + 16), 34, Color("#ffe08a"), 0.3)
	# The shelf: three boards of jars and scrolls.
	_block(img, Rect2i(1 * T, 7 * T, 2 * T, 2 * T - 2), Color("#6b4a2e"))
	for k in 3:
		var sy := 7 * T + 3 + k * 14
		img.fill_rect(Rect2i(1 * T + 2, sy + 11, 2 * T - 4, 2), Color("#3d2b1e"))
		for j in 4:
			var jc: Color = [Color("#c84a5a"), Color("#e8dcb8"), Color("#7fb06a"), Color("#c84a5a")][(j + k) % 4]
			_block(img, Rect2i(1 * T + 4 + j * 10, sy + 2, 8, 9), jc, 0.15)
	# The planters: clover and a fern.
	for k in 2:
		var px := 11 * T + k * T
		_block(img, Rect2i(px + 2, 7 * T + 4, T - 4, T - 6), Color("#8a6440"))
		for j in 70:
			var lx := px + 3 + int(R._h(j, k, 138) * (T - 6))
			var ly := 6 * T + 6 + int(R._h(k, j, 139) * 22)
			img.set_pixel(lx, ly, [Color("#5f7d3c"), Color("#86b25a"), Color("#4a6532")][j % 3])
			img.set_pixel(lx, ly + 1, Color("#3e5a2c"))
	_door(img, r, Color("#8a6440"))


# ---------------------------------------------------------------- hall

const FLAG := [Color("#a39f8f"), Color("#ada896"), Color("#98947f")]
const STONE := Color("#5a5f5c")
const TEAL := Color("#2f6b6e")
const BRASS := Color("#c9a64a")


static func _hall(img: Image, r: Dictionary) -> void:
	var w: int = r["w"]
	var h: int = r["h"]
	# The floor: big clean flagstones in running rows.
	for y in range(2 * T, (h - 1) * T):
		for x in range(T, (w - 1) * T):
			var row := y / 16
			var off := 12 if row % 2 == 1 else 0
			var c: Color = FLAG[int(R._h((x + off) / 24, row, 140) * FLAG.size())]
			if y % 16 == 0 or (x + off) % 24 == 0:
				c = c.darkened(0.3)
			elif y % 16 == 1 or (x + off) % 24 == 1:
				c = c.lightened(0.07)
			elif R._h(x, y, 141) > 0.96:
				c = c.darkened(0.08)
			img.set_pixel(x, y, c)
	# The back wall: stone blocks over a wooden wainscot, a beam along the top.
	for y in range(0, 2 * T):
		for x in range(0, w * T):
			var c: Color
			if y < 5:
				c = Color("#3d2b1e")
			elif y > 2 * T - 14:
				c = Color("#7a5636") if x % 10 != 0 else Color("#4a3220")   # the wainscot panels
				if y == 2 * T - 14:
					c = Color("#9a7044")
			else:
				var row := (y - 5) / 9
				var off := 8 if row % 2 == 1 else 0
				c = STONE.lightened((R._h((x + off) / 16, row, 142) - 0.5) * 0.12)
				if (y - 5) % 9 == 0 or (x + off) % 16 == 0:
					c = STONE.darkened(0.35)
			img.set_pixel(x, y, c)
	# Banners of the Wayline between the boards: teal cloth, a brass mark, a pointed foot.
	for bx in [5 * T + 6, 16 * T + 6]:
		_block(img, Rect2i(bx, 6, 16, 32), TEAL, 0.15)
		for k in 4:
			img.set_pixel(bx + 8 - k, 38 + k, INK)
			img.set_pixel(bx + 8 + k, 38 + k, INK)
		img.fill_rect(Rect2i(bx + 5, 14, 6, 6), BRASS)
		img.fill_rect(Rect2i(bx + 7, 12, 2, 10), BRASS)
	_walls(img, r, Color("#2c2a27"), Color("#8a8574"))
	# The runner from the door to the counter.
	for y in range(4 * T, (h - 1) * T):
		for x in range(9 * T + 8, 13 * T - 8):
			var c := TEAL
			if x < 9 * T + 11 or x > 13 * T - 12:
				c = BRASS if x in [9 * T + 9, 13 * T - 10] else INK
			elif (y / 6) % 4 == 0:
				c = TEAL.lightened(0.08)
			img.set_pixel(x, y, c)
	# The dispatch counter: a long desk, parcels, a ledger, a bell.
	_shadow(img, Rect2i(7 * T + 2, 4 * T, 8 * T, 5), 0.35)
	_block(img, Rect2i(7 * T, 3 * T - 4, 8 * T, T + 4), Color("#8a6038"))
	_block(img, Rect2i(7 * T, 3 * T - 4, 8 * T, 8), Color("#a87a48"), 0.15)
	for k in 3:
		_block(img, Rect2i(7 * T + 8 + k * 14, 3 * T - 18, 12, 12 - k * 2), Color("#b08a5a"), 0.15)
		img.fill_rect(Rect2i(7 * T + 13 + k * 14, 3 * T - 18, 2, 12 - k * 2), Color("#6b4a2e"))   # string
	_block(img, Rect2i(11 * T, 3 * T - 14, 20, 12), Color("#e8dcb8"), 0.05)
	_block(img, Rect2i(13 * T + 6, 3 * T - 12, 10, 8), BRASS, 0.2)
	# The notice wall: a cork board of papers.
	_block(img, Rect2i(2 * T - 4, 10, 2 * T + 8, 30), Color("#a07a4a"))
	for k in 6:
		_block(img, Rect2i(2 * T + (k % 3) * 15, 14 + (k / 3) * 12, 12, 10), [Color("#f2e8cc"), Color("#e8dcb8"), Color("#f6d8c8")][k % 3], 0.04)
	# The roster board: rows of brass name plates.
	_block(img, Rect2i(18 * T - 4, 8, 2 * T + 8, 32), Color("#4a3220"))
	for k in 5:
		img.fill_rect(Rect2i(18 * T + 2, 13 + k * 5, 2 * T - 4 - (k % 3) * 6, 3), BRASS.darkened(0.1 * (k % 2)))
	# Pillars, each with its shadow on the floor.
	for p in [Vector2i(3, 6), Vector2i(18, 6), Vector2i(3, 10), Vector2i(18, 10)]:
		_shadow(img, Rect2i(p.x * T + 6, p.y * T + T - 2, T, 6), 0.35)
		_block(img, Rect2i(p.x * T + 3, p.y * T - 20, T - 6, T + 18), Color("#8a8574"), 0.14)
		_block(img, Rect2i(p.x * T + 1, p.y * T - 22, T - 2, 6), Color("#a39f8f"))
		_block(img, Rect2i(p.x * T + 1, p.y * T + T - 4, T - 2, 4), Color("#6f6b5c"))
	# Benches along the side walls.
	for bx in [1 * T + 2, 20 * T + 2]:
		_shadow(img, Rect2i(bx + 4, 8 * T + 4, T - 4, 3 * T), 0.3)
		_block(img, Rect2i(bx, 8 * T, T - 4, 3 * T - 2), Color("#8a6038"))
		for k in 3:
			img.fill_rect(Rect2i(bx + 2, 8 * T + 8 + k * 24, T - 8, 1), Color("#5a3d25"))
	# Two tables either side of the runner: a chart of the river, a stack of reports.
	for t in [[5, Color("#e8dcb8")], [15, Color("#f2e8cc")]]:
		var tx: int = t[0]
		_shadow(img, Rect2i(tx * T + 3, 9 * T - 2, 2 * T, 5), 0.35)
		_block(img, Rect2i(tx * T, 7 * T + 4, 2 * T, 2 * T - 6), Color("#8a6038"))
		_block(img, Rect2i(tx * T + 5, 7 * T + 9, 2 * T - 10, 2 * T - 18), t[1], 0.05)
	for k in 6:   # the chart's river and its pins
		img.set_pixel(5 * T + 9 + k * 6, 7 * T + 18 + (k % 2) * 3, Color("#5a7a9a"))
		img.set_pixel(5 * T + 10 + k * 6, 7 * T + 18 + (k % 2) * 3, Color("#5a7a9a"))
	for k in 3:
		img.fill_rect(Rect2i(5 * T + 14 + k * 9, 7 * T + 14 + k * 3, 2, 2), Color("#d8342c"))
	for k in 3:   # the report stack
		_block(img, Rect2i(15 * T + 10 + k * 3, 7 * T + 12 - k * 2, 18, 12), Color("#f2e8cc"), 0.04)
	img.fill_rect(Rect2i(15 * T + 18, 7 * T + 10, 6, 2), Color("#d8342c"))
	# Parcels stacked in the lower corners, tied with string.
	for c in [Vector2i(2, 12), Vector2i(18, 12)]:
		for k in 4:
			var bx: int = c.x * T + (k % 2) * 22 + 2
			var by: int = c.y * T + 4 - (k / 2) * 12
			_block(img, Rect2i(bx, by, 20, 14), Color("#b08a5a"), 0.15)
			img.fill_rect(Rect2i(bx + 9, by + 1, 2, 12), Color("#6b4a2e"))
	# Potted ferns beside the upper pillars.
	for c in [Vector2i(4, 6), Vector2i(17, 6)]:
		_block(img, Rect2i(c.x * T + 5, c.y * T + 10, 14, 12), Color("#8a6440"))
		for j in 26:
			var lx: int = c.x * T + 4 + int(R._h(j, c.x, 143) * 16)
			var ly: int = c.y * T - 4 + int(R._h(c.x, j, 144) * 16)
			img.set_pixel(lx, ly, [Color("#5f7d3c"), Color("#86b25a"), Color("#4a6532")][j % 3])
			img.set_pixel(lx, ly + 1, Color("#4a6532"))
	# Lanterns on the wall, glowing.
	for lx in [8 * T, 14 * T]:
		_block(img, Rect2i(lx - 5, 12, 10, 14), BRASS)
		img.fill_rect(Rect2i(lx - 2, 15, 4, 7), Color("#fff2a6"))
		_glow(img, Vector2(lx, 20), 40, Color("#ffd27a"), 0.25)
	_door(img, r, Color("#7a5636"))


# ---------------------------------------------------------------- the Hall's lower floor and chamber
# (Claude, 2026-10-10; Preston: two floors, like the guild in Sky. Painted in code until Codex's art.)

## A stairwell seen from above (redrawn 2026-10-11; Preston: the old one read as a grey wall blocking the
## way). Down: an opening in the floor, the top step at floor level and each step below it darker until
## they vanish into black, low stone sides either side. Up: the steps climb away toward the light of
## the floor above.
static func _stairs(img: Image, rect: Rect2i, down: bool) -> void:
	_shadow(img, Rect2i(rect.position.x - 2, rect.position.y - 2, rect.size.x + 4, rect.size.y + 4), 0.25)
	img.fill_rect(rect, INK)
	var side := 5
	var well := Rect2i(rect.position.x + side, rect.position.y + 2, rect.size.x - side * 2, rect.size.y - 2)
	var far := well.size.y * 2 / 5 if down else well.size.y / 3   # the stone face the stairs run to
	var n := 4 if down else 5
	var hstep := (well.size.y - far) / n
	for k in n:
		var near := float(k + 1) / n        # the last band is the nearest step
		var lit := 0.25 + 0.75 * pow(near, 1.6) if down else 0.95 - 0.5 * near   # up: brighter toward the top
		var c := Color("#9a968a").lerp(Color("#0b0907"), 1.0 - lit)
		var y := well.position.y + far + k * hstep
		if down:
			img.fill_rect(Rect2i(well.position.x, y, well.size.x, hstep), c)
			img.fill_rect(Rect2i(well.position.x, y, well.size.x, 1), c.lightened(0.25))   # the step's lit nose
			img.fill_rect(Rect2i(well.position.x, y + hstep - 1, well.size.x, 1), c.darkened(0.45))
		else:
			# Climbing: each step shows its tread (lit from above) over its riser (the face toward you).
			var tread := hstep * 3 / 5
			img.fill_rect(Rect2i(well.position.x, y, well.size.x, tread), c.lightened(0.12))
			img.fill_rect(Rect2i(well.position.x, y + tread, well.size.x, hstep - tread), c.darkened(0.35))
			img.fill_rect(Rect2i(well.position.x, y, well.size.x, 1), c.lightened(0.35))
	# The wall the stairs run to, and the arched way through it from its middle up (Preston, 2026-10-11:
	# the stairs should look like they lead to an entrance). Down it is dark; up it is lit.
	if far > 0:
		var face := Rect2i(well.position.x, well.position.y, well.size.x, far)
		for y in range(face.position.y, face.end.y):
			for x in range(face.position.x, face.end.x):
				var c := Color("#4a473e").darkened(0.15 + 0.35 * float(face.end.y - y) / far) if down else Color("#8a8574").darkened(0.1 * float(face.end.y - y) / far)
				if (y - face.position.y) % 6 == 0 or (x + ((y - face.position.y) / 6) * 5) % 10 == 0:
					c = c.darkened(0.3)   # the stone courses
				img.set_pixel(x, y, c)
		var aw := int(well.size.x * 0.55)
		var ax := well.position.x + (well.size.x - aw) / 2
		var ah := far + 2
		for y in range(ah):
			for x in range(aw):
				var dx := (x + 0.5 - aw * 0.5) / (aw * 0.5)
				var top := (1.0 - sqrt(maxf(0.0, 1.0 - dx * dx))) * aw * 0.5   # a round arch
				if y >= top:
					# Down: a dark way on. Up: the floor above, lit, brightest at the top of the stairs.
					img.set_pixel(ax + x, face.end.y - ah + y, Color("#050403") if down else Color("#fff2c8").lerp(Color("#d8b878"), float(y) / ah))
		for x in range(aw):   # its lit rim
			var dx := (x + 0.5 - aw * 0.5) / (aw * 0.5)
			var top := int((1.0 - sqrt(maxf(0.0, 1.0 - dx * dx))) * aw * 0.5)
			var yy := face.end.y - ah + top - 1
			if yy >= face.position.y:
				img.set_pixel(ax + x, yy, Color("#7d7a6c"))
	if not down:   # light spilling down the steps from the floor above
		_glow(img, Vector2(well.get_center().x, well.position.y + far), 22, Color("#ffe8b0"), 0.35)
	for sx in [rect.position.x, rect.end.x - side]:   # the low stone sides
		_block(img, Rect2i(sx, rect.position.y - 3, side, rect.size.y + 3), Color("#6f6b5c"), 0.18)
	_block(img, Rect2i(rect.position.x, rect.end.y - 3, rect.size.x, 4), Color("#8a8574"), 0.15)   # the near lip


static func _flags(img: Image, r: Dictionary, tint: float) -> void:
	for y in range(2 * T, (r["h"] - 1) * T):
		for x in range(T, (r["w"] - 1) * T):
			var row := y / 16
			var off := 12 if row % 2 == 1 else 0
			var c: Color = FLAG[int(R._h((x + off) / 24, row, 150) * FLAG.size())].darkened(tint)
			if y % 16 == 0 or (x + off) % 24 == 0:
				c = c.darkened(0.3)
			elif y % 16 == 1 or (x + off) % 24 == 1:
				c = c.lightened(0.07)
			elif R._h(x, y, 151) > 0.96:
				c = c.darkened(0.08)
			img.set_pixel(x, y, c)


## The back wall: stone blocks over a wooden wainscot, a beam along the top (as in the Hall).
static func _back_wall(img: Image, w: int) -> void:
	for y in range(0, 2 * T):
		for x in range(0, w * T):
			var c: Color
			if y < 5:
				c = BARK
			elif y > 2 * T - 14:
				c = Color("#7a5636") if x % 10 != 0 else Color("#4a3220")
				if y == 2 * T - 14:
					c = Color("#9a7044")
			else:
				var row := (y - 5) / 9
				var off := 8 if row % 2 == 1 else 0
				c = STONE.lightened((R._h((x + off) / 16, row, 152) - 0.5) * 0.12)
				if (y - 5) % 9 == 0 or (x + off) % 16 == 0:
					c = STONE.darkened(0.35)
			img.set_pixel(x, y, c)


static func _banner(img: Image, bx: int) -> void:
	_block(img, Rect2i(bx, 6, 16, 32), TEAL, 0.15)
	for k in 4:
		img.set_pixel(bx + 8 - k, 38 + k, INK)
		img.set_pixel(bx + 8 + k, 38 + k, INK)
	img.fill_rect(Rect2i(bx + 5, 14, 6, 6), BRASS)
	img.fill_rect(Rect2i(bx + 7, 12, 2, 10), BRASS)


static func _window(img: Image, rect: Rect2i) -> void:
	_block(img, rect, Color("#6b4a2e"), 0.15)
	var g := rect.grow(-3)
	for y in g.size.y:
		img.fill_rect(Rect2i(g.position.x, g.position.y + y, g.size.x, 1), Color("#b4d2da").lerp(Color("#5f879a"), float(y) / g.size.y))
	for k in g.size.x / 5:   # rain on the glass
		var rx: int = g.position.x + 2 + k * 5
		var ry: int = g.position.y + int(R._h(k, rect.position.x, 153) * (g.size.y - 6))
		img.fill_rect(Rect2i(rx, ry, 1, 4), Color("#e4f0f2"))
	img.fill_rect(Rect2i(g.position.x + g.size.x / 2 - 1, g.position.y, 2, g.size.y), Color("#4a3220"))   # mullions
	img.fill_rect(Rect2i(g.position.x, g.position.y + g.size.y / 2 - 1, g.size.x, 2), Color("#4a3220"))


static func _pillar(img: Image, p: Vector2i) -> void:
	_shadow(img, Rect2i(p.x * T + 6, p.y * T + T - 2, T, 6), 0.35)
	_block(img, Rect2i(p.x * T + 3, p.y * T - 20, T - 6, T + 18), Color("#8a8574"), 0.14)
	_block(img, Rect2i(p.x * T + 1, p.y * T - 22, T - 2, 6), Color("#a39f8f"))
	_block(img, Rect2i(p.x * T + 1, p.y * T + T - 4, T - 2, 4), Color("#6f6b5c"))


static func _fern(img: Image, c: Vector2i) -> void:
	_block(img, Rect2i(c.x * T + 5, c.y * T + 10, 14, 12), Color("#8a6440"))
	for j in 26:
		var lx: int = c.x * T + 4 + int(R._h(j, c.x, 154) * 16)
		var ly: int = c.y * T - 4 + int(R._h(c.x, j, 155) * 16)
		img.set_pixel(lx, ly, [Color("#5f7d3c"), Color("#86b25a"), Color("#4a6532")][j % 3])
		img.set_pixel(lx, ly + 1, Color("#4a6532"))


static func _lantern(img: Image, lx: int) -> void:
	_block(img, Rect2i(lx - 5, 12, 10, 14), BRASS)
	img.fill_rect(Rect2i(lx - 2, 15, 4, 7), Color("#fff2a6"))
	_glow(img, Vector2(lx, 20), 40, Color("#ffd27a"), 0.25)


## The lower floor: the chamber door at the back, the roll-call floor in the middle, crew doors in the side
## walls, the mess table and kitchen hatch to the west, the stairs up in the south-east corner.
static func _lower(img: Image, r: Dictionary) -> void:
	var w: int = r["w"]
	_flags(img, r, 0.06)
	_back_wall(img, w)
	_walls(img, r, Color("#2c2a27"), Color("#8a8574"))
	# The roll-call floor: the Wayline's mark set in brass, an oval of teal stone.
	var cx := 15 * T
	var cy := 9 * T
	for y in range(cy - 46, cy + 47):
		for x in range(cx - 76, cx + 77):
			var d := pow((x - cx) / 74.0, 2) + pow((y - cy) / 44.0, 2)
			if d > 1.0:
				continue
			var c := TEAL.darkened(0.1).lightened((R._h(x / 6, y / 6, 156) - 0.5) * 0.08)
			if d > 0.93:
				c = INK
			elif d > 0.8:
				c = BRASS if d < 0.88 else BRASS.darkened(0.3)
			elif absf(d - 0.36) < 0.035:
				c = BRASS.darkened(0.15)
			img.set_pixel(x, y, c)
	for k in range(-20, 21):   # the four-point mark at its heart
		var t := 1 + (20 - absi(k)) / 7
		img.fill_rect(Rect2i(cx + k, cy - t / 2, 1, t), BRASS)
		img.fill_rect(Rect2i(cx - t, cy + int(k * 0.6) , t * 2, 1), BRASS)
	img.fill_rect(Rect2i(cx - 2, cy - 2, 4, 4), Color("#fff2a6"))
	# A runner from the chamber door to the mark.
	for y in range(2 * T, cy - 40):
		for x in range(14 * T + 6, 16 * T - 6):
			var c := TEAL
			if x < 14 * T + 9 or x > 16 * T - 10:
				c = BRASS if x in [14 * T + 7, 16 * T - 8] else INK
			elif (y / 6) % 4 == 0:
				c = TEAL.lightened(0.08)
			img.set_pixel(x, y, c)
	# The chamber door: tall double doors with a brass star, banners and ferns either side.
	_block(img, Rect2i(14 * T - 4, 4, 2 * T + 8, 2 * T - 4), Color("#5a3d25"), 0.12)
	img.fill_rect(Rect2i(15 * T - 1, 8, 2, 2 * T - 10), INK)
	for k in 6:
		img.fill_rect(Rect2i(14 * T + 2, 12 + k * 6, 2 * T - 4, 1), Color("#4a3220"))
	_block(img, Rect2i(14 * T - 6, 2, 2 * T + 12, 6), BRASS, 0.2)   # the lintel
	img.fill_rect(Rect2i(15 * T - 4, 22, 8, 8), BRASS)
	img.fill_rect(Rect2i(15 * T - 1, 18, 2, 16), BRASS)
	img.fill_rect(Rect2i(15 * T - 8, 25, 16, 2), BRASS)
	img.fill_rect(Rect2i(15 * T - 6, 34, 3, 3), BRASS.darkened(0.2))   # handles
	img.fill_rect(Rect2i(15 * T + 3, 34, 3, 3), BRASS.darkened(0.2))
	_banner(img, 11 * T + 4)
	_banner(img, 18 * T + 4)
	_fern(img, Vector2i(12, 2))
	_fern(img, Vector2i(17, 2))
	_lantern(img, 7 * T)
	_lantern(img, 23 * T)   # mirrors 7 * T across the centre line
	# The duty board and the river windows.
	_block(img, Rect2i(9 * T - 2, 10, 2 * T + 4, 28), Color("#a07a4a"))
	for k in 3:
		_block(img, Rect2i(9 * T + 4 + k * 14, 15 + (k % 2) * 4, 12, 14), [Color("#f2e8cc"), Color("#e8dcb8"), Color("#f6d8c8")][k], 0.04)
	_window(img, Rect2i(3 * T + 2, 8, 2 * T - 4, 32))
	_window(img, Rect2i(25 * T + 2, 8, 2 * T - 4, 32))
	# Pillars round the roll-call floor.
	for p in [Vector2i(9, 5), Vector2i(20, 5), Vector2i(9, 12), Vector2i(20, 12)]:
		_pillar(img, p)
	# Doors in the side walls: the crew room (west) and the runners' room (east), seen from above.
	_side_door(img, 0, 5, 2, true)
	_side_door(img, w - 1, 5, 2, false)
	# The kitchen hatch in the west wall, warm light spilling out.
	_side_hatch(img, 0, 8, 2)
	# The mess hall: a long table with benches and bowls.
	_shadow(img, Rect2i(3 * T + 4, 14 * T - 2, 6 * T, 5), 0.35)
	_block(img, Rect2i(3 * T, 12 * T - 2, 6 * T, 6), Color("#7e5632"))           # far bench
	_block(img, Rect2i(3 * T, 12 * T + 6, 6 * T, T + 4), Color("#8a6038"))      # the table
	_block(img, Rect2i(3 * T, 12 * T + 6, 6 * T, 6), Color("#a87a48"), 0.15)
	_block(img, Rect2i(3 * T, 13 * T + 14, 6 * T, 6), Color("#7e5632"))          # near bench
	for k in 6:
		var bx := 3 * T + 10 + k * 22
		_block(img, Rect2i(bx, 12 * T + 14, 12, 8), Color("#d8cfb8"), 0.1)
		img.fill_rect(Rect2i(bx + 2, 12 * T + 16, 8, 3), [Color("#6f8f4a"), Color("#b0703a")][k % 2])
	# The supply shelf, standing against the back wall.
	_upright(img, 27 * T + 2, T - 4, 2, "supplies")
	# The stairs up to the work floor.
	_stairs(img, Rect2i(25 * T, 13 * T, 2 * T, 2 * T), false)


## Starward's chamber: a plank floor and a wide rug, the whole river on the wall, a window, keepsakes
## and ledgers either side, the Guildmaster's cushion, the door back down at the south.
static func _chamber(img: Image, r: Dictionary) -> void:
	var w: int = r["w"]
	var h: int = r["h"]
	for y in range(2 * T, (h - 1) * T):
		for x in range(T, (w - 1) * T):
			var row := y / 12
			var off := (row * 37) % 48
			var c: Color = PLANK[int(R._h((x + off) / 48, row, 157) * PLANK.size())]
			if y % 12 == 0:
				c = c.darkened(0.35)
			elif (x + off) % 48 == 0:
				c = c.darkened(0.25)
			elif y % 12 == 1:
				c = c.lightened(0.06)
			img.set_pixel(x, y, c)
	_back_wall(img, w)
	_walls(img, r, Color("#2c2a27"), Color("#8a8574"))
	# The rug, teal with a brass border and the Wayline's mark.
	_shadow(img, Rect2i(4 * T + 3, 3 * T + 3, 9 * T, 5 * T), 0.2)
	_block(img, Rect2i(4 * T, 3 * T, 9 * T, 5 * T), TEAL, 0.1)
	var b := Rect2i(4 * T + 5, 3 * T + 5, 9 * T - 10, 5 * T - 10)
	for e in [Rect2i(b.position, Vector2i(b.size.x, 2)), Rect2i(b.position.x, b.end.y - 2, b.size.x, 2),
			Rect2i(b.position, Vector2i(2, b.size.y)), Rect2i(b.end.x - 2, b.position.y, 2, b.size.y)]:
		img.fill_rect(e, BRASS)
	var c0 := Vector2i(8 * T + 12, 6 * T + 6)   # the middle of tile 8, the room's centre line
	for k in range(-14, 15):
		var t := 1 + (14 - absi(k)) / 5
		img.fill_rect(Rect2i(c0.x + k, c0.y - t / 2, 1, t), BRASS)
		img.fill_rect(Rect2i(c0.x - t / 2, c0.y + k, t, 1), BRASS)
	# The Guildmaster's dais: a low platform at the head of the rug, the cushion on it.
	_shadow(img, Rect2i(7 * T + 4, 5 * T - 2, 3 * T, 6), 0.4)
	_block(img, Rect2i(7 * T, 3 * T - 6, 3 * T, 2 * T + 4), Color("#6b4a2e"), 0.1)
	_block(img, Rect2i(7 * T, 3 * T - 6, 3 * T, 2 * T - 6), Color("#8a6038"), 0.14)   # its top
	img.fill_rect(Rect2i(7 * T + 2, 5 * T - 10, 3 * T - 4, 2), BRASS)                   # the brass edge
	for y in range(-9, 10):
		for x in range(-18, 19):
			var d := pow(x / 18.0, 2) + pow(y / 9.0, 2)
			if d <= 1.0:
				img.set_pixel(8 * T + 12 + x, 3 * T + 16 + y, INK if d > 0.8 else (Color("#b8483e") if y < 2 else Color("#8e3430")))
	# The whole river on the wall, mostly blank.
	_block(img, Rect2i(3 * T, 8, 4 * T, 32), Color("#e8dcb8"), 0.05)
	for x in range(3 * T + 6, 7 * T - 6):
		var y := 24 + int(sin(x * 0.11) * 5.0 + sin(x * 0.037) * 3.0)
		img.fill_rect(Rect2i(x, y, 1, 2), Color("#5a7a9a"))
	for k in 4:
		img.fill_rect(Rect2i(3 * T + 12 + k * 7, 22 + (k % 2) * 4, 2, 2), Color("#d8342c"))
	_window(img, Rect2i(10 * T, 8, 4 * T, 32))   # mirrors the map across the centre line
	_lantern(img, 2 * T + 12)   # clear of the corner cases, mirrored across the centre line
	_lantern(img, 15 * T - 12)
	# Keepsakes and ledgers, standing in the back corners (Preston, 2026-10-11: tall furniture goes against
	# the back wall, front to the viewer, not lying on its back by a side wall).
	_upright(img, T + 1, T - 2, 2, "keepsakes")
	_upright(img, 15 * T + 1, T - 2, 2, "books")
	# The door back down.
	img.fill_rect(Rect2i(7 * T - 3, (h - 1) * T, 3 * T + 6, T), INK)
	img.fill_rect(Rect2i(7 * T, (h - 1) * T, 3 * T, T), Color("#2a2017"))
	img.fill_rect(Rect2i(7 * T - 3, (h - 1) * T, 3 * T + 6, 2), Color("#9a7044"))


## The runners' room: two moss bunks under the back wall, a window, the first run's map, a chest, coat pegs,
## and the door in the west wall back to the Hall floor.
static func _runners(img: Image, r: Dictionary) -> void:
	var w: int = r["w"]
	var h: int = r["h"]
	for y in range(2 * T, (h - 1) * T):
		for x in range(T, (w - 1) * T):
			var row := y / 12
			var off := (row * 29) % 48
			var c: Color = PLANK[int(R._h((x + off) / 48, row, 158) * PLANK.size())].darkened(0.04)
			if y % 12 == 0:
				c = c.darkened(0.35)
			elif (x + off) % 48 == 0:
				c = c.darkened(0.25)
			elif y % 12 == 1:
				c = c.lightened(0.06)
			img.set_pixel(x, y, c)
	_back_wall(img, w)
	_walls(img, r, Color("#2c2a27"), Color("#8a8574"))
	# A small rug between the bunks.
	_block(img, Rect2i(4 * T + 12, 5 * T, 4 * T, 2 * T), Color("#8e3430"), 0.1)
	img.fill_rect(Rect2i(4 * T + 16, 5 * T + 4, 4 * T - 8, 1), BRASS.darkened(0.2))
	img.fill_rect(Rect2i(4 * T + 16, 7 * T - 5, 4 * T - 8, 1), BRASS.darkened(0.2))
	# Two bunks: a wooden frame, a moss mattress, a wool blanket, a pillow.
	for bx in [3, 8]:
		_shadow(img, Rect2i(bx * T + 4, 4 * T - 2, 2 * T, 5), 0.35)
		_block(img, Rect2i(bx * T, 2 * T - 6, 2 * T, 2 * T + 4), Color("#6b4a2e"), 0.12)
		_block(img, Rect2i(bx * T + 3, 2 * T - 2, 2 * T - 6, 2 * T - 6), Color("#5f7d3c"), 0.12)
		_block(img, Rect2i(bx * T + 3, 2 * T + 14, 2 * T - 6, T - 2), Color("#b8a27a" if bx == 3 else "#7a8aa0"), 0.12)
		_block(img, Rect2i(bx * T + 10, 2 * T, 2 * T - 20, 10), Color("#e8dcb8"), 0.08)
	img.fill_rect(Rect2i(8 * T + 22, 2 * T + 2, 4, 4), Color("#c84a5a"))   # the reedberry on the pillow
	_window(img, Rect2i(6 * T - 6, 8, T + 12, 32))
	# The first run, pinned on the wall.
	_block(img, Rect2i(10 * T, 10, 2 * T, 28), Color("#e8dcb8"), 0.05)
	for x in range(10 * T + 5, 12 * T - 5):
		img.fill_rect(Rect2i(x, 24 + int(sin(x * 0.2) * 3.0), 1, 1), Color("#5a7a9a"))
	img.fill_rect(Rect2i(10 * T + 6, 16, 22, 1), Color("#6b4a2e"))   # the inked route
	img.fill_rect(Rect2i(10 * T + 27, 14, 3, 3), BRASS)              # the star where the parcel was found
	_lantern(img, 2 * T)
	# The chest and the coat pegs.
	_shadow(img, Rect2i(11 * T + 4, 8 * T - 2, 2 * T, 5), 0.35)
	_block(img, Rect2i(11 * T, 7 * T + 2, 2 * T, T - 2), Color("#7e5632"), 0.14)
	img.fill_rect(Rect2i(11 * T, 7 * T + 8, 2 * T, 2), BRASS.darkened(0.2))
	img.fill_rect(Rect2i(12 * T - 2, 7 * T + 10, 4, 4), BRASS)
	for k in 2:
		_block(img, Rect2i(12 * T + 8, 4 * T + 4 + k * 22, 8, 6), Color("#6b4a2e"))
	# The door in the west wall, seen from above.
	_side_door(img, 0, 5, 2, true)


## A door in a side wall, seen from above (Preston, 2026-10-11: a side door drawn face-on reads as a door
## lying sideways). The gap through the wall's top in shadow, a jamb at each end, and the closed door seen
## edge-on as a thin board along the gap, its handle on the room side.
static func _side_door(img: Image, col: int, row: int, rows: int, west: bool) -> void:
	var x0 := col * T
	var y0 := row * T
	var hgt := rows * T
	img.fill_rect(Rect2i(x0, y0, T, hgt), Color("#2a2017"))
	for x in range(x0, x0 + T):   # the threshold boards
		if x % 6 == 0:
			img.fill_rect(Rect2i(x, y0, 1, hgt), Color("#221a12"))
	_block(img, Rect2i(x0 - 1, y0 - 5, T + 2, 7), Color("#6b4a2e"), 0.15)       # the jambs
	_block(img, Rect2i(x0 - 1, y0 + hgt - 2, T + 2, 7), Color("#6b4a2e"), 0.15)
	var bx := x0 + T / 2 - 2
	_block(img, Rect2i(bx, y0 + 1, 5, hgt - 2), Color("#8a6038"), 0.2)         # the door, edge-on
	img.fill_rect(Rect2i(bx + 5 if west else bx - 2, y0 + hgt / 2 - 1, 2, 3), BRASS)


## The kitchen hatch in a side wall, seen from above: an opening with firelight beyond and a counter
## ledge along it, a pot on the ledge.
static func _side_hatch(img: Image, col: int, row: int, rows: int) -> void:
	var x0 := col * T
	var y0 := row * T
	var hgt := rows * T
	img.fill_rect(Rect2i(x0, y0, T, hgt), Color("#3a2618"))
	img.fill_rect(Rect2i(x0 + 2, y0 + 4, T - 12, hgt - 8), Color("#8a4f26"))     # firelight in the kitchen beyond
	_block(img, Rect2i(x0 - 1, y0 - 5, T + 2, 7), Color("#6b4a2e"), 0.15)
	_block(img, Rect2i(x0 - 1, y0 + hgt - 2, T + 2, 7), Color("#6b4a2e"), 0.15)
	_block(img, Rect2i(x0 + T - 9, y0 + 1, 10, hgt - 2), Color("#a87a48"), 0.18)   # the counter ledge, its top
	for yy in range(-3, 4):   # a pot on the ledge
		for xx in range(-3, 4):
			if xx * xx + yy * yy <= 9:
				img.set_pixel(x0 + T - 4 + xx, y0 + hgt / 2 + yy, INK if xx * xx + yy * yy > 5 else Color("#4a4a52"))
	_glow(img, Vector2(x0 + T + 6, y0 + hgt / 2), 44, Color("#ffb066"), 0.22)


## Tall furniture standing on floor row `row` against the back wall, front to the viewer, rising over the
## wainscot behind it: a wooden case, three shelves, and what is kept on them.
static func _upright(img: Image, x: int, width: int, row: int, kind: String) -> void:
	var bottom := (row + 1) * T - 2
	var top := bottom - 46
	_shadow(img, Rect2i(x + 2, bottom, width, 4), 0.35)
	_block(img, Rect2i(x, top, width, bottom - top), Color("#5a3d25"), 0.12)
	_block(img, Rect2i(x - 1, top - 3, width + 2, 5), Color("#7e5632"), 0.18)   # its top
	var inner := Rect2i(x + 3, top + 4, width - 6, bottom - top - 8)
	img.fill_rect(inner, Color("#2e2016"))
	var sh := inner.size.y / 3
	var cols := [Color("#8e3430"), Color("#2f6b6e"), Color("#7a5636"), Color("#4a5a7a"), Color("#b08a5a")]
	for k in 3:
		var floor_y := inner.position.y + (k + 1) * sh - 2
		img.fill_rect(Rect2i(inner.position.x, floor_y, inner.size.x, 2), Color("#7e5632"))
		var cx := inner.position.x + 1
		var j := 0
		while cx < inner.end.x - 2:
			var hgt := sh - 4 - int(R._h(k, j, 160 + kind.length()) * 4)
			if kind == "books":
				img.fill_rect(Rect2i(cx, floor_y - hgt, 3, hgt), cols[(j + k) % cols.size()])
				img.fill_rect(Rect2i(cx, floor_y - hgt + 2, 3, 1), BRASS.darkened(0.3))
				cx += 3
			elif kind == "keepsakes":
				var c: Color = [Color("#b08a5a"), BRASS, Color("#8a8574")][(j + k) % 3]
				_block(img, Rect2i(cx, floor_y - 7, 7, 7), c, 0.15)
				cx += 9
			else:   # supplies: jars and coils of rope
				if (j + k) % 2 == 0:
					_block(img, Rect2i(cx, floor_y - 8, 6, 8), [Color("#c84a5a"), Color("#d8cfb8"), Color("#5a7a9a")][(j + k) % 3], 0.2)
					img.fill_rect(Rect2i(cx + 1, floor_y - 9, 4, 1), Color("#8a8574"))
				else:
					_block(img, Rect2i(cx, floor_y - 6, 8, 6), Color("#b08a5a"), 0.15)
				cx += 9
			j += 1
