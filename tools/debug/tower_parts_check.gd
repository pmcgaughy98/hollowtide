extends SceneTree
## The Wayline Tower's parts (Claude, 2026-10-27, docs/design/wayline-tower-2026-10-27/TOWER_DESIGN.md sections 5 to
## 10). Every part's rect inside the 432 x 720 frame; a complete slot row for every part (size, frame place, hook,
## locked wayline_tower palette, owner by batch, a brief with no em-dash); every blockout at its sheet size, binary
## alpha, at most its budget of colours and only the family's colours; the assembled tower drawn in order (where parts
## overlap, the upper part owns the pixel); the 2 px rule at the silhouette (no 1 px hairline sticking out); the far
## tower at the asked heights, one connected shape, with the lamp lit under the hook; and the placed tower on Tower
## Rise, its door at world (288, 150), its life nodes, waylines, long shadow and lanterns. Since the 2026-10-27 look
## pass also: the Climb is one unbroken root, the lamp's pan no wider than its glass and its panes with a bright core,
## the glow stepped and added behind the lamp, the waylines' brass-light top, the wings' contact shadows on the ground,
## and the middle-distance tower (small()) at its asked height in the family's colours.
##   Godot --headless --fixed-fps 30 --path . --script res://tools/debug/tower_parts_check.gd
##   ... -- --render docs/design/wayline-tower-2026-10-27/build   also writes assembled_blockout.png, far_70.png and
##   far_170.png (and parts_sheet.png, every part's whole sheet) into that folder.
const TP := preload("res://scripts/town/tower_parts.gd")
const GROK := ["town.building.hall.route_lantern", "town.prop.hall.wayline_post", "town.prop.hall.basket", "town.prop.hall.cradle", "town.prop.hall.parcel"]
const PLACED := ["Exterior", "Door", "Drum", "Hoist", "HoistRope", "Basket", "Galleries", "RootVein", "Chute", "ChuteParcel", "Gable",
	"RoutePegs", "ReelBack", "Reach", "RingFront", "RouteLanterns", "Bell", "Lamp", "Glow", "Vane", "RootFoot", "Yard", "Waylines", "LongShadow",
	"RootFootShadow", "YardShadow"]

var problems := 0


func _ok(what: String, good: bool, detail: Variant = "") -> void:
	print("%s%s -> %s" % [what, "" if str(detail) == "" else " (%s)" % str(detail), "ok" if good else "FAIL"])
	problems += 0 if good else 1


func _colours(img: Image) -> Dictionary:
	var seen := {}
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a > 0.0:
				seen["#" + c.to_html(false)] = true
	return seen


## Opaque pixels that make a 1 px hairline at the silhouette: runs of 2 or more pixels that are each 1 px thick across
## the run (clear on both sides), and diagonal steps of single pixels clear on all four sides.
func _hairlines(img: Image) -> Array:
	var w := img.get_width()
	var h := img.get_height()
	var solid := func(x: int, y: int) -> bool: return x >= 0 and y >= 0 and x < w and y < h and img.get_pixel(x, y).a > 0.0
	var thin_x := {}   # clear left and right: one pixel wide
	var thin_y := {}   # clear above and below: one pixel tall
	for y in h:
		for x in w:
			if not solid.call(x, y):
				continue
			if not solid.call(x - 1, y) and not solid.call(x + 1, y):
				thin_x[Vector2i(x, y)] = true
			if not solid.call(x, y - 1) and not solid.call(x, y + 1):
				thin_y[Vector2i(x, y)] = true
	var out: Array = []
	for p: Vector2i in thin_x:
		if thin_x.has(p + Vector2i(0, 1)) and not thin_x.has(p - Vector2i(0, 1)):
			out.append("vertical hairline from %s" % str(p))
	for p: Vector2i in thin_y:
		if thin_y.has(p + Vector2i(1, 0)) and not thin_y.has(p - Vector2i(1, 0)):
			out.append("horizontal hairline from %s" % str(p))
	for p: Vector2i in thin_x:
		if thin_y.has(p) and (thin_x.has(p + Vector2i(1, 1)) and thin_y.has(p + Vector2i(1, 1)) or thin_x.has(p + Vector2i(-1, 1)) and thin_y.has(p + Vector2i(-1, 1))):
			out.append("diagonal hairline at %s" % str(p))
	return out


