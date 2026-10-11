extends SceneTree
## The pilot's payoff (Claude, 2026-10-10): evolution waits for the pond stone. Before it, the Growth
## Shrine is dark and offers nothing even to a creature that is ready; beating the Warden brings the
## stone home; setting it in wakes the shrine; then the ready creature can evolve. Windowed, it also
## plays the stone rising from the pond and the shrine waking, saving stills.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/stone_check.gd
## With --write-movie docs/design/pond-stone-2026-10-10/raw.avi it also records both scenes.

const TeamState := preload("res://scripts/town/team_state.gd")
const OUT := "res://docs/design/pond-stone-2026-10-10/"
var fails := 0
var shot := {}


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _snap(name: String) -> void:
	if shot.has(name) or DisplayServer.get_name() == "headless":
		return
	shot[name] = true
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


## A team whose leader is ready to evolve (the same setup as evolution_check.gd).
func _ready_team() -> void:
	var c: Dictionary = load("res://scripts/dungeon/dungeon.gd").get_script_constant_map()
	var r: Dictionary = c["EVO"][0]
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["levels"] = {0: {"lv": c["EVO_LEVEL"][0], "exp": 0}}
	TeamState.data["growth"] = {"0:0": {"kos": r["kos"][0], "floors": r["floors"][0], "flank": r["need"][0], "ambush": 0, "took": 0, "slam": 0}}


func _town() -> Node2D:
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await _frames(6)
	var shrine: Dictionary = town.Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "shrine")[0]
	town.team[0]["pos"] = shrine["door"]
	town._place(town.team[0])
	return town


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var Evolution: GDScript = load("res://scripts/town/evolution.gd")
	# 1. A ready creature at a dark shrine: nothing to evolve.
	_ready_team()
	var ready_n: int = Evolution.ready_list(TeamState.data).size()
	var town: Node2D = await _town()
	town.act_use()
	await _frames(4)
	await _snap("01_dark_shrine")
	_ok("Before the stone (%d ready): the shrine says '%s'" % [ready_n, String(town.panel.get("what", "")).left(40)], ready_n > 0 and town.panel.get("service", "") == "growth")
	town.panel = {}
	town.queue_free()
	await _frames(2)
	# 2. The Warden falls: the stone rises, and the team carries it home.
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 7
	dg.poll_input = false
	dg.return_to_town = false
	dg.dungeon = "hollow"
	TeamState.give_to(dg)
	dg.party = [[0, 0], [1, 0], [10, 0]]
	root.add_child(dg)
	await _frames(10)
	dg.floor_n = dg.floors() + 1
	dg._build_floor(true)
	var frames := 0
	while not dg.boss_met and frames < 30 * 120:   # the entrance plays; read its lines
		await process_frame
		frames += 1
		if not dg.talk.is_empty() and frames % 40 == 0:
			dg.act_talk()
	var b: Dictionary = dg.ents[dg.boss]
	b["hp"] = 1
	dg._wound(0, dg.boss, 5, Color.WHITE)
	frames = 0
	var read := 0
	while dg.story.get("stone", "") == "" and frames < 30 * 90:
		await process_frame
		frames += 1
		if dg.intro.get("spent", false):
			await _snap("02a_spent")
		if dg.intro.get("dazed", false) and dg.intro.has("doom"):
			await _snap("02b_pinned")
		if dg.intro.has("streak"):
			await _snap("02c_punch")
		if not dg.talk.is_empty() and String(dg.talk[0][0]) == "Starward":
			await _snap("02d_starward")
		if dg.intro.get("stone_glow", 0.0) > 0.9:
			await _snap("02_pond_lights")
		if dg.intro.has("stone") and not dg.talk.is_empty() and String(dg.talk[0][0]) == "???":
			await _snap("03_stone_risen")
		if dg.intro.has("stone") and not dg.talk.is_empty() and dg.cam_focus != null and dg.intro["stone"].y > dg.ents[0]["node"].position.y - 50:
			await _snap("04_stone_taken")
		if not dg.talk.is_empty():
			read += 1
			if read >= 45:
				read = 0
				dg.act_talk()
	_ok("The Warden beaten: the stone is %s; the Hollow beaten %s" % [dg.story.get("stone", ""), str("hollow" in dg.beaten)], dg.story.get("stone", "") == "carried" and "hollow" in dg.beaten)
	TeamState.take_from(dg, "")
	_ready_team_keep_story()
	dg.queue_free()
	await _frames(2)
	# 3. Back at the shrine: set the stone in; it wakes; then the ready creature evolves.
	town = await _town()
	town.act_use()
	_ok("With the stone: the shrine asks '%s'" % String(town.panel.get("what", "")).left(40), town.panel.get("service", "") == "stone_ask")
	await _frames(2)
	await _snap("05_stone_ask")
	town.act_use()
	await _frames(40)
	await _snap("06_shrine_wakes")
	while town.evolving_now:
		await process_frame
	await _snap("07_shrine_awake")
	_ok("Set in: the stone is %s" % town.stone_state(), town.stone_state() == "installed")
	town.panel = {}
	town.act_use()
	_ok("Then the shrine offers: %s" % town.panel.get("service", ""), town.panel.get("service", "") == "evolve_ask")
	town.queue_free()
	print("STONE: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit()


## After the run, the leader is still ready (the run may have changed its growth record).
func _ready_team_keep_story() -> void:
	var story: Dictionary = TeamState.data.get("story", {})
	_ready_team()
	TeamState.data["story"] = story
