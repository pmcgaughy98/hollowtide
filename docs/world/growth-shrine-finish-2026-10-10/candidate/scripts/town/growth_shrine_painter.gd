extends RefCounted
## Open-air evolution clearing: art/presentation only. Claude owns readiness and evolution.
const Layout = preload("res://scripts/town/town_layout.gd")
const ART := "res://assets/sprites/world/growth_shrine_2026_10_10/shrine_native.png"
const Finish = preload("res://scripts/arena/creature_finish.gd")
const DETAIL = preload("res://scripts/town/building_detail_finish.gdshader")

static func available() -> bool:
	return ResourceLoader.exists("res://scripts/town/building_exteriors.gd") and ResourceLoader.exists(ART) and load(ART).get_size() == Vector2(_place()["rect"].size * Layout.T)

static func _place() -> Dictionary:
	return Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "shrine")[0]

static func apply(img: Image, ground: Image) -> Image:
	if not available(): return img
	var place := _place()
	var at: Vector2i = place["rect"].position * Layout.T
	img.blit_rect(ground, Rect2i(Vector2i.ZERO, ground.get_size()), at)
	var art: Image = load(ART).get_image()
	for y in range(2, art.get_height()):
		for x in range(2, art.get_width()):
			if art.get_pixel(x - 2, y - 2).a < 0.5: continue
			var p := at + Vector2i(x, y)
			img.set_pixelv(p, img.get_pixelv(p).darkened(0.28))
	# Same native street palette; three worn stones bridge the grass gap to the north entrance.
	var d: Vector2i = place["door"] * Layout.T
	for y in range(d.y - Layout.T, d.y + 8):
		for x in range(d.x, d.x + Layout.T):
			var edge := mini(x - d.x, d.x + Layout.T - 1 - x)
			var c := Color("#948461") if (x / 6 + y / 5) % 3 != 0 else Color("#8f805e")
			img.set_pixel(x, y, img.get_pixel(x, y).lerp(c, 0.45 if edge < 2 else 0.88))
	return img

static func attach(parent: Node2D, _host: Node2D) -> Dictionary:
	var base := Node2D.new()
	base.name = "GrowthShrine"
	base.position = Vector2(_place()["rect"].position * Layout.T)
	# An open, low-relief floor remains below every creature; no new invisible collision.
	base.z_index = 0
	parent.add_child(base)
	var sprite := Sprite2D.new()
	sprite.name = "Clearing"
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture = load(ART)
	Finish.apply(sprite)
	sprite.material.shader = DETAIL
	base.add_child(sprite)
	var focus := Sprite2D.new()
	focus.name = "EntranceInlay"
	focus.centered = false
	focus.position = Vector2(78, 14)
	focus.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	base.add_child(focus)
	var frames: Array[Texture2D] = []
	for k in 3: frames.append(ImageTexture.create_from_image(_inlay(k)))
	focus.texture = frames[0]
	return {"base": base, "sprite": sprite, "focus": focus, "frames": frames, "phase": 0.0, "frame": 0, "shrine": true}

static func _inlay(k: int) -> Image:
	var img := Image.create(13, 9, false, Image.FORMAT_RGBA8)
	var colours := [Color("#8d789b"), Color("#c4a7d9"), Color("#eee0bf")]
	# Original small three-leaf mark on the actual (7,12) activation tile.
	for p in [Vector2i(6, 1), Vector2i(5, 2), Vector2i(6, 2), Vector2i(7, 2), Vector2i(6, 3), Vector2i(2, 4), Vector2i(3, 4), Vector2i(3, 5), Vector2i(4, 5), Vector2i(4, 6), Vector2i(9, 4), Vector2i(10, 4), Vector2i(8, 5), Vector2i(9, 5), Vector2i(8, 6), Vector2i(6, 5), Vector2i(6, 6), Vector2i(6, 7)]:
		img.set_pixelv(p + Vector2i(0, 1), Color("#34362e"))
		img.set_pixelv(p, colours[k])
	return img

static func update(b: Dictionary, town: Node2D, delta: float) -> void:
	var service: String = town.panel.get("service", "")
	var target := 1.0 if service in ["growth", "evolve_ask", "growth_done"] else 0.0
	if town.evolving_now: target = 1.0
	b["phase"] = move_toward(b["phase"], target, delta / 0.24)
	var frame := mini(2, int(b["phase"] * 3.0))
	if frame != b["frame"]:
		b["frame"] = frame
		b["focus"].texture = b["frames"][frame]
