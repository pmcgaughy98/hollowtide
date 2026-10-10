extends RefCounted
## Flat Crossroads presentation. All routes, tiles and service input belong to the town.
const Layout = preload("res://scripts/town/town_layout.gd")
const Finish = preload("res://scripts/arena/creature_finish.gd")
const INK := Color("#0b0e11")
const STONES := [Color("#a69470"), Color("#ae9b77"), Color("#b3a17d"), Color("#ac9874")]

static func _place() -> Dictionary:
	return Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "plaza")[0]

static func available() -> bool:
	return ResourceLoader.exists("res://scripts/town/building_exteriors.gd")

static func _path(at: Vector2i) -> bool:
	for r in Layout.PATHS:
		if r.has_point(at / Layout.T): return true
	return false

static func _edge(y: int) -> int:
	# Broken, stepped edges, rather than a rectangular frame or another circular arena.
	if y < 24: return 83 - (y - 8) * 3
	if y < 48: return 28 + ((y / 8) % 2) * 5
	if y < 101: return 26 + ((y / 9) % 3) * 4
	return 39 + (y - 101) * 2

static func apply(img: Image, ground: Image) -> Image:
	if not available(): return img
	var p := _place()
	var at: Vector2i = p["rect"].position * Layout.T
	img.blit_rect(ground, Rect2i(Vector2i.ZERO, ground.get_size()), at)
	# A worn clearing opens from the street and narrows towards the ferry lane.
	# Every original road pixel is skipped, so its two-tile width and seams stay intact.
	for y in range(9, 127):
		var left := _edge(y)
		var right := 288 - left - (7 if y > 72 else 0)
		for x in range(left, right):
			var world := at + Vector2i(x, y)
			if _path(world): continue
			var edge := mini(x - left, right - 1 - x)
			var c := Color("#948461") if ((x / 9 + y / 7) % 4) != 0 else Color("#8f805e")
			img.set_pixelv(world, ground.get_pixel(x, y).lerp(c, 0.38 if edge < 3 else 0.82))
	# Small irregular limestone clusters lead the eye across the clearing. Their gaps
	# show packed earth; no walls, raised furniture or new collision are implied.
	for row in range(1, 8):
		var y := 12 + row * 12
		for col in range(1, 12):
			var n := posmod(col * 37 + row * 19, 61)
			if n % 5 == 0: continue
			var x := 18 + col * 20 + (7 if row % 2 == 0 else 0) + n % 5 - 2
			var stone_y := y + (n / 5) % 5 - 2
			var w := 12 + n % 5
			var h := 7 + n % 3
			for sy in h:
				for sx in w:
					var px := x + sx
					var py := stone_y + sy
					if px < _edge(py) + 7 or px > 280 - _edge(py): continue
					var world := at + Vector2i(px, py)
					if _path(world): continue
					if (sx == 0 or sx == w - 1) and (sy == 0 or sy == h - 1): continue
					if n % 3 == 0 and sx < 2 and sy < 2: continue
					var c: Color = STONES[n % 4]
					if sy == 0: c = Color("#c4ae8b")
					elif sx == w - 1 or sy == h - 1: c = Color("#807559")
					elif n % 4 == 0 and sx == w / 2 + (1 if sy > h / 2 else 0) and sy > 2: c = Color("#807559")
					elif n % 3 == 0 and sy == h - 2 and sx > w - 4: c = Color("#677c4c")
					elif n % 5 == 1 and sy == 2 and sx in [3, 4]: c = Color("#998465")
					img.set_pixelv(world, c)
	# Grass tips overlap a handful of edges, in Highbank's existing ground palette.
	for local in [Vector2i(44, 33), Vector2i(33, 79), Vector2i(64, 119), Vector2i(236, 36), Vector2i(245, 94), Vector2i(215, 120)]:
		var tuft: Vector2i = at + local
		img.fill_rect(Rect2i(tuft, Vector2i(7, 1)), Color("#53673e"))
		img.fill_rect(Rect2i(tuft + Vector2i(1, -3), Vector2i(1, 3)), Color("#819059"))
		img.fill_rect(Rect2i(tuft + Vector2i(4, -2), Vector2i(2, 2)), Color("#677c4c"))
	return img

static func _marker(k: int) -> Image:
	var img := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	# A low limestone inlay, not a standing monument: the leader can cross its tile.
	for y in range(4, 21):
		var inset := 5 if y in [4, 20] else 3 if y in [5, 19] else 2
		for x in range(inset, 24 - inset):
			var c := Color("#ac9874") if (x / 5 + y / 4) % 3 else Color("#b5a07d")
			if x == inset or x == 23 - inset or y in [4, 20]: c = INK
			elif y == 5: c = Color("#d0b891")
			elif y == 19: c = Color("#807559")
			img.set_pixel(x, y, c)
	# Hall's original three-route glyph: dark recessed seams with warm left edges.
	var tint: Color = [Color("#a99870"), Color("#ceb386"), Color("#eee0bf")][k]
	for j in 5:
		img.fill_rect(Rect2i(5 + j, 7 + j, 3, 3), INK)
		img.fill_rect(Rect2i(16 - j, 7 + j, 3, 3), INK)
		img.fill_rect(Rect2i(5 + j, 7 + j, 2, 1), tint)
		img.fill_rect(Rect2i(16 - j, 7 + j, 2, 1), tint)
	img.fill_rect(Rect2i(10, 11, 4, 7), INK)
	img.fill_rect(Rect2i(10, 12, 1, 5), tint)
	# Two broken stone joints make the purpose tile read as carved, not a UI badge.
	img.fill_rect(Rect2i(4, 16, 3, 1), Color("#394337"))
	img.fill_rect(Rect2i(18, 10, 3, 1), Color("#394337"))
	return img

static func attach(parent: Node2D, _host: Node2D) -> Dictionary:
	var base := Node2D.new()
	base.name = "CrossroadsWaymark"
	base.position = Vector2(_place()["door"] * Layout.T)
	# All 72 plaza tiles remain open; this floor inlay always draws below creatures.
	base.z_index = 0
	parent.add_child(base)
	var sprite := Sprite2D.new()
	sprite.name = "CarvedWaymark"
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	Finish.apply(sprite, true)
	base.add_child(sprite)
	var frames: Array[Texture2D] = []
	for k in 3: frames.append(ImageTexture.create_from_image(_marker(k)))
	sprite.texture = frames[0]
	return {"base": base, "sprite": sprite, "frames": frames, "phase": 0.0, "frame": 0}

static func update(b: Dictionary, town: Node2D, delta: float) -> void:
	var target := 1.0 if town.panel.get("id", "") == "plaza" else 0.0
	b["phase"] = move_toward(b["phase"], target, delta / 0.24)
	var frame := mini(2, int(b["phase"] * 3.0))
	if frame != b["frame"]:
		b["frame"] = frame
		b["sprite"].texture = b["frames"][frame]
