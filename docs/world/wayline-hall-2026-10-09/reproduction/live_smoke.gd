extends SceneTree
func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var path = "res://assets/sprites/world/wayline_hall_2026_10_09/wayline_hall_native.png"
	if not ResourceLoader.exists(path):
		push_error("Installed Hall asset is not imported")
		quit(1); return
	var art: Image = load(path).get_image()
	var town = load("res://scripts/town/hub_town.gd")
	var actual: Image = town.paint()
	var expected = Image.load_from_file("D:/dev/hollowtide-wayline-hall-20261009/review/town_after.png")
	var same = actual.get_data() == expected.get_data()
	print("LIVE_HALL_RESULT imported_native=", art.get_size() == Vector2i(240,144), " reviewed_map_exact=",same)
	quit(0 if same and art.get_size() == Vector2i(240,144) else 1)
