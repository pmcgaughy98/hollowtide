extends SceneTree
## The hub town blockout (Claude, 2026-10-09): the layout holds together (no place overlaps another,
## every door is on open ground and reachable from Home, the switchbacks connect the bluff to the
## ferry), the team walks and follows, every place answers E, and the Mouth of the Hollow starts a run.
## Each of those is a verdict line (Claude, 2026-10-24, H03).
##   Godot --path . --fixed-fps 30 --script res://tools/debug/hub_town_check.gd
## The layout picture (and the Hall panel still, with a window) go to the runner's logs folder (HT_CHECK_LOGS),
## or user:// on a direct run. `-- --update-doc` writes them to docs/world/hub-layout-2026-10-09/ instead, so a
## suite run leaves the tracked docs alone (Claude, 2026-10-24, H03; pilot_chain_check.gd's pattern).
## Pass 8 (Claude, 2026-10-26, street lane): a team of four at rest, on every arrival, after a scene and at the Hall's
## and Home's doors, never shares a tile and never stands in a footprint (T1); at rest it keeps off the row along a
## building's foot too. Also the street's sign layout in the talk box's type (T4), the run line's place name and use
## key (T2, T8), the Menu chip under an open panel (T9), the board's lost items (T7), the objective's new lines (T3)
## and the kept door player (T11).

const Layout := preload("res://scripts/town/town_layout.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const Jobs := preload("res://scripts/town/jobs.gd")
const FOUR := [[0, 0], [1, 0], [10, 0], [2, 0]]
const DOC := "res://docs/world/hub-layout-2026-10-09/"
## The ferry landing the switchbacks lead down to, (28,27) in today's map: the anchor "ferry_landing" (lane A, Claude,
## 2026-10-26). Every tile this check stands on is an anchor of the town's areas (scripts/world/areas/), so it runs
## with Highbank v2 off and on (HT_HIGHBANK_V2=1): in v2 the walk follows the exits from Home's area.
const FERRY := "ferry_landing"
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


## Where the pictures go: the tracked docs only when asked, else the runner's logs folder.
func _out_dir() -> String:
	if OS.get_cmdline_user_args().has("--update-doc"):
		return DOC
	var log_dir := OS.get_environment("HT_CHECK_LOGS")
	return log_dir if log_dir != "" else "user://"


func _run() -> void:
	var out := _out_dir()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	# Overlaps, and every door reachable from Home: area by area (today's map is one), the walk going through the
	# areas' exits (lane A, 2026-10-26).
	var reach := _reach_from_home()
	var overlaps: Array = []
	var unreached: Array = []
	var total := 0
	for id in Layout.areas():
		if Layout.v2():
			Layout.use(id, {})
		var here: Array = Layout.PLACES.filter(func(p: Dictionary) -> bool: return not p["kind"] in ["lot", "barrier"])
		total += here.size()
		for a in here.size():
			for b in range(a + 1, here.size()):
				if here[a]["kind"] == "building" and here[b]["kind"] == "building" and here[a]["rect"].intersects(here[b]["rect"]):
					overlaps.append([here[a]["id"], here[b]["id"]])
		for p in here:
			if not reach.get(id, {}).has(p["door"]):
				unreached.append(p["id"])
	var ferry_area := Layout.anchor_area(FERRY)
	var ferry := Layout.anchor(FERRY, ferry_area)
	var ferry_seen: bool = reach.get(ferry_area, {}).has(ferry)
	if Layout.v2():
		Layout.use(Layout.anchor_area("spawn"), {})   # where a day starts, for the picture below
	print("Layout: %d places, building overlaps %s, doors not reachable from Home %s, the ferry reachable %s" % [total, str(overlaps), str(unreached), str(ferry_seen)])
	_ok("Layout: no building overlaps another %s" % str(overlaps), overlaps.is_empty())
	_ok("Layout: every door is reachable from Home (not reached %s)" % str(unreached), unreached.is_empty())
	_ok("Layout: the ferry %s is reachable from Home" % str(ferry), ferry_seen)
	Layout.new()
	var img: Image = load("res://scripts/town/hub_town.gd").paint()
	_ok("Layout: the street paints (an image %s)" % str(img != null), img != null)   # a broken painter fails here, not a hang
	if img != null:
		var png := ProjectSettings.globalize_path(out.path_join("layout_full.png"))
		var err := img.save_png(png)
		print("Layout picture %s %s" % ["written to" if err == OK else "could not be written to", png])
	# Walk it.
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	for k in 4:
		await process_frame
	var start: Vector2i = town.team[0]["pos"]
	for k in 4:
		await town.act_move(Vector2i(1, 0))
	var lead_at: Vector2i = town.team[0]["pos"]
	var mate_at: Vector2i = town.team[1]["pos"]
	var apart: int = maxi(absi(lead_at.x - mate_at.x), absi(lead_at.y - mate_at.y))   # Chebyshev: a diagonal neighbour is 1
	print("Walk: the leader went %s -> %s; the partner follows at %s (%d apart)" % [str(start), str(lead_at), str(mate_at), apart])
	_ok("Walk: four steps east take the leader from %s to %s" % [str(start), str(lead_at)], lead_at == start + Vector2i(4, 0))
	_ok("Walk: the partner follows one tile behind (%d apart)" % apart, apart == 1)
	# Every place answers (each area's in turn; in v2 the town goes into each).
	var answered := 0
	var asked := 0
	for id in Layout.areas():
		town.enter_area(id)
		for p in Layout.PLACES:
			if p["service"] == "dungeon" or p["kind"] in ["lot", "barrier"]:
				continue
			asked += 1
			town.panel = {}
			town.team[0]["pos"] = p["door"]
			town._place(town.team[0])
			var got: Dictionary = town.act_use()
			if got.get("id", "") == p["id"]:
				answered += 1
	town.panel = {}
	town.enter_area(Layout.area_of("hall"))
	town.team[0]["pos"] = Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "hall")[0]["door"] + Vector2i(0, 1)
	town._place(town.team[0])
	town.team[0]["facing"] = "n"
	town.act_use()
	await process_frame
	await process_frame
	# Headless has no viewport texture, so the still needs a window; the printed lines are the check (Claude, 2026-10-21).
	if DisplayServer.get_name() != "headless":
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path(out.path_join("hall_panel.png")))
	_ok("Places: %d of %d answered E from their door" % [answered, asked], answered == asked and asked == 12)
	town.panel = {}
	town.enter_area(Layout.anchor_area("mouth_approach"), "mouth_approach")
	town.team[0]["pos"] = Layout.anchor("mouth_approach")
	town._place(town.team[0])
	await town.act_move(Vector2i(1, 0))
	_ok("The Mouth of the Hollow: stepping on it started a run (%s)" % str(town.get_meta("entered", "")), town.has_meta("entered"))
	town.queue_free()
	await process_frame
	await _rest_checks()
	await _pass8_checks()
	quit(1 if fails else 0)


