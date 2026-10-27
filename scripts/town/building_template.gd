class_name BuildingTemplate
extends RefCounted
## The building template (Claude, 2026-10-26, placeholder factory lane B; 02-town-rewire-design.md section 4). Every
## street building is one class, sized from the creatures so its door clears them. Highbank v2 draws each building
## through its art slot, ArtSlots.texture("town.building.<id>"): Codex's file when one is installed at exactly the
## class canvas, else the coded placeholder painted here from data (roof, wall, door opening, windows, chimney,
## awning). place() stands a building on an area's grid with the parts the game draws itself: a contact shadow, the
## foundation stones and doorstep, the sign (its own slot), the door's three swing frames (cut from door_px, no flood
## fill) and the before state of a lot. v1, today's town, is drawn by building_exteriors.gd and never calls this file,
## so with Highbank v2 off nothing here changes a screen.
##
## The Wayline Tower (canon, Preston 2026-10-26) is the "hall" class: the Hall's 12 x 3 base, double door and room
## entrance, rising 576 px (2.67 screens of the 384 x 216 view) to a signal lantern on a beacon mast. Its numbers are
## the TOWER_* consts below; tower_points() gives a scene the door and the beacon in area px to pan a camera between.

const Layout := preload("res://scripts/town/town_layout.gd")
const Finish := preload("res://scripts/town/exterior_finish.gd")
const PP := preload("res://scripts/art/placeholder_painter.gd")

const T := 24
const EAVE := 6               # px of eave each side, over the neighbouring tiles without collision (02 section 4.1)
const VIEW_H := 216           # the town view's height, for "screens tall"
const BUILDING_SCALE := 1.0   # Preston call 1: 1.0 by default; 1.25 resizes every canvas before the lists go out
const SCALES := [1.0, 1.25]   # what scenes/debug/building_lineup.tscn shows side by side
## base in tiles, canvas and door opening in px (02 section 4.2); wall and roof are the px heights BUILDING_SCALE
## multiplies; door_col is the base column of the (left) door tile. The hall class is the Wayline Tower (canon,
## Preston 2026-10-26): the same 12 x 3 base and doors, rising 576 px to a beacon; its double door is 48 px wide so
## Galeshear (63 px wide, 62 tall, measured from its town/s.png) passes check C11.
const CLASSES := {
	"cottage": {"base": Vector2i(5, 2), "canvas": Vector2i(132, 144), "door_px": Rect2i(55, 94, 22, 48), "pass_creature": "sparkjab",
		"wall": 60, "roof": 36, "door_col": 2, "door_tiles": 1},
	"shop": {"base": Vector2i(6, 2), "canvas": Vector2i(156, 144), "door_px": Rect2i(55, 94, 22, 48), "pass_creature": "sparkjab",
		"wall": 60, "roof": 36, "door_col": 2, "door_tiles": 1},
	"stall": {"base": Vector2i(4, 2), "canvas": Vector2i(108, 120), "door_px": Rect2i(), "pass_creature": "",
		"wall": 36, "roof": 36, "door_col": -1, "door_tiles": 0},
	"hall": {"base": Vector2i(12, 3), "canvas": Vector2i(300, 576), "door_px": Rect2i(126, 510, 48, 64), "pass_creature": "galeshear",
		"wall": 80, "roof": 40, "door_col": 5, "door_tiles": 2, "tower": true},
}

## The Wayline Tower, for the lanes that frame it (the story scene at its foot pans a camera up it; the road home
## shows it far off). Canvas px at BUILDING_SCALE 1.0; the foot is the anchor, the bottom centre on the base's last row.
const TOWER_CLASS := "hall"
const TOWER_SLOT := "town.building.hall"
const TOWER_CANVAS := Vector2i(300, 576)        # 12 tiles + eaves wide, 24 tiles tall
const TOWER_DOOR := Rect2i(126, 510, 48, 64)     # the double door, over base columns 5 and 6
const TOWER_DOOR_COLS := [5, 6]
const TOWER_FOOT := Vector2i(150, 575)
const TOWER_TOP := Vector2i(150, 8)              # the beacon light: where a pan up the Tower ends
## The placeholder's stages, top to bottom, so Codex sees the shape it repaints (canvas px at 1.0).
const TOWER_STAGES := {
	"mast": Rect2i(146, 2, 9, 28),       # the beacon mast, its courier pennant and the signal light at TOWER_TOP
	"cap": Rect2i(114, 30, 72, 26),      # the lantern's roof cap
	"lantern": Rect2i(120, 56, 60, 48),  # the signal lantern room
	"gallery": Rect2i(84, 104, 132, 16), # the lamp gallery's ledge and rail
	"shaft": Rect2i(96, 120, 108, 326),  # the shaft, standing on the terrace; a lit window on every floor
	"base": Rect2i(6, 422, 288, 154),    # the wide base: its terrace roof, and the front wall with the double door
}

const INK := Color("#0b0e11")
const STONE := Color("#8f805e")
const LIGHT := Color("#bea986")
const GRASS := Color("#53673e")
const MOSS := Color("#5f6f45")
const CLAY := Color("#8c5a3c")
const PLUM := Color("#5e4a66")
const AWNING := Color("#a8553f")
const TARP := Color("#c9b98a")
const DOOR_WOOD := Color("#80694a")
const DOOR_SEAM := Color("#1f241e")
const HANDLE := Color("#e2bd72")

