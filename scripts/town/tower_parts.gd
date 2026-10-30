class_name TowerParts
extends RefCounted
## The Wayline Tower in parts (Claude, 2026-10-27; docs/design/wayline-tower-2026-10-27/TOWER_DESIGN.md sections 5, 6,
## 9 and 10). Preston approved "The Reach and the Waiting Lamp" with the defaults: a rooted river-stone tower 30 tiles
## (720 px) tall, built in eras around a living root (the Reach) that climbs the left side and curls over the top to
## hold the runner's lantern (the Waiting Lamp) right above the door. The Reach, the Waiting Lamp, the Route Board,
## the First Post and the dark lantern are working labels until Preston renames or cuts them.
##
## The tower is a stack of art slots assembled in one 432 x 720 frame (FRAME, frame px): fourteen body parts drawn in
## a fixed order (PARTS, the order column), two ground wings at its foot, and the small movers the game animates.
## Every part has a coded blockout painted here, ported from mock_tower.py beside the design doc, so Codex and Grok can
## paint one part at a time: ArtSlots.texture() serves their file once it is installed at exactly the slot's size, and
## this blockout until then. The slot rows live in scripts/art/slots/town_tower.gd (the depot's in town_buildings.gd).
##
## place() stands the whole tower under a parent: one Node2D "WaylineTower" with a sprite per part in draw order, the
## door leaves, the ground wings, and the life (lamp flicker and glow, route lanterns, the hoist basket, cradles on the
## waylines, parcels down the chute, chimney smoke). The rest is for the scenes that frame the tower: assembled_image()
## (the whole blockout as one picture), paint_far() (the tower painted for a far view), wayline() (a cable) and
## long_shadow() (the tower's shadow on the plaza).
##
## On Tower Rise the frame's top-left sits at world (96, -504), so the door is at world (288, 150), the same place as
## the old Hall's door, and the lamp's glass at (312, -386) on the door axis.

const Finish := preload("res://scripts/town/exterior_finish.gd")

# ---------------------------------------------------------------------------------------------------------------------
# Sizes and anchors (frame px: x right, y down, from the frame's top-left)

const FRAME := Vector2i(432, 720)          # 18 x 30 tiles
const FOOT_ROW := 719                      # the frame row the tower stands on (world row 215 on Tower Rise)
const BEACON := Vector2i(216, 118)         # the Waiting Lamp's glass, on the door axis
const APEX := Vector2i(183, 1)             # the vane's tip, the top of the tower
const DOOR := Rect2i(192, 654, 48, 64)     # the 48 x 64 double door: the depot's door_px plus DEPOT_AT
const DEPOT_AT := Vector2i(66, 528)        # the depot's top-left in the frame
const DEPOT_DOOR := Rect2i(126, 126, 48, 64)   # the door inside the depot's own 300 x 192 canvas (its slot's door_px)
const RISE_ORIGIN := Vector2(96, -504)     # the frame's top-left on Tower Rise (world px)
const DOOR_ROW_Z := 192                    # the tower sorts at its door row: row 8 x 24 px on Tower Rise
const CAMERA_LEAN := 72                    # px the town camera leans up while the player stands at the doors (approved default)
const WAYLINE_Z := 2000                    # waylines hang in the air, over everything standing on the ground
const SHADOW_Z := 1                        # the long shadow lies on the ground, under anything standing on it

const KEY := "town.building.hall.key"      # the whole-tower style key: refs only, never installed, never placed
const DEPOT := "town.building.hall"        # the door part keeps the old Hall's id, so rooms and saves are unchanged
const LANTERN := "town.building.hall.route_lantern"
const LAMP := "town.building.hall.lamp"
const BELL := "town.building.hall.bell"
const HOIST := "town.building.hall.hoist"
const YARD := "town.building.hall.yard"
const VANE := "town.building.hall.vane"
const POST := "town.prop.hall.wayline_post"
const STAIR := "town.prop.hall.rise_stair"
const BASKET := "town.prop.hall.basket"
const CRADLE := "town.prop.hall.cradle"
const PARCEL := "town.prop.hall.parcel"
const PLACEHOLDER_HOOK := "res://scripts/town/tower_parts.gd:paint_slot"

## Every part of the tower (TOWER_DESIGN.md section 5), in draw order. "rect" is the part's place in the frame (a
## prop's rect is just its size: the game decides where it goes). "layer": body parts draw as one group at the door
## row; the two ground wings sort one step in front of it; props are the small things the game places (the seven
## route lanterns hang in the body's order, under the Reel Deck rim). "foot" is the frame row the part sorts on, or
## its own foot row for a prop that stands on the ground, or -1 for one that rides or hangs.
const PARTS := [
	{"id": "town.building.hall", "name": "depot", "rect": Rect2i(66, 528, 300, 192), "layer": "body", "order": 1, "foot": 719},
	{"id": "town.building.hall.drum", "name": "drum", "rect": Rect2i(104, 368, 225, 236), "layer": "body", "order": 2, "foot": 719},
	{"id": "town.building.hall.hoist", "name": "hoist", "rect": Rect2i(304, 460, 88, 56), "layer": "body", "order": 3, "foot": 719},
	{"id": "town.building.hall.galleries", "name": "galleries", "rect": Rect2i(88, 252, 217, 206), "layer": "body", "order": 4, "foot": 719},
	{"id": "town.building.hall.root_vein", "name": "root_vein", "rect": Rect2i(80, 326, 60, 296), "layer": "body", "order": 5, "foot": 719},
	{"id": "town.building.hall.chute", "name": "chute", "rect": Rect2i(244, 336, 88, 290), "layer": "body", "order": 6, "foot": 719},
	{"id": "town.building.hall.gable", "name": "gable", "rect": Rect2i(164, 560, 104, 53), "layer": "body", "order": 7, "foot": 719},
	{"id": "town.building.hall.reel_back", "name": "reel_back", "rect": Rect2i(88, 198, 225, 93), "layer": "body", "order": 8, "foot": 719},
	{"id": "town.building.hall.reach", "name": "reach", "rect": Rect2i(128, 24, 104, 300), "layer": "body", "order": 9, "foot": 719},
	{"id": "town.building.hall.ring_front", "name": "ring_front", "rect": Rect2i(84, 286, 232, 60), "layer": "body", "order": 10, "foot": 719},
	{"id": "town.building.hall.route_lantern", "name": "route_lantern", "rect": Rect2i(0, 0, 12, 20), "layer": "prop", "order": 11, "foot": -1},
	{"id": "town.building.hall.bell", "name": "bell", "rect": Rect2i(40, 232, 56, 90), "layer": "body", "order": 12, "foot": 719},
	{"id": "town.building.hall.lamp", "name": "lamp", "rect": Rect2i(200, 92, 32, 42), "layer": "body", "order": 13, "foot": 719},
	{"id": "town.building.hall.vane", "name": "vane", "rect": Rect2i(164, 0, 48, 44), "layer": "body", "order": 14, "foot": 719},
	{"id": "town.building.hall.root_foot", "name": "root_foot", "rect": Rect2i(0, 600, 96, 120), "layer": "ground", "order": 15, "foot": 719},
	{"id": "town.building.hall.yard", "name": "yard", "rect": Rect2i(360, 616, 72, 104), "layer": "ground", "order": 16, "foot": 719},
	{"id": "town.prop.hall.wayline_post", "name": "wayline_post", "rect": Rect2i(0, 0, 24, 64), "layer": "prop", "order": 17, "foot": 63},
	{"id": "town.prop.hall.rise_stair", "name": "rise_stair", "rect": Rect2i(0, 0, 48, 96), "layer": "prop", "order": 18, "foot": 95},
	{"id": "town.prop.hall.basket", "name": "basket", "rect": Rect2i(0, 0, 16, 16), "layer": "prop", "order": 19, "foot": -1},
	{"id": "town.prop.hall.cradle", "name": "cradle", "rect": Rect2i(0, 0, 12, 14), "layer": "prop", "order": 20, "foot": -1},
	{"id": "town.prop.hall.parcel", "name": "parcel", "rect": Rect2i(0, 0, 10, 8), "layer": "prop", "order": 21, "foot": -1},
]

## The seven route lanterns and sheaves, by their angle round the Reel Deck ring (degrees, 0 = right, 90 = front).
const LANTERN_T := [18, 42, 66, 90, 114, 138, 162]
## Their states at first (story flags will drive them): lit while a runner is out on that route, dark when it is
## idle, and one quiet for the route that went quiet (Hollow shown as absence, never a ghost).
const LANTERN_STATES := ["lit", "dark", "lit", "lit", "dark", "quiet", "dark"]
## The Route Board on the gable: three waymark arms meeting at a knot, and which of its 8 pegs are lit at first
## (one per runner out). The pegs are lit by the game, so the painted board shows dark sockets only.
const PEG_KNOT := Vector2(215, 600)
const ROUTE_ARMS := [Vector2(196, 586), Vector2(215, 584), Vector2(236, 587)]
const PEGS_LIT := [1, 4]
## The waylines on Tower Rise (mock_tower.py): from a sheave to a post's pulley at tiles (2, 10) and (24, 10), and two
## off the south cliff toward the Street. "to" is in frame px. A line from the quiet route's sheave hangs slack.
const RISE_LINES := [
	{"sheave": 6, "to": Vector2(-36, 711), "sag": 40.0},
	{"sheave": 0, "to": Vector2(492, 711), "sag": 40.0},
	{"sheave": 5, "to": Vector2(-56, 840), "sag": 34.0},
	{"sheave": 1, "to": Vector2(510, 840), "sag": 34.0},
]
## A wayline post (town.prop.hall.wayline_post) stands with its foot here and takes its line at its pulley.
const POST_FOOT := Vector2i(12, 63)
const POST_PULLEY := Vector2i(12, 7)
## The hoist: the rope hangs from the pulley block, the basket rides it between the yard and the hoist door.
const PULLEY := Vector2(385, 488)
const BASKET_LOW := 634.0       # the basket's top row when it rests on the yard's capstan
const BASKET_HIGH := 492.0      # and when it is up under the pulley
const CHUTE_MOUTH := Vector2(262, 344)
const CHUTE_SPOUT := Vector2(322, 612)
const CHIMNEY := Vector2(341, 524)

# ---------------------------------------------------------------------------------------------------------------------
# The locked wayline_tower palette (section 10): the house's town_stone colours, brass, bronze, ink and the courier's
# teal sampled from the courier's walk sheet. Every part paints from these and nothing else.

const INK := Color("#0b0e11")
const STONE := {"hi": Color("#f5d9a8"), "lit": Color("#e6c697"), "mid": Color("#ccb290"), "sh": Color("#9c8c68"), "dk": Color("#5f5e57")}
const BOULD := {"hi": Color("#c7a378"), "lit": Color("#9c8c68"), "mid": Color("#8e7f5e"), "sh": Color("#5f5e57"), "dk": Color("#3f2716")}
const BRICK := {"hi": Color("#c49b69"), "lit": Color("#b06b3d"), "mid": Color("#8c6545"), "sh": Color("#663f23"), "dk": Color("#3f2716")}
const TIMB := {"hi": Color("#92724b"), "lit": Color("#8c6545"), "mid": Color("#5d4b34"), "sh": Color("#3f2716"), "dk": Color("#23180e")}
const ROOTC := {"hi": Color("#c49b69"), "lit": Color("#b06b3d"), "mid": Color("#663f23"), "sh": Color("#3f2716"), "dk": Color("#23180e")}
const MOSS := {"hi": Color("#c6bb2a"), "lit": Color("#908940"), "mid": Color("#6b6f1d"), "sh": Color("#44421a"), "dk": Color("#44421a")}
const BRASS := {"hi": Color("#f2d27a"), "lit": Color("#d4a94c"), "mid": Color("#a37a32"), "sh": Color("#6b4f1f"), "dk": Color("#3f2716")}
const AMBER := {"hi": Color("#fbd490"), "lit": Color("#f1c177"), "mid": Color("#ecb36b"), "sh": Color("#dca562"), "dk": Color("#c49243")}
const PLAST := {"hi": Color("#f5d9a8"), "lit": Color("#f5d9a8"), "mid": Color("#e6c697"), "sh": Color("#c7a378"), "dk": Color("#9c8c68")}
const BRONZE := {"hi": Color("#dca562"), "lit": Color("#b8793e"), "sh": Color("#7c4a26")}
const TEAL := {"hi": Color("#2d9e9f"), "lit": Color("#12837f"), "mid": Color("#07515c"), "sh": Color("#00313a")}
const OIL := Color("#6b6d45")
const PARCH := Color("#e6c697")
const TWINE := Color("#c49243")
const CLEAR := Color(0, 0, 0, 0)
const HAZE := Color("#a3a891")      # the far view's air (mock_tower.py mock_far)
const SMOKE := Color("#d6ccb8")
## The lamp's glow (_place_glow): [how far out, 1 being its edge; how strong; its light], inside out, and its half size
## round the lamp's middle (the lamp itself is 23 x 29). The light deepens through the amber ramp as it falls off, as
## lamplight does (pass 9 W4, H9-01: brass-light in every step added a green-grey cast to the slate sky).
const GLOW_STEPS := [[0.62, 0.35, "mid"], [0.82, 0.2, "sh"], [1.0, 0.1, "dk"]]
const GLOW_HALF := Vector2i(25, 27)
## The 36 colours of the family, so a check can hold every painted part to it (C5 lock).
const PALETTE := [
	"#0b0e11", "#f5d9a8", "#e6c697", "#ccb290", "#9c8c68", "#5f5e57", "#c7a378", "#8e7f5e", "#3f2716", "#c49b69",
	"#b06b3d", "#8c6545", "#663f23", "#92724b", "#5d4b34", "#23180e", "#c6bb2a", "#908940", "#6b6f1d", "#44421a",
	"#f2d27a", "#d4a94c", "#a37a32", "#6b4f1f", "#fbd490", "#f1c177", "#ecb36b", "#dca562", "#c49243", "#b8793e",
	"#7c4a26", "#6b6d45", "#2d9e9f", "#12837f", "#07515c", "#00313a",
]

static var _cells := {}   # "id|state|frame" -> the painted cell, so each blockout is painted once a session
static var _pal: Array[Color] = []   # PALETTE as colours, for _nearest
static var _near := {}   # an 8-bit colour -> its nearest family colour, filled as shrink() meets them


# ---------------------------------------------------------------------------------------------------------------------
# The table

## The PARTS row for a slot id ({} when the id is not a tower part).
static func part(id: String) -> Dictionary:
	for p in PARTS:
		if String(p["id"]) == id:
			return p
	return {}


## Part ids in draw order; `layer` ("body", "ground", "prop") filters when given.
static func ids(layer: String = "") -> PackedStringArray:
	var out: PackedStringArray = []
	for p in PARTS:
		if layer == "" or String(p["layer"]) == layer:
			out.append(String(p["id"]))
	return out


## The parts drawn as the body group, in order: the fourteen body parts with the route lanterns at their place (11).
static func body_order() -> PackedStringArray:
	var out: PackedStringArray = []
	for p in PARTS:
		if String(p["layer"]) == "body" or String(p["id"]) == LANTERN:
			out.append(String(p["id"]))
	return out


