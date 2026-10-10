extends SceneTree
## The move table (Claude, 2026-10-09). Part 1 writes docs/creatures/move-table-2026-10-09.md from
## scripts/moves/move_body.gd: shared signatures and who can learn them, line-only moves,
## ultimates, every current kit checked against the body gate. Part 2 plays a move scroll in the
## dungeon: a body without the part is refused, one with it learns, a full kit forgets a move
## of the player's choice, the move stays across floors and hits, and floors stock scrolls.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/move_table_check.gd

const Arena := preload("res://scripts/arena/arena_prototype.gd")
const MoveBody := preload("res://scripts/moves/move_body.gd")
const OUT := "res://docs/creatures/move-table-2026-10-09.md"


func _initialize() -> void:
	_run.call_deferred()


func _name(m: String) -> String:
	return Arena.MOVES[m]["name"] if Arena.MOVES.has(m) else m


func _forms_text(forms: Array) -> String:
	return ", ".join(forms.map(func(f): return String(f).capitalize()))


func _run() -> void:
	# ---- Part 1: the table
	var line_of := {}
	var kit_users := {}
	for li in Arena.LINES.size():
		for f in Arena.LINES[li]["forms"]:
			line_of[f[0]] = li
			var kit: Dictionary = Arena.KITS.get(f[0], {})
			for m in kit.get("moves", []) + kit.get("abilities", []):
				if not kit_users.has(m):
					kit_users[m] = []
				kit_users[m].append(f[0])
	var shared: Array = MoveBody.shared(Arena.LINES)
	var t := "# Move table (generated 2026-10-09 by tools/debug/move_table_check.gd)\n\n"
	t += "Draft for Grok, from `scripts/moves/move_body.gd`. Grok's rule (DESIGN_RULES.md, 2026-10-02): a move needs body parts, and a creature may use or learn it only with every one. Essence is not permission. A move whose parts cross lines is a **shared signature** (like Leaf Blade). One whose parts only one line has stays with that line by anatomy. An **ultimate** is never taught.\n\n"
	t += "## Shared signatures\n\n| Move | Needs | Its own users | Other bodies that can learn it |\n|---|---|---|---|\n"
	for m in shared:
		var own: Array = kit_users.get(m, [])
		var others: Array = MoveBody.learners(m).filter(func(f): return not f in own)
		t += "| %s | %s | %s | %s |\n" % [_name(m), ", ".join(MoveBody.NEEDS[m]), _forms_text(own), _forms_text(others)]
	t += "\n## Line moves (the part is that line's alone)\n\n| Move | Needs | Line |\n|---|---|---|\n"
	for m in MoveBody.NEEDS:
		if m in shared:
			continue
		var lines: Array = MoveBody.lines_of(m, Arena.LINES)
		t += "| %s | %s | %s |\n" % [_name(m), ", ".join(MoveBody.NEEDS[m]), ", ".join(lines.map(func(li): return String(Arena.LINES[li]["forms"][0][0]).capitalize() + " line")) if not lines.is_empty() else "nobody (check)"]
	t += "\n## Ultimates (final stage only, never taught)\n\n"
	for li in Arena.LINES.size():
		t += "- %s: %s\n" % [String(Arena.LINES[li]["forms"][2][0]).capitalize(), Arena.LINES[li].get("signature", "")]
	t += "\n## Current kits that fail the gate\n\nThese kits were written for the arena before this table. Changing a kit is Grok's and Preston's call; nothing was changed.\n\n| Creature | Move | Missing |\n|---|---|---|\n"
	var fails := 0
	for form in Arena.KITS:
		var kit: Dictionary = Arena.KITS[form]
		for m in kit.get("moves", []) + kit.get("abilities", []):
			var miss: Array = MoveBody.missing(form, m)
			if not miss.is_empty():
				t += "| %s | %s | %s |\n" % [String(form).capitalize(), _name(m), ", ".join(miss)]
				fails += 1
	var ungated: Array = []
	for m in kit_users:
		if not MoveBody.NEEDS.has(m):
			ungated.append(_name(m))
	if not ungated.is_empty():
		t += "\nNot gated yet (no part list): %s\n" % ", ".join(ungated)
	var f := FileAccess.open(OUT, FileAccess.WRITE)
	f.store_string(t)
	f.close()
	print("Table: %d shared signatures (%s); %d kit moves fail the gate; ungated %s" % [shared.size(), ", ".join(shared.map(func(m): return _name(m))), fails, str(ungated)])

	# ---- Part 2: a scroll in the dungeon
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0]]   # Kithflare (claws) and Tallowroot (no claws)
	dg.levels = {0: {"lv": 3, "exp": 0}}   # Lv 3: Kithflare knows its three level moves, so two scrolls fill it
	root.add_child(dg)
	for k in 4:
		await process_frame
	print("Scroll pool: %s" % str(dg.scroll_pool().map(func(m): return _name(m))))
	var kith: Dictionary = dg.ents[0]
	var tall: Dictionary = dg.ents[1]
	dg.bag["scroll:cinder_claw"] = 1
	var t0: int = dg.turn
	dg.act_use_item("scroll:cinder_claw")
	var rows: Array = dg.teach_rows()
	print("Panel: %s" % str(rows.map(func(r): return r["text"])))
	var r1: String = dg.act_teach(1)
	var r2: String = dg.act_teach(0)
	print("Tallowroot: %s; Kithflare: %s; Kithflare's moves %s; scroll left %d; turns spent %d" % [r1, r2, str(kith["moves"].map(func(m): return _name(m))), dg.bag.get("scroll:cinder_claw", 0), dg.turn - t0])
	# A full kit: Kithflare now knows four. A Pounce scroll asks what to forget.
	dg.bag["scroll:pounce"] = 1
	dg.act_use_item("scroll:pounce")
	var r3: String = dg.act_teach(0)
	var forget_rows: Array = dg.teach_rows()
	var r4: String = dg.act_teach(0, 1)
	print("Full: first answer %s, choices %s; then %s; moves %s" % [r3, str(forget_rows.map(func(r): return r["text"])), r4, str(kith["moves"].map(func(m): return _name(m)))])
	# Down a floor: the team is rebuilt and keeps what it learned.
	dg.floor_n += 1
	dg._build_floor(true)
	for k in 3:
		await process_frame
	print("Next floor: Kithflare's moves %s" % str(dg.ents[0]["moves"].map(func(m): return _name(m))))
	# The learned move hits.
	var lead: Dictionary = dg.ents[0]
	var p: Vector2i = lead["pos"]
	var d := Vector2i.ZERO
	for dd in dg.DIRS:
		if dg.can_step(p, dd) and dg._occupant(p + dd) < 0:
			d = dd
			break
	var w: Dictionary = dg._make(2, 0, 1, p + d)
	dg.ents.append(w)
	dg._place(w)
	var hp: int = w["hp"]
	await dg.use_move(0, "cinder_claw", d)
	print("Cinder Claw on a Rimefin: %d damage" % (hp - w["hp"]))
	# Floors stock scrolls.
	var scrolls := 0
	var items := 0
	for sd in 30:
		dg.floor_seed = 1000 + sd
		dg._build_floor(true)
		for it in dg.floor_items:
			items += 1
			if String(it["kind"]).begins_with("scroll:"):
				scrolls += 1
	print("Stock: %d of %d floor items over 30 floors were scrolls" % [scrolls, items])
	quit()
