extends SceneTree
## Loads every creature file and prints the roster's own validation problems (Claude, 2026-10-08).
##   Godot --path . --headless --script res://tools/debug/roster_check.gd
func _initialize() -> void:
	var all: Array[CreatureData] = CreatureRoster.load_all()
	var problems: PackedStringArray = CreatureRoster.validate_evolutions(all)
	print("%d creatures; %d evolution problems%s" % [all.size(), problems.size(), (": " + ", ".join(problems)) if problems.size() > 0 else ""])
	for c in all:
		if c.id >= 2101 and c.id <= 2103:
			print("  %d %s essence %d front %s back %s evolves into %s" % [c.id, c.creature_name, c.essence, c.sprite.resource_path.get_file() if c.sprite else "none", c.back_sprite.resource_path.get_file() if c.back_sprite else "none", c.evolves_into.creature_name if c.evolves_into else "nothing"])
	quit()
