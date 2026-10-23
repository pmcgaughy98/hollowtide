extends SceneTree
## One still with the heavy finals and the ferret side by side, held still, to judge sizes
## (Preston, 2026-10-08: "fix sizes"). Godot --path . --fixed-fps 30 --script res://tools/debug/arena_sizes_check.gd
func _initialize() -> void:
	var arena: Node2D = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	arena.rocks_on = false
	arena.team_size = 3
	arena._you = 6; arena._you_stage = 2       # Starward, Stormwick, Rampartroot
	arena._rival = 3; arena._rival_stage = 2   # Ironvent, Vitrecrag, Oxbowarchon
	arena.teams_override = [[[6, 2], [0, 2], [1, 2]], [[3, 2], [4, 2], [5, 2]]]   # the lineup above; the filled-in lines moved when lines 7-10 joined
	arena._new_match()
	await process_frame
	var x := 70.0
	var line := ""
	for f in arena._fighters:
		f["rooted"] = 60.0   # held in place without the stun tint
		f["act"] = 60.0
		f["body"].position = Vector2(x, 150)
		f["facing"] = "s"
		var used: Rect2 = f["sprite"].texture.get_image().get_used_rect()
		line += "%s %dpx tall; " % [f["name"], int(used.size.y)]
		x += 42.0
	for k in 6:
		await process_frame
	if DisplayServer.get_name() != "headless":   # no rendered image headless; the still needs a window
		root.get_texture().get_image().save_png("res://docs/creatures/arena-feel-2026-10-07/sizes_lineup.png")
	print(line)
	quit()
