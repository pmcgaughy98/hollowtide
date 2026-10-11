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
	else:
		_home(img, r)
	if id == "home":
		img = preload("res://scripts/town/home_room_art.gd").paint(img)
	return img


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
