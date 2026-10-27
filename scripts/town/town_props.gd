class_name TownProps
extends RefCounted
## Street props and lamps for a town area (Claude, 2026-10-26, placeholder factory lane C; build plan section 2.3).
## An area's "props" list (02-town-rewire-design.md section 3.2: {slot, tile, solid, light, flat}) drawn through
## ArtSlots: Grok's file when it is installed at its exact size, the coded placeholder (scripts/art/placeholders/
## street_props.gd) until then. Under each prop a ground shadow, and on a lit lamp a stepped glow with a wick's flicker,
## both in code (the slot's art carries neither), so an installed file drops onto the same foot.
##
## An entry may also say "flip_h": true (the art mirrored about its foot, so one fence corner turns either way),
## "state" (a still other than the first) and "size" (its footprint).
##
## Where a prop stands: `tile` is the top-left tile of its footprint (1 x 1 for most, 2 x 2 for the well, 2 x 1 for
## the bench, 1 x 2 for the road barrier; a prop may give its own "size"). The slot's anchor pixel (its foot row,
## centred) lands on the bottom row of that footprint, centred, the way a creature's feet sit 23 px down its tile. It
## sorts with the creatures by that foot row; a "flat" prop lies under them. A solid prop's footprint is blocked:
## solid_tiles() is what the town's grid takes. problems() lists a prop that is off the map, unknown, on another
## prop, inside a building or spot, or on a door's or an exit's approach (town_props_check runs it on every area).
##
## Today's map has no props list (TownLayout.area() gives []), so build() adds nothing there and today's town does not
## change.

const T := 24
const FOOTPRINT := {"town.prop.well": Vector2i(2, 2), "town.prop.bench": Vector2i(2, 1), "town.prop.road_barrier": Vector2i(1, 2)}
const SHADOW := Color(0, 0, 0, 0.33)   # a third darker than the ground (building_exteriors.gd's contact shadow rule)
## The lit lamp's glow: stepped rings (town_room.gd's lantern) in the lantern's warm light, between two levels at the
## wick's uneven moments; each lamp starts somewhere else in the list, so a row of them never flickers as one.
const GLOW_RADIUS := 18
const GLOW_COLOUR := Color("#ffd98a")
const GLOW_LEVELS := [0.1, 0.17]
const GLOW_STEPS := [[1, 0.6], [0, 0.23], [1, 0.9], [0, 0.17], [1, 0.41], [0, 0.12], [1, 1.1]]
static var _shadows := {}   # "w x h x band" -> its texture, made once
static var _glow: Texture2D


## Adds the area's props under `parent` and returns the nodes it made (one Node2D per prop, in the list's order).
static func build(area: Dictionary, parent: Node) -> Array:
	var made: Array = []
	if parent == null:
		return made
	var props: Array = area.get("props", [])
	for i in props.size():
		var p: Dictionary = props[i]
		var slot := String(p.get("slot", ""))
		if not ArtSlots.has(slot):
			push_warning("TownProps: no art slot '%s' (area %s)" % [slot, String(area.get("id", ""))])
			continue
		var spec := ArtSlots.spec(slot)
		var node := Node2D.new()
		node.name = "Prop_%s_%d" % [slot.get_slice(".", 2), i]
		node.position = Vector2(foot_px(p))
		node.z_index = 1 if bool(p.get("flat", false)) else int(node.position.y)   # flat: on the ground, under everyone
		node.set_meta("slot", slot)
		node.set_meta("tile", p.get("tile", Vector2i.ZERO))
		parent.add_child(node)
		node.add_child(_shadow(spec))
		var art := Sprite2D.new()
		art.name = "Art"
		art.centered = false
		art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		art.position = -Vector2(spec.get("anchor", Vector2i.ZERO))
		if bool(p.get("flip_h", false)):   # a mirrored prop (a fence corner joining to the left): the foot stays put
			art.flip_h = true
			art.position.x = -float((spec["size"] as Vector2i).x - 1 - (spec["anchor"] as Vector2i).x)
		node.add_child(art)
		if String(spec["kind"]) == "lamp":
			_lamp(node, spec, bool(p.get("light", false)), i)
		else:
			art.texture = ArtSlots.frame(slot, String(p.get("state", "")))
		made.append(node)
	return made


## Lights or darkens lamps build() made: the lit or unlit still, and the glow shown or hidden.
static func set_lit(nodes: Array, on: bool) -> void:
	for n in nodes:
		if n is Node2D and n.has_node("Art") and String(n.get_meta("slot", "")).begins_with("town.lamp."):
			(n.get_node("Art") as Sprite2D).texture = ArtSlots.frame(String(n.get_meta("slot")), "lit" if on else "unlit")
			var glow: Node = n.get_node_or_null("Glow")
			if glow != null:
				glow.visible = on


