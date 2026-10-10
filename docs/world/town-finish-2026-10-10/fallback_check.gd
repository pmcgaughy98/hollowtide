extends SceneTree
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var expected: Image = load("D:/dev/hollowtide-town-finish-20261010/baseline_hub.gd").paint()
	var actual: Image = load("res://scripts/town/hub_town.gd").paint()
	var same := expected.get_data() == actual.get_data()
	var town = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await process_frame
	var absent := not is_instance_valid(town._building_exteriors)
	town.team[0]["pos"] = town.Layout.SPAWN
	town.team[0]["facing"] = "n"
	var usable: bool = town.act_use().get("id", "") == "home"
	print("Fallback: original whole-map pixels ",same,", missing module clean ",absent,", Home usable ",usable)
	town.queue_free()
	await process_frame
	await process_frame
	quit(0 if same and absent and usable else 1)
