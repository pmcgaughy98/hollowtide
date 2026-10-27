extends RefCounted
## Today's Highbank as one area (lane A, Claude, 2026-10-26; placeholder factory build plan 2.1 step 1). The map moved
## here tile for tile from scripts/town/town_layout.gd (Claude, 2026-10-09), in the area format of
## docs/design/placeholder-factory-2026-10-26/02-town-rewire-design.md section 3.2. town_layout.gd keeps its API
## (T, W, H, BANDS, PATHS, PLACES, SPAWN, grid(), door_tiles(), place_at()) and reads its values from here, so with
## Highbank v2 off (the default) every tile, door and lane is as it was.
##
## This is the contract Codex paints to: positions, sizes, doors and jobs. Codex must not move a door or a path tile
## without telling Claude (the rules and the checks read them). Tiles are 24 px, the dungeon's size.

const AREA := {
	"id": "highbank_v1", "name": "Highbank", "kind": "exterior", "size": Vector2i(48, 32),
	"card": "HIGHBANK",
	"music": "",   # today's track goes by where the leader is (hub_town.gd music_track), not by area
	# Terrain bands, top to bottom: the bluff-top town, a cliff, a middle terrace, a cliff, the lower terrace at the
	# ferry, the river. "soft" is where the street's painter frays the lanes into the grass (highbank_painter.gd
	# SOFT_TILES: from the Hall's steps to the Crossroads).
	"ground": {"base": "grass", "bands": [
		{"from": 0, "to": 17, "kind": "grass"},     # the bluff top: Highbank's upper streets
		{"from": 18, "to": 18, "kind": "cliff"},
		{"from": 19, "to": 23, "kind": "terrace"},  # the switchbacks' middle terrace
		{"from": 24, "to": 24, "kind": "cliff"},
		{"from": 25, "to": 29, "kind": "terrace"},  # the Old Ferry Ward's landing
		{"from": 30, "to": 31, "kind": "water"},    # the river
	], "soft": [Rect2i(15, 7, 19, 5)]},
	# Paths (walkable, drawn as lanes). The two cliff crossings are the switchbacks.
	"paths": [
		{"rect": Rect2i(4, 9, 41, 2), "kind": "lane"},     # Market Street, west to east along the bluff
		{"rect": Rect2i(23, 7, 2, 2), "kind": "steps"},    # the hall's steps down to the street
		{"rect": Rect2i(23, 11, 2, 7), "kind": "lane"},    # the street south to the cliff edge (through the plaza)
		{"rect": Rect2i(23, 18, 2, 2), "kind": "steps"},   # switchback 1 through the upper cliff
		{"rect": Rect2i(14, 20, 11, 2), "kind": "lane"},   # along the middle terrace, west
		{"rect": Rect2i(14, 22, 2, 4), "kind": "steps"},   # switchback 2 through the lower cliff
		{"rect": Rect2i(14, 25, 18, 2), "kind": "lane"},   # along the landing, east
		{"rect": Rect2i(45, 9, 3, 2), "kind": "lane"},     # the road east (to the region; closed for now)
	],
	"buildings": [],   # today's buildings are "building" places below, drawn by building_exteriors.gd
	# Buildings: solid footprints; the door is the one walkable tile of the footprint, on its street side. Areas: open
	# walkable spaces with a spot to stand on. Every place has a service the rules use.
	"places": [
		# The hall's door is two tiles wide, to meet its two-tile steps (Preston, 2026-10-10: "the
		# wayline hall door needs widened to meet the path"). "door" stays the main tile; "door_tiles"
		# lists every walkable door tile of a place that has more than one.
		{"id": "hall", "name": "Wayline Tower", "kind": "building", "rect": Rect2i(19, 1, 10, 6), "door": Vector2i(24, 6), "door_tiles": [Vector2i(23, 6), Vector2i(24, 6)],
			"service": "guild", "what": "The Wayline's hall: jobs, the roster, reports."},
		{"id": "board", "name": "Job Board", "kind": "spot", "rect": Rect2i(26, 7, 2, 1), "door": Vector2i(26, 8),
			"service": "jobs", "what": "Requests to take into the Hollows. Pick one, then go down to the ferry."},
		{"id": "lookout", "name": "Bluff Lookout", "kind": "area", "rect": Rect2i(10, 2, 6, 4), "door": Vector2i(13, 5),
			"service": "view", "what": "Where the river looks close. On a clear day you can see the next bend."},
		{"id": "home", "name": "Home", "kind": "building", "rect": Rect2i(3, 3, 5, 5), "door": Vector2i(5, 7),
			"service": "home", "what": "The team's place to sleep and save. The day starts here."},
		{"id": "shop", "name": "Item Shop", "kind": "building", "rect": Rect2i(31, 3, 6, 5), "door": Vector2i(33, 7),
			"service": "shop", "what": "Berries, lamp oil, stones: what a run needs."},
		{"id": "storage", "name": "Storage", "kind": "building", "rect": Rect2i(38, 3, 6, 5), "door": Vector2i(40, 7),
			"service": "storage", "what": "Keeps items between runs. A run's bag is lost when the team goes down; storage is not."},
		{"id": "scrolls", "name": "Scroll Keeper", "kind": "building", "rect": Rect2i(31, 12, 6, 5), "door": Vector2i(33, 12),
			"service": "scrolls", "what": "Move scrolls: teaches a shared signature to a body that has the parts, and remembers forgotten moves."},
		{"id": "yard", "name": "Training Yard", "kind": "area", "rect": Rect2i(38, 12, 7, 5), "door": Vector2i(41, 12),
			"service": "arena", "what": "The arena side mode as the town's dojo: real-time spars and practice."},
		{"id": "shrine", "name": "Growth Shrine", "kind": "area", "rect": Rect2i(4, 12, 6, 5), "door": Vector2i(7, 12),
			"service": "growth", "what": "Where a creature that is ready grows into its next form."},
		{"id": "plaza", "name": "Crossroads", "kind": "area", "rect": Rect2i(18, 11, 12, 6), "door": Vector2i(24, 14),
			"service": "waymark", "what": "The town's centre: the waymark points to every place."},
		{"id": "landing", "name": "Old Ferry Landing", "kind": "area", "rect": Rect2i(26, 26, 12, 4), "door": Vector2i(28, 27),
			"service": "landing", "what": "The old crossing, where the first Hollowtide reports came from."},
		{"id": "gate", "name": "Mouth of the Hollow", "kind": "spot", "rect": Rect2i(33, 27, 2, 2), "door": Vector2i(33, 28),
			"service": "dungeon", "what": "The way into the Hollow. Step in to start a run."},
		{"id": "dock", "name": "Ferry Dock", "kind": "area", "rect": Rect2i(38, 28, 6, 2), "door": Vector2i(39, 28),
			"service": "view", "what": "Planks over the water. No ferry has run since the flood."},
	],
	"props": [],   # today's lamps and posts are painted by the ground painters
	"lots": [],
	"exits": [],   # one area: no exits (the road east is a lane to the map's edge)
	# Named tiles the checks and scenes stand on (each measured from the check or scene that used the bare tile,
	# Claude, 2026-10-26). Highbank v2 gives every name a tile in one of its areas.
	"anchors": {
		"spawn": Vector2i(5, 8),            # outside Home's door, the start of a day (SPAWN)
		"return": Vector2i(24, 8),          # back from a run: on the Hall's steps (hub_town.gd RETURN_SPOT)
		"ferry_landing": Vector2i(28, 27),  # the landing the switchbacks lead down to (hub_town_check FERRY)
		"mouth_approach": Vector2i(32, 28), # one step west of the Mouth's door (hub_town_check, town_loop_check)
		"lane_walk": Vector2i(24, 9),       # below the Hall's steps (town_walk_check, hub_town_check)
		"home_walk": Vector2i(5, 9),        # below Home's door (town_walk_check, hub_town_check)
		"yard_gate": Vector2i(41, 12),      # the Training Yard's gate (town_walk_check)
		"yard_gate_front": Vector2i(41, 11),# the tile north of it
		"music_street": Vector2i(24, 9),    # music_check: by the Hall
		"music_ferry": Vector2i(26, 27),    # music_check: on the ferry landing
		"board_start": Vector2i(26, 14),    # board_scene_check: six tiles below the board's door
		"board_follow": Vector2i(26, 15),   # and the partner one behind
		"view_street": Vector2i(24, 10),    # town_view_capture
		"view_terrace": Vector2i(20, 21),
		"view_landing": Vector2i(32, 26),
	},
	"npcs": [],
}
