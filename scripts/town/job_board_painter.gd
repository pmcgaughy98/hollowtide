extends RefCounted
## Notice-board presentation only. The town owns requests, carried state and service input.
const Layout = preload("res://scripts/town/town_layout.gd")
const Finish = preload("res://scripts/town/exterior_finish.gd")
const UI = preload("res://scripts/ui/ui_style.gd")
const ART := "res://assets/sprites/world/job_board_2026_10_10/board_native.png"
const DISPLAY_ART := "res://assets/sprites/world/job_board_selout_2026_10_10/board_native.png"
# Claude, 2026-10-26 (placeholder factory lane B): the rect comes from the area showing (v1: the PLACES row itself)
# and the 96x48 display art from its keep slot (town.landmark.board: DISPLAY_ART as its legacy, so the pixels do not change).
const SLOT := "town.landmark.board"

static func _place() -> Dictionary:
	return BuildingTemplate.place_entry("board")

static func available() -> bool:
	return ResourceLoader.exists("res://scripts/town/building_exteriors.gd") and ResourceLoader.exists(ART) and load(ART).get_size() == Vector2(_place()["rect"].size * Layout.T)

static func apply(img: Image, ground: Image, reading_ground: Image) -> Image:
	if not available(): return img
	var place := _place()
	var at: Vector2i = place["rect"].position * Layout.T
	var d: Vector2i = place["door"] * Layout.T
	img.blit_rect(ground, Rect2i(Vector2i.ZERO, ground.get_size()), at)
	img.blit_rect(reading_ground, Rect2i(Vector2i.ZERO, reading_ground.get_size()), d)
	# Where readers stand: earth worn bare by feet, an uneven oval with a ragged, dithered edge that runs into the grass
	# and meets Market Street below (Claude, 2026-10-26, pass 8 T10 / L30). It was a packed-earth square the size of the
	# tile, which with the corner ticks read as a dashed rectangle drawn on the ground. The oval stays inside the tile:
	# the turf pass (highbank_painter.gd) paints the tiles round the board afresh, which would cut it square.
	var mid := Vector2(d) + Vector2(Layout.T * 0.5, Layout.T * 0.6)
	for y in Layout.T:
		for x in Layout.T:
			var p := d + Vector2i(x, y)
			var off := Vector2(p) + Vector2(0.5, 0.5) - mid
			var dist := Vector2(off.x / WORN_RX, off.y / WORN_RY).length() + (_h(p.x / 3, p.y / 3, 31) - 0.5) * 0.36
			if dist >= 1.0 or (dist > 0.72 and (dist - 0.72) / 0.28 > _h(p.x, p.y, 32)):
				continue
			var c: Color = WORN[int(_h(p.x / 2, p.y / 2, 33) * WORN.size())]
			if _h(p.x, p.y, 34) > 0.93:
				c = c.darkened(0.18)   # a scuff, a pressed pebble
			img.set_pixelv(p, img.get_pixelv(p).lerp(c, 0.55 if dist > 0.72 else 0.9))
	# The larger stand casts its contact shadow as a separate sprite on the final ground.
	return img


## The worn patch's half-width and half-height in px, and its earth (the old pad's two tones and a lighter, dustier one).
const WORN_RX := 10.5
const WORN_RY := 10.0
const WORN := [Color("#8f805e"), Color("#948461"), Color("#9c8c68")]


## 0 to 1 from a pixel and a salt, the same every paint.
static func _h(x: int, y: int, salt: int) -> float:
	return float(posmod((x * 374761393 + y * 668265263 + salt * 144269) ^ ((x * 2654435761) >> 11), 65521)) / 65521.0

static func _display_texture() -> Texture2D:
	# The original 48x24 stand is retained as the exact fallback.
	# Claude, 2026-10-24 (A4, LV-19): UI.res_image reads the imported texture, which an exported game has; the PNG it does not.
	var slotted := ArtSlots.texture(SLOT)
	if slotted.get_size() == Vector2(96, 48):
		return slotted
	var image := UI.res_image(DISPLAY_ART)
	if image != null and image.get_size()==Vector2i(96,48):
		return ImageTexture.create_from_image(image)
	return load(ART)

static func _visual_scale(texture: Texture2D) -> Vector2:
	return Vector2.ONE if texture.get_size()==Vector2(96,48) else Vector2(2,2)

static func _visual_offset(texture: Texture2D = null) -> Vector2:
	if texture == null: texture = _display_texture()
	var original: Rect2i = load(ART).get_image().get_used_rect()
	var used: Rect2i = texture.get_image().get_used_rect()
	# Same canvas centre and opaque foot row for native art and the original 2x fallback.
	return Vector2(-Layout.T, original.end.y-used.end.y*_visual_scale(texture).y)

static func attach(parent: Node2D, _host: Node2D) -> Dictionary:
	var place := _place()
	var base := Node2D.new()
	base.name = "JobBoard"
	base.position = Vector2(place["rect"].position * Layout.T)
	# Sort at the board's foot row. The south reading tile remains in front of it.
	base.z_index = place["rect"].end.y * Layout.T - 1
	parent.add_child(base)
	# Refined 96x48 native art keeps the enlarged stand's centre and contact row.
	var art := _display_texture()
	var visual_scale := _visual_scale(art)
	var offset := _visual_offset(art)
	var shadow := Sprite2D.new()
	shadow.name = "ContactShadow"
	shadow.centered = false
	shadow.position = offset + Vector2(2, 2)
	shadow.scale = visual_scale
	shadow.texture = art
	shadow.modulate = Color(0, 0, 0, 0.22)
	shadow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	base.add_child(shadow)
	var sprite := Sprite2D.new()
	sprite.name = "NoticeStand"
	sprite.scale = visual_scale
	sprite.position = offset
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture = art
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
	# No marks on the ground at rest (Claude, 2026-10-26, pass 8 T10 / L30): the four limestone corner ticks that framed
	# the reading spot are gone, the worn earth shows where to stand. While the board is open, its lantern light falls
	# on the worn earth: a soft warm oval in two steps, clear at its edge.
	if k == 0:
		return img
	var warm := Color("#f2c14e")
	for y in 24:
		for x in 24:
			var r := Vector2((x + 0.5 - 12.0) / 11.0, (y + 0.5 - 14.0) / 8.0).length()
			if r < 1.0:
				img.set_pixel(x, y, Color(warm, (0.07 if r > 0.6 else 0.12) * float(k)))
	return img

static func update(b: Dictionary, town: Node2D, delta: float) -> void:
	# Claude's working Board panel identifies itself by service, without a place id.
	var target := 1.0 if town.panel.get("id", "") == "board" or town.panel.get("service", "") == "board" else 0.0
	b["phase"] = move_toward(b["phase"], target, delta / 0.24)
	var frame := mini(2, int(b["phase"] * 3.0))
	if frame != b["frame"]:
		b["frame"] = frame
		b["focus"].texture = b["frames"][frame]
