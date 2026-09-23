class_name CreatureRoster
extends RefCounted

## Loads the creature files off disk and checks them for duplicates. Nothing
## here holds state, so you call these directly: CreatureRoster.load_all()

const CREATURE_DIR := "res://data/creatures/"


## Every creature file, sorted by Dex number.
static func load_all() -> Array[CreatureData]:
	var found: Array[CreatureData] = []

	for file_name in DirAccess.get_files_at(CREATURE_DIR):
		# Exported builds rename resources to name.tres.remap, so trim that
		# before checking the extension or this returns nothing outside the editor.
		if file_name.ends_with(".remap"):
			file_name = file_name.trim_suffix(".remap")
		if not file_name.ends_with(".tres"):
			continue

		var res: Resource = load(CREATURE_DIR + file_name)
		if res is CreatureData:
			found.append(res)

	found.sort_custom(func(a: CreatureData, b: CreatureData) -> bool: return a.id < b.id)
	return found


## Returns a list of problems. An empty list means the roster is clean.
##
## The duplicate check matters more now, not less. The old roster ran dry around
## thirty entries and started repeating itself, and this is the cheapest way to
## catch that happening again the moment it starts.
##
## What this CANNOT check: whether a name collides with an existing Pokemon,
## Coromon, Nexomon, Temtem or Cassette Beasts creature. That needs a human
## looking it up, and writing a fake checker here would be worse than none.
static func validate(creatures: Array[CreatureData]) -> PackedStringArray:
	var problems := PackedStringArray()
	var ids_seen := {}
	var names_seen := {}

	for c in creatures:
		# Creatures built in memory rather than loaded from disk have no path,
		# which would otherwise print as a blank name in the message below.
		var where: String = c.resource_path.get_file()
		if where.is_empty():
			where = "(unsaved creature)"

		if c.creature_name.is_empty():
			problems.append("%s has no name" % where)
			continue

		if ids_seen.has(c.id):
			problems.append("Dex number %s used by both %s and %s"
				% [c.dex_number, ids_seen[c.id], c.creature_name])
		else:
			ids_seen[c.id] = c.creature_name

		var name_key: String = c.creature_name.to_lower().strip_edges()
		if names_seen.has(name_key):
			problems.append("%s appears more than once" % c.creature_name)
		else:
			names_seen[name_key] = c.id

		if c.sprite == null:
			problems.append("%s has no sprite assigned" % c.creature_name)

	return problems
