extends RefCounted
## What the team carries between Highbank and the Hollow (Claude, 2026-10-09; Preston: "do the town
## wiring, prologue to town to hollow and back"). One record that lives while the game runs: the
## prologue starts it, the town hands it to a run, the run hands it back on a clear or a faint.
## Saving it to disk is the save system's job, later.

const KEYS := ["party", "roster", "bag", "taught", "growth", "iq", "levels", "cleared", "faints", "tactic"]

static var data := {}


## A new game: the team the prologue chose, and nothing else yet.
static func start(party: Array, metas: Dictionary = {}) -> void:
	data = {"party": party.duplicate(true), "metas": metas.duplicate(true)}


## Copy what a dungeon run knows into the record. `news` says how the run ended.
static func take_from(node: Node, news: String) -> void:
	for k in KEYS:
		var v: Variant = node.get(k)
		data[k] = v.duplicate(true) if v is Array or v is Dictionary else v
	data["news"] = news


## Give a new dungeon run (or the town) what the record holds, before it is added to the tree.
static func give_to(node: Node) -> void:
	for k in KEYS:
		if data.has(k) and k in node:
			var v: Variant = data[k]
			node.set(k, v.duplicate(true) if v is Array or v is Dictionary else v)
	for m in data.get("metas", {}):
		node.set_meta(m, data["metas"][m])