## Each building slot's look (02 section 3.3 fields: roof, wall, windows as base columns, chimney column, awning,
## shutters, and the sign beside the door). An area's building entry may name its own sign; the rest is the slot's.
## "_<class>" rows are the defaults for a building with no row of its own.
const STYLES := {
	"home": {"roof": "moss", "wall": "stone", "windows": [0, 4], "chimney": 3},
	"shop": {"roof": "gable", "wall": "plank", "windows": [0, 5], "awning": true, "sign": {"col": 3, "icon": "bag"}},
	"storage": {"roof": "hip", "wall": "timber", "windows": [0, 5], "sign": {"col": 3, "icon": "crate"}},
	"scrolls": {"roof": "gable", "wall": "timber", "windows": [0, 5], "tint": "plum", "sign": {"col": 3, "icon": "scroll"}},
	"hall": {"roof": "tower", "wall": "river_stone", "windows": [1, 3, 10], "sign": {"col": 8, "icon": "waymark"}},
	"lot_before_shop": {"roof": "gable", "wall": "plank", "windows": [0, 5], "shutters": true},
	"lot_before_stall": {"tarp": true},
	"_cottage": {"roof": "moss", "wall": "stone", "windows": [0, 4]},
	"_shop": {"roof": "gable", "wall": "plank", "windows": [0, 5]},
	"_stall": {},
	"_hall": {"roof": "tower", "wall": "river_stone", "windows": [1, 3, 10]},
}
## A sign's pictogram -> its slot (the five sign slots in scripts/art/slots/town_buildings.gd).
const SIGN_SLOTS := {"waymark": "town.prop.sign_hall", "bag": "town.prop.sign_shop", "crate": "town.prop.sign_storage",
	"scroll": "town.prop.sign_scrolls", "staves": "town.prop.sign_yard"}
## A lot's before state -> its slot (02 section 3.6).
const BEFORE_SLOTS := {"tarp": "town.building.lot_before_stall", "shutters": "town.building.lot_before_shop",
	"plot": "town.landmark.lot_before_plot"}


# ---------------------------------------------------------------------------------------------------------------------
# Sizes

## A class's sizes at a scale: canvas, door_px, anchor (bottom centre), base tiles. At 1.0 these are the CLASSES table;
## at 1.25 wall, roof and door grow and the base stays on its tiles. {} for an unknown class.
static func geometry(cls: String, s: float = BUILDING_SCALE) -> Dictionary:
	if not CLASSES.has(cls):
		return {}
	var c: Dictionary = CLASSES[cls]
	var base: Vector2i = c["base"]
	var w := base.x * T + 2 * EAVE
	var h := roundi(TOWER_CANVAS.y * s) if c.get("tower", false) else base.y * T + roundi((int(c["wall"]) + int(c["roof"])) * s)
	var door := Rect2i()
	var tiles := int(c["door_tiles"])
	if tiles > 0:
		var shape: Rect2i = c["door_px"]
		var dw := roundi(shape.size.x * s)
		var dh := roundi(shape.size.y * s)
		var mid := EAVE + int(c["door_col"]) * T + tiles * T / 2
		door = Rect2i(mid - dw / 2, h - 2 - dh, dw, dh)
	return {"class": cls, "base": base, "canvas": Vector2i(w, h), "door_px": door, "anchor": Vector2i(w / 2, h - 1),
		"door_col": int(c["door_col"]), "door_tiles": tiles, "pass_creature": String(c["pass_creature"]), "scale": s}


## A class's canvas in px at BUILDING_SCALE (Vector2i.ZERO for an unknown class).
static func canvas(cls: String) -> Vector2i:
	return geometry(cls).get("canvas", Vector2i.ZERO)


## A class's door opening inside its canvas at BUILDING_SCALE (an empty Rect2i for a stall or an unknown class).
static func door_px(cls: String) -> Rect2i:
	return geometry(cls).get("door_px", Rect2i())


## Where a class's canvas sits in an area (px): its eaves hang EAVE px over each side of the base and its foot row is
## the base's last row, so everything above the base (roof, the Tower's shaft) rises over the tiles behind it.
static func canvas_origin(cls: String, base: Rect2i, s: float = BUILDING_SCALE) -> Vector2i:
	var size: Vector2i = geometry(cls, s).get("canvas", Vector2i.ZERO)
	return Vector2i(base.position.x * T - EAVE, base.end.y * T - size.y)


## A place's entry (its "rect" and "door" tiles) in the area showing now. With Highbank v2 off it is v1's PLACES row
## itself, so the open-air painters that read it draw exactly where they did; with v2 on it is the row of the area
## that holds the place (its "places", or a building's or lot's base as the rect). {} when no area has it.
static func place_entry(id: String) -> Dictionary:
	if Layout.v2():
		var area := Layout.area(Layout.area_of(id))
		for key in ["places", "buildings", "lots"]:
			for p in area.get(key, []):
				if String(p.get("id", "")) != id:
					continue
				if p.has("rect"):
					return p
				var q: Dictionary = p.duplicate()
				q["rect"] = p.get("base", Rect2i())
				var doors: Variant = p.get("door", [])
				if doors is Array and not (doors as Array).is_empty():
					q["door"] = doors[0]
					q["door_tiles"] = doors
				return q
	for p in Layout.PLACES:
		if p["id"] == id:
			return p
	return {}


## The Tower in area px for a building whose base is `base` (tiles): its canvas origin and size, the middle of its
## door, its foot, and the beacon at its top. A camera panning up the Tower runs from "door" to "top".
static func tower_points(base: Rect2i, s: float = BUILDING_SCALE) -> Dictionary:
	var g := geometry(TOWER_CLASS, s)
	var size: Vector2i = g["canvas"]
	var o := canvas_origin(TOWER_CLASS, base, s)
	var door: Rect2i = g["door_px"]
	var anchor: Vector2i = g["anchor"]
	var top := Vector2(o.x + TOWER_TOP.x, o.y + _ty(TOWER_TOP.y, size.y, s))
	return {"origin": o, "canvas": size, "door": Vector2(o) + Vector2(door.get_center()), "foot": Vector2(o + anchor),
		"top": top, "height": size.y, "screens": float(size.y) / VIEW_H}


# ---------------------------------------------------------------------------------------------------------------------
# The coded placeholder

