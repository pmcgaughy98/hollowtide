extends SceneTree
func _initialize() -> void:
	var town = load("res://scripts/town/hub_town.gd")
	var same = town.paint().get_data() == town.paint_blockout().get_data()
	print("FALLBACK_RESULT original blockout exact: ", same)
	quit(0 if same else 1)
