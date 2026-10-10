extends RefCounted
## Open-air practice yard presentation. The town owns interaction; arena rules stay separate.
const Layout = preload("res://scripts/town/town_layout.gd")
const Finish = preload("res://scripts/town/exterior_finish.gd")
const ART := "res://assets/sprites/world/training_yard_2026_10_10/yard_native.png"

static func _place() -> Dictionary:
	return Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "yard")[0]

static func available() -> bool:
	return ResourceLoader.exists("res://scripts/town/building_exteriors.gd") and ResourceLoader.exists(ART) and load(ART).get_size() == Vector2(_place()["rect"].size * Layout.T)

static func apply(img: Image, ground: Image) -> Image:
	if not available(): return img
	var place := _place()
	var at: Vector2i = place["rect"].position * Layout.T
	img.blit_rect(ground, Rect2i(Vector2i.ZERO, ground.get_size()), at)
	var art: Image = load(ART).get_image()
	# Ground-coloured contact shadow stays inside the fully walkable footprint.
	for y in range(2, art.get_height()):
		for x in range(2, art.get_width()):
			if art.get_pixel(x - 2, y - 2).a < 0.5: continue
			var p := at + Vector2i(x, y)
			img.set_pixelv(p, img.get_pixelv(p).darkened(0.28))
	# The street's earth colours connect the north entrance stones to Market Street.
	var d: Vector2i = place["door"] * Layout.T
	for y in range(d.y - Layout.T, d.y + 14):
		var half := 11 + maxi(0, d.y - y) / 6
		for x in range(d.x + 12 - half, d.x + 12 + half):
			var edge := absi(x - d.x - 12)
			var c := Color("#948461") if (x / 6 + y / 5) % 3 != 0 else Color("#8f805e")
			img.set_pixel(x, y, img.get_pixel(x, y).lerp(c, 0.45 if edge >= half - 2 else 0.88))
	return img

static func attach(parent: Node2D, _host: Node2D) -> Dictionary:
	var base := Node2D.new()
	base.name = "TrainingYard"
	base.position = Vector2(_place()["rect"].position * Layout.T)
	# This is low-relief ground, below creatures, with all 35 original tiles open.
	base.z_index = 0
	parent.add_child(base)
	var sprite := Sprite2D.new()
	sprite.name = "PracticeRing"
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture = load(ART)
	Finish.apply(sprite, true)
	base.add_child(sprite)
	var focus := Sprite2D.new()
	focus.name = "TargetSign"
	focus.centered = false
	focus.position = Vector2(52, 1)
	focus.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	base.add_child(focus)
	var frames: Array[Texture2D] = []
	for k in 3: frames.append(ImageTexture.create_from_image(_sign(k)))
	focus.texture = frames[0]
	return {"base": base, "sprite": sprite, "focus": focus, "frames": frames, "phase": 0.0, "frame": 0}

static func _sign(k: int) -> Image:
	var img := Image.create(19, 32, false, Image.FORMAT_RGBA8)
	var ink := Color("#0b0e11")
	img.fill_rect(Rect2i(8, 15, 2, 17), ink)
	img.fill_rect(Rect2i(0, 0, 19, 17), ink)
	img.fill_rect(Rect2i(1, 1, 17, 15), Color("#bea986"))
	img.fill_rect(Rect2i(2, 2, 15, 13), Color("#665e44"))
	var tint: Color = [Color("#b79a65"), Color("#d4b77e"), Color("#eee0bf")][k]
	# Original practice-target pictogram, readable without a floating name plaque.
	for y in range(3, 14):
		for x in range(4, 15):
			var r := maxi(absi(x - 9), absi(y - 8))
			if r in [5, 3, 0]: img.set_pixel(x, y, tint)
	return img

static func update(b: Dictionary, town: Node2D, delta: float) -> void:
	var target := 1.0 if town.panel.get("id", "") == "yard" else 0.0
	b["phase"] = move_toward(b["phase"], target, delta / 0.24)
	var frame := mini(2, int(b["phase"] * 3.0))
	if frame != b["frame"]:
		b["frame"] = frame
		b["focus"].texture = b["frames"][frame]
