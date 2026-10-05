extends SceneTree

const Gate = preload("res://scripts/move_gate.gd")

## Confirms the learn gate against the live roster. One expected failure:
## Coalcrest still equips Plate Rake, and battle hides it.


func _initialize() -> void:
	var creatures := CreatureRoster.load_all()
	var problems := CreatureRoster.validate_move_gates(creatures)
	var cinder: CreatureData
	var iron: CreatureData
	var roar: MoveData
	var claw: MoveData
	for c in creatures:
		if c.creature_name == "Cinderhide":
			cinder = c
		elif c.creature_name == "Ironvent":
			iron = c
			for move in c.moves:
				if move.move_name == "Furnace Roar":
					roar = move
				elif move.move_name == "Cinder Claw":
					claw = move
	var checks: PackedStringArray = []
	if cinder == null or iron == null or roar == null or claw == null:
		checks.append("missing Cinderhide, Ironvent, Furnace Roar, or Cinder Claw")
	else:
		if Gate.can_learn(cinder, roar):
			checks.append("Cinderhide was allowed Furnace Roar")
		if not Gate.can_learn(iron, roar):
			checks.append("Ironvent was refused its own ultimate")
		if not Gate.can_learn(cinder, claw):
			checks.append("Cinderhide was refused Cinder Claw")
		if cinder.evolves_into == null or cinder.evolves_into.creature_name != "Clinkerhide":
			checks.append("Cinderhide does not evolve into Clinkerhide")
		elif cinder.evolves_into.evolves_into == null or cinder.evolves_into.evolves_into.creature_name != "Ironvent":
			checks.append("Clinkerhide does not evolve into Ironvent")
		elif cinder.evolves_into.evolves_into.evolves_into != null:
			checks.append("Ironvent still has a further evolution")
	var unexpected: PackedStringArray = []
	for problem in problems:
		if not problem.begins_with("Coalcrest equips Plate Rake"):
			unexpected.append(problem)
	if problems.size() != 1:
		checks.append("expected only Plate Rake, got %d" % problems.size())
	checks.append_array(unexpected)
	if checks.is_empty():
		print("GATE_OK")
		quit(0)
	else:
		for line in checks:
			push_error(line)
		quit(1)