## A point on the Reel Deck ring at angle t (degrees), dy px below the deck's edge.
static func ring_pt(t: float, dy: float = 0.0) -> Vector2:
	return Vector2(200.0 + 112.0 * cos(deg_to_rad(t)), 290.0 + 44.0 * sin(deg_to_rad(t)) + dy)


## The brass sheave where wayline i ties off (frame px).
static func sheave(i: int) -> Vector2:
	return ring_pt(LANTERN_T[i], -2.0)


## The top-left of route lantern i, hung under the rim below its sheave (frame px).
static func lantern_at(i: int) -> Vector2i:
	var p := ring_pt(LANTERN_T[i], 8.0)
	return Vector2i(Cv.rnd(p.x - 6.0), Cv.rnd(p.y - 1.0))


## The Route Board's 8 peg sockets (frame px): two and three along the arms, and one at the knot where they meet
## (the mock's peg list held seven; the design and the brief say eight).
static func route_pegs() -> Array[Vector2]:
	var out: Array[Vector2] = []
	var ks := [[0.45, 0.8], [0.4, 0.72, 0.98], [0.45, 0.8]]
	for i in 3:
		var arm: Vector2 = ROUTE_ARMS[i]
		for k in ks[i]:
			out.append(PEG_KNOT + (arm - PEG_KNOT) * float(k))
	out.append(PEG_KNOT)
	return out


## The tower's points in its parent's px when its frame's top-left is at `origin`: the door rect and its middle, the
## foot (bottom middle under the door), the beacon (the lamp's glass) and the apex (the vane's tip).
static func points(origin: Vector2) -> Dictionary:
	return {"frame": Rect2(origin, Vector2(FRAME)), "door_rect": Rect2(origin + Vector2(DOOR.position), Vector2(DOOR.size)),
		"door": origin + Vector2(DOOR.get_center()), "foot": origin + Vector2(DOOR.get_center().x, FOOT_ROW),
		"beacon": origin + Vector2(BEACON), "apex": origin + Vector2(APEX), "height": FRAME.y}


# ---------------------------------------------------------------------------------------------------------------------
# The coded blockout

## The placeholder hook every tower slot row names ("res://scripts/town/tower_parts.gd:paint_slot"): the part's whole
## sheet, every state row and frame, at exactly the row's sheet_size. The key is the assembled blockout at half size.
## null for an id that is not a tower part, so ArtSlots falls back to the shared kind painter.
static func paint_slot(id: String, spec: Dictionary) -> Image:
	if id == KEY:
		var key := assembled_image()
		var size: Vector2i = spec.get("size", Vector2i(FRAME.x / 2, FRAME.y / 2))
		key.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
		return key
	var p := part(id)
	if p.is_empty():
		return null
	var cell: Vector2i = (p["rect"] as Rect2i).size
	var states: Dictionary = spec.get("states", {"static": [1, 0]})
	var most := 1
	for st in states:
		most = maxi(most, int(states[st][0]))
	var sheet := Image.create(cell.x * most, cell.y * maxi(1, states.size()), false, Image.FORMAT_RGBA8)
	var row := 0
	for st in states:
		for f in maxi(1, int(states[st][0])):
			sheet.blit_rect(_cell(id, String(st), f), Rect2i(Vector2i.ZERO, cell), Vector2i(f * cell.x, row * cell.y))
		row += 1
	return sheet


## One cell of a part's blockout (a copy): `state` as its slot row names it ("" for the first), frame `f`.
static func paint_part(id: String, state: String = "", f: int = 0) -> Image:
	return _cell(id, state, f).duplicate() as Image


## The whole tower as one 432 x 720 picture, every part's blockout composed in draw order: the body, the route
## lanterns in their states and the lit Route Board pegs at their places, then the ground wings. With `installed`,
## a part whose painted file is installed shows that file instead of its blockout (the title's Highbank view asks for
## this, so Codex's parts reach the title as they land); the key and the checks keep the blockout.
static func assembled_image(lanterns: Array = LANTERN_STATES, pegs_lit: Array = PEGS_LIT, installed: bool = false) -> Image:
	var img := Image.create(FRAME.x, FRAME.y, false, Image.FORMAT_RGBA8)
	for p in PARTS:
		var id := String(p["id"])
		var name := String(p["name"])
		var rect: Rect2i = p["rect"]
		if name == "route_lantern":
			for i in LANTERN_T.size():
				var lan := _shown(LANTERN, String(lanterns[i]) if i < lanterns.size() else "dark", installed)
				img.blend_rect(lan, Rect2i(Vector2i.ZERO, lan.get_size()), lantern_at(i))
			continue
		if String(p["layer"]) == "prop":
			continue
		var cell := _shown(id, "", installed)
		img.blend_rect(cell, Rect2i(Vector2i.ZERO, rect.size), rect.position)
		if name == "gable":
			var pegs := route_pegs()
			for k in pegs_lit:
				var at := pegs[int(k)]
				img.fill_rect(Rect2i(Cv.rnd(at.x - 1.0), Cv.rnd(at.y - 1.0), 3, 3), AMBER.hi)
	return img


## A part's first frame of `state` for assembled_image(): its installed file's cell when `installed` is asked for and
## a file is there at the slot's size (ArtSlots.source() "file"), else the coded blockout. The file test comes first,
## so nothing is painted or loaded while no part is installed.
static func _shown(id: String, state: String, installed: bool) -> Image:
	if not installed:
		return _cell(id, state, 0)
	var spec := ArtSlots.spec(id)
	var path := String(spec.get("file", ""))
	if path == "" or not (FileAccess.file_exists(path) or ResourceLoader.exists(path)) or ArtSlots.source(id) != "file":
		return _cell(id, state, 0)
	var names: Array = (spec.get("states", {}) as Dictionary).keys()
	var row := maxi(0, names.find(state)) if state != "" else 0
	var size: Vector2i = spec["size"]
	return ArtSlots.image(id).get_region(Rect2i(Vector2i(0, row * size.y), size))


static func _cell(id: String, state: String, f: int) -> Image:
	var key := "%s|%s|%d" % [id, state, f]
	if _cells.has(key):
		return _cells[key]
	var p := part(id)
	var cv := Cv.new(p.get("rect", Rect2i(0, 0, 1, 1)))
	var rng := RandomNumberGenerator.new()
	rng.seed = 11 + int(p.get("order", 0)) * 1009   # a fixed seed per part: the moss and bark land the same each time
	match String(p.get("name", "")):
		"depot":
			_depot(cv, rng)
		"drum":
			_drum(cv, rng)
		"hoist":
			_hoist(cv, f)
		"galleries":
			_galleries(cv)
		"root_vein":
			_root_vein(cv, rng)
		"chute":
			_chute(cv)
		"gable":
			_gable(cv)
		"reel_back":
			_reel_back(cv)
		"reach":
			_reach(cv, rng)
		"ring_front":
			_ring_front(cv)
		"route_lantern":
			_lantern(cv, state, f)
		"bell":
			_bell(cv, state, f)
		"lamp":
			_lamp(cv, state, f)
		"vane":
			_vane(cv, f)
		"root_foot":
			_root_foot(cv, rng)
		"yard":
			_yard(cv, f)
		"wayline_post":
			_post(cv, state)
		"rise_stair":
			_stair(cv)
		"basket":
			_basket(cv, state != "empty")
		"cradle":
			_cradle(cv, state, f)
		"parcel":
			_parcel(cv, state)
	_cells[key] = cv.img
	return cv.img


# ---------------------------------------------------------------------------------------------------------------------
# Drawing helpers (mock_tower.py's, one for one)

## A part's own image, addressed in frame px (the numbers of the design doc and mock_tower.py), so each part paints
## with the coordinates it has in the assembled tower. Shapes overwrite what is under them (a clear shape cuts a hole),
## as the mock's drawing does, and coordinates round the way Python's round() does (halves go to the even neighbour).
class Cv:
	var ox := 0
	var oy := 0
	var img: Image

	func _init(r: Rect2i) -> void:
		ox = r.position.x
		oy = r.position.y
		img = Image.create(maxi(1, r.size.x), maxi(1, r.size.y), false, Image.FORMAT_RGBA8)

	## Python's round(): a half goes to the even neighbour, so a ported coordinate lands on the mock's pixel.
	static func rnd(v: float) -> int:
		var f := floorf(v)
		var d := v - f
		if d > 0.5:
			return int(f) + 1
		if d < 0.5:
			return int(f)
		return int(f) if posmod(int(f), 2) == 0 else int(f) + 1

	## A filled box, both corners inclusive.
	func rect(x0: float, y0: float, x1: float, y1: float, c: Color) -> void:
		var a := rnd(x0)
		var b := rnd(y0)
		var e := rnd(x1)
		var f := rnd(y1)
		if e < a or f < b:
			return
		_fill(Rect2i(a - ox, b - oy, e - a + 1, f - b + 1), c)

	## A filled ellipse round the centre pixel, rx and ry px out to each side (its box is 2 rx + 1 by 2 ry + 1).
	func ell(cx: float, cy: float, rx: float, ry: float, c: Color) -> void:
		var a := maxi(0, rnd(rx))
		var b := maxi(0, rnd(ry))
		var x := rnd(cx) - ox
		var y := rnd(cy) - oy
		for dy in range(-b, b + 1):
			var t := 1.0 - pow(dy / (b + 0.5), 2.0)
			var half := int(floorf((a + 0.5) * sqrt(maxf(0.0, t)) + 0.0001))
			_fill(Rect2i(x - half, y + dy, 2 * half + 1, 1), c)

	## A filled polygon (its edges included).
	func poly(pts: Array, c: Color) -> void:
		var q: Array[Vector2i] = []
		for p: Vector2 in pts:
			q.append(Vector2i(rnd(p.x - ox), rnd(p.y - oy)))
		var y0 := q[0].y
		var y1 := q[0].y
		for p in q:
			y0 = mini(y0, p.y)
			y1 = maxi(y1, p.y)
		for y in range(y0, y1 + 1):
			var xs: Array[float] = []
			for i in q.size():
				var a := q[i]
				var b := q[(i + 1) % q.size()]
				if a.y == b.y or y < mini(a.y, b.y) or y >= maxi(a.y, b.y):
					continue
				xs.append(a.x + float(y - a.y) * float(b.x - a.x) / float(b.y - a.y))
			xs.sort()
			for k in range(0, xs.size() - 1, 2):
				var xa := ceili(xs[k])
				var xb := floori(xs[k + 1])
				if xb >= xa:
					_fill(Rect2i(xa, y, xb - xa + 1, 1), c)
		for i in q.size():
			_bres(q[i], q[(i + 1) % q.size()], c)

	## A line through the points, w px wide.
	func line(pts: Array, c: Color, w: int = 1) -> void:
		for i in pts.size() - 1:
			var p0: Vector2 = pts[i]
			var p1: Vector2 = pts[i + 1]
			var a := Vector2i(rnd(p0.x - ox), rnd(p0.y - oy))
			var b := Vector2i(rnd(p1.x - ox), rnd(p1.y - oy))
			if w <= 1:
				_bres(a, b, c)
			else:
				_wide(a, b, c, w)

	## One pixel.
	func px(x: float, y: float, c: Color) -> void:
		_put(rnd(x - ox), rnd(y - oy), c)

	func _fill(r: Rect2i, c: Color) -> void:
		var cut := r.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
		if cut.size.x > 0 and cut.size.y > 0:
			img.fill_rect(cut, c)

	func _put(x: int, y: int, c: Color) -> void:
		if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
			img.set_pixel(x, y, c)

	func _bres(a: Vector2i, b: Vector2i, c: Color) -> void:
		var dx := absi(b.x - a.x)
		var dy := -absi(b.y - a.y)
		var sx := 1 if a.x < b.x else -1
		var sy := 1 if a.y < b.y else -1
		var err := dx + dy
		var p := a
		while true:
			_put(p.x, p.y, c)
			if p == b:
				break
			var e2 := 2 * err
			if e2 >= dy:
				err += dy
				p.x += sx
			if e2 <= dx:
				err += dx
				p.y += sy

	## A band w px across centred on the segment: every pixel whose centre is within it.
	func _wide(a: Vector2i, b: Vector2i, c: Color, w: int) -> void:
		var d := Vector2(b - a)
		var length := d.length()
		if length == 0.0:
			_fill(Rect2i(a.x - (w - 1) / 2, a.y - (w - 1) / 2, w, w), c)
			return
		var u := d / length
		var n := Vector2(-u.y, u.x)
		var half := w / 2.0
		for y in range(mini(a.y, b.y) - w, maxi(a.y, b.y) + w + 1):
			for x in range(mini(a.x, b.x) - w, maxi(a.x, b.x) + w + 1):
				var q := Vector2(x - a.x, y - a.y)
				var along := q.dot(u)
				var across := q.dot(n)
				if along >= -0.5 and along <= length + 0.5 and across >= -half and across < half:
					_put(x, y, c)


## How far below (or above) a cylinder's middle row its edge is at column x: the plan ellipse's half-height there.
static func _ef(cx: float, rad: float, ry: float, x: float) -> float:
	var u := (x - cx) / rad
	return ry * sqrt(maxf(0.0, 1.0 - u * u)) if absf(u) <= 1.0 else 0.0


## The colour of a cylinder's band at fraction f across it, lit from the left: highlight, lit, mid, shade, dark.
static func _cyl_col(m: Dictionary, f: float) -> Color:
	if f >= 0.06 and f < 0.12:
		return m.hi
	if f < 0.32:
		return m.lit
	if f < 0.66:
		return m.mid
	if f < 0.90:
		return m.sh
	return m.dk


## A cylinder's front face, one column at a time, each column shaded by where it sits across the cylinder (so every
## drum shades on the same fixed frame columns).
static func _cyl_face(cv: Cv, cx: int, rad: int, ry: float, ytop: float, yfoot: float, m: Dictionary) -> void:
	for x in range(cx - rad, cx + rad + 1):
		var f := float(x - (cx - rad)) / float(2 * rad + 1)
		var e := _ef(cx, rad, ry, x)
		cv.rect(x, ytop + e, x, yfoot + e, _cyl_col(m, f))


## A band round a cylinder, d0 to d1 px below its top edge, in material m (between columns xa and xb when given).
static func _band(cv: Cv, cx: int, rad: int, ry: float, ytop: float, d0: float, d1: float, m: Dictionary, xa: int = -100000, xb: int = -100000) -> void:
	var a := cx - rad if xa == -100000 else xa
	var b := cx + rad if xb == -100000 else xb
	for x in range(a, b + 1):
		var f := float(x - (cx - rad)) / float(2 * rad + 1)
		var e := _ef(cx, rad, ry, x)
		cv.rect(x, ytop + e + d0, x, ytop + e + d1, _cyl_col(m, f))


