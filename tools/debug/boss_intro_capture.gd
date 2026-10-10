extends SceneTree
## The Warden's entrance played through (Claude, 2026-10-10): each line is read after a beat, a still
## is saved at every step of the storyboard, and the check ends when the fight has started.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/boss_intro_capture.gd
## With --write-movie docs/design/boss-intro-2026-10-10/raw.avi it also records the scene.

const OUT := "res://docs/design/boss-intro-2026-10-10/"
var dg: Node2D
var shot := {}


func _initialize() -> void:
	_run.call_deferred()


func _snap(name: String) -> void:
	if shot.has(name) or DisplayServer.get_name() == "headless":
		return
	shot[name] = true
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))
	print("still ", name)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	dg = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 7
	dg.poll_input = false
	dg.dungeon = "hollow"   # the Warden is the Hollow's boss (2026-10-10)
	dg.party = [[0, 0], [1, 0], [10, 0]]
	root.add_child(dg)
	for k in 10:
		await process_frame
	dg.floor_n = dg.floors() + 1
	dg._build_floor(true)
	var frames := 0
	var read_wait := 0
	var team_y0: int = dg.ents[0]["pos"].y
	while frames < 30 * 120:
		await process_frame
		frames += 1
		if frames == 60:
			await _snap("00_garden")
		if frames == 200:
			await _snap("01_walk_in")
		if not dg.intro.get("emote", {}).is_empty() and not shot.has("01b_notice"):
			for k in 6:
				await process_frame
			await _snap("01b_notice")
		if dg.intro.has("wipe_at"):
			for k in 12:
				await process_frame
			await _snap("09b_wipe")
		if not dg.talk.is_empty():
			var who: String = String(dg.talk[0][0])
			if who == "???":
				await _snap("02_voice")
			elif dg.ents[dg.boss]["node"].visible and who == String(dg.ents[dg.boss]["name"]):
				await _snap("09_warden_talks")
			read_wait += 1
			if read_wait >= 50:   # a beat to read each line
				read_wait = 0
				dg.act_talk()
			continue
		if dg.intro.get("pond_shadow", 0.0) > 0.75:
			await _snap("03_shadow_in_pond")
		if dg.intro.has("burst_at"):
			var since: float = (Time.get_ticks_msec() - int(dg.intro["burst_at"])) / 1000.0
			if since > 0.08:
				await _snap("04_burst")
			if since > 0.9 and dg.ents[0].get("down", false):
				await _snap("05_knocked_down")
		if dg.intro.get("dazed", false) and not dg.ents[0].get("down", false) and dg.intro.get("ground", {}).is_empty():
			await _snap("06_getting_up_dazed")
		if dg.intro.get("ground", {}).get("k", 0.0) > 0.7:
			await _snap("07_shadow_on_ground")
		if dg.ents[dg.boss]["node"].visible and shot.has("07_shadow_on_ground") and not shot.has("08_slam"):
			for k in 3:
				await process_frame
			await _snap("08_slam")
		if dg.boss_met:
			break
	for k in 20:
		await process_frame
	await _snap("10_fight")
	var b: Dictionary = dg.ents[dg.boss]
	var minions: Array = dg.ents.filter(func(e: Dictionary) -> bool: return e.get("minion", false))
	print("Entrance: %.1f s; fight started %s; scene over %s; Warden shown %s at %s; Listeners shown %s; team pushed back %s (row %d -> %d); pond %s" % [
		frames / 30.0, str(dg.boss_met), str(not dg.cutscene), str(b["node"].visible), str(b["pos"]),
		str(minions.all(func(m: Dictionary) -> bool: return m["node"].visible)), str(dg.ents[0]["pos"].y == team_y0 - load("res://scripts/dungeon/boss_intro.gd").WALK_STEPS + 1), team_y0, dg.ents[0]["pos"].y, str(dg.pond)])
	var good: bool = dg.boss_met and not dg.cutscene and b["node"].visible and minions.all(func(m: Dictionary) -> bool: return m["node"].visible)
	print("BOSS INTRO: %s" % ("ok" if good else "FAIL"))
	quit()