## A prop's footprint in tiles.
static func footprint(p: Dictionary) -> Vector2i:
	if p.get("size") is Vector2i:
		return p["size"]
	var slot := String(p.get("slot", ""))
	if FOOTPRINT.has(slot):
		return FOOTPRINT[slot]
	var cell: Vector2i = ArtSlots.spec(slot).get("size", Vector2i(T, T))
	return Vector2i(maxi(1, ceili(cell.x / float(T))), 1)


## The tiles a prop covers.
static func tiles_of(p: Dictionary) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var at: Vector2i = p.get("tile", Vector2i.ZERO)
	var fp := footprint(p)
	for y in fp.y:
		for x in fp.x:
			out.append(at + Vector2i(x, y))
	return out


## The pixel a prop's anchor lands on: the bottom row of its footprint, centred (a creature's feet are 23 px down).
static func foot_px(p: Dictionary) -> Vector2i:
	var at: Vector2i = p.get("tile", Vector2i.ZERO)
	var fp := footprint(p)
	return Vector2i(at.x * T + fp.x * T / 2, (at.y + fp.y) * T - 1)


## Every tile a solid prop blocks ("solid": true, as TownLayout's grid reads it): the town's grid makes them walls.
static func solid_tiles(area: Dictionary) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for p in area.get("props", []):
		if bool(p.get("solid", false)):
			for t in tiles_of(p):
				if not out.has(t):
					out.append(t)
	return out


## The tiles a prop must leave clear, each with why: every door tile and the tile in front of it, every stand of an
## open-air place and the tiles that step onto it, every exit and the tile inside it, every named anchor.
static func approach_tiles(area: Dictionary) -> Dictionary:
	var out := {}
	var size: Vector2i = area.get("size", Vector2i(48, 32))
	for b in area.get("buildings", []):
		var base: Rect2i = b["base"]
		for d: Vector2i in b.get("door", []):
			out[d] = "the door of %s" % b["id"]
			out[d + (Vector2i.DOWN if d.y == base.end.y - 1 else Vector2i.UP)] = "in front of the door of %s" % b["id"]
	for p in area.get("places", []):
		var r: Rect2i = p["rect"]
		for d: Vector2i in p.get("door_tiles", [p["door"]]):
			out[d] = "the %s of %s" % ["door" if p["kind"] == "building" else "stand", p["id"]]
			for n in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
				if not r.has_point(d + n):
					out[d + n] = "the way onto %s" % p["id"]
	for e in area.get("exits", []):
		var r: Rect2i = e["rect"]
		var inward := Vector2i.ZERO
		if r.position.y == 0:
			inward = Vector2i.DOWN
		elif r.end.y == size.y:
			inward = Vector2i.UP
		elif r.position.x == 0:
			inward = Vector2i.RIGHT
		elif r.end.x == size.x:
			inward = Vector2i.LEFT
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				out[Vector2i(x, y)] = "the exit %s" % e.get("id", "")
				if inward != Vector2i.ZERO and not r.has_point(Vector2i(x, y) + inward):
					out[Vector2i(x, y) + inward] = "the way to the exit %s" % e.get("id", "")
	var anchors: Dictionary = area.get("anchors", {})
	for n in anchors:
		out[anchors[n]] = "the anchor %s" % n
	return out


## What is wrong with an area's props, in plain words; empty when every one resolves and stands clear.
static func problems(area: Dictionary) -> PackedStringArray:
	var bad: PackedStringArray = []
	var size: Vector2i = area.get("size", Vector2i(48, 32))
	var bounds := Rect2i(Vector2i.ZERO, size)
	var keep := approach_tiles(area)
	var solid := {}   # tile -> what blocks it
	for b in area.get("buildings", []):
		_mark(solid, b["base"], "the building %s" % b["id"], b.get("door", []))
	for l in area.get("lots", []):
		_mark(solid, l["base"], "the lot %s" % l["id"], [])
	for p in area.get("places", []):
		if String(p.get("kind", "")) in ["building", "spot"]:
			_mark(solid, p["rect"], "the %s %s" % [p["kind"], p["id"]], p.get("door_tiles", [p["door"]]))
	var shut := {}   # exit tiles a prop is there to close ("shut_exit": the exit's id), and the way onto them
	for e in area.get("exits", []):
		for p in area.get("props", []):
			if String(p.get("shut_exit", "")) != "" and String(p.get("shut_exit", "")) == String(e.get("id", "")):
				for t in tiles_of(p):
					shut[t] = true
	var taken := {}
	var tag := String(area.get("id", "?"))
	var props: Array = area.get("props", [])
	for i in props.size():
		var p: Dictionary = props[i]
		var slot := String(p.get("slot", ""))
		var what := "%s prop %d (%s at %s)" % [tag, i, slot, str(p.get("tile"))]
		if not ArtSlots.has(slot):
			bad.append("%s: not a registered art slot" % what)
			continue
		var kind := String(ArtSlots.spec(slot).get("kind", ""))
		if not kind in ["prop", "lamp"]:
			bad.append("%s: a %s slot, not a prop or lamp" % [what, kind])
		if not p.get("tile") is Vector2i:
			bad.append("%s: tile must be a Vector2i" % what)
			continue
		var states: Dictionary = ArtSlots.spec(slot).get("states", {})
		if kind == "lamp" and not (states.has("lit") and states.has("unlit")):
			bad.append("%s: a lamp needs both its lit and unlit states" % what)
		for t in tiles_of(p):
			if not bounds.has_point(t):
				bad.append("%s: tile %s is off the area" % [what, str(t)])
			if keep.has(t) and not shut.has(t):
				bad.append("%s: on %s %s" % [what, keep[t], str(t)])
			if solid.has(t):
				bad.append("%s: inside %s %s" % [what, solid[t], str(t)])
			if taken.has(t):
				bad.append("%s: on top of %s %s" % [what, taken[t], str(t)])
			taken[t] = "prop %d (%s)" % [i, slot]
	return bad


