extends RefCounted
## The hub town's layout (Claude, 2026-10-09; Preston: "do the world layout with the synthesis so
## Codex can just fill it in"). Highbank from the world bible ("upper streets hold homes, shops, and
## the dispatch hall. Switchback lanes descend ... to the ferry district"), laid out as a
## dungeon-crawler hub: Explorers of Sky's crossroads town (the guild on the high ground, a street of services,
## the hero's home apart, paths down to the water and out to the dungeons) and Rescue Team DX's square
## of services. Structure only; every name here is a working name from the world bible or a role.
##
## This file is the contract: positions, sizes, doors and jobs. Codex paints art to these rects and
## must not move a door or a path tile without telling Claude (the rules and the checks read them).
## Tiles are 24 px, the dungeon's size, so creatures walk the town at the same scale.
##
## Since 2026-10-26 (Claude, placeholder factory lane A) the map itself lives in area files under
## scripts/world/areas/ (index.gd lists them; the format is 02-town-rewire-design.md section 3.2). Today's map is
## highbank_v1.gd, tile for tile, and this file stays the API the town's scripts call: T, W, H, SPAWN, BANDS, PATHS,
## PLACES, grid(), door_tiles(), place_at(). With Highbank v2 off (the default) nothing here changes.
## With it on, BANDS, PATHS and PLACES hold the area the town is showing (use()), so a script that reads
## Layout.PLACES sees that area; W, H and SPAWN stay today's map's, and size() is the current area's.

const Areas := preload("res://scripts/world/areas/index.gd")

const T := 24
const W: int = Areas.V1.AREA["size"].x
const H: int = Areas.V1.AREA["size"].y

# Terrain bands, top to bottom, of the area shown ({from, to, kind} rows; highbank_v1.gd for today's).
static var BANDS: Array = Areas.V1.AREA["ground"]["bands"]

# Paths (walkable, drawn as lanes), as rects. The cliff crossings are the switchbacks.
static var PATHS: Array = _rects(Areas.V1.AREA["paths"])

# Buildings: solid footprints; the door is the one walkable tile of the footprint, on its street
# side. Areas: open walkable spaces with a spot to stand on. Every place has a service the rules use.
# In v2 an area's buildings come first, as places of kind "building" with their base as the rect; a lot not open yet
# is kind "lot" and a shut exit kind "barrier": both solid all through, read from the tile in front.
static var PLACES: Array = Areas.V1.AREA["places"]
const SPAWN: Vector2i = Areas.V1.AREA["anchors"]["spawn"]   # outside Home's door, the start of a day

enum { WALL, OPEN }


## The walkable grid: terrain bands, then paths, then places (a building or a spot is solid except its
## door tiles; Claude, 2026-10-22, LP-13: the Job Board and the Mouth's stones are no longer walked onto).
## In v2 also: an area's ground rects, the rows its roofs cover, its solid props, and its open exits.
static func grid() -> PackedByteArray:
	var w := _size.x
	var h := _size.y
	var g := PackedByteArray()
	g.resize(w * h)
	for b in BANDS:
		for y in range(b["from"], mini(b["to"] + 1, h)):
			for x in w:
				g[y * w + x] = OPEN if b["kind"] in ["grass", "terrace"] else WALL
	if _area != "":
		for r in area().get("ground", {}).get("rects", []):
			_fill(g, r["rect"], OPEN if r["kind"] in ["grass", "terrace"] else WALL)
	for r in PATHS:
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				g[y * w + x] = OPEN
	for p in PLACES:
		var r: Rect2i = p["rect"]
		if p["kind"] in ["building", "spot", "lot", "barrier"]:
			for y in range(r.position.y, r.end.y):
				for x in range(r.position.x, r.end.x):
					g[y * w + x] = WALL
		if p["kind"] in ["lot", "barrier"]:
			continue
		for d in door_tiles(p):
			g[d.y * w + d.x] = OPEN
	if _area != "":
		for r in solid_rects():
			_fill(g, r, WALL)
		for e in _open_exits:
			_fill(g, e["rect"], OPEN)
	return g


