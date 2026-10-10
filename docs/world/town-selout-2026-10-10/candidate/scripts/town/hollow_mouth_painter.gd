extends RefCounted
## Dungeon entrance presentation only. The town owns entry, carried jobs and scene transitions.
const Layout = preload("res://scripts/town/town_layout.gd")
const Finish = preload("res://scripts/town/exterior_finish.gd")
const ART := "res://assets/sprites/world/hollow_mouth_2026_10_10/mouth_native.png"

static func _place() -> Dictionary:
	return Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "gate")[0]

static func available() -> bool:
	return ResourceLoader.exists("res://scripts/town/building_exteriors.gd") and ResourceLoader.exists(ART) and load(ART).get_size() == Vector2(_place()["rect"].size * Layout.T)

static func apply(img: Image, ground: Image) -> Image:
	if not available(): return img
	var place := _place()
	var at: Vector2i = place["rect"].position * Layout.T
	img.blit_rect(ground, Rect2i(Vector2i.ZERO, ground.get_size()), at)
	var art: Image = load(ART).get_image()
	# Low rubble's contact band falls bottom-right, in the existing terrace colours.
	for y in range(2, art.get_height() + 2):
		for x in range(2, art.get_width() + 2):
			if art.get_pixel(x - 2, y - 2).a < 0.5: continue
			var p := at + Vector2i(x, y)
			img.set_pixelv(p, img.get_pixelv(p).darkened(0.28))
	# The existing lane ends just west of the Mouth. A worn earthen elbow connects
	# that end to the unchanged south-west activation tile, entirely on open ground.
	var d: Vector2i = place["door"] * Layout.T
	for y in range(at.y - Layout.T, d.y + Layout.T):
		for x in range(at.x - Layout.T, at.x):
			var edge := mini(x - at.x + Layout.T, at.x - 1 - x)
			var c := Color("#948461") if (x / 6 + y / 5) % 3 != 0 else Color("#8f805e")
			img.set_pixel(x, y, img.get_pixel(x, y).lerp(c, 0.32 if edge < 2 else 0.78))
	for local in [Vector2i(-19, 4), Vector2i(-15, 29), Vector2i(-6, 34)]:
		var p: Vector2i = at + local
		img.fill_rect(Rect2i(p, Vector2i(5, 2)), Color("#807559"))
		img.fill_rect(Rect2i(p, Vector2i(4, 1)), Color("#bea986"))
	return img

static func attach(parent: Node2D, _host: Node2D) -> Dictionary:
	var base := Node2D.new()
	base.name = "HollowMouth"
	base.position = Vector2(_place()["rect"].position * Layout.T)
	# A low scour recess is ground-level. All four existing tiles remain traversable.
	base.z_index = 0
	parent.add_child(base)
	var sprite := Sprite2D.new()
	sprite.name = "ScourRecess"
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture = load(ART)
	Finish.apply(sprite, true)
	base.add_child(sprite)
	return {"base": base, "sprite": sprite}
