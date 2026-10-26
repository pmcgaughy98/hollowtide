extends "res://scripts/creature_opening.gd"
## Private behavioural fixture: count the existing launch hook without replacing a scene or a save.
var launch_count := 0
func _begin_journey() -> void:
	launch_count += 1
	_leaving = true
