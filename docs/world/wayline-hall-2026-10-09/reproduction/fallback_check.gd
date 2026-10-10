extends SceneTree
func _initialize() -> void:
	var town = load("res://scripts/town/hub_town.gd")
	var old = load("res://tools/debug/hall_ground_before.gd").paint(town.paint_blockout())
	var same = old.get_data() == town.paint().get_data()
	print("HALL_FALLBACK_RESULT previous ground/blockout exact: ",same)
	quit(0 if same else 1)