## The placeholder for a building slot (its row names this as "placeholder"): the class's shell from data at the row's
## size and door. The game draws the sign, doorstep, door leaves and shut overlays over it (place()), so Codex's
## repaint leaves them out too. Falls back to the shared kind painter for a row it cannot read.
static func paint_slot(id: String, spec: Dictionary) -> Image:
	var size: Vector2i = spec.get("size", Vector2i.ZERO)
	var cls := String(spec.get("building_class", ""))
	if size.x <= 0 or size.y <= 0 or not CLASSES.has(cls):
		return PlaceholderPainter.by_kind(id, spec)
	var s := _scale_of(cls, size)
	# A lot's shuttered shopfront has no door of its own in its row: its boards go over the class's door.
	var door: Rect2i = spec.get("door_px", geometry(cls, s).get("door_px", Rect2i()))
	var cell := _shell(cls, id.get_slice(".", id.get_slice_count(".") - 1), size, door, s)
	var want: Vector2i = spec.get("sheet_size", size)
	if want == size:
		return cell
	var sheet := Image.create(want.x, want.y, false, Image.FORMAT_RGBA8)
	for y in range(0, want.y - size.y + 1, size.y):
		for x in range(0, want.x - size.x + 1, size.x):
			sheet.blit_rect(cell, Rect2i(Vector2i.ZERO, size), Vector2i(x, y))
	return sheet


## The template picture of a class at any scale (the lineup's 1.25 row, or a lot whose building has no slot yet).
static func template_image(cls: String, name: String, s: float = BUILDING_SCALE) -> Image:
	var g := geometry(cls, s)
	if g.is_empty():
		return Image.create(1, 1, false, Image.FORMAT_RGBA8)
	return _shell(cls, name, g["canvas"], g["door_px"], s)


## The scale a canvas was drawn at, read back from its height.
static func _scale_of(cls: String, size: Vector2i) -> float:
	var c: Dictionary = CLASSES[cls]
	if c.get("tower", false):
		return float(size.y) / TOWER_CANVAS.y
	var base: Vector2i = c["base"]
	return float(size.y - base.y * T) / float(int(c["wall"]) + int(c["roof"]))


## A building's look: its STYLES row, then what its v2 area entry says (roof, wall, windows, chimney, awning), so the
## placeholder Codex repaints matches the map lane A drew. Read from the area files whether or not v2 is on, so a
## slot's placeholder never depends on the switch.
static func _style(cls: String, name: String) -> Dictionary:
	var out: Dictionary = (STYLES.get(name, STYLES.get("_" + cls, {})) as Dictionary).duplicate(true)
	var entry := _area_entry(name)
	for k in ["roof", "wall", "windows", "chimney", "awning"]:
		if entry.has(k):
			out[k] = entry[k]
	return out


## The v2 area entry (a building or a lot) with this id, from scripts/world/areas/index.gd; {} when none has it.
static func _area_entry(id: String) -> Dictionary:
	var index_path := "res://scripts/world/areas/index.gd"
	if not ResourceLoader.exists(index_path):
		return {}
	var index: Script = load(index_path)
	var areas: Dictionary = index.get_script_constant_map().get("V2", {})
	for area_id in areas:
		var area: Dictionary = (areas[area_id] as Script).get_script_constant_map().get("AREA", {})
		for key in ["buildings", "lots"]:
			for b in area.get(key, []):
				if String(b.get("id", "")) == id:
					return b
	return {}


static func _shell(cls: String, name: String, size: Vector2i, door: Rect2i, s: float) -> Image:
	var img := Image.create(maxi(1, size.x), maxi(1, size.y), false, Image.FORMAT_RGBA8)
	var style := _style(cls, name)
	match cls:
		"hall":
			_tower(img, door, s, style)
		"stall":
			_stall(img, style, s)
		_:
			_house(img, door, style, s)
	return img


## Cottage and shop: roof over the footprint, the wall, the door opening, windows, chimney, awning, shutters.
static func _house(img: Image, door: Rect2i, style: Dictionary, s: float) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var wall_top := door.position.y - roundi(12 * s) if door.size.y > 0 else h - roundi(60 * s)
	var roof := MOSS
	match String(style.get("roof", "gable")):
		"gable":
			roof = PLUM if String(style.get("tint", "")) == "plum" else CLAY
		"hip", "flat":
			roof = PP.SLATE
	if style.has("chimney"):
		var cx := EAVE + int(style["chimney"]) * T + 6
		PP.block(img, Rect2i(cx, 2, 10, roundi(24 * s)), STONE)
	_roof(img, Rect2i(1, 1, w - 2, wall_top - 1), String(style.get("roof", "gable")), roof, s)
	_wall(img, Rect2i(EAVE, wall_top, w - 2 * EAVE, h - wall_top), String(style.get("wall", "stone")))
	_rect(img, Rect2i(EAVE - 2, wall_top, w - 2 * EAVE + 4, 1), INK)   # the drip line under the eave
	var shut := bool(style.get("shutters", false))
	for col in style.get("windows", []):
		_window(img, Rect2i(EAVE + int(col) * T + 5, wall_top + roundi(14 * s), 14, roundi(13 * s)), shut)
	if door.size.x > 0:
		_door_opening(img, door)
		if shut:
			for y in range(door.position.y + 4, door.end.y - 4, 10):
				_rect(img, Rect2i(door.position.x - 2, y, door.size.x + 4, 5), INK)
				_rect(img, Rect2i(door.position.x - 1, y + 1, door.size.x + 2, 3), PP.WOOD_LIT)
	if bool(style.get("awning", false)):
		var a := Rect2i(EAVE + 3, wall_top + 2, w - 2 * EAVE - 6, roundi(8 * s))
		var cloth := PP.ramp(AWNING)
		for x in range(a.position.x, a.end.x):
			var c: Color = cloth[1] if ((x - a.position.x) / 6) % 2 == 0 else PP.PARCHMENT
			_rect(img, Rect2i(x, a.position.y, 1, a.size.y), c)
			if (x - a.position.x) % 6 in [2, 3]:
				_rect(img, Rect2i(x, a.end.y, 1, 1), c)   # the scalloped hem
		_rect(img, Rect2i(a.position.x, a.position.y - 1, a.size.x, 1), INK)
		_rect(img, Rect2i(a.position.x - 1, a.position.y, 1, a.size.y), INK)
		_rect(img, Rect2i(a.end.x, a.position.y, 1, a.size.y), INK)


