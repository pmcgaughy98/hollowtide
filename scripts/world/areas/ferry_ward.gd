extends RefCounted
## The Old Ferry Ward, Highbank v2's way down (lane A, Claude, 2026-10-26; 02-town-rewire-design.md section 6.4, build
## plan 2.1). Working label. The switchbacks come down two cliffs from the street to the old ferry landing; the Mouth
## of the Hollow starts every run from here, and the dock looks out over the river. Storage keeps the team's things on
## the landing, so they drop what they don't need on the way to the Mouth (Preston, 2026-10-28).

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
		{"rect": Rect2i(14, 11, 6, 1), "kind": "lane"},      # from Storage's door east to the landing
	],
	"buildings": [
		# Storage, moved down from the Street (Preston, 2026-10-28: yes to "Storage to the Ferry Ward, by the Mouth"), so the
		# team drops things right before a run. On the landing at the foot of the switchbacks, its back to the lower cliff;
		# the Mouth is a short walk east. Still the template's shop box until the keeper-shaped buildings land (Pouchbill's
		# boathouse on stilts, TOWN_MAP.md).
		{"id": "storage", "name": "Storage", "service": "storage",
			"what": "Keeps items between runs. A run's bag is lost when the team goes down; storage is not.",
			"class": "shop", "base": Rect2i(12, 9, 6, 2), "door": [Vector2i(14, 10)], "roof": "hip", "wall": "stone",
			"windows": [5], "sign": {"col": 4, "icon": "crate"}, "room": "storage"},
	],
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
		# The wayline post at the end of the dock, where the quiet route's cable comes down (waylines below): dusty glass.
		{"slot": "town.prop.hall.wayline_post", "tile": Vector2i(33, 13), "solid": true, "state": "quiet"},
	],
	# Waylines (TOWER_DESIGN.md section 7; the format is street.gd's): the route that went quiet (route 5, its lantern
	# dusty and unlit on the deck) was the ferry's, so its line comes over the north edge, toward the Tower, and hangs
	# slack down to the pier post. Hollow shown as absence: a line that carries nothing.
	"waylines": [
		{"route": 5, "post": Vector2i(33, 13), "enter": 620, "sag": 30},
	],
	"lots": [],
	"exits": [
		{"id": "north_steps", "rect": Rect2i(6, 0, 2, 1), "to": "street", "at": "street_south", "facing": "n", "sfx": "stairs"},
	],
	"anchors": {
		# Arriving down the switchbacks from the street: at the foot of the upper steps, on the terrace lane (Claude,
		# 2026-10-27, pass 9 T6 / A9-08). On (6,1) the team stood under the place and "Next:" panels, and the camera, held
		# at the map's top and its west edge there, could not lead away from them.
		"ferry_steps": Vector2i(6, 4),
		"ferry_landing": Vector2i(22, 10),   # the landing's stand (hub_town_check)
		"mouth_approach": Vector2i(24, 10),  # one step west of the Mouth's door (hub_town_check, town_loop_check)
		"music_ferry": Vector2i(22, 11),     # music_check
		"view_terrace": Vector2i(12, 4),     # town_view_capture
		"view_landing": Vector2i(25, 11),
		"storage_front": Vector2i(14, 11),   # the step below Storage's door
	},
	"npcs": [],
}