## A round deck seen from above: the lip (its shadow edge), the lit rim, the top plane, an ink line under the lip, and
## moss specks scattered on it when a random source is given.
static func _deck(cv: Cv, cx: float, cy: float, rx: float, ry: float, top: Color, lip: int = 3, lipc: Color = Color("#9c8c68"), rng: RandomNumberGenerator = null, moss: int = 0) -> void:
	cv.ell(cx, cy + lip, rx, ry, lipc)
	cv.ell(cx, cy, rx, ry, STONE.hi if top != MOSS.lit else MOSS.hi)
	cv.ell(cx + 2, cy + 1, rx - 1, ry - 1, top)
	for x in range(int(cx - rx), int(cx + rx) + 1):
		cv.px(x, cy + _ef(cx, rx, ry, x) + lip + 1, INK)
	if rng != null:
		for _i in moss:
			var a := rng.randf_range(0.0, TAU)
			var k := rng.randf_range(0.55, 0.95)
			var mx := cx + cos(a) * rx * k
			var my := cy + sin(a) * ry * k
			cv.ell(mx, my, rng.randi_range(2, 4), rng.randi_range(1, 2), MOSS.lit)
			cv.px(mx - 1, my - 1, MOSS.hi)


## A round window, 12 to 14 px: a stone ring, a shadowed reveal, warm glass or dark, a cross mullion, a stone sill,
## and timber shutters either side when asked.
static func _round_window(cv: Cv, x: float, y: float, r: int, lit: bool = true, shutters: bool = false, mull: bool = true) -> void:
	if shutters:
		cv.rect(x - r - 4, y - r, x - r - 1, y + r, TIMB.lit)
		cv.rect(x + r + 1, y - r, x + r + 4, y + r, TIMB.mid)
	cv.ell(x, y, r + 1, r + 1, STONE.hi)
	cv.ell(x + 1, y + 1, r + 1, r + 1, TIMB.sh)
	cv.ell(x, y, r, r, AMBER.lit if lit else TIMB.dk)
	if lit:
		cv.ell(x - 1, y - 1, maxi(1, r - 3), maxi(1, r - 3), AMBER.hi)
	if mull:
		cv.rect(x, y - r, x, y + r, INK)
		cv.rect(x - r, y, x + r, y, INK)
	cv.rect(x - r, y + r + 1, x + r, y + r + 2, STONE.hi)


## Points every px along a path of (x, y, thickness) points.
static func _sample_path(pts: Array) -> Array:
	var out: Array = []
	for i in pts.size() - 1:
		var a: Vector3 = pts[i]
		var b: Vector3 = pts[i + 1]
		var n := maxi(1, int(Vector2(b.x - a.x, b.y - a.y).length()))
		for j in n:
			out.append(a.lerp(b, float(j) / n))
	out.append(pts[pts.size() - 1])
	return out


## A rounded tube along a path of (x, y, thickness) points: a root or a rootlet. Shadow down-right, the body, a lit
## streak up-left, bark grain when a random source is given, and worn treads every 9 px for the Climb.
static func _tube(cv: Cv, pts: Array, m: Dictionary, treads: bool = false, gloss: bool = false, rng: RandomNumberGenerator = null) -> void:
	var s := _sample_path(pts)
	for p: Vector3 in s:
		cv.ell(p.x + 1.5, p.y + 1.5, p.z / 2.0, p.z / 2.0, m.sh)
	for p: Vector3 in s:
		cv.ell(p.x, p.y, p.z / 2.0 - 1.5, p.z / 2.0 - 1.5, m.mid)
	for p: Vector3 in s:
		cv.ell(p.x - p.z * 0.17, p.y - p.z * 0.17, p.z * 0.24, p.z * 0.24, m.lit)
	if gloss:
		for p: Vector3 in s:
			if p.z * 0.09 >= 1.0:
				cv.ell(p.x - p.z * 0.28, p.y - p.z * 0.28, p.z * 0.09, p.z * 0.09, m.hi)
	if rng != null and s.size() > 2:
		for _i in maxi(4, s.size() / 4):
			var i := rng.randi_range(1, s.size() - 2)
			var p: Vector3 = s[i]
			var after: Vector3 = s[i + 1]
			var before: Vector3 = s[i - 1]
			var d := Vector2(after.x - before.x, after.y - before.y)
			var l := d.length()
			d = d / (l if l > 0.0 else 1.0)
			var off := rng.randf_range(-0.32, 0.4) * p.z
			var q := Vector2(p.x - d.y * off, p.y + d.x * off)
			var ln := rng.randi_range(3, 8)
			cv.line([q, q + d * ln], m.sh if off > -0.05 * p.z else m.mid)
	if treads:
		# Worn treads at an uneven stride, 2 or 3 px of polished bark on the lit side: climbed, not a ladder's rungs
		# (the 2026-10-27 look pass found even pale ticks every 9 px read as a ladder).
		var strides := [11, 8, 14, 9, 12]
		var i := 5
		var k := 0
		while i < s.size():
			var p: Vector3 = s[i]
			var x0 := p.x - p.z * 0.3
			var y0 := p.y - p.z * 0.3
			cv.rect(x0, y0, x0 + 1 + k % 2, y0, ROOTC.hi)
			cv.rect(x0, y0 + 1, x0 + 1 + k % 2, y0 + 1, ROOTC.sh)
			i += int(strides[k % strides.size()])
			k += 1


## A knot in the bark.
static func _knot(cv: Cv, x: float, y: float, r: int, m: Dictionary = ROOTC) -> void:
	cv.ell(x + 1, y + 1, r, r * 0.8, m.sh)
	cv.ell(x, y, r - 1, (r - 1) * 0.8, m.mid)
	cv.px(x - 1, y - 1, m.lit)
	cv.px(x + r - 1, y + 1, INK)


# ---------------------------------------------------------------------------------------------------------------------
# The parts (frame px), bottom to top

## T1, the depot (the door part, town.building.hall): roof deck seen from above, parapet, limestone and loess brick
## front on a boulder footing, the runners' porch, the First Post, the grand arch with its fan-light and double door,
## and the loading bay, chute bin, burrow hatch and high-water cuts.
static func _depot(cv: Cv, rng: RandomNumberGenerator) -> void:
	# The roof deck, seen from above (mostly hidden by the drum).
	cv.rect(72, 536, 359, 599, STONE.mid)
	cv.rect(72, 536, 359, 538, MOSS.lit)
	for y in [552, 568, 584]:
		cv.rect(72, y, 359, y, STONE.sh)
	for x in range(84, 359, 22):
		cv.rect(x, 539, x, 599, STONE.sh)
	# A skylight, crates, an oilcloth parcel stack and the mess chimney.
	cv.rect(78, 552, 100, 566, TIMB.mid)
	cv.rect(80, 554, 98, 564, AMBER.lit)
	cv.rect(89, 554, 89, 564, INK)
	cv.rect(78, 576, 98, 593, TIMB.lit)
	cv.rect(78, 576, 98, 578, TIMB.hi)
	cv.rect(88, 579, 88, 593, TIMB.sh)
	cv.rect(330, 574, 356, 596, OIL)
	cv.rect(330, 574, 356, 576, MOSS.lit)
	cv.rect(342, 574, 343, 596, TWINE)
	cv.rect(334, 528, 348, 566, BRICK.lit)
	cv.rect(344, 528, 348, 566, BRICK.sh)
	cv.rect(334, 528, 348, 530, INK)
	cv.rect(334, 540, 348, 540, BRICK.sh)
	# Rail posts on the visible deck strips.
	for x in [74, 82, 90, 98, 106, 326, 334, 342, 350, 358]:
		cv.rect(x, 591, x + 1, 597, TIMB.lit)
	cv.rect(72, 590, 107, 590, TIMB.hi)
	cv.rect(324, 590, 359, 590, TIMB.hi)
	# The parapet lip.
	cv.rect(66, 598, 365, 601, STONE.hi)
	cv.rect(66, 602, 365, 607, STONE.lit)
	cv.rect(66, 608, 365, 608, INK)
	# The front wall: limestone, grime toward the ground, two loess brick courses.
	cv.rect(72, 609, 359, 699, STONE.lit)
	cv.rect(72, 609, 359, 611, STONE.sh)
	cv.rect(72, 682, 359, 699, STONE.mid)
	for course in [[624, 628], [664, 667]]:
		cv.rect(72, course[0], 359, course[1], BRICK.lit)
		cv.rect(72, course[1] + 1, 359, course[1] + 1, BRICK.sh)
	# The boulder footing, flaring past the wall.
	cv.rect(66, 700, 365, 719, BOULD.sh)
	var x := 66
	while x < 362:
		var w := rng.randi_range(14, 26)
		var h := rng.randi_range(12, 18)
		cv.ell(x + w / 2.0, 719 - h / 2.0 + 1, w / 2.0, h / 2.0, BOULD.mid)
		cv.ell(x + w / 2.0 - 2, 719 - h / 2.0 - 1, w / 2.0 - 4, h / 2.0 - 4, BOULD.lit)
		cv.px(x + 3, 719 - h + 3, BOULD.hi)
		x += w - 2
	# The runners' porch, left: a moss awning on posts, satchel hooks (one empty: a runner is out), a bench, a window.
	_round_window(cv, 124, 642, 6)
	cv.rect(94, 626, 96, 712, TIMB.mid)
	cv.rect(152, 626, 154, 712, TIMB.mid)
	cv.ell(124, 617, 35, 9, MOSS.mid)
	cv.ell(122, 615, 33, 7, MOSS.lit)
	cv.ell(110, 611, 10, 3, MOSS.hi)
	cv.rect(89, 620, 159, 624, TIMB.lit)
	cv.rect(89, 620, 159, 620, TIMB.hi)
	cv.rect(89, 625, 159, 625, INK)
	var hooks := [104, 116, 128, 140]
	for i in hooks.size():
		var sx: int = hooks[i]
		cv.rect(sx + 3, 652, sx + 4, 654, BRASS.lit)
		if i != 2:
			cv.rect(sx, 655, sx + 7, 666, TEAL.lit)
			cv.rect(sx + 5, 655, sx + 7, 666, TEAL.sh)
			cv.rect(sx, 655, sx + 7, 656, TEAL.hi)
	cv.rect(102, 690, 146, 694, TIMB.lit)
	cv.rect(102, 695, 146, 696, TIMB.sh)
	cv.rect(104, 697, 106, 704, TIMB.sh)
	cv.rect(142, 697, 144, 704, TIMB.sh)
	cv.rect(108, 683, 117, 689, OIL)
	cv.rect(112, 683, 112, 689, TWINE)
	# The First Post: the old relay stone in the left jamb, with the patch worn pale by partners' hands.
	cv.rect(158, 668, 169, 717, BOULD.lit)
	cv.ell(163, 668, 5, 4, BOULD.lit)
	cv.rect(166, 666, 169, 717, BOULD.sh)
	cv.rect(161, 684, 164, 690, STONE.hi)
	# The grand arch, its fan-light with the three-route mullions, and the double door.
	cv.ell(216, 656, 46, 46, BRICK.lit)
	cv.ell(218, 658, 44, 44, BRICK.mid)
	cv.rect(170, 656, 261, 717, BRICK.lit)
	cv.rect(258, 656, 261, 717, BRICK.sh)
	cv.ell(216, 656, 40, 40, TIMB.dk)
	cv.rect(176, 656, 256, 717, TIMB.dk)
	cv.rect(170, 702, 261, 717, BOULD.mid)
	cv.rect(176, 656, 256, 717, TIMB.dk)
	cv.ell(216, 654, 34, 34, AMBER.lit)
	cv.ell(212, 650, 24, 24, AMBER.hi)
	cv.rect(176, 654, 256, 717, TIMB.dk)
	cv.line([Vector2(216, 654), Vector2(216, 620)], INK)
	cv.line([Vector2(216, 654), Vector2(192, 630)], INK)
	cv.line([Vector2(216, 654), Vector2(240, 630)], INK)
	cv.rect(190, 652, 241, 653, TIMB.sh)
	cv.rect(192, 654, 239, 717, TIMB.lit)
	cv.rect(216, 654, 239, 717, TIMB.mid)
	cv.rect(215, 654, 216, 717, INK)
	for y in [666, 700]:
		cv.rect(194, y, 237, y + 2, BRASS.lit)
		cv.rect(194, y + 2, 237, y + 2, BRASS.sh)
	cv.rect(211, 684, 212, 687, BRASS.hi)
	cv.rect(219, 684, 220, 687, BRASS.hi)
	cv.rect(186, 716, 245, 719, STONE.hi)
	cv.rect(211, 608, 221, 617, STONE.hi)
	cv.line([Vector2(216, 615), Vector2(216, 610)], INK)
	cv.line([Vector2(216, 615), Vector2(213, 611)], INK)
	cv.line([Vector2(216, 615), Vector2(219, 611)], INK)
	# The right side: the loading bay under its canopy, the chute bin, the burrow hatch and the high-water cuts.
	cv.rect(272, 650, 332, 653, BRICK.lit)
	cv.rect(276, 654, 328, 717, TIMB.lit)
	cv.rect(302, 654, 328, 717, TIMB.mid)
	cv.rect(301, 654, 302, 717, INK)
	cv.line([Vector2(278, 714), Vector2(299, 657)], TIMB.sh, 2)
	cv.line([Vector2(305, 714), Vector2(326, 657)], TIMB.sh, 2)
	cv.ell(302, 617, 33, 9, MOSS.mid)
	cv.ell(300, 615, 31, 7, MOSS.lit)
	cv.ell(290, 611, 9, 3, MOSS.hi)
	cv.rect(268, 620, 336, 624, TIMB.lit)
	cv.rect(268, 620, 336, 620, TIMB.hi)
	cv.rect(268, 625, 336, 625, INK)
	cv.rect(272, 626, 274, 712, TIMB.mid)
	_round_window(cv, 346, 640, 6)
	cv.rect(316, 698, 334, 717, TIMB.mid)
	cv.rect(316, 698, 334, 700, TIMB.hi)
	cv.rect(319, 692, 331, 699, OIL)
	cv.rect(325, 692, 325, 699, TWINE)
	cv.ell(349, 709, 8, 8, TIMB.sh)
	cv.ell(349, 709, 6, 6, TIMB.dk)
	cv.rect(343, 708, 355, 708, TIMB.mid)
	for y in [684, 692, 700]:
		cv.rect(354, y, 359, y, INK)
	cv.rect(357, 676, 358, 712, BRASS.mid)
	# Moss on the footing tops and the lower courses.
	for _i in 26:
		var mx := rng.randi_range(68, 362)
		var my := rng.randi_range(697, 703)
		cv.ell(mx, my, rng.randi_range(2, 4), 1, MOSS.lit)


