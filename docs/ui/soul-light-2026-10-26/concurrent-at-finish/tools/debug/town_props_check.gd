extends SceneTree
## Lane C's check (Claude, 2026-10-26, placeholder factory build plan sections 2.3 and 5): the street's lamp and props
## and the ground painter that takes any area.
##   1. Every lamp and prop slot in scripts/art/slots/town_street.gd resolves: its coded placeholder
##      (street_props.gd) comes back at exactly the sheet size, binary alpha, its lowest row on the foot row (C7), within
##      its colour budget, and the loader serves a texture of that size. The six ground rows still serve today's files.
##   2. Lamps have both states, lit and unlit: the same silhouette, a different light.
##   3. In every area (today's map, lane A's areas when they exist, and a one-screen lineup of all twelve slots) every
##      prop resolves and nothing sits on a door's approach, an exit, an anchor, another prop or a building; and the
##      rule is live: a lineup with a prop on a doorstep and one inside a building is refused.
##   4. TownProps.build places each prop with its anchor on its foot, a ground shadow under it, a glow on a lit lamp;
##      set_lit turns them off; today's map gets no props at all.
##   5. HighbankPainter.paint_area: today's map comes out pixel for pixel as hub_town.gd paints it, and its finish mask
##      as hub_town.gd makes it; every other area paints at its size, fully opaque, with today's view put back after;
##      paint time per screen stays within 10% of today's (build plan 2.3), measured here.
##   Godot --headless --fixed-fps 30 --path . --script res://tools/debug/town_props_check.gd

const Layout := preload("res://scripts/town/town_layout.gd")
const HP := preload("res://scripts/town/highbank_painter.gd")
const WF := preload("res://scripts/town/world_finish.gd")
const Tiles := preload("res://scripts/town/world_tile_art.gd")
const STREET := "res://scripts/art/slots/town_street.gd"
const PROPS := "res://scripts/art/placeholders/street_props.gd"
const INDEX := "res://scripts/world/areas/index.gd"
const T := 24
const SCREEN := 384.0 * 216.0
const PAINT_MARGIN := 1.10   # build plan 2.3: an area's paint time per screen at most 10% over today's

var fails := 0


func _ok(what: String, good: bool, offenders: Array = []) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1
		for o in offenders.slice(0, 12):
			print("    %s" % str(o))
		if offenders.size() > 12:
			print("    ... and %d more" % (offenders.size() - 12))


## A one-screen lineup of every street slot, for this check only (not a map): a hedge, grass, a lane, a cliff with
## steps, terrace and water; a small building with its door on the lane, the Job Board's spot, an exit the barrier shuts.
static func lineup() -> Dictionary:
	return {"id": "props_lineup", "name": "Props lineup", "kind": "exterior", "size": Vector2i(16, 9),
		"ground": {"base": "grass", "bands": [{"from": 0, "to": 0, "kind": "hedge"}, {"from": 6, "to": 6, "kind": "cliff"},
			{"from": 7, "to": 7, "kind": "terrace"}, {"from": 8, "to": 8, "kind": "water"}]},
		"paths": [{"rect": Rect2i(0, 3, 16, 1), "kind": "lane"}, {"rect": Rect2i(13, 4, 1, 4), "kind": "steps"}],
		"buildings": [{"id": "lineup_home", "name": "Lineup", "service": "home", "class": "cottage", "base": Rect2i(1, 1, 3, 2), "door": [Vector2i(2, 2)]}],
		"places": [{"id": "board", "name": "Job Board", "kind": "spot", "rect": Rect2i(6, 1, 2, 1), "door": Vector2i(6, 2), "service": "jobs"}],
		"props": [
			{"slot": "town.lamp.post", "tile": Vector2i(4, 2), "solid": true, "light": true},
			{"slot": "town.lamp.post", "tile": Vector2i(9, 2), "solid": true, "light": false},
			{"slot": "town.prop.well", "tile": Vector2i(10, 1), "solid": true},
			{"slot": "town.prop.bench", "tile": Vector2i(1, 4), "solid": true},
			{"slot": "town.prop.crates", "tile": Vector2i(4, 4), "solid": true},
			{"slot": "town.prop.barrel", "tile": Vector2i(5, 4), "solid": true},
			{"slot": "town.prop.planter", "tile": Vector2i(6, 4), "solid": true},
			{"slot": "town.prop.fence_h", "tile": Vector2i(7, 4), "solid": true},
			{"slot": "town.prop.fence_h", "tile": Vector2i(8, 4), "solid": true},
			{"slot": "town.prop.fence_corner", "tile": Vector2i(9, 4), "solid": true},
			{"slot": "town.prop.fence_v", "tile": Vector2i(9, 5), "solid": true},
			{"slot": "town.prop.fence_corner", "tile": Vector2i(10, 5), "solid": true, "flip_h": true},
			{"slot": "town.prop.waymark", "tile": Vector2i(11, 4), "solid": true},
			{"slot": "town.prop.road_barrier", "tile": Vector2i(15, 1), "solid": true, "shut_exit": "east"},
			{"slot": "town.prop.mooring_post", "tile": Vector2i(14, 7), "solid": true}],
		"exits": [{"id": "east", "rect": Rect2i(15, 1, 1, 2), "to": "nowhere", "at": "west"}],
		"anchors": {"spawn": Vector2i(3, 4)}}


