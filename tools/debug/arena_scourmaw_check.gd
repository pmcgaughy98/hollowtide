extends SceneTree
## Superseded on 2026-10-09: the Rimefin line was rekit as the ambusher (Needle Bite, Lunge,
## Silt Dive, Riptide, the Ambush passive, Undertow). Phase and Deep Jet are no longer in any
## kit, so this check's steps no longer apply. Run tools/debug/arena_ambusher_check.gd instead.
## Retired (Claude, 2026-10-24, H29): it says RETIRED and quits with 2, so the runner lists it
## as retired rather than as a check that ran. Deleting the file is Preston's call.

func _initialize() -> void:
	print("RETIRED: arena_scourmaw_check staged Phase and Deep Jet, which left every kit on 2026-10-09; no assertions ran.")
	print("Use res://tools/debug/arena_ambusher_check.gd for the Rimefin line's ambusher kit.")
	quit(2) # Distinct non-success status: retirement is never a green check.