## T2, the Sorting Drum: the cream river-stone cylinder, its contact shadow on the depot deck (it owns that seam), the
## root-beam ring, three round lit windows, the 6 x 3 cubby wall (two dark and empty), the hoist door, and its deck with
## the working landing on the right.
static func _drum(cv: Cv, rng: RandomNumberGenerator) -> void:
	var cx := 216
	var r := 108
	var ry := 44.0
	var yt := 416.0
	var yf := 552.0
	_cyl_face(cv, cx, r, ry, yt, yf, STONE)
	for x in range(cx - r, cx + r + 1):
		var e := _ef(cx, r, ry, x)
		cv.px(x, yf + e, INK)
		cv.rect(x, yf + e + 1, x, yf + e + 3, STONE.sh)
	_band(cv, cx, r, ry, yt, 12, 17, ROOTC)
	_band(cv, cx, r, ry, yt, 18, 18, {"hi": INK, "lit": INK, "mid": INK, "sh": INK, "dk": INK})
	for wx in [150, 196, 242]:
		_round_window(cv, wx, yt + _ef(cx, r, ry, wx) + 34, 6)
	_band(cv, cx, r, ry, yt, 58, 61, BRICK)
	# The cubby wall: 6 x 3 sorting cubbies, 10 x 9 each, two dark and empty.
	for x in range(146, 240):
		var e := _ef(cx, r, ry, x)
		cv.rect(x, yt + e + 76, x, yt + e + 119, TIMB.sh)
	var k := 0
	for row in 3:
		for col in 6:
			var x0 := 150 + col * 15
			var e := _ef(cx, r, ry, x0 + 5)
			var y0 := yt + e + 80 + row * 13
			var empty := (row == 0 and col == 4) or (row == 2 and col == 1)
			cv.rect(x0, y0, x0 + 10, y0 + 9, TIMB.dk if empty else AMBER.mid)
			if not empty:
				cv.rect(x0, y0, x0 + 10, y0 + 1, AMBER.hi)
				cv.rect(x0 + 2, y0 + 5, x0 + 8, y0 + 9, PARCH if k % 3 != 0 else OIL)
				cv.rect(x0 + 5, y0 + 5, x0 + 5, y0 + 9, TWINE)
			k += 1
	# The hoist door on the right flank.
	for x in range(306, 321):
		var e := _ef(cx, r, ry, x)
		cv.rect(x, yt + e + 30, x, yt + e + 64, TIMB.mid if x < 314 else TIMB.sh)
	# Moss along the lower courses.
	for _i in 30:
		var mx := rng.randi_range(cx - r + 4, cx + r - 4)
		var e := _ef(cx, r, ry, mx)
		cv.ell(mx, yt + e + rng.randi_range(124, 132), rng.randi_range(2, 4), 1, MOSS.lit)
	_deck(cv, cx, yt, r + 4, ry + 2, STONE.mid, 3, STONE.sh, rng, 16)
	# The visible right-hand terrace of the drum's deck is a working landing: a rail, a crate, a parcel.
	for x in range(252, 327, 7):
		var y := yt + _ef(cx, r + 4, ry + 2, x)
		cv.rect(x, y - 6, x + 1, y - 1, TIMB.lit)
	for x in range(252, 327):
		cv.px(x, yt + _ef(cx, r + 4, ry + 2, x) - 6, TIMB.hi)
	cv.rect(296, 418, 310, 431, TIMB.lit)
	cv.rect(296, 418, 310, 419, TIMB.hi)
	cv.rect(303, 420, 303, 431, TIMB.sh)
	cv.rect(312, 424, 321, 432, OIL)
	cv.rect(316, 424, 316, 432, TWINE)


## The hoist jib (right, low): a root-wood stub, the timber arm with iron straps, a diagonal brace, and the brass
## pulley block. Frame 1 turns the sheave (its highlight moves round).
static func _hoist(cv: Cv, f: int) -> void:
	cv.rect(306, 468, 322, 482, ROOTC.mid)
	cv.rect(306, 468, 322, 469, ROOTC.lit)
	cv.rect(316, 470, 386, 475, TIMB.lit)
	cv.rect(316, 470, 386, 471, TIMB.hi)
	cv.rect(316, 476, 386, 476, INK)
	for x in [334, 360]:
		cv.rect(x, 470, x + 1, 475, BRASS.sh)
	cv.line([Vector2(320, 508), Vector2(362, 477)], TIMB.mid, 3)
	cv.line([Vector2(321, 510), Vector2(363, 479)], INK)
	cv.rect(378, 476, 391, 488, BRASS.mid)
	cv.ell(384, 482, 4, 4, BRASS.lit)
	if f % 2 == 0:
		cv.px(382, 480, BRASS.hi)
		cv.px(386, 484, BRASS.sh)
	else:
		cv.px(386, 480, BRASS.hi)
		cv.px(382, 484, BRASS.sh)
	cv.rect(378, 488, 391, 488, INK)


## T3, the Galleries: the timber-and-plaster drum shifted left, stone under the plaster, its contact shadow on the
## drum's deck, timber bands and posts, 2-1-2 round shuttered windows, the timber walkway wrapping the front right
## (where the chute starts), the empty flyer boards and the ring perch on the left, and its deck.
static func _galleries(cv: Cv) -> void:
	var cx := 200
	var r := 84
	var ry := 34.0
	var yt := 288.0
	var yf := 416.0
	_cyl_face(cv, cx, r, ry, yt, yf, PLAST)
	_band(cv, cx, r, ry, yt, 92, 128, STONE)
	for x in range(cx - r, cx + r + 1):
		var e := _ef(cx, r, ry, x)
		cv.px(x, yf + e, INK)
		cv.rect(x, yf + e + 1, x, yf + e + 3, STONE.sh)
	for d in [[0, 3], [44, 47], [88, 91]]:
		_band(cv, cx, r, ry, yt, d[0], d[1], TIMB)
	for vx in [132, 158, 184, 210, 236, 262]:
		for x in [vx, vx + 1, vx + 2]:
			var e := _ef(cx, r, ry, x)
			cv.rect(x, yt + e + 4, x, yt + e + 88, TIMB.mid if x < cx + 30 else TIMB.sh)
	for wd in [[171, 22], [225, 22], [198, 66], [171, 110], [225, 110]]:
		_round_window(cv, wd[0], yt + _ef(cx, r, ry, wd[0]) + wd[1], 6, true, true)
	# The timber walkway gallery wrapping the front right, with the chute mouth.
	for x in range(204, 300):
		var yo := 342.0 + 40.0 * sqrt(maxf(0.0, 1.0 - pow((x - 200) / 98.0, 2.0)))
		var yi := 342.0 + 34.0 * sqrt(maxf(0.0, 1.0 - pow((x - 200) / 84.0, 2.0))) if x <= 284 else 336.0
		cv.rect(x, minf(yi, yo - 3), x, yo, TIMB.lit)
		cv.rect(x, yo + 1, x, yo + 3, TIMB.mid)
		cv.px(x, yo + 4, INK)
		if x % 8 == 0:
			cv.rect(x, yo - 7, x + 1, yo - 1, TIMB.hi)
		cv.px(x, yo - 7, TIMB.hi)
	# Flyer landing boards and a ring perch on the left face (always shown empty).
	for board in [[92, 362], [96, 404]]:
		var bx0: int = board[0]
		var by: int = board[1]
		cv.rect(bx0, by, 120, by + 2, TIMB.hi)
		cv.rect(bx0, by + 3, 120, by + 4, TIMB.sh)
		cv.line([Vector2(118, by + 12), Vector2(104, by + 5)], TIMB.mid, 2)
	cv.ell(102, 334, 4, 4, BRASS.lit)
	cv.ell(102, 334, 2, 2, CLEAR)
	cv.rect(106, 333, 118, 334, BRASS.sh)
	_deck(cv, cx, yt, r + 3, ry + 1, STONE.mid, 2)


## The Climb: the living root up the tower's left face in one run, from the root foot to the galleries, with worn
## treads, rootlets gripping the stone, knots and moss. It crosses the depot's roof deck and the drum's top on the way:
## over each setback's lip it bends across the deck with a 3 px shadow under it on the wall below, so it reads as one
## root and never as logs propped on the wall (the 2026-10-27 look pass; mock_tower.py dove it into the stone at each
## seam, which left rounded ends). An overlay that hides both seams, so Codex paints one continuous root.
static func _root_vein(cv: Cv, rng: RandomNumberGenerator) -> void:
	var run := [Vector3(90, 608, 17), Vector3(97, 592, 17), Vector3(103, 574, 16), Vector3(106, 556, 15), Vector3(106, 542, 15),
		Vector3(108, 528, 15), Vector3(107, 514, 15), Vector3(104, 494, 14), Vector3(103, 474, 14), Vector3(107, 452, 13),
		Vector3(113, 432, 13), Vector3(118, 410, 12), Vector3(121, 397, 11), Vector3(124, 384, 11), Vector3(127, 366, 10),
		Vector3(132, 350, 10), Vector3(138, 336, 9)]
	# The lips it bends over: [the lip's row, the root's middle there, its thickness]. The shadow shows right of the root.
	for lip in [[542, 106, 15], [410, 118, 12]]:
		cv.rect(lip[1] - lip[2] / 2, lip[0] + 1, lip[1] + lip[2] / 2 + 4, lip[0] + 3, BOULD.sh)
	_tube(cv, run, ROOTC, true, false, rng)
	for s in [[Vector3(105, 566, 6), Vector3(114, 570, 4), Vector3(121, 568, 3)], [Vector3(104, 486, 6), Vector3(113, 482, 4), Vector3(121, 484, 3)],
			[Vector3(116, 420, 5), Vector3(124, 416, 3)], [Vector3(128, 362, 5), Vector3(136, 366, 3)]]:
		_tube(cv, s, ROOTC)
	for kn in [[101, 582, 4], [104, 462, 3]]:
		_knot(cv, kn[0], kn[1], kn[2])
	for m in [[94, 596], [101, 532], [106, 446], [122, 378]]:
		cv.ell(m[0], m[1], 3, 2, MOSS.lit)
		cv.px(m[0] - 1, m[1] - 1, MOSS.hi)


## The parcel chute: a timber trough with brass edges and iron brackets from the galleries' walkway down to the bin on
## the depot deck, with a parcel waiting at the spout. An overlay that hides two seams.
static func _chute(cv: Cv) -> void:
	for y in range(344, 617):
		var xc := 262.0 + 60.0 * (y - 344) / 272.0
		cv.rect(xc - 5, y, xc + 5, y, TIMB.lit)
		cv.rect(xc - 5, y, xc - 4, y, TIMB.hi)
		cv.rect(xc + 2, y, xc + 5, y, TIMB.sh)
		cv.px(xc - 6, y, BRASS.lit)
		cv.px(xc + 6, y, BRASS.sh)
		cv.px(xc + 7, y, INK)
		if y % 14 == 0:
			cv.rect(xc - 5, y, xc + 5, y, TIMB.mid)
		if y % 48 == 20:
			cv.rect(xc + 7, y - 2, xc + 11, y + 2, INK)
	cv.poly([Vector2(252, 338), Vector2(274, 338), Vector2(269, 350), Vector2(257, 350)], TIMB.mid)
	cv.rect(252, 338, 274, 339, TIMB.hi)
	cv.rect(314, 612, 330, 617, TIMB.mid)
	cv.rect(314, 612, 330, 612, BRASS.lit)
	cv.rect(317, 618, 327, 625, PARCH)
	cv.rect(317, 625, 327, 625, STONE.sh)


## The Route Board gable over the arch: arched stone with a moss lip and brick ends, and the brass board with three
## waymark arms and 8 dark peg sockets (the game lights the pegs).
static func _gable(cv: Cv) -> void:
	cv.ell(216, 586, 48, 26, BRICK.lit)
	cv.ell(216, 586, 44, 22, STONE.lit)
	cv.rect(168, 586, 264, 612, STONE.lit)
	cv.rect(168, 586, 171, 612, BRICK.lit)
	cv.rect(261, 586, 264, 612, BRICK.sh)
	for x in range(168, 265):
		var e := _ef(216, 48, 26, x)
		cv.rect(x, 586 - e - 1, x, 586 - e, MOSS.lit)
	cv.rect(168, 609, 264, 612, STONE.sh)
	cv.rect(168, 612, 264, 612, INK)
	cv.rect(190, 580, 241, 605, BRASS.sh)
	cv.rect(191, 581, 240, 604, BRASS.lit)
	cv.rect(191, 581, 240, 582, BRASS.hi)
	for arm in ROUTE_ARMS:
		cv.line([PEG_KNOT, arm], BRASS.sh, 2)
	for p in route_pegs():
		cv.rect(p.x - 1, p.y - 1, p.x + 1, p.y + 1, INK)


## T4 back: the Reel Deck ring's back half (planks, radial joints, the back rail) and the dispatcher's loft standing
## in its middle (timber and brass, one big round lit window, a moss dome).
static func _reel_back(cv: Cv) -> void:
	var ocx := 200
	var ocy := 290
	var orx := 112
	var ory := 44
	cv.ell(ocx, ocy, orx, ory, TIMB.lit)
	cv.rect(ocx - orx - 1, ocy + 1, ocx + orx + 1, ocy + ory + 1, CLEAR)
	for a in range(190, 360, 12):
		var ax := ocx + orx * cos(deg_to_rad(a))
		var ay := ocy + ory * sin(deg_to_rad(a))
		cv.line([Vector2(ocx + 0.5 * (ax - ocx), ocy + 0.5 * (ay - ocy)), Vector2(ax, ay)], TIMB.mid)
	for x in range(ocx - orx, ocx + orx + 1, 9):
		var y := ocy - _ef(ocx, orx, ory, x)
		cv.rect(x, y - 6, x + 1, y, TIMB.hi)
	# The back rail stands against the sky, so it is 2 px both ways (the silhouette's 2 px rule): a 2 x 2 stamp per
	# column, lit on top, so even its steep ends never thin to one pixel.
	for x in range(ocx - orx, ocx + orx + 1):
		var y := ocy - _ef(ocx, orx, ory, x)
		cv.rect(x, y - 6, x + 1, y - 6, TIMB.hi)
		cv.rect(x, y - 5, x + 1, y - 5, TIMB.mid)
	var cx := 196
	var r := 54
	var ry := 22.0
	var yt := 234.0
	var yf := 290.0
	_cyl_face(cv, cx, r, ry, yt, yf, TIMB)
	_band(cv, cx, r, ry, yt, 4, 6, BRASS)
	_band(cv, cx, r, ry, yt, 50, 52, BRASS)
	cv.ell(206, 262, 15, 15, BRASS.lit)
	cv.ell(207, 263, 14, 14, BRASS.sh)
	cv.ell(206, 262, 12, 12, AMBER.lit)
	cv.ell(203, 259, 6, 6, AMBER.hi)
	for a in [-90, 210, 330]:
		cv.line([Vector2(206, 262), Vector2(206 + 12 * cos(deg_to_rad(a)), 262 + 12 * sin(deg_to_rad(a)))], INK)
	cv.ell(196, 236, 58, 22, MOSS.sh)
	cv.ell(196, 230, 52, 26, MOSS.mid)
	cv.ell(193, 227, 46, 22, MOSS.lit)
	cv.ell(178, 218, 14, 7, MOSS.hi)
	for x in range(138, 255):
		cv.px(x, 236 + _ef(196, 58, 22, x) + 1, INK)


## Where the Reach's curl carries its brass lashings, in degrees round the curl's middle (180 its left, 270 its top).
const REACH_LASHINGS := [222.0, 312.0]


## The Reach's thickness at `a` degrees round its curl: 24 px where it leaves the shaft, 13 px where it turns down to
## the hook.
static func _curl_w(a: float) -> float:
	return 24.0 - 11.0 * (a - 180.0) / 180.0


