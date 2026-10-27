extends RefCounted
## The East Quarter, Highbank v2's first room to grow (lane A, Claude, 2026-10-26; build plan 2.1 step 5). Working
## label. Behind the road east: three empty lots, lamps and fences, and nothing else yet: no services, townsfolk or
## story (Preston's call 6, the default: empty and closed). The street's road east needs the story flag
## "east_quarter_open", which nothing sets, so only scenes/debug/highbank_v2.tscn (which opens every exit) and the
## checks reach it. It shows how the base grows: a new quarter is one file like this, an exit each way and an index line.

const AREA := {
	"id": "east_quarter", "name": "East Quarter", "kind": "exterior", "size": Vector2i(30, 14),
	"card": "", "music": "highbank",
	"ground": {"base": "grass", "bands": [
		{"from": 0, "to": 0, "kind": "hedge"},
		{"from": 1, "to": 13, "kind": "grass"},
	], "soft": []},
	"paths": [
		{"rect": Rect2i(0, 8, 29, 2), "kind": "lane"},   # the road in from the street
		{"rect": Rect2i(4, 7, 1, 1), "kind": "lane"},    # worn steps to the lots' fronts
		{"rect": Rect2i(12, 7, 1, 1), "kind": "lane"},
	],
	"buildings": [],
	"places": [],
	"props": [
		{"slot": "town.lamp.post", "tile": Vector2i(9, 7), "solid": true, "light": true},
		{"slot": "town.lamp.post", "tile": Vector2i(16, 7), "solid": true, "light": true},
		{"slot": "town.lamp.post", "tile": Vector2i(24, 7), "solid": true, "light": true},
		{"slot": "town.prop.fence_h", "tile": Vector2i(0, 13), "solid": true},
		{"slot": "town.prop.fence_h", "tile": Vector2i(1, 13), "solid": true},
		{"slot": "town.prop.fence_h", "tile": Vector2i(2, 13), "solid": true},
		{"slot": "town.prop.fence_h", "tile": Vector2i(3, 13), "solid": true},
		{"slot": "town.prop.fence_h", "tile": Vector2i(4, 13), "solid": true},
		{"slot": "town.prop.fence_h", "tile": Vector2i(5, 13), "solid": true},
		{"slot": "town.prop.fence_corner", "tile": Vector2i(6, 13), "solid": true},
		{"slot": "town.prop.fence_corner", "tile": Vector2i(24, 13), "solid": true},
		{"slot": "town.prop.fence_h", "tile": Vector2i(25, 13), "solid": true},
		{"slot": "town.prop.fence_h", "tile": Vector2i(26, 13), "solid": true},
		{"slot": "town.prop.fence_h", "tile": Vector2i(27, 13), "solid": true},
		{"slot": "town.prop.fence_h", "tile": Vector2i(28, 13), "solid": true},
		{"slot": "town.prop.fence_h", "tile": Vector2i(29, 13), "solid": true},
		{"slot": "town.prop.fence_v", "tile": Vector2i(29, 10), "solid": true},
		{"slot": "town.prop.fence_v", "tile": Vector2i(29, 11), "solid": true},
		{"slot": "town.prop.fence_v", "tile": Vector2i(29, 12), "solid": true},
	],
	"lots": [
		{"id": "lot_c", "name": "Shuttered Shop", "base": Rect2i(2, 5, 6, 2), "door": Vector2i(4, 6), "class": "shop",
			"before": "shop", "slot": "town.building.lot_before_shop", "opens": {"flag": "lot_c_open"},
			"what": "Plain boards over the door and the windows. Nobody's moved in yet."},
		{"id": "lot_d", "name": "Empty Stall", "base": Rect2i(11, 5, 4, 2), "door": Vector2i(12, 6), "class": "stall",
			"before": "tarp", "slot": "town.building.lot_before_stall", "opens": {"flag": "lot_d_open"},
			"what": "A tarp tied down over a bare counter. Nobody's set up here yet."},
		{"id": "lot_e", "name": "Empty Plot", "base": Rect2i(10, 10, 6, 4), "door": Vector2i(12, 10), "class": "stall",
			"before": "plot", "slot": "town.landmark.lot_before_plot", "opens": {"flag": "lot_e_open"},
			"what": "Stakes and a low fence round trampled earth. Something's meant to go up here."},
	],
	"exits": [
		{"id": "west_road", "rect": Rect2i(0, 8, 1, 2), "to": "street", "at": "street_east", "facing": "w", "sfx": ""},
	],
	"anchors": {
		"quarter_road": Vector2i(1, 8),   # arriving along the road from the street
	},
	"npcs": [],
}
