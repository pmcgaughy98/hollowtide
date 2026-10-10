extends SceneTree
func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var path = "res://assets/sprites/world/item_shop_2026_10_09/item_shop_native.png"
	if not ResourceLoader.exists(path):
		push_error("Installed Item Shop asset is not imported")
		quit(1); return
	var art: Image = load(path).get_image()
	var town = load("res://scripts/town/hub_town.gd")
	var actual: Image = town.paint()
	var expected = Image.load_from_file("D:/dev/hollowtide-shop-20261009/review/town_after.png")
	var same = actual.get_data() == expected.get_data()
	print("LIVE_SHOP_RESULT imported_native=", art.get_size() == Vector2i(144,120), " reviewed_map_exact=",same)
	quit(0 if same and art.get_size() == Vector2i(144,120) else 1)
