extends RefCounted
## Highbank ground proposal. Claude's collision layout and multi-tile doorway are the contract.
## Code-native, seeded pixel clusters; source creature art and the blockout stay intact.
const Layout = preload("res://scripts/town/town_layout.gd")
const T = Layout.T
const GRASS = [Color("#637849"), Color("#677c4c"), Color("#6b804f"), Color("#6f8352")]
const EARTH = [Color("#8b7c5b"), Color("#8f805e"), Color("#948461"), Color("#998866")]
const STONE = [Color("#ac9874"), Color("#b5a07d"), Color("#bea986"), Color("#c4ae8b")]
const INK = Color("#394337")
const CLIFF = [Color("#a08860"), Color("#8d7452"), Color("#796447"), Color("#63543e")]

static func _hash(x: int, y: int, salt: int = 0) -> int:
	return posmod((x * 374761393 + y * 668265263 + salt * 144269) ^ ((x * 2654435761) >> 11), 65521)

static func _path_at(x: int, y: int) -> bool:
	# October 10: the two-tile Hall doorway now meets the authored two-tile steps.
	for r in Layout.PATHS:
		if r.has_point(Vector2i(x, y)):
			return true
	return false

static func paint(blockout: Image) -> Image:
	var img = Image.create(Layout.W * T, Layout.H * T, false, Image.FORMAT_RGBA8)
	# Larger islands of close tones, rather than independent pixel noise or a 24px checkerboard.
	for y in img.get_height():
		var kind = Layout.band_of(y / T)
		for x in img.get_width():
			var field = sin((x / 5 * 5) * 0.018) + cos((y / 5 * 5) * 0.021) + 0.45 * sin((x + y) * 0.027)
			var patch = clampi(int((field + 2.5) * 0.8), 0, 3)
			var c: Color
			if kind == "grass":
				c = GRASS[patch]
			elif kind == "terrace":
				c = EARTH[patch]
			elif kind == "cliff":
				var depth = y % T
				c = CLIFF[mini(3, depth / 6)]
				if _hash(x / 12, y / 3) % 5 == 0:
					c = c.darkened(0.07)
			else:
				c = Color("#42665f") if _hash(x / 15, y / 5, 4) % 3 == 0 else Color("#466d66")
			img.set_pixel(x, y, c)
	# Small blades, moss, pebbles and tufts use clustered strokes on the same native pixel grid.
	for y in Layout.H:
		for x in Layout.W:
			var kind = Layout.band_of(y)
			if kind not in ["grass", "terrace"]:
				continue
			for k in 4:
				var n = _hash(x, y, 23 + k)
				var p = Vector2i(x * T + 3 + n % 17, y * T + 3 + (n / 17) % 16)
				if kind == "grass":
					img.fill_rect(Rect2i(p, Vector2i(3, 1)), Color("#53673e"))
					img.fill_rect(Rect2i(p + Vector2i(1, -2), Vector2i(1, 2)), Color("#88965e"))
					if n % 5 == 0:
						img.fill_rect(Rect2i(p + Vector2i(-1, -1), Vector2i(2, 1)), Color("#819059"))
				else:
					img.fill_rect(Rect2i(p, Vector2i(3, 1)), Color("#a69776"))
					img.fill_rect(Rect2i(p + Vector2i(1, 1), Vector2i(2, 1)), Color("#73674d"))
	# Both ledges are cut bank clay. Open crossings remain exactly the PATHS tiles.
	for y in [18, 24]:
		for x in Layout.W * T:
			if _path_at(x / T, y):
				continue
			var yy = y * T
			img.set_pixel(x, yy, INK)
			img.set_pixel(x, yy + 1, Color("#a1a16b"))
			img.set_pixel(x, yy + 2, Color("#80935b") if y == 18 else Color("#baa17b"))
			img.set_pixel(x, yy + 22, Color("#4d4837"))
			img.set_pixel(x, yy + 23, INK)
			if _hash(x / 13, y, 7) % 5 == 0:
				img.fill_rect(Rect2i(x, yy + 6, 1, 12), Color("#6b5940"))
			if x % 17 < 5:
				img.fill_rect(Rect2i(x, yy + 6, 1, 1), Color("#b99d6d"))
			img.fill_rect(Rect2i(x, yy + T, 1, 2), Color("#71684c"))
	# Joined roads are painted from one mask, so there are no seams at PATHS intersections.
	for y in Layout.H * T:
		for x in Layout.W * T:
			if not _path_at(x / T, y / T):
				continue
			var row = y / 7
			var shift = 6 if row % 2 == 0 else 0
			var sx = posmod(x + shift, 12)
			var sy = y % 7
			var n = _hash((x + shift) / 12, row, 32)
			var c: Color = STONE[n % 4]
			if sx == 0 or sy == 0 or (sx == 1 and sy == 1):
				c = Color("#807559")
			elif sy == 1:
				c = Color("#cbb590")
			elif sx == 11 or sy == 6:
				c = Color("#998465")
			if n % 7 == 0 and sx in [5, 6] and sy in [3, 4]:
				c = Color("#a28e6c")
			# A soft earthen verge stays inside the road's authored footprint.
			if (x % T < 2 and not _path_at(x / T - 1, y / T)) or (x % T > 21 and not _path_at(x / T + 1, y / T)) or (y % T < 2 and not _path_at(x / T, y / T - 1)) or (y % T > 21 and not _path_at(x / T, y / T + 1)):
				c = Color("#918461")
			img.set_pixel(x, y, c)
	# Stair treads signal elevation only at the two existing cliff crossings.
	for r in Layout.PATHS:
		for y in [18, 24]:
			if not r.has_point(Vector2i(r.position.x, y)):
				continue
			var p = Vector2i(r.position.x * T, y * T)
			for k in 4:
				img.fill_rect(Rect2i(p + Vector2i(2, k * 6), Vector2i(r.size.x * T - 4, 2)), Color("#d0b891"))
				img.fill_rect(Rect2i(p + Vector2i(2, k * 6 + 4), Vector2i(r.size.x * T - 4, 2)), Color("#665a45"))
	# Keep the native ground beneath the installed exteriors for the optional exterior's transparent corners.
	var hall_ground: Image
	var home_ground: Image
	var shop_ground: Image
	var storage_ground: Image
	var scroll_ground: Image
	var shrine_ground: Image
	var yard_ground: Image
	# Flat areas become walkable ground, with their full layout rectangles still readable.
	for place in Layout.PLACES:
		var r: Rect2i = place["rect"]
		var px = Rect2i(r.position * T, r.size * T)
		if place["id"] == "yard":
			yard_ground = img.get_region(px)
		if place["id"] == "shrine":
			shrine_ground = img.get_region(px)
		if place["kind"] == "area":
			var col = Color("#92956a") if place["id"] in ["lookout", "shrine", "yard"] else Color("#b2a17c")
			for edge in [Rect2i(px.position, Vector2i(px.size.x, 1)), Rect2i(px.position + Vector2i(0, px.size.y - 1), Vector2i(px.size.x, 1)), Rect2i(px.position, Vector2i(1, px.size.y)), Rect2i(px.position + Vector2i(px.size.x - 1, 0), Vector2i(1, px.size.y))]:
				img.fill_rect(edge, col)
			for door in Layout.door_tiles(place):
				var d: Vector2i = door * T
				img.fill_rect(Rect2i(d + Vector2i(7, 17), Vector2i(10, 2)), Color("#d0b891"))
		else:
			if place["id"] == "hall":
				hall_ground = img.get_region(px)
			if place["id"] == "home":
				home_ground = img.get_region(px)
			if place["id"] == "shop":
				shop_ground = img.get_region(px)
			if place["id"] == "scrolls":
				scroll_ground = img.get_region(px)
			if place["id"] == "storage":
				storage_ground = img.get_region(px)
			# Building and service-spot art is a later slice. Preserve the original exact pixels.
			img.blit_rect(blockout, px, px.position)
			for door in Layout.door_tiles(place):
				var d: Vector2i = door * T
				if place["kind"] == "building" and Layout.door_tiles(place).size() > 1:
					img.fill_rect(Rect2i(d + Vector2i(0, 4), Vector2i(T, T - 4)), Color("#2a1a12"))
				else:
					img.blit_rect(blockout, Rect2i(d + Vector2i(6, 4), Vector2i(T - 12, T - 4)), d + Vector2i(6, 4))
	# The riverbank and quiet current. The river is still entirely non-walkable.
	for x in Layout.W * T:
		img.set_pixel(x, 30 * T, Color("#374b3b"))
		img.set_pixel(x, 30 * T + 1, Color("#81926c"))
		if posmod(x, 37) < 18:
			img.set_pixel(x, 30 * T + 4, Color("#72958a"))
	for y in range(30 * T + 9, Layout.H * T - 2, 8):
		for x in range(4, Layout.W * T - 25, 29):
			var offset = _hash(x, y, 51) % 12
			img.fill_rect(Rect2i(x + offset, y, 8 + offset / 2, 1), Color("#64867b"))
	if ResourceLoader.exists("res://scripts/town/wayline_hall_painter.gd"):
		img = load("res://scripts/town/wayline_hall_painter.gd").apply(img, hall_ground)
	if ResourceLoader.exists("res://scripts/town/home_painter.gd"):
		img = load("res://scripts/town/home_painter.gd").apply(img, home_ground)
	if ResourceLoader.exists("res://scripts/town/item_shop_painter.gd"):
		img = load("res://scripts/town/item_shop_painter.gd").apply(img, shop_ground)
	if ResourceLoader.exists("res://scripts/town/storage_painter.gd"):
		img = load("res://scripts/town/storage_painter.gd").apply(img, storage_ground)
	if ResourceLoader.exists("res://scripts/town/growth_shrine_painter.gd"):
		img = load("res://scripts/town/growth_shrine_painter.gd").apply(img, shrine_ground)
	if ResourceLoader.exists("res://scripts/town/scroll_keeper_painter.gd"):
		img = load("res://scripts/town/scroll_keeper_painter.gd").apply(img, scroll_ground)
	if ResourceLoader.exists("res://scripts/town/training_yard_painter.gd"):
		img = load("res://scripts/town/training_yard_painter.gd").apply(img, yard_ground)
	return img
