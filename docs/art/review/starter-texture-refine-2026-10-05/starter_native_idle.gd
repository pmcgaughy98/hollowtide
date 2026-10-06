extends SceneTree
const OUT := "C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/starter-texture-review-2026-10-05/proof/"
func _initialize() -> void:
	_run()
func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var id: String = args[0]
	var c: CreatureData = load("res://data/creatures/" + id + ".tres")
	assert(c != null and c.sprite != null and c.back_sprite != null)
	var holder := Node2D.new()
	root.add_child(holder)
	var b: CanvasLayer = load("res://scripts/battle_screen.gd").new()
	b.player_creature = c
	holder.add_child(b)
	await process_frame
	b.start(c)
	await create_timer(1.7, true).timeout
	assert(b._player_sprite.texture == c.back_sprite, "Wrong rear binding")
	assert(b._foe_sprite.texture == c.sprite, "Wrong front binding")
	assert(b._phase == b.Phase.CHOOSING, "Not ready to choose")
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(OUT)
	var filename := OUT + id + "_native_idle.png"
	var err := root.get_texture().get_image().save_png(filename)
	assert(err == OK)
	var report := {
		"creature": id,
		"front_path": c.sprite.resource_path,
		"rear_path": c.back_sprite.resource_path,
		"front_zoom": b._foe_sprite.scale.x,
		"rear_zoom": b._player_sprite.scale.x,
		"battle_size": c.battle_size,
		"essence": c.essence,
		"has_second_essence": c.has_second_essence,
		"second_essence": c.second_essence,
		"evolves_into": c.evolves_into.resource_path if c.evolves_into != null else "",
		"front_texture_exact": true,
		"rear_texture_exact": true,
		"native_idle": filename,
		"normal_near_side_message_box_occlusion": true,
		"attacks_catching_evolution_not_exercised": true
	}
	var f := FileAccess.open(OUT + id + "_native_idle.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(report, "\t"))
	f.close()
	print("STARTER_NATIVE_OK ", JSON.stringify(report))
	quit(0)