## A roof over `r`: moss (a rounded mound), gable, hip, flat or awning, shingle rows, lit along its top.
static func _roof(img: Image, r: Rect2i, kind: String, base: Color, s: float) -> void:
	var rp := PP.ramp(base)
	var top_inset := {"moss": 0, "gable": roundi(14 * s), "hip": roundi(28 * s), "flat": 4, "awning": roundi(14 * s)}.get(kind, 0) as int
	for y in range(r.position.y, r.end.y):
		var k := y - r.position.y
		var inset := int(round(top_inset * (1.0 - float(k) / maxf(1.0, r.size.y - 1))))
		if kind == "moss" and k < 9:
			inset = maxi(inset, roundi(9.0 - sqrt(maxf(0.0, 81.0 - (9.0 - k) * (9.0 - k)))))   # rounded corners
		var x0 := r.position.x + inset
		var x1 := r.end.x - inset
		if x1 - x0 < 3:
			continue
		var c: Color = rp[1]
		if k < 3:
			c = rp[0]
		elif y >= r.end.y - 4:
			c = rp[2]
		elif kind != "moss" and k % 6 == 0:
			c = rp[2]   # a shingle course
		_rect(img, Rect2i(x0, y, x1 - x0, 1), c)
		if kind != "moss" and k % 6 > 0 and k >= 3 and y < r.end.y - 4:
			var off := 0 if (k / 6) % 2 == 0 else 4
			for x in range(x0 + 2 + off, x1 - 2, 8):
				_rect(img, Rect2i(x, y, 1, 1), rp[2])
		elif kind == "moss" and k >= 3 and y < r.end.y - 4 and (k * 7) % 5 == 0:
			for x in range(x0 + 3 + (k % 4) * 3, x1 - 3, 13):
				_rect(img, Rect2i(x, y, 2, 1), rp[2])   # tufts
		_rect(img, Rect2i(x0, y, 1, 1), INK)
		_rect(img, Rect2i(x1 - 1, y, 1, 1), INK)
		if k == 0:
			_rect(img, Rect2i(x0, y, x1 - x0, 1), INK)


## A wall of stone courses, planks, a timber frame over stone, or rounded river stone, lit top-left.
static func _wall(img: Image, r: Rect2i, kind: String) -> void:
	var base := PP.WOOD if kind == "plank" else STONE
	PP.block(img, r, base)
	var rp := PP.ramp(base)
	match kind:
		"plank":
			for x in range(r.position.x + 6, r.end.x - 2, 6):
				_rect(img, Rect2i(x, r.position.y + 2, 1, r.size.y - 3), rp[2])
		"timber":
			_courses(img, r, rp, 7, 12)
			var wood := PP.ramp(PP.WOOD)
			_rect(img, Rect2i(r.position.x, r.position.y, r.size.x, 5), INK)
			_rect(img, Rect2i(r.position.x + 1, r.position.y + 1, r.size.x - 2, 3), wood[1])
			_rect(img, Rect2i(r.position.x + 1, r.position.y + 1, r.size.x - 2, 1), wood[0])
			for x in range(r.position.x + T - EAVE - 1, r.end.x - 4, T):
				_rect(img, Rect2i(x, r.position.y + 5, 4, r.size.y - 5), INK)
				_rect(img, Rect2i(x + 1, r.position.y + 5, 2, r.size.y - 5), wood[1])
		"river_stone":
			_courses(img, r, rp, 8, 10)
		_:
			_courses(img, r, rp, 7, 12)


static func _courses(img: Image, r: Rect2i, rp: Array[Color], rise: int, run: int) -> void:
	for y in range(r.position.y + rise, r.end.y - 1, rise):
		_rect(img, Rect2i(r.position.x + 1, y, r.size.x - 2, 1), rp[2])
		var off := 0 if ((y - r.position.y) / rise) % 2 == 0 else run / 2
		for x in range(r.position.x + 2 + off, r.end.x - 2, run):
			_rect(img, Rect2i(x, y - rise + 1, 1, rise - 1), rp[2])


## A window: an ink frame, lit glass and a mullion cross; shuttered, plain boards.
static func _window(img: Image, r: Rect2i, shut: bool) -> void:
	_rect(img, r, INK)
	if shut:
		_rect(img, r.grow(-1), PP.WOOD_LIT)
		_rect(img, Rect2i(r.position.x + 1, r.position.y + r.size.y / 2, r.size.x - 2, 1), INK)
		return
	_rect(img, r.grow(-1), PP.WINDOW)
	_rect(img, Rect2i(r.position.x + r.size.x / 2, r.position.y, 1, r.size.y), INK)
	_rect(img, Rect2i(r.position.x, r.position.y + r.size.y / 2, r.size.x, 1), INK)


## The door opening at door_px: an ink edge, a 2 px frame and the dark doorway down to the sill. The game draws the
## leaves over it (door_frames), so a repaint keeps this box dark.
static func _door_opening(img: Image, door: Rect2i) -> void:
	_rect(img, Rect2i(door.position.x - 1, door.position.y - 1, door.size.x + 2, door.size.y + 1), INK)
	_rect(img, door, PP.DOOR_FRAME)
	_rect(img, Rect2i(door.position.x + 2, door.position.y + 2, door.size.x - 4, door.size.y - 2), PP.DOOR_DARK)


