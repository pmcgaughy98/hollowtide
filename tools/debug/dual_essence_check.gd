extends SceneTree
## Retired (Claude, 2026-10-27, pass 9 D10, Grok task 10): this check printed each starter line's
## essences against the old turn-based chart in scripts/essence_chart.gd (strong 2.0, weak 0.5).
## The dungeon multiplies ARENA_CHART instead (main 1.5/0.75, second 1.25/0.9), so the print showed
## numbers no fight uses: Tide into Kithflare printed 2.0 where the dungeon hits for 1.5 * 0.9 = 1.35.
## It judged nothing, so the suite listed it as RAN. It now says RETIRED and quits with 2, as
## arena_scourmaw_check does, so the runner lists it as retired. essence_chart.gd and battle_screen.gd
## stay as they are (the old battle still calls that chart). Deleting the file is Preston's call.

func _initialize() -> void:
	print("RETIRED: dual_essence_check printed the old essence_chart.gd multipliers, which the dungeon does not play; no assertions ran.")
	print("The dungeon's chart is ARENA_CHART in res://scripts/arena/arena_prototype.gd.")
	quit(2) # Distinct non-success status: retirement is never a green check.
