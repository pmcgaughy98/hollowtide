extends Node2D
## Finished service exteriors only. Layout, interactions and carried state belong to the town.
const Layout = preload("res://scripts/town/town_layout.gd")
const Finish = preload("res://scripts/arena/creature_finish.gd")
const DETAIL_FINISH = preload("res://scripts/town/building_detail_finish.gdshader")
const SOURCES = {
	"storage": "res://assets/sprites/world/storage_2026_10_10/storage_native.png",
	"hall": "res://assets/sprites/world/wayline_hall_2026_10_10/wayline_hall_native.png",
	"home": "res://assets/sprites/world/home_2026_10_09/home_native.png",
	"shop": "res://assets/sprites/world/item_shop_2026_10_09/item_shop_native.png",
}
const INK = Color("#0b0e11")   # Purposeful building details use the house near-black contour.
const STONE = Color("#8f805e")
const LIGHT = Color("#bea986")
const GRASS = Color("#53673e")
var town: Node2D
var buildings := {}

static func available(id: String) -> bool:
	if id == "storage" and not ResourceLoader.exists("res://scripts/town/storage_painter.gd"):
		return false   # Keep the sprite and restored ground as one optional exterior.
	if not SOURCES.has(id) or not ResourceLoader.exists(SOURCES[id]):
		return false
	var place: Dictionary = Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == id)[0]
	return load(SOURCES[id]).get_size() == Vector2(place["rect"].size * Layout.T)

static func ground_apply(img: Image, ground: Image, place: Dictionary) -> Image:
	var r: Rect2i = place["rect"]
	var px := Rect2i(r.position * Layout.T, r.size * Layout.T)
	img.blit_rect(ground, Rect2i(Vector2i.ZERO, px.size), px.position)
	var art: Image = load(SOURCES[place["id"]]).get_image()
	# A two-pixel contact band, falling bottom-right from the common top-left light.
	for y in range(1, px.size.y + 2):
		for x in range(1, px.size.x + 2):
			var src := Vector2i(clampi(x - 2, 0, px.size.x - 1), clampi(y - 2, 0, px.size.y - 1))
			if art.get_pixelv(src).a < 0.5:
				continue
			var at := px.position + Vector2i(x, y)
			var c := img.get_pixelv(at)
			img.set_pixelv(at, c.darkened(0.33 if x < px.size.x + 1 and y < px.size.y + 1 else 0.17))
	if place["id"] == "hall":
		return img   # The existing two-tile paved steps already join the street.
	# Worn earth widens from the authored threshold to Market Street, without moving tiles.
	var d: Vector2i = place["door"] * Layout.T
	for y in range(d.y + Layout.T, 9 * Layout.T):
		var depth := y - (d.y + Layout.T)
		var half := 11 + depth / 4
		for x in range(d.x + 12 - half, d.x + 12 + half):
			var at := Vector2i(x, y)
			var edge := absi(x - (d.x + 12))
			var c := Color("#8f805e") if (x / 4 + y / 3) % 3 == 0 else Color("#948461")
			if edge >= half - 2:
				c = img.get_pixelv(at).lerp(c, 0.45)
			img.set_pixelv(at, c)
	return img

static func attach(parent: Node2D, host: Node2D) -> Node2D:
	var view = load("res://scripts/town/building_exteriors.gd").new()
	view.name = "BuildingExteriors"
	view.town = host
	parent.add_child(view)
	return view

func _ready() -> void:
	for place in Layout.PLACES:
		var id: String = place["id"]
		if not available(id):
			continue
		var r: Rect2i = place["rect"]
		var base := Node2D.new()
		base.name = id.capitalize()
		base.position = Vector2(r.position * Layout.T)
		# The door row remains in front of the roof. No collision or sorting rule changes.
		base.z_index = (r.end.y - 1) * Layout.T
		add_child(base)
		var sprite := Sprite2D.new()
		sprite.name = "Exterior"
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.texture = load(SOURCES[id])
		Finish.apply(sprite)
		sprite.material.shader = DETAIL_FINISH   # Same house outline; purposeful buildings ink their details too.
		base.add_child(sprite)
		var entrance: Vector2i = place["door"]
		for tile in Layout.door_tiles(place):
			entrance.x = mini(entrance.x, tile.x)
		var local_d: Vector2i = (entrance - r.position) * Layout.T
		var entrance_width: int = Layout.door_tiles(place).size() * Layout.T
		var details := Sprite2D.new()
		details.name = "FoundationAndSign"
		details.centered = false
		details.texture = ImageTexture.create_from_image(_details(r.size * Layout.T, local_d, id, entrance_width))
		base.add_child(details)
		var door := Sprite2D.new()
		door.name = "Door"
		door.centered = false
		door.position = Vector2(local_d + Vector2i(-2, -48 if id == "hall" else -36))
		Finish.apply(door)
		base.add_child(door)
		var frames: Array[Texture2D] = []
		for k in 3:
			frames.append(ImageTexture.create_from_image(_door_frame(k, sprite.texture.get_image(), local_d, id)))
		door.texture = frames[0]
		buildings[id] = {"base": base, "sprite": sprite, "door": door, "frames": frames, "phase": 0.0, "frame": 0}