## T5, the Reach: the living root rising through the deck's moss collar with a gentle S-wobble and a flared foot,
## curling over to the right like a crook to hold the lamp's chain on the door axis; rootlets binding the loft, knots,
## moss on the lit side and along the top of the curl, three worn brass bands, two leaf tufts and the chain hook.
## Pass 9 W5 (H9-02): the curl tapers harder toward the hook (13 px at the turn's end, was 16) and carries two worn brass
## lashings square across it and two knots, so it reads as the same tended root, not a bent pipe.
static func _reach(cv: Cv, rng: RandomNumberGenerator) -> void:
	var pts: Array = []
	var y := 318
	while y > 83:
		var k := (y - 84) / 234.0
		var tt := 24.0 + 10.0 * pow(k, 1.3) + (6.0 * (y - 296) / 22.0 if y > 296 else 0.0)
		pts.append(Vector3(150.0 + 4.0 * sin((318 - y) / 38.0), y, tt))
		y -= 6
	var last: Vector3 = pts[pts.size() - 1]
	var ax := last.x + 32.0
	for a in range(180, 361, 6):
		pts.append(Vector3(ax + 32.0 * cos(deg_to_rad(a)), 84.0 + 32.0 * sin(deg_to_rad(a)), _curl_w(a)))
	pts.append(Vector3(215, 90, 12))
	pts.append(Vector3(216, 96, 10))
	_tube(cv, pts, ROOTC, false, false, rng)
	for a in REACH_LASHINGS:   # worn brass lashings square across the curl, the shaded half toward its middle
		var u := Vector2(cos(deg_to_rad(a)), sin(deg_to_rad(a)))
		var t := Vector2(-u.y, u.x)   # along the curl, toward the hook
		var half := _curl_w(a) * 0.5 - 1.0
		var lo := Vector2(ax, 84.0) + u * (32.0 - half)
		var hi := Vector2(ax, 84.0) + u * (32.0 + half)
		var mid := lo.lerp(hi, 0.4)
		cv.poly([lo - t * 2.0, hi - t * 2.0, hi + t * 1.0, lo + t * 1.0], BRASS.lit)
		cv.poly([lo - t * 2.0, mid - t * 2.0, mid + t * 1.0, lo + t * 1.0], BRASS.sh)
		cv.px((hi - u * 2.0 - t).x, (hi - u * 2.0 - t).y, BRASS.hi)
		cv.line([lo - t * 3.0, hi - t * 3.0], INK)   # the lip on the root's base side, as the shaft's bands have
	for a in [246.0, 336.0]:   # knots on the curl, just off its middle toward the lit top
		var p := Vector2(ax, 84.0) + Vector2(cos(deg_to_rad(a)), sin(deg_to_rad(a))) * 33.0
		_knot(cv, p.x, p.y, 3)
	# Rootlets binding the loft: over the dome and across its face.
	_tube(cv, [Vector3(160, 262, 8), Vector3(170, 250, 6), Vector3(180, 240, 4), Vector3(188, 234, 3)], ROOTC, false, false, rng)
	_tube(cv, [Vector3(162, 292, 7), Vector3(172, 298, 5), Vector3(184, 301, 3)], ROOTC, false, false, rng)
	_tube(cv, [Vector3(138, 300, 8), Vector3(128, 302, 5), Vector3(122, 306, 3)], ROOTC, false, false, rng)
	for kn in [[147, 268, 5], [153, 196, 4], [149, 124, 4]]:
		_knot(cv, kn[0], kn[1], kn[2])
	for m in [[140, 236], [139, 220], [141, 160]]:   # moss climbing the lit side
		cv.ell(m[0], m[1], 2, 4, MOSS.lit)
		cv.px(m[0] - 1, m[1] - 2, MOSS.hi)
	for by in [300, 246, 176]:   # worn brass bands
		var hw: float = 17.0 - (318 - by) * 0.04
		cv.rect(150 - hw, by, 150 + hw, by + 4, BRASS.lit)
		cv.rect(150 + hw * 0.4, by, 150 + hw, by + 4, BRASS.sh)
		cv.rect(150 - hw + 2, by + 1, 150 - hw + 3, by + 1, BRASS.hi)
		cv.rect(150 - hw, by + 5, 150 + hw, by + 5, INK)
	for a in range(196, 300, 5):   # moss along the lit top of the curl, sitting on its edge as the curl narrows
		var r := 32.0 + _curl_w(a) * 0.5 - 1.5
		cv.ell(182 + r * cos(deg_to_rad(a)), 84 + r * sin(deg_to_rad(a)), 2, 2, MOSS.lit)
	for a in range(206, 290, 14):
		var r := 32.0 + _curl_w(a) * 0.5 - 0.5
		cv.px(182 + r * cos(deg_to_rad(a)), 84 + r * sin(deg_to_rad(a)) - 1, MOSS.hi)
	for tuft in [[160, 44], [226, 70]]:   # two small leaf tufts
		cv.ell(tuft[0], tuft[1], 4, 3, MOSS.mid)
		cv.ell(tuft[0] - 1, tuft[1] - 1, 2, 2, MOSS.hi)
	cv.rect(215, 94, 217, 97, BRASS.lit)


## T4 front: the ring's front half (planks, the rim face with its brass band, the front rail at creature hip height),
## the 7 brass sheaves where the waylines tie off, and the moss collar where the Reach rises. The loft's footprint
## stays clear.
static func _ring_front(cv: Cv) -> void:
	var ocx := 200
	var ocy := 290
	var orx := 112
	var ory := 44
	cv.ell(ocx, ocy, orx, ory, TIMB.lit)
	cv.rect(ocx - orx - 1, ocy - ory - 1, ocx + orx + 1, ocy - 1, CLEAR)
	cv.ell(196, 290, 54, 22, CLEAR)
	for a in range(12, 180, 10):
		var ax := ocx + orx * cos(deg_to_rad(a))
		var ay := ocy + ory * sin(deg_to_rad(a))
		cv.line([Vector2(ocx + 0.52 * (ax - ocx), ocy + 0.52 * (ay - ocy)), Vector2(ax, ay)], TIMB.mid)
	cv.ell(196, 290, 54, 22, CLEAR)
	for x in range(ocx - orx, ocx + orx + 1):
		var y := ocy + _ef(ocx, orx, ory, x)
		cv.rect(x, y + 1, x, y + 7, TIMB.mid)
		cv.rect(x, y + 3, x, y + 4, BRASS.lit if x < ocx + 40 else BRASS.sh)
		cv.px(x, y + 8, INK)
	for x in range(ocx - orx + 3, ocx + orx - 2, 10):
		var y := ocy + _ef(ocx, orx, ory, x)
		cv.rect(x, y - 7, x + 1, y, TIMB.hi)
	for x in range(ocx - orx + 3, ocx + orx - 2):
		cv.px(x, ocy + _ef(ocx, orx, ory, x) - 7, TIMB.hi)
	for i in LANTERN_T.size():
		var s := sheave(i)
		cv.ell(s.x, s.y, 3, 3, BRASS.lit)
		cv.px(s.x, s.y, INK)
		cv.px(s.x - 1, s.y - 2, BRASS.hi)
	cv.ell(150, 318, 22, 7, MOSS.mid)
	cv.ell(150, 317, 19, 5, MOSS.lit)
	cv.ell(150, 316, 15, 4, ROOTC.mid)
	cv.ell(146, 315, 7, 2, ROOTC.lit)


## A route lantern (12 x 20, its own cell): a brass hand lantern. Lit flickers over 3 frames; dark is unlit glass;
## quiet is dusty glass with no wick, for the route that went quiet.
static func _lantern(cv: Cv, state: String, f: int) -> void:
	var st := "lit" if state == "" else state
	cv.rect(5, 0, 6, 3, BRASS.sh)
	cv.rect(2, 3, 9, 5, BRASS.lit)
	cv.rect(2, 3, 9, 3, BRASS.hi)
	var glass: Color = AMBER.lit
	if st == "dark":
		glass = TIMB.dk
	elif st == "quiet":
		glass = STONE.sh
	cv.rect(2, 6, 9, 15, glass)
	if st == "lit":
		var hot: Array = [[3, 7, 5, 11], [3, 8, 5, 11], [4, 7, 5, 10]][f % 3]
		cv.rect(hot[0], hot[1], hot[2], hot[3], AMBER.hi)
	if st == "quiet":
		cv.rect(3, 7, 4, 8, STONE.mid)
		cv.line([Vector2(6, 7), Vector2(8, 12)], INK)
	cv.rect(1, 6, 1, 15, BRASS.mid)
	cv.rect(10, 6, 10, 15, BRASS.sh)
	cv.rect(1, 16, 10, 18, BRASS.mid)
	cv.rect(1, 18, 10, 18, BRASS.sh)


## Stillwade's flood bell: the timber gallows off the deck's left end, its moss-topped hood, the bronze bell on an
## iron yoke and its rope. "swing" moves the bell and rope 2 px either way over 4 frames.
static func _bell(cv: Cv, state: String, f: int) -> void:
	var dx := 0
	if state == "swing":
		dx = [0, 2, 0, -2][f % 4]
	cv.rect(86, 248, 89, 320, TIMB.mid)
	cv.rect(86, 248, 86, 320, TIMB.hi)
	cv.rect(46, 248, 90, 252, TIMB.lit)
	cv.rect(46, 248, 90, 248, TIMB.hi)
	cv.rect(46, 253, 90, 253, INK)
	cv.line([Vector2(60, 254), Vector2(86, 282)], TIMB.mid, 3)
	cv.poly([Vector2(50, 248), Vector2(63, 237), Vector2(76, 248)], TIMB.lit)
	cv.poly([Vector2(63, 237), Vector2(76, 248), Vector2(66, 248)], TIMB.mid)
	cv.line([Vector2(51, 247), Vector2(63, 237), Vector2(75, 247)], MOSS.lit, 2)
	cv.px(60, 239, MOSS.hi)
	cv.rect(50, 248, 76, 248, INK)
	cv.rect(61, 254, 63, 258, INK)
	cv.ell(62 + dx, 266, 10, 9, BRONZE.lit)
	cv.rect(52 + dx, 266, 72 + dx, 276, BRONZE.lit)
	cv.rect(64 + dx, 260, 72 + dx, 276, BRONZE.sh)
	cv.rect(50 + dx, 276, 74 + dx, 279, BRONZE.sh)
	cv.rect(54 + dx, 262, 55 + dx, 270, BRONZE.hi)
	cv.rect(61 + dx, 280, 63 + dx, 283, INK)
	cv.rect(66 + dx, 280, 67 + dx, 320, TWINE)


## The Waiting Lamp on its short chain: the bail, the vented cap, the amber panes and the drip pan. Lit, each pane
## glows from a near-white core out to a deeper amber at its foot, its hot patch changing shape over 4 frames (the two
## panes out of step); dark is cold glass with one glint. The pan is no wider than the glass, so the lamp reads as a
## lantern and not as a second bell (the 2026-10-27 look pass).
static func _lamp(cv: Cv, state: String, f: int) -> void:
	cv.rect(215, 92, 216, 101, BRASS.sh)
	for y in [93, 97]:
		cv.px(215, y, BRASS.hi)
	cv.line([Vector2(207, 107), Vector2(209, 103), Vector2(216, 101), Vector2(223, 103), Vector2(225, 107)], BRASS.lit, 2)
	cv.rect(206, 105, 226, 109, BRASS.lit)
	cv.rect(206, 105, 226, 105, BRASS.hi)
	cv.rect(220, 106, 226, 109, BRASS.sh)
	var lit := state != "dark"
	cv.rect(205, 110, 227, 127, AMBER.lit if lit else TIMB.dk)
	if lit:
		for k in 2:
			var x0: int = [206, 217][k]   # each pane's left column (the panes are 10 px wide)
			var hot: Array = [[1, 111, 7, 120], [1, 112, 6, 120], [2, 111, 7, 119], [1, 111, 7, 121]][(f + 2 * k) % 4]
			cv.rect(x0, 122, x0 + 9, 126, AMBER.mid)
			cv.rect(x0 + int(hot[0]), hot[1], x0 + int(hot[2]), hot[3], AMBER.hi)
			cv.rect(x0 + 3, 114, x0 + 4, 115, STONE.hi)   # the 2 x 2 core
	else:
		cv.rect(207, 111, 208, 112, STONE.mid)
	cv.rect(205, 110, 205, 127, BRASS.mid)
	cv.rect(227, 110, 227, 127, BRASS.sh)
	cv.rect(216, 110, 216, 127, INK)
	cv.rect(205, 127, 227, 128, BRASS.mid)   # the base ring, as wide as the glass
	cv.rect(207, 129, 225, 130, BRASS.sh)    # the drip pan tucked under it
	cv.rect(214, 131, 218, 133, BRASS.sh)


## The three-arm route vane at the apex (its tip is APEX) and the teal pennant with its fold, which lifts and drops
## 1 px over 4 frames.
static func _vane(cv: Cv, f: int) -> void:
	var d: int = [0, 1, 0, -1][f % 4]
	cv.rect(181, 8, 182, 43, BRASS.lit)
	cv.rect(182, 8, 182, 43, BRASS.sh)
	cv.ell(182, 11, 2, 2, BRASS.lit)
	cv.line([Vector2(181, 10), Vector2(169, 5)], BRASS.lit, 2)
	cv.line([Vector2(183, 10), Vector2(200, 10)], BRASS.lit, 2)
	cv.line([Vector2(182, 9), Vector2(184, 1)], BRASS.lit, 2)
	cv.poly([Vector2(183, 16), Vector2(195, 16), Vector2(200, 18 + d), Vector2(207, 17 + d), Vector2(200, 21 + d), Vector2(194, 24), Vector2(183, 24)], TEAL.lit)
	cv.poly([Vector2(190, 19), Vector2(199, 19 + d), Vector2(195, 22)], TEAL.sh)
	cv.rect(183, 16, 194, 16, TEAL.hi)


## T0 left, the Great Root buttress: the root arching out of the turf onto the depot's left corner (where the Climb
## starts), rootlets into the turf, treads, knots, moss and a stone at its foot.
static func _root_foot(cv: Cv, rng: RandomNumberGenerator) -> void:
	cv.ell(48, 714, 44, 5, MOSS.sh)
	_tube(cv, [Vector3(4, 718, 18), Vector3(12, 712, 21), Vector3(22, 702, 23), Vector3(32, 688, 24), Vector3(42, 670, 23), Vector3(52, 652, 22),
		Vector3(64, 636, 20), Vector3(78, 622, 18), Vector3(90, 610, 17)], ROOTC, true, false, rng)
	_tube(cv, [Vector3(40, 672, 10), Vector3(44, 692, 8), Vector3(50, 708, 6), Vector3(52, 718, 4)], ROOTC, false, false, rng)
	_tube(cv, [Vector3(26, 698, 8), Vector3(20, 710, 6), Vector3(22, 719, 4)], ROOTC, false, false, rng)
	_tube(cv, [Vector3(64, 638, 9), Vector3(70, 658, 7), Vector3(72, 682, 5), Vector3(76, 704, 4)], ROOTC, false, false, rng)
	for kn in [[32, 688, 5], [64, 636, 4]]:
		_knot(cv, kn[0], kn[1], kn[2])
	for m in [[16, 702], [36, 674], [56, 644], [74, 624]]:
		cv.ell(m[0], m[1], 4, 2, MOSS.lit)
		cv.px(m[0] - 2, m[1] - 1, MOSS.hi)
	cv.ell(34, 716, 7, 3, BOULD.mid)
	cv.ell(32, 715, 4, 2, BOULD.lit)


