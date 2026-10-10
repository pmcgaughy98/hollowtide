extends SceneTree
const Layout = preload("res://scripts/town/town_layout.gd")
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	var before: Image = load("D:/dev/hollowtide-training-yard-20261010/baseline_hub.gd").paint()
	var after: Image = load("res://scripts/town/hub_town.gd").paint()
	var same := before.get_data() == after.get_data()
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	root.add_child(town)
	for k in 5: await process_frame
	var retained: bool = town._building_exteriors.buildings.size() == 6 and not town._building_exteriors.buildings.has("yard")
	town.team[0]["pos"] = Vector2i(41, 12)
	var used: bool = town.act_use().get("id", "") == "yard" and town.panel.get("service", "") == "arena"
	print("Fallback: exact original ground ", same, ", previous six exteriors ", retained, ", Yard service retained ", used)
	town.queue_free()
	for k in 4: await process_frame
	quit(0 if same and retained and used else 1)