static func _details(size: Vector2i, d: Vector2i, id: String, entrance_width: int = 24) -> Image:
	var img := Image.create(size.x, size.y + 1, false, Image.FORMAT_RGBA8)
	# Low broken foundation stones. The door gap and source arch are left intact.
	for x in range(9, size.x - 9, 7):
		if x > d.x - 6 and x < d.x + entrance_width + 5:
			continue
		var y := size.y - 7 + (x / 7) % 2
		img.fill_rect(Rect2i(x, y, 6, 4), INK)
		img.fill_rect(Rect2i(x, y, 5, 2), STONE)
		img.fill_rect(Rect2i(x, y, 4, 1), LIGHT)
	# Sparse grass crosses the wall/ground seam, in the ground's own greens.
	for x in [12, 27, size.x - 26, size.x - 12]:
		img.fill_rect(Rect2i(x, size.y - 4, 5, 1), GRASS)
		img.fill_rect(Rect2i(x + 1, size.y - 6, 1, 3), GRASS)
		img.fill_rect(Rect2i(x + 3, size.y - 5, 1, 2), Color("#88965e"))
	# One lit doorstep/mat anchored entirely to the walkable door tile.
	img.fill_rect(Rect2i(d.x + 1, size.y - 3, entrance_width - 2, 3), INK)
	img.fill_rect(Rect2i(d.x + 2, size.y - 3, entrance_width - 4, 1), LIGHT)
	img.fill_rect(Rect2i(d.x + 3, size.y - 2, entrance_width - 6, 1), STONE)
	if id == "shop":
		var p := d + Vector2i(31, -6)
		img.fill_rect(Rect2i(p + Vector2i(8, 11), Vector2i(2, 16)), INK)
		img.fill_rect(Rect2i(p, Vector2i(19, 16)), INK)
		img.fill_rect(Rect2i(p + Vector2i(1, 1), Vector2i(17, 14)), Color("#9b855c"))
		img.fill_rect(Rect2i(p + Vector2i(2, 2), Vector2i(15, 12)), Color("#665e44"))
		# Original bag pictogram: tied neck, broad satchel and gold clasp.
		img.fill_rect(Rect2i(p + Vector2i(6, 5), Vector2i(7, 8)), LIGHT)
		img.fill_rect(Rect2i(p + Vector2i(7, 3), Vector2i(5, 3)), LIGHT)
		img.fill_rect(Rect2i(p + Vector2i(5, 8), Vector2i(9, 4)), LIGHT)
		img.fill_rect(Rect2i(p + Vector2i(7, 6), Vector2i(5, 1)), INK)
		img.set_pixelv(p + Vector2i(9, 8), Color("#e2bd72"))
	if id == "storage":
		var p := d + Vector2i(31, -6)
		img.fill_rect(Rect2i(p + Vector2i(8, 13), Vector2i(2, 17)), INK)
		img.fill_rect(Rect2i(p, Vector2i(19, 17)), INK)
		img.fill_rect(Rect2i(p + Vector2i(1, 1), Vector2i(17, 15)), LIGHT)
		img.fill_rect(Rect2i(p + Vector2i(2, 2), Vector2i(15, 13)), Color("#665e44"))
		# Crate pictogram: an outlined box with two diagonal braces.
		img.fill_rect(Rect2i(p + Vector2i(4, 4), Vector2i(11, 10)), INK)
		img.fill_rect(Rect2i(p + Vector2i(5, 5), Vector2i(9, 8)), Color("#ab9265"))
		for y in 7:
			img.set_pixelv(p + Vector2i(5 + y, 5 + y), LIGHT)
			img.set_pixelv(p + Vector2i(13 - y, 5 + y), LIGHT)
	if id == "hall":
		var p := d + Vector2i(entrance_width + 10, -25)
		img.fill_rect(Rect2i(p + Vector2i(8, 13), Vector2i(2, 22)), INK)
		img.fill_rect(Rect2i(p, Vector2i(19, 19)), INK)
		img.fill_rect(Rect2i(p + Vector2i(1, 1), Vector2i(17, 17)), LIGHT)
		img.fill_rect(Rect2i(p + Vector2i(2, 2), Vector2i(15, 15)), Color("#49563d"))
		# Original waymark pictogram: three routes meeting at one point (visual proposal).
		for y in 5:
			img.fill_rect(Rect2i(p + Vector2i(4 + y, 5 + y), Vector2i(2, 2)), Color("#e2bd72"))
			img.fill_rect(Rect2i(p + Vector2i(13 - y, 5 + y), Vector2i(2, 2)), Color("#e2bd72"))
		img.fill_rect(Rect2i(p + Vector2i(9, 9), Vector2i(2, 6)), Color("#e2bd72"))
	return img

