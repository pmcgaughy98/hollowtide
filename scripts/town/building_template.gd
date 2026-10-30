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
## The Wayline Tower (canon, Preston 2026-10-26; the approved "Reach and Waiting Lamp" tower, 2026-10-27) is the "hall"
## class. Its door part, the depot, is an ordinary 300 x 192 building on the Hall's 12 x 3 base with the 48 x 64 double
## door; the tower rising 720 px over it is TowerParts (scripts/town/tower_parts.gd), a stack of part slots. With
## Highbank v2 on, place() hands the hall to TowerParts.place(); v1 never calls this file. tower_points() gives a scene
## the door, the beacon and the apex in area px to pan a camera between. A hall entry with "tower": "foot" (Tower Rise
## since 2026-10-29, RISE_CLIMB_SLICE.md slice 1) stands the new Tower's coded foot instead (scripts/town/tower_foot.gd):
## the plinth's two steps, the stair and the Stack's foot with the doors; TowerParts stays for the other callers.

const Layout := preload("res://scripts/town/town_layout.gd")
const Finish := preload("res://scripts/town/exterior_finish.gd")
const PP := preload("res://scripts/art/placeholder_painter.gd")

const T := 24
const EAVE := 6               # px of eave each side, over the neighbouring tiles without collision (02 section 4.1)
const VIEW_H := 216           # the town view's height, for "screens tall"
const BUILDING_SCALE := 1.0   # Preston call 1: 1.0 by default; 1.25 resizes every canvas before the lists go out
const SCALES := [1.0, 1.25]   # what scenes/debug/building_lineup.tscn shows side by side
## base in tiles, canvas and door opening in px (02 section 4.2); wall and roof are the px heights BUILDING_SCALE
## multiplies; door_col is the base column of the (left) door tile. The hall class is the Wayline Tower's depot (canon,
## Preston 2026-10-26 and 2026-10-27): the same 12 x 3 base and doors, 192 px tall, with the tower standing on it
## (TowerParts); its double door is 48 px wide so Galeshear (63 px wide, 62 tall, measured from its town/s.png) passes
## check C11.
const CLASSES := {
	"cottage": {"base": Vector2i(5, 2), "canvas": Vector2i(132, 144), "door_px": Rect2i(55, 94, 22, 48), "pass_creature": "sparkjab",
		"wall": 60, "roof": 36, "door_col": 2, "door_tiles": 1},
	"shop": {"base": Vector2i(6, 2), "canvas": Vector2i(156, 144), "door_px": Rect2i(55, 94, 22, 48), "pass_creature": "sparkjab",
		"wall": 60, "roof": 36, "door_col": 2, "door_tiles": 1},
	"stall": {"base": Vector2i(4, 2), "canvas": Vector2i(108, 120), "door_px": Rect2i(), "pass_creature": "",
		"wall": 36, "roof": 36, "door_col": -1, "door_tiles": 0},
	"hall": {"base": Vector2i(12, 3), "canvas": Vector2i(300, 192), "door_px": Rect2i(126, 126, 48, 64), "pass_creature": "galeshear",
		"wall": 80, "roof": 40, "door_col": 5, "door_tiles": 2},
	# Buildings shaped by their keepers (Preston, 2026-10-28; TOWN_MAP.md): each its own class with its own painter.
	# trading_post: Swaphoard's Item Shop. Roof first (TOWN_SYNTHESIS.md, measured from Explorers of Sky's town): a base
	# three deep so the roof covers solid ground, 192 px tall (about six small creatures of the town set), the roof two
	# thirds of it and the front a 64 px band ("eave", px from the foot to the eave line), the door a quarter. It
	# replaced the lean_to of the same morning (Preston: "to small and shack like").
	"trading_post": {"base": Vector2i(8, 3), "canvas": Vector2i(204, 192), "door_px": Rect2i(79, 142, 22, 48), "pass_creature": "sparkjab",
		"wall": 40, "roof": 80, "eave": 64, "door_col": 3, "door_tiles": 1},
	# burrow: the team's Home, dug into the bluff at the Street's west end (TOWN_MAP.md, Preston's yes 2026-10-28).
	# Roof first like the trading post: the grass bank over a base three deep is the roof, the stone face the bottom
	# 56 px ("eave", the door plus 8), 192 tall so the door stays a quarter of it, the door centred on base column 2.
	"burrow": {"base": Vector2i(5, 3), "canvas": Vector2i(132, 192), "door_px": Rect2i(55, 142, 22, 48), "pass_creature": "sparkjab",
		"wall": 40, "roof": 80, "eave": 56, "door_col": 2, "door_tiles": 1},
}

