extends RefCounted
## Paints a generated floor (scripts/hollow/hollow_gen.gd) into one image at any tile size
## (Claude, 2026-10-09). Ground from the arena's own grass, cut into patches that avoid the
## painted pitch lines; walls as one dark silted bank with a lit lip where it meets open floor,
## a cliff face where a wall sits above floor, a shadow on the floor under it; the stairs as a
## dark way down with lit steps. No new art and no paid generation.

const Gen := preload("res://scripts/hollow/hollow_gen.gd")
const GRASS := "res://assets/backgrounds/arena/arena_grass.png"
const GRASS_FLOOR := Rect2(30, 60, 340, 150)


static func paint(data: Dictionary, t: int, seed_value: int) -> Image:
	if t == 24 and ResourceLoader.exists(preload("res://scripts/dungeon/hollow_bank_painter.gd").ATLAS):
		return preload("res://scripts/dungeon/hollow_bank_painter.gd").paint(data,t,seed_value)
	return paint_procedural(data,t,seed_value)

static func paint_procedural(data: Dictionary, t: int, seed_value: int) -> Image:
	var w: int = data["w"]
	var h: int = data["h"]
	var tiles: PackedByteArray = data["tiles"]
	var img := Image.create(w * t, h * t, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var ground := _patches(load(GRASS).get_image(), GRASS_FLOOR, rng, t)
	var top := Color(0.2, 0.18, 0.16)
	for y in h * t:
		for x in w * t:
			if tiles[(y / t) * w + (x / t)] != Gen.WALL:
				continue
			var hsh: int = (((x * 374761393) + (y * 668265263)) ^ ((x * 2654435761) >> 7)) & 0xFFFF
			var n: float = float(hsh) / 65535.0 * 0.05 - 0.025
			var c := Color(top.r + n, top.g + n, top.b + n)
			if ((x * 31 + y * 17) % 97) == 0:
				c = Color(0.32, 0.29, 0.25)
			img.set_pixel(x, y, c)
	var lip := Color(0.36, 0.32, 0.27)
	var face_h: int = int(t * 0.55)
	for y in h:
		for x in w:
			var wall: bool = tiles[y * w + x] == Gen.WALL
			if not wall:
				img.blit_rect(ground[rng.randi_range(0, ground.size() - 1)], Rect2i(0, 0, t, t), Vector2i(x * t, y * t))
				if y > 0 and tiles[(y - 1) * w + x] == Gen.WALL:
					for k in 3:
						_darken(img, Rect2i(x * t, y * t + k, t, 1), 0.6 + 0.12 * k)
				continue
			if x > 0 and tiles[y * w + x - 1] == Gen.FLOOR:
				img.fill_rect(Rect2i(x * t, y * t, 1, t), lip)
			if x + 1 < w and tiles[y * w + x + 1] == Gen.FLOOR:
				img.fill_rect(Rect2i(x * t + t - 1, y * t, 1, t), lip)
			if y > 0 and tiles[(y - 1) * w + x] == Gen.FLOOR:
				img.fill_rect(Rect2i(x * t, y * t, t, 1), lip)
			if y + 1 < h and tiles[(y + 1) * w + x] == Gen.FLOOR:
				# The cliff face seen from above at an angle: banded silt, dark at the foot.
				var y0: int = y * t + t - face_h
				for k in face_h:
					var shade: float = 1.0 - 0.06 * k
					img.fill_rect(Rect2i(x * t, y0 + k, t, 1), Color(0.36 * shade, 0.29 * shade, 0.22 * shade) if k < face_h - 1 else Color(0.08, 0.06, 0.05))
				img.fill_rect(Rect2i(x * t, y0 - 1, t, 1), Color(0.62, 0.55, 0.44))
	# The stairs.
	var st: Vector2i = data["stairs"]
	var s := Vector2i(st.x * t + t / 2 - 10, st.y * t + t / 2 - 8)
	img.fill_rect(Rect2i(s, Vector2i(20, 16)), Color(0.05, 0.05, 0.07))
	for k in 3:
		img.fill_rect(Rect2i(s + Vector2i(2 + k * 2, 2 + k * 5), Vector2i(16 - k * 4, 2)), Color(0.55, 0.6, 0.66))
	img.fill_rect(Rect2i(s - Vector2i(1, 1), Vector2i(22, 1)), Color(0.85, 0.8, 0.6))
	return img


static func _patches(src: Image, area: Rect2, rng: RandomNumberGenerator, t: int) -> Array[Image]:
	src.convert(Image.FORMAT_RGBA8)
	var out: Array[Image] = []
	for tries in 600:
		if out.size() >= 24:
			break
		var p := Vector2i(rng.randi_range(int(area.position.x), int(area.end.x) - t), rng.randi_range(int(area.position.y), int(area.end.y) - t))
		var patch := src.get_region(Rect2i(p, Vector2i(t, t)))
		var clean := true
		for y in t:
			for x in t:
				var c: Color = patch.get_pixel(x, y)
				if minf(c.r, minf(c.g, c.b)) > 0.7 or c.a < 0.9:
					clean = false
					break
			if not clean:
				break
		if clean:
			out.append(patch)
	if out.is_empty():
		var plain := Image.create(t, t, false, Image.FORMAT_RGBA8)
		plain.fill(Color(0.3, 0.45, 0.2))
		out.append(plain)
	return out


static func _darken(img: Image, r: Rect2i, k: float) -> void:
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			var c: Color = img.get_pixel(x, y)
			img.set_pixel(x, y, Color(c.r * k, c.g * k, c.b * k))
