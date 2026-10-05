class_name MoveGate
extends RefCounted

## Whether this body may use this move. An ultimate (MoveData.signature) stays
## on the form that equips it. Any other move is legal when every required
## part is present. A move with no required parts is legal for every body.


static func can_learn(creature: CreatureData, move: MoveData) -> bool:
	if creature == null or move == null:
		return false
	if move.signature and not creature.moves.has(move):
		return false
	for part in move.required_parts:
		if not creature.body_parts.has(part):
			return false
	return true


## The form's own moves that this body can actually use, in list order, four at most.
static func legal_kit(creature: CreatureData) -> Array[MoveData]:
	var kit: Array[MoveData] = []
	if creature == null:
		return kit
	for move in creature.moves:
		if kit.size() >= 4:
			break
		if can_learn(creature, move):
			kit.append(move)
	return kit