## A stall: a counter along the bottom row, two posts and a striped awning; before it opens, a canvas tarp tied over
## the bare frame.
static func _stall(img: Image, style: Dictionary, s: float) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var counter := roundi(20 * s)
	var post_top := h - roundi(96 * s)
	var wood := PP.ramp(PP.WOOD)
	for px in [EAVE + 2, w - EAVE - 8]:
		PP.block(img, Rect2i(px, post_top, 6, h - post_top), PP.WOOD)
	if bool(style.get("tarp", false)):
		# The bare counter frame: rails and a cross brace, open between them.
		_rect(img, Rect2i(EAVE, h - counter, w - 2 * EAVE, 4), INK)
		_rect(img, Rect2i(EAVE + 1, h - counter + 1, w - 2 * EAVE - 2, 2), wood[0])
		_rect(img, Rect2i(EAVE, h - 4, w - 2 * EAVE, 4), INK)
		_rect(img, Rect2i(EAVE + 1, h - 3, w - 2 * EAVE - 2, 2), wood[1])
		for k in range(0, w - 2 * EAVE - 12):
			var y := h - counter + 4 + k * (counter - 8) / maxi(1, w - 2 * EAVE - 12)
			_rect(img, Rect2i(EAVE + 6 + k, y, 1, 2), wood[2])
		# The tarp, draped from the post tops and sagging between them, a fold down the middle.
		var cloth := PP.ramp(TARP)
		var tarp_top := post_top - roundi(8 * s)
		for x in range(EAVE - 2, w - EAVE + 2):
			var u := float(x - (EAVE - 2)) / float(w - 2 * EAVE + 3)
			var hang := roundi((44 + 10 * sin(u * PI)) * s)
			var y0 := tarp_top + roundi(8 * s * absf(u - 0.5))
			var c: Color = cloth[1]
			if absi(x - w / 2) < 2 or absi(x - w / 4) < 1 or absi(x - 3 * w / 4) < 1:
				c = cloth[2]
			_rect(img, Rect2i(x, y0, 1, hang), c)
			_rect(img, Rect2i(x, y0, 1, 1), INK)
			_rect(img, Rect2i(x, y0 + hang, 1, 1), INK)
			_rect(img, Rect2i(x, y0 + 1, 1, 2), cloth[0])
		for px in [EAVE + 4, w - EAVE - 6]:
			_rect(img, Rect2i(px - 1, tarp_top + roundi(46 * s), 4, 3), INK)   # rope ties at the posts
			_rect(img, Rect2i(px, tarp_top + roundi(46 * s) + 1, 2, 1), cloth[0])
		return
	# Open: the counter, and a striped awning over the posts.
	PP.block(img, Rect2i(EAVE, h - counter, w - 2 * EAVE, counter), PP.WOOD)
	var a := Rect2i(2, post_top - roundi(12 * s), w - 4, roundi(22 * s))
	var stripe := PP.ramp(AWNING)
	for x in range(a.position.x, a.end.x):
		_rect(img, Rect2i(x, a.position.y, 1, a.size.y), stripe[1] if ((x - a.position.x) / 8) % 2 == 0 else PP.PARCHMENT)
	_rect(img, Rect2i(a.position.x, a.position.y, a.size.x, 1), INK)
	_rect(img, Rect2i(a.position.x, a.end.y - 1, a.size.x, 1), INK)
	_rect(img, Rect2i(a.position.x, a.position.y, 1, a.size.y), INK)
	_rect(img, Rect2i(a.end.x - 1, a.position.y, 1, a.size.y), INK)


## A canvas row at scale s, from a 1.0 row v measured on TOWER_CANVAS (distances are kept from the foot).
static func _ty(v: int, h: int, s: float) -> int:
	return (h - 1) - roundi((TOWER_FOOT.y - v) * s)


## A canvas column at scale s, from a 1.0 column (distances are kept from the middle).
static func _tx(v: int, w: int, s: float) -> int:
	return w / 2 + roundi((v - TOWER_CANVAS.x / 2) * s)


## The stage rect `name` of TOWER_STAGES at this canvas and scale (the base keeps its tile-locked width).
static func tower_stage(name: String, size: Vector2i, s: float) -> Rect2i:
	var r: Rect2i = TOWER_STAGES[name]
	var y0 := _ty(r.position.y, size.y, s)
	var y1 := _ty(r.end.y, size.y, s)
	if name == "base":
		return Rect2i(r.position.x, y0, r.size.x, size.y - y0)
	var x0 := _tx(r.position.x, size.x, s)
	var x1 := _tx(r.end.x, size.x, s)
	return Rect2i(x0, y0, x1 - x0, y1 - y0)