static func _door_frame(frame: int, art: Image, d: Vector2i, id: String) -> Image:
	if id == "hall":
		return _hall_door_frame(frame, art, d)
	var img := Image.create(28, 56, false, Image.FORMAT_RGBA8)
	var width: int = [28, 14, 4][frame]
	# Flood only the original opening. Dark roof/stone details cannot join across its light frame.
	var seen := {}
	var pending: Array[Vector2i] = [Vector2i(14, 30)]
	var dark_limit := 0.30 if id == "home" else 0.19   # Home already has warm light at its sill.
	while not pending.is_empty():
		var p: Vector2i = pending.pop_back()
		if seen.has(p) or p.x < 0 or p.y < 0 or p.x >= 28 or p.y >= 56: continue
		var c := art.get_pixelv(d + p + Vector2i(-2, -36))
		if c.a < 0.5 or c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722 > dark_limit: continue
		seen[p] = true
		for step in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]: pending.append(p + step)
	var origin := 0
	if id == "storage" and not seen.is_empty():
		origin = 28
		var end := 0
		for p in seen:
			origin = mini(origin, p.x)
			end = maxi(end, p.x + 1)
		width = [end - origin, maxi(2, (end - origin) / 2), 2][frame]
	for p in seen:
		var col := Color("#333b2f").lerp(Color("#987b46"), clampf((p.y - 34.0) / 21.0, 0.0, 1.0))
		if p.x < origin + width:
			col = Color("#80694a") if p.x % 5 != 0 else Color("#1f241e")
			if not seen.has(p + Vector2i.UP): col = Color("#bba17a")
			if p.x == origin + width - 1 or not seen.has(p + Vector2i.LEFT) or not seen.has(p + Vector2i.RIGHT): col = INK
		if p.x == origin + width - 4 and p.y in [40, 41]: col = Color("#e2bd72")
		img.set_pixelv(p, col)
	return img

static func _hall_door_frame(frame: int, art: Image, d: Vector2i) -> Image:
	var img := Image.create(52, 68, false, Image.FORMAT_RGBA8)
	var seen := {}
	var pending: Array[Vector2i] = [Vector2i(26, 40)]
	# Mask the coherent source arch once: never paint across its masonry or side windows.
	while not pending.is_empty():
		var p: Vector2i = pending.pop_back()
		if seen.has(p) or p.x < 0 or p.y < 0 or p.x >= 52 or p.y >= 68: continue
		var c := art.get_pixelv(d + p + Vector2i(-2, -48))
		if c.a < 0.5 or c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722 > 0.27: continue
		seen[p] = true
		for step in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]: pending.append(p + step)
	var leaf: int = [26, 13, 3][frame]
	for p in seen:
		var col := Color("#333b2f").lerp(Color("#987b46"), clampf((p.y - 43.0) / 23.0, 0.0, 1.0))
		var edge: int = mini(p.x, 51 - p.x)
		if edge < leaf:
			col = Color("#80694a") if edge % 6 != 0 else Color("#1f241e")
			if not seen.has(p + Vector2i.UP): col = LIGHT
			if edge == leaf - 1 or not seen.has(p + Vector2i.LEFT) or not seen.has(p + Vector2i.RIGHT): col = INK
			if p.y in [48, 49] and edge == leaf - 4: col = Color("#e2bd72")
		img.set_pixelv(p, col)
	return img

func _process(delta: float) -> void:
	for id in buildings:
		var b: Dictionary = buildings[id]
		var target := 1.0 if town.panel.get("id", "") == id else 0.0
		b["phase"] = move_toward(b["phase"], target, delta / 0.24)
		var frame := mini(2, int(b["phase"] * 3.0))
		if frame != b["frame"]:
			b["frame"] = frame
			b["door"].texture = b["frames"][frame]
