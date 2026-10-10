extends SceneTree
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	var missing := not ResourceLoader.exists("res://assets/sprites/world/wayline_hall_2026_10_10/wayline_hall_native.png")
	var expected: Image = load("D:/dev/hollowtide-hall-finish-20261010/baseline_hub.gd").paint()
	var actual: Image = load("res://scripts/town/hub_town.gd").paint()
	var same := expected.get_data() == actual.get_data()
	var town = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await process_frame
	var pair: bool = town._building_exteriors.buildings.size() == 2 and not town._building_exteriors.buildings.has("hall")
	var usable := true
	for x in [23, 24]:
		town.panel = {}
		town.team[0]["pos"] = Vector2i(x, 6)
		usable = usable and town.act_use().get("id", "") == "hall"
	print("Missing new Hall source ",missing,", exact historical Hall / other ground ",same,", finished pair retained ",pair,", both guild tiles usable ",usable)
	town.queue_free()
	for k in 4: await process_frame
	quit(0 if missing and same and pair and usable else 1)
