extends SceneTree
## Prints each starter line's essences and how a few attack essences score
## against them, to check the two-essence rule. Usage: Godot --headless --path . --script res://tools/debug/dual_essence_check.gd
func _initialize() -> void:
	var E := CreatureData.Essence
	for f in ["001_rimefin", "502_riftfin", "002_cinderhide", "102_ironvent", "1701_tallowroot"]:
		var c: CreatureData = load("res://data/creatures/" + f + ".tres")
		var row := []
		for a in [E.EMBER, E.TIDE, E.STONE, E.BLOOM, E.HOLLOW, E.ELECTRIC]:
			row.append("%s x%s" % [String(E.keys()[a]).capitalize(), EssenceChart.against(a, c)])
		print(c.creature_name, " (", c.essence_name(), "): ", ", ".join(row))
	quit()
