extends RefCounted
## The hub town's layout (Claude, 2026-10-09; Preston: "do the world layout with the synthesis so
## Codex can just fill it in"). Highbank from the world bible ("upper streets hold homes, shops, and
## the dispatch hall. Switchback lanes descend ... to the ferry district"), laid out as a Mystery
## Dungeon hub: Explorers of Sky's crossroads town (the guild on the high ground, a street of services,
## the hero's home apart, paths down to the water and out to the dungeons) and Rescue Team DX's square
## of services. Structure only; every name here is a working name from the world bible or a role.
##
## This file is the contract: positions, sizes, doors and jobs. Codex paints art to these rects and
## must not move a door or a path tile without telling Claude (the rules and the checks read them).
## Tiles are 24 px, the dungeon's size, so creatures walk the town at the same scale.

const T := 24
const W := 48
const H := 32

# Terrain bands, top to bottom: the bluff-top town, a cliff, a middle terrace, a cliff, the lower
# terrace at the ferry, the river.
const BANDS := [
	{"from": 0, "to": 17, "kind": "grass"},     # the bluff top: Highbank's upper streets
	{"from": 18, "to": 18, "kind": "cliff"},
	{"from": 19, "to": 23, "kind": "terrace"},  # the switchbacks' middle terrace
	{"from": 24, "to": 24, "kind": "cliff"},
	{"from": 25, "to": 29, "kind": "terrace"},  # the Old Ferry Ward's landing
	{"from": 30, "to": 31, "kind": "water"},    # the river
]

# Paths (walkable, drawn as lanes). The two cliff crossings are the switchbacks.
const PATHS := [
	Rect2i(4, 9, 41, 2),     # Market Street, west to east along the bluff
	Rect2i(23, 7, 2, 2),     # the hall's steps down to the street
	Rect2i(23, 11, 2, 7),    # the street south to the cliff edge (through the plaza)
	Rect2i(23, 18, 2, 2),    # switchback 1 through the upper cliff
	Rect2i(14, 20, 11, 2),   # along the middle terrace, west
	Rect2i(14, 22, 2, 4),    # switchback 2 through the lower cliff
	Rect2i(14, 25, 18, 2),   # along the landing, east
	Rect2i(45, 9, 3, 2),     # the road east (to the region; closed for now)
]

# Buildings: solid footprints; the door is the one walkable tile of the footprint, on its street
# side. Areas: open walkable spaces with a spot to stand on. Every place has a service the rules use.
const PLACES := [
	{"id": "hall", "name": "Wayline Hall", "kind": "building", "rect": Rect2i(19, 1, 10, 6), "door": Vector2i(24, 6),
		"service": "guild", "what": "The Wayline Compact's hall: jobs, the team roster, reports. The guild of this game."},
	{"id": "board", "name": "Job Board", "kind": "spot", "rect": Rect2i(26, 7, 2, 1), "door": Vector2i(26, 8),
		"service": "jobs", "what": "Requests to take into the Hollows. Pick one, then go down to the ferry."},
	{"id": "lookout", "name": "Bluff Lookout", "kind": "area", "rect": Rect2i(10, 2, 6, 4), "door": Vector2i(13, 5),
		"service": "view", "what": "Where the river looks close. Later: the region map."},
	{"id": "home", "name": "Home", "kind": "building", "rect": Rect2i(3, 3, 5, 5), "door": Vector2i(5, 7),
		"service": "home", "what": "The team's place to sleep and save. The day starts here."},
	{"id": "shop", "name": "Item Shop", "kind": "building", "rect": Rect2i(31, 3, 6, 5), "door": Vector2i(33, 7),
		"service": "shop", "what": "Berries, lamp oil, stones: what a run needs."},
	{"id": "storage", "name": "Storage", "kind": "building", "rect": Rect2i(38, 3, 6, 5), "door": Vector2i(40, 7),
		"service": "storage", "what": "Keeps items between runs; a run's bag is lost on a faint, storage is not."},
	{"id": "scrolls", "name": "Scroll Keeper", "kind": "building", "rect": Rect2i(31, 12, 6, 5), "door": Vector2i(33, 12),
		"service": "scrolls", "what": "Move scrolls: teaches a shared signature to a body that has the parts, and remembers forgotten moves."},
	{"id": "yard", "name": "Training Yard", "kind": "area", "rect": Rect2i(38, 12, 7, 5), "door": Vector2i(41, 12),
		"service": "arena", "what": "The arena side mode as the town's dojo: real-time spars and practice."},
	{"id": "shrine", "name": "Growth Shrine", "kind": "area", "rect": Rect2i(4, 12, 6, 5), "door": Vector2i(7, 12),
		"service": "growth", "what": "Shows each creature's growth toward evolving, and its IQ skills."},
	{"id": "plaza", "name": "Crossroads", "kind": "area", "rect": Rect2i(18, 11, 12, 6), "door": Vector2i(24, 14),
		"service": "waymark", "what": "The town's centre: the waymark points to every place."},
	{"id": "landing", "name": "Old Ferry Landing", "kind": "area", "rect": Rect2i(26, 26, 12, 4), "door": Vector2i(28, 27),
		"service": "landing", "what": "The old crossing, where the first Hollowtide reports came from."},
	{"id": "gate", "name": "Mouth of the Hollow", "kind": "spot", "rect": Rect2i(33, 27, 2, 2), "door": Vector2i(33, 28),
		"service": "dungeon", "what": "The way into the Hollow. Step in to start a run."},
	{"id": "dock", "name": "Ferry Dock", "kind": "area", "rect": Rect2i(38, 28, 6, 2), "door": Vector2i(39, 28),
		"service": "view", "what": "Planks over the water. Later: the crossing to the far bank."},
]
const SPAWN := Vector2i(5, 8)   # outside Home's door, the start of a day

enum { WALL, OPEN }


## The walkable grid: terrain bands, then paths, then places (a building is solid except its door).
static func grid() -> PackedByteArray:
	var g := PackedByteArray()
	g.resize(W * H)
	for b in BANDS:
		for y in range(b["from"], b["to"] + 1):
			for x in W:
				g[y * W + x] = OPEN if b["kind"] in ["grass", "terrace"] else WALL
	for r in PATHS:
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				g[y * W + x] = OPEN
	for p in PLACES:
		var r: Rect2i = p["rect"]
		if p["kind"] == "building":
			for y in range(r.position.y, r.end.y):
				for x in range(r.position.x, r.end.x):
					g[y * W + x] = WALL
		g[p["door"].y * W + p["door"].x] = OPEN
	return g


static func band_of(y: int) -> String:
	for b in BANDS:
		if y >= b["from"] and y <= b["to"]:
			return b["kind"]
	return "water"


static func place_at(t: Vector2i) -> Dictionary:
	for p in PLACES:
		if p["door"] == t:
			return p
	return {}
