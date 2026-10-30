extends RefCounted
## Highbank Street, the first of Highbank v2's areas (lane A, Claude, 2026-10-26; 02-town-rewire-design.md section 6.2,
## build plan 2.1). Behind the switch: TownLayout.v2() is false unless HT_HIGHBANK_V2=1 or the debug scene
## (scenes/debug/highbank_v2.tscn) turns it on. Area and lot names are working labels, Preston's to rename.
##
## One long street, the way Explorers of Sky's town is one street of services: Home and the shops face the lane from
## the north side, doors south; the Lookout, the Training Yard and an empty plot sit on the south
## side; the Crossroads at the east end, with steps north to Tower Rise and the switchbacks south to the Old Ferry Ward.
## The road east is closed (its exit needs a flag nothing sets). Buildings use the template classes of section 4.2
## (scripts/town/building_template.gd): "base" is the solid footprint with the front wall on its bottom row, and the
## roof rises over the rows above it.

const AREA := {
	"id": "street", "name": "Highbank Street", "kind": "exterior", "size": Vector2i(56, 19),
	"card": "HIGHBANK", "music": "highbank",
	"ground": {"base": "grass", "bands": [
		{"from": 0, "to": 0, "kind": "hedge"},     # the hedge along the back of the lots
		{"from": 1, "to": 17, "kind": "grass"},
		{"from": 18, "to": 18, "kind": "cliff"},   # the bluff's edge; the switchbacks cross it
	], "soft": [Rect2i(40, 9, 14, 9)]},          # the lanes fray into the grass round the Crossroads
	"paths": [
		# The street grew two rows on 2026-10-28 (TOWN_SYNTHESIS.md): the buildings moved down two so a taller roof fits
		# under the hedge, and the lane three, so a two-row dooryard lies between each front and the road.
		{"rect": Rect2i(1, 11, 55, 2), "kind": "lane"},    # Market Street, west to east
		{"rect": Rect2i(46, 1, 2, 10), "kind": "steps"},   # north, up to Tower Rise
		{"rect": Rect2i(46, 13, 2, 6), "kind": "steps"},   # south, the switchbacks down to the Old Ferry Ward
		{"rect": Rect2i(5, 9, 1, 2), "kind": "lane"},      # a worn path from each door across its dooryard to the lane
		{"rect": Rect2i(10, 9, 10, 2), "kind": "lane"},    # the Item Shop's forecourt, trodden bare in front of its stock
		{"rect": Rect2i(30, 9, 1, 2), "kind": "lane"},
		{"rect": Rect2i(37, 9, 1, 2), "kind": "lane"},
	],
	"buildings": [
		# Home dug into the bluff (Preston's yes, 2026-10-28; TOWN_MAP.md): the burrow class, a grass bank over a base three
		# deep, the round-ringed door on the same tile as the old cottage's so the path and the spawn stay put.
		{"id": "home", "name": "Home", "service": "home", "what": "The team's place to sleep and save. The day starts here.",
			"class": "burrow", "base": Rect2i(3, 6, 5, 3), "door": [Vector2i(5, 8)], "room": "home"},
		# Swaphoard's trading post (Preston, 2026-10-28: the Item Shop is the first building shaped by its keeper, then
		# "wire shop again but make bigger"): the trading_post class, roof first on a base three deep. Its dooryard is the
		# forecourt above and the goods tables, crates, mat and rocks in "props".
		{"id": "shop", "name": "Item Shop", "service": "shop", "what": "Berries, lamp oil, stones: what a run needs.",
			"class": "trading_post", "base": Rect2i(11, 6, 8, 3), "door": [Vector2i(14, 8)], "sign": {"col": 2, "icon": "bag"},
			"room": "", "shut": "shop"},
		# Storage stood here at (20,5) until Preston moved it down to the Ferry Ward (2026-10-28); its ground stays open for
		# a keeper-shaped building to come (docs/design/town-map-2026-10-28/TOWN_MAP.md).
		# The Scroll Keeper's door moves to the street side, down to a cellar room (Preston's call 4, the default).
		{"id": "scrolls", "name": "Scroll Keeper", "service": "scrolls",
			"what": "Move scrolls: teaches a shared signature to a body that has the parts, and remembers forgotten moves.",
			"class": "shop", "base": Rect2i(28, 7, 6, 2), "door": [Vector2i(30, 8)], "roof": "flat", "wall": "timber",
			"windows": [0], "sign": {"col": 4, "icon": "scroll"}, "room": "", "shut": "scrolls"},
	],
	"places": [
		{"id": "lookout", "name": "Bluff Lookout", "kind": "area", "rect": Rect2i(1, 14, 6, 4), "door": Vector2i(4, 15),
			"service": "view", "what": "Where the river looks close. On a clear day you can see the next bend."},
		# The Growth Shrine stood at (12,11) until Preston moved it to the Great Tree Path (2026-10-28).
		{"id": "yard", "name": "Training Yard", "kind": "area", "rect": Rect2i(21, 14, 7, 4), "door": Vector2i(24, 14),
			"service": "arena", "what": "The arena side mode as the town's dojo: real-time spars and practice."},
		{"id": "plaza", "name": "Crossroads", "kind": "area", "rect": Rect2i(41, 9, 12, 9), "door": Vector2i(46, 15),
			"service": "waymark", "what": "The town's centre: the waymark points to every place."},
	],
	"props": [
		{"slot": "town.lamp.post", "tile": Vector2i(10, 10), "solid": true, "light": true},
		{"slot": "town.lamp.post", "tile": Vector2i(19, 10), "solid": true, "light": true},
		{"slot": "town.lamp.post", "tile": Vector2i(27, 10), "solid": true, "light": true},
		{"slot": "town.lamp.post", "tile": Vector2i(35, 10), "solid": true, "light": true},
		{"slot": "town.lamp.post", "tile": Vector2i(41, 10), "solid": true, "light": true},
		{"slot": "town.lamp.post", "tile": Vector2i(52, 10), "solid": true, "light": true},
		# The Item Shop's dooryard (TOWN_SYNTHESIS.md): its stock laid out either side of the front on goods tables seen
		# from above, crates stacked against the walls, rocks closing the yard's ends. No mat: the step in front of a door
		# stays clear by the town's rule (area_data_check), and the trodden forecourt already marks it.
		{"slot": "town.prop.goods_table", "tile": Vector2i(9, 8), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.goods_table", "tile": Vector2i(19, 8), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.crate_stack", "tile": Vector2i(10, 7), "solid": true},
		{"slot": "town.prop.crate_stack", "tile": Vector2i(19, 7), "solid": true},
		{"slot": "town.prop.rock_cluster", "tile": Vector2i(8, 8), "solid": true},
		{"slot": "town.prop.rock_cluster", "tile": Vector2i(21, 8), "solid": true},
		{"slot": "town.prop.waymark", "tile": Vector2i(48, 14), "solid": true},
		# The road east is barred while its exit is shut (the East Quarter, a later area).
		{"slot": "town.prop.road_barrier", "tile": Vector2i(55, 11), "size": Vector2i(1, 2), "solid": true, "shut_exit": "road_east"},
		# The wayline post on the Crossroads' west side, just below Market Street, where route 1's cable from the Tower ties
		# off (waylines below). It stood by the steps at (45,6) until the 2026-10-27 look pass found the whole cable above
		# the view from the street's middle rows; from here it comes down over the north steps to the lane, in sight.
		# Route 1's lantern on the deck is dark (TowerParts.LANTERN_STATES), so its post waits unlit.
		{"slot": "town.prop.hall.wayline_post", "tile": Vector2i(44, 13), "solid": true, "state": "waiting"},
	],
	# Waylines (TOWER_DESIGN.md section 7): cables from the Wayline Tower's Reel Deck. Each comes in over the edge that
	# faces the Tower (index.gd tower_edge(): north here, up the steps) at "enter" px along it, and ties off at the pulley
	# of the wayline post standing on "post"; one line per open route ("route": its sheave and lantern on the deck,
	# TowerParts.LANTERN_T). index.gd waylines() gives them in this area's px. The Tower is never drawn here.
	"waylines": [
		{"route": 1, "post": Vector2i(44, 13), "enter": 1176, "sag": 14},
	],
	# Lots: places that are not open yet (02 section 3.6). Each stands in its "before" state, solid, and reads a line;
	# it opens when "opens" holds, and only a lot with a "building" becomes one. No beat opens a lot yet.
	"lots": [
		{"id": "lot_a", "name": "Empty Stall", "base": Rect2i(36, 7, 4, 2), "door": Vector2i(37, 8), "class": "stall",
			"before": "tarp", "slot": "town.building.lot_before_stall", "opens": {"flag": "lot_a_open"},
			"what": "A tarp tied down over a bare counter. Nobody's set up here yet."},
		{"id": "lot_b", "name": "Empty Plot", "base": Rect2i(31, 14, 6, 4), "door": Vector2i(33, 14), "class": "stall",
			"before": "plot", "slot": "town.landmark.lot_before_plot", "opens": {"flag": "lot_b_open"},
			"what": "Stakes and a low fence round trampled earth. Something's meant to go up here."},
	],
	"exits": [
		{"id": "north_steps", "rect": Rect2i(46, 0, 2, 1), "to": "hall_rise", "at": "rise_steps", "facing": "n", "sfx": "stairs"},
		{"id": "south_steps", "rect": Rect2i(46, 18, 2, 1), "to": "ferry_ward", "at": "ferry_steps", "facing": "s", "sfx": "stairs"},
		{"id": "road_east", "rect": Rect2i(55, 11, 1, 2), "to": "east_quarter", "at": "quarter_road", "facing": "e", "sfx": "",
			"needs": "east_quarter_open", "name": "Road East",
			"shut": "Two posts and crossed planks across the road east. It's closed for now."},
	],
	"anchors": {
		"spawn": Vector2i(5, 9),           # under Home's door, the start of a day
		# Arriving down the steps from Tower Rise: four steps down, not on the top one (Claude, 2026-10-27, pass 9 T6 /
		# A9-08). On (46,1) the camera was already held at the map's top, so it could not lead lower, and the leader
		# stood under the "Next:" panel's end with its partner (screen y 2 to 104 and 92 to 185, the panel to 98).
		"street_north": Vector2i(46, 4),
		"street_south": Vector2i(46, 17),  # arriving up the switchbacks from the Ferry Ward
		"street_east": Vector2i(54, 11),    # arriving back from the East Quarter
		"home_walk": Vector2i(5, 10),       # two steps below Home's door (town_walk_check, hub_town_check)
		"yard_gate": Vector2i(24, 14),     # the Training Yard's gate
		"yard_gate_front": Vector2i(24, 13),
		"music_street": Vector2i(24, 12),   # music_check
		"view_street": Vector2i(24, 12),    # town_view_capture
	},
	"npcs": [],
}