## Every tile reachable from Home's door, area by area: {area id: {tile: true}}. A walk onto an exit carries on from the
## tile the exit lands on in its area (Highbank v2; today's map has no exits).
func _reach_from_home() -> Dictionary:
	var home := Layout.anchor_area("spawn")
	var entries := {home: [Layout.anchor("spawn", home)]}
	var reach := {}
	var todo: Array = [home]
	while not todo.is_empty():
		var id: String = todo.pop_front()
		if Layout.v2():
			Layout.use(id, {})
		var g: PackedByteArray = Layout.grid()
		var size := Layout.size()
		var seen: Dictionary = reach.get(id, {})
		var q: Array = []
		for t in entries[id]:
			if not seen.has(t):
				seen[t] = true
				q.append(t)
		while not q.is_empty():
			var c: Vector2i = q.pop_front()
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var n: Vector2i = c + d
				if n.x >= 0 and n.y >= 0 and n.x < size.x and n.y < size.y and g[n.y * size.x + n.x] == Layout.OPEN and not seen.has(n):
					seen[n] = true
					q.append(n)
		reach[id] = seen
		for e in Layout.area(id).get("exits", []):
			var r: Rect2i = e["rect"]
			var hit := false
			for t in seen:
				hit = hit or r.has_point(t)
			var land := Layout.anchor(String(e["at"]), String(e["to"]))
			if hit and Layout.exit_open(e, {}) and not reach.get(e["to"], {}).has(land):
				entries[e["to"]] = entries.get(e["to"], []) + [land]
				todo.append(e["to"])
	return reach


## A town for the pass 8 checks: a team of four, arriving as `data` says (arrive_at, news, story).
func _town(data := {}) -> Node2D:
	TeamState.start(FOUR)
	TeamState.data.merge(data, true)
	var t: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	TeamState.give_to(t)
	t.poll_input = false
	root.add_child(t)
	for k in 4:
		await process_frame
	return t


## What is wrong with where the team stands: shared tiles, partners in a footprint, and (`resting`) on a facade's row.
func _team_faults(t: Node2D, resting: bool) -> Array:
	var bad: Array = []
	var seen := {}
	for k in t.team.size():
		var p: Vector2i = t.team[k]["pos"]
		if seen.has(p):
			bad.append("%s shares %s with %s" % [t.team[k]["form"], str(p), seen[p]])
		seen[p] = t.team[k]["form"]
		if k == 0:
			continue
		if not t.follower_ok(p):
			bad.append("%s in a footprint or on solid ground at %s" % [t.team[k]["form"], str(p)])
		elif resting and not t.rest_ok(p):
			bad.append("%s on a facade's row at %s" % [t.team[k]["form"], str(p)])
	return bad


