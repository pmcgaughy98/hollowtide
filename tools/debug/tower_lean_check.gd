extends SceneTree
## The look-up at the Wayline Tower's doors, and Tower Rise's ground around the Tower (Claude, 2026-10-27;
## docs/design/wayline-tower-2026-10-27/TOWER_DESIGN.md section 7, approved with the defaults).
##
## With Highbank v2 on (HT_HIGHBANK_V2=1), on the town itself:
##   The lean: standing in Tower Rise's "lean" box (cols 11 to 14, rows 1 to 4, the door landing) facing north, the
##   camera eases up over 0.4 s toward TowerParts.CAMERA_LEAN (72 px); what shows is capped so the leader's feet stay
##   30 px above the bottom edge, and the view never rises past the area's painted headroom plus the lean (72 + 72 px
##   of the Stack over row 0). Measured from the world's offset (the camera itself), not from hub_town's own number. It
##   does not engage outside the box, facing another way, or in a scene; it eases back when the leader turns; a new
##   area starts level.
##   The Rise (the climb to the new Tower's doors, RISE_CLIMB_SLICE.md slice 1, Claude 2026-10-29): the Stack's foot
##   stands its doors at (288, -42) over row 0's door tiles, the plinth and its two rails under it; row 0 is shut but
##   the doors, the two step faces are shut but the stair in cols 12 and 13, the landing and the terrace are open east
##   of the root; the foot keeps its well, lamps and Job Board; the sky clears the Tower scene's top hold; the two
##   wayline posts stand unstrung (no line hangs on the Rise in slice 1).
##   The waylines elsewhere: each area's lines come in over the edge that faces the Tower (index.gd tower_edge), end
##   on their post's pulley as TownProps drew it, stay inside the area (never above its top), one line per route, each
##   post's state following its route lantern, and the East Quarter's line waits for its flag.
## With v2 off (the default game): at the old Hall's doors, facing north, the camera never moves (today's town).
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/tower_lean_check.gd
##   (run_checks.py tower_lean, with and without HT_HIGHBANK_V2=1)

const TeamState := preload("res://scripts/town/team_state.gd")
const Layout := preload("res://scripts/town/town_layout.gd")
const Areas := preload("res://scripts/world/areas/index.gd")
const TP := preload("res://scripts/town/tower_parts.gd")
const BT := preload("res://scripts/town/building_template.gd")
const VIEW := Vector2(384, 216)
const SETTLE := 15   # frames to wait for the lean to settle (0.4 s is 12 frames at 30 fps)

var town: Node2D
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	fails += 0 if good else 1


func _run() -> void:
	TeamState.start([[0, 0], [1, 0]])
	# The Shortcut Crew met already, so none wait at the board: this check walks Tower Rise for many seconds and leaves
	# it, and a crew member idling mid-step as the area changes trips a freed-node error that is not the camera's.
	TeamState.data["story"] = {"met_crew": true}
	town = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	for k in 6:
		await process_frame
	if Layout.v2():
		await _lean_v2()
		await _rise()
		await _lines()
	else:
		await _lean_v1()
	print("RESULT: %s" % ("the look-up, the Rise and the waylines hold" if fails == 0 else "%d problems" % fails))
	quit(1 if fails else 0)


# ---------------------------------------------------------------------------------------------------------------------
# Measuring the camera

## The view's top row in world px: the world is drawn at _world.position, so its top is the negative of that.
func _top() -> float:
	return -town._world.position.y


## The leader's feet in world px: the bottom row of its standing picture's opaque pixels (the whole picture when the
## image cannot be read headless). The sprite is centred on its node's middle less half its height plus 4 px, so its
## picture ends 4 px below the node (hub_town.gd _place).
func _feet() -> float:
	var e: Dictionary = town.team[0]
	var sprite: Sprite2D = e["sprite"]
	var tex: Texture2D = e["still"][e["facing"]]
	var h := tex.get_size().y
	var img := tex.get_image()
	var bottom := h if img == null or img.is_empty() else float(img.get_used_rect().end.y)
	return e["node"].position.y + sprite.position.y - h * 0.5 + bottom


