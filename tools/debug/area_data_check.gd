extends SceneTree
## The town's area files hold together (lane A, Claude, 2026-10-26; build plan 2.1, 02-town-rewire-design.md 7.3).
## Headless, no town scene: it reads scripts/world/areas/ through TownLayout (scripts/town/town_layout.gd).
## For today's map and for every Highbank v2 area: the format (AreaSchema.validate); every exit has a way back; every
## door, stand, lot and exit is reachable from where the area is entered; a walkable tile before each door; no prop on
## a door's approach; every anchor walkable; and across v2 the 13 place ids of today's town, each once, with the
## anchors the checks stand on. Also: the lots stand in their before state, and the East Quarter is shut unless the
## debug scene opens the exits. Prints each area as a map of letters, for reading.
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/area_data_check.gd
## Run with HT_HIGHBANK_V2=1 too (the gate runs both ways): the answers are the same, v2 is examined either way.

const Layout := preload("res://scripts/town/town_layout.gd")
const Areas := preload("res://scripts/world/areas/index.gd")
const PLACE_IDS := ["hall", "board", "lookout", "home", "shop", "storage", "scrolls", "yard", "shrine", "plaza", "landing", "gate", "dock"]
## The anchors the checks and captures stand on: each in today's map and in one v2 area.
const CHECK_ANCHORS := ["spawn", "return", "ferry_landing", "mouth_approach", "lane_walk", "home_walk", "yard_gate",
	"yard_gate_front", "music_street", "music_ferry", "board_start", "board_follow", "view_street", "view_terrace", "view_landing"]
