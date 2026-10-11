extends RefCounted
## Shared sel-out, bounded to exposed wall faces/edges and the stairs.
## Generated topology, authored terrain and walking surfaces are never rebuilt.
const Gen := preload("res://scripts/hollow/hollow_gen.gd")
const SHADER := preload("res://scripts/dungeon/dungeon_finish.gdshader")

static func floor_at(data: Dictionary, x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < data.w and y < data.h and data.tiles[y * data.w + x] != Gen.WALL

static func mask(data: Dictionary, t: int, look: String) -> Image:
	var image := Image.create(data.w * t, data.h * t, false, Image.FORMAT_RGBA8)
	image.fill(Color.BLACK)
	var face_h := int(t * (0.62 if look == "riverbank" else (0.45 if look == "valley" else 0.6)))
	for y in data.h:
		for x in data.w:
			if data.tiles[y * data.w + x] != Gen.WALL:
				continue
			var p := Vector2i(x * t, y * t)
			if floor_at(data, x - 1, y):
				image.fill_rect(Rect2i(p, Vector2i(2, t)), Color.WHITE)
			if floor_at(data, x + 1, y):
				image.fill_rect(Rect2i(p + Vector2i(t - 2, 0), Vector2i(2, t)), Color.WHITE)
			if floor_at(data, x, y - 1):
				image.fill_rect(Rect2i(p, Vector2i(t, 2)), Color.WHITE)
			if floor_at(data, x, y + 1):
				image.fill_rect(Rect2i(p + Vector2i(0, t - face_h), Vector2i(t, face_h)), Color.WHITE)
	# Both code painters have the same 24x20 stair surround. The atlas uses the whole tile.
	var st: Vector2i = data.stairs * t
	var stairs := Rect2i(st, Vector2i(t, t)) if look == "bank" else Rect2i(st + Vector2i(t / 2 - 12, t / 2 - 10), Vector2i(24, 20))
	image.fill_rect(stairs, Color.WHITE)
	return image

static func apply(sprite: Sprite2D, data: Dictionary, t: int, look: String) -> void:
	var finish := ShaderMaterial.new()
	finish.shader = SHADER
	finish.set_shader_parameter("detail_mask", ImageTexture.create_from_image(mask(data, t, look)))
	sprite.material = finish
