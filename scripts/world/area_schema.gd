class_name AreaSchema
extends RefCounted
## The town area format's checker (Claude, 2026-10-26, placeholder factory contract). One area is one Dictionary
## (scripts/world/areas/<id>.gd holds it as `const AREA`), with the fields of 02-town-rewire-design.md section 3.2,
## buildings as in 3.3, interiors as in 3.5 and lots as in 3.6. validate() lists every problem in plain words; an
## empty list means the area is well formed. Reachability (two-way exits, every door reachable) is
## area_data_check's job (lane A), since it needs the walkable grid.

const KINDS := ["exterior", "interior"]
const GROUND := ["grass", "terrace", "cliff", "water", "hedge"]
const PATH_KINDS := ["lane", "steps", "boardwalk"]
const PLACE_KINDS := ["building", "area", "spot"]   # "building" places are today's v1 entries; v2 uses "buildings"
const CLASSES := ["cottage", "shop", "stall", "hall"]
const ROOFS := ["moss", "gable", "hip", "flat", "awning"]
const WALLS := ["stone", "plank", "timber", "river_stone"]
const FACINGS := ["n", "s", "e", "w"]


static func validate(area: Dictionary) -> PackedStringArray:
	var bad: PackedStringArray = []
	var id := String(area.get("id", ""))
	if id == "":
		bad.append("area: no id")
	var tag := "area '%s'" % id
	if String(area.get("name", "")) == "":
		bad.append("%s: no name" % tag)
	var kind := String(area.get("kind", ""))
	if not kind in KINDS:
		bad.append("%s: kind '%s' is not exterior or interior" % [tag, kind])
	var size: Variant = area.get("size")
	if not size is Vector2i or size.x <= 0 or size.y <= 0:
		bad.append("%s: size must be a Vector2i of tiles" % tag)
		return bad
	var bounds := Rect2i(Vector2i.ZERO, size)
	for f in ["card", "music"]:
		if area.has(f) and not area[f] is String:
			bad.append("%s: %s must be a String" % [tag, f])
	_ground(area.get("ground", {}), kind, bounds, tag, bad)
	var seen := {}
	for p in _list(area, "paths", tag, bad):
		_rect_in(p.get("rect"), bounds, "%s path" % tag, bad)
		if not String(p.get("kind", "")) in PATH_KINDS:
			bad.append("%s: path kind '%s' unknown" % [tag, String(p.get("kind", ""))])
	for b in _list(area, "buildings", tag, bad):
		_building(b, bounds, tag, bad)
		_unique(String(b.get("id", "")), seen, tag, bad)
	for p in _list(area, "places", tag, bad):
		_place(p, bounds, tag, bad)
		_unique(String(p.get("id", "")), seen, tag, bad)
	for p in _list(area, "props", tag, bad):
		var slot := String(p.get("slot", ""))
		if slot == "" or not ArtSlots.has(slot):
			bad.append("%s: prop slot '%s' is not a registered art slot" % [tag, slot])
		_tile_in(p.get("tile"), bounds, "%s prop %s" % [tag, slot], bad)
	for l in _list(area, "lots", tag, bad):
		var lid := String(l.get("id", ""))
		_unique(lid, seen, tag, bad)
		_rect_in(l.get("base"), bounds, "%s lot %s base" % [tag, lid], bad)
		if not String(l.get("class", "")) in CLASSES:
			bad.append("%s: lot %s class '%s' unknown" % [tag, lid, String(l.get("class", ""))])
		if not l.get("opens", {}) is Dictionary or (l.get("opens", {}) as Dictionary).is_empty():
			bad.append("%s: lot %s needs an opens condition ({beaten: ...} or {flag: ...})" % [tag, lid])
	for e in _list(area, "exits", tag, bad):
		var eid := String(e.get("id", ""))
		_rect_in(e.get("rect"), bounds, "%s exit %s" % [tag, eid], bad)
		if String(e.get("to", "")) == "" or String(e.get("at", "")) == "":
			bad.append("%s: exit %s needs to (an area id) and at (an anchor or place id there)" % [tag, eid])
		if e.has("facing") and not String(e["facing"]) in FACINGS:
			bad.append("%s: exit %s facing '%s' unknown" % [tag, eid, String(e["facing"])])
	var anchors: Variant = area.get("anchors", {})
	if not anchors is Dictionary:
		bad.append("%s: anchors must be a Dictionary of name -> tile" % tag)
	else:
		for n in anchors:
			_tile_in(anchors[n], bounds, "%s anchor %s" % [tag, n], bad)
	for n in _list(area, "npcs", tag, bad):
		if String(n.get("form", "")) == "":
			bad.append("%s: an npc has no form" % tag)
		_tile_in(n.get("tile"), bounds, "%s npc %s" % [tag, String(n.get("form", ""))], bad)
	for s in _list(area, "spots", tag, bad):
		_rect_in(s.get("rect"), bounds, "%s spot %s" % [tag, String(s.get("id", ""))], bad)
	return bad