## The Wayline Tower, for the lanes that frame it (the story scene at its foot pans a camera up it; the road home
## shows it far off). The depot's numbers in its own canvas px at BUILDING_SCALE 1.0 (its foot is the anchor, the
## bottom centre on the base's last row); the tower's in TowerParts' 432 x 720 frame, where the depot's top-left is
## TOWER_DEPOT_AT. TOWER_PARTS is the draw order (TowerParts.PARTS: id, name, frame rect, layer, order, foot).
const TP := preload("res://scripts/town/tower_parts.gd")
const Foot := preload("res://scripts/town/tower_foot.gd")
const TOWER_CLASS := "hall"
const TOWER_SLOT := "town.building.hall"         # the depot's slot (the door part); the other parts are town_tower.gd
const TOWER_DEPOT := Vector2i(300, 192)          # the depot canvas: 12 tiles + eaves wide, 8 tiles tall
const TOWER_DOOR := Rect2i(126, 126, 48, 64)     # the double door in the depot, over base columns 5 and 6
const TOWER_DOOR_COLS := [5, 6]
const TOWER_FOOT := Vector2i(150, 191)           # the depot's foot (its anchor)
const TOWER_FRAME := TP.FRAME                    # 432 x 720: the whole tower, 30 tiles (3.33 screens) tall
const TOWER_DEPOT_AT := TP.DEPOT_AT              # the depot's top-left in the frame
const TOWER_BEACON := TP.BEACON                  # the Waiting Lamp's glass in the frame: where a pan up the Tower ends
const TOWER_APEX := TP.APEX                      # the vane's tip, the tower's top
const TOWER_PARTS := TP.PARTS

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
const GLASS_DARK := Color("#24282b")   # the dark inside an open counter or a loft door
const BERRY := Color("#b8433a")        # stock on the Item Shop's shelves

## Each building slot's look (02 section 3.3 fields: roof, wall, windows as base columns, chimney column, awning,
## shutters, and the sign beside the door). An area's building entry may name its own sign; the rest is the slot's.
## "_<class>" rows are the defaults for a building with no row of its own.
const STYLES := {
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
	"_trading_post": {"sign": {"col": 2, "icon": "bag"}},
	"_burrow": {},
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
	var h := base.y * T + roundi((int(c["wall"]) + int(c["roof"])) * s)
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


## The Tower in area px for a hall whose base is `base` (tiles), at BUILDING_SCALE: "origin" and "canvas" are the
## whole tower's frame (its top-left and 432 x 720), "depot_origin" the depot canvas's top-left, "door" the middle of
## the double door, "foot" the sill under it, "top" the beacon (the Waiting Lamp's glass) and "apex" the vane's tip.
## A camera panning up the Tower runs from "door" to "top". On Tower Rise (base 7, 6, 12, 3): origin (96, -504),
## door (312, 182), top (312, -386).
static func tower_points(base: Rect2i) -> Dictionary:
	var depot := canvas_origin(TOWER_CLASS, base)
	var o := depot - TOWER_DEPOT_AT
	var p := TP.points(Vector2(o))
	return {"origin": o, "canvas": TOWER_FRAME, "depot_origin": depot, "door": p["door"], "foot": p["foot"],
		"top": p["beacon"], "apex": p["apex"], "height": TOWER_FRAME.y, "screens": float(TOWER_FRAME.y) / VIEW_H}


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
			var depot := TP.paint_part(TOWER_SLOT)
			if depot.get_size() != size:
				depot.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)   # off BUILDING_SCALE: a stand-in only
			img = depot
		"stall":
			_stall(img, style, s)
		"trading_post":
			_trading_post(img, door, s)
		"burrow":
			_burrow(img, door, s)
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
	_rect(img, Rect2i(1, wall_top, w - 2, 1), INK)   # the drip line under the whole eave, its overhang included
	_eave_shade(img, Rect2i(EAVE, wall_top + 1, w - 2 * EAVE, 5),
		PP.ramp(PP.WOOD if String(style.get("wall", "stone")) in ["plank", "timber"] else STONE)[2])   # timber: its top beam
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
			if kind != "moss":
				# The eave (Preston, 2026-10-29, roofs read flat): a crease, the lit lip where the roof turns down, its face.
				c = [rp[2], rp[0], rp[1], rp[1]][y - (r.end.y - 4)]
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


