extends SceneTree
const W := "D:/dev/hollowtide-pilot-waking-20261010/"
func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
	for k in n: await process_frame
func run() -> void:
	root.size=Vector2i(1152,648)
	DirAccess.make_dir_recursive_absolute(W+"review/before/")
	var pro:Node=load(W+"originals/scripts/creature_prologue.gd").new()
	pro.hero=1;pro.partner=2;pro.chosen_by_soul=true;pro.reduce_motion=true
	root.add_child(pro)
	for phase in 3:
		pro.phase=phase
		await frames(8)
		pro.refresh()
		await frames(6);await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(W+"review/before/wake-%d.png"%phase)
	for n in root.get_children():n.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await frames(12)
	print("BEFORE captured the unmodified original waking script")
	quit()
