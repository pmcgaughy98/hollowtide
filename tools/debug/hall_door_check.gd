extends SceneTree
## The Wayline Hall's door is two tiles wide and meets its two-tile steps (Claude, 2026-10-10).
## Both door tiles are walkable, both answer E as the hall, and both lead straight onto the steps.
## Claude, 2026-10-26 (placeholder factory lane B): the Hall is now the Wayline Tower (place id "hall" unchanged). The
## Tower keeps the Hall's doors: its template double door is two tiles wide, over the place's two door tiles, so the
## rooms, checks and saves that reach the hall are unchanged. With Highbank v2 on, the Tower is read from its area
## (Tower Rise, doors (12, 8) and (13, 8)) and must sit on a 12 x 3 base with its doors in base columns 5 and 6.
##   Godot --headless --path . --script res://tools/debug/hall_door_check.gd
const Layout := preload("res://scripts/town/town_layout.gd")
const BT := preload("res://scripts/town/building_template.gd")

func _initialize() -> void:
	var bad := 0
	var hall: Dictionary = BT.place_entry("hall")
	if hall.is_empty():
		print("no place 'hall' in any area -> WRONG")
		print("RESULT: 1 problems")
		quit()
		return
	var tiles: Array = Layout.door_tiles(hall)
	if not Layout.v2():
		var g := Layout.grid()
		for d in tiles:
			var open: bool = g[d.y * Layout.W + d.x] == Layout.OPEN
			var below: bool = g[(d.y + 1) * Layout.W + d.x] == Layout.OPEN
			var answers: bool = Layout.place_at(d).get("id", "") == "hall"
			print("door tile %s: walkable %s, the step below walkable %s, answers as the hall %s" % [d, open, below, answers])
			bad += 0 if open and below and answers else 1
	print("door tiles %d, steps 2 wide -> %s" % [tiles.size(), "ok" if tiles.size() == 2 else "WRONG"])
	bad += 0 if tiles.size() == 2 else 1
	# The Tower's double door spans exactly those two tiles.
	var cls: Dictionary = BT.CLASSES[BT.TOWER_CLASS]
	var door := BT.door_px(BT.TOWER_CLASS)
	var spans: bool = int(cls["door_tiles"]) == tiles.size() and door.size.x == tiles.size() * BT.T and door.position.x == BT.EAVE + int(cls["door_col"]) * BT.T
	print("the Tower's door %s spans %d door tiles from base column %d -> %s" % [door, int(cls["door_tiles"]), int(cls["door_col"]), "ok" if spans else "WRONG"])
	bad += 0 if spans else 1
	if Layout.v2():
		var base: Rect2i = hall.get("rect", Rect2i())
		var cols: Array = []
		var on_row := true
		for d in tiles:
			cols.append(d.x - base.position.x)
			on_row = on_row and d.y == base.end.y - 1
		var fits: bool = base.size == cls["base"] and on_row and cols == BT.TOWER_DOOR_COLS
		print("v2: the Tower in %s on base %s, door tiles %s in base columns %s on its last row -> %s" % [Layout.area_of("hall"), base, tiles, cols, "ok" if fits else "WRONG"])
		bad += 0 if fits else 1
	print("RESULT: %s" % ("the hall door meets the steps" if bad == 0 else "%d problems" % bad))
	quit()
