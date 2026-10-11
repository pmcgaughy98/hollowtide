extends SceneTree
## Evolving at the Growth Shrine (Claude, 2026-10-10; Preston: evolve "outside dungeon at a specific
## location", with the evolution scene). In town: the Shrine names who is ready and asks; yes plays the
## scene (stills of the trade and the reveal in a windowed run) and Kithflare becomes Sparkwick on the
## record and on the street; asking again, no one is ready. Then a full move set: the move that did
## not fit waits, and the next run's first floor offers it in the learn panel.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/evolution_check.gd

const OUT := "res://docs/ui/ui-tour-2026-10-10/"
const TeamState := preload("res://scripts/town/team_state.gd")


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _check(label: String, ok: bool, detail: String) -> int:
	print("%s: %s -> %s" % [label, detail, "ok" if ok else "WRONG"])
	return 0 if ok else 1


func _snap(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


func _ready_record(taught: Array) -> void:
	var c: Dictionary = load("res://scripts/dungeon/dungeon.gd").get_script_constant_map()
	var r: Dictionary = c["EVO"][0]
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["story"] = {"stone": "installed"}   # the shrine is awake (stone_check.gd covers the dark shrine)
	TeamState.data["levels"] = {0: {"lv": c["EVO_LEVEL"][0], "exp": 0}}
	TeamState.data["growth"] = {"0:0": {"kos": r["kos"][0], "floors": r["floors"][0], "flank": r["need"][0], "ambush": 0, "took": 0, "slam": 0}}
	TeamState.data["taught"] = {"0:0": taught}


func _run() -> void:
	var bad := 0
	_ready_record(["claw", "ember_feint", "fireball"])
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await _frames(6)
	var shrine: Dictionary = town.Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "shrine")[0]
	town.team[0]["pos"] = shrine["door"]
	town._place(town.team[0])
	town.act_use()
	bad += _check("The Shrine asks", town.panel.get("service", "") == "evolve_ask" and String(town.panel.get("what", "")).contains("Kithflare is ready"),
		"'%s'" % town.panel.get("what", ""))
	town.act_use()
	# The scene: catch the trade and the reveal.
	var scene: Node = null
	var seen := {}
	var t0 := Time.get_ticks_msec()
	while town.evolving_now and Time.get_ticks_msec() - t0 < 20000:
		await process_frame
		if scene == null:
			for n in town.get_children():
				if n is CanvasLayer and n.get_script() != null and String(n.get_script().resource_path).ends_with("evolution_scene.gd"):
					scene = n
		if scene != null and is_instance_valid(scene) and not seen.has(scene.stage):
			seen[scene.stage] = true
			if scene.stage in ["trade", "reveal"]:
				await _frames(8)
				await _snap("13_evolution_" + scene.stage)
	bad += _check("The scene", seen.has("intro") and seen.has("whiten") and seen.has("trade") and seen.has("reveal"), "stages %s" % str(seen.keys()))
	var rec: Dictionary = TeamState.data
	bad += _check("Evolved", rec["party"][0] == [0, 1] and town.party[0] == [0, 1] and town.team[0]["form"] == "sparkwick" and rec["taught"].get("0:1", []) == ["pounce", "claw", "ember_feint", "fireball"] and String(town.panel.get("what", "")).contains("evolved into Sparkwick"),
		"party %s, on the street %s, moves %s, '%s'" % [str(rec["party"]), town.team[0]["form"], str(rec["taught"].get("0:1", [])), town.panel.get("what", "")])
	town.panel = {}
	town.act_use()
	bad += _check("No one else", String(town.panel.get("what", "")).contains("No one is ready"), "'%s'" % town.panel.get("what", ""))
	town.queue_free()
	await _frames(4)

	# A full set: Kithflare knows four; on evolving, Pounce takes slot 0 and Cinder Claw has to wait.
	_ready_record(["claw", "ember_feint", "fireball", "cinder_claw"])
	var res: Dictionary = load("res://scripts/town/evolution.gd").evolve(TeamState.data, 0)
	var waits: bool = TeamState.data.get("pending_learn", []) == [[0, 1, "cinder_claw"]]
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	TeamState.give_to(dg)
	root.add_child(dg)
	await _frames(6)
	bad += _check("Waiting move", waits and dg.ents[0]["form"] == "sparkwick" and dg.teach_kind == "learn:cinder_claw" and dg.pending_learn.is_empty(),
		"waiting %s; next run: %s knows %s, panel '%s'" % [str(res["waiting"]), dg.ents[0]["name"], str(dg.ents[0]["moves"]), dg.teach_kind])
	dg.queue_free()
	print("RESULT: %s" % ("evolving at the Growth Shrine works" if bad == 0 else "%d problems" % bad))
	quit()