## How many separate shapes the opaque pixels make (8-connected).
func _shapes(img: Image) -> int:
	var w := img.get_width()
	var h := img.get_height()
	var seen := {}
	var n := 0
	for y in h:
		for x in w:
			var p := Vector2i(x, y)
			if seen.has(p) or img.get_pixelv(p).a <= 0.0:
				continue
			n += 1
			var stack: Array[Vector2i] = [p]
			seen[p] = true
			while not stack.is_empty():
				var q: Vector2i = stack.pop_back()
				for dy in [-1, 0, 1]:
					for dx in [-1, 0, 1]:
						var r := q + Vector2i(dx, dy)
						if r.x < 0 or r.y < 0 or r.x >= w or r.y >= h or seen.has(r) or img.get_pixelv(r).a <= 0.0:
							continue
						seen[r] = true
						stack.append(r)
	return n


func _lit(c: Color) -> bool:
	return c.a > 0.0 and c.r > 0.85 and c.g > 0.6 and c.b < 0.65


func _initialize() -> void:
	var t0 := Time.get_ticks_msec()
	var frame := Rect2i(Vector2i.ZERO, TP.FRAME)
	var family := {}
	for hex in TP.PALETTE:
		family["#" + Color(hex).to_html(false)] = true

	# 1. The table: every body and ground part inside the frame, props at their own size, orders 1 to 21.
	var outside: Array = []
	for p in TP.PARTS:
		var r: Rect2i = p["rect"]
		if String(p["layer"]) != "prop" and not frame.encloses(r):
			outside.append("%s %s" % [p["name"], str(r)])
		if String(p["layer"]) == "prop" and r.position != Vector2i.ZERO:
			outside.append("prop %s at %s" % [p["name"], str(r.position)])
	_ok("parts: %d (%d body, %d ground, %d props), every body and ground rect inside the %s frame" % [TP.PARTS.size(), TP.ids("body").size(), TP.ids("ground").size(), TP.ids("prop").size(), str(TP.FRAME)],
		outside.is_empty() and TP.PARTS.size() == 21 and TP.ids("body").size() == 13 and TP.ids("ground").size() == 2, outside)
	_ok("anchors: the beacon %s on the door axis, the apex %s on the top row, the door %s on the foot row" % [str(TP.BEACON), str(TP.APEX), str(TP.DOOR)],
		TP.BEACON.x == TP.DOOR.get_center().x and TP.APEX.y <= 1 and TP.DOOR.end.y == TP.FOOT_ROW - 1 and TP.DOOR == Rect2i(TP.DEPOT_AT + TP.DEPOT_DOOR.position, TP.DEPOT_DOOR.size))

	# 2. Slot rows: one per part and the key, complete and matching the table.
	var bad_rows: Array = []
	var rows := 0
	for id in Array(TP.ids()) + [TP.KEY]:
		var s := ArtSlots.spec(id)
		if s.is_empty():
			bad_rows.append("%s has no slot row" % id)
			continue
		rows += 1
		var p := TP.part(id)
		var want_size: Vector2i = (p["rect"] as Rect2i).size if not p.is_empty() else Vector2i(TP.FRAME.x / 2, TP.FRAME.y / 2)
		var pal: Dictionary = s.get("palette", {})
		var brief := String(s.get("brief", ""))
		var owner := "grok" if GROK.has(id) else "codex"
		var why: Array = []
		if s.get("size") != want_size:
			why.append("size %s, part %s" % [str(s.get("size")), str(want_size)])
		if not p.is_empty() and String(p["layer"]) != "prop" and s.get("frame_at") != (p["rect"] as Rect2i).position:
			why.append("frame_at %s, part at %s" % [str(s.get("frame_at")), str((p["rect"] as Rect2i).position)])
		if String(s.get("placeholder", "")) != TP.PLACEHOLDER_HOOK:
			why.append("hook %s" % s.get("placeholder", ""))
		if String(pal.get("family", "")) != "wayline_tower" or not bool(pal.get("lock", false)) or int(pal.get("max", 0)) > (41 if id == TP.KEY else 32):
			why.append("palette %s" % str(pal))
		if String(s.get("owner", "")) != owner:
			why.append("owner %s, batch list says %s" % [s.get("owner"), owner])
		if brief.length() < 60 or brief.contains(String.chr(0x2014)) or brief.contains(String.chr(0x2013)) or brief.to_lower().contains("mystery" + " dungeon"):
			why.append("brief (%d chars) empty or with a dash Preston bans" % brief.length())
		if String(s.get("census", "")) == "" or String(s.get("lane", "")) != ("B" if id == TP.DEPOT else "T"):
			why.append("census %s lane %s" % [s.get("census", ""), s.get("lane", "")])
		if not why.is_empty():
			bad_rows.append("%s: %s" % [id, "; ".join(why)])
	_ok("slot rows: %d of %d (21 parts and the key), complete, locked to wayline_tower, owners by batch" % [rows, TP.PARTS.size() + 1], bad_rows.is_empty() and rows == TP.PARTS.size() + 1, bad_rows)

	# 3. Every blockout: its sheet size, binary alpha, its budget, the family's colours only, not empty.
	var bad_ph: Array = []
	var counts: Array = []
	for id in Array(TP.ids()) + [TP.KEY]:
		var s := ArtSlots.spec(id)
		if s.is_empty():
			continue
		var img := PlaceholderPainter.paint(id, s)
		var cols := _colours(img)
		var stray := cols.keys().filter(func(c: String) -> bool: return not family.has(c))
		var budget := int(s["palette"].get("max", 32))
		var allowed := PlaceholderPainter.allowed_sides(s["edges"])
		var size: Vector2i = s["size"]
		for cy in range(0, img.get_height(), size.y):
			for cx in range(0, img.get_width(), size.x):
				var cell := img.get_region(Rect2i(cx, cy, size.x, size.y))
				for side in ["top", "bottom", "left", "right"]:
					if allowed.has(side):
						continue
					var strip := Rect2i(0, 0 if side == "top" else size.y - 1, size.x, 1) if side in ["top", "bottom"] else Rect2i(0 if side == "left" else size.x - 1, 0, 1, size.y)
					if not cell.get_region(strip).is_invisible():
						bad_ph.append("%s: the cell at %d, %d touches its %s edge" % [id, cx, cy, side])
		counts.append("%s %d" % [String(id).get_slice(".", String(id).get_slice_count(".") - 1), cols.size()])
		if img.get_size() != s["sheet_size"] or img.detect_alpha() == Image.ALPHA_BLEND or cols.size() > budget or not stray.is_empty() or img.get_used_rect().size == Vector2i.ZERO:
			bad_ph.append("%s: %s of %s, %d colours of %d, off-family %s" % [id, str(img.get_size()), str(s["sheet_size"]), cols.size(), budget, str(stray.slice(0, 4))])
		if id != TP.KEY and img.get_data() != TP.paint_slot(id, s).get_data():
			bad_ph.append("%s: the slot does not draw TowerParts' blockout" % id)
	_ok("blockouts: exact sheets, binary alpha, clear of forbidden edges, within budget, family colours only (%s)" % ", ".join(counts), bad_ph.is_empty(), bad_ph)

	# 4. The assembled tower: in draw order, the upper part owns every pixel where parts overlap.
	var whole := TP.assembled_image()
	var used := whole.get_used_rect()
	var body: Array = []
	var cells := {}
	for p in TP.PARTS:
		if String(p["layer"]) != "prop":
			body.append(p)
			cells[String(p["id"])] = TP.paint_part(String(p["id"]))
	var hung: Array[Rect2i] = []   # the route lanterns and lit pegs hang over the body; their pixels are theirs
	for i in TP.LANTERN_T.size():
		hung.append(Rect2i(TP.lantern_at(i), Vector2i(12, 20)))
	for k in TP.PEGS_LIT:
		var peg: Vector2 = TP.route_pegs()[int(k)]
		hung.append(Rect2i(Vector2i(peg.round()) - Vector2i(2, 2), Vector2i(5, 5)))
	var wrong := 0
	var shared := 0
	var first := ""
	for i in body.size():
		var lower: Dictionary = body[i]
		for j in range(i + 1, body.size()):
			var upper: Dictionary = body[j]
			var cut := (lower["rect"] as Rect2i).intersection(upper["rect"])
			if cut.size.x <= 0 or cut.size.y <= 0:
				continue
			var up_img: Image = cells[String(upper["id"])]
			var up_at: Vector2i = (upper["rect"] as Rect2i).position
			for y in range(cut.position.y, cut.end.y):
				for x in range(cut.position.x, cut.end.x):
					var u := up_img.get_pixel(x - up_at.x, y - up_at.y)
					if u.a <= 0.0 or hung.any(func(r: Rect2i) -> bool: return r.has_point(Vector2i(x, y))):
						continue
					shared += 1
					var top_owner := upper
					for k in range(j + 1, body.size()):
						var r: Rect2i = body[k]["rect"]
						if r.has_point(Vector2i(x, y)) and (cells[String(body[k]["id"])] as Image).get_pixel(x - r.position.x, y - r.position.y).a > 0.0:
							top_owner = body[k]
					if top_owner == upper and whole.get_pixel(x, y) != u:
						wrong += 1
						if first == "":
							first = "%s over %s at %d, %d" % [upper["name"], lower["name"], x, y]
	_ok("assembled %s, %d px tall: where parts overlap the upper part owns the pixel (%d overlap px)" % [str(whole.get_size()), used.size.y, shared], whole.get_size() == TP.FRAME and used.size.y >= 540 and wrong == 0, first)

	# 5. The 2 px rule at the silhouette.
	var hair := _hairlines(whole)
	_ok("silhouette: no 1 px hairline sticks out (%d found)" % hair.size(), hair.is_empty(), hair.slice(0, 8))

	# 6. The far tower: the asked height, one shape, the lamp lit under the hook.
	for h in [70, 170]:
		var far := TP.paint_far(h, 0.35)
		var fp := TP.far_points(h)
		var hook: Vector2i = fp["hook"]
		var under := Color(0, 0, 0, 0)   # the first lit pixel below the hook's end, within the chain's length
		for dy in range(1, ceili(3.0 * h / 72.0) + 2):
			for dx in [0, -1, 1, -2, 2]:
				if under.a <= 0.0 and _lit(far.get_pixel(hook.x + dx, hook.y + dy)):
					under = far.get_pixel(hook.x + dx, hook.y + dy)
		var lamp_lit := 0
		var lr: Rect2i = fp["lamp_rect"]
		for y in range(lr.position.y, lr.end.y):
			for x in range(lr.position.x, lr.end.x):
				lamp_lit += 1 if _lit(far.get_pixel(x, y)) else 0
		var shapes := _shapes(far)
		_ok("far %d: %s, %d shape(s), apex %s, lamp lit %d px under the hook %s" % [h, str(far.get_size()), shapes, str(fp["apex"]), lamp_lit, str(hook)],
			far.get_height() == h and far.get_size() == fp["size"] and shapes == 1 and lamp_lit >= 2 and _lit(under) and far.get_used_rect().position.y <= 1
			and far.get_used_rect().end.y == h, under.to_html(false))

	# 7. The placed tower on Tower Rise.
	var holder := Node2D.new()
	root.add_child(holder)
	var tower := TP.place(holder, TP.RISE_ORIGIN, {"shadow_drop": 96})
	var missing := PLACED.filter(func(n: String) -> bool: return tower.get_node_or_null(n) == null)
	var door_world := tower.position + Vector2(TP.DOOR.position)
	_ok("place(): WaylineTower at %s, z %d, its door at world %s" % [str(tower.position), tower.z_index, str(door_world)],
		tower.name == "WaylineTower" and door_world == Vector2(288, 150) and tower.z_index == TP.DOOR_ROW_Z and tower.get_meta("door_px") == TP.DOOR
		and tower.position + Vector2(TP.BEACON) == Vector2(312, -386) and (tower.get_meta("frames") as Array).size() == 3)
	_ok("place(): every part, door and life node is there", missing.is_empty(), missing)
	var lan: Node = tower.get_node_or_null("RouteLanterns")
	var states: Array = []
	if lan != null:
		for c in lan.get_children():
			states.append(String(c.get_meta("state", "?")))
	_ok("place(): seven route lanterns, %s" % str(states), states == TP.LANTERN_STATES)
	var lines: Node = tower.get_node_or_null("Waylines")
	var strung := 0
	var cradles := 0
	var slack := 0
	if lines != null:
		for c in lines.get_children():
			if c is Line2D:
				strung += 1
				slack += 1 if bool(c.get_meta("quiet", false)) else 0
			elif String(c.name).begins_with("Cradle"):
				cradles += 1
	_ok("place(): %d waylines hung over everything (z %d), %d slack for the quiet route, %d cradles riding" % [strung, lines.z_index if lines != null else -1, slack, cradles],
		strung == TP.RISE_LINES.size() and lines.z_index == TP.WAYLINE_Z and not lines.z_as_relative and slack == 1 and cradles == strung - slack)
	var line: Line2D = lines.get_child(0) if lines != null else null
	var tags := 0
	if line != null:
		for c in line.get_children():
			tags += 1 if c is Polygon2D else 0
	_ok("wayline(): 1 px ink, a lit top, teal tags every 40 px (%d)" % tags, line != null and is_equal_approx(line.width, 1.0) and line.default_color == TP.INK
		and line.get_node_or_null("Lit") != null and tags >= 1)
	var shadow: Sprite2D = tower.get_node_or_null("LongShadow")
	var shade := shadow.texture.get_image() if shadow != null else null
	var dark := Color()
	if shade != null:
		for y in shade.get_height():
			for x in shade.get_width():
				if shade.get_pixel(x, y).a > 0.0:
					dark = shade.get_pixel(x, y)
					break
			if dark.a > 0.0:
				break
	_ok("long shadow: %s on the ground (z %d), about 24 %% black" % [str(shade.get_size()) if shade != null else "none", shadow.z_index if shadow != null else -1],
		shadow != null and shadow.z_index == TP.SHADOW_Z and shade.get_height() == 97 and absf(dark.a - 62.0 / 255.0) < 0.01 and shadow.position == Vector2(0, TP.FOOT_ROW))
	# The look pass's fixes, measured on the placed tower and the painted cells.
	var lamp: Node = tower.get_node_or_null("Lamp")
	var glow: Sprite2D = tower.get_node_or_null("Glow")
	var gimg := glow.texture.get_image() if glow != null else null
	var peak := 0.0
	var steps := {}
	if gimg != null:
		for y in gimg.get_height():
			for x in gimg.get_width():
				var a := gimg.get_pixel(x, y).a
				peak = maxf(peak, a)
				if a > 0.0:
					steps[snappedf(a, 0.01)] = true
	var added: bool = glow != null and glow.material is CanvasItemMaterial and (glow.material as CanvasItemMaterial).blend_mode == CanvasItemMaterial.BLEND_MODE_ADD
	_ok("the lamp's glow: %d steps, strongest %.2f, added, just behind the lamp (glow %d, lamp %d)" % [steps.size(), peak,
		glow.get_index() if glow != null else -1, lamp.get_index() if lamp != null else -1],
		glow != null and lamp != null and steps.size() == 3 and absf(peak - 0.35) < 0.01 and added and glow.get_index() == lamp.get_index() - 1)
	var lit_line: Line2D = (lines.get_child(0) as Node).get_node_or_null("Lit") if lines != null else null
	_ok("waylines: the lit top is brass-light (%s)" % (lit_line.default_color.to_html(false) if lit_line != null else "none"),
		lit_line != null and lit_line.default_color == TP.BRASS.hi)
	var wings: Array = []
	for n in ["RootFootShadow", "YardShadow"]:
		var sh: Sprite2D = tower.get_node_or_null(n)
		var wing: Rect2i = TP.part("town.building.hall." + ("root_foot" if n == "RootFootShadow" else "yard"))["rect"]
		var box := Rect2(sh.position, sh.texture.get_size()) if sh != null else Rect2()
		# On the ground under the wing: absolute z SHADOW_Z, past the foot row, inside the wing's width.
		var good: bool = (sh != null and not sh.z_as_relative and sh.z_index == TP.SHADOW_Z and box.end.y > TP.FOOT_ROW + 2
			and box.position.y < TP.FOOT_ROW and box.position.x >= wing.position.x - 4 and box.end.x <= wing.end.x + 4)
		wings.append("%s %s %s" % [n, str(box), "ok" if good else "bad"])
		if not good:
			wings.append("FAIL")
	_ok("contact shadows under the ground wings: %s" % ", ".join(wings), not wings.has("FAIL"))
	var still := TP.place(holder, Vector2.ZERO, {"life": false, "lines": []})
	_ok("place() with life off: nothing moves, no waylines", still.get_node_or_null("Smoke0") == null and still.get_node("Waylines").get_child_count() == 0)
	TP.set_lantern(tower, 5, "lit")
	TP.set_pegs(tower, [0, 7])
	_ok("set_lantern() and set_pegs() change a placed tower", String(tower.get_node("RouteLanterns/Lantern5").get_meta("state")) == "lit"
		and tower.get_node("RoutePegs").get_child_count() == 2)
	holder.free()

	# 7b. The painted cells the look pass asked to change.
	# The Climb: from the root foot to the galleries every row holds root bark, so it is one root (it used to stop at
	# the depot's roof deck and the drum's top and start again, which read as three logs).
	var vein := TP.paint_part("town.building.hall.root_vein")
	var vr: Rect2i = TP.part("town.building.hall.root_vein")["rect"]
	var bark := [TP.ROOTC.hi, TP.ROOTC.lit, TP.ROOTC.mid, TP.ROOTC.sh]
	var gaps: Array = []
	for fy in range(340, 604):
		var has := false
		for fx in range(vr.position.x, vr.end.x):
			if vein.get_pixel(fx - vr.position.x, fy - vr.position.y) in bark:
				has = true
				break
		if not has:
			gaps.append(fy)
	_ok("the Climb is one root: bark on every row from 340 to 603 (%d rows without)" % gaps.size(), gaps.is_empty(), gaps.slice(0, 6))
	# The lamp: its pan no wider than the glass (23 px), and each lit pane with a near-white core.
	var lamp_img := TP.paint_part(TP.LAMP, "lit", 0)
	var lr: Rect2i = TP.part(TP.LAMP)["rect"]
	var glass_w := 0
	var pan_w := 0
	for y in lamp_img.get_height():
		var n := 0
		for x in lamp_img.get_width():
			n += 1 if lamp_img.get_pixel(x, y).a > 0.0 else 0
		if y + lr.position.y >= 110 and y + lr.position.y <= 126:
			glass_w = maxi(glass_w, n)
		elif y + lr.position.y >= 127:
			pan_w = maxi(pan_w, n)
	var cores := 0
	for x0 in [206, 217]:
		cores += 1 if lamp_img.get_pixel(x0 + 3 - lr.position.x, 114 - lr.position.y) == TP.STONE.hi else 0
	_ok("the Waiting Lamp: the pan %d px under %d px of glass, %d panes with a bright core" % [pan_w, glass_w, cores],
		pan_w > 0 and pan_w <= glass_w and cores == 2)
	# The middle-distance tower (the road's vista): exactly as tall as asked, the frame's width to scale, family colours.
	var mid_img := TP.small(176)
	var stray_mid := _colours(mid_img).keys().filter(func(h: String) -> bool: return not h in TP.PALETTE)
	_ok("small(176): %s, %d colours, all the family's" % [str(mid_img.get_size()), _colours(mid_img).size()],
		mid_img.get_size() == Vector2i(106, 176) and stray_mid.is_empty() and mid_img.get_used_rect().size.y >= 170, stray_mid.slice(0, 4))

	# 8. The renders for the design folder, when asked.
	var args := OS.get_cmdline_user_args()
	var at := args.find("--render")
	if at >= 0 and at + 1 < args.size():
		var dir := String(args[at + 1])
		var out_dir := ProjectSettings.globalize_path(dir if dir.begins_with("res://") else "res://" + dir)
		DirAccess.make_dir_recursive_absolute(out_dir)
		whole.save_png(out_dir.path_join("assembled_blockout.png"))
		TP.paint_far(70, 0.35).save_png(out_dir.path_join("far_70.png"))
		TP.paint_far(170, 0.2).save_png(out_dir.path_join("far_170.png"))
		var sheets: Array[Image] = []
		var w := 0
		var hgt := 0
		for id in TP.ids():
			var img := PlaceholderPainter.paint(id, ArtSlots.spec(id))
			sheets.append(img)
			w += img.get_width() + 8
			hgt = maxi(hgt, img.get_height())
		var sheet := Image.create(w, hgt, false, Image.FORMAT_RGBA8)
		sheet.fill(Color("#24302f"))
		var x := 0
		for img in sheets:
			sheet.blend_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i(x, 0))
			x += img.get_width() + 8
		sheet.save_png(out_dir.path_join("parts_sheet.png"))
		print("rendered assembled_blockout.png, far_70.png, far_170.png and parts_sheet.png into %s" % out_dir)
	print("tower_parts_check took %d ms" % (Time.get_ticks_msec() - t0))
	print("RESULT: %s" % ("the tower's parts hold" if problems == 0 else "%d problems" % problems))
	quit(1 if problems else 0)
