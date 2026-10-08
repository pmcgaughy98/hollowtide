extends SceneTree
## Stages Stormwick's lightbulb kit and saves close-up stills (Claude, 2026-10-07).
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_stormwick_check.gd
## Saves user://arena_captures/storm_<n>.png and a contact sheet of crops around Stormwick.
var OUT := ProjectSettings.globalize_path("user://arena_captures/")
var arena: Node2D
var shots: Array[Image] = []

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	await process_frame
	arena._you = 0; arena._you_stage = 2; arena._rival = 1; arena._rival_stage = 1
	arena._new_match()
	var me: Dictionary = arena._fighters[0]
	var foe: Dictionary = arena._fighters[1]
	foe["ai"] = true
	me["body"].position = Vector2(150, 140)
	foe["body"].position = Vector2(225, 125)
	# Lantern at rest, then half charged, then full (white-hot).
	for c in [0.0, 55.0, 100.0]:
		me["charge"] = c
		await _hold(4)
		await _snap()
	me["charge"] = 0.0
	# Wick Bolt and the smoulder it leaves.
	arena._do_move(0, "wick_bolt", foe)
	await _hold(2)
	await _snap()
	await _hold(14)
	await _snap()
	# Raptor Rake up close.
	me["body"].position = foe["body"].position + Vector2(-16, 4)
	arena._do_move(0, "claw", foe)
	await _hold(2)
	await _snap()
	# Flashstep back out.
	arena._do_move(0, "flashstep", foe)
	await _hold(2)
	await _snap()
	await _hold(5)
	await _snap()
	_sheet()
	print("saved ", shots.size(), " stills; rival hp ", foe["hp"], "/", foe["max_hp"])
	quit()

func _hold(frames: int) -> void:
	arena._fighters[1]["act"] = 9.0   # keep the rival still so the shots are clean
	for i in frames:
		await process_frame

func _snap() -> void:
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	img.save_png(OUT + "storm_%d.png" % shots.size())
	shots.append(img)

## Crops round the two creatures, side by side.
func _sheet() -> void:
	var w := 480
	var h := 300
	var sheet := Image.create(w * 4, h * 2, false, Image.FORMAT_RGBA8)
	for k in shots.size():
		var crop := shots[k].get_region(Rect2i(300, 220, w, h))
		sheet.blit_rect(crop, Rect2i(0, 0, w, h), Vector2i((k % 4) * w, (k / 4) * h))
	sheet.save_png(OUT + "storm_sheet.png")
