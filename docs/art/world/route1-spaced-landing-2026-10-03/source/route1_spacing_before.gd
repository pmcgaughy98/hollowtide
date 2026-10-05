extends SceneTree
const OUT := "C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/route1-spaced-landing-review/"
func _initialize() -> void: call_deferred("_run")
func frames(count: int) -> void:
	for i in count: await process_frame
func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+label+".png")
func _run() -> void:
	var journey: Node2D=load("res://scenes/world_journey.tscn").instantiate()
	journey.initial_area="route1"
	root.add_child(journey); current_scene=journey
	await frames(35)
	var courier: Node2D=journey.active_area.get_node("Player")
	var camera: Camera2D=courier.get_node("Camera2D")
	# Manual review placements are visual evidence, not traversal proof.
	courier.set_physics_process(false);courier.position=Vector2(250,330)
	camera.zoom=Vector2.ONE;camera.reset_smoothing()
	await frames(5);await capture("before-core-overview")
	camera.zoom=Vector2.ONE*3;courier.position=Vector2(398,268);camera.reset_smoothing()
	await frames(5);await capture("before-cluster-gameplay")
	journey.queue_free();current_scene=null;journey=null
	await frames(10);quit()