## The eave's shadow on the wall under it: the wall's own dark tone through the ordered dither, solid on its top row
## thinning to none, so the roof stands out over the wall and the picture keeps its palette.
static func _eave_shade(img: Image, r: Rect2i, dark: Color) -> void:
	for y in range(r.position.y, mini(r.end.y, img.get_height())):
		var density := 1.0 - float(y - r.position.y) / float(r.size.y)
		for x in range(r.position.x, mini(r.end.x, img.get_width())):
			if img.get_pixel(x, y).a > 0.0 and (GROUND_DITHER[(y & 3) * 4 + (x & 3)] + 0.5) / 16.0 < density:
				img.set_pixel(x, y, dark)


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


## The team's Home, dug into the bluff (TOWN_MAP.md, Preston's yes 2026-10-28). Roof first like the trading post: the
## bank's grass dome is the roof, lit on its crown, a stovepipe standing out of it. Under the turf's hanging lip, a short
## face of river stone between the bank's flanks: a round window either side, the doorway under a stone ring that cuts
## up into the turf, a lantern by it, a parcel waiting below the right window (a courier team lives here), a flat step.
static func _burrow(img: Image, door: Rect2i, s: float) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var eave := h - roundi(int(CLASSES["burrow"]["eave"]) * s)   # the turf's lip: the bank above it, the face below
	var top := roundi(14 * s)                 # the crown of the bank
	var gp := PP.ramp(GRASS)
	var cx := w / 2
	var half := w / 2 - 1
	var widths := {}
	var prev := 0
	for y in range(top, eave):
		var k := float(y - top + 1) / float(eave - top)
		var hw := roundi(half * sqrt(1.0 - (1.0 - k) * (1.0 - k)))
		widths[y] = hw
		_rect(img, Rect2i(cx - hw, y, 2 * hw, 1), gp[0] if y < top + roundi(8 * s) else gp[1])
		_rect(img, Rect2i(cx - hw + 1, y, maxi(1, hw / 5), 1), gp[0])            # lit down the left
		_rect(img, Rect2i(cx + hw - maxi(2, hw / 6), y, maxi(2, hw / 6), 1), gp[2])   # shaded down the right
		if (y - top) % 6 == 3:   # tufts in staggered rows
			var off := 0 if ((y - top) / 6) % 2 == 0 else 4
			for x in range(cx - hw + 4 + off, cx + hw - 4, 8):
				_rect(img, Rect2i(x, y, 1, 2), gp[2])
		# The outline: each side's step out from the row above, so the dome's edge has no gaps.
		var step := maxi(1, hw - prev)
		_rect(img, Rect2i(cx - hw, y, step, 1), INK)
		_rect(img, Rect2i(cx + hw - step, y, step, 1), INK)
		prev = hw
	for p in [Vector2(0.3, 0.45), Vector2(0.62, 0.3), Vector2(0.45, 0.72), Vector2(0.76, 0.6), Vector2(0.18, 0.8)]:
		var fp := Vector2i(roundi(p.x * w), top + roundi(p.y * (eave - top)))
		if absi(fp.x - cx) < int(widths.get(fp.y, 0)) - 3:   # wildflowers, only on the turf
			_rect(img, Rect2i(fp.x, fp.y, 1, 1), PP.PARCHMENT)
			_rect(img, Rect2i(fp.x, fp.y + 1, 1, 1), gp[2])
	# The stovepipe out of the bank, right of the crown, a turf collar round its foot.
	var px := cx + roundi(28 * s)
	var foot := top
	while foot < eave - 1 and int(widths.get(foot, 0)) < absi(px - cx) + 10:
		foot += 1
	PP.block(img, Rect2i(px, roundi(4 * s), 6, foot - roundi(4 * s) + 4), PP.SLATE)
	PP.block(img, Rect2i(px - 2, 1, 10, 4), PP.SLATE)
	_rect(img, Rect2i(px - 2, foot + 3, 10, 2), gp[2])
	# The face between the bank's flanks, and the flanks running down to the ground.
	var fx0 := EAVE + roundi(8 * s)
	var fx1 := w - EAVE - roundi(8 * s)
	for y in range(eave, h):
		_rect(img, Rect2i(1, y, fx0 - 1, 1), gp[1])
		_rect(img, Rect2i(fx1, y, w - 1 - fx1, 1), gp[2])
		_rect(img, Rect2i(1, y, 1, 1), INK)
		_rect(img, Rect2i(w - 2, y, 1, 1), INK)
	_wall(img, Rect2i(fx0, eave, fx1 - fx0, h - eave), "river_stone")
	_rect(img, Rect2i(fx0 - 1, eave, 1, h - eave), INK)
	_rect(img, Rect2i(fx1, eave, 1, h - eave), INK)
	_rect(img, Rect2i(1, h - 1, w - 2, 1), INK)
	# The turf's lip over the face, its fringe hanging.
	_rect(img, Rect2i(1, eave - 2, w - 2, 3), gp[2])
	for x in range(fx0 + 1, fx1 - 1, 3):
		_rect(img, Rect2i(x, eave + 1, 1, 1 + (x / 3) % 3), gp[3])
	# The door's stone ring, cutting up into the turf, then the arched doorway inside it.
	var dcx := door.position.x + door.size.x / 2
	var ccy := door.position.y + door.size.x / 2   # the arch's centre: the door's top is the top of its round
	var ring := door.size.x / 2 + roundi(5 * s)
	_arch(img, dcx, ccy, ring + 1, door.end.y, INK)
	_arch(img, dcx, ccy, ring, door.end.y, LIGHT)
	for a in [200.0, 235.0, 270.0, 305.0, 340.0]:   # the ring's joints, radial
		var d := Vector2.from_angle(deg_to_rad(a))
		for r in range(door.size.x / 2 + 1, ring):
			_rect(img, Rect2i(dcx + roundi(d.x * r), ccy + roundi(d.y * r), 1, 1), PP.ramp(LIGHT)[2])
	for y in range(ccy + 8, door.end.y - 2, 8):     # and the jambs' courses
		_rect(img, Rect2i(dcx - ring, y, ring - door.size.x / 2, 1), PP.ramp(LIGHT)[2])
		_rect(img, Rect2i(dcx + door.size.x / 2, y, ring - door.size.x / 2, 1), PP.ramp(LIGHT)[2])
	_arch(img, dcx, ccy, door.size.x / 2 + 1, door.end.y, INK)
	_arch(img, dcx, ccy, door.size.x / 2, door.end.y, PP.DOOR_FRAME)
	_arch(img, dcx, ccy, door.size.x / 2 - 2, door.end.y, PP.DOOR_DARK)
	# Round windows either side, lit.
	for wx in [dcx - roundi(40 * s), dcx + roundi(40 * s)]:
		var at := Vector2i(wx, eave + roundi(22 * s))
		_disc(img, at, 10, INK)
		_disc(img, at, 9, LIGHT)
		_disc(img, at, 7, INK)
		_disc(img, at, 6, PP.WINDOW)
		_rect(img, Rect2i(at.x, at.y - 6, 1, 12), INK)
		_rect(img, Rect2i(at.x - 6, at.y, 12, 1), INK)
	# A lantern on a hook left of the ring, a parcel under the right window, the step.
	var lx := dcx - ring - roundi(8 * s)
	_rect(img, Rect2i(lx + 2, eave + roundi(6 * s), 1, 4), INK)
	PP.block(img, Rect2i(lx, eave + roundi(10 * s), 6, 8), HANDLE)
	var parcel := Rect2i(dcx + roundi(30 * s), h - 15, 16, 13)
	PP.block(img, parcel, TARP)
	_rect(img, Rect2i(parcel.position.x + parcel.size.x / 2, parcel.position.y, 1, parcel.size.y), CLAY)
	_rect(img, Rect2i(parcel.position.x, parcel.position.y + parcel.size.y / 2, parcel.size.x, 1), CLAY)
	_rect(img, Rect2i(dcx - 15, h - 2, 30, 1), LIGHT)
	_rect(img, Rect2i(dcx - 16, h - 3, 32, 1), INK)