## Every walkable door tile of a place: its "door", or all of "door_tiles" when it has them.
static func door_tiles(p: Dictionary) -> Array:
	return p.get("door_tiles", [p["door"]])


static func band_of(y: int) -> String:
	for b in BANDS:
		if y >= b["from"] and y <= b["to"]:
			return b["kind"]
	return "water"


## A place's name by its id ("gate" -> "Mouth of the Hollow"), or "" for none (Claude, 2026-10-26, pass 8 T2 / L03):
## the street's plaque, the town's run line and the objective read the gate's name from here, so a rename is one edit.
## In v2 the place may be in another area than the one shown.
static func place_name(id: String) -> String:
	for p in PLACES:
		if p["id"] == id:
			return String(p["name"])
	if v2():
		return String(place(id).get("name", ""))
	return ""


static func place_at(t: Vector2i) -> Dictionary:
	for p in PLACES:
		if t in door_tiles(p):
			return p
	return {}


# Town areas (lane A, Claude, 2026-10-26; build plan section 2.1). The API was written as stubs by the placeholder
# factory contract; these are the bodies. With Highbank v2 off there is one area, today's map (V1_AREA), and the town
# never calls use(): every list above stays as it was.
const V1_AREA := "highbank_v1"
const HIGHBANK_V2 := false   # the v2 switch (Preston walks v2 before it is on); HT_HIGHBANK_V2=1 also turns it on
## Today's named tiles (highbank_v1.gd's anchors): the contract's name for them.
const ANCHORS: Dictionary = Areas.V1.AREA["anchors"]

static var _area := ""             # the area use() last showed; "" while today's map is the only one
static var _size := Vector2i(W, H)
static var _open_exits: Array = []  # the shown area's exits that may be walked through
static var _forced := false        # scenes/debug/highbank_v2.tscn turns v2 on for the session
## The debug scene opens every exit, so the East Quarter (behind a flag nothing sets) can be walked.
static var open_exits := false


## With the switch on from the start (HT_HIGHBANK_V2=1), the lists above hold v2's first area until the town picks.
static func _static_init() -> void:
	if v2():
		use(Areas.V2_FIRST)


## True when the rewired Highbank (street, Tower Rise, Old Ferry Ward, East Quarter) is on.
static func v2() -> bool:
	return HIGHBANK_V2 or _forced or OS.get_environment("HT_HIGHBANK_V2") == "1"


## Turns v2 on for the session without the environment (scenes/debug/highbank_v2.tscn), and opens every exit.
static func force_v2() -> void:
	_forced = true
	open_exits = true
	use(Areas.V2_FIRST)


## The area the town is showing.
static func area_id() -> String:
	if not v2():
		return V1_AREA
	return _area if _area != "" else Areas.V2_FIRST


## Every area the town has: today's map alone, or v2's.
static func areas() -> PackedStringArray:
	return Areas.v2_ids() if v2() else PackedStringArray([V1_AREA])


## An area as data (02-town-rewire-design.md section 3.2; read-only); "" means the current area. With v2 off only
## today's map exists.
static func area(id: String = "") -> Dictionary:
	var want := id if id != "" else area_id()
	if not want in areas():
		return {}
	return Areas.area(want)


## The current area's size in tiles (W x H with v2 off).
static func size() -> Vector2i:
	return _size


## Show area `id`: BANDS, PATHS and PLACES become its own, and the grid follows. `rec` is the team's record, for lots
## that open with the story and exits that need a flag. False for an area the town does not have.
static func use(id: String, rec: Dictionary = {}) -> bool:
	if not id in areas():
		return false
	var a: Dictionary = Areas.area(id)
	_area = id
	_size = a["size"]
	BANDS = a.get("ground", {}).get("bands", [])
	PATHS = _rects(a.get("paths", []))
	PLACES = _places_of(a, rec)
	_open_exits = a.get("exits", []).filter(func(e: Dictionary) -> bool: return exit_open(e, rec))
	return true