## The Wayline Tower's placeholder, in its stages: the base (terrace roof, front wall, pilasters, double door, windows),
## the shaft (stone courses, string courses, a lit window on every floor, a courier banner), the lamp gallery, the
## signal lantern room, its cap, and the beacon mast with a pennant and the signal light at the top.
static func _tower(img: Image, door: Rect2i, s: float, style: Dictionary = {}) -> void:
	var size := img.get_size()
	var w := size.x
	var h := size.y
	var stone := PP.ramp(STONE)
	var slate := PP.ramp(PP.SLATE)
	var teal := PP.ramp(PP.SEAL)
	var glow := PP.ramp(PP.LANTERN)
	var lit := PP.ramp(LIGHT)
	var wall_top := door.position.y - roundi(16 * s)
	var base := tower_stage("base", size, s)
	# The base's terrace roof, over its three-tile depth.
	var terrace := Rect2i(1, base.position.y, w - 2, wall_top - base.position.y)
	for y in range(terrace.position.y, terrace.end.y):
		var k := y - terrace.position.y
		var inset := roundi(10 * (1.0 - float(k) / maxf(1.0, terrace.size.y - 1)))
		var x0 := terrace.position.x + inset
		var x1 := terrace.end.x - inset
		var c: Color = slate[0] if k < 2 else (slate[2] if k % 6 == 0 or y >= terrace.end.y - 3 else slate[1])
		_rect(img, Rect2i(x0, y, x1 - x0, 1), c)
		_rect(img, Rect2i(x0, y, 1, 1), INK)
		_rect(img, Rect2i(x1 - 1, y, 1, 1), INK)
	_rect(img, Rect2i(terrace.position.x + 10, terrace.position.y, terrace.size.x - 20, 1), INK)
	# The shaft stands on the terrace, a third of the way back from the front wall.
	var shaft := tower_stage("shaft", size, s)
	PP.block(img, shaft, STONE)
	_courses(img, shaft, stone, 8, 12)
	var floor_h := roundi(70 * s)
	for y in range(shaft.position.y + floor_h, shaft.end.y - 4, floor_h):
		_rect(img, Rect2i(shaft.position.x, y, shaft.size.x, 3), INK)            # a string course
		_rect(img, Rect2i(shaft.position.x + 1, y + 1, shaft.size.x - 2, 1), LIGHT)
	for y in range(shaft.position.y + roundi(90 * s), shaft.end.y - roundi(60 * s), floor_h):
		var win := Rect2i(w / 2 - roundi(6 * s), y, roundi(12 * s), roundi(22 * s))
		_rect(img, win, INK)
		_rect(img, win.grow(-1), PP.WINDOW)
		_rect(img, Rect2i(win.position.x + win.size.x / 2, win.position.y, 1, win.size.y), INK)
		for side in [-1, 1]:   # arrow slits either side
			_rect(img, Rect2i(w / 2 + side * roundi(34 * s) - 1, y + roundi(4 * s), 3, roundi(12 * s)), INK)
	# A courier banner hung under the gallery: teal cloth, a lantern-gold chevron (a pictogram, no letters).
	var banner := Rect2i(w / 2 - roundi(14 * s), shaft.position.y + roundi(4 * s), roundi(28 * s), roundi(60 * s))
	_rect(img, banner.grow(1), INK)
	_rect(img, banner, teal[1])
	_rect(img, Rect2i(banner.position.x, banner.position.y, 2, banner.size.y), teal[0])
	for k in roundi(10 * s):
		_rect(img, Rect2i(w / 2 - k - 1, banner.position.y + roundi(18 * s) + k, 2, 2), PP.LANTERN)
		_rect(img, Rect2i(w / 2 + k - 1, banner.position.y + roundi(18 * s) + k, 2, 2), PP.LANTERN)
	var notch := roundi(6 * s)
	for x in range(banner.position.x, banner.end.x):   # a swallowtail hem
		var d := absi(x - w / 2)
		if d < notch:
			_rect(img, Rect2i(x, banner.end.y - (notch - d), 1, notch - d + 1), INK)
	# The gallery: a ledge wider than the shaft, a rail of posts.
	var gal := tower_stage("gallery", size, s)
	var ledge := Rect2i(gal.position.x, gal.position.y + gal.size.y / 2, gal.size.x, gal.size.y - gal.size.y / 2)
	PP.block(img, ledge, LIGHT)
	_rect(img, Rect2i(gal.position.x + 2, gal.position.y, gal.size.x - 4, 2), INK)
	for x in range(gal.position.x + 3, gal.end.x - 3, 8):
		_rect(img, Rect2i(x, gal.position.y, 2, ledge.position.y - gal.position.y), INK)
	# The lantern room: lit glass between ink mullions, on a stone sill, the lamp's core in the middle.
	var lan := tower_stage("lantern", size, s)
	PP.block(img, lan, PP.LANTERN)
	_rect(img, Rect2i(lan.position.x + 2, lan.position.y + 2, lan.size.x - 4, 3), glow[0])
	for x in range(lan.position.x + lan.size.x / 4, lan.end.x - 2, lan.size.x / 4):
		_rect(img, Rect2i(x - 1, lan.position.y, 2, lan.size.y), INK)
	_rect(img, Rect2i(w / 2 - roundi(6 * s), lan.position.y + lan.size.y / 2 - roundi(6 * s), roundi(12 * s), roundi(12 * s)), PP.WINDOW)
	_rect(img, Rect2i(lan.position.x - 2, lan.end.y - 4, lan.size.x + 4, 4), INK)
	_rect(img, Rect2i(lan.position.x - 1, lan.end.y - 3, lan.size.x + 2, 2), stone[1])
	# The cap: a pointed slate roof.
	var cap := tower_stage("cap", size, s)
	for y in range(cap.position.y, cap.end.y):
		var u := float(y - cap.position.y) / maxf(1.0, cap.size.y - 1)
		var half := roundi(3 + u * (cap.size.x / 2 - 3))
		var c: Color = slate[0] if u < 0.25 else (slate[2] if y >= cap.end.y - 3 else slate[1])
		_rect(img, Rect2i(w / 2 - half, y, half * 2, 1), c)
		_rect(img, Rect2i(w / 2 - half, y, 1, 1), INK)
		_rect(img, Rect2i(w / 2 + half - 1, y, 1, 1), INK)
	_rect(img, Rect2i(cap.position.x - 2, cap.end.y - 1, cap.size.x + 4, 1), INK)
	# The beacon mast, a courier pennant, and the signal light at the very top (TOWER_TOP).
	var top := _ty(TOWER_TOP.y, h, s)
	_rect(img, Rect2i(w / 2 - 1, top + 3, 3, cap.position.y - top - 2), INK)
	_rect(img, Rect2i(w / 2, top + 4, 1, cap.position.y - top - 4), PP.WOOD_LIT)
	var pen := top + roundi(8 * s)
	for k in roundi(14 * s):
		var tall := maxi(1, roundi((7 - k * 0.5) * s))
		_rect(img, Rect2i(w / 2 + 2 + k, pen, 1, tall), teal[0] if k < 2 else teal[1])
		_rect(img, Rect2i(w / 2 + 2 + k, pen + tall, 1, 1), INK)
	_rect(img, Rect2i(w / 2 - 3, top - 3, 7, 7), INK)
	_rect(img, Rect2i(w / 2 - 2, top - 2, 5, 5), PP.LANTERN)
	_rect(img, Rect2i(w / 2 - 1, top - 1, 2, 2), glow[0])
	# The front wall: river stone between lit pilasters, windows, and the double door under a stone arch.
	var front := Rect2i(EAVE, wall_top, w - 2 * EAVE, h - wall_top)
	PP.block(img, front, STONE)
	_courses(img, front, stone, 8, 10)
	_rect(img, Rect2i(EAVE - 2, wall_top, w - 2 * EAVE + 4, 1), INK)   # the drip line
	for px in [EAVE, w / 2 - roundi(40 * s), w / 2 + roundi(40 * s) - 10, w - EAVE - 10]:
		PP.block(img, Rect2i(px, wall_top + 1, 10, h - wall_top - 1), LIGHT)   # pilasters
		_rect(img, Rect2i(px + 2, wall_top + 4, 1, h - wall_top - 6), lit[0])
	for col in style.get("windows", STYLES["hall"]["windows"]):
		_window(img, Rect2i(EAVE + int(col) * T + 4, wall_top + roundi(16 * s), 16, roundi(20 * s)), false)
	var arch := Rect2i(door.position.x - 4, door.position.y - roundi(8 * s), door.size.x + 8, door.size.y + roundi(8 * s))
	_rect(img, arch, INK)
	_rect(img, arch.grow_individual(-1, -1, -1, 0), LIGHT)
	_rect(img, Rect2i(w / 2 - 3, arch.position.y, 6, 5), lit[0])
	_door_opening(img, door)


