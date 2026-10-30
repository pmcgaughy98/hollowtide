extends SceneTree
## The building template and the Wayline Tower (Claude, 2026-10-26, placeholder factory lane B; build plan section 2.2;
## the tower rebuilt in parts 2026-10-27, docs/design/wayline-tower-2026-10-27/TOWER_DESIGN.md). Canvases, doors and
## anchors per class; the hall's depot and the tower standing on it (TowerParts' order, the assembled height, the lamp
## lit on the door axis); lane B's placeholders (exact size, binary alpha, colour budget, clear edges); place()
## standing the hall and a lot on a grid (the whole tower when Highbank v2 is on, the depot alone when it is off); the
## sign and shut overlay placeholders matching today's code; and v1 still drawn at rect x 24, so the town does not change
## with v2 off. tools/debug/tower_parts_check.gd checks the parts themselves.
##   Godot --headless --path . --script res://tools/debug/building_template_check.gd
const BT := preload("res://scripts/town/building_template.gd")
const TP := preload("res://scripts/town/tower_parts.gd")
const BE := preload("res://scripts/town/building_exteriors.gd")
const Layout := preload("res://scripts/town/town_layout.gd")
const T := 24
## The tower's body, drawn in this order (TOWER_DESIGN.md section 5), the route lanterns hung at their place.
const BODY := ["town.building.hall", "town.building.hall.drum", "town.building.hall.hoist", "town.building.hall.galleries",
	"town.building.hall.root_vein", "town.building.hall.chute", "town.building.hall.gable", "town.building.hall.reel_back",
	"town.building.hall.reach", "town.building.hall.ring_front", "town.building.hall.route_lantern", "town.building.hall.bell",
	"town.building.hall.lamp", "town.building.hall.vane"]

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


