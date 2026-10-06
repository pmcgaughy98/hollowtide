extends SceneTree
func _initialize() -> void:
	var all := CreatureRoster.load_all()
	for c in all:
		print(c.dex_number, " ", c.creature_name, " ", c.essence_name(), " -> ", c.evolves_into.creature_name if c.evolves_into else "-", " back=", c.back_sprite != null)
	print("evolution problems: ", CreatureRoster.validate_evolutions(all))
	quit()