func _tiles(t: Node2D) -> String:
	return str(t.team.map(func(e: Dictionary) -> Vector2i: return e["pos"]))


## T1 / L01: every arrival, after a scene, and at the Hall's and Home's doors.
func _rest_checks() -> void:
	var arrivals := [["a new day, by Home", {}], ["home from a run", {"news": "cleared"}], ["out of the Hall", {"arrive_at": "hall"}],
		["out of Home", {"arrive_at": "home"}], ["out of the Storage", {"arrive_at": "storage"}], ["back from the Hollow's walkway", {"arrive_at": "gate"}]]
	for a in arrivals:
		var t: Node2D = await _town(a[1])
		var bad := _team_faults(t, true)
		_ok("Rest, %s: the team on %s, apart and off every footprint and facade row%s" % [a[0], _tiles(t), "" if bad.is_empty() else "; " + ", ".join(bad)], bad.is_empty())
		t.queue_free()
		await process_frame
	# A scene that leaves partners badly placed (the board scene can knock one onto the Hall's doorway): when it hands
	# the street back, they settle.
	var t2: Node2D = await _town({"news": "cleared"})
	var lead: Vector2i = t2.team[0]["pos"]
	var hall: Dictionary = Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "hall")[0]   # home from a run: by the Hall
	t2.team[1]["pos"] = hall["door"]       # the Hall's door tile, (24,6) in today's map
	t2.team[2]["pos"] = lead               # on the leader
	t2.team[3]["pos"] = Vector2i(hall["rect"].position.x + 2, hall["rect"].end.y)    # the row along the Hall's foundation, (21,7)
	for e in t2.team:
		t2._place(e)
	t2.cutscene = true
	await process_frame
	await process_frame
	t2.cutscene = false
	for k in 20:
		await process_frame
	var bad2 := _team_faults(t2, true)
	_ok("Rest, after a scene: partners left on the Hall's door, the leader's tile and the foundation's row settle to %s%s" % [_tiles(t2), "" if bad2.is_empty() else "; " + ", ".join(bad2)], bad2.is_empty())
	# At the doors: the line walks up onto the Hall's door and Home's; nobody shares a tile or stands in the footprint.
	var walks := [["the Hall's door", "lane_walk"], ["Home's door", "home_walk"]]   # (24,9) and (5,9) in today's map, the line east of it
	t2.panel = {}   # the homecoming's news line holds the keys
	for w in walks:
		t2.enter_area(Layout.anchor_area(w[1]), w[1])
		for k in t2.team.size():
			t2.team[k]["pos"] = Layout.anchor(w[1]) + Vector2i(k, 0)
			t2._place(t2.team[k])
		var bad3: Array = []
		for step in 3:
			await t2.act_move(Vector2i(0, -1))
			bad3.append_array(_team_faults(t2, false))
		_ok("At %s: the leader on %s, the line on %s, apart and off the footprint%s" % [w[0], str(t2.team[0]["pos"]), _tiles(t2), "" if bad3.is_empty() else "; " + ", ".join(bad3)],
			bad3.is_empty() and Layout.place_at(t2.team[0]["pos"]).get("kind", "") == "building")
	t2.queue_free()
	await process_frame


