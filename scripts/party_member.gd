class_name PartyMember
extends RefCounted

## One owned creature. Separate objects let two captures of the same species
## keep separate identities when one of them evolves.
var species: CreatureData


func _init(initial_species: CreatureData) -> void:
	species = initial_species