static func _mark(into: Dictionary, r: Rect2i, what: String, open: Array) -> void:
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			if not open.has(Vector2i(x, y)):
				into[Vector2i(x, y)] = what


## The ground shadow under a prop, falling to the lower right: a stepped oval at its foot for a standing prop, a low
## band the width of the cell for a fence span that tiles. Never in the slot's art.
static func _shadow(spec: Dictionary) -> Sprite2D:
	var cell: Vector2i = spec.get("size", Vector2i(T, T))
	var band := String(spec.get("tiling", "none")) != "none"
	var w := cell.x if band else maxi(8, cell.x - 6)
	var h := 3 if band else clampi(cell.x / 4, 4, 9)
	var key := "%dx%dx%s" % [w, h, band]
	if not _shadows.has(key):
		var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
		for y in h:
			for x in w:
				var d := Vector2((x + 0.5 - w * 0.5) / (w * 0.5), (y + 0.5 - h * 0.5) / (h * 0.5)).length()
				if band or d <= 1.0:
					img.set_pixel(x, y, Color.WHITE)
		_shadows[key] = ImageTexture.create_from_image(img)
	var s := Sprite2D.new()
	s.name = "Shadow"
	s.texture = _shadows[key]
	s.centered = false
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.modulate = SHADOW
	var anchor: Vector2i = spec.get("anchor", Vector2i(cell.x / 2, cell.y - 1))
	s.position = Vector2(-anchor.x, -h / 2) if band else Vector2(-w / 2 + 2, -h / 2 - 1)   # 2 px to the right
	s.z_as_relative = false
	s.z_index = 1   # over the ground picture, under every creature and prop
	return s


## A lamp: its lit or unlit still, and when lit the glow round the lantern, stepping between two levels.
static func _lamp(node: Node2D, spec: Dictionary, lit: bool, k: int) -> void:
	var slot := String(spec["id"])
	(node.get_node("Art") as Sprite2D).texture = ArtSlots.frame(slot, "lit" if lit else "unlit")
	if _glow == null:
		var r := GLOW_RADIUS
		var img := Image.create(2 * r + 1, 2 * r + 1, false, Image.FORMAT_RGBA8)
		for y in 2 * r + 1:
			for x in 2 * r + 1:
				var d := Vector2(x - r, y - r).length() / float(r)
				if d < 1.0:
					var c := GLOW_COLOUR
					c.a = floorf((1.0 - d) * 4.0) / 4.0   # four rings, stepped like pixel art
					img.set_pixel(x, y, c)
		_glow = ImageTexture.create_from_image(img)
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	var glow := Sprite2D.new()
	glow.name = "Glow"
	glow.texture = _glow
	glow.material = add
	glow.centered = false   # on whole pixels: the texture is an odd size
	glow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var la: Vector2i = spec.get("light_anchor", Vector2i(12, 8))
	var anchor: Vector2i = spec.get("anchor", Vector2i.ZERO)
	glow.position = Vector2(la - anchor) - Vector2(GLOW_RADIUS, GLOW_RADIUS)
	glow.z_index = 1   # just over the lamp's own glass
	glow.visible = lit
	node.add_child(glow)
	# The wick: hold each level for its time, starting k steps in, round and round while the lamp is in the tree.
	var steps: Array = GLOW_STEPS.slice(k % GLOW_STEPS.size()) + GLOW_STEPS.slice(0, k % GLOW_STEPS.size())
	glow.modulate.a = float(GLOW_LEVELS[int(steps[0][0])])
	if glow.is_inside_tree():
		_flicker(glow, steps)
	else:
		glow.tree_entered.connect(_flicker.bind(glow, steps), CONNECT_ONE_SHOT)


static func _flicker(glow: Sprite2D, steps: Array) -> void:
	var tw := glow.create_tween().set_loops()
	for st: Array in steps:
		var level := float(GLOW_LEVELS[int(st[0])])
		tw.tween_callback(func() -> void: glow.modulate.a = level)
		tw.tween_interval(float(st[1]))