const DIRS4 := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool, detail: Array = []) -> void:
	print("%s%s -> %s" % [what, "" if detail.is_empty() else " %s" % str(detail.slice(0, 6)), "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _run() -> void:
	print("Highbank v2 switch: %s (HT_HIGHBANK_V2=%s, HIGHBANK_V2 %s)" % [Layout.v2(), OS.get_environment("HT_HIGHBANK_V2"), Layout.HIGHBANK_V2])
	# Today's map, as the town reads it with the switch off.
	var v1: Dictionary = Areas.area(Layout.V1_AREA)
	_ok("today's map: the format holds", AreaSchema.validate(v1).is_empty(), Array(AreaSchema.validate(v1)))
	var v1_ids: Array = v1["places"].map(func(p: Dictionary) -> String: return p["id"])
	_ok("today's map: the 13 places, each once (%d)" % v1_ids.size(), _each_once(v1_ids))
	var v1_missing := CHECK_ANCHORS.filter(func(n: String) -> bool: return not v1["anchors"].has(n))
	_ok("today's map: every anchor the checks stand on", v1_missing.is_empty(), v1_missing)
	if not Layout.v2():
		_ok("switch off: the town shows today's map (%s, %s tiles)" % [Layout.area_id(), str(Layout.size())],
			Layout.area_id() == Layout.V1_AREA and Layout.size() == Vector2i(Layout.W, Layout.H) and Layout.PLACES == v1["places"])
		Layout.force_v2()   # examine v2 all the same, as the debug scene does
	Layout.open_exits = false
	var all_ids: Array = []
	var anchors := {}
	for id in Areas.v2_ids():
		var a: Dictionary = Areas.area(id)
		var bad := AreaSchema.validate(a)
		_ok("%s: the format holds" % id, bad.is_empty(), Array(bad))
		Layout.use(id, {})
		var g := Layout.grid()
		print(_map(a, g))
		for p in Layout.PLACES:
			if p["kind"] in ["building", "area", "spot"]:
				all_ids.append(p["id"])
		for n in a.get("anchors", {}):
			anchors[n] = anchors.get(n, []) + [id]
		_area_checks(id, a, g)
	_ok("v2: the 13 places of today's town, each once (%d)" % all_ids.size(), _each_once(all_ids), all_ids)
	var shared: Array = anchors.keys().filter(func(n: String) -> bool: return anchors[n].size() > 1)
	_ok("v2: no anchor name in two areas", shared.is_empty(), shared)
	var v2_missing := CHECK_ANCHORS.filter(func(n: String) -> bool: return not anchors.has(n))
	_ok("v2: every anchor the checks stand on has a tile", v2_missing.is_empty(), v2_missing)
	# How the areas join: from the street every area but the East Quarter, and that one only with the exits opened.
	var shut_reach := _reach_areas()
	Layout.open_exits = true
	var open_reach := _reach_areas()
	Layout.open_exits = false
	_ok("v2: from the street the walk reaches %s; the East Quarter shut" % str(shut_reach),
		not "east_quarter" in shut_reach and shut_reach.size() == Areas.v2_ids().size() - 1)
	_ok("v2: with the debug scene's open exits it reaches every area %s" % str(open_reach), open_reach.size() == Areas.v2_ids().size())
	# Lots stand in their before state with an empty record, and a lot's flag would open it.
	var lots: Array = []
	var before := true
	for id in Areas.v2_ids():
		for l in Areas.area(id).get("lots", []):
			lots.append(l["id"])
			before = before and not Layout.lot_open(l, {}) and Layout.lot_open(l, {"story": {String(l["opens"].get("flag", "")): true}, "beaten": [String(l["opens"].get("beaten", ""))]})
	_ok("v2: lots %s stand in their before state, and each opens on its condition" % str(lots), before and lots.size() == 5)
	# Saves keep place ids: an old arrive_at finds its area.
	var homes: Array = PLACE_IDS.filter(func(p: String) -> bool: return Layout.area_of(p) == "")
	_ok("v2: every place id resolves to an area (arrive_at in an old save)", homes.is_empty(), homes)
	print("AREA DATA: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)


## One area, shown by Layout.use() with an empty record: exits both ways, reach, doors, props and anchors.
func _area_checks(id: String, a: Dictionary, g: PackedByteArray) -> void:
	var size: Vector2i = a["size"]
	var open := func(t: Vector2i) -> bool: return Rect2i(Vector2i.ZERO, size).has_point(t) and g[t.y * size.x + t.x] == Layout.OPEN
	# Exits: each has a way back, landing on a walkable anchor next to it.
	var one_way: Array = []
	for e in a.get("exits", []):
		var to: Dictionary = Areas.area(String(e["to"]))
		var back: Array = to.get("exits", []).filter(func(x: Dictionary) -> bool: return x["to"] == id)
		var land: Vector2i = to.get("anchors", {}).get(String(e["at"]), Vector2i(-1, -1))
		if to.is_empty() or back.is_empty() or land == Vector2i(-1, -1):
			one_way.append(e["id"])
	_ok("%s: every exit has a way back and a tile to land on" % id, one_way.is_empty(), one_way)
	# Reach: from the area's arrival (spawn or the tile an exit into it lands on), every door, stand and exit.
	var start: Vector2i = a["anchors"].get("spawn", Vector2i(-1, -1))
	if start == Vector2i(-1, -1):
		for e in a.get("exits", []):
			for x in Areas.area(String(e["to"])).get("exits", []):
				if x["to"] == id and a["anchors"].has(String(x["at"])):
					start = a["anchors"][String(x["at"])]
	var seen := {start: true}
	var q: Array = [start]
	while not q.is_empty():
		var c: Vector2i = q.pop_front()
		for d in DIRS4:
			var n: Vector2i = c + d
			if not seen.has(n) and open.call(n):
				seen[n] = true
				q.append(n)
	var unreached: Array = []
	var no_front: Array = []
	var fronts := {}   # tiles a prop must keep off: doors, the tile before each, stands, lot fronts, exits
	for p in Layout.PLACES:
		var d: Vector2i = p["door"]
		match String(p["kind"]):
			"building":
				for t in Layout.door_tiles(p):
					fronts[t] = true
					fronts[t + Vector2i(0, 1)] = true
					if not open.call(t + Vector2i(0, 1)):
						no_front.append("%s %s" % [p["id"], str(t)])
					if not seen.has(t):
						unreached.append("%s door %s" % [p["id"], str(t)])
			"lot", "barrier":   # read from any tile beside the read tile
				var near: Array = DIRS4.map(func(v: Vector2i) -> Vector2i: return d + v).filter(func(t: Vector2i) -> bool: return seen.has(t))
				for v in DIRS4:
					fronts[d + v] = true
				if near.is_empty():
					unreached.append("%s %s" % [p["id"], str(d)])
			_:
				fronts[d] = true
				if not seen.has(d):
					unreached.append("%s stand %s" % [p["id"], str(d)])
	for e in Layout._open_exits:
		var r: Rect2i = e["rect"]
		var hit := false
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				fronts[Vector2i(x, y)] = true
				hit = hit or seen.has(Vector2i(x, y))
		if not hit:
			unreached.append("exit %s" % e["id"])
	_ok("%s: every door, stand, lot and open exit reachable from %s" % [id, str(start)], unreached.is_empty(), unreached)
	_ok("%s: a walkable tile before every door" % id, no_front.is_empty(), no_front)
	var on_front: Array = []
	for p in a.get("props", []):
		var r := Rect2i(p["tile"], p.get("size", Vector2i.ONE))
		for t in fronts:
			if r.has_point(t) and String(p.get("shut_exit", "")) == "":
				on_front.append("%s %s" % [p["slot"], str(p["tile"])])
		if not ArtSlots.has(String(p["slot"])):
			on_front.append("%s is not a slot" % p["slot"])
	_ok("%s: no prop on a door's approach, a stand or an exit (every prop a slot)" % id, on_front.is_empty(), on_front)
	var stuck: Array = []
	for n in a.get("anchors", {}):
		if not open.call(a["anchors"][n]):
			stuck.append("%s %s" % [n, str(a["anchors"][n])])
	_ok("%s: every anchor on a walkable tile" % id, stuck.is_empty(), stuck)
	var wide: Array = []
	for b in a.get("buildings", []):
		var cv: Vector2i = ArtSlots.spec(Layout.slot_of(b)).get("size", Vector2i.ZERO)
		if cv.x > 384 or cv.x > (b["base"] as Rect2i).size.x * Layout.T + 12:
			wide.append("%s %s" % [b["id"], str(cv)])
	_ok("%s: every building's art no wider than its base and eaves, and than the view" % id, wide.is_empty(), wide)


## The areas a walk from the street reaches through exits that are open (Layout.open_exits as set).
func _reach_areas() -> Array:
	var got: Array = [Areas.V2_FIRST]
	var q: Array = [Areas.V2_FIRST]
	while not q.is_empty():
		var at: String = q.pop_front()
		for e in Areas.area(at).get("exits", []):
			if Layout.exit_open(e, {}) and not got.has(e["to"]):
				got.append(e["to"])
				q.append(e["to"])
	return got


func _each_once(ids: Array) -> bool:
	if ids.size() != PLACE_IDS.size():
		return false
	for p in PLACE_IDS:
		if ids.count(p) != 1:
			return false
	return true


## The area as letters: % hedge, = cliff, ~ water, # path, . open, X solid (roofs, props), B building, @ door or stand,
## L lot, > exit, o open-air place.
func _map(a: Dictionary, g: PackedByteArray) -> String:
	var size: Vector2i = a["size"]
	var rows := PackedStringArray()
	var tens := "    "
	var ones := "    "
	for x in size.x:
		tens += str(x / 10)
		ones += str(x % 10)
	rows.append("== %s (%s) %dx%d tiles, %dx%d px" % [a["name"], a["id"], size.x, size.y, size.x * Layout.T, size.y * Layout.T])
	rows.append(tens)
	rows.append(ones)
	for y in size.y:
		var s := ""
		for x in size.x:
			var t := Vector2i(x, y)
			var c := "."
			var kind := Layout.band_of(y)
			c = {"hedge": "%", "cliff": "=", "water": "~", "terrace": ":"}.get(kind, ".")
			for r in Layout.PATHS:
				if r.has_point(t):
					c = "#"
			for p in Layout.PLACES:
				if (p["rect"] as Rect2i).has_point(t):
					c = {"building": "B", "spot": "S", "lot": "L", "barrier": "|"}.get(p["kind"], "o")
			if g[y * size.x + x] == Layout.WALL and c in [".", "#", ":", "o"]:
				c = "X"
			for p in Layout.PLACES:
				if t == p["door"] or t in Layout.door_tiles(p):
					c = "@"
			if not Layout.exit_at(t).is_empty():
				c = ">"
			s += c
		rows.append("%2d  %s" % [y, s])
	return "\n".join(rows)