## T0 right, the hoist yard: a timber dock on legs, the capstan winch (its handle swings over 2 frames), parcels, a
## crate, a barrow wheel and a barrel with a teal lid.
static func _yard(cv: Cv, f: int) -> void:
	cv.rect(364, 664, 428, 699, TIMB.lit)
	for y in range(668, 700, 6):
		cv.rect(364, y, 428, y, TIMB.mid)
	cv.rect(364, 664, 428, 665, TIMB.hi)
	cv.rect(364, 700, 428, 709, TIMB.mid)
	cv.rect(364, 710, 428, 710, INK)
	for x in [366, 396, 424]:
		cv.rect(x, 711, x + 2, 719, TIMB.sh)
	cv.ell(388, 672, 8, 4, BRASS.mid)
	cv.rect(380, 660, 396, 672, TIMB.mid)
	cv.ell(388, 660, 8, 4, BRASS.lit)
	cv.rect(386, 650, 390, 660, TIMB.sh)
	if f % 2 == 0:
		cv.rect(396, 662, 404, 663, BRASS.sh)
	else:
		cv.rect(372, 662, 380, 663, BRASS.sh)
	cv.rect(404, 670, 424, 690, OIL)
	cv.rect(404, 670, 424, 672, MOSS.lit)
	cv.rect(413, 670, 414, 690, TWINE)
	cv.rect(408, 662, 420, 670, PARCH)
	cv.rect(414, 662, 414, 670, TWINE)
	cv.rect(366, 678, 380, 692, TIMB.sh)
	cv.rect(366, 678, 380, 680, TIMB.hi)
	cv.ell(369, 696, 4, 4, BRASS.mid)
	cv.ell(369, 696, 2, 2, TIMB.dk)
	cv.rect(418, 636, 430, 662, TIMB.mid)
	cv.rect(418, 638, 430, 640, BRASS.sh)
	cv.ell(424, 636, 6, 3, TEAL.mid)


## A wayline post (24 x 64): a boulder foot, the timber post, the glyph plate (the three-route mark as a shape), the
## brass pulley at the top and the lantern on its hook: lit when strung, unlit while waiting, dusty when quiet.
static func _post(cv: Cv, state: String) -> void:
	# The boulder foot (Preston, 2026-10-29: things must stand off the ground): lit on top and to the west, shaded low
	# and east of the post, outlined, with a dark contact row where it meets the ground.
	cv.rect(4, 56, 19, 63, BOULD.mid)
	cv.rect(4, 56, 19, 57, BOULD.lit)
	cv.rect(4, 58, 5, 60, BOULD.lit)
	cv.rect(4, 61, 19, 62, BOULD.sh)
	cv.rect(15, 58, 17, 60, BOULD.sh)
	cv.rect(3, 57, 3, 62, INK)
	cv.rect(20, 57, 20, 62, INK)
	cv.rect(4, 63, 19, 63, INK)
	cv.rect(10, 10, 14, 56, TIMB.lit)
	cv.rect(13, 10, 14, 56, TIMB.mid)
	cv.rect(10, 56, 14, 56, TIMB.dk)   # where the post goes into the stone
	cv.rect(8, 30, 16, 37, BRASS.lit)
	cv.line([Vector2(12, 36), Vector2(12, 32)], INK)
	cv.line([Vector2(12, 36), Vector2(10, 32)], INK)
	cv.line([Vector2(12, 36), Vector2(14, 32)], INK)
	cv.ell(12, 7, 6, 6, BRASS.mid)
	cv.ell(12, 7, 4, 4, BRASS.lit)
	cv.px(12, 7, INK)
	# The lantern on its hook, drawn as the route lanterns are (pass 9 W6, H9-06: it was one block of glass): the bracket
	# off the post, the ring it hangs by, a vented cap, a brass frame round two panes with a bar between them, and the
	# base. Strung, the near pane holds the flame's hot spot; waiting, cold dark glass with one glint; quiet, dusty grey
	# glass with a crack.
	cv.rect(15, 14, 20, 15, BRASS.sh)
	cv.rect(19, 16, 20, 17, BRASS.sh)
	cv.rect(17, 18, 21, 18, BRASS.hi)
	cv.rect(16, 19, 22, 19, BRASS.lit)
	cv.px(19, 19, INK)
	var glass: Color = AMBER.lit
	if state == "waiting":
		glass = TIMB.dk
	elif state == "quiet":
		glass = STONE.sh
	cv.rect(16, 20, 22, 26, glass)
	cv.rect(16, 20, 16, 26, BRASS.lit)
	cv.rect(22, 20, 22, 26, BRASS.sh)
	cv.rect(19, 20, 19, 26, BRASS.mid)
	cv.rect(16, 27, 22, 27, BRASS.lit)
	cv.rect(17, 28, 21, 28, BRASS.sh)
	if state == "waiting":
		cv.px(17, 21, STONE.mid)
	elif state == "quiet":
		cv.rect(17, 21, 17, 22, STONE.mid)
		cv.line([Vector2(20, 21), Vector2(21, 25)], INK)
	else:
		cv.rect(17, 22, 18, 25, AMBER.hi)
		cv.px(20, 24, AMBER.hi)
	cv.ell(10, 56, 4, 2, MOSS.lit)


## The painted rise stair (48 x 96): eight worn stone steps, roots in two risers and the three-route glyph inlaid in
## the top step. Each root pushes out through a riser's face (an ink lip where it breaks the stone) and lies down over
## the tread below it, thinning (pass 9 W7, H9-05: two stubs lay on the treads, as if dropped there).
static func _stair(cv: Cv) -> void:
	for i in 8:
		var y := i * 12
		cv.rect(0, y, 47, y + 7, STONE.lit)
		cv.rect(0, y, 47, y + 1, STONE.hi)
		cv.rect(0, y + 8, 47, y + 11, STONE.sh)
		cv.rect(0, y + 7, 47, y + 7, STONE.hi)   # the lit nosing where the tread turns down
		cv.rect(0, y + 8, 47, y + 8, INK)         # contact under the projecting cap
		cv.rect(0, y + 11, 47, y + 11, INK)
		cv.rect(14 + (i % 3) * 6, y + 3, 30 + (i % 3) * 6, y + 5, STONE.mid)
	# Low stone cheeks stay inside the 48 px frame. West catches the high light;
	# east shows its darker face. These are walls, with no painted ground shadow.
	cv.rect(0, 0, 4, 95, STONE.mid)
	cv.rect(0, 0, 2, 94, STONE.hi)
	cv.rect(3, 0, 4, 94, INK)
	cv.rect(43, 0, 47, 95, STONE.sh)
	cv.rect(43, 0, 44, 94, STONE.lit)
	cv.rect(45, 0, 45, 94, INK)
	for i in 8:
		cv.rect(0, i * 12 + 11, 2, i * 12 + 11, STONE.mid)
		cv.rect(43, i * 12 + 11, 44, i * 12 + 11, STONE.mid)
	cv.rect(0, 95, 47, 95, INK)   # the stair and wall toes meet the ground on this row
	cv.line([Vector2(24, 9), Vector2(24, 3)], STONE.hi)
	cv.line([Vector2(24, 9), Vector2(19, 4)], STONE.hi)
	cv.line([Vector2(24, 9), Vector2(29, 4)], STONE.hi)
	for r in STAIR_ROOTS:
		var at: Vector2 = r[0]
		_tube(cv, [Vector3(at.x, at.y, 5), r[1], r[2]], ROOTC)
		cv.line([at + Vector2(-3, -2), at + Vector2(2, -2)], INK)   # the stone cracked open over it, under the tread's lip


## The rise stair's two roots: where each breaks out of a riser's face (step 3's on the left, step 5's on the right;
## a step's riser is its rows 8 to 10, so the root's top stays under the tread's lip), then two (x, y, thickness) points
## down over the tread below.
const STAIR_ROOTS := [
	[Vector2(3, 46), Vector3(8, 50, 4), Vector3(14, 53, 3)],
	[Vector2(44, 70), Vector3(39, 74, 4), Vector3(33, 77, 3)],
]


## The hoist basket (16 x 16): wicker on two rope slings, with an oilcloth parcel when full.
static func _basket(cv: Cv, full: bool) -> void:
	cv.line([Vector2(8, 0), Vector2(3, 6)], TWINE)
	cv.line([Vector2(8, 0), Vector2(13, 6)], TWINE)
	cv.rect(2, 6, 13, 14, TIMB.hi)
	cv.rect(9, 6, 13, 14, TIMB.lit)
	for y in [8, 11, 14]:
		cv.rect(2, y, 13, y, TIMB.mid)
	if full:
		cv.rect(4, 3, 11, 7, OIL)
		cv.rect(7, 3, 7, 7, TWINE)


## A cradle on a wayline (12 x 14): the brass trolley wheel, the twine sling and a parcel (none when empty). Its sling
## sways 1 px over 2 frames.
static func _cradle(cv: Cv, state: String, f: int) -> void:
	var dx := f % 2
	cv.ell(6, 2, 2, 2, BRASS.lit)
	cv.rect(5, 4, 6, 6, BRASS.sh)
	cv.line([Vector2(6, 6), Vector2(2 + dx, 8)], TWINE)
	cv.line([Vector2(6, 6), Vector2(9 + dx, 8)], TWINE)
	if state != "empty":
		cv.rect(2 + dx, 8, 9 + dx, 12, OIL)
		cv.rect(6 + dx, 8, 6 + dx, 12, TWINE)
	else:
		cv.rect(2 + dx, 8, 9 + dx, 8, TWINE)


## A parcel (10 x 8): oilcloth with a moss-green top, or paper, tied with twine.
static func _parcel(cv: Cv, state: String) -> void:
	if state == "paper":
		cv.rect(2, 0, 8, 7, PARCH)
		cv.rect(2, 0, 8, 0, STONE.hi)
		cv.rect(5, 0, 5, 7, TWINE)
	else:
		cv.rect(0, 2, 9, 7, OIL)
		cv.rect(0, 2, 9, 2, MOSS.lit)
		cv.rect(4, 2, 4, 7, TWINE)


# ---------------------------------------------------------------------------------------------------------------------
# Standing the tower in a scene

## Stands the whole tower under `parent` with its frame's top-left at `origin` (parent px; RISE_ORIGIN on Tower Rise)
## and returns its node, "WaylineTower". Its children, in draw order: one sprite per body part ("Exterior" is the
## depot, then "Door", the door leaves), the route lanterns ("RouteLanterns"), the ground wings ("RootFoot", "Yard",
## one step in front), the life, the waylines ("Waylines", hung in the air) and the long shadow ("LongShadow", on the
## ground). Each part draws ArtSlots.texture(id): the installed file at exactly its size, else this file's blockout.
## Meta, as BuildingTemplate.place() sets for a building: "frames" (the door's three swing frames), "door_px" (the door
## in the tower's px), "class" ("hall"), "slot" (the depot's), plus "beacon" and "apex" (tower px).
##
## opts (all optional): "z" (the door row's z, DOOR_ROW_Z), "lanterns" (7 states), "pegs_lit" (peg indices), "lamp"
## ("lit" or "dark"), "lines" (waylines: [{"sheave": i, "to": Vector2 in tower px, "sag": px, "quiet": bool}], default
## RISE_LINES; [] for none), "shadow_drop" (px of ground below the foot for the long shadow; 0 for none) and "life"
## (false: everything still, for a check or a screenshot).
static func place(parent: Node, origin: Vector2, opts: Dictionary = {}) -> Node2D:
	var tower := Node2D.new()
	tower.name = "WaylineTower"
	tower.position = origin
	tower.z_index = int(opts.get("z", DOOR_ROW_Z))
	tower.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(tower)
	var life := bool(opts.get("life", true))
	tower.set_meta("life", life)
	var lanterns: Array = opts.get("lanterns", LANTERN_STATES)
	for p in PARTS:
		var id := String(p["id"])
		var name := String(p["name"])
		var rect: Rect2i = p["rect"]
		if name == "route_lantern":
			_place_lanterns(tower, lanterns, life)
			continue
		if String(p["layer"]) == "prop":
			continue   # the movers are placed with the parts they ride; posts and the stair belong to the area
		var sprite := _sprite(tower, id, "", Vector2(rect.position), "Exterior" if name == "depot" else name.to_pascal_case())
		if String(p["layer"]) == "ground":
			sprite.z_index = 1   # the ground wings sort one step in front of the body, on the door row
			_contact_shadow(tower, name)
		match name:
			"depot":
				_place_door(tower)
			"hoist":
				_place_basket(tower)
			"chute":
				_place_chute_parcel(tower, life)
			"gable":
				set_pegs(tower, opts.get("pegs_lit", PEGS_LIT))
			"bell":
				_animate(sprite, BELL, "rest", life)
			"lamp":
				_animate(sprite, LAMP, String(opts.get("lamp", "lit")), life)
				_place_glow(tower, sprite, life)
			"vane":
				_animate(sprite, VANE, "flutter", life)
	if life:
		_run_basket(tower)
		_place_smoke(tower)
	_place_waylines(tower, opts.get("lines", RISE_LINES), lanterns, life)
	var drop := int(opts.get("shadow_drop", 0))
	if drop > 0:
		var shadow := Sprite2D.new()
		shadow.name = "LongShadow"
		shadow.centered = false
		shadow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		shadow.texture = ImageTexture.create_from_image(long_shadow(drop))
		shadow.position = Vector2(0, FOOT_ROW)
		shadow.z_as_relative = false
		shadow.z_index = SHADOW_Z
		tower.add_child(shadow)
	tower.set_meta("door_px", DOOR)
	tower.set_meta("class", "hall")
	tower.set_meta("slot", DEPOT)
	tower.set_meta("beacon", Vector2(BEACON))
	tower.set_meta("apex", Vector2(APEX))
	return tower