## The view's top with no lean: the leader 12 px under the middle, held by the area's edges and the painted headroom
## over its top (hub_town.gd headroom()).
func _level_top() -> float:
	var look: float = town.team[0]["node"].position.y - 12.0
	var focus := clampf(look, VIEW.y * 0.5 - town.headroom(), Layout.size().y * Layout.T - VIEW.y * 0.5)
	return roundf(focus - VIEW.y * 0.5)


## Puts the leader on `tile` facing `facing` (partners where they are) and waits `frames` frames.
func _stand(tile: Vector2i, facing: String, frames: int = SETTLE) -> void:
	var e: Dictionary = town.team[0]
	e["pos"] = tile
	e["facing"] = facing
	e["walk_t"] = 0.0
	town._place(e)
	for k in frames:
		await process_frame


## Turns the leader where it stands and counts frames until the camera stops moving (at most 30).
func _turn(facing: String) -> Array:
	town.team[0]["facing"] = facing
	town._place(town.team[0])
	var tops: Array = []
	for k in 30:
		await process_frame
		tops.append(_top())
	return tops


# ---------------------------------------------------------------------------------------------------------------------
# v1: the switch off

func _lean_v1() -> void:
	var hall: Dictionary = BT.place_entry("hall")
	var doors: Array = Layout.door_tiles(hall)
	var moved: Array = []
	var d0: Vector2i = doors[0]
	for dy in range(1, 4):
		for dx in range(-1, 3):
			var t := d0 + Vector2i(dx, dy)
			if not town.open_at(t):
				continue
			await _stand(t, "n")
			if town.cam_lean != 0.0 or absf(_top() - _level_top()) > 0.5:
				moved.append(str(t))
	_ok("v1 (switch off): below the Hall's doors %s facing north the camera stays level at every open tile (moved at %s)" % [str(doors), str(moved)],
		moved.is_empty())


# ---------------------------------------------------------------------------------------------------------------------
# v2: the lean at the Tower's doors

