extends RefCounted
## The Old Ferry Ward, Highbank v2's way down (lane A, Claude, 2026-10-26; 02-town-rewire-design.md section 6.4, build
## plan 2.1). Working label. The switchbacks come down two cliffs from the street to the old ferry landing; the Mouth
## of the Hollow starts every run from here, and the dock looks out over the river.

const AREA := {
	"id": "ferry_ward", "name": "Old Ferry Ward", "kind": "exterior", "size": Vector2i(34, 16),
	"card": "", "music": "ferry_landing",
	"ground": {"base": "terrace", "bands": [
		{"from": 0, "to": 1, "kind": "grass"},     # the foot of the bluff top, under the street
		{"from": 2, "to": 2, "kind": "cliff"},     # the upper cliff
		{"from": 3, "to": 6, "kind": "terrace"},   # the switchbacks' middle terrace
		{"from": 7, "to": 7, "kind": "cliff"},     # the lower cliff
		{"from": 8, "to": 12, "kind": "terrace"},  # the landing
		{"from": 13, "to": 15, "kind": "water"},   # the river
	], "soft": [Rect2i(18, 8, 12, 5)]},
	"paths": [
		{"rect": Rect2i(6, 0, 2, 4), "kind": "steps"},       # down from the street through the upper cliff
		{"rect": Rect2i(6, 3, 16, 2), "kind": "lane"},       # east along the middle terrace
		{"rect": Rect2i(20, 3, 2, 6), "kind": "steps"},      # down through the lower cliff
		{"rect": Rect2i(20, 8, 9, 2), "kind": "lane"},       # along the landing to the Mouth
		{"rect": Rect2i(28, 12, 6, 2), "kind": "boardwalk"}, # the dock's planks over the water
	],
	"buildings": [],
	"places": [
		{"id": "landing", "name": "Old Ferry Landing", "kind": "area", "rect": Rect2i(18, 9, 12, 4), "door": Vector2i(22, 10),
			"service": "landing", "what": "The old crossing, where the first Hollowtide reports came from."},
		{"id": "gate", "name": "Mouth of the Hollow", "kind": "spot", "rect": Rect2i(25, 9, 2, 2), "door": Vector2i(25, 10),
			"service": "dungeon", "what": "The way into the Hollow. Step in to start a run."},
		{"id": "dock", "name": "Ferry Dock", "kind": "area", "rect": Rect2i(28, 12, 6, 2), "door": Vector2i(29, 12),
			"service": "view", "what": "Planks over the water. No ferry has run since the flood."},
	],
	"props": [
		{"slot": "town.lamp.post", "tile": Vector2i(19, 8), "solid": true, "light": true},
		{"slot": "town.prop.mooring_post", "tile": Vector2i(27, 12), "solid": true},
	],
	"lots": [],
	"exits": [
		{"id": "north_steps", "rect": Rect2i(6, 0, 2, 1), "to": "street", "at": "street_south", "facing": "n", "sfx": "stairs"},
	],
	"anchors": {
		"ferry_steps": Vector2i(6, 1),       # arriving down the switchbacks from the street
		"ferry_landing": Vector2i(22, 10),   # the landing's stand (hub_town_check)
		"mouth_approach": Vector2i(24, 10),  # one step west of the Mouth's door (hub_town_check, town_loop_check)
		"music_ferry": Vector2i(22, 11),     # music_check
		"view_terrace": Vector2i(12, 4),     # town_view_capture
		"view_landing": Vector2i(25, 11),
	},
	"npcs": [],
}
