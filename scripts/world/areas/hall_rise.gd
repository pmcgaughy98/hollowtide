extends RefCounted
## Tower Rise, Highbank v2's high ground (lane A, Claude, 2026-10-26; 02-town-rewire-design.md section 6.3, build plan
## 2.1). Working label; the id stays "hall_rise" as every Hall id does (canon, Preston 2026-10-26: the Wayline Hall is
## now the Wayline Tower, player-facing only; place, room and flag ids keep "hall" so saves and checks keep working).
##
## The climb to the doors (Claude, 2026-10-29; docs/design/vast-scale-2026-10-27/RISE_CLIMB_SLICE.md, slice 1, a
## proposal in working labels). On the 10-28 door mock Preston said "thats the old tower"; asked how to reach the doors
## he chose "Climb the stair": the true scale of the new Tower (VAST_SCALE_DESIGN.md, "Numbers"), its two plinth steps
## 8 tiles tall each, with the doors at the Stack's foot on row 0. Every band is wider than the Rise, so each face
## spans the whole width. Top to bottom:
##   above 0   the Stack's face, pale stone with brass rings, off the top (painted by scripts/town/tower_foot.gd)
##   0         the Stack's foot: the "hall" building's base row, the double door at (12,0) and (13,0)
##   1 to 4    the door landing on step 2, a brass rail along its south edge
##   5 to 12   step 2's face, river-stone courses, the stair at cols 12 and 13
##   13 to 17  the terrace on step 1, its rail on the south edge
##   18 to 25  step 1's face, the stair at cols 12 and 13
##   26 to 30  the Rise's foot (the old rows 9 to 13 moved down 17): lamps, Job Board, well, posts, the lane west, the
##             steps down to the Street
## The great tree's root comes in from the west along the lane on row 29, half buried, with treads cut into it, and
## climbs step 1, the terrace, step 2 and the Stack's west side in cols 0 to 4, solid scenery.
##
## The faces are solid "cliff" ground and the stair is two "steps" paths. The building template places the coded foot
## (TowerFoot) for the "hall" entry instead of the old 30-tile tower (TowerParts), which the Tower scene
## (scripts/story/tower_reveal.gd) still stands on the doors for its climb until slice 2 retimes it.
##
## "sky" is the room drawn above the area so a camera can pan up the Tower: the camera stays inside the area except while
## a scene lifts its clamp (hub_town.gd cam_lift; the Tower scene). 720 clears the old tower the scene still climbs:
## its frame stands on the door sill (y 24), so its top is at -696 and the scene's top hold at -705. "headroom" is how
## much of the Stack the camera may show above row 0 in normal play, so the 64 px doors over row 0's sill always show
## whole; the look-up ("lean", hub_town.gd _lean_rise) rises CAMERA_LEAN px more into the Stack. The Job Board stands at
## the plinth's foot, where the Shortcut Crew wait on the first visit (board_scene.gd places them from the board's
## door), the well beside the steps (a prop only, Preston's call 7), and the steps down to the street.
##
## The four waylines that hung from the old tower's Reel Deck are left off for slice 1: the Low Reel is now about 34
## tiles up the Stack, off the top of every view here, and the slice plan leaves the choice open. The two posts stand
## at the foot unstrung.