## How much of a door frame the leaves cover, inside the jambs and above the sill: drawn pixels that are not the dark
## doorway behind them (the template's frames leave the doorway clear, the tower's paint it TowerParts' doorway brown).
func _cover(frame: Texture2D, size: Vector2i) -> float:
	var fi: Image = frame.get_image()
	var dark := TP.TIMB.dk.to_rgba32()
	var n := 0
	var all := 0
	for y in range(2, size.y - 2):
		for x in range(2, size.x - 2):
			all += 1
			var c := fi.get_pixel(x, y)
			n += 1 if c.a > 0.0 and c.to_rgba32() != dark else 0
	return snappedf(float(n) / float(maxi(1, all)), 0.01)


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
			if c.has("eave"):
				# Roof first (TOWN_SYNTHESIS.md, measured from Explorers of Sky's town): the roof at least 60% of the
				# height, the door at most about a quarter, the front tall enough for the door and its lintel.
				var roof_share := 1.0 - float(int(c["eave"])) / float(size.y)
				var door_share := float(door.size.y) / float(size.y)
				_ok("%s: roof first, %d%% of the height over a %d px front; the door %d%% of the height" % [cls, roundi(roof_share * 100.0), int(c["eave"]), roundi(door_share * 100.0)],
					roof_share >= 0.6 and door_share <= 0.26 and int(c["eave"]) >= door.size.y + 8)
		var big := BT.geometry(cls, 1.25)
		_ok("%s: at 1.25 the canvas grows on the same base" % cls, big["canvas"].x == size.x and big["canvas"].y > size.y and big["door_px"].size.y >= door.size.y)
		_ok("%s: canvas() and door_px() follow BUILDING_SCALE %.2f" % [cls, BT.BUILDING_SCALE], BT.canvas(cls) == BT.geometry(cls)["canvas"] and BT.door_px(cls) == BT.geometry(cls)["door_px"])

	# 2. The Wayline Tower: the hall class is its depot (the Hall's base and doors, 300 x 192); the tower stands on it.
	var hall: Dictionary = BT.CLASSES[BT.TOWER_CLASS]
	_ok("Tower depot: hall canvas %s is TOWER_DEPOT 300 x 192" % str(hall["canvas"]), hall["canvas"] == Vector2i(300, 192) and BT.TOWER_DEPOT == hall["canvas"] and BT.canvas("hall") == BT.TOWER_DEPOT)
	_ok("Tower depot: the Hall's 12 x 3 base and its double door %s over base columns 5 and 6" % str(BT.TOWER_DOOR), hall["base"] == Vector2i(12, 3)
		and BT.TOWER_DOOR == hall["door_px"] and BT.TOWER_DOOR == Rect2i(126, 126, 48, 64) and BT.TOWER_DOOR.position.x == BT.EAVE + 5 * T
		and BT.TOWER_DOOR.size.x == 2 * T and BT.TOWER_DOOR_COLS == [5, 6] and BT.door_px("hall") == BT.TOWER_DOOR)
	var spec := ArtSlots.spec(BT.TOWER_SLOT)
	var anchors: Dictionary = spec.get("anchors", {})
	_ok("Tower depot: its slot %s is the depot canvas, door and foot, at frame %s" % [BT.TOWER_SLOT, str(spec.get("frame_at"))],
		spec.get("size") == BT.TOWER_DEPOT and spec.get("door_px") == BT.TOWER_DOOR and spec.get("anchor") == BT.TOWER_FOOT
		and String(spec.get("building_class", "")) == BT.TOWER_CLASS and spec.get("frame_at") == BT.TOWER_DEPOT_AT
		and String(spec.get("placeholder", "")) == TP.PLACEHOLDER_HOOK)
	_ok("Tower depot: its beacon and apex anchors %s %s are the frame's, in the depot's px" % [str(anchors.get("beacon")), str(anchors.get("apex"))],
		anchors.get("beacon") == BT.TOWER_BEACON - BT.TOWER_DEPOT_AT and anchors.get("apex") == BT.TOWER_APEX - BT.TOWER_DEPOT_AT)
	_ok("Tower: the depot's door lands on the frame's door %s" % str(TP.DOOR), Rect2i(BT.TOWER_DEPOT_AT + BT.TOWER_DOOR.position, BT.TOWER_DOOR.size) == TP.DOOR
		and TP.DEPOT_DOOR == BT.TOWER_DOOR and BT.TOWER_PARTS == TP.PARTS and BT.TOWER_FRAME == Vector2i(432, 720))
	var orders: Array = []
	for p in TP.PARTS:
		orders.append(int(p["order"]))
	var sorted := orders.duplicate()
	sorted.sort()
	_ok("TowerParts: %d parts in order 1 to %d, the body drawn %s" % [TP.PARTS.size(), orders.size(), "as the design lists it" if Array(TP.body_order()) == BODY else "OUT OF ORDER"],
		orders == sorted and orders == range(1, TP.PARTS.size() + 1) and Array(TP.body_order()) == BODY and TP.ids("ground").size() == 2 and TP.ids("prop").size() == 6)
	var whole := TP.assembled_image()
	var used := whole.get_used_rect()
	_ok("TowerParts: assembled %s, standing %d px tall (at least 540) from row %d to the foot row" % [str(whole.get_size()), used.size.y, used.position.y],
		whole.get_size() == BT.TOWER_FRAME and used.size.y >= 540 and used.position.y <= 2 and used.end.y == BT.TOWER_FRAME.y)
	var lit := 0
	for y in range(BT.TOWER_BEACON.y - 4, BT.TOWER_BEACON.y + 5):
		for x in range(BT.TOWER_BEACON.x - 4, BT.TOWER_BEACON.x + 5):
			var c := whole.get_pixel(x, y)
			lit += 1 if c.a > 0.0 and c.r > 0.85 and c.g > 0.6 and c.b < 0.6 else 0
	_ok("TowerParts: the Waiting Lamp burns round the beacon %s (%d of 81 px lit)" % [str(BT.TOWER_BEACON), lit], lit > 40)
	_ok("TowerParts: the beacon is on the door axis", BT.TOWER_BEACON.x == TP.DOOR.get_center().x)
	var pts := BT.tower_points(Rect2i(7, 6, 12, 3))
	_ok("tower_points on Tower Rise: origin %s, door %s up to the beacon %s is %d px (a pan of %.2f screens)" % [str(pts["origin"]), str(pts["door"]), str(pts["top"]), int(pts["door"].y - pts["top"].y), (pts["door"].y - pts["top"].y) / 216.0],
		pts["origin"] == Vector2i(96, -504) and pts["door"] == Vector2(312, 182) and pts["top"] == Vector2(312, -386) and pts["apex"] == Vector2(279, -503)
		and pts["depot_origin"] == Vector2i(162, 24) and pts["canvas"] == BT.TOWER_FRAME)
	var tall := BT.template_image("hall", "hall", 1.25)
	_ok("Tower depot at 1.25 is %dx%d, a stretched stand-in" % [tall.get_width(), tall.get_height()], tall.get_size() == BT.geometry("hall", 1.25)["canvas"] and tall.get_used_rect().size.y > 0)

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
		if pair[0] == "hall" and String(place.get("tower", "")) == "foot":
			for p in Layout.Areas.V1.AREA["places"]:   # Tower Rise's hall is the Stack's one-row foot (2026-10-29): v1's board
				if p["id"] == "hall":
					place = p
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

	# 5. place(): the hall and a lot on a grid, as v2 stands them (the whole tower) or, off v2, the depot alone.
	var holder := Node2D.new()
	root.add_child(holder)
	var b := {"id": "hall", "class": "hall", "base": Rect2i(7, 6, 12, 3), "door": [Vector2i(12, 8), Vector2i(13, 8)]}
	var node: Node2D = BT.place(b, holder)
	var ext: Sprite2D = node.get_node_or_null("Exterior") if node != null else null
	var leaves: Sprite2D = node.get_node_or_null("Door") if node != null else null
	var frames: Array = node.get_meta("frames", []) if node != null else []
	var door_px: Rect2i = node.get_meta("door_px", Rect2i()) if node != null else Rect2i()
	if Layout.v2():
		_ok("place() v2: the hall is the whole tower, its frame at %s, sorted at its door row" % (str(node.position) if node != null else "null"),
			node != null and node.position == Vector2(96, -504) and node.z_index == 8 * T and node.get_node_or_null("Reach") != null
			and node.get_node_or_null("Lamp") != null and (node.get_node_or_null("RouteLanterns") as Node) != null and node.get_node("RouteLanterns").get_child_count() == 7)
		_ok("place() v2: its depot is the slot (%s) at the frame's depot place, no Sign or Details" % ArtSlots.source(BT.TOWER_SLOT), ext != null
			and ext.position == Vector2(BT.TOWER_DEPOT_AT) and ext.texture.get_size() == Vector2(BT.TOWER_DEPOT)
			and node.get_node_or_null("Sign") == null and node.get_node_or_null("Details") == null)
		_ok("place() v2: door_px %s in the tower's px puts the doors at world %s" % [str(door_px), str(node.position + Vector2(door_px.position)) if node != null else "?"],
			node != null and door_px == TP.DOOR and node.position + Vector2(door_px.position) == Vector2(288, 150) and leaves != null and leaves.position == Vector2(TP.DOOR.position))
	else:
		_ok("place() v1 call: the depot stands at its canvas origin, sorted at its door row", node != null and node.position == Vector2(7 * T - BT.EAVE, 9 * T - BT.TOWER_DEPOT.y) and node.z_index == 8 * T, str(node.position) if node != null else "null")
		_ok("place() v1 call: its picture is the depot slot (%s), its sign the waymark slot" % ArtSlots.source(BT.TOWER_SLOT), ext != null and ext.texture.get_size() == Vector2(BT.TOWER_DEPOT)
			and node.get_node_or_null("Sign") != null and node.get_node("Sign").texture == ArtSlots.texture("town.prop.sign_hall") and door_px == BT.TOWER_DOOR)
	var cover := []
	for f in frames:
		cover.append(_cover(f, door_px.size))
	_ok("place(): three door frames, closed to open (cover %s)" % str(cover), leaves != null and frames.size() == 3 and cover[0] > 0.95 and cover[1] < 0.6 and cover[2] < 0.15)
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
	quit(1 if problems else 0)
