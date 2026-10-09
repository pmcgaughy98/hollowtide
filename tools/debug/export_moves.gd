extends SceneTree
## Every line's forms, kits and moves as one Markdown table (Claude, 2026-10-09), for research
## uploads and for the move-table work. Reads the arena's tables; changes nothing.
##   Godot --headless --path . --script res://tools/debug/export_moves.gd

const Arena := preload("res://scripts/arena/arena_prototype.gd")
const CD := preload("res://scripts/creature_data.gd")
const OUT := "res://docs/research/gemini-upload-2026-10-09/hollowtide-current-moves.md"


func _initialize() -> void:
	var names := {}
	for k in CD.Essence.keys():
		names[CD.Essence[k]] = String(k).capitalize()
	var used := {}
	var t := "# Hollowtide: current creatures and moves (exported 2026-10-09)\n\n"
	t += "Every creature line has three stages. Stage 1 has a basic attack plus 2 abilities, stage 2 a basic plus 3 and a passive, and stage 3 adds a signature (an ultimate). Moves were designed per creature from the body parts its art shows. Damage, cooldown (seconds, real-time arena) and range (pixels) are working numbers; on the dungeon grid, range becomes tiles (24 px each) and the kind decides the shape: front tile, dash along a line, shot down a line, or burst around a target.\n\n"
	t += "## Lines and kits\n\n| Line | Stage | Creature | Essences | Basic | Abilities | Passive | Signature |\n|---|---|---|---|---|---|---|---|\n"
	for li in Arena.LINES.size():
		var line: Dictionary = Arena.LINES[li]
		for s in line["forms"].size():
			var form: String = line["forms"][s][0]
			var cdata: Resource = load(line["forms"][s][1])
			var ess: Array = []
			ess.append(names.get(cdata.get("essence"), "?"))
			if cdata.get("has_second_essence"):
				ess.append(names.get(cdata.get("second_essence"), "?"))
			var kit: Dictionary = Arena.KITS.get(form, {})
			var basic: Array = kit.get("moves", [])
			var abil: Array = kit.get("abilities", [])
			for m in basic + abil:
				used[m] = true
			t += "| %d | %d | %s | %s | %s | %s | %s | %s |\n" % [li + 1, s + 1, cdata.get("creature_name"), " / ".join(ess), ", ".join(basic.map(func(m): return Arena.MOVES[m]["name"] if Arena.MOVES.has(m) else m)), ", ".join(abil.map(func(m): return Arena.MOVES[m]["name"] if Arena.MOVES.has(m) else m)), str(kit.get("passive", "")), line.get("signature", "") if s == 2 else ""]
	t += "\n## Moves\n\n| Move | Essence | Kind | Damage | Cooldown | Range | Used by |\n|---|---|---|---|---|---|---|\n"
	for m in Arena.MOVES:
		var mv: Dictionary = Arena.MOVES[m]
		var who: Array = []
		for form in Arena.KITS:
			var kit: Dictionary = Arena.KITS[form]
			if m in kit.get("moves", []) or m in kit.get("abilities", []):
				who.append(form.capitalize())
		if who.is_empty():
			continue
		t += "| %s | %s | %s | %s | %s | %s | %s |\n" % [mv["name"], names.get(Arena.MOVE_ESSENCE.get(m, -1), "the user's own"), Arena.TELEGRAPH[m][0] if Arena.TELEGRAPH.has(m) else "", str(mv.get("damage", "")), str(mv.get("cooldown", "")), str(mv.get("range", "")), ", ".join(who)]
	var f := FileAccess.open(OUT, FileAccess.WRITE)
	f.store_string(t)
	f.close()
	print("wrote ", OUT, " (", t.length(), " chars)")
	quit()
