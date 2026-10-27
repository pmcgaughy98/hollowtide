extends RefCounted
## Tower Rise, Highbank v2's high ground (lane A, Claude, 2026-10-26; 02-town-rewire-design.md section 6.3, build plan
## 2.1). Working label; the id stays "hall_rise" as every Hall id does (canon, Preston 2026-10-26: the Wayline Hall is
## now the Wayline Tower, player-facing only; place, room and flag ids keep "hall" so saves and checks keep working).
##
## The Wayline Tower stands here on the Hall's old base (12 x 3, the double door at (12,8) and (13,8)) and rises 576 px,
## about 2.7 screens, past the top of this area to a beacon (town.building.hall, lane B). "sky" is the room drawn above
## the area so a camera can pan up the Tower: the camera stays inside the area except while a scene lifts its clamp
## (hub_town.gd cam_lift; the Tower scene at its foot, lane S). The Job Board stands at the Tower's foot, where the
## Shortcut Crew wait on the first visit (board_scene.gd places them from the board's door), the well beside the steps
## (a prop only, Preston's call 7), and the steps down to the street.

const AREA := {
	"id": "hall_rise", "name": "Tower Rise", "kind": "exterior", "size": Vector2i(26, 14),
	"card": "", "music": "wayline_hall",
	"sky": 480,   # px of sky above row 0 for the pan up the Tower (its canvas top is at y -360, the beacon at -352)
	"ground": {"base": "grass", "bands": [
		{"from": 0, "to": 0, "kind": "hedge"},
		{"from": 1, "to": 12, "kind": "grass"},
		{"from": 13, "to": 13, "kind": "cliff"},   # the rise's edge; the steps cross it
	], "soft": [Rect2i(10, 9, 8, 4)]},
	"paths": [
		{"rect": Rect2i(12, 9, 2, 4), "kind": "steps"},   # from the Tower's doors down to the edge
		{"rect": Rect2i(14, 10, 2, 1), "kind": "lane"},   # across to the Job Board
	],
	"buildings": [
		{"id": "hall", "name": "Wayline Tower", "service": "guild", "what": "The Wayline's tower: jobs, the roster, reports.",
			"class": "hall", "base": Rect2i(7, 6, 12, 3), "door": [Vector2i(12, 8), Vector2i(13, 8)], "roof": "flat",
			"wall": "river_stone", "windows": [1, 10], "sign": {"col": 8, "icon": "waymark"}, "room": "hall"},
	],
	"places": [
		{"id": "board", "name": "Job Board", "kind": "spot", "rect": Rect2i(16, 9, 2, 1), "door": Vector2i(16, 10),
			"service": "jobs", "what": "Requests to take into the Hollows. Pick one, then go down to the ferry."},
	],
	"props": [
		{"slot": "town.lamp.post", "tile": Vector2i(11, 9), "solid": true, "light": true},
		{"slot": "town.lamp.post", "tile": Vector2i(14, 9), "solid": true, "light": true},
		{"slot": "town.prop.well", "tile": Vector2i(8, 10), "size": Vector2i(2, 2), "solid": true},
	],
	"lots": [],
	"exits": [
		{"id": "south_steps", "rect": Rect2i(12, 13, 2, 1), "to": "street", "at": "street_north", "facing": "s", "sfx": "stairs"},
	],
	"anchors": {
		"return": Vector2i(12, 9),         # back from a run: on the Tower's steps (RETURN_SPOT in v1)
		"rise_steps": Vector2i(12, 12),    # arriving up the steps from the street
		"tower_foot": Vector2i(13, 10),    # where the two stop at the Tower's foot (the Tower scene, lane S)
		"lane_walk": Vector2i(12, 11),     # three steps below the Tower's door (town_walk_check, hub_town_check)
		"board_start": Vector2i(16, 12),   # board_scene_check: walking up to the board from below
		"board_follow": Vector2i(17, 12),
	},
	"npcs": [],
}