const AREA := {
	"id": "hall_rise", "name": "Tower Rise", "kind": "exterior", "size": Vector2i(26, 31),
	"card": "", "music": "wayline_hall",
	"sky": 720,       # px of sky above row 0 for the Tower scene's pan up the old tower it still stands on the doors
	"headroom": 72,   # px of the Stack's foot the camera shows above row 0 in normal play (hub_town.gd _process)
	"ground": {"base": "grass", "bands": [
		{"from": 0, "to": 0, "kind": "cliff"},       # the Stack's foot; the doors open in it
		{"from": 1, "to": 4, "kind": "terrace"},     # the door landing
		{"from": 5, "to": 12, "kind": "cliff"},      # step 2's face
		{"from": 13, "to": 17, "kind": "terrace"},   # the terrace on step 1
		{"from": 18, "to": 25, "kind": "cliff"},     # step 1's face
		{"from": 26, "to": 29, "kind": "grass"},     # the Rise's foot
		{"from": 30, "to": 30, "kind": "cliff"},     # the rise's edge; the steps cross it
	], "soft": [Rect2i(10, 26, 8, 4)],
	# The great tree's root where it lies on the flat: across the landing and the terrace, and its heave at the foot
	# where it turns up the plinth (it lies along the lane on row 29 below that, walked over). Painted by TowerFoot.
	"rects": [
		{"rect": Rect2i(0, 1, 5, 4), "kind": "terrace", "solid": true},
		{"rect": Rect2i(0, 13, 5, 5), "kind": "terrace", "solid": true},
		{"rect": Rect2i(0, 26, 4, 2), "kind": "grass", "solid": true},
	]},
	"paths": [
		# From the plinth's foot down to the edge. "art": the painted rise stair (town.prop.hall.rise_stair, 48 x 96)
		# lies over these coded steps, flat under everyone; a prop cannot, as the steps are the stair's approach.
		{"rect": Rect2i(12, 26, 2, 4), "kind": "steps", "art": "town.prop.hall.rise_stair"},
		{"rect": Rect2i(12, 18, 2, 8), "kind": "steps"},   # up step 1's face to the terrace (TowerFoot paints it)
		{"rect": Rect2i(12, 5, 2, 8), "kind": "steps"},    # up step 2's face to the door landing
		{"rect": Rect2i(14, 27, 2, 1), "kind": "lane"},    # across to the Job Board
		# West along the rise's foot to the Great Tree Path, the way the great root came (Claude, 2026-10-28; Preston:
		# "The Tower and tree will have their own areas"). The Tower keeps open ground round it: no building is added here.
		{"rect": Rect2i(0, 29, 12, 1), "kind": "lane"},
	],
	"buildings": [
		# The Stack's foot. The base is one row deep: everything above it is the Stack, off the area's top.
		{"id": "hall", "name": "Wayline Tower", "service": "guild", "what": "The Wayline's tower: jobs, the roster, reports.",
			"class": "hall", "base": Rect2i(7, 0, 12, 1), "door": [Vector2i(12, 0), Vector2i(13, 0)], "roof": "flat",
			"wall": "river_stone", "windows": [1, 10], "sign": {"col": 8, "icon": "waymark"}, "room": "hall",
			"tower": "foot"},   # the building template stands the new Tower's coded foot here (scripts/town/tower_foot.gd)
	],
	"places": [
		{"id": "board", "name": "Job Board", "kind": "spot", "rect": Rect2i(16, 26, 2, 1), "door": Vector2i(16, 27),
			"service": "jobs", "what": "Requests to take into the Hollows. Pick one, then go down to the ferry."},
	],
	"props": [
		{"slot": "town.lamp.post", "tile": Vector2i(11, 26), "solid": true, "light": true},
		{"slot": "town.lamp.post", "tile": Vector2i(14, 26), "solid": true, "light": true},
		{"slot": "town.prop.well", "tile": Vector2i(8, 27), "size": Vector2i(2, 2), "solid": true},
		# The two wayline posts at the foot. The west one moved from col 2 to col 5, off the root's heave. Their states
		# still follow their routes' lanterns (TowerParts.LANTERN_STATES); no line is hung on the Rise in slice 1.
		{"slot": "town.prop.hall.wayline_post", "tile": Vector2i(5, 27), "solid": true, "state": "waiting"},
		{"slot": "town.prop.hall.wayline_post", "tile": Vector2i(24, 27), "solid": true, "state": "strung"},
	],
	"lots": [],
	"exits": [
		{"id": "south_steps", "rect": Rect2i(12, 30, 2, 1), "to": "street", "at": "street_north", "facing": "s", "sfx": "stairs"},
		{"id": "west_path", "rect": Rect2i(0, 28, 1, 2), "to": "tree_path", "at": "path_east", "facing": "w", "sfx": ""},
	],
	"anchors": {
		"return": Vector2i(12, 1),         # back from a run: on the landing under the doors (RETURN_SPOT in v1)
		"rise_steps": Vector2i(12, 29),    # arriving up the steps from the street
		"rise_west": Vector2i(1, 29),      # arriving from the Great Tree Path, on the root's back
		"tower_foot": Vector2i(13, 27),    # at the stair's foot, where the two first look up
		"lane_walk": Vector2i(12, 3),      # three steps below the Tower's door (town_walk_check, hub_town_check)
		"board_start": Vector2i(16, 29),   # board_scene_check: walking up to the board from below
		"board_follow": Vector2i(17, 29),
	},
	# The camera's look-up at the doors (TOWER_DESIGN.md section 7, Preston's default yes): standing in this box on the
	# landing facing one of these ways, the view eases up to TowerParts.CAMERA_LEAN px more of the Stack
	# (hub_town.gd _lean_rise; tower_lean_check).
	"lean": {"rect": Rect2i(11, 1, 4, 4), "facing": ["n"]},
	"npcs": [],
}