static func _ground(g: Variant, kind: String, bounds: Rect2i, tag: String, bad: PackedStringArray) -> void:
	if not g is Dictionary:
		bad.append("%s: ground must be a Dictionary" % tag)
		return
	if kind == "interior":
		var walls: Variant = g.get("walls", {})
		if not walls is Dictionary:
			bad.append("%s: ground.walls must be {n, s, w, e} tiles" % tag)
		return
	for b in g.get("bands", []):   # today's map: rows {from, to, kind}
		if not String(b.get("kind", "")) in GROUND:
			bad.append("%s: ground band kind '%s' unknown" % [tag, String(b.get("kind", ""))])
		if int(b.get("from", -1)) < 0 or int(b.get("to", -1)) >= bounds.size.y:
			bad.append("%s: ground band rows %s-%s outside the area" % [tag, str(b.get("from")), str(b.get("to"))])
	for r in g.get("rects", []):
		_rect_in(r.get("rect"), bounds, "%s ground rect" % tag, bad)
		if not String(r.get("kind", "")) in GROUND:
			bad.append("%s: ground rect kind '%s' unknown" % [tag, String(r.get("kind", ""))])


static func _building(b: Dictionary, bounds: Rect2i, tag: String, bad: PackedStringArray) -> void:
	var bid := String(b.get("id", ""))
	var t := "%s building %s" % [tag, bid]
	for f in ["id", "name", "service"]:
		if String(b.get(f, "")) == "":
			bad.append("%s: no %s" % [t, f])
	if not String(b.get("class", "")) in CLASSES:
		bad.append("%s: class '%s' unknown" % [t, String(b.get("class", ""))])
	var base: Variant = b.get("base")
	if not _rect_in(base, bounds, t + " base", bad):
		return
	var doors: Variant = b.get("door", [])
	if not doors is Array or (doors.is_empty() and String(b.get("class", "")) != "stall"):
		bad.append("%s: door must list its door tiles" % t)
	else:
		for d in doors:
			if not d is Vector2i or d.y != base.end.y - 1 or d.x < base.position.x or d.x >= base.end.x:
				bad.append("%s: door %s is not on the base's bottom row" % [t, str(d)])
	if b.has("roof") and not String(b["roof"]) in ROOFS:
		bad.append("%s: roof '%s' unknown" % [t, String(b["roof"])])
	if b.has("wall") and not String(b["wall"]) in WALLS:
		bad.append("%s: wall '%s' unknown" % [t, String(b["wall"])])
	if b.has("sign") and (not b["sign"] is Dictionary or not b["sign"].has("col") or not b["sign"].has("icon")):
		bad.append("%s: sign must be {col, icon}" % t)
	var slot := String(b.get("slot", "town.building." + bid))
	if not ArtSlots.has(slot):
		bad.append("%s: art slot '%s' is not registered" % [t, slot])


static func _place(p: Dictionary, bounds: Rect2i, tag: String, bad: PackedStringArray) -> void:
	var pid := String(p.get("id", ""))
	var t := "%s place %s" % [tag, pid]
	for f in ["id", "name", "service"]:
		if String(p.get(f, "")) == "":
			bad.append("%s: no %s" % [t, f])
	if not String(p.get("kind", "")) in PLACE_KINDS:
		bad.append("%s: kind '%s' unknown" % [t, String(p.get("kind", ""))])
	_rect_in(p.get("rect"), bounds, t + " rect", bad)
	_tile_in(p.get("door"), bounds, t + " door", bad)
	for d in p.get("door_tiles", []):
		_tile_in(d, bounds, t + " door tile", bad)


static func _list(area: Dictionary, field: String, tag: String, bad: PackedStringArray) -> Array:
	var v: Variant = area.get(field, [])
	if not v is Array:
		bad.append("%s: %s must be an Array" % [tag, field])
		return []
	var out: Array = []
	for e in v:
		if e is Dictionary:
			out.append(e)
		else:
			bad.append("%s: an entry of %s is not a Dictionary" % [tag, field])
	return out


static func _unique(id: String, seen: Dictionary, tag: String, bad: PackedStringArray) -> void:
	if id == "":
		return
	if seen.has(id):
		bad.append("%s: id '%s' is used twice" % [tag, id])
	seen[id] = true


static func _rect_in(r: Variant, bounds: Rect2i, what: String, bad: PackedStringArray) -> bool:
	if not r is Rect2i or r.size.x <= 0 or r.size.y <= 0:
		bad.append("%s: needs a Rect2i with a size" % what)
		return false
	if not bounds.encloses(r):
		bad.append("%s %s is outside the area" % [what, str(r)])
		return false
	return true


static func _tile_in(t: Variant, bounds: Rect2i, what: String, bad: PackedStringArray) -> void:
	if not t is Vector2i:
		bad.append("%s: needs a Vector2i tile" % what)
	elif not bounds.has_point(t):
		bad.append("%s %s is outside the area" % [what, str(t)])
