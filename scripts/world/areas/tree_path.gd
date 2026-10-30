extends RefCounted
## The Great Tree Path, Highbank v2's way into the forest round the great tree (Claude, 2026-10-28; Preston: "The Tower
## and tree will have their own areas while the tower is in a part of town not surrounded by buildings", then "Do a
## inside the forest map design"). Working label, Preston's to rename; the tree's own name is still open (great-tree
## memory). The design and its reasons: docs/design/town-map-2026-10-28/TOWN_MAP.md, "Inside the forest".
##
## In from Tower Rise on the east, the path winds under the trees: west, then north round a wall of trunks past the
## Canopy Gap, then west into the Shrine's clearing, where the canopy opens and the Growth Shrine stands (Preston moved it
## here the same day: growth beside the tree). Past the clearing the path climbs to the great root and follows it west
## to where it dives into the deep forest: the Root Path, shut, because the tree is a later dungeon with no area yet.
## The root runs the whole width along the north, stepping down as it goes; it leaves by the east edge toward the
## Tower it climbs.
##
## Placeholder ground: the root is a solid "terrace" strip and the deep forest is hedge until the landmark step gives
## them art slots; the trunks are town.prop.forest_trunk (a coded placeholder until its file is installed).

const AREA := {
	"id": "tree_path", "name": "Great Tree Path", "kind": "exterior", "size": Vector2i(40, 24),
	"card": "", "music": "highbank",
	"ground": {"base": "grass", "bands": [
		{"from": 0, "to": 1, "kind": "hedge"},     # the canopy wall to the north
		{"from": 2, "to": 21, "kind": "grass"},    # the forest floor
		{"from": 22, "to": 23, "kind": "hedge"},   # and to the south
	], "soft": [
		Rect2i(12, 9, 10, 7),    # the Shrine's clearing, where the canopy opens
		Rect2i(29, 10, 5, 3),    # the Canopy Gap
	],
	"rects": [
		{"rect": Rect2i(0, 2, 3, 4), "kind": "hedge"},     # the deep forest, west; the root dives into it here
		{"rect": Rect2i(0, 8, 3, 14), "kind": "hedge"},    #   and below the Root Path's opening (rows 6 and 7)
		{"rect": Rect2i(37, 4, 3, 10), "kind": "hedge"},   # the forest's east edge, either side of the way in
		{"rect": Rect2i(37, 17, 3, 5), "kind": "hedge"},
		# The great root, half buried, stepping down from the east edge (toward the Tower) to the deep forest in the west.
		# Nobody walks on it.
		{"rect": Rect2i(26, 2, 14, 2), "kind": "terrace", "solid": true},
		{"rect": Rect2i(12, 3, 14, 2), "kind": "terrace", "solid": true},
		{"rect": Rect2i(3, 4, 9, 2), "kind": "terrace", "solid": true},
	]},
	"paths": [
		{"rect": Rect2i(28, 15, 11, 2), "kind": "lane"},   # in from Tower Rise
		{"rect": Rect2i(27, 10, 2, 7), "kind": "lane"},    # north round the trunks, past the Canopy Gap
		{"rect": Rect2i(21, 10, 6, 2), "kind": "lane"},    # west into the Shrine's clearing
		{"rect": Rect2i(10, 8, 4, 2), "kind": "lane"},     # out of the clearing's north-west corner
		{"rect": Rect2i(9, 6, 2, 4), "kind": "lane"},      # up to the root
		{"rect": Rect2i(1, 6, 9, 2), "kind": "lane"},      # west under the root to where it dives in
	],
	"buildings": [],
	"places": [
		# Moved from Highbank Street (Preston, 2026-10-28: yes to "the Growth Shrine to the Great Tree Path"). Same rect size
		# as before, so its art and socket fit unchanged.
		{"id": "shrine", "name": "Growth Shrine", "kind": "area", "rect": Rect2i(14, 11, 6, 4), "door": Vector2i(16, 11),
			"service": "growth", "what": "Where a creature that is ready grows into its next form.",
			"anchors": {"socket": Vector2i(72, 64)}},   # px in the shrine's art (town.landmark.shrine): the stone goes here
		{"id": "canopy_gap", "name": "Canopy Gap", "kind": "area", "rect": Rect2i(29, 10, 5, 3), "door": Vector2i(30, 10),
			"service": "view", "what": "A gap in the leaves. Off to the north-west the great tree's crown fills half the sky."},
		# The way on to the great tree: shut until the tree is a place to go (a later dungeon, in scope order).
		# A spot read from the tile in front of it, as a shut exit's barrier is (the schema has no barrier place).
		{"id": "tree_way", "name": "Root Path", "kind": "spot", "rect": Rect2i(0, 6, 1, 2), "door": Vector2i(1, 6),
			"service": "closed", "what": "The root runs on into the deep woods, toward the great tree. There's no way through yet."},
	],
	"props": [
		{"slot": "town.lamp.post", "tile": Vector2i(36, 14), "solid": true, "light": true},   # the last lamp from town
		{"slot": "town.lamp.post", "tile": Vector2i(12, 15), "solid": true, "light": true},   # by the Shrine
		# Trunks, 2 x 1 tiles each: they wall the path so no screen shows both its ends.
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(14, 6), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(18, 6), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(22, 6), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(26, 7), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(31, 6), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(34, 8), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(31, 13), "size": Vector2i(2, 1), "solid": true},   # these two hide
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(34, 13), "size": Vector2i(2, 1), "solid": true},   #   the Gap
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(23, 13), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(24, 16), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(5, 10), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(8, 12), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(4, 14), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(4, 17), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(8, 18), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(13, 18), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(17, 18), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(21, 18), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(26, 19), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(30, 19), "size": Vector2i(2, 1), "solid": true},
		{"slot": "town.prop.forest_trunk", "tile": Vector2i(34, 19), "size": Vector2i(2, 1), "solid": true},
	],
	"waylines": [],
	"lots": [],
	"exits": [
		{"id": "east_path", "rect": Rect2i(39, 15, 1, 2), "to": "hall_rise", "at": "rise_west", "facing": "e", "sfx": ""},
	],
	"anchors": {
		"path_east": Vector2i(37, 15),      # arriving from Tower Rise
		"shrine_front": Vector2i(16, 10),   # the step before the Shrine
		"view_tree_path": Vector2i(24, 10), # on the way into the clearing
	},
	"npcs": [],
}
