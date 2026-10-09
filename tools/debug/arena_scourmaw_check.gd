extends SceneTree
## Superseded on 2026-10-09: the Rimefin line was rekit as the ambusher (Needle Bite, Lunge,
## Silt Dive, Riptide, the Ambush passive, Undertow). Phase and Deep Jet are no longer in any
## kit, so this check's steps no longer apply. Run tools/debug/arena_ambusher_check.gd instead.

func _initialize() -> void:
	print("arena_scourmaw_check is superseded; run arena_ambusher_check.gd")
	quit()
