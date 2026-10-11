extends RefCounted
## Evolving, done at the Growth Shrine in Highbank (Claude, 2026-10-10; Preston: "we'll keep that you
## evolve outside dungeon at a specific location", as Explorers of Sky's creatures evolve at its spring).
## In the Hollow a teammate only becomes ready (its level and the EVO conditions met); here, on the
## carried team record, it evolves. The rules are Grok's (docs/creatures/learnset-draft-2026-10-10.md):
## the new body keeps every earlier move it can still perform, its basic takes slot 0, four moves at
## most; the move taught on evolving and any level moves already due come along when there is room,
## and the rest wait in `pending_learn` for the start of the next run, where the learn panel asks
## which move to forget or lets the new one go.
##   Evolution.ready_list(record)  -> indices of the party ready to evolve
##   Evolution.evolve(record, k)   -> what happened; changes the record

const DUNGEON := "res://scripts/dungeon/dungeon.gd"   # loaded, not preloaded: dungeon.gd is large and preloads the UI
const ArenaData := preload("res://scripts/arena/arena_prototype.gd")
const Lines := preload("res://scripts/creatures/lines.gd")
const MoveBody := preload("res://scripts/moves/move_body.gd")
const MOVES_MAX := 4


static func _consts() -> Dictionary:
	return load(DUNGEON).get_script_constant_map()


static func ready(rec: Dictionary, k: int) -> bool:
	var party: Array = rec.get("party", [])
	if k < 0 or k >= party.size():
		return false
	var ln := int(party[k][0])
	var st := int(party[k][1])
	var c := _consts()
	if st >= 2 or not c["EVO"].has(ln):
		return false
	var r: Dictionary = c["EVO"][ln]
	var g: Dictionary = rec.get("growth", {}).get("%d:%d" % [ln, st], {})
	var lv := int(rec.get("levels", {}).get(ln, {}).get("lv", 1))
	return lv >= c["EVO_LEVEL"][st] and int(g.get("kos", 0)) >= r["kos"][st] and int(g.get("floors", 0)) >= r["floors"][st] and int(g.get(r["way"], 0)) >= r["need"][st]


static func ready_list(rec: Dictionary) -> Array:
	var out: Array = []
	for k in rec.get("party", []).size():
		if ready(rec, k):
			out.append(k)
	return out


static func evolve(rec: Dictionary, k: int) -> Dictionary:
	var D: GDScript = load(DUNGEON)
	var c := _consts()
	var ln := int(rec["party"][k][0])
	var st := int(rec["party"][k][1])
	var lv := int(rec.get("levels", {}).get(ln, {}).get("lv", 1))
	var old_form: String = D.form_of(ln, st)
	var new_form: String = D.form_of(ln, st + 1)
	if not rec.has("taught"):
		rec["taught"] = {}
	var old: Array = rec["taught"].get("%d:%d" % [ln, st], D.moves_for(ln, st, lv))
	var basic: String = D.basic_of(new_form)
	var kept: Array = [basic]
	var lost: Array = []
	for m in old:
		if m in kept:
			continue
		if MoveBody.can_learn(new_form, m):
			kept.append(m)
		else:
			lost.append(m)
	var waiting: Array = []
	for m in kept.slice(MOVES_MAX):
		waiting.append(m)
	kept = kept.slice(0, MOVES_MAX)
	# The move taught on evolving, then the level moves already due, in list order.
	var learned: Array = []
	var offers: Array = []
	for entry in c["LEARN"].get(new_form, []):
		if entry[0] is String:
			offers.append(entry[1])
	for entry in c["LEARN"].get(new_form, []):
		if entry[0] is int and entry[0] <= lv:
			offers.append(entry[1])
	for m in offers:
		if m in kept or not MoveBody.can_learn(new_form, m):
			continue
		if kept.size() < MOVES_MAX and waiting.is_empty():
			kept.append(m)
			learned.append(m)
		else:
			waiting.append(m)
	rec["taught"]["%d:%d" % [ln, st + 1]] = kept
	if not rec.has("pending_learn"):
		rec["pending_learn"] = []
	for m in waiting:
		rec["pending_learn"].append([ln, st + 1, m])
	rec["party"][k] = [ln, st + 1]
	return {"line": ln, "old_form": old_form, "new_form": new_form,
		"old_name": load(Lines.of(ln)["forms"][st][1]).creature_name,
		"new_name": load(Lines.of(ln)["forms"][st + 1][1]).creature_name,
		"moves": kept, "learned": learned, "lost": lost, "waiting": waiting}
