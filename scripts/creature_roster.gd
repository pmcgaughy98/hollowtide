class_name CreatureRoster
extends RefCounted

const Gate = preload("res://scripts/move_gate.gd")

## Loads the creature files off disk and checks them for duplicates. Nothing
## here holds state, so you call these directly: CreatureRoster.load_all()

const CREATURE_DIR := "res://data/creatures/"

## Three stage lines are the target, so four is an error rather than a warning.
const MAX_STAGES := 3


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


## Checks the evolution lines. Kept separate from validate() because these rules
## are about how creatures relate to each other, not about one creature's fields.
##
## The rules are yours, from Digimon: a line should make sense, and you should
## never have several creatures that evolve into the same one. Writing them as
## checks rather than as a note in a document means the roster cannot drift away
## from them quietly, which is how the last one went wrong.
static func validate_evolutions(creatures: Array[CreatureData]) -> PackedStringArray:
	var problems := PackedStringArray()

	# Who points at whom. Built once, then every rule below reads from it.
	#
	# `settled` holds creatures whose loop problem has already been reported. It
	# stops one loop being announced once per member, and it keeps the length
	# walk at the bottom from following a line that never ends.
	var incoming := {}
	var settled := {}

	for c in creatures:
		var next: CreatureData = c.evolves_into
		if next == null:
			continue
		if next == c:
			problems.append("%s evolves into itself." % _label(c))
			settled[c] = true
			continue
		if not incoming.has(next):
			incoming[next] = []
		incoming[next].append(_label(c))

	# Converging lines. This is the specific thing you dislike, several creatures
	# sharing one evolution, so it is an error and not a warning.
	for target in incoming:
		var sources: Array = incoming[target]
		if sources.size() > 1:
			problems.append("%s is the evolution of %d creatures (%s). Each line needs its own destination."
				% [_label(target), sources.size(), ", ".join(sources)])

	# Loops. Walking forward from a creature either runs off the end of its line
	# or arrives somewhere already visited, and the second case means a loop.
	#
	# Whichever creature finds a loop first names every member of it and marks
	# them settled, so the loop is reported once no matter how many creatures
	# lead into it. A loop would also hang the length walk below, which is the
	# other reason it has to be found first.
	for c in creatures:
		var seen := {}
		var node: CreatureData = c
		while node != null and not seen.has(node):
			seen[node] = true
			node = node.evolves_into

		if node == null or settled.has(node):
			continue

		var members := PackedStringArray()
		var walker: CreatureData = node
		while true:
			members.append(_label(walker))
			settled[walker] = true
			walker = walker.evolves_into
			if walker == node:
				break

		problems.append("Evolution loop: %s -> %s. A line has to end somewhere."
			% [" -> ".join(members), members[0]])

	# Line length, measured only from the start of each line, so a four stage
	# line is reported once rather than once per stage.
	for c in creatures:
		if incoming.has(c) or settled.has(c):
			continue
		var chain := PackedStringArray()
		var node: CreatureData = c
		while node != null and not settled.has(node):
			chain.append(_label(node))
			node = node.evolves_into
		if chain.size() > MAX_STAGES:
			problems.append("%s runs %d stages and the limit is %d: %s"
				% [_label(c), chain.size(), MAX_STAGES, " -> ".join(chain)])

	return problems


## An equipped move the body cannot learn. Plate Rake on Coalcrest is the
## known failure. The creature file is left as it is. Battle hides the move.
static func validate_move_gates(creatures: Array[CreatureData]) -> PackedStringArray:
	var problems := PackedStringArray()
	for c in creatures:
		for move in c.moves:
			if move != null and not Gate.can_learn(c, move):
				problems.append("%s equips %s without the parts it needs (%s)."
					% [_label(c), move.move_name, ", ".join(move.required_parts)])
	return problems


## A creature's name, falling back to something readable when it has none yet.
static func _label(c: CreatureData) -> String:
	if not c.creature_name.is_empty():
		return c.creature_name
	var file_name: String = c.resource_path.get_file()
	return file_name if not file_name.is_empty() else "(unnamed creature)"
