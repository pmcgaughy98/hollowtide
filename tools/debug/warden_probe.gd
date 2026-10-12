extends SceneTree
## Where does the pilot's team actually lose The Hollow? (Claude, 2026-10-12; the pilot chain came home from The
## Hollow three times out of three, on 2026-10-11 and today, without the Warden beaten.) Plays The Hollow on
## autopilot with the team the chain arrives with (the two starters plus Dustkite and Canvaswing, all about Lv 5),
## three seeds, and reports the floor reached, whether the Warden was met, its lowest health, and what beat the
## leader. The dungeon is not the current scene, so a faint sets its "went_to_town" meta instead of leaving.
##   Godot --headless --path . --script res://tools/debug/warden_probe.gd

const TeamState := preload("res://scripts/town/team_state.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for sd in [99, 7, 31337]:
		TeamState.start([[0, 0], [1, 0], [9, 0], [8, 0]])
		TeamState.data["story"] = {"met_crew": true, "parcel": "delivered", "guild_trial": true, "runner": true, "road_talk": true}
		TeamState.data["beaten"] = ["mouth", "first"]
		TeamState.data["levels"] = {0: {"lv": 5, "exp": 14}, 1: {"lv": 5, "exp": 14}, 9: {"lv": 4, "exp": 126}, 8: {"lv": 5, "exp": 30}}
		TeamState.data["bag"] = {"reedberry": 1}
		var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
		dg.floor_seed = sd
		dg.poll_input = false
		TeamState.give_to(dg)
		dg.dungeon = "hollow"
		dg.return_to_town = true
		root.add_child(dg)
		for k in 4:
			await process_frame
		dg.autopilot = true
		var frames := 0
		var top_floor := 1
		var met := false
		var boss_low := -1
		var boss_max := -1
		var lead_low := 999
		while frames < 30 * 700 and not dg.has_meta("went_to_town") and dg.cleared == 0:
			await process_frame
			frames += 1
			if not dg.talk.is_empty() and frames % 4 == 0:
				dg.act_talk()
			top_floor = maxi(top_floor, dg.floor_n)
			if dg.boss >= 0 and dg.boss < dg.ents.size():
				var b: Dictionary = dg.ents[dg.boss]
				if b["awake"]:
					met = true
				boss_max = int(b["max_hp"])
				boss_low = int(b["hp"]) if boss_low < 0 else mini(boss_low, int(b["hp"]))
			if not dg.ents.is_empty():
				lead_low = mini(lead_low, int(dg.ents[0]["hp"]))
		var how := "cleared" if dg.cleared > 0 else (String(dg.get_meta("went_to_town")) if dg.has_meta("went_to_town") else "still going")
		var lf: Dictionary = dg.last_faint
		print("WARDEN seed %d: %s after %d turns (%d frames); reached B%dF of %d; Warden met %s, its health lowest %d of %d; the leader went down on %s to %s after %d turns, %d wilds downed (Lv %d, max %d); faints %d" % [
			sd, how, dg.turn, frames, top_floor, dg.floors() + 1, str(met), boss_low, boss_max, str(lf.get("floor", "?")), str(lf.get("fell_to", "nothing")), int(lf.get("turns", 0)), int(lf.get("downed", 0)), dg.level_of(0), int(dg.ents[0]["max_hp"]) if not dg.ents.is_empty() else 0, dg.faints])
		dg.queue_free()
		for k in 3:
			await process_frame
	quit(0)
