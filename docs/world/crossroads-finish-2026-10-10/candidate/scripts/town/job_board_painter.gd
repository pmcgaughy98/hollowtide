extends RefCounted
## Notice-board presentation only. The town owns requests, carried state and service input.
const Layout = preload("res://scripts/town/town_layout.gd")
const Finish = preload("res://scripts/arena/creature_finish.gd")
const ART := "res://assets/sprites/world/job_board_2026_10_10/board_native.png"

static func _place() -> Dictionary:
	return Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "board")[0]

static func available() -> bool:
	return ResourceLoader.exists("res://scripts/town/building_exteriors.gd") and ResourceLoader.exists(ART) and load(ART).get_size() == Vector2(_place()["rect"].size * Layout.T)

static func apply(img: Image, ground: Image, reading_ground: Image) -> Image:
	if not available(): return img
	var place := _place()
	var at: Vector2i = place["rect"].position * Layout.T
	var d: Vector2i = place["door"] * Layout.T
	img.blit_rect(ground, Rect2i(Vector2i.ZERO, ground.get_size()), at)
	img.blit_rect(reading_ground, Rect2i(Vector2i.ZERO, reading_ground.get_size()), d)
	# Packed-earth reading pad replaces the old yellow block, leading south to Market Street.
	for y in Layout.T:
		for x in Layout.T:
			var edge := mini(x, Layout.T - 1 - x)
			var c := Color("#8f805e") if (x / 6 + y / 5) % 3 == 0 else Color("#948461")
			img.set_pixelv(d + Vector2i(x, y), img.get_pixelv(d + Vector2i(x, y)).lerp(c, 0.42 if edge < 2 else 0.88))
	var art: Image = load(ART).get_image()
	for y in range(2, art.get_height() + 2):
		for x in range(2, art.get_width() + 2):
			if art.get_pixel(x - 2, y - 2).a < 0.5: continue
			var p := at + Vector2i(x, y)
			img.set_pixelv(p, img.get_pixelv(p).darkened(0.28))
	return img

static func attach(parent: Node2D, _host: Node2D) -> Dictionary:
	var place := _place()
	var base := Node2D.new()
	base.name = "JobBoard"
	base.position = Vector2(place["rect"].position * Layout.T)
	# Sort at the board's foot row. The south reading tile remains in front of it.
	base.z_index = place["rect"].end.y * Layout.T - 1
	parent.add_child(base)
	var sprite := Sprite2D.new()
	sprite.name = "NoticeStand"
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture = load(ART)
	Finish.apply(sprite, true)
	base.add_child(sprite)
	# Reading-pad feedback is ground-level, so a creature always draws above it.
	var pad := Node2D.new()
	pad.name = "ReadingPad"
	pad.position = Vector2(place["door"] * Layout.T)
	parent.add_child(pad)
	var focus := Sprite2D.new()
	focus.name = "ReadingCorners"
	focus.centered = false
	focus.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pad.add_child(focus)
	var frames: Array[Texture2D] = []
	for k in 3: frames.append(ImageTexture.create_from_image(_marker(k)))
	focus.texture = frames[0]
	return {"base": base, "sprite": sprite, "pad": pad, "focus": focus, "frames": frames, "phase": 0.0, "frame": 0}

static func _marker(k: int) -> Image:
	var img := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	var tint: Color = [Color("#ab9265"), Color("#ceb386"), Color("#eee0bf")][k]
	# Four inset limestone corners frame the unchanged reading spot, never a fake door.
	for x in [2, 17]:
		for y in [3, 18]:
			img.fill_rect(Rect2i(x, y, 5, 2), Color("#394337"))
			img.fill_rect(Rect2i(x, y, 5, 1), tint)
	return img

static func update(b: Dictionary, town: Node2D, delta: float) -> void:
	# Claude's working Board panel identifies itself by service, without a place id.
	var target := 1.0 if town.panel.get("id", "") == "board" or town.panel.get("service", "") == "board" else 0.0
	b["phase"] = move_toward(b["phase"], target, delta / 0.24)
	var frame := mini(2, int(b["phase"] * 3.0))
	if frame != b["frame"]:
		b["frame"] = frame
		b["focus"].texture = b["frames"][frame]
