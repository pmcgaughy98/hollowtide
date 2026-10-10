extends SceneTree
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	var missing: bool = not load("res://scripts/town/building_exteriors.gd").available("scrolls")
	var expected: Image = load("D:/dev/hollowtide-selout-scroll-20261010/baseline_hub.gd").paint()
	var actual: Image = load("res://scripts/town/hub_town.gd").paint()
	var same := expected.get_data() == actual.get_data()
	var town = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await process_frame
	var others: bool = town._building_exteriors.buildings.size() == 5 and not town._building_exteriors.buildings.has("scrolls")
	town.team[0]["pos"] = Vector2i(33, 12)
	var usable: bool = town.act_use().get("id", "") == "scrolls" and town.panel.get("service", "") == "scrolls"
	print("Optional Scroll Keeper unavailable ",missing,", whole ground exact old picture ",same,", other exteriors retained ",others,", scroll service usable ",usable)
	town.queue_free()
	for k in 4: await process_frame
	quit(0 if missing and same and others and usable else 1)