func _lean_v2() -> void:
	await town.enter_area("hall_rise", "lane_walk")
	var box: Dictionary = Layout.area().get("lean", {})
	var head: float = town.headroom()
	var sky_top := -(head + TP.CAMERA_LEAN)   # the highest the leaned view may go: the headroom plus the lean
	_ok("Tower Rise has its lean box %s facing %s on the door landing (design: cols 11 to 14, rows 1 to 4, north), %.0f px of the Stack over row 0"
			% [str(box.get("rect")), str(box.get("facing")), head],
		box.get("rect") == Rect2i(11, 1, 4, 4) and box.get("facing") == ["n"] and head == 72.0)
	# Level first: under the doors facing south. The headroom shows the doors (y -42 to 22) whole.
	await _stand(Vector2i(12, 1), "s")
	var level := _top()
	_ok("at (12,1) facing south: no lean (%.1f px), the view top %.1f where the plain follow puts it (%.1f), the doors' top (y -42) on screen" % [town.cam_lean, level, _level_top()],
		town.cam_lean == 0.0 and absf(level - _level_top()) <= 0.5 and level <= -42.0)
	# Turn north: it eases in over 0.4 s.
	var tops := await _turn("n")
	var full: float = tops[tops.size() - 1]
	var rise := level - full
	var settled := tops.size()
	for k in tops.size():
		if absf(tops[k] - full) <= 0.5:
			settled = k + 1
			break
	var first: float = level - float(tops[0])
	_ok("turning north eases the view up: %.1f px after one frame, settled after %d frames (0.4 s is 12)" % [first, settled],
		first < rise * 0.25 and settled >= 10 and settled <= 13)
	_ok("the lean wants its full %d px (TowerParts.CAMERA_LEAN) once eased in (eased %.2f)" % [TP.CAMERA_LEAN, town._lean_t],
		TP.CAMERA_LEAN == 72 and is_equal_approx(town._lean_t, 1.0))
	var feet_on_screen := _feet() - full
	var capped := absf(feet_on_screen - (VIEW.y - 30.0)) <= 1.0
	_ok("the view rose %.1f px (hub_town says %.1f): stopped %s, the leader's feet %.1f px above the bottom edge (at least 30)"
			% [rise, town.cam_lean, "at 72 px" if absf(rise - 72.0) <= 1.0 else "by the feet rule", VIEW.y - feet_on_screen],
		absf(rise - town.cam_lean) <= 1.0 and rise > 0.0 and (capped or absf(rise - 72.0) <= 1.0) and VIEW.y - feet_on_screen >= 29.0)
	_ok("the leaned view stays inside the Stack's painted headroom: its top %.1f px (at least %.0f), the leader on screen" % [full, sky_top],
		full >= sky_top and feet_on_screen > 0.0 and feet_on_screen < VIEW.y)
	# The place and "Next:" panels (screen rows 6 to 98) slide up with the lean.
	var tucked: float = town.hud_tuck()
	_ok("the place and Next: panels slide up %.0f px with the lean (HUD_TUCK %.0f), the lower one's foot at screen row %.0f" % [tucked, town.HUD_TUCK, 98.0 - tucked],
		tucked == roundf(town.HUD_TUCK * minf(1.0, town.cam_lean / float(TP.CAMERA_LEAN))) and 98.0 - tucked <= 6.0)
	var e0: Dictionary = town.team[0]
	print("  (the view top %.1f -> %.1f at the doors, the %s's feet at y %.1f, its node at %.1f)"
		% [level, full, e0["form"], _feet(), e0["node"].position.y])
	# Releases: turning away eases it back to level.
	tops = await _turn("s")
	var back: float = tops[tops.size() - 1]
	_ok("turning south eases it back: %.1f px still up after one frame, level again (%.1f, was %.1f), the panels home (%.0f px up)" % [float(tops[0]) - full, back, level, town.hud_tuck()],
		float(tops[0]) - full < rise * 0.25 and absf(back - level) <= 0.5 and town.cam_lean == 0.0 and town.hud_tuck() == 0.0)
	# Only in the box, only facing north.
	var wrong: Array = []
	for f in ["e", "w", "s", "ne", "nw", "se", "sw"]:
		await _stand(Vector2i(13, 2), f)
		if town.cam_lean > 0.0:
			wrong.append("(13,2) facing %s: %.1f" % [f, town.cam_lean])
	for t in [Vector2i(10, 2), Vector2i(15, 2), Vector2i(12, 5), Vector2i(10, 4), Vector2i(15, 4)]:
		await _stand(t, "n")
		if town.cam_lean > 0.0 or town.lean_at_rest() > 0.0:
			wrong.append("%s facing n: %.1f (at rest %.1f)" % [str(t), town.cam_lean, town.lean_at_rest()])
	_ok("no lean facing another way, or outside the box facing north (the stair's top step included) %s" % str(wrong), wrong.is_empty())
	wrong = []
	var inside: Array = []
	var low := 1e9
	for t in [Vector2i(11, 2), Vector2i(13, 2), Vector2i(14, 2), Vector2i(11, 4), Vector2i(14, 4), Vector2i(13, 1)]:
		await _stand(t, "s", 2)
		await _stand(t, "n")
		var lean_feet := VIEW.y - (_feet() - _top())
		low = minf(low, lean_feet)
		inside.append("%s %.0f" % [str(t), town.cam_lean])
		if town.cam_lean <= 0.0 or lean_feet < 29.0 or _top() < sky_top:
			wrong.append(str(t))
	_ok("inside the box facing north it leans at every open tile [%s], feet at least %.1f px clear" % [", ".join(inside), low], wrong.is_empty())
	# A walk up step 2's stair onto the landing and into the box: no jump, feet clear and the top inside the headroom
	# on every frame.
	for k in range(1, town.team.size()):
		town.team[k]["pos"] = Vector2i(13, 8 + k)
		town._place(town.team[k])
	await _stand(Vector2i(12, 8), "n")
	var worst_jump := 0.0
	var worst_feet := 1e9
	var worst_top := 1e9
	var last := _top()
	var mid_rest := -1.0   # lean_at_rest() one frame into the last step, the leader still between rows 2 and 1
	for k in 7:
		town.act_move(Vector2i(0, -1))
		for f in 14:
			await process_frame
			if k == 6 and f == 0:
				mid_rest = town.lean_at_rest()
			worst_jump = maxf(worst_jump, absf(_top() - last))
			last = _top()
			worst_feet = minf(worst_feet, VIEW.y - (_feet() - last))
			worst_top = minf(worst_top, last)
	_ok("walking up the stair from (12,8) to %s: the camera moves at most %.1f px a frame, the feet at least %.1f px clear, the top at least %.1f"
			% [str(town.team[0]["pos"]), worst_jump, worst_feet, worst_top],
		town.team[0]["pos"] == Vector2i(12, 1) and worst_jump <= 16.0 and worst_feet >= 29.0 and worst_top >= sky_top and town.cam_lean > 0.0)
	# A scene levels it (the scene steers the camera), and a new area starts level.
	town.cutscene = true
	for k in SETTLE:
		await process_frame
	var in_scene: float = town.cam_lean
	var rest_in_scene: float = town.lean_at_rest()   # what a scene would end its pan on (tower_reveal.gd reads it)
	town.cutscene = false
	for k in SETTLE:
		await process_frame
	var after: float = town.cam_lean
	_ok("lean_at_rest() names the lean before it happens: %.1f mid-step onto (12,1), %.1f during a scene, %.1f once it settles"
			% [mid_rest, rest_in_scene, after],
		after > 0.0 and absf(rest_in_scene - after) <= 0.5 and absf(mid_rest - after) <= 0.5)
	# A scene that steers the camera itself (as the Tower scene does) and hands it back leaned or level: no jump (the
	# ease itself peaks at 1.5 x 72 px over 12 frames, 9 px a frame; a jump would be the whole lean at once).
	var leaned_top := _top()
	var level_top := _level_top()
	var hand := ""
	var smooth := true
	for scene_top in [leaned_top, level_top]:
		town.cutscene = true
		var cam := SceneCam.new()
		cam.town = town
		cam.top = scene_top
		root.add_child(cam)
		for k in SETTLE:
			await process_frame
		town.cutscene = false
		cam.free()
		var worst := 0.0
		var was: float = scene_top
		for k in SETTLE:
			await process_frame
			worst = maxf(worst, absf(_top() - was))
			was = _top()
		hand += "left at %.0f: moves at most %.1f px a frame, settles at %.0f; " % [scene_top, worst, was]
		smooth = smooth and worst <= 10.0 and absf(was - leaned_top) <= 0.5 and (scene_top != leaned_top or worst <= 1.0)
	_ok("a scene that steers the camera hands it back without a jump (%s)" % hand, smooth)
	await town.enter_area("street", "street_north")
	var on_street: float = town.cam_lean
	await process_frame
	_ok("a scene eases it to %.1f, it comes back after (%.1f), and the street starts level (%.1f, then %.1f)" % [in_scene, after, on_street, town.cam_lean],
		in_scene == 0.0 and after > 0.0 and on_street == 0.0 and town.cam_lean == 0.0)


