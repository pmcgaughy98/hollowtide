extends Node2D
## Finished service exteriors only. Layout, interactions and carried state belong to the town.
const Layout = preload("res://scripts/town/town_layout.gd")
const Finish = preload("res://scripts/town/exterior_finish.gd")
const Template = preload("res://scripts/town/building_template.gd")
const SOURCES = {
	"scrolls": "res://assets/sprites/world/scroll_cellar_2026_10_10/scroll_native.png",
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
	if id in ["lookout", "landing", "dock"]:
		return ResourceLoader.exists("res://scripts/town/landmark_exteriors.gd") and load("res://scripts/town/landmark_exteriors.gd").available(id)
	if id == "gate":
		return ResourceLoader.exists("res://scripts/town/hollow_mouth_painter.gd") and load("res://scripts/town/hollow_mouth_painter.gd").available()
	if id == "plaza":
		return ResourceLoader.exists("res://scripts/town/crossroads_painter.gd") and load("res://scripts/town/crossroads_painter.gd").available()
	if id == "board":
		return ResourceLoader.exists("res://scripts/town/job_board_painter.gd") and load("res://scripts/town/job_board_painter.gd").available()
	if id == "yard":
		return ResourceLoader.exists("res://scripts/town/training_yard_painter.gd") and load("res://scripts/town/training_yard_painter.gd").available()
	if id == "scrolls" and not ResourceLoader.exists("res://scripts/town/scroll_keeper_painter.gd"):
		return false
	if id == "shrine":
		return ResourceLoader.exists("res://scripts/town/growth_shrine_painter.gd") and load("res://scripts/town/growth_shrine_painter.gd").available()
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
	if place["id"] == "scrolls":
		art = _scroll_standing(art)   # the shadow falls from the porch where it now stands (T3)
	# A two-pixel contact band, falling bottom-right from the common top-left light.
	for y in range(1, px.size.y + 2):
		for x in range(1, px.size.x + 2):
			var src := Vector2i(clampi(x - 2, 0, px.size.x - 1), clampi(y - 2, 0, px.size.y - 1))
			if art.get_pixelv(src).a < 0.5:
				continue
			var at := px.position + Vector2i(x, y)
			var c := img.get_pixelv(at)
			img.set_pixelv(at, c.darkened(0.33 if x < px.size.x + 1 and y < px.size.y + 1 else 0.17))
	if place["id"] == "scrolls":
		var d: Vector2i = place["door"] * Layout.T
		for y in range(d.y - Layout.T, d.y):
			var half := 11 + (d.y - y) / 5
			for x in range(d.x + 12 - half, d.x + 12 + half):
				var at := Vector2i(x, y)
				var c := Color("#8f805e") if (x / 4 + y / 3) % 3 == 0 else Color("#948461")
				img.set_pixelv(at, img.get_pixelv(at).lerp(c, 0.45 if absi(x - d.x - 12) >= half - 2 else 0.9))
		return img
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
	if Layout.v2():
		show_area(Layout.area())   # Highbank v2: the building template and the art slots (Claude, 2026-10-26)
		return
	for place in Layout.PLACES:
		var id: String = place["id"]
		if not available(id):
			continue
		if id in OPEN_AIR:
			buildings[id] = _attach_open_air(id)
			continue
		var r: Rect2i = place["rect"]
		var base := Node2D.new()
		base.name = id.capitalize()
		base.position = Vector2(r.position * Layout.T)
		# The door row remains in front of the roof. No collision or sorting rule changes.
		base.z_index = r.position.y * Layout.T if id == "scrolls" else (r.end.y - 1) * Layout.T
		add_child(base)
		var sprite := Sprite2D.new()
		sprite.name = "Exterior"
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.texture = load(SOURCES[id])
		var lift := PORCH_LIFT if id == "scrolls" else 0
		if id == "scrolls":
			# The cellar porch stands on the ground at the door, off the roof (Claude, 2026-10-23, T3).
			var parts := _scroll_parts(sprite.texture.get_image())
			sprite.texture = ImageTexture.create_from_image(parts[0])
			var porch := Sprite2D.new()
			porch.name = "Porch"
			porch.centered = false
			porch.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			porch.texture = ImageTexture.create_from_image(parts[1])
			porch.position = Vector2(0, -lift)
			Finish.apply(porch, true)
			base.add_child(porch)
		Finish.apply(sprite, true)   # Shared sel-out includes purposeful internal contours.
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
		details.position = Vector2(0, -lift)   # the Scroll Keeper's landing line and sign go up with its porch
		base.add_child(details)
		var door := Sprite2D.new()
		door.name = "Door"
		door.centered = false
		door.position = Vector2(local_d + Vector2i(-2, -lift if id == "scrolls" else -48 if id == "hall" else -36))
		Finish.apply(door)
		base.add_child(door)
		var frames: Array[Texture2D] = []
		for k in 3:
			frames.append(ImageTexture.create_from_image(_door_frame(k, sprite.texture.get_image(), local_d, id)))
		door.texture = frames[0]
		buildings[id] = {"base": base, "sprite": sprite, "door": door, "frames": frames, "phase": 0.0, "frame": 0}
		if id in SHUT_IDS:
			var shut := Sprite2D.new()
			shut.name = "Shut"
			shut.centered = false
			shut.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			shut.position = door.position
			# The chain is a slot (town.prop.shut_chain) whose placeholder is _chain_image(); the boards stay cut to this
			# door's own opening in v1 (Claude, 2026-10-26, placeholder factory).
			shut.texture = ArtSlots.texture("town.prop.shut_chain") if id == "scrolls" else ImageTexture.create_from_image(_boards_image(frames[0].get_image()))
			base.add_child(shut)   # after the door, so it draws over it
	if buildings.has("yard"):
		_rope_across_yard()


## The open-air places: low pictures under the creatures, drawn by their own painters (Claude, 2026-10-26: one list
## for v1 and v2; the calls are the ones _ready made before).
const OPEN_AIR := ["lookout", "landing", "dock", "gate", "plaza", "board", "yard", "shrine"]


func _attach_open_air(id: String) -> Dictionary:
	if id in ["lookout", "landing", "dock"]:
		return load("res://scripts/town/landmark_exteriors.gd").attach(self, town, id)
	match id:
		"gate":
			return load("res://scripts/town/hollow_mouth_painter.gd").attach(self, town)
		"plaza":
			return load("res://scripts/town/crossroads_painter.gd").attach(self, town)
		"board":
			return load("res://scripts/town/job_board_painter.gd").attach(self, town)
		"yard":
			return load("res://scripts/town/training_yard_painter.gd").attach(self, town)
		"shrine":
			return load("res://scripts/town/growth_shrine_painter.gd").attach(self, town)
	return {}


## Highbank v2 (Claude, 2026-10-26, placeholder factory lane B): the area's buildings and lots stand on its grid through
## the building template, each drawn from its art slot (BuildingTemplate.place); the shut overlays are slots; the
## open-air places the area lists are drawn by their painters at the rects the area gives them. Lane A calls this
## again with the new area after enter_area, so one node serves every street area.
func show_area(area: Dictionary) -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	buildings.clear()
	for b in area.get("buildings", []):
		var node: Node2D = Template.place(b, self)
		if node == null:
			continue
		var id := String(b.get("id", ""))
		var frames: Array = node.get_meta("frames", [])
		buildings[id] = {"base": node, "sprite": node.get_node_or_null("Exterior"), "door": node.get_node_or_null("Door"),
			"frames": frames, "phase": 0.0, "frame": 0}
		if frames.is_empty():
			buildings[id]["landmark"] = true   # a stall: no door to swing
		if id in SHUT_IDS:
			_shut_over(node, id)
	# A lot shows its before state until the team's record opens it (TownLayout.lot_open, lane A's rule).
	var rec: Dictionary = town.call("_record") if is_instance_valid(town) and town.has_method("_record") else {}
	for lot in area.get("lots", []):
		var entry: Dictionary = lot
		if lot.has("building") and Layout.lot_open(lot, rec):
			entry = lot.duplicate()
			entry["open"] = true
		var node: Node2D = Template.place(entry, self)
		if node != null:
			buildings[String(lot.get("id", ""))] = {"base": node, "landmark": true}
	var listed := {}
	for p in area.get("places", []):
		if String(p.get("kind", "")) != "building":
			listed[String(p.get("id", ""))] = true
	for id in OPEN_AIR:
		if listed.has(id) and not buildings.has(id) and available(id):
			buildings[id] = _attach_open_air(id)
	if buildings.has("yard"):
		_rope_across_yard()


## A v2 shut door: the boards slot over a single door, the chain slot across the Scroll Keeper's.
func _shut_over(node: Node2D, id: String) -> void:
	var door: Rect2i = node.get_meta("door_px", Rect2i())
	if door.size.x <= 0:
		return
	var shut := Sprite2D.new()
	shut.name = "Shut"
	shut.centered = false
	shut.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if id == "scrolls":
		shut.texture = ArtSlots.texture("town.prop.shut_chain")
		shut.position = Vector2(door.position + Vector2i((door.size.x - 28) / 2, door.size.y / 2 - 22))
	else:
		shut.texture = ArtSlots.texture("town.prop.shut_boards")
		shut.position = Vector2(door.position - Vector2i(2, 2))
	node.add_child(shut)   # after the door, so it draws over it


## The Scroll Keeper's cellar porch (Claude, 2026-10-23, T3 / L23). Its source art draws the porch, lanterns, crates
## and purple banners against the top of the mossy roof, so from the street it read as a market stall up on the
## roof. The porch is cut from the roof along the foot of its stone ledge and drawn PORCH_LIFT px higher, standing
## on the ground at the door with a strip of grass between it and the roof; the cellar lid, its chain and the sign
## go up with it. The roof's ridge beam stays with the roof. The source PNG is not changed. The other signs (Hall,
## Item Shop, Storage) stand at their own doors and were checked in the same render.
const PORCH_LIFT := 12


## How many rows from the top of column `x` of the Scroll Keeper's art belong to the porch (0: none). The cut
## slants up at both ends, so the roof's side frames keep their posts and the grass between reads as ground, not
## a square hole in the roof.
static func _porch_rows(x: int) -> int:
	if x < 30 or x >= 112:
		return 0
	if x >= 64 and x < 78:
		return 30   # the ridge beam's end stays with the roof
	if x < 40:
		return 26 + (x - 30) * 14 / 10
	if x >= 102:
		return 26 + (111 - x) * 14 / 10
	return 40


## [roof, porch]: the Scroll Keeper's art split along the porch's ledge, each at full size with the other cleared.
static func _scroll_parts(art: Image) -> Array:
	var roof: Image = art.duplicate()
	if roof.is_compressed():
		roof.decompress()
	roof.convert(Image.FORMAT_RGBA8)
	var porch := Image.create(roof.get_width(), roof.get_height(), false, Image.FORMAT_RGBA8)
	for x in roof.get_width():
		for y in mini(_porch_rows(x), roof.get_height()):
			porch.set_pixel(x, y, roof.get_pixel(x, y))
			roof.set_pixel(x, y, Color(0, 0, 0, 0))
	return [roof, porch]


## The Scroll Keeper as it stands: the roof, and the porch PORCH_LIFT px up (rows lifted past the top are cut off).
static func _scroll_standing(art: Image) -> Image:
	var parts := _scroll_parts(art)
	var out: Image = parts[0]
	out.blend_rect(parts[1], Rect2i(0, PORCH_LIFT, out.get_width(), out.get_height() - PORCH_LIFT), Vector2i.ZERO)
	return out


## Shut for this build (Claude, 2026-10-22, GS-12; Preston's call 9, default shut signs): boards nailed
## across the Item Shop's door, a chain and padlock on the Scroll Keeper's cellar lid, a rope across the
## Training Yard's gate. The town's sign says why (hub_town.gd SHUT). Their doors never swing open.
const SHUT_IDS := ["shop", "scrolls", "yard"]
const WOOD := Color("#80694a")
const WOOD_LIT := Color("#bba17a")
const CARD := Color("#e3c89a")
const SCRAWL := Color("#8c7a5a")
const IRON := Color("#48473c")
const IRON_LIT := Color("#8a8778")
const BRASS := Color("#d0ac68")
const HEMP := Color("#c9b98a")


## Two planks across the door's opening (its frame-0 shape), the lower one a pixel off level as if
## nailed by hand, and a card tucked between them.
static func _boards_image(opening: Image) -> Image:
	var img := Image.create(opening.get_width(), opening.get_height(), false, Image.FORMAT_RGBA8)
	var u := opening.get_used_rect()
	if u.size.x < 6 or u.size.y < 12:
		u = Rect2i(4, 24, 20, 30)   # no opening found: the usual arch
	var x0 := maxi(0, u.position.x - 2)
	var x1 := mini(img.get_width(), u.end.x + 2)
	for k in 2:
		var y := u.position.y + int(u.size.y * (0.3 if k == 0 else 0.64)) - 2
		for half in 2:
			var a := x0 if half == 0 else (x0 + x1) / 2
			var b := (x0 + x1) / 2 if half == 0 else x1
			var dy := 1 if k == 1 and half == 1 else 0
			img.fill_rect(Rect2i(a, y + dy, b - a, 5), INK)
			img.fill_rect(Rect2i(a + (1 if half == 0 else 0), y + dy + 1, b - a - 1, 3), WOOD)
			img.fill_rect(Rect2i(a + (1 if half == 0 else 0), y + dy + 1, b - a - 1, 1), WOOD_LIT)
		img.set_pixel(x0 + 2, y + 2, INK)   # nails
		img.set_pixel(x1 - 3, y + 2 + (1 if k == 1 else 0), INK)
	var cx := u.position.x + u.size.x / 2 - 4
	var cy := u.position.y + int(u.size.y * 0.3) + 5
	img.fill_rect(Rect2i(cx, cy, 9, 8), INK)
	img.fill_rect(Rect2i(cx + 1, cy + 1, 7, 6), CARD)
	img.fill_rect(Rect2i(cx + 2, cy + 2, 5, 1), SCRAWL)
	img.fill_rect(Rect2i(cx + 2, cy + 4, 3, 1), SCRAWL)
	return img


## A chain across the shut cellar lid (_scroll_door_frame's frame 0: x 10 to 20, y 15 to 29) and a
## brass padlock on it.
static func _chain_image() -> Image:
	var img := Image.create(28, 36, false, Image.FORMAT_RGBA8)
	for x in range(7, 24):
		var lit := (x / 2) % 2 == 0
		img.set_pixel(x, 21, IRON_LIT if lit else IRON)
		img.set_pixel(x, 22, IRON if lit else INK)
	img.fill_rect(Rect2i(14, 21, 4, 2), INK)   # the shackle
	img.set_pixel(15, 22, Color(0, 0, 0, 0))
	img.set_pixel(16, 22, Color(0, 0, 0, 0))
	img.fill_rect(Rect2i(13, 23, 6, 5), INK)
	img.fill_rect(Rect2i(14, 24, 4, 3), BRASS)
	img.set_pixel(15, 25, INK)   # the keyhole
	return img


## Two stakes either side of the Yard's gate tile and a rope sagging between them, with a board hung off
## it. Sorted with the creatures by its foot, so one standing on the gate reads as stopped at the rope.
func _rope_across_yard() -> void:
	var yard: Dictionary = Template.place_entry("yard")
	var rope := Sprite2D.new()
	rope.name = "YardRope"
	rope.centered = false
	rope.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rope.texture = ArtSlots.texture("town.prop.shut_rope")   # placeholder: rope_image(), today's rope
	var at: Vector2i = yard["door"] * Layout.T + Vector2i(-3, 6)
	rope.position = Vector2(at)
	rope.z_index = at.y + 14   # its foot: in front of a creature on the gate tile, behind one below it
	add_child(rope)


## The rope across the Yard's gate: two stakes and a sagging hemp rope with a board hung off it (30 x 20).
static func rope_image() -> Image:
	var w := Layout.T + 6
	var img := Image.create(w, 20, false, Image.FORMAT_RGBA8)
	for sx in [0, w - 3]:
		img.fill_rect(Rect2i(sx, 1, 3, 14), INK)
		img.fill_rect(Rect2i(sx + 1, 2, 1, 12), WOOD)
		img.set_pixel(sx + 1, 2, WOOD_LIT)
	var mid := (w - 1) * 0.5
	for x in range(3, w - 3):
		var sag := 4.0 * (1.0 - pow((x - mid) / (mid - 3.0), 2.0))
		var y := 4 + int(round(sag))
		img.set_pixel(x, y, HEMP)
		img.set_pixel(x, y + 1, INK)
	var bx := int(mid) - 4
	img.set_pixel(int(mid), 9, INK)   # the cord
	img.fill_rect(Rect2i(bx, 10, 9, 7), INK)
	img.fill_rect(Rect2i(bx + 1, 11, 7, 5), Color("#9b855c"))
	img.fill_rect(Rect2i(bx + 2, 12, 5, 1), SCRAWL)
	img.fill_rect(Rect2i(bx + 2, 14, 4, 1), SCRAWL)
	return img


## Placeholders for lane B's sign and shut overlay slots (Claude, 2026-10-26, placeholder factory): today's coded
## pictogram boards, planks, chain and rope at each slot's exact size, so a placeholder looks as the town does now.
## Each row in scripts/art/slots/town_buildings.gd names its function here.
const SIGN_ICONS := {"sign_hall": "waymark", "sign_shop": "bag", "sign_storage": "crate", "sign_scrolls": "scroll", "sign_yard": "staves"}
const SIGN_POST_TOP := {"bag": 11, "crate": 13, "waymark": 13, "scroll": 15, "staves": 13}


static func slot_sign(id: String, _spec: Dictionary) -> Image:
	var img := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	var icon: String = SIGN_ICONS.get(id.get_slice(".", 2), "")
	sign_board(img, Vector2i(2, 1), icon, 23 - int(SIGN_POST_TOP.get(icon, 13)))   # the post reaches the foot row
	return img


static func slot_shut_boards(_id: String, _spec: Dictionary) -> Image:
	var opening := Image.create(26, 50, false, Image.FORMAT_RGBA8)
	opening.fill_rect(Rect2i(3, 2, 20, 47), INK)   # a 22 x 48 door, less the planks' 1 px reach past each jamb
	return _boards_image(opening)


static func slot_shut_chain(_id: String, _spec: Dictionary) -> Image:
	return _chain_image()


static func slot_shut_rope(_id: String, _spec: Dictionary) -> Image:
	return rope_image()


## A sign board at p with its pictogram, on a post; post < 0 keeps each board's v1 post length. The pictograms are
## the ones _details and _scroll_details drew (moved here unchanged), plus the Yard's crossed staves (a proposal).
static func sign_board(img: Image, p: Vector2i, icon: String, post: int = -1) -> void:
	match icon:
		"bag":
			img.fill_rect(Rect2i(p + Vector2i(8, 11), Vector2i(2, 16 if post < 0 else post)), INK)
			img.fill_rect(Rect2i(p, Vector2i(19, 16)), INK)
			img.fill_rect(Rect2i(p + Vector2i(1, 1), Vector2i(17, 14)), Color("#9b855c"))
			img.fill_rect(Rect2i(p + Vector2i(2, 2), Vector2i(15, 12)), Color("#665e44"))
			# Original bag pictogram: tied neck, broad satchel and gold clasp.
			img.fill_rect(Rect2i(p + Vector2i(6, 5), Vector2i(7, 8)), LIGHT)
			img.fill_rect(Rect2i(p + Vector2i(7, 3), Vector2i(5, 3)), LIGHT)
			img.fill_rect(Rect2i(p + Vector2i(5, 8), Vector2i(9, 4)), LIGHT)
			img.fill_rect(Rect2i(p + Vector2i(7, 6), Vector2i(5, 1)), INK)
			img.set_pixelv(p + Vector2i(9, 8), Color("#e2bd72"))
		"crate":
			img.fill_rect(Rect2i(p + Vector2i(8, 13), Vector2i(2, 17 if post < 0 else post)), INK)
			img.fill_rect(Rect2i(p, Vector2i(19, 17)), INK)
			img.fill_rect(Rect2i(p + Vector2i(1, 1), Vector2i(17, 15)), LIGHT)
			img.fill_rect(Rect2i(p + Vector2i(2, 2), Vector2i(15, 13)), Color("#665e44"))
			# Crate pictogram: an outlined box with two diagonal braces.
			img.fill_rect(Rect2i(p + Vector2i(4, 4), Vector2i(11, 10)), INK)
			img.fill_rect(Rect2i(p + Vector2i(5, 5), Vector2i(9, 8)), Color("#ab9265"))
			for y in 7:
				img.set_pixelv(p + Vector2i(5 + y, 5 + y), LIGHT)
				img.set_pixelv(p + Vector2i(13 - y, 5 + y), LIGHT)
		"waymark":
			img.fill_rect(Rect2i(p + Vector2i(8, 13), Vector2i(2, 22 if post < 0 else post)), INK)
			img.fill_rect(Rect2i(p, Vector2i(19, 19)), INK)
			img.fill_rect(Rect2i(p + Vector2i(1, 1), Vector2i(17, 17)), LIGHT)
			img.fill_rect(Rect2i(p + Vector2i(2, 2), Vector2i(15, 15)), Color("#49563d"))
			# Original waymark pictogram: three routes meeting at one point (visual proposal).
			for y in 5:
				img.fill_rect(Rect2i(p + Vector2i(4 + y, 5 + y), Vector2i(2, 2)), Color("#e2bd72"))
				img.fill_rect(Rect2i(p + Vector2i(13 - y, 5 + y), Vector2i(2, 2)), Color("#e2bd72"))
			img.fill_rect(Rect2i(p + Vector2i(9, 9), Vector2i(2, 6)), Color("#e2bd72"))
		"scroll":
			img.fill_rect(Rect2i(p + Vector2i(8, 15), Vector2i(2, 17 if post < 0 else post)), INK)
			img.fill_rect(Rect2i(p, Vector2i(19, 17)), INK)
			img.fill_rect(Rect2i(p + Vector2i(1, 1), Vector2i(17, 15)), LIGHT)
			img.fill_rect(Rect2i(p + Vector2i(2, 2), Vector2i(15, 13)), Color("#665e44"))
			# Original rolled parchment pictogram; no text or borrowed artwork.
			img.fill_rect(Rect2i(p + Vector2i(5, 4), Vector2i(9, 10)), INK)
			img.fill_rect(Rect2i(p + Vector2i(6, 5), Vector2i(7, 8)), Color("#e3c89a"))
			img.fill_rect(Rect2i(p + Vector2i(4, 4), Vector2i(10, 2)), LIGHT)
			img.fill_rect(Rect2i(p + Vector2i(5, 12), Vector2i(10, 2)), LIGHT)
			img.fill_rect(Rect2i(p + Vector2i(8, 8), Vector2i(3, 1)), Color("#8c7897"))
		"staves":
			img.fill_rect(Rect2i(p + Vector2i(8, 13), Vector2i(2, 17 if post < 0 else post)), INK)
			img.fill_rect(Rect2i(p, Vector2i(19, 17)), INK)
			img.fill_rect(Rect2i(p + Vector2i(1, 1), Vector2i(17, 15)), LIGHT)
			img.fill_rect(Rect2i(p + Vector2i(2, 2), Vector2i(15, 13)), Color("#665e44"))
			# Two crossed sparring staves, their ends bound (a proposal for the Training Yard).
			for k in 9:
				img.fill_rect(Rect2i(p + Vector2i(5 + k, 4 + k), Vector2i(2, 1)), WOOD_LIT)
				img.fill_rect(Rect2i(p + Vector2i(12 - k, 4 + k), Vector2i(2, 1)), WOOD_LIT)
			for e in [Vector2i(4, 3), Vector2i(13, 3), Vector2i(4, 12), Vector2i(13, 12)]:
				img.fill_rect(Rect2i(p + e, Vector2i(2, 2)), INK)

static func _details(size: Vector2i, d: Vector2i, id: String, entrance_width: int = 24) -> Image:
	if id == "scrolls": return _scroll_details(size, d)
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
		sign_board(img, d + Vector2i(31, -6), "bag")
	if id == "storage":
		sign_board(img, d + Vector2i(31, -6), "crate")
	if id == "hall":
		sign_board(img, d + Vector2i(entrance_width + 10, -25), "waymark")
	return img

static func _door_frame(frame: int, art: Image, d: Vector2i, id: String) -> Image:
	if id == "scrolls": return _scroll_door_frame(frame, art, d)
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

static func _scroll_details(size: Vector2i, d: Vector2i) -> Image:
	var img := Image.create(size.x, size.y + 1, false, Image.FORMAT_RGBA8)
	# North landing meets the recessed stairs. Never draw a sill across the stairwell.
	img.fill_rect(Rect2i(d + Vector2i(7, 13), Vector2i(13, 1)), LIGHT)
	sign_board(img, d + Vector2i(-25, 1), "scroll")
	return img

static func _scroll_door_frame(frame: int, _art: Image, _d: Vector2i) -> Image:
	var img := Image.create(28, 36, false, Image.FORMAT_RGBA8)
	# The source contains the complete descending stairwell. Its lid hinges at the
	# south edge, then folds back toward the roof, exposing the original treads.
	var top: int = [15, 23, 31][frame]
	var depth: int = [15, 7, 4][frame]
	for y in range(top, top + depth):
		for x in range(10, 21):
			var c := Color("#80694a") if (x - 10) % 4 != 0 else Color("#28251f")
			if y == top: c = LIGHT
			if x in [10, 20] or y == top + depth - 1: c = INK
			img.set_pixel(x, y, c)
	# Iron cross-straps, hinges and a ring pull remain attached to the same lid.
	if depth > 4:
		for y in [top + 3, top + depth - 3]:
			img.fill_rect(Rect2i(11, y, 9, 1), Color("#333631"))
		img.fill_rect(Rect2i(14, top + 1, 3, 2), Color("#d0ac68"))
		img.set_pixel(15, top + 1, INK)
	for x in [12, 19]: img.fill_rect(Rect2i(x, 30, 2, 2), Color("#48473c"))
	return img

func _process(delta: float) -> void:
	for id in buildings:
		var b: Dictionary = buildings[id]
		if b.get("landmark", false): continue   # Open-air props have no door animation.
		if id == "gate": continue   # Static recess; stepping in is owned by town entry.
		if id == "plaza":
			load("res://scripts/town/crossroads_painter.gd").update(b, town, delta)
			continue
		if id == "board":
			load("res://scripts/town/job_board_painter.gd").update(b, town, delta)
			continue
		if id == "yard":
			load("res://scripts/town/training_yard_painter.gd").update(b, town, delta)
			continue
		if id == "shrine":
			load("res://scripts/town/growth_shrine_painter.gd").update(b, town, delta)
			continue
		var target := 1.0 if town.panel.get("id", "") == id and not id in SHUT_IDS else 0.0
		b["phase"] = move_toward(b["phase"], target, delta / 0.24)
		var frame := mini(2, int(b["phase"] * 3.0))
		if frame != b["frame"]:
			b["frame"] = frame
			b["door"].texture = b["frames"][frame]
