extends SceneTree
## Highbank in play with its new ground (Claude, 2026-10-10): the upper street by the hall, and the
## landing by the river. Windowed only.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/town_view_capture.gd

const TeamState := preload("res://scripts/town/team_state.gd")


func _initialize() -> void:
	_run.call_deferred()


func _snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://docs/world/highbank-ground-2026-10-10/%s.png" % name))
	print("saved ", name)


func _run() -> void:
	TeamState.start([[0, 0], [1, 0]])
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	# The tiles are anchors of the town's areas (lane A, Claude, 2026-10-26): (24,10), (20,21) and (32,26) in today's map;
	# with Highbank v2 on, the town goes into each anchor's area first.
	var Layout: GDScript = town.Layout
	for spot in [["street", "view_street"], ["terrace", "view_terrace"], ["landing", "view_landing"]]:
		town.enter_area(Layout.anchor_area(spot[1]), spot[1])
		town.team[0]["pos"] = Layout.anchor(spot[1])
		town._place(town.team[0])
		for k in 12:
			await process_frame
		await _snap("play_" + spot[0])
	quit()