## A round-topped shape: a half disc of radius rad on (cx, cy), straight sides down to row bottom (exclusive).
static func _arch(img: Image, cx: int, cy: int, rad: int, bottom: int, c: Color) -> void:
	for y in range(cy - rad, bottom):
		for x in range(cx - rad, cx + rad):
			var dx := x - cx + 0.5
			var dy := y - cy + 0.5
			if (y >= cy or dx * dx + dy * dy <= rad * rad) and x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
				img.set_pixel(x, y, c)


static func _disc(img: Image, at: Vector2i, rad: int, c: Color) -> void:
	_arch(img, at.x, at.y, rad, at.y, c)
	for y in range(at.y, at.y + rad):
		for x in range(at.x - rad, at.x + rad):
			var dx := x - at.x + 0.5
			var dy := y - at.y + 0.5
			if dx * dx + dy * dy <= rad * rad and x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
				img.set_pixel(x, y, c)


## Swaphoard's Item Shop as a hoarder's trading post (Preston, 2026-10-28: "wire shop again but make bigger", and the
## perspective). Roof first, the way a town seen from above reads (docs/design/town-map-2026-10-28/TOWN_SYNTHESIS.md):
## a clay hip roof over two thirds of the height, its back plane past the ridge catching the light; a loft dormer with
## a hoist and a crate hanging over the tiles; a tied sack on the ridge for the trade; a chimney. Under a deep eave
## shadow, a short plank front on a stone sill: a shuttered window, the door, and the open counter under a striped
## awning with stock on the sill. The goods tables and crates out front are the dooryard's own props.
static func _trading_post(img: Image, door: Rect2i, s: float) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var eave := h - roundi(int(CLASSES["trading_post"]["eave"]) * s)   # the eave line: the roof above it, the front below
	var x0 := EAVE
	var x1 := w - EAVE
	var rp := PP.ramp(CLAY)
	var wp := PP.ramp(DOOR_WOOD)
	var top := roundi(6 * s)                 # the back eave, the farthest edge seen
	var ridge := top + roundi(18 * s)
	var hip := roundi(46 * s)                # how far in the hips bring the ridge's ends
	# The back plane, narrowing away from us.
	for y in range(top, ridge):
		var ins := hip + roundi((1.0 - float(y - top) / maxf(1.0, ridge - top)) * 12.0)
		_rect(img, Rect2i(1 + ins, y, w - 2 - 2 * ins, 1), rp[0] if y > top else INK)
		_rect(img, Rect2i(1 + ins, y, 1, 1), INK)
		_rect(img, Rect2i(w - 2 - ins, y, 1, 1), INK)
	# The chimney stands on the back plane, right of the ridge's middle.
	PP.block(img, Rect2i(w - 2 - hip - 30, 2, 12, ridge + 2), STONE)
	# The front plane: ridge to eave, widening to the full overhang; tile courses, staggered joints, the hips inked,
	# a shaded strip down the right where the side plane turns away.
	for y in range(ridge, eave):
		var k := float(y - ridge) / maxf(1.0, eave - 1 - ridge)
		var ins := roundi(hip * (1.0 - k))
		var row := y - ridge
		var c: Color = rp[2] if row % 8 == 0 or y >= eave - 3 else rp[1]
		_rect(img, Rect2i(1 + ins, y, w - 2 - 2 * ins, 1), c)
		if row % 8 > 0 and y < eave - 3:
			var off := 0 if (row / 8) % 2 == 0 else 5
			for x in range(4 + ins + off, w - 4 - ins, 10):
				_rect(img, Rect2i(x, y, 1, 1), rp[2])
		_rect(img, Rect2i(w - 8 - ins, y, 5, 1), rp[2])
		_rect(img, Rect2i(1 + ins, y, 1, 1), INK)
		_rect(img, Rect2i(w - 2 - ins, y, 1, 1), INK)
	_rect(img, Rect2i(1 + hip, ridge, w - 2 - 2 * hip, 2), INK)            # the ridge
	_rect(img, Rect2i(2 + hip, ridge - 1, w - 4 - 2 * hip, 1), PP.PARCHMENT)   # light along its cap
	_rect(img, Rect2i(1, eave - 1, w - 2, 1), INK)                        # the eave's edge
	# The loft dormer in the front plane, its little gable, the loft door open on the dark.
	var dw := roundi(34 * s)
	var dx := w / 2 - dw / 2
	var dy := ridge + roundi(20 * s)
	var dh := roundi(30 * s)
	for i in 10:
		var half := 4 + (dw / 2) * i / 10
		_rect(img, Rect2i(w / 2 - half - 2, dy - 10 + i, 2 * half + 4, 1), rp[0] if i < 4 else rp[1])
		_rect(img, Rect2i(w / 2 - half - 2, dy - 10 + i, 1, 1), INK)
		_rect(img, Rect2i(w / 2 + half + 1, dy - 10 + i, 1, 1), INK)
	_rect(img, Rect2i(w / 2 - 6, dy - 11, 12, 1), INK)
	PP.block(img, Rect2i(dx, dy, dw, dh), DOOR_WOOD)
	_rect(img, Rect2i(dx + 7, dy + 6, dw - 14, dh - 8), GLASS_DARK)
	# The hoist: a beam out over the tiles, a rope, a crate hanging from it.
	PP.block(img, Rect2i(w / 2 - 2, dy - 14, 4, 8), DOOR_WOOD)
	_rect(img, Rect2i(w / 2, dy - 7, 1, dh + 12), INK)
	PP.block(img, Rect2i(w / 2 - 7, dy + dh + 4, 14, 12), DOOR_WOOD)
	_rect(img, Rect2i(w / 2 - 6, dy + dh + 9, 12, 1), wp[2])
	# A tied sack on the ridge, the trade's mark.
	PP.block(img, Rect2i(w / 2 - 6, ridge - 13, 12, 13), TARP)
	_rect(img, Rect2i(w / 2 - 3, ridge - 16, 6, 3), TARP)
	_rect(img, Rect2i(w / 2 - 4, ridge - 13, 8, 1), INK)
	# The front: planks on a stone sill, the shadow under the eave.
	_wall(img, Rect2i(x0, eave, x1 - x0, h - eave), "plank")
	_rect(img, Rect2i(x0, eave, x1 - x0, roundi(7 * s)), wp[2])
	_rect(img, Rect2i(x0, eave + roundi(7 * s), x1 - x0, 1), INK)
	PP.block(img, Rect2i(x0 - 1, h - 6, x1 - x0 + 2, 6), STONE)
	# A shuttered window, left.
	var win := Rect2i(x0 + 20, eave + roundi(20 * s), 18, roundi(16 * s))
	_window(img, win, false)
	for sx in [win.position.x - 7, win.end.x + 1]:
		PP.block(img, Rect2i(sx, win.position.y - 1, 6, win.size.y + 2), DOOR_WOOD)
	# The door.
	if door.size.x > 0:
		_door_opening(img, door)
	# The counter, right: the dark of the shop behind, shelves of stock, the sill board, the striped awning over it.
	var cx := door.end.x + roundi(12 * s)
	var counter := Rect2i(cx, eave + roundi(20 * s), x1 - 10 - cx, roundi(24 * s))
	_rect(img, counter, GLASS_DARK)
	for sy in [counter.position.y + 8, counter.position.y + 16]:
		_rect(img, Rect2i(counter.position.x, sy, counter.size.x, 1), wp[2])
		for gx in range(counter.position.x + 3, counter.end.x - 3, 6):
			_rect(img, Rect2i(gx, sy - 3, 3, 3), [BERRY, HANDLE, MOSS][(gx / 6 + sy) % 3])
	PP.block(img, Rect2i(counter.position.x - 3, counter.end.y, counter.size.x + 6, 5), DOOR_WOOD)
	for gx in range(counter.position.x + 2, counter.end.x - 4, 9):
		_rect(img, Rect2i(gx, counter.end.y - 4, 4, 4), [BERRY, HANDLE, MOSS][(gx / 9) % 3])   # stock on the sill
	var aw := Rect2i(counter.position.x - 5, eave + roundi(9 * s), counter.size.x + 10, roundi(9 * s))
	var cloth := PP.ramp(AWNING)
	for x in range(aw.position.x, aw.end.x):
		var col: Color = cloth[1] if ((x - aw.position.x) / 6) % 2 == 0 else PP.PARCHMENT
		_rect(img, Rect2i(x, aw.position.y, 1, aw.size.y), col)
		if (x - aw.position.x) % 6 in [2, 3]:
			_rect(img, Rect2i(x, aw.end.y, 1, 1), col)   # the scalloped hem
	_rect(img, Rect2i(aw.position.x, aw.position.y - 1, aw.size.x, 1), INK)


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
		_rect(img, Rect2i(EAVE + 1, h - 3, w - 2 * EAVE - 2, 1), wood[0])   # the rail's lit top
		for k in range(0, w - 2 * EAVE - 12):
			var y := h - counter + 4 + k * (counter - 8) / maxi(1, w - 2 * EAVE - 12)
			_rect(img, Rect2i(EAVE + 6 + k, y, 1, 2), wood[2])
		# The tarp, draped from the post tops and sagging between them, a fold down the middle.
		var cloth := PP.ramp(TARP)
		var tarp_top := post_top - roundi(8 * s)
		var top_d := maxi(3, roundi(6 * s))
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
			# Its top, lit, turning down over the front (Preston, 2026-10-29: the canopy read flat): a crease under the
			# lip, and the hem curling under in shade.
			_rect(img, Rect2i(x, y0 + 1, 1, top_d), cloth[0])
			_rect(img, Rect2i(x, y0 + 1 + top_d, 1, 1), cloth[2])
			_rect(img, Rect2i(x, y0 + hang - 2, 1, 2), cloth[2])
		for px in [EAVE + 2, w - EAVE - 8]:   # the tarp's shadow down the posts under its hem
			for x in range(px, px + 6):
				var u := float(x - (EAVE - 2)) / float(w - 2 * EAVE + 3)
				var bottom := tarp_top + roundi(8 * s * absf(u - 0.5)) + roundi((44 + 10 * sin(u * PI)) * s)
				_eave_shade(img, Rect2i(x, bottom + 1, 1, 6), wood[2])
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
	if cls == TOWER_CLASS and is_equal_approx(s, BUILDING_SCALE) and Layout.v2():
		if String(entry.get("tower", "")) == "foot":
			return _place_foot(entry, parent)
		return _place_tower(entry, parent)
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
	node.add_child(_ground_shadow(base_rect, node.position))
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


