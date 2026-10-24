extends SceneTree
## Stormwick's lightbulb kit stills (Claude, 2026-10-07): staged Wick Bolt, Raptor Rake and
## Flashstep and saved close-ups to user://arena_captures/.
## Retired (Claude, 2026-10-24, H31): Stormwick's kit is now Pounce, Ember Feint (replaced
## Flashstep on 2026-10-08), Lantern Volley and Lantern Tackle, so the moves this staged are in
## no kit. The old staging code is in git history. Deleting the file is Preston's call.
##   Current checks: arena_abilities_check.gd (Ember Feint charges, Lantern Volley, the pounce)
##   and arena_tackle_check.gd (marks and the Lantern Tackle zip).

func _initialize() -> void:
	print("RETIRED: arena_stormwick_check staged Wick Bolt, Raptor Rake and Flashstep, which Stormwick no longer has; no assertions ran.")
	print("Use res://tools/debug/arena_abilities_check.gd and res://tools/debug/arena_tackle_check.gd for the current kit.")
	quit(2) # Distinct non-success status: retirement is never a green check.