## The area a place id lives in ("hall" -> "highbank_v1", or "hall_rise" in v2), or "" for none. Saves keep place
## ids, so an old arrive_at still resolves through this.
static func area_of(place_id: String) -> String:
	for id in areas():
		for p in _places_of(Areas.area(id), {}):
			if p["id"] == place_id:
				return id
	return ""


## A named tile in an area ("" = the current one), or (-1, -1) when it has no such anchor.
static func anchor(anchor_name: String, area_name: String = "") -> Vector2i:
	return area(area_name).get("anchors", {}).get(anchor_name, Vector2i(-1, -1))


## The area that has the anchor `anchor_name` (anchor names are not shared between areas), or "".
static func anchor_area(anchor_name: String) -> String:
	for id in areas():
		if Areas.area(id).get("anchors", {}).has(anchor_name):
			return id
	return ""


## A place by id, from whichever area has it (with "area" added), or {}.
static func place(id: String) -> Dictionary:
	var where := area_of(id)
	if where == "":
		return {}
	var src: Array = PLACES if where == area_id() else _places_of(Areas.area(where), {})
	for p in src:
		if p["id"] == id:
			var out: Dictionary = p.duplicate()
			out["area"] = where
			return out
	return {}


## Where to head for a place: its door when it is in the area shown, else the first tile of the exit that starts the
## shortest way to its area; (-1, -1) when there is no way. The board scene's crew run for the Mouth this way.
static func way_to(place_id: String) -> Vector2i:
	for p in PLACES:
		if p["id"] == place_id:
			return p["door"]
	var goal := area_of(place_id)
	if goal == "":
		return Vector2i(-1, -1)
	var first := {}   # area -> the exit out of the shown area that reached it first
	var queue: Array = []
	for e in _open_exits:
		if not first.has(e["to"]):
			first[e["to"]] = e
			queue.append(e["to"])
	while not queue.is_empty():
		var at: String = queue.pop_front()
		if at == goal:
			return (first[at]["rect"] as Rect2i).position
		for e in Areas.area(at).get("exits", []):
			if not first.has(e["to"]) and e["to"] != area_id() and exit_open(e, {}):
				first[e["to"]] = first[at]
				queue.append(e["to"])
	return Vector2i(-1, -1)


## The open exit under tile `t` in the area shown, or {}.
static func exit_at(t: Vector2i) -> Dictionary:
	for e in _open_exits:
		if (e["rect"] as Rect2i).has_point(t):
			return e
	return {}


## Whether an exit may be walked through: it needs nothing, or the story flag it needs is set, or the debug scene
## opened every exit.
static func exit_open(e: Dictionary, rec: Dictionary) -> bool:
	var needs := String(e.get("needs", ""))
	return needs == "" or open_exits or bool(rec.get("story", {}).get(needs, false))


## Whether a lot is open: its "opens" condition holds in the record ({"beaten": dungeon id} or {"flag": story flag}).
## Nothing opens a lot yet (build plan 2.1 step 4); one with no "building" stays in its before state either way.
static func lot_open(lot: Dictionary, rec: Dictionary) -> bool:
	var opens: Dictionary = lot.get("opens", {})
	if opens.has("beaten"):
		return String(opens["beaten"]) in rec.get("beaten", [])
	if opens.has("flag"):
		return bool(rec.get("story", {}).get(String(opens["flag"]), false))
	return false


## The art slot a lot shows before it opens, or a building shows.
static func slot_of(b: Dictionary) -> String:
	return String(b.get("slot", "town.building." + String(b.get("id", ""))))


