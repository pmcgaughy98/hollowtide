extends SceneTree
## Checks the player's back view steps through its back_idle_frames in battle (Claude, 2026-10-06).
##   Godot --path . --script res://tools/debug/back_idle_check.gd -- <player> <foe>
func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var holder := Node2D.new(); root.add_child(holder)
	var b: CanvasLayer = load("res://scripts/battle_screen.gd").new()
	b.player_creature = load("res://data/creatures/" + a[0] + ".tres")
	holder.add_child(b)
	await process_frame
	b.start(load("res://data/creatures/" + a[1] + ".tres"))
	var seen := {}
	for i in 12:
		await create_timer(0.17, true).timeout
		seen[b._player_sprite.texture.resource_path.get_file()] = true
	print(a[0], " player side showed: ", seen.keys())
	quit()
