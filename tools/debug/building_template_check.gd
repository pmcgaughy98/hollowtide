extends SceneTree
## The building template and the Wayline Tower (Claude, 2026-10-26, placeholder factory lane B; build plan section 2.2).
## Canvases, doors and anchors per class; the Tower's size, doors and stages; lane B's placeholders (exact size, binary
## alpha, colour budget, clear edges); place() standing a building and a lot on a grid; the sign and shut overlay
## placeholders matching today's code; and v1 still drawn at rect x 24, so the town does not change with v2 off.
##   Godot --headless --path . --script res://tools/debug/building_template_check.gd
const BT := preload("res://scripts/town/building_template.gd")
const BE := preload("res://scripts/town/building_exteriors.gd")
const Layout := preload("res://scripts/town/town_layout.gd")
const T := 24

var problems := 0


func _ok(what: String, good: bool, detail: Variant = "") -> void:
	print("%s%s -> %s" % [what, "" if str(detail) == "" else " (%s)" % str(detail), "ok" if good else "FAIL"])
	problems += 0 if good else 1


func _content(form: String) -> Vector2i:
	var path := "res://assets/sprites/arena/%s/town/s.png" % form
	if not FileAccess.file_exists(path):
		return Vector2i.ZERO
	return Image.load_from_file(ProjectSettings.globalize_path(path)).get_used_rect().size


func _colours(img: Image) -> int:
	var seen := {}
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a > 0.0:
				seen[c.to_rgba32()] = true
	return seen.size()


func _touches(img: Image, allowed: Array) -> String:
	var w := img.get_width()
	var h := img.get_height()
	for side in ["top", "bottom", "left", "right"]:
		if allowed.has(side):
			continue
		for i in (w if side in ["top", "bottom"] else h):
			var at := Vector2i(i, 0 if side == "top" else h - 1) if side in ["top", "bottom"] else Vector2i(0 if side == "left" else w - 1, i)
			if img.get_pixelv(at).a > 0.0:
				return side
	return ""


