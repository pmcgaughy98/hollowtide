extends Node

## What the player has caught.
##
## Registered as an autoload called PlayerParty, which means any script can
## reach it by that name without anything passing a reference around. That is
## the Godot convention for a small piece of state the whole game shares, and
## it is why capture did not need plumbing through the player or the battle.
##
## This holds CreatureData files, not individual creatures. Catching two
## Cinderhides gives you two entries pointing at the same file. That is correct
## while nothing is per-creature: there are no nicknames, no levels, and no
## current HP carried between battles. The first time any of those exist, this
## becomes an array of small runtime objects that each point at a CreatureData,
## and that is the moment to change it, not before.
##
## Nothing here is saved to disk. Close the game and the party is gone. Saving
## is its own step.

signal party_changed

## Six is the genre standard and it gives capture a reason to ever say no.
const MAX_PARTY := 6

var caught: Array[CreatureData] = []


func is_full() -> bool:
	return caught.size() >= MAX_PARTY


## Adds a creature. Returns false if the party is already full.
func add(creature: CreatureData) -> bool:
	if creature == null or is_full():
		return false
	caught.append(creature)
	party_changed.emit()
	return true


## How many of this particular creature the player owns.
func count_of(creature: CreatureData) -> int:
	var n := 0
	for c in caught:
		if c == creature:
			n += 1
	return n
