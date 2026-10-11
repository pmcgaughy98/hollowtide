extends SceneTree
const W := "D:/dev/hollowtide-waking-art-20261010/"
func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
	for k in n: await process_frame
func run() -> void:
	root.size=Vector2i(1152,648)
	DirAccess.make_dir_recursive_absolute(W+"review/before/")
	var pro:Node=load("res://scenes/creature_prologue.tscn").instantiate()
	pro.hero=1;pro.partner=2;pro.chosen_by_soul=true;pro.reduce_motion=true
	root.add_child(pro)
	await frames(8)
	# Render the original code bank as the same viewport background, retaining all real UI/actors.
	pro.bank.artwork=null
	pro.bank.background.material=null
	pro.bank.background.texture=ImageTexture.create_from_image(pro.bank.paint())
	pro.bank.queue_redraw()
	for phase in 3:
		pro.phase=phase
		await frames(8)
		pro.refresh()
		await frames(6);await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(W+"review/before/wake-%d.png"%phase)
	for n in root.get_children():n.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await frames(12)
	print("BEFORE captured the exact original code bank beneath the unchanged UI/actors")
	quit()
