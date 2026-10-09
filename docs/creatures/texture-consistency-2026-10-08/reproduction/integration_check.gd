extends SceneTree
const Finish = preload("res://scripts/arena/creature_finish.gd")
const OUT = "D:/dev/hollowtide-texture-consistency-20261008/"
var failures: Array[String] = []
func _initialize() -> void:call_deferred("run")

func run() -> void:
	var arena: Node2D = load("res://scenes/arena_prototype.tscn").instantiate()
	arena.picker_redirect = false
	arena.match_horn = false
	arena.rocks_on = false
	arena.poll_input = false
	arena.teams_override = [[[1,2],[6,2],[5,2]],[[8,2],[7,2],[2,2]]]
	root.add_child(arena)
	await process_frame
	arena.set_process(false)
	for i in arena._fighters.size():
		var f: Dictionary = arena._fighters[i]
		f.body.position = arena._floor().get_center()+Vector2(-70+70*(i%3),-18+52*(i/3))
		arena._set_texture(f,f.art.still.se)
	arena._hud.queue_redraw()
	await frames(2)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"arena-six-after.png")
	for f in arena._fighters:f.sprite.material=null
	await frames(2)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"arena-six-before.png")
	for f in arena._fighters:Finish.apply(f.sprite)
	arena.set_process(true)
	arena.auto_you = true
	await frames(180)
	for f in arena._fighters:
		if f.sprite.material == null or f.sprite.material.shader != Finish.SHADER:failures.append(f.name+" lost material")
	print("Six combat sprites retain finish through movement and effects: ",failures.is_empty())
	arena.queue_free()
	await process_frame
	var hollow: Node2D = load("res://scenes/hollow_floor.tscn").instantiate()
	hollow.floor_seed=4242
	hollow.party=[[1,1],[8,1],[6,1]]
	hollow.poll_input=false
	root.add_child(hollow)
	await frames(10)
	for f in hollow._fighters:
		if f.sprite.material == null or f.sprite.material.shader != Finish.SHADER:failures.append(f.name+" hollow missing finish")
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"hollow-after.png")
	print("Hollow allies and wild creatures inherit finish: ",failures.is_empty())
	hollow.queue_free()
	await process_frame
	# Alpha/tint must apply to the repaired contour as well as the original body.
	var view:=SubViewport.new()
	view.size=Vector2i(96,96)
	view.transparent_bg=true
	root.add_child(view)
	var spr:=Sprite2D.new()
	spr.position=Vector2(48,48)
	spr.texture=load("res://assets/sprites/arena/starward/small/se.png")
	Finish.apply(spr)
	view.add_child(spr)
	spr.modulate.a=0
	await frames(2)
	await RenderingServer.frame_post_draw
	if view.get_texture().get_image().get_used_rect().has_area():failures.append("Outline ignores alpha")
	print("Creature and outline both disappear at zero alpha: ",failures.is_empty())
	view.queue_free()
	await process_frame
	var file:=FileAccess.open(OUT+"integration-checks.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":["six fighters moving and effects","Hollow allies and wild spawns","zero alpha includes contour"],"failures":failures},"  "))
	file.close()
	quit(0 if failures.is_empty() else 1)

func frames(n:int) -> void:
	for i in n:await process_frame