## How many tile rows a building's roof covers above its base (02 section 4.3): its art's height in whole tiles, less
## the base's depth. The art's size is its slot's (scripts/art/slots/town_buildings.gd), else its class's canvas.
static func roof_rows(b: Dictionary) -> int:
	if b.get("walk_behind", false):
		return 0
	var tall: int = (ArtSlots.spec(slot_of(b)).get("size", Vector2i.ZERO) as Vector2i).y
	if tall <= 0:
		tall = BuildingTemplate.canvas(String(b.get("class", ""))).y
	return maxi(0, ceili(tall / float(T)) - (b["base"] as Rect2i).size.y)


## The shown area's solid rects beyond its places: the rows its roofs cover (buildings and lots) and its solid props
## (a prop with "shut_exit" only while that exit is shut). Each is clipped to the area.
static func solid_rects() -> Array:
	var a := area()
	var out: Array = []
	var roofed: Array = a.get("buildings", []).duplicate()
	roofed.append_array(a.get("lots", []))
	for b in roofed:
		var base: Rect2i = b["base"]
		var rows := roof_rows(b)
		if rows > 0:
			out.append(Rect2i(base.position.x, base.position.y - rows, base.size.x, rows))
	var open_ids: Array = _open_exits.map(func(e: Dictionary) -> String: return String(e["id"]))
	for p in a.get("props", []):
		if not p.get("solid", false) or String(p.get("shut_exit", "")) in open_ids:
			continue
		out.append(Rect2i(p["tile"], TownProps.footprint(p)))   # lane C's footprint: its "size", else its slot's (bench 2x1, well 2x2, barrier 1x2)
	var bounds := Rect2i(Vector2i.ZERO, _size)
	return out.map(func(r: Rect2i) -> Rect2i: return r.intersection(bounds)).filter(func(r: Rect2i) -> bool: return r.has_area())


## An area's places in the shape PLACES has always had: its buildings ("building", the base as the rect), its lots
## (open ones that have a building become one; the rest "lot"), its open-air places as they are, and each shut exit
## that says why ("barrier").
static func _places_of(a: Dictionary, rec: Dictionary) -> Array:
	if a.get("id", "") == V1_AREA:
		return a["places"]
	var out: Array = []
	for b in a.get("buildings", []):
		out.append(_as_place(b))
	for l in a.get("lots", []):
		if lot_open(l, rec) and l.has("building"):
			var b: Dictionary = (l["building"] as Dictionary).duplicate()
			b["base"] = l["base"]
			b["class"] = l["class"]
			out.append(_as_place(b))
		else:
			out.append({"id": l["id"], "name": l.get("name", "Empty Lot"), "kind": "lot", "rect": l["base"], "door": l["door"],
				"service": "lot", "what": l.get("what", "")})
	out.append_array(a.get("places", []))
	for e in a.get("exits", []):
		if e.has("shut") and not exit_open(e, rec):
			out.append({"id": e["id"], "name": e.get("name", ""), "kind": "barrier", "rect": e["rect"],
				"door": (e["rect"] as Rect2i).position, "service": "closed", "what": e["shut"]})
	return out


static func _as_place(b: Dictionary) -> Dictionary:
	var doors: Array = b.get("door", [])
	var p := {"id": b["id"], "name": b["name"], "kind": "building", "rect": b["base"], "door": doors[0] if not doors.is_empty() else (b["base"] as Rect2i).end - Vector2i.ONE,
		"service": b["service"], "what": b.get("what", ""), "class": b.get("class", ""), "slot": slot_of(b)}
	if doors.size() > 1:
		p["door_tiles"] = doors
	return p


static func _rects(paths: Array) -> Array:
	return paths.map(func(p: Dictionary) -> Rect2i: return p["rect"])


static func _fill(g: PackedByteArray, r: Rect2i, v: int) -> void:
	var c := r.intersection(Rect2i(Vector2i.ZERO, _size))
	for y in range(c.position.y, c.end.y):
		for x in range(c.position.x, c.end.x):
			g[y * _size.x + x] = v
