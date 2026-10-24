extends SceneTree
## The hub town blockout (Claude, 2026-10-09): the layout holds together (no place overlaps another,
## every door is on open ground and reachable from Home, the switchbacks connect the bluff to the
## ferry), the team walks and follows, every place answers E, and the Mouth of the Hollow starts a run.
## Each of those is a verdict line (Claude, 2026-10-24, H03).
##   Godot --path . --fixed-fps 30 --script res://tools/debug/hub_town_check.gd
## The layout picture (and the Hall panel still, with a window) go to the runner's logs folder (HT_CHECK_LOGS),
## or user:// on a direct run. `-- --update-doc` writes them to docs/world/hub-layout-2026-10-09/ instead, so a
## suite run leaves the tracked docs alone (Claude, 2026-10-24, H03; pilot_chain_check.gd's pattern).

const Layout := preload("res://scripts/town/town_layout.gd")
const DOC := "res://docs/world/hub-layout-2026-10-09/"
const FERRY := Vector2i(28, 27)   # the ferry landing the switchbacks lead down to
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
	var g: PackedByteArray = Layout.grid()
	# Overlaps.
	var overlaps: Array = []
	for a in Layout.PLACES.size():
		for b in range(a + 1, Layout.PLACES.size()):
			if Layout.PLACES[a]["kind"] == "building" and Layout.PLACES[b]["kind"] == "building" and Layout.PLACES[a]["rect"].intersects(Layout.PLACES[b]["rect"]):
				overlaps.append([Layout.PLACES[a]["id"], Layout.PLACES[b]["id"]])
	# Reachable from the spawn.
	var seen := {Layout.SPAWN: true}
	var q: Array = [Layout.SPAWN]
	while not q.is_empty():
		var c: Vector2i = q.pop_front()
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = c + d
			if n.x >= 0 and n.y >= 0 and n.x < Layout.W and n.y < Layout.H and g[n.y * Layout.W + n.x] == Layout.OPEN and not seen.has(n):
				seen[n] = true
				q.append(n)
	var unreached: Array = []
	for p in Layout.PLACES:
		if not seen.has(p["door"]):
			unreached.append(p["id"])
	print("Layout: %d places, building overlaps %s, doors not reachable from Home %s, the ferry reachable %s" % [Layout.PLACES.size(), str(overlaps), str(unreached), str(seen.has(FERRY))])
	_ok("Layout: no building overlaps another %s" % str(overlaps), overlaps.is_empty())
	_ok("Layout: every door is reachable from Home (not reached %s)" % str(unreached), unreached.is_empty())
	_ok("Layout: the ferry %s is reachable from Home" % str(FERRY), seen.has(FERRY))
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
	# Every place answers.
	var answered := 0
	for p in Layout.PLACES:
		if p["service"] == "dungeon":
			continue
		town.panel = {}
		town.team[0]["pos"] = p["door"]
		town._place(town.team[0])
		var got: Dictionary = town.act_use()
		if got.get("id", "") == p["id"]:
			answered += 1
	town.panel = {}
	town.team[0]["pos"] = Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "hall")[0]["door"] + Vector2i(0, 1)
	town._place(town.team[0])
	town.team[0]["facing"] = "n"
	town.act_use()
	await process_frame
	await process_frame
	# Headless has no viewport texture, so the still needs a window; the printed lines are the check (Claude, 2026-10-21).
	if DisplayServer.get_name() != "headless":
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path(out.path_join("hall_panel.png")))
	_ok("Places: %d of %d answered E from their door" % [answered, Layout.PLACES.size() - 1], answered == Layout.PLACES.size() - 1)
	town.panel = {}
	town.team[0]["pos"] = Vector2i(32, 28)
	town._place(town.team[0])
	await town.act_move(Vector2i(1, 0))
	_ok("The Mouth of the Hollow: stepping on it started a run (%s)" % str(town.get_meta("entered", "")), town.has_meta("entered"))
	quit(1 if fails else 0)