# ---------------------------------------------------------------------------------------------------------------------
# v2: Tower Rise around the Tower

func _rise() -> void:
	await town.enter_area("hall_rise", "lane_walk")
	var a: Dictionary = Layout.area()
	# The template stands the Tower's foot under building_exteriors.gd's node (v2 show_area), or straight in the area:
	# the Stack node it returns, the plinth and rails in its "foot" sibling (tower_foot.gd place()).
	var tower: Node2D = town.area_art.get("hall")
	if tower == null and is_instance_valid(town._building_exteriors):
		tower = town._building_exteriors.buildings.get("hall", {}).get("base")
	if tower == null:
		_ok("the new Tower's foot stands on Tower Rise", false)
		return
	var at: Vector2 = tower.position + (tower.get_parent() as Node2D).position
	var door := Rect2(Rect2i(tower.get_meta("door_px", Rect2i())))
	door.position += at
	var foot: Node2D = tower.get_meta("foot", null)
	var parts: Array = foot.get_children().map(func(n: Node) -> String: return String(n.name)) if foot != null else []
	_ok("the new Tower's foot: the Stack (%s) at %s, its doors at %s over row 0's door tiles, under it %s; no waylines and no beacon (the Tower scene stands its own tower)"
			% [tower.name, str(at), str(door), str(parts)],
		at == Vector2(0, -240) and door == Rect2(288, -42, 48, 64) and tower.has_node("Exterior") and tower.has_node("Door")
		and parts == ["Plinth", "Rail5", "Rail18"] and not tower.has_node("Waylines") and not tower.has_meta("beacon"))
	var size: Vector2i = a["size"]
	var g: PackedByteArray = town.grid
	var wrong: Array = []
	for y in 26:
		for x in size.x:
			var want_open: bool
			if y == 0:
				want_open = x == 12 or x == 13      # the Stack's foot, but its doors
			elif (y >= 5 and y <= 12) or y >= 18:
				want_open = x == 12 or x == 13      # the step faces, but the stair
			else:
				want_open = x >= 5                  # the landing and the terrace, east of the root
			if (g[y * size.x + x] == Layout.OPEN) != want_open:
				wrong.append(str(Vector2i(x, y)))
	_ok("rows 0 to 25: row 0 shut but the doors (12,0) and (13,0); the faces (rows 5 to 12, 18 to 25) shut but the stair in cols 12 and 13; the landing (1 to 4) and the terrace (13 to 17) open but the root in cols 0 to 4 (wrong: %s)"
			% str(wrong), wrong.is_empty())
	var kept := g[27 * size.x + 8] == Layout.WALL and g[28 * size.x + 9] == Layout.WALL and g[26 * size.x + 11] == Layout.WALL \
		and g[26 * size.x + 14] == Layout.WALL and g[26 * size.x + 16] == Layout.WALL and g[27 * size.x + 16] == Layout.OPEN \
		and g[26 * size.x + 0] != Layout.OPEN and g[27 * size.x + 3] != Layout.OPEN \
		and g[29 * size.x + 0] == Layout.OPEN and g[29 * size.x + 11] == Layout.OPEN
	_ok("at the foot the well (8,27), the lamps (11,26) and (14,26) and the Job Board (16,26) stand, its stand (16,27) open; the root's heave (cols 0 to 3, rows 26 and 27) shut, the lane on row 29 open", kept)
	_ok("the sky (%d px) clears the Tower scene's top hold (view top -705); the headroom (%d px) shows the doors' top (y -42)" % [int(a.get("sky", 0)), int(a.get("headroom", 0))],
		int(a.get("sky", 0)) == 720 and int(a.get("headroom", 0)) >= 42)
	var drawn := _posts()
	var on_posts := ""
	var ok_posts := drawn.size() == 2
	for tile: Vector2i in [Vector2i(5, 27), Vector2i(24, 27)]:
		var route := 6 if tile.x < 12 else 0
		var state := String(drawn.get(tile, {}).get("state", ""))
		on_posts += "%s %s (route %d's lantern %s); " % [str(tile), state if state != "" else "missing", route, TP.LANTERN_STATES[route]]
		ok_posts = ok_posts and drawn.has(tile) and state == _post_state(route)
	_ok("the two wayline posts stand at the foot lit as their routes, unstrung (lines on the Rise: %d): %s" % [Areas.waylines("hall_rise").size(), on_posts],
		ok_posts and Areas.waylines("hall_rise").is_empty())
	var street_exit := false
	for e in a["exits"]:
		street_exit = street_exit or (e["to"] == "street" and (e["rect"] as Rect2i) == Rect2i(12, 30, 2, 1))
	_ok("the steps down to the Street leave over the south edge at (12,30) and (13,30)", street_exit)
	var stair: Dictionary = a["paths"][0]
	var stair_size: Vector2i = ArtSlots.spec(String(stair.get("art", ""))).get("size", Vector2i.ZERO)
	_ok("the steps (12,26) to (13,29) name the rise stair's slot %s, its 48 x 96 cell their exact size" % String(stair.get("art", "")),
		stair.get("art", "") == TP.STAIR and (stair["rect"] as Rect2i).position == Vector2i(12, 26) and stair_size == (stair["rect"] as Rect2i).size * Layout.T)


