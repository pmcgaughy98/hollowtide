extends SceneTree
const OUT := "C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/area-transition-review/"
var journey: Node2D
func _initialize() -> void:
	call_deferred("_run")
func frames(count: int) -> void:
	for i in count: await process_frame
func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+label+".png")
func _run() -> void:
	journey=load("res://scenes/world_journey.tscn").instantiate()
	root.add_child(journey)
	current_scene=journey
	await frames(45)
	await capture("installed-home-gameplay")
	# These overviews are review-only placements, not traversal evidence.
	var camera: Camera2D=journey.active_area.get_node("Player/Camera2D")
	camera.zoom=Vector2.ONE
	journey.active_area.get_node("Player").position=Vector2(512,416)
	await frames(3)
	await capture("installed-home-overview")
	journey.travel("route1",Vector2(-720,512),Vector2.RIGHT)
	await frames(45)
	await capture("installed-route-approach")
	journey.travel("riverfront",Vector2(320,512),Vector2.RIGHT)
	await frames(45)
	await capture("installed-riverfront-gameplay")
	camera=journey.active_area.get_node("Player/Camera2D")
	camera.zoom=Vector2.ONE
	journey.active_area.get_node("Player").position=Vector2(512,416)
	await frames(3)
	await capture("installed-riverfront-overview")
	print("AREA_RENDER_OK ",journey.active_id," ",journey.transitions)
	journey.queue_free()
	current_scene=null
	journey=null
	await frames(10)
	quit()