## The hall in Highbank v2: the whole Wayline Tower (TowerParts.place) with its depot on the hall's base, sorting at
## the door row like any building. Its long shadow falls on the ground below the foot down to the cliff row (the area's last row).
## Meta as place() sets it: "door_px" (the door in the tower's px), "frames", "class", "slot"; no Details or Sign (the
## depot paints its own footing, doorstep and Route Board).
static func _place_tower(entry: Dictionary, parent: Node) -> Node2D:
	var base_rect: Rect2i = entry["base"]
	var o := canvas_origin(TOWER_CLASS, base_rect) - TOWER_DEPOT_AT
	var rows := Layout.size().y if Layout.size().y > 0 else base_rect.end.y
	var drop := maxi(0, (rows - 1 - base_rect.end.y) * T)   # down to the cliff row, the area's last
	var node := TP.place(parent, Vector2(o), {"z": (base_rect.end.y - 1) * T, "shadow_drop": drop})
	node.name = String(entry.get("id", TOWER_CLASS)).capitalize().replace(" ", "")
	node.set_meta("slot", String(entry.get("slot", TOWER_SLOT)))
	return node


## The hall on Tower Rise since 2026-10-29: the new Tower's foot (TowerFoot.place), the plinth across the area's
## width and the Stack's foot over the hall's one-row base with the doors on it. Meta as place() sets it ("frames",
## "door_px" in the Stack node's px, "class", "slot"); it has no "beacon", so the Tower scene stands its own old tower
## on the doors (tower_reveal.gd town_tower).
## The building's shadow on the ground (Preston, 2026-10-29: buildings looked "flat and part of the scene"): its base
## shadowed 4 px right and 3 px down, solid, with a dithered rim 5 px wide fading out. It lies under the building's own
## picture, so what shows is a band along its foot and down its east side (the light is high in the west). Over the
## ground and under every creature and prop (z 1), as the props' shadows are.
const GROUND_DITHER := [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]