## The wayline posts TownProps drew in the area shown: tile -> {pulley (world px), state}.
func _posts() -> Dictionary:
	var out := {}
	var spec := ArtSlots.spec(TP.POST)
	var off := Vector2(spec["anchors"]["pulley"] - spec["anchor"])
	var shown: Array = Layout.area().get("props", [])
	for n in town._area_parent().find_children("Prop_*", "Node2D", false, false):
		if String(n.get_meta("slot", "")) != TP.POST:
			continue
		var tile: Vector2i = n.get_meta("tile")
		var state := ""
		for p in shown:
			if p["slot"] == TP.POST and p["tile"] == tile:
				state = String(p.get("state", ""))
		out[tile] = {"pulley": n.position + off, "state": state}
	return out


## A scene's own camera, as the Tower scene's TowerCam: after the town's _process it holds the view's top at `top`.
class SceneCam extends Node:
	var town: Node
	var top := 0.0

	func _init() -> void:
		process_priority = 100

	func _process(_delta: float) -> void:
		town._world.position.y = -top


## A post's state for its route's lantern on the deck: lit -> strung, dark -> waiting, quiet -> quiet.
func _post_state(route: int) -> String:
	return {"lit": "strung", "dark": "waiting", "quiet": "quiet"}.get(String(TP.LANTERN_STATES[route]), "")