func _initialize() -> void:
	var t0 := Time.get_ticks_msec()
	# 1. The street's slots.
	var rows: Dictionary = (load(STREET) as Script).get_script_constant_map().get("SLOTS", {})
	var street: Array = []
	var ground: Array = []
	for id in rows:
		if String(rows[id]["kind"]) in ["prop", "lamp"]:
			street.append(id)
		elif String(rows[id]["kind"]) == "ground":
			ground.append(id)
	street.sort()
	var bad_slot: Array = []
	var painter: Script = load(PROPS)
	for id: String in street:
		var s := ArtSlots.spec(id)
		var sheet: Vector2i = s["sheet_size"]
		var cell: Vector2i = s["size"]
		var hook := String(s.get("placeholder", ""))
		if not hook.begins_with(PROPS + ":"):
			bad_slot.append("%s placeholder %s is not street_props.gd's" % [id, hook])
			continue
		var img: Image = painter.call(hook.get_slice(":", 2), id, s)
		if img == null or img.get_size() != sheet:
			bad_slot.append("%s hook painted %s, sheet %s" % [id, img.get_size() if img else "nothing", sheet])
			continue
		if img.detect_alpha() == Image.ALPHA_BLEND:
			bad_slot.append("%s placeholder has partial alpha" % id)
		var colours := {}
		for cy in range(0, sheet.y, cell.y):
			var low := -1
			for y in cell.y:
				for x in sheet.x:
					var c := img.get_pixel(x, cy + y)
					if c.a > 0.0:
						low = y
						colours[c.to_rgba32()] = true
			if low != int(s["anchor"].y):
				bad_slot.append("%s cell row %d: lowest opaque row %d, foot row %d (C7)" % [id, cy / cell.y, low, s["anchor"].y])
		if colours.size() > int(s["palette"]["max"]):
			bad_slot.append("%s %d colours, budget %d" % [id, colours.size(), s["palette"]["max"]])
		var tex := ArtSlots.texture(id)
		if Vector2i(tex.get_size()) != sheet or not ArtSlots.source(id) in ["placeholder", "file"]:
			bad_slot.append("%s resolves to %s from %s" % [id, tex.get_size(), ArtSlots.source(id)])
	_ok("street slots: %d lamp and prop slots resolve to their coded placeholders (exact sheet, binary alpha, foot row, budget)" % street.size(), bad_slot.is_empty() and street.size() == 12, bad_slot)
	var bad_ground: Array = []
	for id: String in ground:
		if ArtSlots.source(id) != ("placeholder" if ArtSlots.forcing() else "legacy") or Vector2i(ArtSlots.texture(id).get_size()) != ArtSlots.sheet_size(id):
			bad_ground.append("%s from %s" % [id, ArtSlots.source(id)])
	_ok("ground: %d keep rows serve today's files at their size (world_tile_art.gd reads them as before)" % ground.size(), bad_ground.is_empty() and ground.size() == 6, bad_ground)

	# 2. Lamps: both states.
	var bad_lamp: Array = []
	for id: String in street:
		var s := ArtSlots.spec(id)
		if String(s["kind"]) != "lamp":
			continue
		var states: Dictionary = s["states"]
		if not (states.has("lit") and states.has("unlit")):
			bad_lamp.append("%s states %s" % [id, states.keys()])
			continue
		var lit := ArtSlots.frame(id, "lit").get_image()
		var unlit := ArtSlots.frame(id, "unlit").get_image()
		var la: Vector2i = s.get("light_anchor", Vector2i(-1, -1))
		if lit.get_size() != s["size"] or unlit.get_size() != s["size"] or not Rect2i(Vector2i.ZERO, s["size"]).has_point(la):
			bad_lamp.append("%s frames %s %s, light anchor %s" % [id, lit.get_size(), unlit.get_size(), la])
			continue
		var same_shape := true
		for y in lit.get_height():
			for x in lit.get_width():
				if (lit.get_pixel(x, y).a > 0.0) != (unlit.get_pixel(x, y).a > 0.0):
					same_shape = false
		if not same_shape or lit.get_data() == unlit.get_data() or lit.get_pixelv(la) == unlit.get_pixelv(la):
			bad_lamp.append("%s: lit and unlit must share a silhouette and differ at the light anchor" % id)
	_ok("lamps have both states (lit and unlit: one silhouette, a different light at the anchor)", bad_lamp.is_empty(), bad_lamp)

	# 3. Every area's props stand clear, and the rule is live.
	var areas: Array = [Layout.area()]
	if ResourceLoader.exists(INDEX):
		var index: Script = load(INDEX)
		if index.has_method("v2_ids") and index.has_method("area"):
			for id in index.call("v2_ids"):
				var a: Dictionary = index.call("area", String(id))
				if not a.is_empty():
					areas.append(a)
	areas.append(lineup())
	var bad_area: Array = []
	var prop_count := 0
	for a: Dictionary in areas:
		bad_area.append_array(Array(TownProps.problems(a)))
		prop_count += (a.get("props", []) as Array).size()
	_ok("props stand clear in %s (%d props): registered, on the area, off every door, exit, anchor, building and other prop" % [", ".join(areas.map(func(a: Dictionary) -> String: return String(a["id"]))), prop_count], bad_area.is_empty(), bad_area)
	var wrong := lineup()
	wrong["props"] = (wrong["props"] as Array) + [{"slot": "town.prop.crates", "tile": Vector2i(2, 3)}, {"slot": "town.prop.barrel", "tile": Vector2i(1, 1)}]
	var caught := TownProps.problems(wrong)
	var on_step := Array(caught).any(func(p: String) -> bool: return p.contains("in front of the door"))
	var inside := Array(caught).any(func(p: String) -> bool: return p.contains("inside the building"))
	_ok("the rule is live: a crate on a doorstep and a barrel inside a building are refused (%d lines)" % caught.size(), on_step and inside and caught.size() == 2, Array(caught))

	# 4. build(): anchors on feet, shadows, the lamp's glow, set_lit.
	var holder := Node2D.new()
	root.add_child(holder)
	var bad_build: Array = []
	for a: Dictionary in areas:
		var nodes := TownProps.build(a, holder)
		var props: Array = a.get("props", [])
		if nodes.size() != props.size():
			bad_build.append("%s: %d nodes for %d props" % [a["id"], nodes.size(), props.size()])
			continue
		for i in nodes.size():
			var n: Node2D = nodes[i]
			var p: Dictionary = props[i]
			var s := ArtSlots.spec(String(p["slot"]))
			var art: Sprite2D = n.get_node_or_null("Art")
			var foot := TownProps.foot_px(p)
			if art == null or art.texture == null or Vector2i(art.texture.get_size()) != s["size"]:
				bad_build.append("%s %s: art %s" % [a["id"], n.name, art.texture.get_size() if art and art.texture else "missing"])
				continue
			# The anchor pixel lands on the foot: the bottom of the footprint, centred.
			var anchor_at := n.position + art.position + Vector2(s["anchor"])
			if bool(p.get("flip_h", false)):
				anchor_at.x = n.position.x + art.position.x + float(s["size"].x - 1 - s["anchor"].x)
			if Vector2i(n.position) != foot or Vector2i(anchor_at) != foot or foot.y != (p["tile"].y + TownProps.footprint(p).y) * T - 1:
				bad_build.append("%s %s: anchor at %s, foot %s" % [a["id"], n.name, anchor_at, foot])
			if n.get_node_or_null("Shadow") == null:
				bad_build.append("%s %s: no ground shadow" % [a["id"], n.name])
			var glow: Node = n.get_node_or_null("Glow")
			if String(s["kind"]) == "lamp" and bool(p.get("light", false)) != (glow != null and glow.visible):
				bad_build.append("%s %s: light %s, glow %s" % [a["id"], n.name, p.get("light", false), glow != null and glow.visible])
		var lamps := nodes.filter(func(n: Node) -> bool: return String(n.get_meta("slot", "")) == "town.lamp.post")
		TownProps.set_lit(lamps, false)
		for n: Node2D in lamps:
			var glow: Node = n.get_node_or_null("Glow")
			if (glow != null and glow.visible) or (n.get_node("Art") as Sprite2D).texture.get_image().get_data() != ArtSlots.frame("town.lamp.post", "unlit").get_image().get_data():
				bad_build.append("%s %s: set_lit(false) left it lit" % [a["id"], n.name])
	var today := TownProps.build(Layout.area(), holder)
	_ok("build() puts every prop's anchor on its foot with a ground shadow, lit lamps glow, set_lit darkens them", bad_build.is_empty(), bad_build)
	_ok("today's map gets no props and no solid prop tiles (v2 off: the town as it is)", today.is_empty() and TownProps.solid_tiles(Layout.area()).is_empty())
	holder.free()

	# 5. paint_area: today's map unchanged; any area at its size; time per screen.
	var hub: Script = load("res://scripts/town/hub_town.gd")
	var t := Time.get_ticks_usec()
	var v1: Image = HP.paint_area(Layout.area())
	var v1_ms := (Time.get_ticks_usec() - t) / 1000.0
	var v1_screen := v1_ms / (v1.get_width() * v1.get_height() / SCREEN)
	var today_img: Image = hub.call("paint")
	_ok("paint_area(today's map) is hub_town.gd's street, pixel for pixel (%dx%d, %.0f ms, %.0f ms a screen)" % [v1.get_width(), v1.get_height(), v1_ms, v1_screen],
		v1.get_size() == today_img.get_size() and v1.get_data() == today_img.get_data())
	var m1: Image = WF.street_mask(Layout.area())
	var m0: Image = hub.call("_finish_mask")
	_ok("street_mask(today's map) is hub_town.gd's finish mask", m1.get_size() == m0.get_size() and m1.get_data() == m0.get_data())
	var bad_paint: Array = []
	var worst := 0.0
	var worst_id := ""
	var lines: Array = []
	for a: Dictionary in areas.slice(1):
		t = Time.get_ticks_usec()
		var img: Image = HP.paint_area(a)
		var ms := (Time.get_ticks_usec() - t) / 1000.0
		var want: Vector2i = a["size"] * T
		var per := ms / (want.x * want.y / SCREEN)
		# The timing rule is for real areas; the one-screen lineup is a fixture (judged only when no area exists yet).
		if (a["id"] != "props_lineup" or areas.size() == 2) and per > worst:
			worst = per
			worst_id = String(a["id"])
		lines.append("%s %.0f ms a screen" % [a["id"], per])
		if img.get_size() != want or img.detect_alpha() != Image.ALPHA_NONE:
			bad_paint.append("%s painted %s (want %s), alpha %d" % [a["id"], img.get_size(), want, img.detect_alpha()])
		if WF.street_mask(a).get_size() != want:
			bad_paint.append("%s finish mask is not %s" % [a["id"], want])
		if Tiles.view != Layout.V1_AREA:
			bad_paint.append("%s left the painters on view '%s', not today's map" % [a["id"], Tiles.view])
	_ok("every other area paints at its size, fully opaque, with today's map put back after (%s)" % ", ".join(lines), bad_paint.is_empty(), bad_paint)
	_ok("paint time per screen within 10%% of today's: the slowest area, %s, %.0f ms against today's %.0f ms" % [worst_id, worst, v1_screen], worst <= v1_screen * PAINT_MARGIN)
	print("town_props_check took %d ms" % (Time.get_ticks_msec() - t0))
	print("RESULT: %s" % ("the street's props resolve and the ground paints any area" if fails == 0 else "%d checks did not hold" % fails))
	quit(1 if fails else 0)