# ---------------------------------------------------------------------------------------------------------------------
# What the game draws over a building: shadow, foundation, doorstep, sign, door leaves

## Foundation stones along the base (skipping the door), grass across the wall's foot and the lit doorstep, as
## building_exteriors.gd draws them for v1 (lines "Low broken foundation stones" to "One lit doorstep").
static func details_image(size: Vector2i, door: Rect2i) -> Image:
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	for x in range(9, size.x - 9, 7):
		if door.size.x > 0 and x > door.position.x - 8 and x < door.end.x + 3:
			continue
		var y := size.y - 7 + (x / 7) % 2
		img.fill_rect(Rect2i(x, y, 6, 4), INK)
		img.fill_rect(Rect2i(x, y, 5, 2), STONE)
		img.fill_rect(Rect2i(x, y, 4, 1), LIGHT)
	for x in [12, 27, size.x - 26, size.x - 12]:
		img.fill_rect(Rect2i(x, size.y - 4, 5, 1), GRASS)
		img.fill_rect(Rect2i(x + 1, size.y - 6, 1, 3), GRASS)
		img.fill_rect(Rect2i(x + 3, size.y - 5, 1, 2), Color("#88965e"))
	if door.size.x > 0:
		img.fill_rect(Rect2i(door.position.x - 1, size.y - 3, door.size.x + 2, 3), INK)
		img.fill_rect(Rect2i(door.position.x, size.y - 3, door.size.x, 1), LIGHT)
		img.fill_rect(Rect2i(door.position.x + 1, size.y - 2, door.size.x - 2, 1), STONE)
	return img


## The door's three swing frames, cut from the door opening itself (no flood fill): closed, half and open. A single
## door swings from its left jamb, a double door from the middle out. The open part stays clear, so the slot's dark
## doorway shows through.
static func door_frames(door: Vector2i, tiles: int) -> Array[Texture2D]:
	var out: Array[Texture2D] = []
	for f in 3:
		var img := Image.create(maxi(1, door.x), maxi(1, door.y), false, Image.FORMAT_RGBA8)
		for y in range(2, door.y):
			for x in range(2, door.x - 2):
				var span := door.x - 4
				var leaf := 0
				var edge := 0
				if tiles >= 2:
					leaf = [span / 2, span / 4, 2][f]
					edge = mini(x - 2, door.x - 3 - x)
				else:
					leaf = [span, span / 2, 3][f]
					edge = x - 2
				if edge >= leaf:
					continue
				var c := DOOR_WOOD if edge % 6 != 0 else DOOR_SEAM
				if y == 2:
					c = LIGHT
				if edge == leaf - 1 or x == 2 or x == door.x - 3:
					c = INK
				if edge == leaf - 4 and y in [door.y / 2, door.y / 2 + 1]:
					c = HANDLE
				img.set_pixel(x, y, c)
		out.append(ImageTexture.create_from_image(img))
	return out


## Stands one building, or one lot, on an area's grid under `parent` and returns its node (02 sections 3.3, 3.6, 4.3).
## The node sits at the canvas origin and sorts at its door row, as v1's buildings do; its children are the contact
## shadow, the picture ("Exterior", the slot), the foundation and doorstep ("Details"), the sign ("Sign", its slot)
## and the door ("Door", frames in meta "frames"). Meta: "door_px" (canvas px), "class", "slot".
static func place(b: Dictionary, parent: Node) -> Node2D:
	return place_scaled(b, parent, BUILDING_SCALE)


## place() at another scale (the lineup's 1.25 row): slots only fit BUILDING_SCALE, so off it the template is drawn.
static func place_scaled(b: Dictionary, parent: Node, s: float) -> Node2D:
	if b.has("before") and not bool(b.get("open", false)):
		return _place_lot(b, parent, s)
	var entry := b
	if b.has("before"):   # an open lot: its building on the lot's base
		entry = (b.get("building", {}) as Dictionary).duplicate()
		entry["base"] = b["base"]
		if not entry.has("class"):
			entry["class"] = b.get("class", "shop")
	var cls := String(entry.get("class", ""))
	if not CLASSES.has(cls) or not (entry.get("base") is Rect2i):
		return null
	var id := String(entry.get("id", cls))
	var base_rect: Rect2i = entry["base"]
	var g := geometry(cls, s)
	var size: Vector2i = g["canvas"]
	var slot := String(entry.get("slot", "town.building." + id))
	var tex: Texture2D = null
	if is_equal_approx(s, BUILDING_SCALE) and ArtSlots.has(slot) and ArtSlots.sheet_size(slot) == size:
		tex = ArtSlots.texture(slot)   # one state, one frame: the sheet is the picture
	else:
		tex = ImageTexture.create_from_image(template_image(cls, id, s))
	var node := Node2D.new()
	node.name = id.capitalize().replace(" ", "")
	node.position = Vector2(canvas_origin(cls, base_rect, s))
	node.z_index = (base_rect.end.y - 1) * T   # the door row: in front of the roof, behind a creature on the door tile
	parent.add_child(node)
	var shadow := Sprite2D.new()
	shadow.name = "ContactShadow"
	shadow.centered = false
	shadow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	shadow.texture = tex
	shadow.position = Vector2(2, 2)
	shadow.modulate = Color(0, 0, 0, 0.28)
	node.add_child(shadow)
	var sprite := Sprite2D.new()
	sprite.name = "Exterior"
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture = tex
	Finish.apply(sprite, true)   # the shared sel-out finish every building has
	node.add_child(sprite)
	var door: Rect2i = g["door_px"]
	var details := Sprite2D.new()
	details.name = "Details"
	details.centered = false
	details.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	details.texture = ImageTexture.create_from_image(details_image(size, door))
	node.add_child(details)
	var sign_at: Dictionary = entry.get("sign", _style(cls, id).get("sign", {}))
	if sign_at.has("col") and SIGN_SLOTS.has(String(sign_at.get("icon", ""))):
		var board := Sprite2D.new()
		board.name = "Sign"
		board.centered = false
		board.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		board.texture = ArtSlots.texture(SIGN_SLOTS[String(sign_at["icon"])])
		board.position = Vector2(EAVE + int(sign_at["col"]) * T, size.y - 3 - 23)   # its foot (12, 23) on the doorstep row
		node.add_child(board)
	var frames: Array[Texture2D] = []
	if door.size.x > 0:
		frames = door_frames(door.size, int(g["door_tiles"]))
		var leaves := Sprite2D.new()
		leaves.name = "Door"
		leaves.centered = false
		leaves.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		leaves.position = Vector2(door.position)
		leaves.texture = frames[0]
		Finish.apply(leaves)
		node.add_child(leaves)
	node.set_meta("frames", frames)
	node.set_meta("door_px", door)
	node.set_meta("class", cls)
	node.set_meta("slot", slot)
	return node


