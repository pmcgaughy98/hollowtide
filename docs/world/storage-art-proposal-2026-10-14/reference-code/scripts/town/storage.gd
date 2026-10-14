extends RefCounted
## Storage (Claude, 2026-10-12; R6 of docs/design/genre-synthesis-2026-10-12.md: the town grows with routes).
## The Storage keeps items between runs: a faint loses the bag, never this. It opens when the river road is
## clear, which is when Rootbank Warren's crew are beaten (the road runs past their den). Nothing is bought:
## the service is the route's reward, the genre's warehouse in our frame. The record is TeamState.data:
## "stored" (kind -> count), beside "bag". Parcels are for carrying, not keeping. Words are Claude's drafts.

const DUNGEON := "res://scripts/dungeon/dungeon.gd"   # loaded, not preloaded: dungeon.gd loads town scripts
const Arena := preload("res://scripts/arena/arena_prototype.gd")
const ROUTE := "first"   # the dungeon whose clearing reopens the road
const PARCEL := "parcel"


static func open(data: Dictionary) -> bool:
	return ROUTE in data.get("beaten", [])


static func shut_text() -> String:
	return "Shut. A note on the door: \"Back when the river road's clear.\" Gruntle's bunch hold the Warren, and the road runs right past their den."


static func bag_kinds() -> int:
	return int(load(DUNGEON).get_script_constant_map()["BAG_KINDS"])


static func item_name(kind: String) -> String:
	if kind.begins_with("scroll:"):
		var m := kind.substr(7)
		return "%s Scroll" % String(Arena.MOVES.get(m, {}).get("name", m))
	var items: Dictionary = load(DUNGEON).get_script_constant_map()["ITEMS"]
	return String(items.get(kind, {}).get("name", kind))


## Every kind in the bag or the store, the bag's kinds first: [kind, in the bag, kept here].
static func rows(data: Dictionary) -> Array:
	var bag: Dictionary = data.get("bag", {})
	var stored: Dictionary = data.get("stored", {})
	var out: Array = []
	for k in bag:
		out.append([String(k), int(bag[k]), int(stored.get(k, 0))])
	for k in stored:
		if not bag.has(k):
			out.append([String(k), 0, int(stored[k])])
	return out


## Move one of a kind: n = 1 puts one in the store, n = -1 takes one out. Returns what to say.
static func move(data: Dictionary, kind: String, n: int) -> String:
	if kind == PARCEL:
		return "The parcel's for carrying, not keeping."
	var bag: Dictionary = data.get("bag", {})
	var stored: Dictionary = data.get("stored", {})
	var said := ""
	if n > 0:
		if int(bag.get(kind, 0)) <= 0:
			return "None of that in the bag."
		bag[kind] = int(bag[kind]) - 1
		if bag[kind] <= 0:
			bag.erase(kind)
		stored[kind] = int(stored.get(kind, 0)) + 1
		said = "Put in: %s. It stays here through anything." % item_name(kind)
	else:
		if int(stored.get(kind, 0)) <= 0:
			return "None of that kept here."
		if not bag.has(kind) and bag.size() >= bag_kinds():
			return "The bag holds %d kinds. Put something in first." % bag_kinds()
		stored[kind] = int(stored[kind]) - 1
		if stored[kind] <= 0:
			stored.erase(kind)
		bag[kind] = int(bag.get(kind, 0)) + 1
		said = "Taken out: %s." % item_name(kind)
	data["bag"] = bag
	data["stored"] = stored
	return said
