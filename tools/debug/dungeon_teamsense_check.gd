extends SceneTree
## Team Sense (Claude, 2026-10-10): each habit set up on open floor, and the creature's own answer
## (its plan and why). Focus on the leader's foe; the basic finishes what it would down anyway; a
## support steps out of melee while a teammate holds the foe; a healer walks to the hurt; a hurt
## partner walks to the healer; and a full autopilot run still clears.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_teamsense_check.gd


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _check(label: String, ok: bool, detail: String) -> int:
	print("%s: %s -> %s" % [label, detail, "ok" if ok else "WRONG"])
	return 0 if ok else 1


var dg: Node2D
var base := Vector2i.ZERO


func _put(e: Dictionary, off: Vector2i) -> void:
	e["pos"] = base + off
	dg._place(e)


func _clear_wild() -> void:
	for e in dg.ents:
		if e["team"] == 1:
			e["hp"] = 0
			e["pos"] = Vector2i(-50, -50)
			e["node"].visible = false
	dg.focus = {}


func _wild(off: Vector2i, hp := 40) -> Dictionary:
	var w: Dictionary = dg._make(2, 0, 1, base + off)
	w["max_hp"] = 40
	w["hp"] = hp
	w["awake"] = true
	dg.ents.append(w)
	dg._place(w)
	return w


func _run() -> void:
	var bad := 0
	dg = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[1, 0], [0, 0], [10, 0]]   # Tallowroot leads; Kithflare and Troughspine are the partners
	root.add_child(dg)
	await _frames(4)
	# An open patch: 9 x 5 floor tiles.
	var found := false
	for y in range(2, dg.data["h"] - 6):
		for x in range(2, dg.data["w"] - 10):
			var ok := true
			for dy in range(-2, 3):
				for dx in range(-2, 7):
					if not dg._floor_at(Vector2i(x + dx, y + dy)):
						ok = false
			if ok:
				base = Vector2i(x, y)
				found = true
				break
		if found:
			break
	print("open patch at %s" % str(base))
	var lead: Dictionary = dg.ents[0]
	var kith: Dictionary = dg.ents[1]
	var trough: Dictionary = dg.ents[2]
	var KI := 1
	var TI := 2

	# 1. Focus: two foes beside Kithflare; the leader is fighting the one on the right.
	_clear_wild()
	_put(lead, Vector2i(5, 0)); _put(trough, Vector2i(0, 2)); _put(kith, Vector2i(2, 0))
	var left := _wild(Vector2i(1, 0))
	var right := _wild(Vector2i(3, 0))
	kith["cds"]["claw"] = 0
	var plain: Dictionary = dg._decide(KI)
	dg.focus = left   # the one it would not pick on its own
	var focused: Dictionary = dg._decide(KI)
	bad += _check("Focus", focused.get("j", -1) == dg.ents.find(left) and plain.get("j", -1) != dg.ents.find(left) and focused.get("why", "") == "focus",
		"no focus: %s; focus on the leader's foe: %s" % [str(plain), str(focused)])

	# 2. No overkill: a foe on 1 health; Cinder Claw would win the score, the basic downs it too.
	_clear_wild()
	_put(lead, Vector2i(5, 2)); _put(trough, Vector2i(0, 2)); _put(kith, Vector2i(2, 0))
	var weak := _wild(Vector2i(3, 0), 1)
	kith["moves"].assign(["claw", "cinder_claw"])
	kith["cds"] = {"claw": 0, "cinder_claw": 0}
	var fin: Dictionary = dg._decide(KI)
	weak["hp"] = 40
	var full: Dictionary = dg._decide(KI)
	bad += _check("No overkill", fin.get("m", "") == "claw" and fin.get("why", "") == "no overkill" and full.get("m", "") == "cinder_claw",
		"foe on 1: %s; foe on 40: %s" % [str(fin), str(full)])

	# 3. Keep range: a foe beside Troughspine and beside Kithflare too; Spring Spit is ready.
	_clear_wild()
	_put(lead, Vector2i(6, 2)); _put(trough, Vector2i(2, 0)); _put(kith, Vector2i(3, 1))
	_wild(Vector2i(3, 0))
	trough["cds"] = {"spring_spit": 0, "seep": 5}
	var kr: Dictionary = dg._decide(TI)
	var away: bool = kr.get("kind", "") == "move" and dg._awake_foes_beside(TI, trough["pos"] + kr.get("d", Vector2i.ZERO)).is_empty()
	bad += _check("Keep range", kr.get("why", "") == "keep range" and away, "plan %s, the new tile is out of reach %s" % [str(kr), str(away)])
	# ...and not when nobody else holds the foe.
	_put(kith, Vector2i(0, 2))
	var alone: Dictionary = dg._decide(TI)
	bad += _check("Keep range, alone", alone.get("why", "") != "keep range", "plan %s" % str(alone))

	# 4. To the hurt: Seep ready, the leader at a quarter health three tiles off.
	# The healer is a real Archroot (line 10, stage 1), made by the game's own _make the way the
	# party is, so Seep comes from its learn data, not from this check (Grok, 2026-10-12: Troughspine
	# does not learn Seep, Archroot does on growing). It takes Troughspine's place on the team for
	# parts 4 and 5, fresh, so every move is ready (Claude, 2026-10-21).
	_clear_wild()
	var arch: Dictionary = dg._make(10, 1, 0, base)
	trough["node"].visible = false
	dg.ents[TI] = arch
	_put(lead, Vector2i(4, 0)); _put(arch, Vector2i(0, 0)); _put(kith, Vector2i(0, 2))
	print("the healer: %s knows %s, ready %s" % [arch["name"], str(arch["moves"]), str(arch["cds"])])
	lead["hp"] = lead["max_hp"] / 4
	var th: Dictionary = dg._decide(TI)
	var closer: bool = th.has("d") and dg._cheb(arch["pos"] + th["d"], lead["pos"]) < dg._cheb(arch["pos"], lead["pos"])
	bad += _check("To the hurt", th.get("why", "") == "to the hurt" and closer, "plan %s, closer %s" % [str(th), str(closer)])
	lead["hp"] = lead["max_hp"]

	# 5. To a healer: Kithflare under a third, Archroot's Seep ready four tiles off.
	_put(arch, Vector2i(5, 0)); _put(kith, Vector2i(1, 0)); _put(lead, Vector2i(1, 2))
	kith["hp"] = kith["max_hp"] / 4
	var tk: Dictionary = dg._decide(KI)
	bad += _check("To a healer", tk.get("why", "") == "to a healer", "plan %s" % str(tk))
	kith["hp"] = kith["max_hp"]
	dg.queue_free()
	await _frames(4)

	# 6. A whole run on autopilot still works (the habits do not stall the team).
	var run: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	run.floor_seed = 99
	run.poll_input = false
	run.party = [[0, 0], [1, 0], [10, 0]]
	root.add_child(run)
	await _frames(4)
	run.autopilot = true
	var t0: int = Time.get_ticks_msec()
	while run.floor_n < 2 and run.ents[0]["hp"] > 0 and Time.get_ticks_msec() - t0 < 120000:
		await _frames(10)
	bad += _check("Autopilot", run.floor_n >= 2, "reached B%dF in %d turns" % [run.floor_n, run.turn])
	run.queue_free()
	print("RESULT: %s" % ("team sense works" if bad == 0 else "%d problems" % bad))
	quit()