## The soft shadow on the ground under a ground wing (CONTACT: the root foot's arch where it meets the turf, the yard's
## dock legs), so the wings sit on the grass instead of floating on it: a flat ellipse of black in three steps (about 30,
## 18 and 8 %) a few px past the foot row, on the ground under anything standing (z SHADOW_Z, as the long shadow).
## Named "<Wing>Shadow" (RootFootShadow, YardShadow). Added in the 2026-10-27 fix pass.
const CONTACT := {"root_foot": Rect2i(46, 717, 50, 6), "yard": Rect2i(396, 717, 38, 6)}   # middle (frame px), half size
static func _contact_shadow(tower: Node2D, wing: String) -> void:
	if not CONTACT.has(wing):
		return
	var c: Rect2i = CONTACT[wing]
	var half := c.size
	var img := Image.create(half.x * 2 + 1, half.y * 2 + 1, false, Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var d := Vector2(float(x - half.x) / half.x, float(y - half.y) / half.y).length()
			var a := 0.3 if d <= 0.5 else (0.18 if d <= 0.8 else (0.08 if d <= 1.0 else 0.0))
			if a > 0.0:
				img.set_pixel(x, y, Color(0, 0, 0, a))
	var shade := Sprite2D.new()
	shade.name = wing.to_pascal_case() + "Shadow"
	shade.centered = false
	shade.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	shade.texture = ImageTexture.create_from_image(img)
	shade.position = Vector2(c.position - half)
	shade.z_as_relative = false
	shade.z_index = SHADOW_Z
	tower.add_child(shade)


## Sets route lantern i ("lit", "dark" or "quiet") on a placed tower.
static func set_lantern(tower: Node2D, i: int, state: String) -> void:
	var s := tower.get_node_or_null("RouteLanterns/Lantern%d" % i) as Sprite2D
	if s != null:
		_animate(s, LANTERN, state, bool(tower.get_meta("life", true)))


## Lights the Route Board's pegs at these indices (0 to 7) on a placed tower; the rest stay dark sockets.
static func set_pegs(tower: Node2D, lit: Array) -> void:
	var holder := tower.get_node_or_null("RoutePegs") as Node2D
	if holder == null:
		holder = Node2D.new()
		holder.name = "RoutePegs"
		tower.add_child(holder)
	for c in holder.get_children():
		holder.remove_child(c)
		c.queue_free()
	var img := Image.create(3, 3, false, Image.FORMAT_RGBA8)
	img.fill(AMBER.hi)
	var tex := ImageTexture.create_from_image(img)
	var pegs := route_pegs()
	for k in lit:
		if int(k) < 0 or int(k) >= pegs.size():
			continue
		var peg := Sprite2D.new()
		peg.name = "Peg%d" % int(k)
		peg.centered = false
		peg.texture = tex
		peg.position = Vector2(Cv.rnd(pegs[int(k)].x - 1.0), Cv.rnd(pegs[int(k)].y - 1.0))
		holder.add_child(peg)


## Lights or darkens the Waiting Lamp ("lit" or "dark"); the glow follows it.
static func set_lamp(tower: Node2D, state: String) -> void:
	var s := tower.get_node_or_null("Lamp") as Sprite2D
	if s != null:
		_animate(s, LAMP, state, bool(tower.get_meta("life", true)))
	var glow := tower.get_node_or_null("Glow") as CanvasItem
	if glow != null:
		glow.visible = state != "dark"


## Rests the flood bell or swings it ("rest" or "swing").
static func set_bell(tower: Node2D, state: String) -> void:
	var s := tower.get_node_or_null("Bell") as Sprite2D
	if s != null:
		_animate(s, BELL, state, bool(tower.get_meta("life", true)))


## The door's three swing frames, cut from the depot picture itself (painted closed): 0 is the painted leaves, 1 half
## open, 2 open. Each leaf of the double door hinges at its outer jamb and narrows toward it; the doorway behind is
## dark and the threshold stone stays. Works the same on Codex's painted depot once it is installed.
static func door_frames(depot: Image) -> Array[Texture2D]:
	var out: Array[Texture2D] = []
	var src := depot.get_region(DEPOT_DOOR)
	var w := DEPOT_DOOR.size.x
	var half := w / 2
	for f in 3:
		var leaf: int = [half, half / 2, 2][f]
		var img := Image.create(w, DEPOT_DOOR.size.y, false, Image.FORMAT_RGBA8)
		img.fill(TIMB.dk)
		for y in DEPOT_DOOR.size.y:
			for x in w:
				var edge := mini(x, w - 1 - x)   # how far this column is from its leaf's hinge
				if y >= DEPOT_DOOR.size.y - 2:
					img.set_pixel(x, y, src.get_pixel(x, y))   # the threshold stone does not swing
					continue
				if edge >= leaf:
					continue
				var col := edge * half / leaf   # the painted column the narrowed leaf shows here
				img.set_pixel(x, y, src.get_pixel(col if x < half else w - 1 - col, y))
		out.append(ImageTexture.create_from_image(img))
	return out


static func _sprite(parent: Node, id: String, state: String, at: Vector2, node_name: String) -> Sprite2D:
	var s := Sprite2D.new()
	s.name = node_name
	s.centered = false
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.texture = ArtSlots.frame(id, state, 0)
	s.position = at
	Finish.apply(s, true)   # the runtime rim every building gets; the parts are painted without an outer outline
	parent.add_child(s)
	return s


## The frames of one state of a slot, each an AtlasTexture cut from its sheet (the installed file or the blockout).
static func _frames(id: String, state: String) -> Array[Texture2D]:
	var states: Dictionary = ArtSlots.spec(id).get("states", {})
	var n := int(states[state][0]) if states.has(state) else 1
	var out: Array[Texture2D] = []
	for i in n:
		out.append(ArtSlots.frame(id, state, i))
	return out


## Shows a state of a part on its sprite and, with life on, loops its frames at the state's fps (a Sprite2D whose
## texture a tween swaps, rather than an AnimatedSprite2D, so the shared rim finish applies as on every building).
static func _animate(sprite: Sprite2D, id: String, state: String, life: bool) -> void:
	if sprite.has_meta("cycle"):
		var old: Tween = sprite.get_meta("cycle")
		if old != null and old.is_valid():
			old.kill()
		sprite.remove_meta("cycle")
	var frames := _frames(id, state)
	sprite.texture = frames[0]
	sprite.set_meta("state", state)
	var states: Dictionary = ArtSlots.spec(id).get("states", {})
	var fps := float(states[state][1]) if states.has(state) else 0.0
	if not life or frames.size() < 2 or fps <= 0.0:
		return
	var tw := sprite.create_tween().set_loops()
	for t in frames:
		tw.tween_callback(sprite.set.bind("texture", t))
		tw.tween_interval(1.0 / fps)
	sprite.set_meta("cycle", tw)


static func _place_door(tower: Node2D) -> void:
	var frames := door_frames(ArtSlots.image(DEPOT))
	var leaves := Sprite2D.new()
	leaves.name = "Door"
	leaves.centered = false
	leaves.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	leaves.position = Vector2(DOOR.position)
	leaves.texture = frames[0]
	Finish.apply(leaves)
	tower.add_child(leaves)
	tower.set_meta("frames", frames)


static func _place_lanterns(tower: Node2D, states: Array, life: bool) -> void:
	var holder := Node2D.new()
	holder.name = "RouteLanterns"
	tower.add_child(holder)
	for i in LANTERN_T.size():
		var s := _sprite(holder, LANTERN, "", Vector2(lantern_at(i)), "Lantern%d" % i)
		_animate(s, LANTERN, String(states[i]) if i < states.size() else "dark", life)
		if life and s.has_meta("cycle"):
			(s.get_meta("cycle") as Tween).custom_step(0.17 * i)   # the seven flicker out of step


## The hoist rope (a coded 1 px cable from the pulley block) and the basket that rides it, drawn just after the hoist.
static func _place_basket(tower: Node2D) -> void:
	var rope := _rope(PULLEY + Vector2(0, 1), Vector2(PULLEY.x, BASKET_LOW))
	rope.name = "HoistRope"
	tower.add_child(rope)
	var basket := _sprite(tower, BASKET, "full", Vector2(PULLEY.x - 8, BASKET_LOW), "Basket")
	basket.set_meta("full", ArtSlots.frame(BASKET, "full", 0))
	basket.set_meta("empty", ArtSlots.frame(BASKET, "empty", 0))


## The basket's round trip, about 10 s: a rest on the yard, up with a parcel (4 s), a rest at the hoist door, down
## empty (4 s). The hoist's sheave and the yard's winch turn while the rope moves.
static func _run_basket(tower: Node2D) -> void:
	var basket := tower.get_node_or_null("Basket") as Sprite2D
	var rope := tower.get_node_or_null("HoistRope") as Line2D
	var hoist := tower.get_node_or_null("Hoist") as Sprite2D
	var yard := tower.get_node_or_null("Yard") as Sprite2D
	if basket == null or rope == null:
		return
	var turns := [_frames(HOIST, "turn"), _frames(YARD, "winch")]
	var move := func(y: float) -> void:
		var at := roundf(y)
		basket.position.y = at
		rope.points = PackedVector2Array([Vector2(PULLEY.x + 0.5, PULLEY.y + 1.5), Vector2(PULLEY.x + 0.5, at + 0.5)])
		var lit := rope.get_node_or_null("Lit") as Line2D
		if lit != null:
			lit.points = rope.points
		var k := int(at / 3.0) % 2
		if hoist != null and turns[0].size() > k:
			hoist.texture = turns[0][k]
		if yard != null and turns[1].size() > k:
			yard.texture = turns[1][k]
	var tw := basket.create_tween().set_loops()
	tw.tween_callback(basket.set.bind("texture", basket.get_meta("full")))
	tw.tween_interval(1.0)
	tw.tween_method(move, BASKET_LOW, BASKET_HIGH, 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(basket.set.bind("texture", basket.get_meta("empty")))
	tw.tween_interval(1.0)
	tw.tween_method(move, BASKET_HIGH, BASKET_LOW, 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	basket.set_meta("cycle", tw)


## A parcel that slides down the chute from the walkway to the bin every 12 to 20 s (the first one soon).
static func _place_chute_parcel(tower: Node2D, life: bool) -> void:
	var parcel := _sprite(tower, PARCEL, "", CHUTE_MOUTH, "ChuteParcel")
	parcel.visible = false
	if not life:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 2027
	_chute_once(parcel, rng, 1.5)


static func _chute_once(parcel: Sprite2D, rng: RandomNumberGenerator, wait: float) -> void:
	if not is_instance_valid(parcel):
		return
	var slide := func(t: float) -> void:
		var p := CHUTE_MOUTH.lerp(CHUTE_SPOUT, t)
		parcel.position = Vector2(roundf(p.x) - 5, roundf(p.y) - 6)
	var tw := parcel.create_tween()
	tw.tween_interval(wait)
	tw.tween_callback(parcel.set.bind("texture", ArtSlots.frame(PARCEL, ["oilcloth", "paper"][rng.randi() % 2], 0)))
	tw.tween_callback(parcel.set.bind("visible", true))
	tw.tween_method(slide, 0.0, 1.0, 2.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(parcel.set.bind("visible", false))
	tw.tween_callback(func() -> void: _chute_once(parcel, rng, rng.randf_range(12.0, 20.0)))
	parcel.set_meta("cycle", tw)


## The glow's picture (GLOW_HALF round the lamp's middle, each step's amber at its strength), for _place_glow and the
## checks that measure it against the sky.
static func glow_image() -> Image:
	var img := Image.create(GLOW_HALF.x * 2 + 1, GLOW_HALF.y * 2 + 1, false, Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var d := Vector2(float(x - GLOW_HALF.x) / GLOW_HALF.x, float(y - GLOW_HALF.y) / GLOW_HALF.y).length()
			for step in GLOW_STEPS:
				if d <= float(step[0]):
					img.set_pixel(x, y, Color(AMBER[String(step[2])], float(step[1])))
					break
	return img


## The lamp's glow: warm light in three steps round the lamp (GLOW_STEPS: about 35, 20 and 10 % of amber, amber-mid
## nearest the glass, deepening to amber-dark at the edge), added to whatever is behind it, so the sky and the crook
## round the lamp lift toward amber. It hangs just behind the lamp, so the panes keep their own painted core. Stepped,
## as pixel-art light is, and breathing with the flicker. (Two 1 px rings until the 2026-10-27 look pass, which read
## as a grey outline; brass-light until pass 9, which read green-grey on the slate sky.)
static func _place_glow(tower: Node2D, lamp: Sprite2D, life: bool) -> void:
	var img := glow_image()
	var glow := Sprite2D.new()
	glow.name = "Glow"
	glow.centered = false
	glow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	glow.texture = ImageTexture.create_from_image(img)
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.material = add
	glow.position = Vector2(BEACON) + Vector2(0, 2) - Vector2(GLOW_HALF)   # round the lamp's middle, cap to pan
	glow.visible = String(lamp.get_meta("state", "lit")) != "dark"
	tower.add_child(glow)
	tower.move_child(glow, lamp.get_index())   # just behind the lamp
	if not life:
		return
	var breathe := glow.create_tween().set_loops()
	breathe.tween_property(glow, "modulate:a", 0.6, 0.9).set_trans(Tween.TRANS_SINE)
	breathe.tween_property(glow, "modulate:a", 1.0, 1.3).set_trans(Tween.TRANS_SINE)
	# The lamp sways on its chain a whole pixel at a time (a sprite turned by a fraction of a degree would shimmer).
	var base_x := lamp.position.x
	var sway := lamp.create_tween().set_loops()
	var step := func(v: float) -> void: lamp.position.x = base_x + roundf(v)
	sway.tween_method(step, -1.0, 1.0, 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	sway.tween_method(step, 1.0, -1.0, 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Three puffs of smoke from the mess chimney, rising and thinning, out of step.
static func _place_smoke(tower: Node2D) -> void:
	var img := Image.create(9, 7, false, Image.FORMAT_RGBA8)
	var cv := Cv.new(Rect2i(0, 0, 9, 7))
	cv.ell(4, 3, 4, 3, SMOKE)
	img = cv.img
	var tex := ImageTexture.create_from_image(img)
	for k in 3:
		var puff := Sprite2D.new()
		puff.name = "Smoke%d" % k
		puff.centered = true
		puff.texture = tex
		puff.position = CHIMNEY
		puff.modulate.a = 0.0
		tower.add_child(puff)
		var tw := puff.create_tween().set_loops()
		tw.tween_property(puff, "position", CHIMNEY + Vector2(14, -34), 3.6).from(CHIMNEY)
		tw.parallel().tween_property(puff, "modulate:a", 0.0, 3.6).from(0.5)
		tw.custom_step(1.2 * k)


## The waylines: a cable from each named sheave out to its post, hung over everything on the ground, with a cradle
## sliding out along every strung line about every 12 s. The quiet route's line hangs slack and carries nothing.
static func _place_waylines(tower: Node2D, lines: Array, lanterns: Array, life: bool) -> void:
	var holder := Node2D.new()
	holder.name = "Waylines"
	holder.z_as_relative = false
	holder.z_index = WAYLINE_Z
	tower.add_child(holder)
	var k := 0
	for l in lines:
		var i := int(l.get("sheave", 0))
		var quiet := bool(l.get("quiet", i < lanterns.size() and String(lanterns[i]) == "quiet"))
		var sag := float(l.get("sag", 36.0)) * (1.6 if quiet else 1.0)
		var from := sheave(i)
		var to: Vector2 = l.get("to", from)
		var line := wayline(from, to, sag)
		line.name = "Wayline%d" % i
		line.set_meta("quiet", quiet)
		holder.add_child(line)
		if quiet or not life:
			continue
		var cradle := _sprite(holder, CRADLE, "loaded", from, "Cradle%d" % i)
		cradle.visible = false
		var sway := [ArtSlots.frame(CRADLE, "loaded", 0), ArtSlots.frame(CRADLE, "loaded", 1)]
		var ride := func(t: float) -> void:
			var p := curve_at(from, to, sag, t)
			cradle.position = Vector2(roundf(p.x) - 6, roundf(p.y) - 2)
			cradle.texture = sway[int(t * 24.0) % 2]
		var travel := clampf(from.distance_to(to) / 45.0, 4.0, 9.0)
		var tw := cradle.create_tween().set_loops()
		tw.tween_callback(cradle.set.bind("visible", true))
		tw.tween_method(ride, 0.0, 1.0, travel)
		tw.tween_callback(cradle.set.bind("visible", false))
		tw.tween_interval(12.0 - travel)
		tw.custom_step(3.7 * k)
		cradle.set_meta("cycle", tw)
		k += 1


# ---------------------------------------------------------------------------------------------------------------------
# Coded pieces for the scenes that frame the tower

## A point on a wayline: the straight line from `from` to `to`, sagging `sag` px at its middle.
static func curve_at(from: Vector2, to: Vector2, sag: float, t: float) -> Vector2:
	return from.lerp(to, t) + Vector2(0, sag * 4.0 * t * (1.0 - t))


## A wayline cable as a Line2D in its parent's px: 1 px of ink with a 1 px lit top (a child, "Lit", in brass-light so
## the cable shows over grass as well as sky; it was stone shadow until the 2026-10-27 look pass found the lines lost
## on the ground), and a teal tag every 40 px (children "Tag*"). Points sit on pixel centres so the line stays one
## crisp pixel at any zoom.
static func wayline(from: Vector2, to: Vector2, sag: float) -> Line2D:
	var line := _cable(INK)
	line.name = "Wayline"
	var n := maxi(2, int(from.distance_to(to) / 4.0))
	var pts := PackedVector2Array()
	for j in n + 1:
		pts.append(_snap(curve_at(from, to, sag, float(j) / n)))
	line.points = pts
	var lit := _cable(BRASS.hi)
	lit.name = "Lit"
	var top := PackedVector2Array()
	for p in pts:
		top.append(p + Vector2(0, -1))
	lit.points = top
	line.add_child(lit)
	var px := int(from.distance_to(to))
	var k := 0
	for j in range(20, px, 40):
		var p := _snap(curve_at(from, to, sag, float(j) / px)) - Vector2(0.5, 0.5)
		var tag := Polygon2D.new()
		tag.name = "Tag%d" % k
		tag.color = TEAL.lit
		tag.polygon = PackedVector2Array([p + Vector2(0, 1), p + Vector2(2, 1), p + Vector2(2, 4), p + Vector2(0, 4)])
		line.add_child(tag)
		k += 1
	return line


## The hoist rope: a straight 1 px cable with its lit side on the left.
static func _rope(from: Vector2, to: Vector2) -> Line2D:
	var rope := _cable(INK)
	rope.points = PackedVector2Array([_snap(from), _snap(to)])
	var lit := _cable(STONE.sh)
	lit.name = "Lit"
	lit.position = Vector2(-1, 0)
	lit.points = rope.points
	rope.add_child(lit)
	return rope


static func _cable(c: Color) -> Line2D:
	var l := Line2D.new()
	l.width = 1.0
	l.default_color = c
	l.antialiased = false
	l.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	l.joint_mode = Line2D.LINE_JOINT_SHARP
	return l


static func _snap(p: Vector2) -> Vector2:
	return Vector2(floorf(p.x) + 0.5, floorf(p.y) + 0.5)


## The tower's long shadow on the plaza (section 7): its whole silhouette sheared down and to the right (a pixel h px
## above the foot lands 0.30 h to the right and 0.13 h below the foot) at about 24 % black, cut off `drop` px below
## the foot (the cliff row). Placed with its top-left at frame (0, FOOT_ROW); FRAME.x + 216 px wide, drop + 1 tall.
static func long_shadow(drop: int) -> Image:
	var h_max := FOOT_ROW
	var img := Image.create(FRAME.x + int(ceilf(0.30 * h_max)) + 1, maxi(1, drop + 1), false, Image.FORMAT_RGBA8)
	var whole := assembled_image()
	var shade := Color(0, 0, 0, 62.0 / 255.0)
	for y in FRAME.y:
		var h := FOOT_ROW - y
		var sy := Cv.rnd(0.13 * h)
		if sy > drop:
			continue
		for x in FRAME.x:
			if whole.get_pixel(x, y).a > 0.0:
				img.set_pixel(Cv.rnd(x + 0.30 * h), sy, shade)
	return img


# ---------------------------------------------------------------------------------------------------------------------
# The tower in the middle distance

## The whole tower shrunk to `height_px` tall, for a view where it stands between the far icon and its true size: the
## road's held view from the rise (route_scene.gd), and the title's Highbank (title_highbank.gd). paint_far's grid is
## laid out for about 70 px and turns to flat blocks when it is drawn much bigger; this keeps the drum, the galleries,
## the Reel Deck and the crook. With `installed`, each part shows Codex's or Grok's file once it is in, its blockout
## until then. Use paint_far for about 100 px or less.
static func small(height_px: int, installed: bool = true) -> Image:
	return shrink(assembled_image(LANTERN_STATES, PEGS_LIT, installed), _small_w(height_px), height_px)


## Where a frame point (tower px) lands in small(height_px).
static func small_pt(height_px: int, p: Vector2) -> Vector2:
	return Vector2(p.x * _small_w(height_px) / FRAME.x, p.y * height_px / FRAME.y)


static func _small_w(height_px: int) -> int:
	return roundi(FRAME.x * height_px / float(FRAME.y))


## A picture shrunk to w x h by averaging (a box filter): each new pixel is the average of the pixels it covers, kept
## only when at least half of them are opaque, and snapped to the family's nearest colour, so the result is still
## pixel art in the tower's palette with on-or-off alpha. The engine does most of the averaging: with alpha
## premultiplied (a clear pixel adds nothing), its mipmaps halve the picture by 2 x 2 averages, and the loop here only
## averages the last small step from the smallest mipmap that is still at least w x h. (Moved here from
## title_highbank.gd on 2026-10-27, so the road's vista shrinks the tower the same way.)
static func shrink(src: Image, w: int, h: int) -> Image:
	var s := src.duplicate() as Image
	if s.get_format() != Image.FORMAT_RGBA8:
		s.convert(Image.FORMAT_RGBA8)
	s.premultiply_alpha()
	s.generate_mipmaps()
	var level := 0
	var sw := s.get_width()
	var sh := s.get_height()
	while level < s.get_mipmap_count() and sw / 2 >= w and sh / 2 >= h:
		level += 1
		sw = maxi(1, sw / 2)
		sh = maxi(1, sh / 2)
	var data := s.get_data()
	var base := s.get_mipmap_offset(level) if level > 0 else 0
	var out := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for oy in h:
		var y0 := floori(float(oy * sh) / h)
		var y1 := maxi(y0 + 1, floori(float((oy + 1) * sh) / h))
		for ox in w:
			var x0 := floori(float(ox * sw) / w)
			var x1 := maxi(x0 + 1, floori(float((ox + 1) * sw) / w))
			var r := 0
			var g := 0
			var b := 0
			var a := 0
			for y in range(y0, y1):
				var row := base + y * sw * 4
				for x in range(x0, x1):
					var i := row + x * 4
					r += data[i]
					g += data[i + 1]
					b += data[i + 2]
					a += data[i + 3]
			if a > 0 and a * 2 >= 255 * (x1 - x0) * (y1 - y0):
				out.set_pixel(ox, oy, _nearest(mini(255, r * 255 / a), mini(255, g * 255 / a), mini(255, b * 255 / a)))
	return out


## The family colour nearest an 8-bit colour (the "redmean" distance, a cheap fit to the eye), cached.
static func _nearest(r: int, g: int, b: int) -> Color:
	var key := (r << 16) | (g << 8) | b
	if _near.has(key):
		return _near[key]
	if _pal.is_empty():
		for hex in PALETTE:
			_pal.append(Color(hex))
	var best := _pal[0]
	var best_d := INF
	for c in _pal:
		var cr := c.r8
		var rm := (r + cr) * 0.5
		var dr := float(r - cr)
		var dg := float(g - c.g8)
		var db := float(b - c.b8)
		var d := (2.0 + rm / 256.0) * dr * dr + 4.0 * dg * dg + (2.0 + (255.0 - rm) / 256.0) * db * db
		if d < best_d:
			best_d = d
			best = c
	_near[key] = best
	return best


# ---------------------------------------------------------------------------------------------------------------------
# The far tower

## The tower painted for a far view at `height_px` tall (section 9), not shrunk from the big one: the root slope on
## the left, the depot with its dark door, the drum with a window band, a 2 px hoist tick and its rope on the right,
## the galleries, a 3 px ring bar with lantern specks and one gap, the bell's tick on the left, the loft, the crook in
## a thick stroke with the small amber lamp hanging under its hook, and the vane. Drawn on the mock's 70 px layout and
## scaled, with every stroke at least 2 px. `haze` (0 to 1) mixes everything but the lamp toward the far air; the lamp
## stays lit. Its height is exactly height_px (minimum 24); far_points() gives its foot, lamp and apex.
static func paint_far(height_px: int, haze: float = 0.0) -> Image:
	var g := _far_grid(height_px)
	var cv := Cv.new(Rect2i(0, 0, g.w, g.h))
	_far_poly(cv, g, [Vector2(68, 72), Vector2(72, 66), Vector2(79, 61), Vector2(81, 64), Vector2(76, 72)], ROOTC.mid)
	_far_rect(cv, g, 78, 56, 106, 72, STONE.lit)
	_far_rect(cv, g, 98, 56, 106, 72, STONE.sh)
	_far_rect(cv, g, 78, 55, 106, 56, STONE.hi)
	_far_rect(cv, g, 90, 64, 94, 72, TIMB.dk)
	_far_rect(cv, g, 106, 66, 112, 72, TIMB.mid)
	_far_rect(cv, g, 82, 38, 102, 56, STONE.lit)
	_far_rect(cv, g, 96, 38, 102, 56, STONE.sh)
	_far_rect(cv, g, 85, 46, 93, 48, AMBER.mid)
	_far_rect(cv, g, 102, 46, 109, 47, TIMB.lit, 2, 2)
	_far_rect(cv, g, 108, 48, 108, 60, INK)
	_far_rect(cv, g, 83, 28, 99, 38, PLAST.mid)
	_far_rect(cv, g, 94, 28, 99, 38, STONE.sh)
	_far_rect(cv, g, 79, 31, 101, 33, TIMB.lit, 2, 3)
	_far_rect(cv, g, 79, 33, 101, 33, BRASS.sh)
	for lx in [82, 87, 92, 97, 100]:
		_far_rect(cv, g, lx, 34, lx, 34, AMBER.hi if lx != 87 else TIMB.dk)
	_far_rect(cv, g, 74, 26, 79, 27, TIMB.lit, 2, 2)
	_far_rect(cv, g, 78, 26, 79, 30, TIMB.mid, 2, 2)    # the gallows post, so the bell tick stands on the ring
	_far_rect(cv, g, 75, 28, 76, 30, BRONZE.lit, 2, 2)
	_far_rect(cv, g, 86, 22, 96, 30, TIMB.mid)
	_far_rect(cv, g, 86, 21, 96, 22, MOSS.lit)
	# The crook: the shaft, the curl stamped round its centre, and the hook's end.
	_far_rect(cv, g, 84, 9, 86, 31, ROOTC.lit, 2, 2)
	_far_rect(cv, g, 86, 9, 86, 31, ROOTC.mid)
	var c := _far_pt(g, Vector2(89, 9))
	var s := maxi(2, Cv.rnd(2.0 * g.k))
	for a in range(180, 361, 3):
		var x: float = c.x + 4.0 * g.k * cos(deg_to_rad(a))
		var y: float = c.y + 4.0 * g.k * sin(deg_to_rad(a))
		cv.rect(x - s / 2, y - s / 2, x - s / 2 + s - 1, y - s / 2 + s - 1, ROOTC.lit)
	_far_rect(cv, g, 92, 9, 93, 11, ROOTC.mid, 2, 2)
	_far_rect(cv, g, 92, 12, 92, 12, BRASS.sh)           # the chain, so the lamp hangs from the hook
	var lamp := Rect2i()
	lamp = lamp.merge(_far_rect(cv, g, 92, 13, 93, 15, AMBER.hi, 2, 2))
	lamp = lamp.merge(_far_rect(cv, g, 91, 14, 91, 15, AMBER.mid))
	_far_rect(cv, g, 88, 1, 89, 4, BRASS.lit, 2, 2)
	var img := cv.img
	if haze > 0.0:
		for y in img.get_height():
			for x in img.get_width():
				var px := img.get_pixel(x, y)
				if px.a > 0.0 and not lamp.has_point(Vector2i(x, y)):
					img.set_pixel(x, y, Color(px.lerp(HAZE, clampf(haze, 0.0, 1.0)), 1.0))
	return img


## The far tower's points at `height_px`: its image size, the foot (bottom middle under the door), the lamp's middle,
## the hook's end just above it, and the apex (the vane's tip).
static func far_points(height_px: int) -> Dictionary:
	var g := _far_grid(height_px)
	var lamp := _far_box(g, 92, 13, 93, 15, 2, 2)
	var hook := _far_box(g, 92, 9, 93, 11, 2, 2)
	return {"size": Vector2i(g.w, g.h), "foot": Vector2i(_far_box(g, 92, 72, 92, 72).position.x, g.h - 1),
		"lamp": lamp.get_center(), "lamp_rect": lamp, "hook": Vector2i(hook.get_center().x, hook.end.y - 1),
		"apex": Vector2i(_far_box(g, 88, 1, 89, 4, 2, 2).get_center().x, 0)}


## The far tower's grid: its 72 mock rows (y 1 to 72, the foot under x 92) scaled to fill height_px exactly.
static func _far_grid(height_px: int) -> Dictionary:
	var h := maxi(24, height_px)
	var k := h / 72.0
	var ax := int(ceilf(24.0 * k)) + 1
	return {"h": h, "k": k, "ax": ax, "w": ax + int(ceilf(22.0 * k)) + 2}


## A mock pixel's centre on the far grid.
static func _far_pt(g: Dictionary, p: Vector2) -> Vector2:
	return Vector2(g.ax + (p.x + 0.5 - 92.0) * g.k - 0.5, g.h - (73.0 - p.y - 0.5) * g.k - 0.5)


## A mock box (corners inclusive) on the far grid, at least minw by minh px.
static func _far_box(g: Dictionary, x0: int, y0: int, x1: int, y1: int, minw: int = 1, minh: int = 1) -> Rect2i:
	var px0 := Cv.rnd(g.ax + (x0 - 92) * g.k)
	var px1 := maxi(px0 + minw, Cv.rnd(g.ax + (x1 + 1 - 92) * g.k))
	var py0 := Cv.rnd(g.h - (73 - y0) * g.k)
	var py1 := maxi(py0 + minh, Cv.rnd(g.h - (73 - (y1 + 1)) * g.k))
	return Rect2i(px0, py0, px1 - px0, py1 - py0)


static func _far_rect(cv: Cv, g: Dictionary, x0: int, y0: int, x1: int, y1: int, c: Color, minw: int = 1, minh: int = 1) -> Rect2i:
	var r := _far_box(g, x0, y0, x1, y1, minw, minh)
	cv.rect(r.position.x, r.position.y, r.end.x - 1, r.end.y - 1, c)
	return r


static func _far_poly(cv: Cv, g: Dictionary, pts: Array, c: Color) -> void:
	var out: Array = []
	for p: Vector2 in pts:
		out.append(_far_pt(g, p))
	cv.poly(out, c)
