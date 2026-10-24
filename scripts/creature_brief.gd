extends RefCounted
## A creature's name and essences without its pictures (PERF-06, Claude, 2026-10-24). Loading a CreatureData .tres
## also loads its sprite, back sprite, idle frames and the form it evolves into, and the dungeon's _make only wants
## three plain values from it: that load cost about 50 ms a creature on every floor after the first, because the
## floor before had let go of the resource. This keeps {name, essence, second essence} per .tres path for the
## session, read once on first use. It holds no textures and no resource, only strings and numbers.

static var _briefs := {}


## {"name": String, "essence": int, "second": int (-1 when it has none)} for the CreatureData at `path`.
static func of(path: String) -> Dictionary:
	if not _briefs.has(path):
		var c: CreatureData = load(path)
		_briefs[path] = {"name": c.creature_name, "essence": int(c.essence), "second": int(c.second_essence) if c.has_second_essence else -1}
	return _briefs[path]


## Its essences in the order _make lists them: the first, then the second when it has one.
static func essences(path: String) -> Array:
	var b := of(path)
	return [b["essence"]] if int(b["second"]) < 0 else [b["essence"], b["second"]]
