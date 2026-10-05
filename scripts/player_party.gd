extends Node

const Gate = preload("res://scripts/move_gate.gd")

## Run-local ownership. Each slot is one creature, even when two slots share
## the same CreatureData species file. The active slot is chosen outside battle.
## Nothing is saved to disk yet.
signal party_changed

const MAX_PARTY := 6

var caught: Array[PartyMember] = []
var active_slot := -1


func is_full() -> bool:
	return caught.size() >= MAX_PARTY


## The scene's exported creature is a fallback for a fresh game only.
## A starter occupies one of the six party slots.
func ensure_starter(starter: CreatureData) -> void:
	if caught.is_empty():
		add(starter)
	elif active_slot < 0 or active_slot >= caught.size():
		active_slot = 0
		party_changed.emit()


func active_member() -> PartyMember:
	if active_slot < 0 or active_slot >= caught.size():
		return null
	return caught[active_slot]


func active_creature() -> CreatureData:
	var member := active_member()
	if member == null:
		return null
	return member.species


## Chooses which owned creature enters the next battle.
func select(slot: int) -> bool:
	if slot < 0 or slot >= caught.size():
		return false
	if active_slot != slot:
		active_slot = slot
		party_changed.emit()
	return true


## Adds a distinct owned creature. Returns false if the party is full.
func add(creature: CreatureData) -> bool:
	if creature == null or is_full():
		return false
	caught.append(PartyMember.new(creature))
	if active_slot == -1:
		active_slot = 0
	party_changed.emit()
	return true


## Evolves only the selected individual, not the first matching species.
## One stage. The new form's own legal moves replace what this one knew.
func evolve_active(expected: CreatureData, next: CreatureData) -> bool:
	if next == null or active_creature() != expected:
		return false
	if expected.evolves_into != next:
		return false
	var member := caught[active_slot]
	member.species = next
	member.known = Gate.legal_kit(next)
	party_changed.emit()
	return true


## Teaches a signature to the active creature. Fails when the body lacks a
## part, when the move is an ultimate, or when four moves are already known.
## There is no teach screen yet. Evolution does not call this.
func try_learn(move: MoveData) -> bool:
	var member := active_member()
	if member == null or not Gate.can_learn(member.species, move):
		return false
	if member.known.is_empty():
		member.known = Gate.legal_kit(member.species)
	if member.known.has(move):
		return true
	if member.known.size() >= 4:
		return false
	member.known.append(move)
	party_changed.emit()
	return true


func count_of(creature: CreatureData) -> int:
	var n := 0
	for member in caught:
		if member.species == creature:
			n += 1
	return n