# ---------------------------------------------------------------------------------------------------------------------
# v2: the waylines in the other areas

func _lines() -> void:
	var edges := {}
	for id in Areas.v2_ids():
		edges[id] = Areas.tower_edge(id)
	_ok("the edge facing the Tower, from the area index: %s" % str(edges),
		edges == {"street": "n", "hall_rise": "", "ferry_ward": "n", "east_quarter": "w", "tree_path": "e"})   # tree_path: Claude, 2026-10-28
	var routes := {}
	for id in ["street", "ferry_ward", "east_quarter"]:
		var a: Dictionary = Areas.area(id)
		var lines: Array = Areas.waylines(id)
		await town.enter_area(id)
		var drawn := _posts()
		var px := Vector2(a["size"] * Layout.T)
		var bad: Array = []
		if lines.size() != a.get("waylines", []).size() or lines.is_empty():
			bad.append("%d lines for %d listed" % [lines.size(), a.get("waylines", []).size()])
		for l in lines:
			var from: Vector2 = l["from"]
			var on_edge: bool = {"n": from.y == 0.0, "s": from.y == px.y, "w": from.x == 0.0, "e": from.x == px.x}[edges[id]]
			var pulley: Vector2 = drawn.get(l["post"], {}).get("pulley", Vector2(-1, -1))
			if not on_edge:
				bad.append("route %d starts at %s, not on the %s edge" % [l["route"], str(from), edges[id]])
			if pulley.distance_to(l["to"]) > 0.5:
				bad.append("route %d ends at %s, its post's pulley is at %s" % [l["route"], str(l["to"]), str(pulley)])
			if String(drawn.get(l["post"], {}).get("state", "")) != _post_state(l["route"]) or l["quiet"] != (_post_state(l["route"]) == "quiet"):
				bad.append("route %d's post is %s, its lantern %s" % [l["route"], drawn.get(l["post"], {}).get("state", "none"), TP.LANTERN_STATES[l["route"]]])
			if routes.has(l["route"]):
				bad.append("route %d also in %s" % [l["route"], routes[l["route"]]])
			routes[l["route"]] = id
			var cable: Line2D = TP.wayline(l["from"], l["to"], l["sag"])
			for p in cable.points:
				if not Rect2(Vector2.ZERO, px).grow(1.0).has_point(p):
					bad.append("route %d leaves the area at %s" % [l["route"], str(p)])
					break
			cable.free()
		var problems := TownProps.problems(a)
		_ok("%s: %d line(s) %s over the %s edge to their posts' pulleys, inside the area, posts clear (%s)"
				% [id, lines.size(), str(lines.map(func(l: Dictionary) -> String: return "route %d %s -> %s" % [l["route"], str(l["from"]), str(l["to"])])),
				edges[id], "; ".join(bad + Array(problems))],
			bad.is_empty() and problems.is_empty())
	var east: Dictionary = Areas.waylines("east_quarter")[0]
	_ok("the East Quarter's line waits for east_quarter_open (shut %s, open with the flag %s)"
			% [str(Layout.exit_open(east, {})), str(Layout.exit_open(east, {"story": {"east_quarter_open": true}}))],
		Layout.open_exits or (not Layout.exit_open(east, {}) and Layout.exit_open(east, {"story": {"east_quarter_open": true}})))
	_ok("Tower Rise has none of these lists' lines (slice 1 hangs none there)", Areas.waylines("hall_rise").is_empty())
