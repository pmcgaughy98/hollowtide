extends RefCounted
## Highbank Street, the first of Highbank v2's areas (lane A, Claude, 2026-10-26; 02-town-rewire-design.md section 6.2,
## build plan 2.1). Behind the switch: TownLayout.v2() is false unless HT_HIGHBANK_V2=1 or the debug scene
## (scenes/debug/highbank_v2.tscn) turns it on. Area and lot names are working labels, Preston's to rename.
##
## One long street, the way Explorers of Sky's town is one street of services: Home and the shops face the lane from
## the north side, doors south; the Lookout, the Growth Shrine, the Training Yard and an empty plot sit on the south
## side; the Crossroads at the east end, with steps north to Tower Rise and the switchbacks south to the Old Ferry Ward.
## The road east is closed (its exit needs a flag nothing sets). Buildings use the template classes of section 4.2
## (scripts/town/building_template.gd): "base" is the solid footprint with the front wall on its bottom row, and the
## roof rises over the rows above it.

const AREA := {
	"id": "street", "name": "Highbank Street", "kind": "exterior", "size": Vector2i(56, 16),
	"card": "HIGHBANK", "music": "highbank",
	"ground": {"base": "grass", "bands": [
		{"from": 0, "to": 0, "kind": "hedge"},     # the hedge along the back of the lots
		{"from": 1, "to": 14, "kind": "grass"},
		{"from": 15, "to": 15, "kind": "cliff"},   # the bluff's edge; the switchbacks cross it
	], "soft": [Rect2i(40, 7, 14, 8)]},          # the lanes fray into the grass round the Crossroads
	"paths": [
		{"rect": Rect2i(1, 8, 55, 2), "kind": "lane"},     # Market Street, west to east
		{"rect": Rect2i(46, 1, 2, 7), "kind": "steps"},    # north, up to Tower Rise
		{"rect": Rect2i(46, 10, 2, 6), "kind": "steps"},   # south, the switchbacks down to the Old Ferry Ward
		{"rect": Rect2i(5, 7, 1, 1), "kind": "lane"},      # a worn step from each door to the lane
		{"rect": Rect2i(14, 7, 1, 1), "kind": "lane"},
		{"rect": Rect2i(22, 7, 1, 1), "kind": "lane"},
		{"rect": Rect2i(30, 7, 1, 1), "kind": "lane"},
		{"rect": Rect2i(37, 7, 1, 1), "kind": "lane"},
	],
	"buildings": [
		{"id": "home", "name": "Home", "service": "home", "what": "The team's place to sleep and save. The day starts here.",
			"class": "cottage", "base": Rect2i(3, 5, 5, 2), "door": [Vector2i(5, 6)], "roof": "moss", "wall": "river_stone",
			"windows": [0], "chimney": 1, "room": "home"},
		{"id": "shop", "name": "Item Shop", "service": "shop", "what": "Berries, lamp oil, stones: what a run needs.",
			"class": "shop", "base": Rect2i(12, 5, 6, 2), "door": [Vector2i(14, 6)], "roof": "gable", "wall": "plank",
			"windows": [0, 5], "awning": true, "sign": {"col": 4, "icon": "bag"}, "room": "", "shut": "shop"},
		{"id": "storage", "name": "Storage", "service": "storage",
			"what": "Keeps items between runs. A run's bag is lost when the team goes down; storage is not.",
			"class": "shop", "base": Rect2i(20, 5, 6, 2), "door": [Vector2i(22, 6)], "roof": "hip", "wall": "stone",
			"windows": [5], "sign": {"col": 4, "icon": "crate"}, "room": "storage"},
		# The Scroll Keeper's door moves to the street side, down to a cellar room (Preston's call 4, the default).
		{"id": "scrolls", "name": "Scroll Keeper", "service": "scrolls",
			"what": "Move scrolls: teaches a shared signature to a body that has the parts, and remembers forgotten moves.",
			"class": "shop", "base": Rect2i(28, 5, 6, 2), "door": [Vector2i(30, 6)], "roof": "flat", "wall": "timber",
			"windows": [0], "sign": {"col": 4, "icon": "scroll"}, "room": "", "shut": "scrolls"},
	],
	"places": [
		{"id": "lookout", "name": "Bluff Lookout", "kind": "area", "rect": Rect2i(1, 11, 6, 4), "door": Vector2i(4, 12),
			"service": "view", "what": "Where the river looks close. On a clear day you can see the next bend."},
		{"id": "shrine", "name": "Growth Shrine", "kind": "area", "rect": Rect2i(12, 11, 6, 4), "door": Vector2i(14, 11),
			"service": "growth", "what": "Where a creature that is ready grows into its next form.",
			"anchors": {"socket": Vector2i(72, 64)}},   # px in the shrine's art (town.landmark.shrine): the stone goes here
		{"id": "yard", "name": "Training Yard", "kind": "area", "rect": Rect2i(21, 11, 7, 4), "door": Vector2i(24, 11),
			"service": "arena", "what": "The arena side mode as the town's dojo: real-time spars and practice."},
		{"id": "plaza", "name": "Crossroads", "kind": "area", "rect": Rect2i(41, 7, 12, 8), "door": Vector2i(46, 12),
			"service": "waymark", "what": "The town's centre: the waymark points to every place."},
	],
	"props": [
		{"slot": "town.lamp.post", "tile": Vector2i(10, 7), "solid": true, "light": true},
		{"slot": "town.lamp.post", "tile": Vector2i(19, 7), "solid": true, "light": true},
		{"slot": "town.lamp.post", "tile": Vector2i(27, 7), "solid": true, "light": true},
		{"slot": "town.lamp.post", "tile": Vector2i(35, 7), "solid": true, "light": true},
		{"slot": "town.lamp.post", "tile": Vector2i(41, 7), "solid": true, "light": true},
		{"slot": "town.lamp.post", "tile": Vector2i(52, 7), "solid": true, "light": true},
		{"slot": "town.prop.waymark", "tile": Vector2i(48, 11), "solid": true},
		# The road east is barred while its exit is shut (the East Quarter, a later area).
		{"slot": "town.prop.road_barrier", "tile": Vector2i(55, 8), "size": Vector2i(1, 2), "solid": true, "shut_exit": "road_east"},
	],
	# Lots: places that are not open yet (02 section 3.6). Each stands in its "before" state, solid, and reads a line;
	# it opens when "opens" holds, and only a lot with a "building" becomes one. No beat opens a lot yet.
	"lots": [
		{"id": "lot_a", "name": "Empty Stall", "base": Rect2i(36, 5, 4, 2), "door": Vector2i(37, 6), "class": "stall",
			"before": "tarp", "slot": "town.building.lot_before_stall", "opens": {"flag": "lot_a_open"},
			"what": "A tarp tied down over a bare counter. Nobody's set up here yet."},
		{"id": "lot_b", "name": "Empty Plot", "base": Rect2i(31, 11, 6, 4), "door": Vector2i(33, 11), "class": "stall",
			"before": "plot", "slot": "town.landmark.lot_before_plot", "opens": {"flag": "lot_b_open"},
			"what": "Stakes and a low fence round trampled earth. Something's meant to go up here."},
	],
	"exits": [
		{"id": "north_steps", "rect": Rect2i(46, 0, 2, 1), "to": "hall_rise", "at": "rise_steps", "facing": "n", "sfx": "stairs"},
		{"id": "south_steps", "rect": Rect2i(46, 15, 2, 1), "to": "ferry_ward", "at": "ferry_steps", "facing": "s", "sfx": "stairs"},
		{"id": "road_east", "rect": Rect2i(55, 8, 1, 2), "to": "east_quarter", "at": "quarter_road", "facing": "e", "sfx": "",
			"needs": "east_quarter_open", "name": "Road East",
			"shut": "Two posts and crossed planks across the road east. It's closed for now."},
	],
	"anchors": {
		"spawn": Vector2i(5, 7),           # under Home's door, the start of a day
		"street_north": Vector2i(46, 1),   # arriving down the steps from Tower Rise
		"street_south": Vector2i(46, 14),  # arriving up the switchbacks from the Ferry Ward
		"street_east": Vector2i(54, 8),    # arriving back from the East Quarter
		"home_walk": Vector2i(5, 8),       # two steps below Home's door (town_walk_check, hub_town_check)
		"yard_gate": Vector2i(24, 11),     # the Training Yard's gate
		"yard_gate_front": Vector2i(24, 10),
		"music_street": Vector2i(24, 9),   # music_check
		"view_street": Vector2i(24, 9),    # town_view_capture
	},
	"npcs": [],
}
