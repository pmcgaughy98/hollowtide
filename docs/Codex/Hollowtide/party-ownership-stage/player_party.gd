extends Node

## Run-local ownership. Each slot is one creature, even when two slots share
## the same CreatureData species file. The first slot is the active partner
## until a party-selection screen exists. Nothing is saved to disk yet.
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


func active_creature() -> CreatureData:
	if active_slot < 0 or active_slot >= caught.size():
		return null
	return caught[active_slot].species


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
func evolve_active(expected: CreatureData, next: CreatureData) -> bool:
	if next == null or active_creature() != expected:
		return false
	caught[active_slot].species = next
	party_changed.emit()
	return true


func count_of(creature: CreatureData) -> int:
	var n := 0
	for member in caught:
		if member.species == creature:
			n += 1
	return n