static func _ground_shadow(base_rect: Rect2i, origin: Vector2) -> Sprite2D:
	var foot := Rect2i(base_rect.position * T, base_rect.size * T)
	var off := Vector2i(4, 3)
	var rim := 5
	var size := foot.size + off + Vector2i(rim, rim)
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	for y in size.y:
		for x in size.x:
			var out := maxi(maxi(0, x - (foot.size.x + off.x - 1)), maxi(0, y - (foot.size.y + off.y - 1)))
			if out == 0 or (GROUND_DITHER[(y & 3) * 4 + (x & 3)] + 0.5) / 16.0 < 1.0 - float(out) / float(rim + 1):
				img.set_pixel(x, y, Color.WHITE)
	var s := Sprite2D.new()
	s.name = "GroundShadow"
	s.centered = false
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.texture = ImageTexture.create_from_image(img)
	s.position = Vector2(foot.position) - origin
	s.modulate = Color(0, 0, 0, 0.3)
	s.z_as_relative = false
	s.z_index = 1
	return s


static func _place_foot(entry: Dictionary, parent: Node) -> Node2D:
	var cols := Layout.size().x if Layout.size().x > 0 else 26
	var node := Foot.place(parent, entry, cols * T)
	node.set_meta("slot", String(entry.get("slot", TOWER_SLOT)))
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
