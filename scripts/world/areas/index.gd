extends RefCounted
## Every town area, by id (lane A, Claude, 2026-10-26; 02-town-rewire-design.md section 3.1). One file per area under
## scripts/world/areas/, each holding `const AREA := {...}` in the format of 02 section 3.2. scripts/town/town_layout.gd
## reads them; nothing else needs to know the files.
##
## With Highbank v2 off (the default) the town is V1 alone, today's map. With it on (HT_HIGHBANK_V2=1, the const
## TownLayout.HIGHBANK_V2, or scenes/debug/highbank_v2.tscn) the town is the V2 areas, joined by their exits. A new area
## is a file, a line in V2, and an exit each way (tools/debug/area_data_check.gd refuses a one-way exit).

const V1 := preload("res://scripts/world/areas/highbank_v1.gd")
const V2 := {
	"street": preload("res://scripts/world/areas/street.gd"),
	"hall_rise": preload("res://scripts/world/areas/hall_rise.gd"),
	"ferry_ward": preload("res://scripts/world/areas/ferry_ward.gd"),
	"east_quarter": preload("res://scripts/world/areas/east_quarter.gd"),
	"tree_path": preload("res://scripts/world/areas/tree_path.gd"),   # Claude, 2026-10-28: the great tree's own area
}
const V2_FIRST := "street"   # where a day starts in v2 (its "spawn" anchor)


## The area's data (read-only), or {} for an unknown id.
static func area(id: String) -> Dictionary:
	if id == V1.AREA["id"]:
		return V1.AREA
	if V2.has(id):
		return V2[id].AREA
	return {}


## The ids of v2's areas, in the order above.
static func v2_ids() -> PackedStringArray:
	return PackedStringArray(V2.keys())


# The Wayline Tower's cables outside Tower Rise (Claude, 2026-10-27; docs/design/wayline-tower-2026-10-27/TOWER_DESIGN.md
# section 7). Tower Rise's own four hang from the Tower itself (TowerParts.place). Every other area lists its lines under
# "waylines" ({route, post, enter, sag, needs}); these two read that list against the exits between the areas.
const TOWER_AREA := "hall_rise"
const POST := "town.prop.hall.wayline_post"
const QUIET_SLACK := 1.6   # the quiet route's line hangs this much lower, as on Tower Rise (TowerParts._place_waylines)


## The edge of area `id` that faces the Wayline Tower ("n", "s", "e" or "w"): the side the exit stands on that starts
## the shortest walk to Tower Rise, whether or not that exit is open yet. "" for Tower Rise itself and for an area with
## no way there.
static func tower_edge(id: String) -> String:
	if id == TOWER_AREA or not V2.has(id):
		return ""
	var first := {}   # area -> the exit out of `id` that reached it first
	var queue: Array = []
	for e in area(id).get("exits", []):
		if V2.has(String(e["to"])) and not first.has(e["to"]):
			first[e["to"]] = e
			queue.append(e["to"])
	while not queue.is_empty():
		var at: String = queue.pop_front()
		if at == TOWER_AREA:
			return _side(area(id)["size"], first[at]["rect"])
		for e in area(at).get("exits", []):
			if V2.has(String(e["to"])) and not first.has(e["to"]) and e["to"] != id:
				first[e["to"]] = first[at]
				queue.append(e["to"])
	return ""


## Area `id`'s waylines in its own px, ready to hang (TowerParts.wayline(from, to, sag)): each comes in at "enter" px
## along the edge that faces the Tower and ends on the pulley of the wayline post standing on its "post" tile. Each is
## {route, from, to, sag, quiet, needs, post}: "quiet" when its post is ("state": "quiet"), and then it hangs slack;
## "needs" is the story flag that opens its route ("" for none), for TownLayout.exit_open. [] for Tower Rise and for an
## area without lines; a line whose post is missing is left out (tower_lean_check names it).
static func waylines(id: String) -> Array:
	var out: Array = []
	var edge := tower_edge(id)
	if edge == "":
		return out
	var a := area(id)
	var size: Vector2 = Vector2(a["size"] * 24)
	var spec := ArtSlots.spec(POST)
	var anchor: Vector2i = spec.get("anchor", Vector2i(12, 63))
	var pulley: Vector2i = spec.get("anchors", {}).get("pulley", Vector2i(12, 7))
	for l in a.get("waylines", []):
		var post := {}
		for p in a.get("props", []):
			if String(p.get("slot", "")) == POST and p.get("tile") == l.get("post"):
				post = p
		if post.is_empty():
			continue
		# The post's foot is its tile's bottom row, centred (TownProps.foot_px for a one-tile prop); the pulley is
		# that far up its picture.
		var tile: Vector2i = post["tile"]
		var foot := Vector2(tile.x * 24 + 12, (tile.y + 1) * 24 - 1)
		var along := float(l.get("enter", 0))
		var from: Vector2 = {"n": Vector2(along, 0), "s": Vector2(along, size.y), "w": Vector2(0, along),
			"e": Vector2(size.x, along)}[edge]
		var quiet := String(post.get("state", "")) == "quiet"
		out.append({"route": int(l.get("route", -1)), "from": from, "to": foot + Vector2(pulley - anchor),
			"sag": float(l.get("sag", 30)) * (QUIET_SLACK if quiet else 1.0), "quiet": quiet,
			"needs": String(l.get("needs", "")), "post": tile})
	return out


## Which edge of an area of `size` tiles the tile rect `r` stands on.
static func _side(size: Vector2i, r: Rect2i) -> String:
	if r.position.y == 0:
		return "n"
	if r.end.y == size.y:
		return "s"
	if r.position.x == 0:
		return "w"
	return "e"