## A lot before it opens: its before slot (tarp over a stall frame, a boarded shopfront, a fenced plot) on its base.
static func _place_lot(lot: Dictionary, parent: Node, s: float) -> Node2D:
	var before := String(lot.get("before", ""))
	var cls := String(lot.get("class", "stall"))
	var slot := String(lot.get("slot", ""))   # the area may name the slot; else the before state picks it
	if not ArtSlots.has(slot):
		if not BEFORE_SLOTS.has(before):
			before = "plot" if cls == "plot" else ("tarp" if cls == "stall" else "shutters")
		slot = BEFORE_SLOTS[before]
	var lot_spec := ArtSlots.spec(slot)
	var flat := String(lot_spec.get("anchor_mode", "")) == "top_left"   # an open-air plot lies flat
	if not (lot.get("base") is Rect2i):
		return null
	var base_rect: Rect2i = lot["base"]
	var node := Node2D.new()
	node.name = String(lot.get("id", "lot")).capitalize().replace(" ", "")
	parent.add_child(node)
	var sprite := Sprite2D.new()
	sprite.name = "Exterior"
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture = ArtSlots.texture(slot)
	if flat:
		node.position = Vector2(base_rect.position * T)   # open-air: top-left on the lot, below the creatures
		node.z_index = 0
	else:
		var lot_cls := String(lot_spec.get("building_class", "stall" if cls == "stall" else "shop"))
		node.position = Vector2(canvas_origin(lot_cls, base_rect, s))
		node.z_index = (base_rect.end.y - 1) * T
		if not is_equal_approx(s, BUILDING_SCALE):
			sprite.texture = ImageTexture.create_from_image(template_image(lot_cls, slot.get_slice(".", 2), s))
	Finish.apply(sprite, true)
	node.add_child(sprite)
	node.set_meta("frames", [])
	node.set_meta("door_px", Rect2i())
	node.set_meta("class", cls)
	node.set_meta("slot", slot)
	return node


## The empty plot's placeholder (town.landmark.lot_before_plot): trampled earth inside a low timber fence with a gap
## to walk in, and stakes and a string marking where something will stand.
static func paint_plot(_id: String, spec: Dictionary) -> Image:
	var size: Vector2i = spec.get("sheet_size", spec.get("size", Vector2i(144, 96)))
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	var earth := [Color("#8f805e"), Color("#948461"), Color("#9c8c68")]
	for y in size.y:
		for x in size.x:
			img.set_pixel(x, y, earth[(x / 4 + y / 3 + (x * y) % 5) % 3])
	var wood := PP.ramp(PP.WOOD)
	for y in [5, size.y - 9]:   # rails, the south one open in the middle
		for x in range(2, size.x - 2):
			if y > 10 and absi(x - size.x / 2) < 14:
				continue
			img.set_pixel(x, y, INK)
			img.set_pixel(x, y + 1, wood[0])
			img.set_pixel(x, y + 2, INK)
	for x in [2, size.x - 4]:
		img.fill_rect(Rect2i(x, 5, 3, size.y - 11), INK)
		img.fill_rect(Rect2i(x + 1, 6, 1, size.y - 13), wood[1])
	for x in range(2, size.x - 2, 24):
		for y in [2, size.y - 12]:
			if y > 10 and absi(x - size.x / 2) < 14:
				continue
			img.fill_rect(Rect2i(x, y, 3, 9), INK)
			img.fill_rect(Rect2i(x + 1, y + 1, 1, 7), wood[0])
	var stakes := [Vector2i(36, 30), Vector2i(size.x - 36, 30), Vector2i(size.x - 36, size.y - 30), Vector2i(36, size.y - 30)]
	for i in stakes.size():
		var a: Vector2i = stakes[i]
		var b: Vector2i = stakes[(i + 1) % stakes.size()]
		for k in 33:
			var p := Vector2i(a.x + (b.x - a.x) * k / 32, a.y + (b.y - a.y) * k / 32)
			img.set_pixelv(p, PP.PARCHMENT)
	for a in stakes:
		img.fill_rect(Rect2i(a.x - 1, a.y - 7, 3, 8), INK)
		img.fill_rect(Rect2i(a.x, a.y - 6, 1, 6), wood[0])
	return img


static func _rect(img: Image, r: Rect2i, c: Color) -> void:
	var cut := r.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	if cut.size.x > 0 and cut.size.y > 0:
		img.fill_rect(cut, c)