func _pass8_checks() -> void:
	var town: Node2D = await _town({"news": "cleared", "story": {"parcel": "saved"}})
	var HubTown: GDScript = town.get_script()
	# T4 / L11: the arrival's news in the talk box's type, every row inside the frame and above the key hint, and the
	# box's name tab clear of the screen's top panels.
	var texts: Array = [String(town.panel.get("what", ""))]
	for s in HubTown.SHUT.values():
		texts.append(s)
	texts.append("Rootbank Warren is behind you and the parcel is back. Starward will want to see it in the Wayline Tower. And with the crew out of the Warren, the river road's clear: the Storage is open.")
	var lay_bad: Array = []
	var hint_top: float = -UI.font("label").get_ascent(UI.type_size("label"))
	for s in texts:
		var lay: Dictionary = HubTown.sign_layout(s)
		var box: Rect2 = lay["box"]
		var rows: PackedStringArray = lay["rows"]
		var end: float = (lay["at"] as Vector2).y + float(lay["row_h"]) * (rows.size() - 1) + UI.font("story").get_descent(UI.type_size("story"))
		if end > box.end.y - 12.0 + hint_top or box.position.y - 22.0 < 104.0:
			lay_bad.append("'%s..' (%d rows, ends %.0f)" % [s.left(24), rows.size(), end])
	_ok("Signs: %d texts at the story role's %d px, each inside its box above the key hint%s" % [texts.size(), UI.type_size("story"), "" if lay_bad.is_empty() else "; " + ", ".join(lay_bad)], lay_bad.is_empty())
	# T9 / LH8-06: the Menu chip goes while a panel is open.
	var menu := town.get_node_or_null("GamePauseMenu")
	town.panel = {}
	await process_frame
	var chip_open: bool = menu != null and menu.hint != null and menu.hint.visible
	town.panel = {"name": "Bluff Lookout", "what": "Where the river looks close.", "service": "view"}
	await process_frame
	await process_frame
	var chip_shut: bool = menu != null and menu.hint != null and not menu.hint.visible
	town.panel = {}
	_ok("Menu chip: shown on the street %s, hidden while the board is open %s" % [str(chip_open), str(chip_shut)], chip_open and chip_shut)
	# T2 / L03 and T8 / L20: the run line names the gate as the layout does; the use key is "interact"'s on each device.
	TeamState.data["story"] = {}   # the way down open, so the run line shows
	var lines: Array = town.key_lines()
	var gate := Layout.place_name("gate")
	var keys_ok := true
	var said: Array = []
	for dev in ["keyboard", "pad"]:
		UI.set_device(dev)
		var l0 := String(town.key_lines()[0])
		said.append(l0)
		keys_ok = keys_ok and l0.ends_with("%s use" % UI.binding_text(&"interact", dev))
	UI.set_device("keyboard")
	_ok("Run line '%s' names the gate '%s'; the use keys %s match Use / stairs" % [lines[-1], gate, str(said)], String(lines[-1]).contains(gate) and keys_ok)
	var strip: Rect2 = town.key_strip()
	_ok("Key strip %s on screen and below the Next line" % str(strip), strip.position.x >= 6.0 and strip.end.x <= 1152.0 and strip.position.y > 98.0)
	# T7 / L19: one lost item to a board, never the one it pays, while the three lost items go round.
	var twice := 0
	var same := 0
	for seed in range(1, 301):
		var board: Array = Jobs.post(seed).filter(func(j: Dictionary) -> bool: return j.has("item"))
		var items := {}
		for j in board:
			if items.has(j["item"]) and board.size() <= Jobs.LOST_ITEMS.size():
				twice += 1
			items[j["item"]] = true
			if j["item"] == j["reward"] and board.size() < Jobs.LOST_ITEMS.size():
				same += 1
	_ok("Board: 300 boards, a lost item named twice %d times, one the job also pays %d times (where there was another)" % [twice, same], twice == 0 and same == 0)
	# T3 / L10 and L-10: the Mouth's own line below; after the end card, the record in order.
	var Objective: GDScript = load("res://scripts/town/objective.gd")
	var mouth: String = Objective.current({}, [], true)["short"]
	var bank: String = Objective.current({}, [])["short"]
	var after := {"parcel": "delivered", "stone": "installed", "pilot_end_seen": true}
	var beaten := ["mouth", "first", "hollow"]
	TeamState.data["story"] = after
	TeamState.data["party"] = [[0, 0], [1, 0]]
	TeamState.data["jobs"] = []
	Objective.set("_memo_at", -100)
	var ready_s: String = Objective.current(after, beaten)["short"]
	TeamState.data["party"] = [[0, 1], [1, 1]]
	var job: Dictionary = Jobs.post(7)[0]
	TeamState.data["jobs"] = [job]
	Objective.set("_memo_at", -100)
	var job_s: String = Objective.current(after, beaten)["short"]
	TeamState.data["jobs"] = []
	Objective.set("_memo_at", -100)
	var none_s: String = Objective.current(after, beaten)["short"]
	print("Objective: Mouth '%s', bank '%s', ready '%s', job '%s', none '%s'" % [mouth, bank, ready_s, job_s, none_s])
	_ok("Objective: the Mouth has its own line, and after the end card the line reads ready, then jobs, then the board",
		mouth != bank and ready_s.contains("ready to grow") and job_s.contains(Jobs.client_name(job)) and none_s == "New requests on the Job Board.")
	# T11 / L33: the door kept on the root plays on past the town (enter_room's sound).
	town._sfx("door", true)
	await process_frame
	await process_frame
	var door: AudioStreamPlayer = null
	for c in root.get_children():
		if c is AudioStreamPlayer and c.stream != null and String(c.stream.resource_path).ends_with("door.wav"):
			door = c
	_ok("Door kept on the root: in the tree %s, on bus %s, playing %s" % [str(door != null), str(door.bus) if door != null else "-", str(door.playing) if door != null else "-"],
		door != null and door.bus == &"SFX" and door.playing)
	town.queue_free()
	await process_frame
