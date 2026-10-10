extends SceneTree
## The Wayline Hall's door is two tiles wide and meets its two-tile steps (Claude, 2026-10-10).
## Both door tiles are walkable, both answer E as the hall, and both lead straight onto the steps.
##   Godot --headless --path . --script res://tools/debug/hall_door_check.gd
const Layout := preload("res://scripts/town/town_layout.gd")

func _initialize() -> void:
	var g := Layout.grid()
	var hall: Dictionary = Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "hall")[0]
	var bad := 0
	for d in Layout.door_tiles(hall):
		var open: bool = g[d.y * Layout.W + d.x] == Layout.OPEN
		var below: bool = g[(d.y + 1) * Layout.W + d.x] == Layout.OPEN
		var answers: bool = Layout.place_at(d).get("id", "") == "hall"
		print("door tile %s: walkable %s, the step below walkable %s, answers as the hall %s" % [d, open, below, answers])
		bad += 0 if open and below and answers else 1
	print("door tiles %d, steps 2 wide -> %s" % [Layout.door_tiles(hall).size(), "ok" if Layout.door_tiles(hall).size() == 2 else "WRONG"])
	bad += 0 if Layout.door_tiles(hall).size() == 2 else 1
	print("RESULT: %s" % ("the hall door meets the steps" if bad == 0 else "%d problems" % bad))
	quit()