func _initialize() -> void:
	# 1. Classes: the table, at 1.0, door on its tiles, sill on the step, anchor bottom centre.
	for cls in BT.CLASSES:
		var c: Dictionary = BT.CLASSES[cls]
		var g := BT.geometry(cls, 1.0)
		var size: Vector2i = g["canvas"]
		var door: Rect2i = g["door_px"]
		var base: Vector2i = c["base"]
		_ok("%s: geometry at 1.0 is the class table" % cls, size == c["canvas"] and door == c["door_px"], "%s %s" % [str(size), str(door)])
		_ok("%s: canvas %s is the base %s plus eaves wide" % [cls, str(size), str(base)], size.x == base.x * T + 2 * BT.EAVE)
		_ok("%s: anchor %s is the canvas's bottom centre" % [cls, str(g["anchor"])], g["anchor"] == Vector2i(size.x / 2, size.y - 1))
		if door.size.x > 0:
			var tiles := int(c["door_tiles"])
			var mid := BT.EAVE + int(c["door_col"]) * T + tiles * T / 2
			_ok("%s: door %s centred over its %d door tile(s), sill 2 px above the foot row" % [cls, str(door), tiles],
				door.get_center().x == mid and door.end.y == size.y - 2 and Rect2i(Vector2i.ZERO, size).encloses(door))
			var form := String(c["pass_creature"])
			var body := _content(form)
			_ok("%s: door %dx%d clears its pass creature %s (%dx%d)" % [cls, door.size.x, door.size.y, form, body.x, body.y],
				body != Vector2i.ZERO and door.size.y >= body.y and door.size.x >= 0.75 * body.x)
		var big := BT.geometry(cls, 1.25)
		_ok("%s: at 1.25 the canvas grows on the same base" % cls, big["canvas"].x == size.x and big["canvas"].y > size.y and big["door_px"].size.y >= door.size.y)
		_ok("%s: canvas() and door_px() follow BUILDING_SCALE %.2f" % [cls, BT.BUILDING_SCALE], BT.canvas(cls) == BT.geometry(cls)["canvas"] and BT.door_px(cls) == BT.geometry(cls)["door_px"])

	# 2. The Wayline Tower: the Hall's base and doors, at least 2.5 screens tall, a beacon at the top.
	var hall: Dictionary = BT.CLASSES[BT.TOWER_CLASS]
	_ok("Tower: canvas %s, %.2f screens of the 216 px view (at least 540 px)" % [str(BT.TOWER_CANVAS), BT.TOWER_CANVAS.y / 216.0], BT.TOWER_CANVAS.y >= 540 and BT.TOWER_CANVAS == hall["canvas"])
	_ok("Tower: the Hall's 12 x 3 base and its double door over base columns 5 and 6", hall["base"] == Vector2i(12, 3) and BT.TOWER_DOOR == hall["door_px"]
		and BT.TOWER_DOOR.position.x == BT.EAVE + 5 * T and BT.TOWER_DOOR.size.x == 2 * T and BT.TOWER_DOOR_COLS == [5, 6])
	var spec := ArtSlots.spec(BT.TOWER_SLOT)
	_ok("Tower: its slot %s is the tower canvas, door and beacon" % BT.TOWER_SLOT, spec.get("size") == BT.TOWER_CANVAS and spec.get("door_px") == BT.TOWER_DOOR
		and spec.get("anchor") == BT.TOWER_FOOT and spec.get("anchors", {}).get("beacon") == BT.TOWER_TOP and String(spec.get("building_class", "")) == BT.TOWER_CLASS)
	var order := ["mast", "cap", "lantern", "gallery", "shaft", "base"]
	var stacked := true
	for i in order.size():
		var r: Rect2i = BT.TOWER_STAGES[order[i]]
		stacked = stacked and Rect2i(Vector2i.ZERO, BT.TOWER_CANVAS).encloses(r)
		if i > 0:
			stacked = stacked and r.position.y >= BT.TOWER_STAGES[order[i - 1]].position.y
	_ok("Tower: stages mast, cap, lantern, gallery, shaft, base inside the canvas, top to bottom", stacked)
	var tower := PlaceholderPainter.paint(BT.TOWER_SLOT, spec)
	var used := tower.get_used_rect()
	var beacon := tower.get_pixelv(BT.TOWER_TOP)
	_ok("Tower placeholder rises the full canvas (opaque from row %d)" % used.position.y, used.position.y <= 10 and used.end.y == BT.TOWER_CANVAS.y)
	_ok("Tower placeholder: the signal light burns at TOWER_TOP %s" % str(BT.TOWER_TOP), beacon.a > 0.0 and beacon.r > 0.85 and beacon.g > 0.6 and beacon.b < 0.6, beacon.to_html(false))
	var lan: Rect2i = BT.TOWER_STAGES["lantern"]
	var lantern_px := 0
	for y in range(lan.position.y, lan.end.y):
		for x in range(lan.position.x, lan.end.x):
			var c := tower.get_pixel(x, y)
			if c.r > 0.85 and c.g > 0.6 and c.b < 0.5:
				lantern_px += 1
	_ok("Tower placeholder: the lantern room is lit (%d of %d px)" % [lantern_px, lan.get_area()], lantern_px * 2 > lan.get_area())
	var d := BT.TOWER_DOOR.grow(-3)
	var dark := tower.get_pixelv(d.get_center())
	_ok("Tower placeholder: the doorway is dark where the leaves go", dark.get_luminance() < 0.3, dark.to_html(false))
	var pts := BT.tower_points(Rect2i(19, 4, 12, 3))
	_ok("tower_points: door %s up to the beacon %s is %d px (a pan of %.2f screens)" % [str(pts["door"]), str(pts["top"]), int(pts["door"].y - pts["top"].y), (pts["door"].y - pts["top"].y) / 216.0],
		pts["door"].y - pts["top"].y >= 500 and pts["origin"] == Vector2i(19 * T - BT.EAVE, 7 * T - BT.TOWER_CANVAS.y) and pts["top"].x == pts["door"].x)
	var tall := BT.template_image("hall", "hall", 1.25)
	_ok("Tower at 1.25 is %dx%d with its beacon still inside the canvas" % [tall.get_width(), tall.get_height()], tall.get_size() == BT.geometry("hall", 1.25)["canvas"] and tall.get_used_rect().position.y > 0)

	# 3. Lane B's placeholders: exact sheet, binary alpha, colour budget, clear of forbidden edges (C1, C3, C4, C2).
	var lane_b := 0
	for id in ArtSlots.ids():
		var s := ArtSlots.spec(id)
		if String(s.get("lane", "")) != "B" or String(s.get("status", "")) == "keep":
			continue
		lane_b += 1
		var img := PlaceholderPainter.paint(id, s)
		var budget := int(s["palette"].get("max", 0))
		var touch := _touches(img, PlaceholderPainter.allowed_sides(s["edges"]))
		_ok("%s placeholder %s, %d colours of %d, edges clear" % [id, str(img.get_size()), _colours(img), budget],
			img.get_size() == s["sheet_size"] and img.detect_alpha() != Image.ALPHA_BLEND and (budget == 0 or _colours(img) <= budget) and touch == "", touch)
		var hook := String(s.get("placeholder", ""))
		_ok("%s paints with its own hook, not the shared kind painter" % id, hook != "" and img.get_data() != PlaceholderPainter.by_kind(id, s).get_data(), hook)
	_ok("lane B has 16 new slots", lane_b == 16, lane_b)

	# 4. The sign and shut overlay placeholders are today's code.
	_ok("shut_chain placeholder is today's chain", ArtSlots.image("town.prop.shut_chain").get_data() == BE._chain_image().get_data())
	_ok("shut_rope placeholder is today's rope", ArtSlots.image("town.prop.shut_rope").get_data() == BE.rope_image().get_data())
	for pair in [["shop", "town.prop.sign_shop", Vector2i(31, -6), Vector2i(19, 16)], ["storage", "town.prop.sign_storage", Vector2i(31, -6), Vector2i(19, 17)],
			["hall", "town.prop.sign_hall", Vector2i(34, -25), Vector2i(19, 19)], ["scrolls", "town.prop.sign_scrolls", Vector2i(-25, 1), Vector2i(19, 17)]]:
		var place: Dictionary = BT.place_entry(pair[0])
		var r: Rect2i = place["rect"]
		var entrance: Vector2i = place["door"]
		for tile in Layout.door_tiles(place):
			entrance.x = mini(entrance.x, tile.x)
		var local_d: Vector2i = (entrance - r.position) * T
		var v1 := BE._details(r.size * T, local_d, pair[0], Layout.door_tiles(place).size() * T)
		var offset: Vector2i = pair[2]
		if pair[0] == "hall":
			offset = Vector2i(Layout.door_tiles(place).size() * T + 10, -25)   # _details: entrance width + 10
		var board := Rect2i(local_d + offset, pair[3])
		var slot := ArtSlots.image(pair[1])
		_ok("%s: the sign slot's board is the v1 board, pixel for pixel" % pair[1], slot.get_region(Rect2i(Vector2i(2, 1), pair[3])).get_data() == v1.get_region(board).get_data())

	# 5. place(): the Tower and a lot on a grid, as v2 stands them.
	var holder := Node2D.new()
	root.add_child(holder)
	var b := {"id": "hall", "class": "hall", "base": Rect2i(7, 6, 12, 3), "door": [Vector2i(12, 8), Vector2i(13, 8)]}
	var node: Node2D = BT.place(b, holder)
	var ext: Sprite2D = node.get_node_or_null("Exterior") if node != null else null
	var leaves: Sprite2D = node.get_node_or_null("Door") if node != null else null
	var frames: Array = node.get_meta("frames", []) if node != null else []
	_ok("place(): the Tower stands at its canvas origin, sorted at its door row", node != null and node.position == Vector2(7 * T - BT.EAVE, 9 * T - BT.TOWER_CANVAS.y) and node.z_index == 8 * T, str(node.position) if node != null else "null")
	_ok("place(): its picture is the slot (%s), its sign the waymark slot" % ArtSlots.source(BT.TOWER_SLOT), ext != null and ext.texture.get_size() == Vector2(BT.TOWER_CANVAS)
		and node.get_node_or_null("Sign") != null and node.get_node("Sign").texture == ArtSlots.texture("town.prop.sign_hall"))
	var cover := []
	for f in frames:
		var fi: Image = f.get_image()
		var n := 0
		var inside := BT.TOWER_DOOR.size - Vector2i(4, 2)
		for y in range(2, BT.TOWER_DOOR.size.y):
			for x in range(2, BT.TOWER_DOOR.size.x - 2):
				n += 1 if fi.get_pixel(x, y).a > 0.0 else 0
		cover.append(snappedf(float(n) / float(inside.x * inside.y), 0.01))
	_ok("place(): three door frames from door_px, closed to open (cover %s)" % str(cover), leaves != null and frames.size() == 3 and leaves.position == Vector2(BT.TOWER_DOOR.position)
		and cover[0] > 0.95 and cover[1] < 0.6 and cover[2] < 0.15)
	var lot: Node2D = BT.place({"id": "lot_a", "class": "stall", "base": Rect2i(36, 5, 4, 2), "before": "tarp", "opens": {"beaten": "first"}}, holder)
	_ok("place(): a lot before it opens shows its tarp slot", lot != null and String(lot.get_meta("slot", "")) == "town.building.lot_before_stall" and lot.get_node("Exterior").texture.get_size() == Vector2(108, 120))
	var plot: Node2D = BT.place({"id": "lot_b", "class": "stall", "base": Rect2i(30, 3, 6, 4), "before": "plot", "opens": {"flag": "x"}}, holder)
	_ok("place(): a plot lot lies flat at its base", plot != null and plot.position == Vector2(30 * T, 3 * T) and plot.z_index == 0)
	holder.free()

	# 6. v1 is unchanged: every place resolves to its PLACES row, every building drawn at rect x 24.
	if not Layout.v2():
		var same := true
		for p in Layout.PLACES:
			same = same and is_same(BT.place_entry(p["id"]), p)
		_ok("v1: place_entry() is each PLACES row itself", same)
		var town := Node2D.new()
		var host := GDScript.new()   # the town's one field building_exteriors reads each frame
		host.source_code = "extends Node2D\nvar panel := {}\n"
		host.reload()
		town.set_script(host)
		root.add_child(town)
		var view = BE.attach(town, town)
		await process_frame
		var at_rect := true
		var names: PackedStringArray = []
		for id in ["home", "shop", "storage", "scrolls", "hall"]:
			var place: Dictionary = BT.place_entry(id)
			var r: Rect2i = place["rect"]
			var built: Dictionary = view.buildings.get(id, {})
			var sprite: Sprite2D = built.get("sprite")
			var good: bool = sprite != null and built["base"].position == Vector2(r.position * T) and sprite.texture.get_size() == Vector2(r.size * T)
			at_rect = at_rect and good
			names.append("%s %s" % [id, "ok" if good else "WRONG"])
		_ok("v1: buildings drawn from their PNGs at rect x 24", at_rect, ", ".join(names))
		_ok("v1: open-air places drawn (%d)" % view.buildings.size(), view.buildings.size() == 13)
		town.free()
	else:
		print("v1 checks skipped: Highbank v2 is on")
	print("RESULT: %s" % ("the template, the Tower and v1 hold" if problems == 0 else "%d problems" % problems))
	quit()
