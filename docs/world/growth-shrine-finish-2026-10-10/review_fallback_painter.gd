extends SceneTree
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	var missing: bool = not load("res://scripts/town/building_exteriors.gd").available("shrine")
	var expected: Image = load("D:/dev/hollowtide-shrine-finish-20261010/baseline_hub.gd").paint()
	var actual: Image = load("res://scripts/town/hub_town.gd").paint()
	var same := expected.get_data() == actual.get_data()
	var town = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await process_frame
	var others: bool = town._building_exteriors.buildings.size() == 4 and not town._building_exteriors.buildings.has("shrine")
	town.team[0]["pos"] = Vector2i(7, 12)
	var usable: bool = town.act_use().get("id", "") == "shrine" and town.panel.get("service", "") == "growth"
	print("Optional shrine unavailable ",missing,", whole ground exact old picture ",same,", other exteriors retained ",others,", evolution service usable ",usable)
	town.queue_free()
	for k in 4: await process_frame
	quit(0 if missing and same and others and usable else 1)
